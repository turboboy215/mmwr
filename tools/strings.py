#!/usr/bin/env python3
"""Walk the game's screen-text records and print them.

A record is a two-byte little-endian BG tilemap destination ($9800-$9BFF),
followed by characters encoded as ASCII + $60 (with space as $6C), terminated by
$00. See docs/ROMMAP.md.

    python3 tools/strings.py                        scan bank $06
    python3 tools/strings.py --range 0x18000 0x1C000
    python3 tools/strings.py --rom other.gb --range 0x18000 0x1C000
    python3 tools/strings.py --asm                  emit RGBDS source

`--asm` prints each record as `dw` plus a `db` string, ready to replace an
INCBIN once constants/charmap.inc exists. Check the result with ./build.sh - if
the bytes do not come back identical, the charmap is wrong, not the ROM.
"""
import argparse, signal, sys

try: signal.signal(signal.SIGPIPE, signal.SIG_DFL)   # play nicely with `head`
except (AttributeError, ValueError): pass

def decode(b):
    out = []
    for x in b:
        if x == 0x6C: out.append(' ')
        elif 0x60 <= x < 0xE0 and 32 <= x - 0x60 < 127: out.append(chr(x - 0x60))
        else: out.append('{%02X}' % x)
    return ''.join(out)

def walk(d, lo, hi):
    out, i = [], lo
    while i < hi - 3:
        dest = d[i] | d[i+1] << 8
        if 0x9800 <= dest < 0x9C00:
            j, s = i + 2, []
            while j < hi and d[j] != 0 and (d[j] == 0x6C or 0x80 <= d[j] < 0xE0):
                s.append(d[j]); j += 1
            if j < hi and d[j] == 0 and len(s) >= 3:
                out.append((i, dest, bytes(s))); i = j + 1; continue
        i += 1
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--rom', default='baserom.gb')
    ap.add_argument('--range', nargs=2, type=lambda s: int(s, 0), default=[0x18000, 0x1C000])
    ap.add_argument('--asm', action='store_true')
    a = ap.parse_args()
    d = open(a.rom, 'rb').read()
    recs = walk(d, a.range[0], min(a.range[1], len(d)))
    if not recs:
        print("no records found in %05X-%05X" % tuple(a.range)); return
    # A record is only trustworthy if it abuts its neighbours. Graphics data
    # throws the occasional lone match; a run of records that tile exactly is
    # real. Report the runs, and keep isolated hits separate.
    runs, cur = [], [recs[0]]
    for prev, rec in zip(recs, recs[1:]):
        if rec[0] == prev[0] + 2 + len(prev[2]) + 1: cur.append(rec)
        else: runs.append(cur); cur = [rec]
    runs.append(cur)
    blocks = [r for r in runs if len(r) > 1]
    loners = [r[0] for r in runs if len(r) == 1]
    recs = [rec for r in blocks for rec in r]
    if not recs:
        print("only isolated matches found; none of them tile, so treat them as noise")
        for off, dest, sbytes in loners:
            print("  %05X -> $%04X  %s" % (off, dest, decode(sbytes)))
        return

    if a.asm:
        for off, dest, s in recs:
            print("\t;$%05X" % off)
            print("\tdw $%04X" % dest)
            print('\tdb "%s", 0' % decode(s).replace('"', '\\"'))
            print()
    else:
        for blk in blocks:
            end = blk[-1][0] + 2 + len(blk[-1][2]) + 1
            print("block %05X-%05X (%d bytes, %d strings)" % (
                blk[0][0], end - 1, end - blk[0][0], len(blk)))
            for off, dest, sbytes in blk:
                print("  %05X -> $%04X  %s" % (off, dest, decode(sbytes)))
            print()
        if loners:
            print("isolated matches, almost certainly data that happens to fit the shape:")
            for off, dest, sbytes in loners:
                print("  %05X -> $%04X  %s" % (off, dest, decode(sbytes)))

if __name__ == '__main__':
    main()
