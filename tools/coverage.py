#!/usr/bin/env python3
"""Report how much of the ROM is real assembly vs. still raw INCBIN.

Scans every .asm/.inc under the repo for

    INCBIN "baserom.gb", <start>, <length>
    freespace $<start>

and classifies all 262144 ROM bytes as:
  asm      - expressed as source (instructions, db/dw tables, ds fills)
  incbin   - still copied verbatim out of the base ROM
  padding  - bank tail padding re-emitted by the freespace macro

Since step 7.1 no INCBIN remains, and since 7.2 the freespace macro is gone (every
tail is an explicit `ds` fill, which counts as asm like any other source), so both
columns read 0. The patterns are kept so the tool still reads older checkouts.

Run from the repo root:  python3 tools/coverage.py [--md]
"""
import os, re, sys

ROM_SIZE = 0x40000
BANK = 0x4000

def ev(expr):
    expr = re.sub(r';.*', '', expr).strip().rstrip(',')
    expr = re.sub(r'\$([0-9A-Fa-f]+)', lambda m: str(int(m.group(1), 16)), expr)
    if not re.fullmatch(r'[0-9+\-*/()\s]+', expr):
        raise ValueError(expr)
    return eval(expr)

def scan(root='.'):
    tag = bytearray(ROM_SIZE)          # 0 = asm, 1 = incbin, 2 = padding
    incbins = freespaces = 0
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in ('.git', 'tools', 'docs')]
        for fn in filenames:
            if not fn.lower().endswith(('.asm', '.inc')):
                continue
            path = os.path.join(dirpath, fn)
            for line in open(path, encoding='utf-8', errors='replace'):
                m = re.search(r'INCBIN\s+"baserom\.gb"\s*,\s*([^,]+),\s*(.+)$', line, re.I)
                if m:
                    try: start, length = ev(m.group(1)), ev(m.group(2))
                    except ValueError: continue
                    for i in range(start, min(start + length, ROM_SIZE)): tag[i] = 1
                    incbins += 1
                    continue
                m = re.match(r'\s*freespace\s+(\$?[0-9A-Fa-f]+)\s*(;.*)?$', line)
                if m and 'MACRO' not in line:
                    try: start = ev(m.group(1))
                    except ValueError: continue
                    end = (start // BANK + 1) * BANK
                    for i in range(start, min(end, ROM_SIZE)): tag[i] = 2
                    freespaces += 1
    return tag, incbins, freespaces

def main():
    md = '--md' in sys.argv
    tag, nin, nfs = scan()
    rows = []
    for b in range(ROM_SIZE // BANK):
        seg = tag[b*BANK:(b+1)*BANK]
        a = seg.count(0); i = seg.count(1); p = seg.count(2)
        real = a + i
        rows.append((b, a, i, p, (100.0*a/real if real else 100.0)))
    ta = sum(r[1] for r in rows); ti = sum(r[2] for r in rows); tp = sum(r[3] for r in rows)
    treal = ta + ti

    if md:
        print("| Bank | Assembly | Raw INCBIN | Padding | Bank done |")
        print("|-----:|---------:|-----------:|--------:|----------:|")
        for b, a, i, p, pc in rows:
            print("| $%02X | %s | %s | %s | %s |" % (
                b, f"{a:,}", f"{i:,}", f"{p:,}",
                "n/a (empty)" if a+i == 0 else f"{pc:.1f}%"))
        print("| **Total** | **%s** | **%s** | **%s** | **%.2f%%** |" % (
            f"{ta:,}", f"{ti:,}", f"{tp:,}", 100.0*ta/treal))
    else:
        print("bank   asm   incbin  padding   done")
        for b, a, i, p, pc in rows:
            print(" $%02X %6d %8d %8d  %s" % (b, a, i, p, "   --" if a+i == 0 else "%5.1f%%" % pc))
        print("-" * 40)
        print("total %6d %8d %8d  %5.2f%%" % (ta, ti, tp, 100.0*ta/treal))
        print("\n%d INCBIN chunks, %d freespace fills" % (nin, nfs))
        print("%.1f KB of %.1f KB of real content disassembled" % (ta/1024, treal/1024))

if __name__ == '__main__':
    main()
