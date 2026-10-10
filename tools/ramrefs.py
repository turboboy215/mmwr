#!/usr/bin/env python3
"""Tally every RAM address the ROM appears to touch, with reference counts.

Scans the base ROM for the instruction forms that carry a 16-bit address or an
HRAM offset:

    EA nn nn   ld [nn], a          FA nn nn   ld a, [nn]
    21 nn nn   ld hl, nn           11 nn nn   ld de, nn
    01 nn nn   ld bc, nn           08 nn nn   ld [nn], sp
    E0 nn      ldh [$FFnn], a      F0 nn      ldh a, [$FFnn]

This is a byte scan, not a decode, so data can masquerade as an instruction.
Two things keep it honest:

  * every hit is classified as `code` or `blob` depending on whether its ROM
    offset lies in a region the source has already disassembled (i.e. outside
    every INCBIN). A hit in `code` is real; a hit in `blob` is a lead.
  * counts are reported per access form, so a single `ld hl` hit with no loads
    or stores anywhere reads as the weak evidence it is.

Usage, from the repo root:

    python3 tools/ramrefs.py                 top WRAM and HRAM addresses
    python3 tools/ramrefs.py --all           every address, no cutoff
    python3 tools/ramrefs.py --min 3         only addresses with >= 3 refs
    python3 tools/ramrefs.py --sites C108    where a given address is touched
"""
import os, re, sys, argparse, collections

ROM = 'baserom.gb'
FORMS = {0xEA: ('st',  3), 0xFA: ('ld',  3), 0x21: ('hl',  3),
         0x11: ('de',  3), 0x01: ('bc',  3), 0x08: ('sp',  3),
         0xE0: ('hst', 2), 0xF0: ('hld', 2)}

def ev(expr):
    expr = re.sub(r';.*', '', expr).strip().rstrip(',')
    expr = re.sub(r'\$([0-9A-Fa-f]+)', lambda m: str(int(m.group(1), 16)), expr)
    if not re.fullmatch(r'[0-9+\-*/()\s]+', expr):
        raise ValueError(expr)
    return eval(expr)

def blob_mask(size):
    """True where the ROM is still raw INCBIN or freespace padding."""
    mask = bytearray([0]) * size
    for dp, dn, fn in os.walk('.'):
        dn[:] = [d for d in dn if d not in ('.git', 'docs')]
        for f in fn:
            if not f.lower().endswith(('.asm', '.inc')):
                continue
            for line in open(os.path.join(dp, f), encoding='utf-8', errors='replace'):
                m = re.search(r'INCBIN\s+"baserom\.gb"\s*,\s*([^,]+),\s*(.+)$', line, re.I)
                if m:
                    try: s, n = ev(m.group(1)), ev(m.group(2))
                    except ValueError: continue
                    for i in range(s, min(s + n, size)): mask[i] = 1
                    continue
                m = re.match(r'\s*freespace\s+(\$?[0-9A-Fa-f]+)\s*(;.*)?$', line)
                if m and 'MACRO' not in line:
                    try: s = ev(m.group(1))
                    except ValueError: continue
                    for i in range(s, min((s // 0x4000 + 1) * 0x4000, size)): mask[i] = 1
    return mask

def scan():
    d = open(ROM, 'rb').read()
    blob = blob_mask(len(d))
    refs = collections.defaultdict(lambda: collections.defaultdict(int))
    sites = collections.defaultdict(list)
    i = 0
    while i < len(d) - 2:
        op = d[i]
        if op in FORMS:
            kind, ln = FORMS[op]
            addr = (0xFF00 | d[i+1]) if ln == 2 else (d[i+1] | d[i+2] << 8)
            keep = (0xC000 <= addr <= 0xDFFF) or (ln == 2 and addr >= 0xFF80)
            if keep:
                where = 'blob' if blob[i] else 'code'
                refs[addr][kind + ':' + where] += 1
                sites[addr].append((i, kind, where))
        i += 1
    return refs, sites

def total(v, where=None):
    return sum(n for k, n in v.items() if where is None or k.endswith(where))

def report(refs, lo, hi, title, minref, limit):
    rows = [(a, v) for a, v in refs.items() if lo <= a <= hi and total(v) >= minref]
    rows.sort(key=lambda r: (-total(r[1], 'code'), -total(r[1]), r[0]))
    print("\n=== %s (%d addresses) ===" % (title, len(rows)))
    print("  addr   code blob  forms (code only)")
    for a, v in rows[:limit]:
        forms = ' '.join("%s=%d" % (k.split(':')[0], n)
                         for k, n in sorted(v.items()) if k.endswith('code'))
        print("  $%04X  %4d %4d  %s" % (a, total(v, 'code'), total(v, 'blob'), forms))
    if len(rows) > limit:
        print("  ... and %d more (use --all)" % (len(rows) - limit))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--min', type=int, default=1)
    ap.add_argument('--sites')
    a = ap.parse_args()
    refs, sites = scan()
    if a.sites:
        addr = int(a.sites, 16)
        print("$%04X touched at:" % addr)
        for off, kind, where in sites.get(addr, []):
            print("  %05X  bank %02X  %-3s  %s" % (off, off // 0x4000, kind, where))
        return
    limit = 10**9 if a.all else 40
    report(refs, 0xC000, 0xDFFF, 'WRAM', a.min, limit)
    report(refs, 0xFF80, 0xFFFE, 'HRAM', a.min, limit)

if __name__ == '__main__':
    main()
