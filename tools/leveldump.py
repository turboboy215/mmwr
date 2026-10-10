#!/usr/bin/env python3
"""Dump and render the stage data in banks $05 and $08 (format: docs/LEVELS.md).

    python3 tools/leveldump.py baserom.gb                  text dump, all stages
    python3 tools/leveldump.py baserom.gb --stage 3        one stage
    python3 tools/leveldump.py baserom.gb --png out/       one PNG per stage
    python3 tools/leveldump.py baserom.gb --png out/ --objects
                                                           ... with spawn markers
    python3 tools/leveldump.py baserom.gb --png out/ --blocks
                                                           ... and blockset sheets

Stages are numbered as the game numbers them: the one-based StageLoadTab index
(1 Cut Man, 2 Ice Man, 3 Elec Man, 4 Fire Man, 5-7 Wily 1-3, 8 the unused
alternate Fire Man), plus 9 for the unreferenced test stage. The pairing of
stage data, data bank and tileset is read from the ROM's own tables exactly as
LoadStage and LoadStageTiles do it, so the render cannot pair a stage with the
wrong graphics:

    StageLoadTab ($00:2F93, 4-byte records) -> ROM0 pointer slot + data bank
    slot -> pointer in the data bank -> stage header
    StageTilesetPtrs ($00:248B) -> ROM0 slot -> bank $0C list of
        (count, first tile, source) records

Every room reachable from a restart point through the exit records is drawn
with that restart point's blockset, laid out by the room's X offset and stacked by
the transition direction (bit 1 of a record's flags = exit downwards). The
background palette is the one the stage's frame hook writes to wShadowBGP on its
first frame (a few stages animate it), so the shades match the real game.

Stages 1-4 (bank $05) are confirmed against the game. Stages 5-7 are the Wily
castle and 8 the unused alternate Fire Man (bank $08); 9 is an unreferenced test
stage in bank $08 that no table lists. All nine are source, so the build proves
the parse. Restart records outside a stage's table (Wily 2's boss rooms and two
orphans) are listed in EXTRA_RESTARTS, and an exit into another stage's data
(Wily 1 into Wily 2's hub) is reported rather than followed.
"""
import argparse, os, sys
from PIL import Image, ImageDraw

STAGE_LOAD_TAB = 0x2F93
STAGE_TILESET_PTRS = 0x248B     # ROM0, one-based, -> ROM0 slot -> bank $0C list
STAGE_NAMES = {9: 'wily2_test', 1: 'cut_man', 2: 'ice_man', 3: 'elec_man', 4: 'fire_man',
               5: 'wily1', 6: 'wily2', 7: 'wily3', 8: 'fire_man_alt'}
# wShadowBGP as each bank $05 stage's frame hook first sets it. Stages whose
# hook leaves the palette alone keep LoadStage's $78.
FIRST_FRAME_BGP = {1: 0x92, 2: 0xE4, 3: 0xC6, 4: 0x4F, 5: 0xE4, 6: 0xE4, 7: 0xE4,
                   8: 0x8F, 9: 0xE4}
# Stage 9 is not a StageLoadTab entry: an unreferenced stage header in bank $08
# that lays Wily 2's four room layouts side by side. Rendered with Wily 2's tiles.
UNLISTED = {9: (0x08, 0x6D05, 6)}
# Restart-point records that are not in their stage's restart table: Wily 2's
# five teleporter destinations (loaded by its hub code through
# JumpLoadRestartPoint), and one orphaned record each in Wily 1 and Wily 3.
# Rooms whose background tiles are not the stage tileset. The Wily Machine room's
# blockset (bank $08 $6B28) draws the machine itself with tiles 0-$4F of bank
# $06's Wily Machine cutscene graphics (WilyMachineGfx: a byte count, then the
# tiles at $06:7237); the room fades in from black after they are loaded. Which
# code loads them is not traced yet; the match is visual (step 4.4).
# The Wily Machine room's blockset is drawn with tiles the room loads itself:
# type 48 (WilyMachine, bank $0D) streams 80 tiles from $D:5476 to $9000 (step
# 5.6; step 4.4 had matched bank $06's look-alike cutscene tiles instead).
BLOCKSET_TILES = {(0x08, 0x6B28): (0x0D, 0x5476, 80 * 16)}
EXTRA_RESTARTS = {5: [0x40A4], 6: [0x4E04, 0x4E12, 0x4E20, 0x4E2E, 0x4E3C], 7: [0x5855]}
SHADES = [255, 170, 85, 0]


