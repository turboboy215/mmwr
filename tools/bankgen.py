#!/usr/bin/env python3
"""Bootstrap a ROMX bank into source: tools/bankgen.py tools/bankgen/bankNN.py

Used to take banks $01 (step 5.1) and $09 (step 5.2) from INCBIN to source in
one pass. Code is found by recursive descent from the config's ENTRIES; data
comes from its DATA items; every byte from $4000 to the config's END must be
covered exactly once, or this aborts. Names, comments and operand overrides
come from the config, labels for ROM0 and RAM from mmwr.sym (so build first).

It writes the bank's files (the config's CHUNKS) and banks/bankNN.asm.
**It overwrites them**: once a bank's step is committed, edit the .asm by hand
and treat the config as a historical record, not the source of truth.
"""
import sys, re, os
sys.path.insert(0, 'tools')
from disasm import OPS, cb
sys.path.insert(0, os.path.join('tools', 'bankgen'))
import frames as _frames

CFG = sys.argv[1]
_pre = {}
exec(re.search(r'^BANK\s*=.*$', open(CFG).read(), re.M).group(0), _pre)
BANK = _pre['BANK']
_rom = open('baserom.gb', 'rb').read()
# the bank seen as the CPU sees it: ROM0 at $0000, this bank at $4000
d = _rom[:0x4000] + _rom[BANK * 0x4000:(BANK + 1) * 0x4000]
_frames.d = d
parse_frames, msprite_len = _frames.parse, _frames.msprite_len
w = lambda a: d[a] | d[a+1] << 8

cfg = {'ROM': d}
exec(open(CFG).read(), cfg)
LO, HI = 0x4000, cfg['END']
PFX = '%02X' % BANK
ENTRIES = cfg['ENTRIES']; DATA = cfg['DATA']; NAMES = cfg['NAMES']
COMMENTS = cfg.get('COMMENTS', {}); OPER = cfg.get('OPER', {})
INLINE = cfg.get('INLINE', {}); HEADER = cfg['HEADER']; FOOTER = cfg['FOOTER']
LOCALNAMES = cfg.get('LOCALNAMES', {})
CHUNKS = cfg['CHUNKS']; FILEHEAD = cfg['FILEHEAD']

# ---------------------------------------------------------------- symbols
romsym, ramsym = {}, {}
for l in open('mmwr.sym'):
    m = re.match(r'^([0-9A-Fa-f]{2}):([0-9A-Fa-f]{4}) (\S+)$', l.strip())
    if not m: continue
    b, a, n = int(m.group(1), 16), int(m.group(2), 16), m.group(3)
    if n.endswith('End') or n.startswith('Bank1') and False: pass
    if a < 0x4000:
        if b == 0:
            # prefer a global name over a local one
            if a not in romsym or ('.' in romsym[a] and '.' not in n): romsym[a] = n
    elif a >= 0x8000:
        if '.' in n: continue
        ramsym.setdefault(a, n)
# sizes of RAM labels, from the ds lines
ramsize = {}
for f in ('ram/wram.asm', 'ram/hram.asm'):
    for l in open(f):
        m = re.match(r'^(\w+)::?\s+ds\s+([^;]+)', l)
        if m:
            v = m.group(2).strip().replace('$', '0x')
            try: ramsize[m.group(1)] = eval(v)
            except Exception: pass
HW = {0x00:'rJOYP',0x0F:'rIF',0x40:'rLCDC',0x41:'rSTAT',0x42:'rSCY',0x43:'rSCX',
      0x44:'rLY',0x45:'rLYC',0x46:'rDMA',0x47:'rBGP',0x48:'rOBP0',0x49:'rOBP1',
      0x4A:'rWY',0x4B:'rWX',0xFF:'rIE'}

def ramname(v):
    if v in ramsym:
        n = ramsym[v]
        if n.startswith('h') and v < 0xFF80: pass
        return n
    # inside a sized label?
    for back in range(1, 0x80):
        a = v - back
        if a in ramsym and ramsize.get(ramsym[a], 0) > back:
            return "%s + $%02X" % (ramsym[a], back) if back > 9 else "%s + %d" % (ramsym[a], back)
    return None

