#!/usr/bin/env python3
"""Find a byte pattern in the base ROM, and optionally in other regional dumps.

Third-party documentation for this game is mostly written against the European
ROM (see docs/ROMMAP.md), so an address from a wiki or a forum post is usually
*not* our address. The reliable move is to take the byte sequence from whatever
listing you are reading and search for it.

    python3 tools/findbytes.py "3e 01 ea a1 df"
    python3 tools/findbytes.py "3E01EAA1DF" --dc 0x0857
    python3 tools/findbytes.py "21 08 c1" --also ../roms/mmwr-e.gb ../roms/rockman.gb

  --dc      an address a source claims, printed as a delta next to each hit
  --also    extra ROM files to search, for comparing regional versions
  --mask    '??' in the pattern matches any byte, e.g. "cd ?? ?? 21"
"""
import argparse, os, re, sys

def parse(pat):
    toks = re.findall(r'\?\?|[0-9A-Fa-f]{2}', pat.replace(' ', ''))
    if not toks:
        sys.exit("could not parse a byte pattern from %r" % pat)
    return [None if t == '??' else int(t, 16) for t in toks]

def find(d, pat):
    n = len(pat)
    first = next((i for i, b in enumerate(pat) if b is not None), None)
    if first is None:
        sys.exit("pattern is all wildcards")
    out, i = [], 0
    while True:
        i = d.find(bytes([pat[first]]), i)
        if i < 0 or i - first + n > len(d):
            break
        s = i - first
        if s >= 0 and all(p is None or d[s + k] == p for k, p in enumerate(pat)):
            out.append(s)
        i += 1
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('pattern')
    ap.add_argument('--dc', type=lambda s: int(s, 0), default=None)
    ap.add_argument('--also', nargs='*', default=[])
    ap.add_argument('--rom', default='baserom.gb')
    a = ap.parse_args()
    pat = parse(a.pattern)
    print("pattern: %s  (%d bytes)" % (
        ' '.join('??' if b is None else '%02X' % b for b in pat), len(pat)))
    for path in [a.rom] + a.also:
        if not os.path.exists(path):
            print("  %-28s (missing)" % os.path.basename(path)); continue
        d = open(path, 'rb').read()
        hits = find(d, pat)
        name = os.path.basename(path)
        if not hits:
            print("  %-28s no match" % name); continue
        for h in hits[:8]:
            delta = "  delta %+d" % (h - a.dc) if a.dc is not None else ""
            print("  %-28s %05X  bank $%02X:$%04X%s" % (
                name, h, h // 0x4000,
                h if h < 0x4000 else 0x4000 + (h % 0x4000), delta))
        if len(hits) > 8:
            print("  %-28s ... and %d more" % (name, len(hits) - 8))

if __name__ == '__main__':
    main()
