#Config for tools/bankgen.py: ROM bank $0E (step 5.4), the ending. See the
#note in tools/bankgen.py: this bootstrapped the bank, and the .asm files it
#wrote are now the source of truth.
BANK = 0x0E
END = 0x7BAF
HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0E
;
;The ending. StageFrameLoop.ending in bank $00 pages this bank in and jumps to
;$4000 when a defeated boss's index is 6 (the game's last), and the bank never
;returns: it ends in an endless frame loop on the closing text screen. 100%
;source since step 5.4. The bank is:
;
;  $4000-$455A  engine/ending/kit.asm: the entry jump, then a kit of copies of
;               bank $00/$01 routines (far call to bank $01, LCD off, queued
;               tile copy, scroll and block helpers, frame waits, the sprite
;               system's setup and an 8x16 DrawMetasprite). Bank $0B opens
;               with a near-identical kit; labels here end in _0E.
;  $455B-$4B05  engine/ending/skull_ship.asm: scene 1, the skull ship blows up
;  $4B06-$4FA7  engine/ending/roll_call.asm: scene 2, a shuttle in space, then
;               Mega Man and the enemy roll call
;  $4FA8-$7040  engine/ending/roll_call_data.asm: its script, names, sprites
;               and tiles (gfx/ending/)
;  $7041-$7BAE  engine/ending/corridor.asm: scene 3, Mega Man walks down a
;               corridor with windows on space, then the closing text
;  $7BAF-$7FFF  unused, all $FF
;
;The ending runs with 8x16 sprites (LCDC $87). Its scenes keep their state in
;$CC00-$CC1B, and borrow the object records at $C600-$C7xx and the stage
;engine's scroll and room variables. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$7BAF-$7FFF: unused, all $FF. (CorridorScene's tile copy reads the first 11 of
;these bytes as the end of its last tile.)	;[ok]
SECTION "Bank E Free Space", ROMX[$7BAF], BANK[$E]
	ds $8000 - $7BAF, $FF
