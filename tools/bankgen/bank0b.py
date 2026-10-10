#Config for tools/bankgen.py: ROM bank $0B (step 5.4). See the note in
#tools/bankgen.py: this bootstrapped the bank, and the .asm files it wrote are
#now the source of truth.
import sys as _sys
_sys.path.insert(0, 'tools')
from disasm import OPS as _OPS

BANK = 0x0B
END = 0x55D0
HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0B
;
;The Wily cutscenes. Bank $00's main flow pages this bank in and calls $4000
;twice in a game, only while $DCD0 is non-zero: before Wily stage 1 is entered,
;and before Wily 3 (wWilyProgress & $1F = $1F). 100% source since step 5.4.
;
;  $4000-$4515  engine/cutscenes/kit_0b.asm: the `jp` to PlayWilyCutscene, then
;               a kit of helpers that bank $0E carries too (its copy is at $4002-
;               $455B); labels end in _0B. About half of it is never called here.
;  $4516-$4921  engine/cutscenes/castle_cutscene.asm: the entry and the first
;               cutscene - the stage select with Dr. Wily in the middle, then
;               (after the saucer scene) Mega Man beaming down at the castle
;  $4922-$4C60  engine/cutscenes/wily_saucer.asm: Wily's saucer on a dark screen
;  $4C61-$4CA5  engine/cutscenes/helpers_0b.asm: tilemap copy and the
;               skippable frame waits of the first cutscene
;  $4CA6-$52F8  engine/cutscenes/wily_stage_select.asm: the stage-select
;               cursor and portrait, their tilemap and sprite tiles
;  $52F9-$55CF  engine/cutscenes/skull_ship_cutscene.asm: the second cutscene -
;               a saucer leaves the castle and flies to the skull ship
;  $55D0-$7FFF  unused, all $FF
;
;Both cutscenes run with bank $0B paged in and reach the bank $00 screen
;loaders through FarCallBank1_0B (see there for why). Each can be skipped with
;A or B, but only after it has been seen once: the first sets $DFCF and the
;second $DFD0 to $FF when they finish. The scenes keep their sprites in 7-byte
;"sprite records" drawn by DrawSpriteRecord_0B, in the shot-state RAM from
;$C200 (wShotCount), which no shot uses outside a stage.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$55D0-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank B Free Space", ROMX[$55D0], BANK[$B]
	ds $8000 - $55D0, $FF