class Rom:
    def __init__(self, path):
        self.d = open(path, 'rb').read()

    def off(self, bank, addr):
        return addr if addr < 0x4000 else bank * 0x4000 + addr - 0x4000

    def b(self, bank, addr):
        return self.d[self.off(bank, addr)]

    def w(self, bank, addr):
        o = self.off(bank, addr)
        return self.d[o] | self.d[o + 1] << 8

    def bytes(self, bank, addr, n):
        o = self.off(bank, addr)
        return self.d[o:o + n]


def parse_room(rom, bank, addr):
    """A room ('sub-section'), as LoadRoom and BuildExitBoxes read it."""
    room = {'addr': addr, 'id': rom.b(bank, addr), 'routine': rom.w(bank, addr + 1),
            'layout': rom.w(bank, addr + 3), 'offset': rom.w(bank, addr + 5)}
    a = addr + 7
    exits = []
    for _ in range(2):
        if rom.b(bank, a) == 0:
            exits.append(None)
            a += 1
        else:
            exits.append({'box': rom.b(bank, a), 'column': rom.b(bank, a + 1),
                          'flags': rom.b(bank, a + 2), 'target': rom.w(bank, a + 3)})
            a += 5
    room['exits'] = exits
    spawns = []
    while rom.b(bank, a):
        t, x, y, e = rom.bytes(bank, a, 4)
        spawns.append({'type': t, 'x': x, 'y': y, 'extra': e})
        a += 4
    room['spawns'] = spawns
    room['end'] = a + 1
    lay = room['layout']
    room['width'], room['height'] = rom.b(bank, lay), rom.b(bank, lay + 1)
    room['map'] = rom.bytes(bank, lay + 2, room['width'] * room['height'])
    return room


def stage_header(rom, index):
    if index in UNLISTED:
        return UNLISTED[index][:2]
    rec = STAGE_LOAD_TAB + (index - 1) * 4
    slot, bank = rom.w(0, rec), rom.b(0, rec + 2)
    return bank, rom.w(bank, rom.w(0, slot))


def parse_restart(rom, bank, s, listed=True):
    return {'addr': s, 'blocks': rom.w(bank, s + 1), 'collision': rom.w(bank, s + 3),
            'init': rom.w(bank, s + 5), 'hook': rom.w(bank, s + 7), 'x': rom.w(bank, s + 9),
            'y': rom.b(bank, s + 11), 'room': rom.w(bank, s + 12), 'listed': listed}


def parse_stage(rom, index):
    bank, hdr = stage_header(rom, index)
    # The stage's data runs up to the next stage header in the same bank; exits
    # that leave it (Wily 1 drops into Wily 2's hub) are noted, not followed.
    heads = sorted(h for b, h in (stage_header(rom, i) for i in STAGE_NAMES) if b == bank)
    end = next((h for h in heads if h > hdr), 0x8000)
    stage = {'index': index, 'bank': bank, 'header': hdr,
             'sections_ptr': rom.w(bank, hdr), 'checkpoints_ptr': rom.w(bank, hdr + 2)}
    cps, a = [], stage['checkpoints_ptr']
    while rom.b(bank, a) != 0xFF:
        cps.append((rom.b(bank, a), rom.b(bank, a + 1)))
        a += 2
    stage['checkpoints'] = cps
    # The header does not store a section count: section 0 is the stage start
    # and each checkpoint record names the room that section k+1 starts in.
    sections = [parse_restart(rom, bank, rom.w(bank, stage['sections_ptr'] + 2 * k))
                for k in range(len(cps) + 1)]
    stage['sections'] = sections
    stage['extra_restarts'] = [parse_restart(rom, bank, a, False)
                               for a in EXTRA_RESTARTS.get(index, [])]
    allrp = sections + stage['extra_restarts']
    rooms, room_blocks, leaves = {}, {}, set()
    for rp in allrp:            # a restart point's own room gets its blockset first
        room_blocks.setdefault(rp['room'], rp['blocks'])
    for rp in allrp:
        todo = [rp['room']]
        while todo:
            r = todo.pop()
            if r in rooms:
                continue
            if not hdr <= r < end:
                leaves.add(r)
                continue
            rooms[r] = parse_room(rom, bank, r)
            room_blocks.setdefault(r, room_blocks.get(rp['room'], rp['blocks']))
            for e in rooms[r]['exits']:
                if e:
                    room_blocks.setdefault(e['target'], room_blocks[r])
                    todo.append(e['target'])
    stage['rooms'] = rooms
    stage['leaves'] = sorted(leaves)
    stage['blocksets'] = {}
    for b in sorted(set(room_blocks[r] for r in rooms)):
        n = rom.b(bank, b)
        stage['blocksets'][b] = [rom.bytes(bank, b + 1 + 4 * i, 4) for i in range(n)]
    for r in rooms:
        rooms[r]['blocks'] = stage['blocksets'][room_blocks[r]]
        rooms[r]['blockset'] = room_blocks[r]
    blk = sections[0]['blocks']
    count = rom.b(bank, blk)
    stage['block_count'] = count
    stage['blocks'] = [rom.bytes(bank, blk + 1 + 4 * i, 4) for i in range(count)]
    stage['collision'] = rom.bytes(bank, sections[0]['collision'], count)
    return stage