# ---------------------------------------------------------------- data items
items = []      # (start, end, name, kind, extra)
labels = {}     # addr -> name (globals in bank 1)
for it in DATA:
    s, e, name, kind = it[:4]
    extra = it[4] if len(it) > 4 else {}
    if kind == 'frames':
        hb = extra.get('hitbox', True)
        for k, a, b in parse_frames(s, e, extra['tables'], extra.get('frames', []), hitbox=hb):
            assert k != 'gap', ('gap in frames', hex(a), hex(b))
            nm = NAMES.get(a) or ('%s_%s%04X' % ('FrameTable' if k == 'table' else 'Frame', cfg.get('FRAMEPFX', ''), a))
            items.append((a, b, nm, 'ftable' if k == 'table' else ('frame' if hb else 'msprite'), {}))
        continue
    if 'labels' in extra:
        extra['labels'] = {a: NAMES.get(a, n) for a, n in extra['labels'].items()}
    items.append((s, e, NAMES.get(s) or name or 'Data_%s_%04X' % (PFX, s), kind, extra))
for s, e, nm, k, x in items:
    labels[s] = nm
    if k == 'anim':
        p = s
        while p < e:
            if p != s:
                x.setdefault('labels', {}).setdefault(p, NAMES.get(p, 'Data_%s_%04X' % (PFX, p)))
            q = p + 3
            while d[q] != 0xFF: q += 1
            p = q + 1
    for sub, subname in x.get('labels', {}).items():
        labels[sub] = subname
indata = {}
for s, e, nm, k, x in items:
    for a in range(s, e):
        assert a not in indata, ('data overlap', hex(a))
        indata[a] = s

# ---------------------------------------------------------------- code trace
def ilen(a):
    op = d[a]
    if op == 0xCB: return 2
    return OPS[op][1] if op in OPS else None
JR = {0x18,0x20,0x28,0x30,0x38}; JP = {0xC3,0xC2,0xCA,0xD2,0xDA}; CALL = {0xCD,0xC4,0xCC,0xD4,0xDC}
seen = {}; calls = set(ENTRIES); jumps = set(); refs = {}   # target -> set of source pcs
work = list(ENTRIES)
while work:
    pc = work.pop()
    while LO <= pc < HI and pc not in seen:
        assert pc not in indata, ('code runs into data', hex(pc))
        n = ilen(pc); assert n, ('bad opcode', hex(pc))
        seen[pc] = n; op = d[pc]
        if op in JR:
            o = d[pc+1]; o = o - 256 if o > 127 else o; t = pc + 2 + o
            work.append(t); jumps.add(t); refs.setdefault(t, set()).add(pc)
            if op == 0x18: break
        elif op in JP | CALL:
            t = w(pc+1)
            if LO <= t < 0x8000:
                work.append(t); refs.setdefault(t, set()).add(pc)
                (calls if op in CALL else jumps).add(t)
            if op == 0xC3: break
        elif op in (0xC9, 0xD9, 0xE9): break
        pc += n
code = set()
for a, n in seen.items():
    for k in range(a, a+n):
        assert k not in indata, ('code/data overlap', hex(k))
        code.add(k)
missing = [a for a in range(LO, HI) if a not in code and a not in indata]
if missing:
    runs = []; st = missing[0]; pv = st
    for a in missing[1:]:
        if a != pv + 1: runs.append((st, pv+1)); st = a
        pv = a
    runs.append((st, pv+1))
    print('UNCOVERED:', ' '.join('%04X-%04X' % r for r in runs), file=sys.stderr)
    if os.environ.get('BANKGEN_DUMP'):
        # for working out what the gaps are: the traced code and the gaps
        import json
        json.dump({'seen': {str(a): n for a, n in seen.items()}, 'gaps': runs},
                  open(os.environ['BANKGEN_DUMP'], 'w'))
    sys.exit(1)

# ---------------------------------------------------------------- labels
glob = set(calls) | set(ENTRIES) | set(labels) | {a for a in NAMES if a in seen}
# targets jumped to from another routine become global
def parent_of(a):
    best = None
    for g in glob:
        if g <= a and (best is None or g > best): best = g
    return best
changed = True
while changed:
    changed = False
    gl = sorted(glob)
    import bisect
    def par(a):
        k = bisect.bisect_right(gl, a) - 1
        return gl[k] if k >= 0 else None
    for t in sorted(jumps):
        if t in glob or t not in seen: continue
        if any(par(s) != par(t) for s in refs.get(t, ())):
            glob.add(t); changed = True
gl = sorted(glob)
import bisect
def par(a):
    k = bisect.bisect_right(gl, a) - 1
    return gl[k] if k >= 0 else None
def gname(a):
    if a in NAMES: return NAMES[a]
    if a in labels: return labels[a]
    return 'Func_%s_%04X' % (PFX, a)