'''

# kit routines that nothing in this bank calls, and code reached only by copy
ENTRIES = [0x4000, 0x4058, 0x4074, 0x40CA, 0x40EC, 0x4122, 0x4138, 0x4153,
           0x429C, 0x42DE, 0x4466, 0x4A41]
L = lambda **k: k
R = lambda a: ROM[a]
def sb(v): return v - 256 if v > 127 else v

def mslines(a, comment=None):
    """The db lines of the DrawMetasprite metasprite at a, and its end."""
    g = R(a + 2); n = (g >> 4) * (g & 15)
    out = ['\tdb $%02X, $%02X, $%02X\t;dx, dy, %dx%d' % (R(a), R(a + 1), g, g >> 4, g & 15)]
    p = a + 3
    if n:
        out.append('\tdb ' + ', '.join('$%02X' % R(q) for q in range(p, p + n)))
    p += n
    while R(p) != 0x80:
        out.append('\tdb $%02X, $%02X, $%02X' % (R(p), R(p + 1), R(p + 2))); p += 3
    out.append('\tdb $80')
    return out, p + 1

def MS(a, name):
    """A plain metasprite."""
    lines, e = mslines(a)
    return (a, e, name, 'raw', L(lines=lines))

def HMS(a, name, msname):
    """A metasprite after an unread 4-byte hitbox (the object-frame layout);
    the code points at the metasprite, msname."""
    lines, e = mslines(a + 4)
    return (a, e, name, 'raw', L(lines=['\tdb $%02X, $%02X, $%02X, $%02X\t;hitbox (unused)' %
        tuple(R(a + i) for i in range(4)), '%s:\t;$%04X' % (msname, a + 4)] + lines,
        labels={a + 4: msname}))

def REC7(a, name):
    """A sprite record for DrawSpriteRecord_0B."""
    return (a, a + 7, name, 'raw', L(lines=[
        '\tdb $%02X, $%02X, $%02X, $%02X, $%02X\t;attributes, tile base, X, Y, sprite handle' %
        tuple(R(a + i) for i in range(5)), '\tdw @@%04X\t;metasprite' % (R(a + 5) | R(a + 6) << 8)]))

def REC8(a, name, labels=None):
    """A record for DrawSpriteRecordIndirectHandle_0B: the handle by pointer."""
    return '\tdb $%02X, $%02X, $%02X, $%02X\t;attributes, tile base, X, Y' % \
        tuple(R(a + i) for i in range(4)), \
        '\tdw $%04X, @@%04X\t;sprite handle pointer, metasprite' % (
        R(a + 4) | R(a + 5) << 8, R(a + 6) | R(a + 7) << 8)

_corners = []
for _i, _n in enumerate(('WilyCursorTopLeft', 'WilyCursorTopRight', 'WilyCursorBottomLeft',
                         'WilyCursorBottomRight')):
    if _i: _corners.append('%s:\t;$%04X' % (_n, 0x4CF9 + 8 * _i))
    _corners += list(REC8(0x4CF9 + 8 * _i, _n))

DATA = [
 (0x401C, 0x4033, 'Bank1TrampolineCode_0B', 'raw', L(lines=[
    '\tld a, [wCurrentBank]', '\tpush af', '\tld a, $01', '\tbankswitch',
    '\tdb $CD\t;call', '.target', '\tdw $0000\t;patched with HL', '\tpop af',
    '\tbankswitch', '\tret', 'Bank1TrampolineCodeEnd_0B:'])),
 # the first cutscene's castle part
 MS(0x47C4, 'MegaManStandMetasprite'),
 MS(0x47D4, 'TeleportBeamMetasprite'),
 MS(0x47DC, 'TeleportWarpMetasprite1'),
 MS(0x47EC, 'TeleportWarpMetasprite2'),
 (0x47F6, 0x4906, 'CastleSceneTiles', 'raw', L(lines=[
    '\tINCBIN "gfx/cutscenes/castle_mega_man.2bpp"', 'CastleSceneTilesEnd:'])),
 REC7(0x4906, 'SaucerDomeRecord'),
 REC7(0x490D, 'SaucerBaseRecord'),
 REC7(0x4914, 'SaucerWilyRecord'),
 REC7(0x491B, 'CastleBeamRecord'),
 # the saucer
 HMS(0x4B0D, 'SaucerDomeFrame', 'SaucerDomeMetasprite'),
 HMS(0x4B2D, 'SaucerBaseFrame1', 'SaucerBaseMetasprite1'),
 HMS(0x4B47, 'SaucerBaseFrame2', 'SaucerBaseMetasprite2'),
 (0x4B61, 0x4C61, 'SaucerTiles', 'raw', L(lines=[
    '\tINCBIN "gfx/cutscenes/wily_saucer.2bpp"', 'SaucerTilesEnd:'])),
 # the stage select
 (0x4CF9, 0x4D19, 'WilyCursorTopLeft', 'raw', L(lines=_corners, labels={
    0x4D01: 'WilyCursorTopRight', 0x4D09: 'WilyCursorBottomLeft', 0x4D11: 'WilyCursorBottomRight'})),
 MS(0x4D19, 'WilyCursorMetasprite'),
 (0x4D2C, 0x4D34, 'WilyPortraitRecord', 'raw', L(lines=list(REC8(0x4D2C, '')))),
 HMS(0x4D34, 'WilyPortraitFrame', 'WilyPortraitMetasprite'),
 HMS(0x4D45, 'SaucerWilyFrame1', 'SaucerWilyMetasprite1'),
 HMS(0x4D53, 'SaucerWilyFrame2', 'SaucerWilyMetasprite2'),
 (0x4D61, 0x4EC9, 'WilyStageSelectTilemap', 'raw', L(lines=[
    'INCBIN "gfx/tilemaps/wily_stage_select.tilemap"'])),
 (0x4EC9, 0x52F9, 'WilyStageSelectTiles', 'raw', L(lines=[
    '\tINCBIN "gfx/sprites/stage_select.2bpp"\t;8 tiles, the cursor (bank $04\'s copy)',
    '\tINCBIN "gfx/bosses/obj_type48.2bpp", 38 * 16, 59 * 16\t;Dr. Wily (bank $07\'s tiles 38-96)',
    'WilyStageSelectTilesEnd:'])),
 # the second cutscene
 REC7(0x5386, 'SaucerDotRecord'),
 (0x54AD, 0x54CA, 'SkullShipStars', 'raw', L(lines=[
    '\tdb $%02X, $%02X, $%02X, $%02X\t;Y, X, tile, attributes' % tuple(R(0x54AD + 4 * i + k) for k in range(4))
    for i in range(7)] + ['SkullShipHiddenStar:\t;$54C9',
    '\tdb $A0\t;Y = $A0: hidden. The other three bytes are the code that follows'],
    labels={0x54C9: 'SkullShipHiddenStar'})),
 (0x5534, 0x5564, 'SkullShipSceneTiles', 'raw', L(lines=[
    '\tINCBIN "gfx/cutscenes/skull_ship_stars.2bpp"', 'SkullShipSceneTilesEnd:'])),
 (0x5583, 0x5587, 'SkullShipFadeInBGP', 'db', {}),
 HMS(0x5587, 'SaucerDotFrame', 'SaucerDotMetasprite'),
 (0x5590, 0x55D0, 'SaucerDotWobble', 'raw', L(lines=[
    '\tdb ' + ', '.join('%d' % sb(R(0x5590 + i)) for i in range(r, r + 16)) for r in range(0, 64, 16)])),
]

NAMES = {
 # the kit
 0x4000: 'Entry_0B_4000', 0x4003: 'FarCallBank1_0B', 0x4033: 'HideAllSpritesAlt_0B',
 0x4042: 'DisableLCD_0B', 0x4058: 'QueueTileCopy_0B', 0x4074: 'CopyQueuedTiles_0B',
 0x4122: 'ClampToScrollLimits_0B', 0x4138: 'WriteVRAMByteAtDE_0B',
 0x4140: 'WriteVRAMByteAlwaysSafe_0B', 0x4210: 'InitSpriteSystem_0B',
 0x4281: 'DrawSpriteRecordIndirectHandle_0B', 0x429C: 'DrawSpriteRecordIndirect_0B',
 0x42C7: 'DrawSpriteRecord_0B', 0x42DE: 'AnimateAndDrawObject_0B',
 0x4302: 'AnimateObjectFramePtr_0B', 0x4320: 'AnimateObject_0B',
 0x4360: 'DrawMetaspriteRows16_0B', 0x4466: 'DrawMetaspriteRows16NoFlip_0B',
 # the first cutscene
 0x4516: 'PlayWilyCutscene', 0x45F2: 'CastleBeamDownScene', 0x4741: 'FadeToWhite_0B',
 0x4765: 'FadeToBlack_0B', 0x4789: 'StartTeleportFrames', 0x4793: 'StepTeleportFrames',
 0x47A6: 'GetTeleportFrame',
 0x4922: 'WilySaucerScene', 0x4A41: 'WaitForButtonHeld_0B', 0x4A4F: 'SaucerSceneFrame',
 0x4A59: 'SaucerSceneWait', 0x4A62: 'DrawSaucer', 0x4AB7: 'DrawSaucerWily',
 0x4AEB: 'LoadSaucerSceneGfx',
 0x4C61: 'CopyTilemap20x18_0B', 0x4C7B: 'CastleCutsceneWaitFrame',
 0x4C7D: 'CastleCutsceneWaitFrames',
 0x4CA6: 'BlinkStageSelectCursor_0B', 0x4CD7: 'DrawWilyStageCursor', 0x4CEC: 'DrawWilyCursorCorner',
 0x4D1E: 'DrawWilyPortrait',
 # the second cutscene
 0x52F9: 'SkullShipCutscene', 0x538D: 'SkullShipArrivalScene', 0x5473: 'MoveSaucerDot',
 0x54CA: 'TwinkleStars', 0x5509: 'SkullShipWaitFrame', 0x550B: 'SkullShipWaitFrames',
 0x5564: 'SkullShipFadeIn',
}

LOCALNAMES = {
 0x403C: '.loop', 0x4047: '.waitVBlank',
 0x408E: '.fullChunk', 0x4091: '.gotLength', 0x40C9: '.done',
 0x4143: '.waitNotHBlank', 0x4149: '.waitHBlank',
 0x45A2: '.waitStart', 0x45C4: '.flash', 0x45D8: '.setPalette',
 0x4676: '.fall', 0x4692: '.gotSpeed', 0x46AE: '.warpIn', 0x46D3: '.waitCue',
 0x46F0: '.warpOut', 0x4719: '.rise',
 0x479D: '.store', 0x47C2: '.notDone',
 0x49A7: '.flyIn', 0x49CC: '.openDome', 0x49E9: '.laugh', 0x4A04: '.closeDome',
 0x4A1D: '.domeShut', 0x4A22: '.flyOut', 0x4A40: '.done',
 0x4A99: '.gotCounter', 0x4AA9: '.gotFrame', 0x4ACD: '.gotFace',
 0x4C63: '.row', 0x4C65: '.col', 0x4C92: '.pressed', 0x5520: '.pressed',
 0x5376: '.rise',
 0x53BD: '.seed', 0x53C5: '.stars', 0x53DE: '.flyIn', 0x53F6: '.gotDistance',
 0x5401: '.notThere', 0x5403: '.arrived', 0x5412: '.fadeIn', 0x544A: '.waitCue',
 0x545D: '.hold', 0x5486: '.gotIndex', 0x54AB: '.notGone',
 0x54D3: '.loop', 0x54E7: '.visible', 0x54F0: '.copy',
}

OPER = {
 0x4004: 'Bank1TrampolineCode_0B',
 0x400A: 'Bank1TrampolineCodeEnd_0B - Bank1TrampolineCode_0B',
 0x4012: 'wBank1Trampoline + Bank1TrampolineCode_0B.target - Bank1TrampolineCode_0B',
 0x4016: 'wBank1Trampoline + Bank1TrampolineCode_0B.target - Bank1TrampolineCode_0B + 1',
 # ROM0 jump stubs handed to FarCallBank1_0B
 0x4532: 'JumpLoadStageSelectScreen', 0x45A2: 'JumpDelayFrame', 0x45AB: 'JumpReadJoypad',
 0x4605: 'JumpLoadWilyCastleScreen', 0x4A41: 'JumpReadJoypad', 0x4C7E: 'JumpDelayFrame',
 0x530D: 'JumpLoadWilyCastleScreen', 0x539B: 'JumpLoadSkullShipScreen', 0x550C: 'JumpDelayFrame',
 # copy lengths
 0x4547: 'WilyStageSelectTilesEnd - WilyStageSelectTiles',
 0x4611: 'CastleSceneTilesEnd - CastleSceneTiles',
 0x4B06: 'SaucerTilesEnd - SaucerTiles',
 0x5319: '1 * 16\t;only the first tile, the saucer dot',
 0x5325: 'SkullShipSceneTilesEnd - SkullShipSceneTiles',
 # sounds (SoundTab index + 1 in the bank wAudioBank selects) and bank-1 routines
 0x458F: '$26\t;bank $0A: StageSelect', 0x45BD: '$2B\t;SFX_Shing',
 0x462D: '$27\t;bank $0A: WilyIntro', 0x46C4: '$08\t;SFX_Land',
 0x470A: '$21\t;SFX_Teleport', 0x497D: '$01\t;bank $02: SFX_UFO',
 0x5349: '$01\t;bank $0A: SFX_UFO', 0x53B0: '$01\t;SFX_UFO', 0x540D: '$27\t;WilyIntro',
 0x45B8: '$00\t;AudioStopAll', 0x45F7: '$00\t;AudioStopAll', 0x4922: '$00\t;AudioStopAll',
}
OPER.update({0x46C9: 'LOW(MegaManStandMetasprite)', 0x46CE: 'HIGH(MegaManStandMetasprite)',
 0x470F: 'LOW(TeleportBeamMetasprite)', 0x4714: 'HIGH(TeleportBeamMetasprite)'})
INLINE = {0x5390: 'xor a\t;AudioStopAll', 0x5403: 'xor a\t;AudioStopAll'}

# The scenes' scratch at $C200-$C21F (the shot state, idle outside a stage) is
# written as offsets from wShotCount rather than by the shot fields' names.
_code = [(0x4516, 0x47C4), (0x4922, 0x4B0D), (0x4C61, 0x4CF9), (0x4D1E, 0x4D2C),
         (0x52F9, 0x5386), (0x538D, 0x54AD), (0x54CA, 0x5534), (0x5564, 0x5583)]
for _s, _e in _code:
    _pc = _s
    while _pc < _e:
        _op = ROM[_pc]; _n = 2 if _op == 0xCB else _OPS[_op][1]
        if _op in (0x01, 0x11, 0x21, 0xEA, 0xFA):
            _v = ROM[_pc + 1] | ROM[_pc + 2] << 8
            if 0xC200 <= _v < 0xC220 and _pc not in OPER:
                OPER[_pc] = 'wShotCount' if _v == 0xC200 else 'wShotCount + $%02X' % (_v - 0xC200)
        _pc += _n
    assert _pc == _e, hex(_s)

COMMENTS = {}
C = COMMENTS

C[0x4000] = '''$4000: bank $00 calls here (`call $4000` with bank $0B paged in) to play a
Wily cutscene.	;[ok]'''
C[0x4003] = '''Call the ROM0 routine at HL with bank $01 paged in, then page the current
bank back in. Copies Bank1TrampolineCode_0B to wBank1Trampoline ($C0B0),
patches HL into its `call` and jumps to it. Bank $00's screen loaders end with
`ld a, 1 / bankswitch` because bank $01 normally calls them; through the
trampoline, running from WRAM, they return to this bank. The cutscenes use it
for every ROM0 call that may switch banks. Same code as bank $0C's FarCallBank1.	;[ok]'''
C[0x401C] = '''Copied to wBank1Trampoline and run there; position-independent. Same as bank
$0C's Bank1TrampolineCode.	;[ok]'''
C[0x4033] = '''Hide all 40 shadow-OAM sprites (Y = $A0). Byte-identical to bank $00's
HideAllSpritesAlt (and bank $0C's PasswordHideSprites).	;[ok]'''
C[0x4042] = '''If the LCD is on, wait for LY 145-150 (VBlank) and switch it off. Byte-identical
to bank $00's DisableLCD.	;[ok]'''
C[0x4058] = '''Set up a chunked copy of BC bytes from HL to DE, A bytes at a time, for
CopyQueuedTiles_0B. Byte-identical to bank $08's QueueTileCopy. Not called in
this bank.	;[ok]'''
C[0x4074] = '''Copy the next chunk of the queued copy through JumpCopyVRAM. As bank $08's
CopyQueuedTiles, plus a `scf`: returns carry when it copied a chunk, NC when
nothing was left. Not called in this bank.	;[ok]'''
C[0x40CA] = '''Byte-identical to bank $01's AccumulatePlayerDX: $D84E = how far Mega Man moved in X
this frame; add it to the 16-bit $D80D (the old value saved at $D852). Not
called in this bank.	;[ok]'''
C[0x40EC] = '''GetPlayerScreenX_0B, then wPlayerX = E. Bank $00's SetPlayerScreenX, calling the local copy.
Not called in this bank.	;[ok]'''
C[0x40F4] = '''Byte-identical to bank $00's GetPlayerScreenX: from the
16-bit $D80D and wScrollMaxX, returns E and sets $D85D to 0, 1 or 2.	;[ok]'''
C[0x4122] = '''Clamp DE between the scroll limits wScrollMinX/wScrollMaxX. Byte-identical to
bank $00's ClampToScrollLimits. Not called in this bank.	;[ok]'''
C[0x4138] = '''[DE] = A, through WriteVRAMByteAlwaysSafe_0B. Not called in this bank.	;[ok]'''
C[0x4140] = '''[HL] = A, waiting for HBlank (interrupts off meanwhile); D is preserved.
Byte-identical to bank $00's WriteVRAMByte.alwaysSafe.	;[ok]'''
C[0x4153] = '''The left-edge half of bank $00's QueueScrollColumn, which streams a column of
blocks into the BG map as the stage scrolls: when $D84F is set and SCX crossed
an 8-pixel boundary since $D854, look up the column 16 px left of the screen
and leave its 8 tile pairs at $DDD0, the BG map address at $D866 and $10 in
$D865. Bank $00's version also does the right edge. Not called in this bank.	;[?]'''
C[0x4210] = '''Set up the sprite system's tables (see engine/sprites.asm): as bank $00's
InitSpriteSystem, but with all 40 OAM entries in the pool ($CE50 = $28, not $36;
$CE58 = $FF, not 0). The third offset loop runs 256 times (B = 0), on past
$CF77 to $D04F; the next loop rewrites $CF50-$CF77. Byte-identical to bank $0C's
InitSpriteSystem_0C.	;[ok]'''
C[0x4281] = '''DrawSpriteRecord_0B for an 8-byte record whose handle is read through a
pointer: db attributes, tile base, X, Y / dw handle pointer, metasprite.	;[ok]'''
C[0x429C] = '''DrawSpriteRecord_0B with every field read through a pointer: five pointers
(attributes, tile base, X, Y, handle), then the metasprite. Not called in this
bank.	;[ok]'''
C[0x42C7] = '''Draw the sprite record at HL, 7 bytes: db attributes ($D3EA), tile base
($CE55), X ($FFA2), Y ($FFA3), sprite handle / dw metasprite - through
JumpDrawMetasprite. All of this bank's scene sprites are drawn this way.	;[ok]'''
C[0x42DE] = '''Animate object C with the animation record at DE (AnimateObjectFramePtr_0B) and
draw its frame with DrawMetaspriteRows16_0B: handle from offset $10, X from
$0D, Y from $0F. Unlike bank $00's DrawObjectSprite it does not skip a hitbox
or set $D3EA/$CE55. Not called in this bank.	;[ok]'''
C[0x4302] = '''AnimateObject_0B, then $CE53/$CE54 = the current frame's pointer (the frame
table at offset $15, indexed by the frame at $17).	;[ok]'''
C[0x4320] = '''Animate object C. DE = an animation record (dw frame table, db frames per
step, db frame, ..., $FF). Byte-identical to the object library's
AnimateObject.	;[ok]'''
C[0x4360] = '''Bank $00's DrawMetasprite with two changes: grid rows are 16 px apart, not 8,
and the early exits are plain `ret`s that leave $CE57 alone. Reached only
from AnimateAndDrawObject_0B.	;[ok]'''
C[0x4466] = '''DrawMetaspriteRows16_0B without flips: each tile byte is added whole to the
tile base and $D3EA is used as it is. Not called in this bank.	;[ok]'''