def load_tiles(rom, index):
    """VRAM $9000-$97FF as LoadStageTiles leaves it: 128 tiles."""
    vram = bytearray(128 * 16)
    index = UNLISTED.get(index, (0, 0, index))[2]
    slot = rom.w(0, STAGE_TILESET_PTRS + 2 * (index - 1))
    a = rom.w(0x0C, rom.w(0, slot))
    while rom.b(0x0C, a):
        n, first, src = rom.b(0x0C, a), rom.b(0x0C, a + 1), rom.w(0x0C, a + 2)
        vram[first * 16:(first + n) * 16] = rom.bytes(0x0C, src, n * 16)
        a += 4
    return vram


def draw_tile(px, vram, tile, x0, y0, bgp):
    if tile >= 128:     # outside $9000-$97FF; never used by bank $05
        for y in range(8):
            for x in range(8):
                px[x0 + x, y0 + y] = (255, 0, 255)
        return
    t = vram[tile * 16:tile * 16 + 16]
    for y in range(8):
        lo, hi = t[2 * y], t[2 * y + 1]
        for x in range(8):
            c = ((lo >> (7 - x)) & 1) | (((hi >> (7 - x)) & 1) << 1)
            s = SHADES[(bgp >> (2 * c)) & 3]
            px[x0 + x, y0 + y] = (s, s, s)