def lname(a):
    if a in LOCALNAMES: return LOCALNAMES[a]
    sh = cfg.get('SHARED')
    if sh and sh[1] <= a < sh[2]: return '.o%03X' % (a - sh[1])
    return '.l%04X' % a
# name for any bank-1 address from context pc
def b1(a, ctx):
    if a in glob: return gname(a)
    if a in jumps and a in seen:
        n = lname(a)
        return n if par(a) == par(ctx) else gname(par(a)) + n
    if a in labels: return labels[a]
    return None

def romname(v):
    return romsym.get(v)

# ---------------------------------------------------------------- emit code
def fmt(pc):
    op = d[pc]
    if pc in INLINE: return INLINE[pc]
    if pc in OPER and '@@' in OPER[pc]:
        OPER[pc] = re.sub(r'@@([0-9A-F]{4})', lambda m: b1(int(m.group(1), 16), pc), OPER[pc])
    if op == 0xCB: return cb(d[pc+1])
    m, l = OPS[op]; raw = d[pc:pc+l]
    if '{n16}' in m:
        v = raw[1] | raw[2] << 8
        s = OPER.get(pc)
        if s is None:
            if op in JP | CALL:
                s = b1(v, pc) if LO <= v < 0x8000 else (romname(v) or ramname(v) if v >= 0xC000 else romname(v))
            elif op in (0x01, 0x11, 0x21):      # ld rr, n16
                if LO <= v < HI:
                    s = b1(v, pc)
                    if s is None: WARN.append('ld rr at %04X -> unlabelled %04X' % (pc, v))
                elif 0xC000 <= v < 0xFF80: s = ramname(v)
            elif op in (0xEA, 0xFA):
                if v >= 0xC000: s = ramname(v)
                if v >= 0xFF00 and (v & 0xFF) in HW: s = HW[v & 0xFF]
        m = m.replace('{n16}', s or '$%04X' % v)
    if '{n8}' in m:
        s = OPER.get(pc)
        m = m.replace('{n8}', s or '$%02X' % raw[1])
    if '{a8}' in m:
        a8 = raw[1]
        s = HW.get(a8) if (a8 < 0x80 or a8 == 0xFF) else ramsym.get(0xFF00 | a8)
        m = m.replace('{a8}', s or '$FF%02X' % a8)
    if '{e8}' in m:
        o = raw[1] - 256 if raw[1] > 127 else raw[1]
        if m.startswith('jr'):
            m = m.replace('{e8}', b1(pc + 2 + o, pc))
        else:
            m = m.replace('{e8}', '%+d' % o)
    return m

def dval(v, ctx):
    if LO <= v < HI:
        n = b1(v, ctx)
        if n: return n
        WARN.append('dw in %04X -> unlabelled %04X' % (ctx, v))
    return '$%04X' % v