C[0x4516] = '''Play a Wily cutscene. Saves SP in wShotSlots (the skip in the wait routines
returns through it). wWilyProgress & $1F = $1F (before Wily 3): the skull-ship
cutscene. Otherwise (before Wily 1) the first cutscene:
 - the stage select, all four portraits empty and Dr. Wily in the middle
   (WilyStageSelectTilemap over the normal screen), StageSelect music, the
   cursor round the middle slot blinking, until Start;
 - SFX_Shing and 120 frames of palette flashing. E is set to $E4 or 0 by the
   frame count but never used: OBP0 and BGP get the counter itself (0-$10).
   A missing `ld a, e`?	;[?]
 - WilySaucerScene, then CastleBeamDownScene.
Then $DFCF = $FF, which makes the first cutscene skippable from now on.	;[ok]'''
C[0x45F2] = '''Mega Man beams down in front of Dr. Wily's castle: the castle screen fades in
with WilyIntro; the beam drops from above the screen at X $20, accelerating
($60/256 px a frame per frame, at most 16 px a frame) to Y $78; the warp frames;
SFX_Land and the standing pose. When the music posts $E1 to SongCue (a track
event, Audio2_EventCue - the scene waits on the song), 120 frames, the warp
frames again, SFX_Teleport, the beam rises 16 px a frame off the top, 60
frames, fade to white.	;[ok]'''
C[0x4741] = '''Fade BGP to white: $E4, $90, $40, $00, 6 frames apart.	;[ok]'''
C[0x4765] = '''Fade BGP to black: $E4, $F9, $FE, $FF, 6 frames apart.	;[ok]'''
C[0x4789] = '''Start the warp frames: wTeleportState = 1, its counter $DFCD = 0 - Mega Man's
teleport RAM, reused.	;[ok]'''
C[0x4793] = '''Step the warp frames and point the beam record's metasprite at the frame;
wTeleportState = $FF when done.	;[ok]'''
C[0x47A6] = '''Count $DFCD up: DE = TeleportWarpMetasprite1 for counts 1-3,
TeleportWarpMetasprite2 for 4-7, TeleportBeamMetasprite for 8-11; carry at
12.	;[ok]'''
C[0x47C4] = '''The castle scene's metasprites, tile base 0 (CastleSceneTiles).
Mega Man standing (the free tile is the top of his helmet).	;[ok]'''
C[0x47D4] = '''The teleport beam.	;[ok]'''
C[0x47DC] = '''Two frames of the beam turning into Mega Man (or back).	;[ok]'''
C[0x47F6] = '''17 sprite tiles for the castle scene: Mega Man, the beam (tiles 11-15 are
also bank $04's Mega Man tiles 103-107), and in tile 0 the saucer dot that
SkullShipCutscene uses.	;[ok]'''
C[0x4906] = '''Initial sprite records for the saucer scene (copied to wShotCount, +$08,
+$16) and the castle scene. Named by what they show.	;[ok]'''