'''
L = lambda **k: k
def FR(s, e, tables, frames=()):
    #metasprites without a hitbox: the ending draws them directly
    return (s, e, None, 'frames', L(tables=tables, frames=list(frames), hitbox=False))
W = lambda a: ROM[a] | ROM[a + 1] << 8

ENTRIES = [0x4000, 0x40CA, 0x4224, 0x42C6, 0x42E1, 0x430C]

_kitfile = 'engine/ending/kit.asm'
CHUNKS = {0x4000: (_kitfile, 'Ending Kit'),
          0x455B: ('engine/ending/skull_ship.asm', 'Ending Skull Ship'),
          0x4B06: ('engine/ending/roll_call.asm', 'Ending Roll Call'),
          0x4FA8: ('engine/ending/roll_call_data.asm', 'Ending Roll Call Data'),
          0x7041: ('engine/ending/corridor.asm', 'Ending Corridor')}
_fh = lambda what: (';Mega Man: Dr. Wily\'s Revenge disassembly - the ending: %s\n'
                    ';Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified\n'
                    ';here, [dc] corroborated by Data Crystal, [?] guess.\n' % what)
FILEHEAD = {_kitfile: _fh('the bank\'s routine kit'),
            'engine/ending/skull_ship.asm': _fh('scene 1, the skull ship'),
            'engine/ending/roll_call.asm': _fh('scene 2, the roll call'),
            'engine/ending/roll_call_data.asm': _fh('the roll call\'s data'),
            'engine/ending/corridor.asm': _fh('scene 3, the corridor')}

# ------------------------------------------------------------------ names
ROLL = ['Suzy', 'Changkey', 'Drillun', 'CuttingWheel', 'ScrewDriver', 'SuperCutter',
        'Metall', 'Gabyoall', 'Scworm', 'Mole', 'Pipi', 'SniperJoe', 'Bigeye',
        'KaminariGoro', 'ChangkeyMaker', 'Picopico', 'BunbyHeri', 'CutMan', 'ElecMan',
        'IceMan', 'FireMan', 'BubbleMan', 'HeatMan', 'QuickMan', 'FlashMan', 'Enker']
TEXT = ['SUZY', 'CHANGKEY', 'DRILLUN', 'CUTTING WHEEL', 'SCREW DRIVER', 'SUPER CUTTER',
        'METALL', 'GABYOALL', 'SCWORM', 'MOLE', 'PIPI', 'SNIPER JOE', 'BIGEYE',
        'KAMINARI GORO', 'CHANGKEY MAKER', 'PICOPICO', 'BUNBY HERI', 'CUTMAN', 'ELECMAN',
        'ICEMAN', 'FIREMAN', 'BUBBLEMAN', 'HEATMAN', 'QUICKMAN', 'FLASHMAN', 'ENKER']
BOSSES = [('CutMan', 'cut_man'), ('ElecMan', 'elec_man'), ('IceMan', 'ice_man'),
          ('FireMan', 'fire_man'), ('BubbleMan', 'bubble_man'), ('HeatMan', 'heat_man'),
          ('QuickMan', 'quick_man'), ('FlashMan', 'flash_man'), ('Enker', 'enker')]

NAMES = {
 0x4000: 'StartEnding',
 0x4003: 'FarCallBank1_0E', 0x401C: 'Bank1TrampolineCode_0E',
 0x4033: 'HideAllSpritesAlt_0E', 0x4042: 'DisableLCD_0E',
 0x4058: 'QueueTileCopy_0E', 0x4074: 'CopyQueuedTiles_0E',
 0x4122: 'ClampToScrollLimits_0E',
 0x4138: 'WriteVRAMByteAtDE_0E', 0x4140: 'WriteVRAMByteAlwaysSafe_0E',
 0x4153: 'QueueLeftScrollColumn_0E',
 0x4213: 'PasswordWaitFrame_0E', 0x4215: 'PasswordWaitFrames_0E',
 0x4224: 'WaitForButtons_0E', 0x4232: 'FadeInBG_0E',
 0x4255: 'InitSpriteSystem_0E',
 0x4323: 'AnimateAndDrawObject16_0E', 0x4326: 'DrawObject16_0E',
 0x4347: 'AnimateObjectGetFrame_0E', 0x4365: 'AnimateObject_0E',
 0x43A5: 'DrawMetasprite16_0E', 0x44AB: 'DrawMetasprite16NoFlip_0E',
 # scene 1
 0x455B: 'SkullShipScene', 0x45F2: 'UpdateSkullShipCraft', 0x4622: 'FadeOutSkullShip',
 0x4655: 'PlayRandomExplosionSound', 0x466A: 'UpdateExplosionGroup0',
 0x467C: 'UpdateExplosionGroup1', 0x4681: 'UpdateExplosionGroup2',
 0x4686: 'UpdateExplosionGroup3', 0x4689: 'UpdateExplosionGroup',
 0x46D3: 'ExplosionGroupBits', 0x46DB: 'DrawExplosionGroup',
 0x4718: 'ExplosionGroupPositions', 0x4738: 'InitSkullShipScene',
 0x4795: 'InitExplosionGroup', 0x47B4: 'SkullShipExplosionAnim', 0x47C0: 'SkullShipExplosionFrames',
 0x4800: 'SkullShipCraftFrame', 0x4806: 'SkullShipSpriteTiles',
 # scene 2
 0x4B06: 'RollCallScene', 0x4B85: 'InitRollCallScene', 0x4C16: 'BlankTextRow20',
 0x4C2A: 'UpdateRollCall', 0x4DB9: 'BlankTextRow10', 0x4DC3: 'UpdateShuttleAndMegaMan',
 0x4EAA: 'EndingMegaManWalkAnim0', 0x4EB2: 'EndingMegaManWalkAnim4', 0x4EBA: 'EndingMegaManWalkAnim8',
 0x4EC2: 'EndingMegaManStandAnim', 0x4ECA: 'EndingMegaManFrames', 0x4EE4: 'ShuttleAnim',
 0x4EEA: 'ShuttleFrames', 0x4EEE: 'UpdateStars', 0x4F10: 'MoveAndDrawStar',
 0x4F5B: 'SpawnStar',
 0x4FA8: 'RollCallScript', 0x4FF0: 'RollCallTextPtrs', 0x5024: 'RollCallFramePtrs',
 0x5058: 'RollCallTilesetIds', 0x5072: 'RollCallTilesets',
 0x5277: 'ShuttleFrame0', 0x5280: 'ShuttleFrame1',
 0x5332: 'StarFrame1', 0x5337: 'StarFrame2', 0x533C: 'StarFrame3',
 0x5341: 'EndingSpaceSpriteTiles', 0x59A1: 'RollCallEnemyTiles',
 0x6101: 'RollCallEnemyTiles2', 0x6C41: 'EndingFontTiles',
 # scene 3
 0x7041: 'CorridorScene', 0x70CA: 'SetBGPWait12', 0x70D2: 'SetBGPWait60',
 0x70DA: 'InitCorridorScene', 0x7109: 'CorridorFloorTilemap',
 0x7149: 'InitCorridorMegaMan', 0x7169: 'UpdateCorridorIntro',
 0x72E5: 'DrawCorridorScreen', 0x734A: 'DrawBlockAlwaysSafe',
 0x7391: 'UpdateCorridorMegaMan', 0x7407: 'CorridorStepTab',
 0x7412: 'GetCorridorLook', 0x7436: 'CorridorLookTab', 0x7444: 'ScrollCorridor',
 0x7499: 'CorridorBlockCount', 0x749A: 'CorridorBlocks', 0x7552: 'CorridorLayout',
 0x77CA: 'CorridorTiles',
}
for _i in range(26):
    NAMES[W(0x5024 + 2 * _i)] = NAMES.get(W(0x5024 + 2 * _i)) or 'RollCallFrame%s' % ROLL[_i]
NAMES[0x526B] = 'RollCallFrameBoss'
for _k in range(8):
    NAMES[0x47D0 + 6 * _k] = 'SkullShipExplosionFrame%d' % _k
for _k in range(13):
    NAMES[W(0x4ECA + 2 * _k)] = 'EndingMegaManFrame%d' % _k

LOCALNAMES = {}
#What each roll-call sprite's tiles match elsewhere in the ROM, comparing tile
#shapes with the colours remapped and allowing an X flip (the ending's art uses
#other colour indices than the stages'). Checked against every 16-byte run in
#the ROM outside bank $0E.
EVID = ['type 21\'s tiles', 'type 11\'s tiles (also in 12\'s)', 'type 13\'s tiles',
        'the Wily Machine parts\' tiles (types 48-51, $7:75C3), not type 1\'s',
        'type 2\'s tiles (2 of 4)', 'type 5\'s tiles', 'type 17\'s tiles (8 of 12)',
        'type 3\'s tiles', 'type 24\'s tiles', 'type 18\'s tiles', 'type 19\'s tiles',
        'tiles found nowhere else', 'type 6\'s tiles, byte for byte',
        'type 15\'s tiles (7 of 14)', 'type 12\'s tiles', 'tiles found nowhere else',
        'type 7\'s tiles (5 of 6)'] + [None] * 9

# ------------------------------------------------------------------ data
def _incbin(name, png, n=None, end=True):
    ln = ['\tINCBIN "gfx/ending/%s.2bpp"%s' % (png, (', 0, %s' % n) if n else '')]
    if end: ln.append('%sEnd:' % name)
    return ln

_tramp = ['\tld a, [wCurrentBank]', '\tpush af', '\tld a, $01', '\tbankswitch',
          '\tdb $CD\t;call', '.target', '\tdw $0000\t;patched with HL', '\tpop af',
          '\tbankswitch', '\tret', 'Bank1TrampolineCodeEnd_0E:']

# the roll-call script: (frame, entry) records
_script = []
for _p in range(0x4FA8, 0x4FF0, 3):
    _e = ROM[_p + 2]
    _script += ['\tdw $%04X\t;%s' % (W(_p), TEXT[_e - 1]), '\tdb %d' % _e]
_script.append('RollCallScriptEnd:')

_tsid = ['\tdb %d\t;%s' % (ROM[0x5058 + _i], TEXT[_i]) for _i in range(26)]
_tsets = []
_tsnames = {0x6101: 'RollCallEnemyTiles2'}
for _b, (_n, _f) in enumerate(BOSSES):
    _tsnames[0x6341 + 0x100 * _b] = 'RollCall%sTiles' % _n
for _k in range(1, 13):
    _a = 0x506E + 4 * _k
    _src = W(_a + 2); _n = _tsnames[_src]
    assert W(_a) == (0x240 if _src == 0x6101 else 0x100)
    _tsets.append('\tdw %sEnd - %s, %s\t;%d' % (_n, _n, _n, _k))

_text = ['\tSETCHARMAP rollcall']
_textlabels = {}
for _i in range(26):
    _p = W(0x4FF0 + 2 * _i); _nm = 'RollCallText%s' % ROLL[_i]
    _textlabels[_p] = _nm
    _text.append('%s:\t;$%04X' % (_nm, _p))
    while True:
        _dst = W(_p); _p += 2
        _s = ''
        while ROM[_p] not in (0, 0xFF):
            _s += chr(ROM[_p] + 0x20); _p += 1
        _t = ROM[_p]; _p += 1
        _row, _col = (_dst - 0x9800) // 32, (_dst - 0x9800) % 32
        _text.append('\tdw TILEMAP0 + %d * 32 + %d' % (_row, _col))
        _text.append('\tdb "%s", %s' % (_s, '0' if _t == 0 else '$FF\t;next line'))
        if _t == 0: break
_text.append('\tSETCHARMAP main')
assert _p == 0x51CE

_bosstiles = []
for _b, (_n, _f) in enumerate(BOSSES):
    if _b: _bosstiles.append('RollCall%sTiles:\t;$%04X' % (_n, 0x6341 + 0x100 * _b))
    _bosstiles += _incbin('RollCall%sTiles' % _n, 'roll_call_' + _f)
_bosslabels = {0x6341 + 0x100 * _b: 'RollCall%sTiles' % BOSSES[_b][0] for _b in range(1, 9)}

_blocks = ['\tdb 46\t;blocks']
for _i in range(46):
    _b = ROM[0x749A + 4 * _i:0x749A + 4 * _i + 4]
    _blocks.append('\tblock $%02X, $%02X, $%02X, $%02X\t;$%02X' % (_b[0], _b[2], _b[1], _b[3], _i))
_blocks[1] = 'CorridorBlocks:\t;$749A\n' + _blocks[1]
_layout = ['\tdb 70, 9\t;width, height: 9 rows, so not the stages\' `layout` macro',
           '\tREDEF LAYOUT_W = 70\t;for lrow']
for _r in range(9):
    _layout.append('\tlrow "%s"' % ' '.join('%02X' % ROM[0x7554 + _r * 70 + _c] for _c in range(70)))

DATA = [
 (0x401C, 0x4033, None, 'raw', L(lines=_tramp)),
 (0x4251, 0x4255, None, 'db', {}),
 (0x46D3, 0x46DB, None, 'db', {}),
 (0x4718, 0x4738, None, 'raw', L(lines=['\tdb $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X\t;group %d: (x, y) x 4' %
                                         (tuple(ROM[0x4718 + 8 * g:0x4720 + 8 * g]) + (g,)) for g in range(4)])),
 (0x47B4, 0x47C0, None, 'anim', {}),
 FR(0x47C0, 0x4806, [0x47C0], [0x4800]),
 (0x4806, 0x4B06, None, 'raw', L(lines=_incbin('SkullShipSpriteTiles', 'skull_ship_sprites'))),
 (0x4C16, 0x4C2A, None, 'raw', L(lines=['\tds 20, 0\t;font tile 0 is the blank'])),
 (0x4DB9, 0x4DC3, None, 'raw', L(lines=['\tds 10, 0'])),
 (0x4EAA, 0x4ECA, None, 'anim', {}),
 (0x4ECA, 0x4EE4, None, 'dw', L(width=4)),
 (0x4EE4, 0x4EEA, None, 'anim', {}),
 (0x4EEA, 0x4EEE, None, 'dw', L(width=2)),
 (0x4FA8, 0x4FF0, None, 'raw', L(lines=_script, labels={0x4FF0: 'RollCallScriptEnd'})),
 (0x4FF0, 0x5024, None, 'raw', L(lines=['\tdw %s' % _textlabels[W(0x4FF0 + 2 * _i)] for _i in range(26)])),
 (0x5024, 0x5058, None, 'raw', L(lines=['\tdw %s\t;%s%s' % (NAMES[W(0x5024 + 2 * _i)], TEXT[_i], (': ' + EVID[_i]) if EVID[_i] else '') for _i in range(26)])),
 (0x5058, 0x5072, None, 'raw', L(lines=_tsid)),
 (0x5072, 0x50A2, None, 'raw', L(lines=_tsets)),
 (0x50A2, 0x51CE, None, 'raw', L(lines=_text[:1] + _text[2:], labels=_textlabels)),
 FR(0x51CE, 0x5341, [], sorted(set([W(0x5024 + 2 * _i) for _i in range(26)] + [W(0x4ECA + 2 * _k) for _k in range(13)] +
                                  [0x5277, 0x5280, 0x5332, 0x5337, 0x533C]))),
 (0x5341, 0x59A1, None, 'raw', L(lines=_incbin('EndingSpaceSpriteTiles', 'space_sprites', '102 * 16'))),
 (0x59A1, 0x6101, None, 'raw', L(lines=_incbin('RollCallEnemyTiles', 'roll_call_enemies', '118 * 16'))),
 (0x6101, 0x6341, None, 'raw', L(lines=_incbin('RollCallEnemyTiles2', 'roll_call_enemies_2', '36 * 16'))),
 (0x6341, 0x6C41, 'RollCallCutManTiles', 'raw', L(lines=_bosstiles, labels=_bosslabels)),
 (0x6C41, 0x7041, None, 'raw', L(lines=_incbin('EndingFontTiles', 'font'))),
 (0x7109, 0x7149, None, 'raw', L(lines=['\tINCBIN "gfx/tilemaps/ending_corridor_floor.tilemap"'])),
 (0x7407, 0x7412, None, 'raw', L(lines=['\tdb 0, 7\t;step 0: frame offset, X pull-back',
                                         '\tdb 1, 7', '\tdb 2, 7', '\tdb 3, 7', '\tdb 0, 7\t;read only for the next step\'s count',
                                         '\tdb $C9\t;never read'])),
 (0x7436, 0x7444, None, 'raw', L(lines=['\tdw 0, $0158\t;look, while the scroll X is at least this',
                                         '\tdw 4, $00B8', '\tdw 8, $0051', '\tdw 12\t;the last: standing',
                                         'CorridorLookTabEnd:'], labels={0x7444: 'CorridorLookTabEnd'})),
 (0x7499, 0x7552, None, 'raw', L(lines=_blocks, labels={0x749A: 'CorridorBlocks'})),
 (0x7552, 0x77CA, None, 'raw', L(lines=_layout)),
 (0x77CA, 0x7BAF, None, 'raw', L(lines=_incbin('CorridorTiles', 'corridor', '$7BAF - $77CA', end=False))),
]
DATA[0] = (0x401C, 0x4033, None, 'raw', L(lines=_tramp, labels={0x4033: 'Bank1TrampolineCodeEnd_0E'}))
#text label for the first entry is emitted by the item itself
DATA = [x if x[0] != 0x50A2 else (0x50A2, 0x51CE, 'RollCallTextSuzy', 'raw', L(lines=_text[:1] + _text[2:], labels=_textlabels)) for x in DATA]

OPER = {
 0x4004: 'Bank1TrampolineCode_0E',
 0x400A: 'Bank1TrampolineCodeEnd_0E - Bank1TrampolineCode_0E',
 0x4012: 'wBank1Trampoline + Bank1TrampolineCode_0E.target - Bank1TrampolineCode_0E',
 0x4016: 'wBank1Trampoline + Bank1TrampolineCode_0E.target - Bank1TrampolineCode_0E + 1',
 0x4216: 'JumpDelayFrame', 0x4224: 'JumpReadJoypad',
 0x4574: 'JumpLoadSkullShipScreen',
 0x4580: 'SkullShipSpriteTilesEnd - SkullShipSpriteTiles',
 0x46B2: 'LOW(ExplosionGroupBits)', 0x46B7: 'HIGH(ExplosionGroupBits)',
 0x4B29: 'EndingFontTilesEnd - EndingFontTiles',
 0x4B35: 'EndingSpaceSpriteTilesEnd - EndingSpaceSpriteTiles',
 0x4B41: 'RollCallEnemyTilesEnd - RollCallEnemyTiles',
 0x4C68: 'RollCallTilesetIds - 1', 0x4C75: 'RollCallTilesets - 4',
 0x4CA7: 'RollCallTextPtrs - 2', 0x4CF3: 'RollCallFramePtrs - 2',
 0x4DAC: 'LOW(RollCallScriptEnd)', 0x4DAF: 'HIGH(RollCallScriptEnd)',
 0x71F6: 'LOW(CorridorBlocks)', 0x71FB: 'HIGH(CorridorBlocks)',
 0x7200: 'LOW(CorridorLayout)', 0x7205: 'HIGH(CorridorLayout)',
 0x7424: 'LOW(CorridorLookTabEnd)', 0x7427: 'HIGH(CorridorLookTabEnd)',
 0x7158: 'CorridorStepTab', 0x71F0: 'CorridorBlockCount',
 0x457D: 'VRAM_TILES0', 0x4B23: 'VRAM_TILES2', 0x4B2F: 'VRAM_TILES1', 0x4B3B: 'VRAM_TILES0',
 0x4C80: 'VRAM_TILES0', 0x70E4: 'VRAM_TILES2', 0x4BFA: 'TILEMAP0',
 0x4D87: 'TILEMAP0 + 6 * 32 + 6', 0x4D93: 'TILEMAP0 + 7 * 32 + 6',
 0x70FF: 'TILEMAP0 + 16 * 32', 0x7313: 'TILEMAP0 + 30',
}

COMMENTS = {
 0x4000: '''The bank's entry: StageFrameLoop.ending (bank $00) pages bank $0E in and