def layout_rooms(stage):
    """Grid position (block column, screen row) of every room."""
    pos = {}
    for sec in stage['sections'] + stage['extra_restarts']:
        start = sec['room']
        if start in pos or start not in stage['rooms']:
            continue
        base_row = 0 if not pos else max(r for _, r in pos.values()) + 1
        todo = [(start, base_row)]
        while todo:
            r, row = todo.pop()
            if r in pos or r not in stage['rooms']:
                continue
            room = stage['rooms'][r]
            pos[r] = (room['offset'] // 16, row)
            for e in room['exits']:
                if e:
                    todo.append((e['target'], row + (1 if e['flags'] & 2 else -1)))
    top = min(r for _, r in pos.values())
    return {k: (c, r - top) for k, (c, r) in pos.items()}


def patched_vram(rom, vram, gfx):
    bank, src, count = gfx
    v = bytearray(vram)
    n = min(count, len(v))
    v[0:n] = rom.bytes(bank, src, n)
    return v


def render(stage, vram, bgp, objects, rom=None):
    pos = layout_rooms(stage)
    width = max(c + stage['rooms'][r]['width'] for r, (c, _) in pos.items())
    rows = max(r for _, r in pos.values()) + 1
    img = Image.new('RGB', (width * 16, rows * 128), (40, 40, 60))
    px = img.load()
    for r, (col, row) in pos.items():
        room = stage['rooms'][r]
        gfx = BLOCKSET_TILES.get((stage['bank'], room['blockset']))
        rv = patched_vram(rom, vram, gfx) if gfx and rom else vram
        for by in range(room['height']):
            for bx in range(room['width']):
                blk = room['map'][by * room['width'] + bx]
                bs = room['blocks']
                tl, bl, tr, br = bs[blk] if blk < len(bs) else (0,) * 4
                x0, y0 = (col + bx) * 16, row * 128 + by * 16
                draw_tile(px, rv, tl, x0, y0, bgp)
                draw_tile(px, rv, tr, x0 + 8, y0, bgp)
                draw_tile(px, rv, bl, x0, y0 + 8, bgp)
                draw_tile(px, rv, br, x0 + 8, y0 + 8, bgp)
    d = ImageDraw.Draw(img)
    for r, (col, row) in pos.items():
        room = stage['rooms'][r]
        x0, y0 = col * 16, row * 128
        d.rectangle([x0, y0, x0 + room['width'] * 16 - 1, y0 + 127], outline=(0, 120, 255))
        d.text((x0 + 2, y0 + 1), '%02X' % room['id'], fill=(0, 120, 255))
        if objects:
            for s in room['spawns']:
                sx, sy = x0 + s['x'] * 16, y0 + (s['y'] & 0xF0)
                d.rectangle([sx, sy, sx + 15, sy + 15], outline=(255, 0, 0))
                d.text((sx + 2, sy + 3), '%d' % s['type'], fill=(255, 0, 0))
    return img


def render_blocks(stage, vram, bgp):
    """The stage's blockset as a sheet, 16 blocks per row, numbered in hex."""
    n = stage['block_count']
    img = Image.new('RGB', (16 * 20, ((n + 15) // 16) * 30), (40, 40, 60))
    px = img.load()
    d = ImageDraw.Draw(img)
    for i, (tl, bl, tr, br) in enumerate(stage['blocks']):
        x0, y0 = (i % 16) * 20 + 2, (i // 16) * 30 + 12
        for t, dx, dy in ((tl, 0, 0), (tr, 8, 0), (bl, 0, 8), (br, 8, 8)):
            draw_tile(px, vram, t, x0 + dx, y0 + dy, bgp)
        d.text((x0, y0 - 11), '%02X' % i, fill=(255, 255, 0))
    return img


def dump(stage):
    b = stage['bank']
    print('stage %d (%s): bank $%02X header $%04X' % (
        stage['index'], STAGE_NAMES[stage['index']], b, stage['header']))
    print('  checkpoints:', ' '.join('room %02X/%02X' % c for c in stage['checkpoints']))
    for k, s in enumerate(stage['sections']):
        print('  restart point %d @$%04X: blocks $%04X collision $%04X init $%04X hook $%04X '
              'start x=$%04X y=$%02X room $%04X' % (k, s['addr'], s['blocks'], s['collision'],
                                                    s['init'], s['hook'], s['x'], s['y'], s['room']))
    for s in stage['extra_restarts']:
        print('  restart record @$%04X (not in the restart table): blocks $%04X collision $%04X '
              'init $%04X hook $%04X start x=$%04X y=$%02X room $%04X' % (
                  s['addr'], s['blocks'], s['collision'], s['init'], s['hook'], s['x'], s['y'], s['room']))
    for r in stage['leaves']:
        print('  an exit leaves the stage for room $%04X' % r)
    print('  %d blocks; collision: %s' % (stage['block_count'], stage['collision'].hex(' ')))
    for r in sorted(stage['rooms']):
        room = stage['rooms'][r]
        ex = []
        for e in room['exits']:
            if not e:
                ex.append('-')
                continue
            n = e['box'] >> 4
            cols = 'column %d' % e['column'] if n == 1 else 'columns %d-%d' % (
                e['column'], e['column'] + n - 1)
            ex.append('%s (row %d, %s) -> $%04X' % (
                'down' if e['flags'] & 2 else 'up', e['box'] & 15, cols, e['target']))
        print('  room %02X @$%04X: %dx%d layout $%04X offset $%04X routine $%04X; exits: %s; %d spawns'
              % (room['id'], r, room['width'], room['height'], room['layout'],
                 room['offset'], room['routine'], ', '.join(ex), len(room['spawns'])))
        for s in room['spawns']:
            print('      type %2d at column %3d row %d (y $%02X, extra $%02X)' % (
                s['type'], s['x'], s['y'] >> 4, s['y'], s['extra']))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('rom')
    ap.add_argument('--stage', type=int, action='append')
    ap.add_argument('--png', metavar='DIR')
    ap.add_argument('--objects', action='store_true', help='mark object spawns')
    ap.add_argument('--blocks', action='store_true', help='also write the blockset sheet')
    a = ap.parse_args()
    rom = Rom(a.rom)
    for i in a.stage or [1, 2, 3, 4, 5, 6, 7, 8, 9]:
        st = parse_stage(rom, i)
        if a.png:
            os.makedirs(a.png, exist_ok=True)
            img = render(st, load_tiles(rom, i), FIRST_FRAME_BGP.get(i, 0x78), a.objects, rom)
            out = os.path.join(a.png, '%d_%s.png' % (i, STAGE_NAMES[i]))
            img.save(out)
            print('wrote', out, '(%dx%d)' % img.size)
            if a.blocks:
                out = os.path.join(a.png, '%d_%s_blocks.png' % (i, STAGE_NAMES[i]))
                render_blocks(st, load_tiles(rom, i), FIRST_FRAME_BGP.get(i, 0x78)).save(out)
                print('wrote', out)
        else:
            dump(st)


if __name__ == '__main__':
    main()