C[0x4922] = '''Dr. Wily's saucer (named by the picture), on a dark grey screen: SFX_UFO; it
drifts in from the right at 1/2 px a frame to X $50; 120 frames; the dome
lifts 24 px, showing Wily; 60 frames; his face alternates between two frames
12 times (laughing?); the dome closes; 30 frames; the saucer flies off to the
left at 2 px a frame. Scratch: three sprite records (dome, base, Wily) at
wShotCount, +$08, +$16; +$0F the base's 8-frame light toggle; +$10 the dome's
lift; +$12 a sub-pixel accumulator; +$13/+$14 the saucer's X/Y; +$1E the face
count; +$1F set once the dome starts to open.	;[ok]'''
C[0x4A41] = '''Read the joypad until a button in B is held - no frame wait. Nothing calls
it.	;[ok]'''
C[0x4A4F] = '''Draw the saucer and Wily, then wait a frame.	;[ok]'''
C[0x4A59] = '''SaucerSceneFrame B times.	;[ok]'''
C[0x4A62] = '''Draw the dome at the saucer's X, Y - lift, and the base 12 px lower, switching
its frame every 8 frames; falls through to DrawSaucerWily.	;[ok]'''
C[0x4AB7] = '''Draw Wily at the saucer's X + 4, Y: SaucerWilyMetasprite1, or on odd face
counts once the dome is opening, SaucerWilyMetasprite2.	;[ok]'''
C[0x4AEB] = '''BG tiles $8800-$97FF all colour 3, BG map 0 cleared, SaucerTiles to $8420
(sprite tiles $42-$51). The sprite tiles from $8000 are still the stage
select's, so Wily is drawn from WilyStageSelectTiles.	;[ok]'''
C[0x4B0D] = '''The saucer's frames, tile base $42, in the object-frame layout: the records
point past the hitbox, which nothing reads. The dome; its top row is the four
free-placed tiles.	;[ok]'''
C[0x4B2D] = '''The base, two frames of its lights.	;[ok]'''
C[0x4B61] = '''16 sprite tiles of the saucer, loaded to $8420.	;[ok]'''

