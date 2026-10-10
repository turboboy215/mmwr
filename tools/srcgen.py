#!/usr/bin/env python3
"""Turn a ROM range into assemble-ready RGBDS source.

tools/disasm.py prints one instruction per line with addresses and bytes, for
reading. This emits something you can paste over an INCBIN and build:

  * every branch target inside the range gets a label; call targets (and
    anything jumped to from outside the range) are global `Func_BB_AAAA`,
    everything else is a local `.lAAAA` under the nearest global
  * operands that match a known symbol in mmwr.sym are replaced by the name,
    so run ./build.sh first to get a current symbol file
  * $FFxx hardware registers become their hardware.inc names
  * the two-instruction bank switch collapses to the `bankswitch` macro
  * ranges given with --data are emitted as `db`, --words as `dw`

    python3 tools/srcgen.py 0x855 0xCC9 --bank 0 --words 0x9F5 0xA05

It is a first draft, not a finished product. Read the output, decide what is
really code, give things real names, and let ./build.sh be the judge.
"""
import argparse, re, sys, os
sys.path.insert(0, os.path.dirname(__file__))
from disasm import OPS, cb   # reuse the opcode table
from ramrefs import blob_mask

HW = {0x00:'rJOYP',0x01:'rSB',0x02:'rSC',0x04:'rDIV',0x05:'rTIMA',0x06:'rTMA',0x07:'rTAC',
      0x0F:'rIF',0x24:'rAUDVOL',0x25:'rAUDTERM',0x26:'rAUDENA',0x40:'rLCDC',0x41:'rSTAT',
      0x42:'rSCY',0x43:'rSCX',0x44:'rLY',0x45:'rLYC',0x46:'rDMA',0x47:'rBGP',0x48:'rOBP0',
      0x49:'rOBP1',0x4A:'rWY',0x4B:'rWX',0xFF:'rIE'}
BRANCH = {0x18,0x20,0x28,0x30,0x38}                     # jr
JP16   = {0xC3,0xC2,0xCA,0xD2,0xDA}
CALL16 = {0xCD,0xC4,0xCC,0xD4,0xDC}

def load_syms(path):
    rom, ram = {}, {}
    if not os.path.exists(path): return rom, ram
    for l in open(path):
        m = re.match(r'^([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4})\s+(\S+)$', l.strip())
        if not m: continue
        b, a, n = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
        if '.' in n or n.endswith('End'): continue   # end markers are never targets
        if a >= 0xC000: ram.setdefault(a, n)
        else: rom.setdefault((b, a), n)
    return rom, ram

def all_rom_syms(path):
    """(bank, address) of every ROM symbol, local labels included."""
    out = []
    if not os.path.exists(path): return out
    for l in open(path):
        m = re.match(r'^([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4})\s+(\S+)$', l.strip())
        if m and int(m.group(2), 16) < 0x8000:
            out.append((int(m.group(1), 16), int(m.group(2), 16)))
    return out

