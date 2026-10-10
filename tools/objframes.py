#!/usr/bin/env python3
"""Render an object type's animation frames, for identifying what it is.

    python3 tools/objframes.py baserom.gb TYPE BANK START END out.png [SKIP] [7]

Draws every frame (a 4-byte hitbox, then a metasprite) whose label lies in
START..END of BANK, using mmwr.sym for the labels - so build first. Tiles come
from the type's own sprite tileset (ObjectTilesetPtrs; bank $04 for types below
$1E, bank $07 from $1E up), which is what an object's tile base normally points
at; a child object that borrows its parent's tiles will draw wrongly. Each frame
is drawn on a grey grid square with its hitbox outlined in red and the object's
origin marked in blue.

SKIP is how many tiles of the tileset come before the object's own: an object
that adds to its tile base at spawn (Changkey Maker +8, Kaminari Goro +$11,
Scworm's spawn +1) draws frame tile n from tileset tile n + SKIP. Without it
those frames come out scrambled.

A final 7 draws with 7-bit tile numbers ($CE57 set: bits 0-6 the tile, bit 7 X
flip, no Y flip), which objects with more than 64 tiles use - the Wily Machine's
Dr. Wily frames (step 5.6).
"""
import sys, re
from PIL import Image, ImageDraw

def main():
    rom = open(sys.argv[1], 'rb').read()
    typ, bank = int(sys.argv[2], 0), int(sys.argv[3], 0)
    lo, hi, outp = int(sys.argv[4], 0), int(sys.argv[5], 0), sys.argv[6]
    skip = int(sys.argv[7], 0) if len(sys.argv) > 7 else 0
    wide = len(sys.argv) > 8 and sys.argv[8] == '7'
    off = lambda b, a: b * 0x4000 + a - 0x4000 if a >= 0x4000 else a
    w = lambda o: rom[o] | rom[o + 1] << 8
    # tileset: ObjectTilesetPtrs ($249B) -> ROM0 word -> GfxPtr -> (count, source), bank 4/7
    ref = w(0x249B + 2 * (typ - 1))
    tbank = 4 if typ < 0x1E else 7
    rec = w(off(tbank, w(ref)))          # GfxPtr -> the (count, source) record
    count = rom[off(tbank, rec)]
    src = off(tbank, w(off(tbank, rec + 1)))
    tiles = [rom[src + 16 * i: src + 16 * i + 16] for i in range(count)]
    frames = []
    for l in open('mmwr.sym'):
        m = re.match(r'^([0-9a-fA-F]{2}):([0-9a-fA-F]{4}) (\S+)$', l.strip())
        if m and int(m.group(1), 16) == bank and lo <= int(m.group(2), 16) < hi and 'Frame' in m.group(3) and 'Table' not in m.group(3) and '.' not in m.group(3):
            frames.append((int(m.group(2), 16), m.group(3)))
    frames.sort()
    S = 72
    cols = 8
    rows = (len(frames) + cols - 1) // cols or 1
    img = Image.new('RGB', (cols * S, rows * (S + 10)), (255, 255, 255))
    dr = ImageDraw.Draw(img)
    pal = [(255, 255, 255), (170, 170, 170), (85, 85, 85), (0, 0, 0)]
    def tile(t, x0, y0, xf, yf):
        t += skip
        if t >= len(tiles):
            dr.rectangle([x0, y0, x0 + 7, y0 + 7], outline=(255, 0, 255)); return
        b = tiles[t]
        for y in range(8):
            lo_, hi_ = b[2 * y], b[2 * y + 1]
            for x in range(8):
                c = (lo_ >> (7 - x) & 1) | (hi_ >> (7 - x) & 1) << 1
                if c:
                    if not (0 <= x0 + x < img.width - 8 and 0 <= y0 + y < img.height - 8): continue
                    px = x0 + (7 - x if xf else x); py = y0 + (7 - y if yf else y)
                    img.putpixel((px, py), pal[c])
    for k, (a, name) in enumerate(frames):
        cx, cy = (k % cols) * S, (k // cols) * (S + 10)
        ox, oy = cx + S // 2, cy + S // 2
        dr.rectangle([cx + 1, cy + 1, cx + S - 2, cy + S - 2], fill=(230, 230, 230))
        p = off(bank, a)
        x1, x2, y1, y2 = [v - 256 if v > 127 else v for v in rom[p:p + 4]]
        p += 4
        dx, dy, g = rom[p], rom[p + 1], rom[p + 2]
        dx = dx - 256 if dx > 127 else dx; dy = dy - 256 if dy > 127 else dy
        p += 3
        ncol, nrow = g >> 4, g & 15
        if g:
            for r in range(nrow):
                for c in range(ncol):
                    t = rom[p]; p += 1
                    if t != 0xFF:
                        tile(t & (0x7F if wide else 0x3F), ox + dx + 8 * c, oy + dy + 8 * r, t & 0x80, 0 if wide else t & 0x40)
            while rom[p] != 0x80:
                tx, ty, t = rom[p], rom[p + 1], rom[p + 2]; p += 3
                tx = tx - 256 if tx > 127 else tx; ty = ty - 256 if ty > 127 else ty
                tile(t & (0x7F if wide else 0x3F), ox + dx + tx, oy + dy + ty, t & 0x80, 0 if wide else t & 0x40)
        dr.rectangle([ox + min(x1, x2), oy + min(y1, y2), ox + max(x1, x2), oy + max(y1, y2)], outline=(220, 0, 0))
        dr.point((ox, oy), fill=(0, 0, 255))
        dr.text((cx + 2, cy + S), name.replace('Frame', 'F')[-12:], fill=(0, 0, 0))
    img = img.resize((img.width * 2, img.height * 2), Image.NEAREST)
    img.save(outp)
    print('%d frames, %d tiles in tileset' % (len(frames), count))

if __name__ == '__main__':
    main()