C[0x4C61] = '''Copy a 20x18 tilemap from HL to the BG map at DE. Byte-identical to bank
$00's CopyTilemap20x18.	;[ok]'''
C[0x4C7B] = '''Wait one frame (DelayFrame through FarCallBank1_0B, then ReadJoypad). Falls
into the next with B = 1.	;[ok]'''
C[0x4C7D] = '''Wait B frames. If A or B is pressed and the first cutscene has been seen
($DFCF set), skip it: wAudioBank = 2, SP back to what PlayWilyCutscene saved,
and `ret` - out of PlayWilyCutscene altogether.	;[ok]'''

C[0x4CA6] = '''Cycle OBP0 every 8 frames so the cursor blinks. Byte-identical to bank $01's
BlinkStageSelectCursor.	;[ok]'''
C[0x4CD7] = '''Draw the stage-select cursor round the middle slot: four one-tile sprites at
its corners, palette OBP0. Falls into DrawWilyCursorCorner for the last.	;[ok]'''
C[0x4CEC] = '''Allocate a one-entry sprite handle into $CC00 and draw the corner record at
HL with it.	;[ok]'''
C[0x4CF9] = '''The cursor's corners, 8-byte records (DrawSpriteRecordIndirectHandle_0B).	;[ok]'''
C[0x4D19] = '''One tile, the cursor's corner.	;[ok]'''
C[0x4D1E] = '''Allocate a 9-entry sprite handle into $CC10 and draw Dr. Wily in the middle
slot.	;[ok]'''
C[0x4D2C] = '''Dr. Wily in the middle slot, tile base 8, palette OBP1.	;[ok]'''
C[0x4D34] = '''Wily's frames, tile base 8, hitbox first as in the saucer's. The middle
slot's portrait, 3x3.	;[ok]'''
C[0x4D45] = '''Wily's face in the saucer, 3x2: two frames that differ in the top-left two
tiles.	;[ok]'''
C[0x4D61] = '''The stage select with all four portraits empty, 20x18, copied to $9800 over
the normal stage-select map; drawn with the stage select's BG tiles.	;[ok]'''
C[0x4EC9] = '''67 sprite tiles, to $8000: the stage-select cursor and 59 tiles of Dr. Wily,
both copies of tiles stored elsewhere, so the source INCBINs those PNGs.	;[ok]'''