def decode(d, i):
    op = d[i]
    if op == 0xCB: return ('cb', 2)
    if op not in OPS: return (None, 1)
    return (OPS[op][0], OPS[op][1])

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('start'); ap.add_argument('end')
    ap.add_argument('--bank', type=lambda s: int(s, 0), default=0)
    ap.add_argument('--data', nargs=2, action='append', default=[])
    ap.add_argument('--words', nargs=2, action='append', default=[])
    ap.add_argument('--rom', default='baserom.gb')
    ap.add_argument('--sym', default='mmwr.sym')
    ap.add_argument('--trace', action='store_true',
                    help='follow control flow from the entry points; bytes never '
                         'reached are emitted as data')
    ap.add_argument('--entry', nargs='+', default=[],
                    help='extra entry points (CPU addresses) for --trace')
    a = ap.parse_args()
    d = open(a.rom, 'rb').read()
    S, E, bank = int(a.start, 0), int(a.end, 0), a.bank
    base = 0 if bank == 0 else 0x4000
    def cpu(off): return base + off - bank * 0x4000
    def off(cpuaddr): return bank * 0x4000 + cpuaddr - base if bank else cpuaddr
    lo, hi = cpu(S), cpu(E)
    data = [(int(x, 0), int(y, 0), 'db') for x, y in a.data] + \
           [(int(x, 0), int(y, 0), 'dw') for x, y in a.words]
    def in_data(o):
        for s, e, k in data:
            if s <= o < e: return (s, e, k)
        return None
    romsym, ramsym = load_syms(a.sym)

    if a.trace:
        # recursive descent: anything not reached from an entry point is data
        entries = {lo} | {int(x, 0) for x in a.entry}
        blob = blob_mask(len(d))
    # Sync points for checking that a byte-scan "caller" in already-assembled
    # code really is an instruction: every symbol, locals included. Decoding
    # linearly from the nearest one at or before the caller has to land on it.
    import bisect
    sync = sorted(set(bb * 0x4000 + (aa - (0x4000 if bb else 0))
                      for bb, aa in all_rom_syms(a.sym)))
    def on_boundary(j):
        k = bisect.bisect_right(sync, j) - 1
        if k < 0: return False
        p = sync[k]
        while p < j:
            p += decode(d, p)[1]
        return p == j
        for j in range(len(d) - 2):     # callers in real source, or ROM0 stubs
            if d[j] in JP16 | CALL16 and not (S <= j < E) and not blob[j]:
                t = d[j+1] | d[j+2] << 8
                if lo <= t < hi: entries.add(t)
        seen, work = set(), list(entries)
        while work:
            pc = work.pop()
            while lo <= pc < hi and pc not in seen:
                i = off(pc)
                if in_data(i): break
                m, ln = decode(d, i)
                if m is None: break
                seen.update(range(pc, pc + ln))
                op = d[i]
                if op in BRANCH:
                    o8 = d[i+1] - 256 if d[i+1] > 127 else d[i+1]
                    work.append(pc + 2 + o8)
                    if op == 0x18: break
                elif op in JP16 | CALL16:
                    work.append(d[i+1] | d[i+2] << 8)
                    if op == 0xC3: break
                elif op in (0xC9, 0xD9, 0xE9): break      # ret, reti, jp hl
                elif op == 0xCF: pc += ln + 2; continue      # rst $08 + inline dw
                pc += ln
        # every unreached run becomes a db range
        run = None
        for c in range(lo, hi):
            if c not in seen and not in_data(off(c)):
                if run is None: run = c
            elif run is not None:
                data.append((off(run), off(c), 'db')); run = None
        if run is not None: data.append((off(run), off(hi), 'db'))
        print(";srcgen: traced %d entry points; %d bytes reached, %d left as data" % (
            len(entries), len(seen), (hi - lo) - len(seen)), file=sys.stderr)

    # pass 1: decode, collect targets
    insns, targets, calls = [], set(), set()
    i = S
    while i < E:
        dr = in_data(i)
        if dr:
            insns.append((i, 'data', dr)); i = dr[1]; continue
        m, ln = decode(d, i)
        raw = d[i:i+ln]
        pc = cpu(i)
        op = d[i]
        if op in BRANCH:
            off8 = raw[1] - 256 if raw[1] > 127 else raw[1]
            targets.add(pc + 2 + off8)
        elif op in JP16 or op in CALL16:
            t = raw[1] | raw[2] << 8
            if lo <= t < hi:
                targets.add(t)
                if op in CALL16: calls.add(t)
        insns.append((i, m, ln))
        i += ln
    # anything referenced from elsewhere in the ROM by call/jp is global too -
    # but this is a byte scan, so only believe it where the target could
    # plausibly start a routine: right after a ret, jp, jr or reti
    ends = set()
    for i, m, ln in insns:
        if m != 'data' and d[i] in (0xC9, 0xD9, 0xC3, 0x18, 0xE9):
            ends.add(cpu(i) + ln)
    blob = blob_mask(len(d))
    for j in range(len(d) - 2):
        if d[j] in JP16 | CALL16 and not (S <= j < E):
            t = d[j+1] | d[j+2] << 8
            # a caller in already-disassembled code is a real caller
            # (the audio banks are source but mostly music data, so their
            # byte patterns are not evidence of a call)
            if not blob[j] and j // 0x4000 not in (0x02, 0x0A) and lo <= t < hi and (bank == 0 or j // 0x4000 in (0, bank)) and on_boundary(j):
                calls.add(t); targets.add(t); continue
            t = d[j+1] | d[j+2] << 8
            if lo <= t < hi and (bank == 0 or j // 0x4000 in (0, bank)) and t in ends:
                calls.add(t); targets.add(t)
    calls.add(lo); targets.add(lo)
    # only real instruction boundaries can carry a label; a byte-scan "caller"
    # that lands mid-instruction is data that happens to look like a call
    starts = {cpu(i) for i, m, ln in insns}
    for i, m, ln in insns:
        pass  # a data block can only be labelled at its first byte
    bad = sorted(t for t in targets if t not in starts)
    if bad:
        print(";srcgen: ignored %d target(s) that are not instruction starts: %s" % (
            len(bad), ' '.join('$%04X' % t for t in bad)), file=sys.stderr)
    targets &= starts; calls &= starts
    names = {}
    for t in sorted(targets):
        known = romsym.get((bank, t))
        names[t] = known if (known and t in calls) else (
            "Func_%02X_%04X" % (bank, t) if t in calls else ".l%04X" % t)
    parent_of, cur = {}, None
    for t in sorted(names):
        if not names[t].startswith('.'): cur = names[t]
        parent_of[t] = cur

    def ref(t):
        n = names[t]
        if not n.startswith('.'): return n
        return n  # caller decides qualification

    def sym16(v, ctx_parent):
        if lo <= v < hi and v in names:
            n = names[v]
            if n.startswith('.') and parent_of[v] != ctx_parent:
                return parent_of[v] + n
            return n
        if v >= 0xC000 and v in ramsym: return ramsym[v]
        if v < 0x4000 and (0, v) in romsym: return romsym[(0, v)]
        if bank and 0x4000 <= v < 0x8000 and (bank, v) in romsym: return romsym[(bank, v)]
        return "$%04X" % v

    # pass 2: emit
    out, cur_parent = [], None
    k = 0
    while k < len(insns):
        i, m, ln = insns[k]
        pc = cpu(i)
        if pc in names:
            n = names[pc]
            if not n.startswith('.'):
                cur_parent = n
                out.append("")
                out.append("%s:\t;$%04X" % (n, pc))
            else:
                out.append(n)
        if m == 'data':
            s, e, kind = ln
            step = 2 if kind == 'dw' else 1
            for p in range(s, e, 8 * step):
                chunk = d[p:min(e, p + 8 * step)]
                if kind == 'dw':
                    vals = [sym16(chunk[q] | chunk[q+1] << 8, cur_parent) for q in range(0, len(chunk), 2)]
                else:
                    vals = ["$%02X" % x for x in chunk]
                out.append("\t%s %s" % (kind, ', '.join(vals)))
            k += 1; continue
        raw = d[i:i+ln]
        op = raw[0]
        # bankswitch collapse
        if op == 0xEA and raw[1:3] == bytes([0x99, 0xDF]) and d[i+3:i+6] == bytes([0xEA, 0x00, 0x21]):
            out.append("\tbankswitch")
            k += 2; continue
        if m is None:
            out.append("\tdb $%02X\t;invalid opcode" % op); k += 1; continue
        if m == 'cb':
            out.append("\t" + cb(raw[1])); k += 1; continue
        txt = m
        if "{n16}" in txt:
            v = raw[1] | raw[2] << 8
            s = sym16(v, cur_parent)
            if op == 0x31 and v == 0xFFFE: s = "STACK_TOP"
            if v == 0xFFFF and op in (0xEA, 0xFA): s = "rIE"
            txt = txt.replace("{n16}", s)
        if "{n8}" in txt:  txt = txt.replace("{n8}", "$%02X" % raw[1])
        if "{a8}" in txt:
            a8 = raw[1]
            nm = HW.get(a8) if a8 < 0x80 or a8 == 0xFF else ramsym.get(0xFF00 | a8)
            txt = txt.replace("{a8}", nm or "$FF%02X" % a8)
        if "{e8}" in txt:
            off8 = raw[1] - 256 if raw[1] > 127 else raw[1]
            if txt.startswith("jr"):
                t = pc + 2 + off8
                txt = txt.replace("{e8}", sym16(t, cur_parent))
            elif txt.startswith("add sp"): txt = txt.replace("{e8}", "%d" % off8)
            else: txt = txt.replace("{e8}", "%+d" % off8)
        out.append("\t" + txt)
        k += 1
    print('\n'.join(out).lstrip('\n'))

if __name__ == '__main__':
    main()