jumps here at the end of the game. Nothing returns.	;[ok]''',
 0x4003: '''$4003-$455A: the kit. Most of these routines are byte-for-byte copies of
bank $00/$01/$08 routines (bank $0B carries the same kit at the same
addresses); a copy keeps its original's name with an _0E suffix.

FarCallBank1_0E: call the bank $01 routine at HL from this bank, through
the trampoline below copied to wBank1Trampoline. Bank $0C's FarCallBank1,
byte for byte. HL here is always a ROM0 jump stub.	;[ok]''',
 0x401C: '''Copied to wBank1Trampoline and run there; position-independent.	;[ok]''',
 0x4033: '''Hide all 40 sprites (Y = $A0). HideAllSpritesAlt ($166E), byte for byte.	;[ok]''',
 0x4042: '''Turn the LCD off inside VBlank. DisableLCD ($15EA), byte for byte.	;[ok]''',
 0x4058: '''Set up a chunked copy of BC bytes from HL to DE, A bytes per
CopyQueuedTiles_0E call. Bank $08's QueueTileCopy, byte for byte.	;[ok]''',
 0x4074: '''Copy the next chunk of the queued copy through JumpCopyVRAM. Returns
carry when a chunk was copied, NC once nothing is left. Bank $08's
CopyQueuedTiles with one more byte, the `scf` before the return (bank $0D's
copy at $D:4739 has it too).	;[ok]''',
 0x40CA: '''Unused here: a copy of AccumulatePlayerDX ($D84E = this frame's X movement of
Mega Man, added to the 16-bit $D80D). Nothing in bank $0E calls it.	;[ok]''',
 0x40EC: '''SetPlayerScreenX's twin: GetPlayerScreenX_0E, then wPlayerX = E. The corridor scene
uses it to place its (unseen) player position.	;[ok]''',
 0x40F4: '''GetPlayerScreenX, byte for byte: from the 16-bit $D80D, the on-screen X in E
and the scroll state in C/$D85D (0 scrolling, 1 at the left limit, 2 at the
right).	;[ok]''',
 0x4122: '''Clamp DE between wScrollMinX and wScrollMaxX. ClampToScrollLimits
($3226), byte for byte.	;[ok]''',
 0x4138: '''Write A to VRAM at DE (WriteVRAMByteAlwaysSafe_0E with HL = DE; HL kept).	;[ok]''',
 0x4140: '''[HL] = A after waiting for HBlank, whatever the LCD state. The same 19
bytes as WriteVRAMByte.alwaysSafe ($18A0).	;[ok]''',
 0x4153: '''When this frame scrolled ($D84F non-zero) across an 8-pixel boundary of
SCX (compared with $D854), queue the BG tile column 16 pixels left of the
screen for the VBlank handler: its map address in $D866/$D867, its tiles in
the $DDD0 buffer and their count in $D865, from the blocks in the $DE00 grid
(the grid column is refilled from the room layout first when needed). The
stage engine's QueueScrollColumn does the same for both directions, and
bank $00's VBlankDrawColumn copies it out.	;[ok]''',
 0x4213: '''Wait one frame, reading the joypad. Bank $0C's PasswordWaitFrame (the
password-specific name is inherited; the code is the generic frame wait).	;[ok]''',
 0x4215: '''Wait B frames (JumpDelayFrame through FarCallBank1_0E), reading the
joypad each one. Bank $0C's PasswordWaitFrames.	;[ok]''',
 0x4224: '''Unused here: read the joypad until a button in B is held - no frame
wait in between. Bank $0B has the same 14 bytes ($B:4A41).	;[ok]''',
 0x4232: '''Fade the background in from black: wShadowBGP $FE, $F9, $E4, three
frames each.	;[ok]''',
 0x4251: '''Unused: the four BGP steps FadeInBG_0E writes inline ($FF, $FE, $F9, $E4).
Nothing reads them; bank $0B has the same four bytes ($B:5583).	;[ok]''',
 0x4255: '''Set up the sprite system's tables as InitSpriteSystem does, with three
differences: all 40 OAM entries are pooled ($CE50 = $28, $CF77 counts down
40 entries from 0), $CE58 = $FF, and the $CF50 loop runs 256 times (B = 0),
filling $CF50-$D04F. Bank $0C has an unreferenced copy (InitSpriteSystem_0C).	;[ok]''',
 0x42C6: '''Unused here (as in bank $0C): draw a metasprite from a parameter block at
HL - attribute (-> $D3EA), tile base (-> $CE55), X, Y, a pointer to the
sprite handle, the metasprite pointer - with JumpDrawMetasprite.	;[ok]''',
 0x42E1: '''Unused here: as DrawSpriteRecordIndirectHandle_0E, but each of the five byte fields is a pointer
to the byte.	;[ok]''',
 0x430C: '''Unused here: as DrawSpriteRecordIndirectHandle_0E, but the sprite handle is the byte itself.	;[ok]''',
 0x4323: '''AnimateObjectGetFrame_0E, then fall into DrawObject16_0E.	;[ok]''',
 0x4326: '''Draw object C (record page in H) with DrawMetasprite16_0E: handle at
offset $10, X at $0D, Y at $0F, the frame data at $CE53/$CE54. Keeps C.	;[ok]''',
 0x4347: '''AnimateObject_0E with the animation record at DE, then look the new frame
up in the frame table (offsets $15/$16, frame number at $17) and leave its
address in $CE53/$CE54.	;[ok]''',
 0x4365: '''Animate object C, DE = an animation record (dw frame table, db frames per
step, frame numbers..., $FF loops). The object library's AnimateObject,
byte for byte.	;[ok]''',
 0x43A5: '''DrawMetasprite ($2CF0) for 8x16 sprites: the same code, except that grid
rows are 16 pixels apart. Sprite handle A, metasprite at HL, position in
$FFA2/$FFA3, attributes $D3EA, tile base $CE55, $CE57 as there.	;[ok]''',
 0x44AB: '''DrawMetasprite16_0E without the flip bits: every tile byte is added whole
to the tile base, and $D3EA is the attribute byte unchanged. Used for the
roll call's enemies.	;[ok]''',
 0x455B: '''Scene 1. Sound off (CallBank1Routine 0), LCD off, the skull ship screen
(JumpLoadSkullShipScreen), this scene's sprite tiles, 8x16 sprites; fade
in, then run until FadeOutSkullShip has blacked the screen out and all four
explosion groups have stopped ($CC02 = $1F), and go on to the roll call.
$CC00/$CC01 count frames from the start of the scene.	;[ok]''',
 0x45F2: '''From frame 300: move the small craft (record $C700) left a pixel a frame
and draw SkullShipCraftFrame, until its X wraps into $A0-$DF (off the left
edge).	;[ok]''',
 0x4622: '''Until $CC02 is set: every 10 frames ($CC06) count $CC03 up; BGP $E4 for
120 frames, then $F9, $FE and $FF (black) 120 frames each; on black set
$CC02 = $10, which tells the explosion groups to stop.	;[ok]''',
 0x4655: '''Sound $02 (the enemy explosion's) on every 128th frame, or at random
(RNG < $18) on other frames.	;[ok]''',
 0x466A: '''The four explosion groups, records $C600/$C640/$C680/$C6C0. Group 0
also plays the random explosion sound once the explosions have begun
($CC05) and until the fade is done.	;[ok]''',
 0x4689: '''Explosion group C: wait for its start delay (offset $27); then, once the
screen is black ($CC02), stop at the end of its cycle - set its bit
(ExplosionGroupBits by group number, offset $09) in $CC02 and play sound
$02 - or else animate (SkullShipExplosionAnim) and draw.	;[ok]''',
 0x46D3: '''Group number -> its bit in $CC02.	;[ok]''',
 0x46DB: '''Draw explosion group C's current frame four times, at the group's four
positions in ExplosionGroupPositions, with the sprite handles at offsets
$28-$2B.	;[ok]''',
 0x4718: '''Four (x, y) positions per explosion group, 8 bytes a group.	;[ok]''',
 0x4738: '''Set up scene 1: the sprite system, the four explosion groups (start delays
60, 68, 76 and 84 frames) and the craft at (64, 96) with a 10-entry sprite.	;[ok]''',
 0x4795: '''Explosion group at HL: start delay E, group number D, four sprite handles
of four OAM entries each at offsets $28-$2B.	;[ok]''',
 0x47B4: '''The explosion: frames 0-7, four frames each.	;[ok]''',
 0x47C0: '''8x16 metasprites (DrawMetasprite16_0E format, no hitbox).	;[ok]''',
 0x4800: '''The small craft that flies off left in scene 1 (tiles $0C/$0E).	;[ok]''',
 0x4806: '''Scene 1's sprite tiles at $8000: a large and a small craft ($00-$0F; only
$0C/$0E are drawn), then the explosion frames ($10-$2F).	;[ok]''',
 0x4B06: '''Scene 2. From black: sound $02, then after 150 frames sound $28; load the
ending font to $9000, the space sprites to $8800 and the roll-call enemies
to $8000; then every frame the shuttle (later Mega Man), the stars and the
roll call, until the script is done ($CC18), and on to the corridor. BGP
$CF draws the blank BG black.	;[ok]''',
 0x4B85: '''Set up scene 2: the sprite system, 11 star records at $C600 (kind, handle,
Y, X; one OAM entry each) with UpdateStars run 255 times so the sky starts
full, the shuttle record at $C640 (X $C0, Y $58, 5 OAM entries), the script
pointer ($CC1A/$CC1B), a 12-entry sprite for the roll call ($CC10), and a
blank BG map.	;[ok]''',
 0x4C16: '''Font tile 0, the space, for blanking BG rows.	;[ok]''',
 0x4C2A: '''The roll call, state $CC03:
 0  wait for the script's next frame number (against $CC00); take its entry
    ($CC04); queue the entry's tileset (RollCallTilesetIds) to $8000, 32
    bytes a frame -> 1, or with none -> 2
 1  copy the queued tiles -> 2
 2  after 10 frames write the name (RollCallTextPtrs; each line while LY is
    in $40-$85), start the sprite (RollCallFramePtrs) at X $E0, Y $20 -> 3
 3  move right a pixel a frame, pausing 120 frames at X $50; at X $B4-$CF
    -> 4 after 30 frames
 4  blank the name rows; -> 0, or set $CC18 when the script is done	;[ok]''',
 0x4DB9: '''Ten blank tiles: one name line.	;[ok]''',
 0x4DC3: '''Record $C640, from frame 300: the shuttle (tile base $86) flies in from
X $C0 half a pixel a frame; at X $70 it stops and OBP0 fades it to black
over 60 frames. At frame 730 its sprite is swapped for a 9-entry one, and
from then it is Mega Man (tile base $96), standing at ($70, $58) while
OBP0 fades him in.	;[ok]''',
 0x4EAA: '''Big Mega Man's walk cycles (four frames of 24 each) and his standing
frame. Only EndingMegaManStandAnim is used: the corridor scene picks
EndingMegaManFrames entries itself (UpdateCorridorMegaMan).	;[ok]''',
 0x4ECA: '''Big Mega Man: three walk cycles of four (0-3, 4-7, 8-11; the corridor's
"looks") and standing (12). Tile base $96.	;[ok]''',
 0x4EE4: '''The shuttle: two frames, four frames each.	;[ok]''',
 0x4EEE: '''Spawn stars now and then, and move and draw every live one (OBP1, tile
base $80).	;[ok]''',
 0x4F10: '''Star record HL, kind A: kind 1 moves right 2 pixels a frame, kind 2 one,
kind 3 one every other frame (bit 7 of the kind toggles). It is removed at
X $A8-$EF; otherwise drawn with StarFrame1-3.	;[ok]''',
 0x4F5B: '''Count $C632 up to the random interval $C633 (20-51 frames); then take a
free star record, give it a random Y (0-$87), a random kind (1, 2 or 3 for RNG
below $30, below $78, the rest) and X $F8, just off the left edge.	;[ok]''',
 0x4FA8: '''The roll call script: (frame number, entry) pairs, entries into the
tables below (one-based). An enemy every 450 frames from frame 1160.
DRILLUN (3) and PICOPICO (16) have full entries - name, sprite, tiles -
but the script skips them, so the ending never shows them.	;[ok]''',
 0x4FF0: '''Per entry: its name. UpdateRollCall indexes this table from entry 1 at
RollCallTextPtrs - 2; the byte pairs before it are the script's tail.	;[ok]''',
 0x5024: '''Per entry: its metasprite, drawn with DrawMetasprite16_0E (from
RollCallFramePtrs - 2). All nine robot masters share RollCallFrameBoss,
a 4x2 head drawn from each one's own 16 tiles.	;[ok]''',
 0x5058: '''Per entry: the RollCallTilesets entry loaded to $8000 before it is shown,
0 for none (the first 14 use RollCallEnemyTiles, loaded with the scene).	;[ok]''',
 0x5072: '''Tilesets 1-12: dw byte count, source. 1-3 are the same 36 tiles.	;[ok]''',
 0x50A2: '''The names, in the rollcall charmap: dw BG map address, then the text, ended
by 0 or by $FF for another (address, text) line.	;[ok]''',
 0x51CE: '''The roll call's metasprites, then the shuttle's, big Mega Man's and the
stars'. Tile bytes are added whole to the tile base (no flip bits).	;[ok]''',
 0x5341: '''Sprite tiles $80-$E5 at $8800: three stars, the shuttle, big Mega Man,
three more stars.	;[ok]''',
 0x59A1: '''Sprite tiles at $8000 for roll-call entries 1-14, in entry order. Most are
the in-game enemies' own tile shapes with other colour indices (see
RollCallFramePtrs).	;[ok]''',
 0x6101: '''Tileset 1-3: Changkey Maker ($00-$0F), Picopico ($10-$1B) and Bunby Heli
($1C-$23).	;[ok]''',
 0x6341: '''Tilesets 4-12: a 16-tile head per robot master, in roll-call order.	;[ok]''',
 0x6C41: '''The ending's font at $9000: ASCII $20-$5F, with a copyright glyph at `@`.
See the rollcall charmap.	;[ok]''',
 0x7041: '''Scene 3. The corridor intro (UpdateCorridorIntro, with the stars still
running) until it sets $CC03; then Mega Man walks while the corridor
scrolls, until he reaches his last look (standing, 12). Then wait 360
frames, fade BGP to black (60 frames a step; the E values loaded beside
them are never used), show the closing text (CallBank1Routine 6,
LoadEndingScreen), set BGP $AB, $57, $03 12 frames apart, and stay there
for good.	;[ok]''',
 0x70CA: '''wShadowBGP = A, then wait 12 frames.	;[ok]''',
 0x70D2: '''wShadowBGP = A, then wait 60 frames.	;[ok]''',
 0x70DA: '''Set up scene 3: queue CorridorTiles to $9000 (63 tiles, $03F0 bytes - 11
more than CorridorTiles holds, so the last tile ends in the bank's $FF
fill), BGP black, wStageBank = $0E for the scroll-column code, and the
floor rows at BG rows 16-17.	;[ok]''',
 0x7109: '''BG rows 16-17: the corridor floor below the scrolling room.	;[ok]''',
 0x7149: '''Mega Man at ($70, $58) in record $C640: step 0, frame offset from
CorridorStepTab, step counter 1, look 0.	;[ok]''',
 0x7169: '''The corridor intro, state $C680:
 0  copy the queued tiles (Mega Man still drawn by UpdateShuttleAndMegaMan)
    -> 2
 2  set the stage engine up for the corridor: blockset, layout (70 x 9),
    row pointers, scroll limits, scroll X $02F0 -> 3
 3  after 120 frames draw the screen (DrawCorridorScreen) -> 4
 4  walk for 180 frames, the BG still black -> 5
 5  walk while OBP1 fades the stars out over 120 frames -> 1
 1  walk while BGP fades the corridor in over 121 frames; set $CC03	;[ok]''',
 0x72E5: '''Draw 8 rows of 12 blocks of the corridor into the BG map from column 30
(wrapping), starting at the block column the clamped scroll X - $60 is in.	;[ok]''',
 0x734A: '''DrawBlock ($3496) with every VRAM write through the always-safe HBlank
wait, so it can run with the LCD on: block [HL] to the map at DE, recorded
in the $DE00 grid. Returns HL + 1.	;[ok]''',
 0x7391: '''Scroll the corridor, pick Mega Man's look (GetCorridorLook, kept in
$C66B), and below 12 walk: he moves right a pixel for each pixel scrolled,
and every 7 of them steps the walk cycle (CorridorStepTab) and moves back 7
- so he stays in place while the corridor passes. Draws frame look + step
from EndingMegaManFrames.	;[ok]''',
 0x7407: '''Walk steps: frame offset, then the pixels to move back (also the next
step's count).	;[ok]''',
 0x7412: '''E = the look for the scroll X ($D80D): the first CorridorLookTab entry
whose threshold the scroll X is at or above, 12 past the last.	;[ok]''',
 0x7436: '''As the corridor scrolls (X from $02F0 down), Mega Man's look changes from
walk cycle 0 to 4 to 8, then 12 (standing) ends the walk.	;[ok]''',
 0x7444: '''Scroll the view left by 7/16 of a pixel a frame (6/16 below scroll X
$60) with a fraction in $CC05, down to scroll X $50. On a step: $D80D and
$D80F one less, SCX one less, $D84F = $FF, the old SCX in $D854.	;[ok]''',
 0x7499: '''The corridor's blockset, written with the stage `block` macro. No
collision table: nothing walks on it.	;[ok]''',
 0x7552: '''The corridor: 70 blocks wide, 9 high - windows on space, with the Earth in
the first. (wRoomHeight is 9, so the scroll columns use all nine rows;
DrawCorridorScreen draws eight.)	;[ok]''',
 0x77CA: '''BG tiles at $9000 for the corridor. 62 whole tiles and 5 bytes of a 63rd;
its last 11 bytes are the free space's $FF.	;[ok]''',
}

# Step 7.3d: the last provisional Func_ labels, renamed in the source (which
# has been hand-edited since; do not regenerate it from this config).
NAMES.update({
 0x40CA: 'AccumulatePlayerDX_0E',
 0x40EC: 'SetPlayerScreenX_0E',
 0x40F4: 'GetPlayerScreenX_0E',
 0x42C6: 'DrawSpriteRecordIndirectHandle_0E',
 0x42E1: 'DrawSpriteRecordIndirect_0E',
 0x430C: 'DrawSpriteRecord_0E',
})
