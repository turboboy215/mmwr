#!/usr/bin/env python3
"""Convert between Game Boy 2bpp tile data and grayscale PNG.

    python3 tools/gfx.py extract baserom.gb 0x41E 26 gfx/font.png [--width 16]
    python3 tools/gfx.py topng   in.2bpp out.png [--width 16]

Shade mapping is the DMG default that rgbgfx expects for a grayscale image:
colour 0 = white ... colour 3 = black. build.sh turns the PNGs back into .2bpp
with rgbgfx, and ./build.sh proves the round trip is exact.
"""
import sys, argparse
from PIL import Image

SHADES = [255, 170, 85, 0]

def tiles_to_png(data, out, width):
    n = len(data) // 16
    width = min(width, n)
    rows = (n + width - 1) // width
    img = Image.new('L', (width * 8, rows * 8), 255)
    px = img.load()
    for t in range(n):
        tx, ty = (t % width) * 8, (t // width) * 8
        for y in range(8):
            lo, hi = data[t*16 + y*2], data[t*16 + y*2 + 1]
            for x in range(8):
                bit = 7 - x
                c = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
                px[tx + x, ty + y] = SHADES[c]
    img.save(out)

def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest='cmd', required=True)
    e = sub.add_parser('extract'); e.add_argument('rom'); e.add_argument('start')
    e.add_argument('count', type=int); e.add_argument('out'); e.add_argument('--width', type=int, default=16)
    t = sub.add_parser('topng'); t.add_argument('src'); t.add_argument('out')
    t.add_argument('--width', type=int, default=16)
    a = ap.parse_args()
    if a.cmd == 'extract':
        d = open(a.rom, 'rb').read(); s = int(a.start, 0)
        tiles_to_png(d[s:s + a.count * 16], a.out, a.width)
    else:
        tiles_to_png(open(a.src, 'rb').read(), a.out, a.width)

if __name__ == '__main__':
    main()