C[0x52F9] = '''The second cutscene, before Wily 3: the castle fades in; 60 frames; SFX_UFO;
60 frames; a saucer, one tile, rises from the castle at X $50, Y $50 swaying
from side to side (MoveSaucerDot) until it is off the top. Then
SkullShipArrivalScene.	;[ok]'''
C[0x5386] = '''The saucer dot's sprite record.	;[ok]'''
C[0x538D] = '''Fade to black and show the skull ship (LoadSkullShipScreen) still black, with
seven twinkling stars; SFX_UFO. 60 frames, then the saucer dot rises from the
bottom (X $50, Y $8F), swaying, until it is within 4 px of X $50 and above Y
$50 - it reaches the ship. Sound off, WilyIntro, the ship fades in over 128
frames, and the dot is moved off screen. When the music posts $E1 to
SongCue, 120 frames; then $DFD0 = $FF (skippable from now on) and back.
Scratch: the dot's record at wShotCount; +$08-$0E the stars' counters, seeded
from JumpRNG; +$16 the fade counter; +$1D the sway index; +$1F a sub-pixel
accumulator. $CC00 is a second sub-pixel accumulator here.	;[ok]'''
C[0x5473] = '''On every other call ($CC00 += $80): add the current SaucerDotWobble entry to
the dot's X and step the index (0-$3F), and raise the dot 3/8 px (a pixel on
each carry of +$1F += $60). Carry once it has gone off the top (Y $92-$EF).	;[ok]'''
C[0x54AD] = '''The seven stars, as OAM entries.	;[ok]'''
C[0x54CA] = '''Write the stars straight into shadow OAM entries 8-14 ($C020): each star's
counter counts up every frame and the star shows when its bits 1-2 are clear,
2 frames in 8; otherwise its entry is SkullShipHiddenStar.	;[ok]'''
C[0x5509] = '''Wait one frame. Falls into the next with B = 1.	;[ok]'''
C[0x550B] = '''Wait B frames; skippable with A or B once $DFD0 is set, as
CastleCutsceneWaitFrames.	;[ok]'''
C[0x5534] = '''Three sprite tiles to $8010 (tiles 1-3): stars, small to large. They are
also bank $04's stage-select tiles 2, 4 and 6.	;[ok]'''
C[0x5564] = '''Fade BGP in from black: $FE, $F9, $E4, 3 frames apart.	;[ok]'''
C[0x5583] = '''BGP values for the skull ship's fade-in.	;[ok]'''
C[0x5587] = '''The saucer dot: tile 0, hitbox first.	;[ok]'''
C[0x5590] = '''64 X offsets for the dot's sway, one every other frame.	;[ok]'''