WARN = []
out = []
out += HEADER.rstrip('\n').split('\n')
pc = LO
cur = None
while pc < HI:
    if pc in CHUNKS:
        out.append('@@CHUNK %s|%s|%04X' % (CHUNKS[pc][0], CHUNKS[pc][1], pc))
    if pc in COMMENTS and (pc in glob or pc in indata and indata[pc] == pc):
        out.append('')
        out += [(';' + c if c else ';') for c in COMMENTS[pc].split('\n')]
    elif pc in glob and pc in seen:
        out.append('')
    if pc in seen:
        if pc in glob:
            out.append('%s:\t;$%04X' % (gname(pc), pc))
        elif pc in jumps:
            out.append(lname(pc))
        out.append('\t' + fmt(pc))
        pc += seen[pc]
        continue
    # data item
    s = pc; it = [x for x in items if x[0] == s][0]
    _, e, nm, kind, x = it
    if not (pc in COMMENTS): out.append('')
    out.append('%s:\t;$%04X' % (nm, s))
    width = x.get('width', 8)
    sub = x.get('labels', {})
    def rows(a, b, kind_, width_):
        res = []
        p = a
        while p < b:
            # break at sub labels
            q = min([b] + [k for k in sub if p < k < b])
            if kind_ == 'dw':
                vals = [dval(w(r), s) for r in range(p, q, 2)]
                for i in range(0, len(vals), width_):
                    res.append('\tdw ' + ', '.join(vals[i:i+width_]))
            else:
                vals = ['$%02X' % d[r] for r in range(p, q)]
                for i in range(0, len(vals), width_):
                    res.append('\tdb ' + ', '.join(vals[i:i+width_]))
            if q < b:
                res.append('%s:\t;$%04X' % (sub[q], q))
            p = q
        return res
    if kind in ('db', 'dw'):
        out += rows(s, e, kind, width if kind == 'db' else x.get('width', 4))
    elif kind == 'raw':
        out += [re.sub(r'@@([0-9A-F]{4})', lambda m: dval(int(m.group(1), 16), s), ln) for ln in x['lines']]
    elif kind == 'anim':
        p = s
        while p < e:
            if p != s:
                out.append('%s:\t;$%04X' % (sub.get(p, 'Data_%s_%04X' % (PFX, p)), p))
                labels[p] = sub.get(p, 'Data_%s_%04X' % (PFX, p))
            q = p + 3
            while d[q] != 0xFF: q += 1
            out.append('\tdw %s' % dval(w(p), s))
            out.append('\tdb %d\t;frames per step' % d[p+2])
            out.append('\tdb ' + ', '.join('$%02X' % d[r] for r in range(p+3, q)) + ', $FF')
            p = q + 1
        assert p == e, ('anim overrun', hex(s))
    elif kind == 'ftable':
        vals = [dval(w(r), s) for r in range(s, e, 2)]
        for i in range(0, len(vals), 4):
            out.append('\tdw ' + ', '.join(vals[i:i+4]))
    elif kind in ('frame', 'msprite'):
        p = s
        if kind == 'frame':
            out.append('\tdb ' + ', '.join('$%02X' % d[r] for r in range(p, p+4)) + '\t;hitbox')
            p += 4
            if p in sub or (p in labels and labels[p] != nm):
                pass
        g = d[p+2]; n = (g >> 4) * (g & 15)
        out.append('\tdb $%02X, $%02X, $%02X' % (d[p], d[p+1], g) + '\t;dx, dy, %dx%d' % (g >> 4, g & 15))
        p += 3
        if g:
            if n:
                out.append('\tdb ' + ', '.join('$%02X' % d[r] for r in range(p, p+n)))
            p += n
            while d[p] != 0x80:
                out.append('\tdb $%02X, $%02X, $%02X' % (d[p], d[p+1], d[p+2])); p += 3
            out.append('\tdb $80')
            p += 1
        assert p == e, ('frame length', hex(s), hex(p), hex(e))
    else:
        raise SystemExit('unknown kind ' + kind)
    pc = e
# A shared file (the object library) is assembled into several banks: its
# SECTION line goes in the bank file, and its labels carry {VAR}.
SHARED = cfg.get('SHARED')      # (file, start, end, var, suffix)
files = {}; order = []; cur = None; secline = {}
for ln in out:
    if ln.startswith('@@CHUNK '):
        f, sec, a = ln[8:].split('|')
        if f not in files:
            files[f] = [FILEHEAD[f].rstrip('\n')]; order.append(f)
        cur = f
        s = 'SECTION "%s", ROMX[$%s], BANK[$%X]' % (sec, a, BANK)
        if SHARED and f == SHARED[0]: secline[f] = s
        else: files[f] += ['', s]
        continue
    if cur is None: continue
    files[cur].append(ln)
inc = []
for f in order:
    txt = '\n'.join(files[f]) + '\n'
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    if SHARED:
        sf, s0, s1, var, sfx = SHARED
        if f == sf:
            txt = re.sub(r'(?<=:\t);\$([0-9A-F]{4})\b', lambda m: ';+$%03X' % (int(m.group(1), 16) - s0)
                         if s0 <= int(m.group(1), 16) < s1 else m.group(0), txt)
        else:
            txt = txt.replace('{%s}' % var, sfx)
    if SHARED and f == SHARED[0] and os.path.exists(f):
        # the shared file already exists (another bank made it): it must come
        # out the same from this bank, or the shared copy is wrong somewhere
        if open(f).read() != txt:
            open(f + '.new', 'w').write(txt)
            WARN.append('%s differs from this bank\'s version: see %s.new' % (f, f))
    else:
        open(f, 'w').write(txt)
    if f in secline: inc.append(secline[f] + '\n')
    inc.append('include "%s"\n' % f)
pre = ''
if SHARED: pre = 'DEF %s EQUS "%s"\n\n' % (SHARED[3], SHARED[4])
post = ('\nPURGE %s\n' % SHARED[3]) if SHARED else ''
open('banks/bank%02x.asm' % BANK, 'w').write(HEADER.rstrip('\n') + '\n\n' + pre + ''.join(inc) + FOOTER + post)
[print('WARN', x, file=sys.stderr) for x in WARN]
print('ok: %d code bytes, %d data bytes, %d globals' % (len(code), len(indata), len(glob)), file=sys.stderr)
