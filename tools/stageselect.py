#!/usr/bin/env python3
"""Render the stage-select robot master sprites (bank $07, step 4.4).

    python3 tools/stageselect.py baserom.gb out.png

Rebuilds sprite VRAM the way LoadStageSelectBosses does - each robot master's tileset
copied through its tile list (a count, then a source tile number per
destination tile, $FF = blank) to $8080 (Fire Man), $8360 (Cut Man), $8580 (Ice
Man) and $8820 (Elec Man) - then draws every frame of every frame list with the
metasprite format DrawSpriteGrid reads: cols << 4 | rows, rows x cols (tile,
attributes) pairs of 8x16 sprites, then (dx, dy, tile, attributes) extras up to
$80. Addresses are read from bank $07's pointer table, so this works on any
build of the ROM.
"""
import sys
from PIL import Image, ImageDraw

BANK = 0x07
SHADES = [255, 170, 85, 0]


def main(rom_path, out):
    r = open(rom_path, 'rb').read()
    o = lambda a: BANK * 0x4000 + a - 0x4000
    b = lambda a: r[o(a)]
    w = lambda a: b(a) | b(a + 1) << 8
    ptr = lambda slot: w(0x4000 + 2 * slot)   # bank $07 pointer table
    vram = bytearray(256 * 16)
    # (tileset slot, tile-list slot, destination) as in LoadStageSelectBosses
    for ts, tl, dest in ((6, 21, 0x8080), (0, 22, 0x8360), (2, 23, 0x8580), (4, 24, 0x8820)):
        n, src = b(ptr(ts)), w(ptr(ts) + 1)
        lst = w(ptr(tl))
        d = dest - 0x8000
        for i in range(b(lst)):
            t = b(lst + 1 + i)
            vram[d:d + 16] = bytes(16) if t == 0xFF else r[o(src + 16 * t):o(src + 16 * t + 16)]
            d += 16
    names = ['Fire Man', 'Cut Man', 'Ice Man', 'Elec Man']
    lists = [ptr(25 + k) for k in range(4)] + [ptr(29)]
    frames = [[w(a) for a in range(lists[k], lists[k + 1], 2)] for k in range(4)]
    img = Image.new('RGB', (80 + 6 * 48, 4 * 56), (120, 150, 200))
    px, d = img.load(), ImageDraw.Draw(img)

    def sprite(t, x0, y0, attr):
        for half in (0, 1):
            tt = (t & 0xFE) + half
            for y in range(8):
                lo, hi = vram[tt * 16 + 2 * y], vram[tt * 16 + 2 * y + 1]
                for x in range(8):
                    bit = x if attr & 0x20 else 7 - x
                    c = ((lo >> bit) & 1) | (((hi >> bit) & 1) << 1)
                    X, Y = x0 + x, y0 + half * 8 + y
                    if c and 0 <= X < img.size[0] and 0 <= Y < img.size[1]:
                        px[X, Y] = (SHADES[c],) * 3

    for row, fl in enumerate(frames):
        d.text((2, row * 56 + 20), names[row], fill=(0, 0, 0))
        for j, a in enumerate(fl):
            bx, by = 80 + j * 48 + 8, row * 56 + 16
            d.text((bx - 6, by - 14), str(j), fill=(0, 0, 0))
            cols, rows = b(a) >> 4, b(a) & 15
            p = a + 1
            for rr in range(rows):
                for c in range(cols):
                    sprite(b(p), bx + 8 * c, by + 16 * rr, b(p + 1))
                    p += 2
            while b(p) != 0x80:
                dx, dy = b(p), b(p + 1)
                sprite(b(p + 2), bx + (dx - 256 if dx > 127 else dx),
                       by + (dy - 256 if dy > 127 else dy), b(p + 3))
                p += 4
    img.resize((img.size[0] * 2, img.size[1] * 2), Image.NEAREST).save(out)
    print('wrote', out)


if __name__ == '__main__':
    main(*sys.argv[1:3])