CHUNKS = {
 0x4000: ('engine/cutscenes/kit_0b.asm', 'Bank 0B Kit'),
 0x4516: ('engine/cutscenes/castle_cutscene.asm', 'Castle Cutscene'),
 0x4922: ('engine/cutscenes/wily_saucer.asm', 'Wily Saucer Scene'),
 0x4C61: ('engine/cutscenes/helpers_0b.asm', 'Bank 0B Scene Helpers'),
 0x4CA6: ('engine/cutscenes/wily_stage_select.asm', 'Wily Stage Select'),
 0x52F9: ('engine/cutscenes/skull_ship_cutscene.asm', 'Skull Ship Cutscene'),
}
def _fh(title, extra=''):
    return (";Mega Man: Dr. Wily's Revenge disassembly - %s\n"
            ";Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is\n"
            ";pinned to its original address. Confidence tags: [ok] verified here, [dc]\n"
            ";corroborated by Data Crystal, [?] guess.\n%s") % (title, extra)
FILEHEAD = {
 'engine/cutscenes/kit_0b.asm': _fh("bank $0B's helper kit", r''';
;$4003-$4515 is a kit of helpers that bank $0E carries as well, near-identical
;(up to $455B there); bank $0C holds pieces of it (FarCallBank1,
;Bank1TrampolineCode, InitSpriteSystem_0C) and bank $08 the tile-copy pair. Routines
;that match a counterpart elsewhere carry its name with _0B added. Nothing in
;this bank calls QueueTileCopy_0B, CopyQueuedTiles_0B, AccumulatePlayerDX_0B,
;SetPlayerScreenX_0B, ClampToScrollLimits_0B, WriteVRAMByteAtDE_0B, QueueLeftScrollColumn_0B,
;DrawSpriteRecordIndirect_0B, AnimateAndDrawObject_0B (and so its helpers and
;DrawMetaspriteRows16_0B) or DrawMetaspriteRows16NoFlip_0B.	;[ok]
'''),
 'engine/cutscenes/castle_cutscene.asm': _fh('the first Wily cutscene'),
 'engine/cutscenes/wily_saucer.asm': _fh("the first cutscene's saucer scene"),
 'engine/cutscenes/helpers_0b.asm': _fh("the first cutscene's helpers"),
 'engine/cutscenes/wily_stage_select.asm': _fh("the first cutscene's stage select"),
 'engine/cutscenes/skull_ship_cutscene.asm': _fh('the second Wily cutscene'),
}

# Step 7.3d: the last provisional Func_ labels, renamed in the source (which
# has been hand-edited since; do not regenerate it from this config).
NAMES.update({
 0x40CA: 'AccumulatePlayerDX_0B',
 0x40EC: 'SetPlayerScreenX_0B',
 0x40F4: 'GetPlayerScreenX_0B',
 0x4153: 'QueueLeftScrollColumn_0B',
})
