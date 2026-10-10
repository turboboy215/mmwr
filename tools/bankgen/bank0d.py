#Config for tools/bankgen.py: ROM bank $0D (step 5.6). See the note in
#tools/bankgen.py: this bootstrapped the bank, and the .asm files it wrote are
#now the source of truth.
import sys as _sys
_sys.path.insert(0, 'tools/bankgen')
from objlib import lib as _lib
BANK = 0xD
END = 0x6311
LIB = 0x401B
_ln, _lc, _lo, _ld, _ldata = _lib(LIB)


HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0D
;
;The third object bank ($03, $09, $0D): code for 9 object types, reached only
;through ObjectTypeTab - Quick Man and his Quick Boomerangs, the Wily Machine
;fight (types 48-52), the hub's teleporter lights and its sign. 100% source
;since step 5.6. The bank is:
;
;  $4000-$401A  the entry table: one `jp` per object type, in ObjectTypeTab
;               order (slot n is the type listed against it there)
;  $401B-$471C  the object library, engine/object_library.asm (shared with
;               banks $03 and $09; its labels end in {OBJBANK}, _0D here)
;  $471D-$478E  copies of bank $08's QueueTileCopy/CopyQueuedTiles (with the
;               `scf` that banks $0B and $0E have), engine/objects/tile_copy_0d.asm
;  $478F-$48D8  helpers the Wily Machine types share: a state pointer at
;               offsets $3E/$3F, the boss-bar fill, the part record
;  $48D9-$5A75  the Wily Machine fight: types 48-52, then their animations,
;               frames and the room's background tiles (wily_machine_data.asm)
;  $5A76-$6310  Quick Man (46), his Quick Boomerang (47), the teleporter light
;               (53) and the teleport system sign (56), each with its data,
;               ending with a direction helper Quick Man and type 47 share
;  $6311-$7FFF  unused, all $FF
;
;Object modes are as in banks $03 and $09: B = 0 spawn, 1 frame, 2 killed, 3
;frozen by Ice Slasher; B = 0 on return removes the object. Quick Man does not
;end his own fight - the three type 47s placed beside him do. Types 48-52 run
;on a state pointer instead of a state number: ObjSetState stores a handler's
;address at offsets $3E/$3F and the frame call jumps there.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$6311-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank D Free Space", ROMX[$6311], BANK[$D]
	ds $8000 - $6311, $FF
'''
SLOTS = [(0x4000 + 3*i, ROM[0x4001+3*i] | ROM[0x4002+3*i] << 8) for i in range(9)]
ENTRIES = [t for _, t in SLOTS] + [a for a, _ in SLOTS] + _ld + [a for a in _ln if a not in [x[0] for x in _ldata]]
DATA = list(_ldata)
NAMES = dict(_ln)
COMMENTS = dict(_lc)
OPER = dict(_lo)
# slot address -> (type, name, file); 0 for the shared code chunks
OBJS = {
 0x48D9: (48, 'WilyMachine', 'wily_machine'), 0x4DC9: (49, 'WilyMachineLowerCannon', 'wily_machine_lower_cannon'), 0x4F06: (50, 'WilyMachineBitingHead', 'wily_machine_biting_head'),
 0x50AF: (51, 'WilyMachineCannonShot', 'wily_machine_cannon_shot'), 0x51BB: (52, 'WilyMachineCuttingWheel', 'wily_machine_cutting_wheel'), 0x5A76: (46, 'QuickMan', 'quick_man'),
 0x5EC2: (47, 'QuickManQuickBoomerang', 'quick_man_quick_boomerang'), 0x61C3: (53, 'TeleporterLight', 'teleporter_light'),
 0x625C: (56, 'TeleportSystemSign', 'teleport_system_sign'),
}
CHUNKS = {0x4000: ('engine/objects/entry_table_0d.asm', 'Bank D Entry Table'),
          LIB: ('engine/object_library.asm', 'Object Library 0D'),
          0x471D: ('engine/objects/tile_copy_0d.asm', 'Tile Copy 0D'),
          0x478F: ('engine/objects/wily_machine_helpers.asm', 'Wily Machine Helpers'),
          0x527A: ('engine/objects/wily_machine_data.asm', 'Wily Machine Data'),
          0x62D2: ('engine/objects/get_direction_to_point.asm', 'Direction Helper 0D')}
def _fh(title):
    return (";Mega Man: Dr. Wily's Revenge disassembly - %s\n"
            ";Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is\n"
            ";pinned to its original address. Confidence tags: [ok] verified here, [dc]\n"
            ";corroborated by Data Crystal, [?] guess.\n") % title
FILEHEAD = {'engine/objects/entry_table_0d.asm': _fh("bank $0D's entry table"),
 'engine/objects/tile_copy_0d.asm': _fh("bank $0D's copy of the queued tile copy"),
 'engine/objects/wily_machine_helpers.asm': _fh("helpers shared by the Wily Machine types (48-52)"),
 'engine/objects/wily_machine_data.asm': _fh("the Wily Machine types' animations, frames and\n;background tiles"),
 'engine/objects/get_direction_to_point.asm': _fh("GetDirectionToPoint, used by Quick Man and type 47")}
for _a, (_t, _n, _f) in OBJS.items():
    CHUNKS[_a] = ('engine/objects/%s.asm' % _f, '%s (type %d)' % (_n, _t))
    FILEHEAD['engine/objects/%s.asm' % _f] = _fh('object type %d, %s' % (_t, _n))
    NAMES[_a] = _n + 'Routine'
for _a, _t in SLOTS:
    NAMES[_a] = 'Entry_0D_%04X' % _a
from objlib import HEAD as _lh
FILEHEAD['engine/object_library.asm'] = _lh
SHARED = ('engine/object_library.asm', LIB, LIB + 0x702, 'OBJBANK', '_0D')

L = lambda **k: k
def FR(s, e, tables, frames=(), hitbox=True):
    return (s, e, None, 'frames', L(tables=tables, frames=list(frames), hitbox=hitbox))
FRAMEPFX = '0D_'
C = COMMENTS

# ---- step 5.6: classifying the gaps. Code reached only through ObjSetState
# (`ld de, handler` / `call` or `jp ObjSetState`, or ObjStartBossBarFill's next
# state), and one unreferenced routine.
ENTRIES += [0x47B3, 0x4988, 0x49A8, 0x49BF, 0x49D8, 0x49E7, 0x4A2B, 0x4A95, 0x4AA9, 0x4AC9,
            0x4AFB, 0x4B2D, 0x4B68, 0x4B9F, 0x4BD9, 0x4E45, 0x4E64, 0x4F88, 0x4FA3, 0x5023,
            0x4981]
DATA += [
 FR(0x4888, 0x48D9, [0x4888], hitbox=False),
 (0x4A23, 0x4A2B, None, 'db', L(width=2)),
 (0x4A93, 0x4A95, None, 'db', {}),
 (0x4B64, 0x4B68, None, 'db', {}),
 (0x4C34, 0x4C40, None, 'db', L(width=3)),
 (0x4E06, 0x4E08, None, 'db', {}),
 (0x4E08, 0x4E0C, None, 'db', {}),
 (0x4F4C, 0x4F4E, None, 'db', {}),
 (0x50D7, 0x50DF, None, 'db', L(width=4, labels={0x50DB: 'WilyMachineCannonShotReflectedSpeed'})),
 (0x51F1, 0x5211, None, 'db', L(width=4)),
 (0x527A, 0x52C4, None, 'anim', {}),
 FR(0x52C4, 0x5438, [0x52C4]),
 (0x5438, 0x543E, None, 'anim', {}),
 FR(0x543E, 0x5476, [0x543E]),
 (0x5476, 0x5976, None, 'raw', L(lines=['\tINCBIN "gfx/wily_machine/room.2bpp"', 'WilyMachineRoomTilesEnd:'])),
 (0x5976, 0x5A76, None, 'raw', L(lines=['\tINCBIN "gfx/wily_machine/room_dome_open.2bpp"', 'WilyMachineDomeOpenTilesEnd:'])),
 (0x5CFC, 0x5D00, None, 'db', {}),
 FR(0x5D00, 0x5EC2, [0x5D00]),
 (0x6157, 0x6197, None, 'db', L(width=4)),
 FR(0x6197, 0x61C3, [0x6197]),
 (0x61D3, 0x61DD, None, 'db', L(width=2)),
 (0x623B, 0x6240, None, 'db', {}),
 (0x6240, 0x6246, None, 'anim', {}),
 FR(0x6246, 0x625A, [0x6246]),
 (0x625A, 0x625C, None, 'db', {}),
 (0x62A5, 0x62AB, None, 'anim', {}),
 FR(0x62AB, 0x62D2, [0x62AB]),
]
OPER.update({
 # frame tables stored straight into OBJ_FRAMES
 0x4927: 'LOW(@@52C4)', 0x492A: 'HIGH(@@52C4)', 0x5A92: 'LOW(@@5D00)', 0x5A95: 'HIGH(@@5D00)',
 0x5EFB: 'LOW(@@6197)', 0x5EFE: 'HIGH(@@6197)',
 # table + computed index: add a, LOW / adc a, HIGH
 0x49FB: 'LOW(@@4A23)', 0x4A00: 'HIGH(@@4A23)', 0x51DD: 'LOW(@@51F1)', 0x51E2: 'HIGH(@@51F1)',
 0x61E5: 'LOW(@@61D3)', 0x61EA: 'HIGH(@@61D3)', 0x6206: 'LOW(@@623B)', 0x620B: 'HIGH(@@623B)',
 # a frame used for its hitbox, and one drawn straight (past its 4-byte hitbox)
 0x513C: 'LOW(@@5360)', 0x5141: 'HIGH(@@5360)', 0x4DAB: '@@5356 + 4',
 # the home position read as data
 0x4FF9: '@@4F4C', 0x502D: '@@4F4C', 0x5031: '@@4F4C + 1',
 # the tile streams
 0x498D: 'VRAM_TILES2', 0x4990: 'WilyMachineRoomTilesEnd - @@5476',
 0x49C4: 'VRAM_TILES2', 0x49C7: 'WilyMachineDomeOpenTilesEnd - @@5976',
})

# ---- the shared code before the first object
NAMES.update({0x471D: 'QueueTileCopy_0D', 0x4739: 'CopyQueuedTiles_0D'})
C[0x471D] = '''Set up a chunked copy of BC bytes from HL to DE, A bytes at a time, for
CopyQueuedTiles_0D. Byte-identical to bank $08's QueueTileCopy. The Wily Machine
streams its background tiles in with the pair.	;[ok]'''
C[0x4739] = '''Copy the next chunk of the queued copy through JumpCopyVRAM. As bank $08's
CopyQueuedTiles, plus a `scf` (as in banks $0B and $0E): returns carry when it
copied a chunk, NC when nothing was left.	;[ok]'''
NAMES.update({0x478F: 'ObjSetPosition', 0x479A: 'ObjStartBossBarFill', 0x47B3: 'ObjFillBossBar',
 0x47E5: 'ObjSetState', 0x47ED: 'SpawnExplosionBurstAt', 0x47F9: 'AllocPartRecord',
 0x4812: 'AllocVisorLightSprite', 0x482E: 'DrawVisorLight', 0x487B: 'FreeVisorLightSprite',
 0x4888: 'VisorLightFrames'})
C[0x478F] = '''The object's screen X (offset $0D) and Y ($0F) from the two bytes at DE.	;[ok]'''
C[0x479A] = '''Start filling the boss bar (bank $00 draws $C101 as its length): $3A = B
(never read), $3C/$3D = DE, the state to go to when it is full; $C101 = 0;
a 3-entry sprite for the animation that plays meanwhile; state ObjFillBossBar.	;[ok]'''
C[0x47B3] = '''State: draw the visor light and every 5 frames add 8 to $C101, with sound
7, until it reaches $98; then free the sprite, give the object $13 hit points
and go to the state saved at $3C/$3D. Used by types 48 and 49.	;[ok]'''
C[0x47E5] = '''The state pointer: the frame code of types 48-50 jumps to the address at
offsets $3E/$3F (pushing its own continuation as the return address). This
sets it to DE.	;[ok]'''
C[0x47ED] = '''An explosion burst (CallBank1Routine 1, SpawnExplosionBurst, B = $0C) at
X = E, Y = D.	;[ok]'''
C[0x47F9] = '''Take an object slot (AllocObjectSlot) without putting it in the active list -
so no routine runs for it - and return its record address in DE ($C600 +
slot * $40). Type 48 uses one to hold its cannon's position and sprite.	;[ok]'''
C[0x4812] = '''Get a 3-entry sprite handle into offset $30 for the visor light (the light on
the Wily Machine's visor that animates while the boss bar fills - Will), and
start it at frame 0 (offset $2D) with a 5-frame step ($2C).	;[ok]'''
C[0x482E] = '''Step and draw the visor light (Will: part of the Wily Machine's visor): 9 frames (VisorLightFrames), one
every 5 frames, drawn at the fixed screen point (X $74, Y $47) with the
object's tile base + $69 and attributes $10.	;[ok]'''
C[0x487B] = '''Free the visor light's sprite handle (offset $30).	;[ok]'''
C[0x4888] = '''Nine 3x1 metasprites (no hitbox), DrawMetasprite format.	;[ok]'''

# ---- step 5.6: the object routines. Types 49-52 are never placed; the
# SpawnChildObject callers in this bank make them (49 $4EBE, 52 $4EDD, 50
# $5099, 51 $5198).
C[0x48D9] = '''Type 48, placed once in Wily 3's last room: the Wily Machine fight, run as a
chain of states (ObjSetState). It is what makes the room the Wily Machine: its
spawn streams the room's background tiles, WilyMachineRoomTiles (80 tiles,
bank $0D's own - not bank $06's cutscene set), to $9000.	;[ok]
Spawn: wWilyProgress $9F, wBossesDefeated $0F, $CC5B-$CC5D cleared (fight
flags, damage, flash timer), palettes black, invisible (flags 0), controls
locked ($D845), wStageState 1. Then:
 1 stream the 80 tiles in, $40 bytes a frame; spawn type 49; fade in over 128
   frames (WilyMachineFadeInPalettes) and show the boss bar ($C100).
 2 type 49 fills the bar and fights (phase 1). When it is killed ($CC5B bit
   0) and the explosions are over: a burst at (X $7C, Y $2B), and 10 frames
   later this object appears there - Dr. Wily in the cockpit, a hitbox over
   the whole machine but hit points $FE - with type 50 and the cannon part
   (WilyMachineInitCannon); then 16 tiles are streamed over the first ones,
   which opens the dome in the background (WilyMachineDomeOpenTiles).
 3 sound $19, 300 frames, then the bar refills (ObjStartBossBarFill) and
   $CC5B bit 1 starts phase 2: the cannon fires type 51s, type 50 bites, and
   the only damage is $CC5C, written by a type 51 that Mirror Buster sent back
   (WilyMachineCheckDamage: 8 bar units per point, 20-frame flash).
 4 bar empty ($CCF5): a death explosion at the cannon; after the explosions,
   150 frames of palette flicker and explosion sounds; then a 12-tile sprite:
   Dr. Wily jumps out and falls to Y $64, wStageState 2 (the victory jingle);
   360 frames, 180 more, a fade to white (WilyFadePalettes); then
   wVictoryTimer 0 and wStageState 3, so StageFrameLoop's .stageCleared runs
   with stage index 6 and jumps to .ending (bank $0E). The victory timer is
   held at $01E0 every frame until then.	;[ok]
Frame: runs the state (unless anything is frozen), the cannon and the damage
check, and keeps its position at $CCF2/$CCF3. Killed: B = 0 (it is never
shootable with hit points that can run out). Ice Slasher: ObjClearFreeze.	;[ok]'''
NAMES.update({0x495C: 'WilyMachineFrame', 0x4988: 'WilyMachineLoadTiles', 0x49A8: 'WilyMachineWaitTiles',
 0x49BF: 'WilyMachineLoadDomeOpenTiles', 0x49D8: 'WilyMachineWaitDomeOpenTiles', 0x49E7: 'WilyMachineFadeIn',
 0x4A23: 'WilyMachineFadeInPalettes', 0x4A2B: 'WilyMachineWaitPhase1', 0x4A93: 'WilyMachineCockpitPosition',
 0x4A95: 'WilyMachineStartPause', 0x4AA9: 'WilyMachinePause', 0x4AC9: 'WilyMachinePhase2',
 0x4AFB: 'WilyMachineExplode', 0x4B2D: 'WilyJumpOut', 0x4B64: 'WilyJumpVelocity', 0x4B68: 'WilyFall',
 0x4B9F: 'WilyLanded', 0x4BD9: 'WilyFadeOut', 0x4C34: 'WilyFadePalettes',
 0x4C40: 'WilyMachineCheckDamage', 0x4CC9: 'WilyMachineInitCannon', 0x4D06: 'WilyMachineCannonExplosion',
 0x4D1D: 'WilyMachineUpdateCannon', 0x4D42: 'WilyMachineMoveCannon', 0x4D87: 'WilyMachineDrawCannon',
 0x4DB4: 'WilyMachineExplosionSound', 0x5476: 'WilyMachineRoomTiles', 0x5976: 'WilyMachineDomeOpenTiles'})
C[0x4981] = '''Unused: nothing calls it. Animates through all 22 frames (Data_0D_527A).	;[ok]'''
C[0x4A2B] = '''State: wait for type 49's death ($CC5B bit 0) and the end of the explosions,
then the burst and the appearance (10-frame countdown in $27). The `call
JumpCallBank1Routine` with A = 0 here is never reached ($09 is non-zero there,
so `inc a / cp 1` never matches).	;[ok]'''
C[0x4A23] = '''BGP, OBP1 pairs for the fade in, 32 frames each.	;[ok]'''
C[0x4C34] = '''Four 3-byte entries, of which only the first byte is read: BGP (also OBP0,
OBP1) for the fade to white, 4 frames each.	;[ok]'''
C[0x4C40] = '''Phase 2's damage, once $CC5B bit 1 is set (and not bit 3, the death
sequence; not after the fade starts, $2A). While $CC5D runs the palette
flashes; else $CC5C points come off the bar (x 8) and start a 20-frame flash.
At 0: if Mega Man is dying ($DF94) the bar stays at 1; otherwise $CCF5 (boss
beaten), controls locked, pause disabled ($DF41), $CC5B bit 2, a death
explosion at the cannon and AudioStopAll.	;[ok]'''
C[0x4CC9] = '''Set up the cannon: a slot record that is never run (AllocPartRecord), kept at
$2E/$2F, with a 2-entry sprite, at (X $78, Y $4B), $09 = 1, this object's tile
base.	;[ok]'''
C[0x4D1D] = '''The cannon, in phase 2 until the boss is beaten: it moves 4 px a frame
between Y $4B and $6B ($09: 0 up, 1 down; bit 1 waiting), waits 120 frames at
each end and fires a type 51 (WilyMachineCannonShotSpawn); drawn with frame 6 every frame.	;[ok]'''
C[0x4DB4] = '''Sound 2 every 128 frames and at random about 1 frame in 5.	;[ok]'''

C[0x4DC9] = '''Type 49: never placed; spawned by type 48 (WilyMachineLowerCannonSpawn) once the room's tiles
are in. The Wily Machine's lower cannon (3x3 frames $0A/$0B), phase 1 of the
fight. At (X $6B, Y $5C), shots destroyed (hit points $FF) until the bar shows;
then it fills the bar (ObjStartBossBarFill: 19 hit points), unlocks Mega Man
and after 60 frames bobs between Y $5C and $64 at 0.8 px a frame, pausing 20
frames at each end; each time it reaches the bottom it fires a type 52
(WilyMachineCuttingWheelSpawn), alternately one of the four lobs and one of the four low
throws. The bar shows its hit points. Killed: $CC5B bit 0 (type 48 goes on),
sound 2, removed. Ice Slasher: ObjClearFreeze.	;[ok]'''
NAMES.update({0x4DEC: 'WilyMachineLowerCannonInit', 0x4E0C: 'WilyMachineLowerCannonFrame', 0x4E20: 'WilyMachineLowerCannonSyncPosition', 0x4E06: 'WilyMachineLowerCannonStartPosition',
 0x4E08: 'WilyMachineLowerCannonVelocity', 0x4E45: 'WilyMachineLowerCannonWaitForBar', 0x4E64: 'WilyMachineLowerCannonFight', 0x4EBC: 'WilyMachineLowerCannonSpawn',
 0x4ED4: 'WilyMachineCuttingWheelSpawn'})
C[0x4EBC] = '''Spawn a type 49 with this object's tile base and run WilyMachineLowerCannonInit on it.	;[ok]'''
C[0x4ED4] = '''Spawn a type 52 at this object, tile base + $61, $CC08 = B | random 0-3 (B =
0 or 4), and run WilyMachineCuttingWheelInit on it.	;[ok]'''

C[0x4F06] = '''Type 50: never placed; spawned by type 48 (WilyMachineBitingHeadSpawn) when phase 2 begins. A
biting head (frames 0-5) that waits at (X $94, Y $33) - WilyMachineBitingHeadHome - for 180
frames, then flies 2 px a frame (LineStep) to where Mega Man was, waits 60
frames and flies home. Hit points $FE: shots bounce off. Only moves while
$CC5B bit 1 is set. Once the boss is beaten (and when killed) it zeroes its hit
points and keeps its position at $CCF2/$CCF3, returning B = 1.	;[ok]'''
NAMES.update({0x4F2C: 'WilyMachineBitingHeadInit', 0x4F4C: 'WilyMachineBitingHeadHome', 0x4F88: 'WilyMachineBitingHeadWait', 0x4FA3: 'WilyMachineBitingHeadFly',
 0x5023: 'WilyMachineBitingHeadWaitAtTarget', 0x503E: 'WilyMachineBitingHeadCheckAtTarget', 0x5063: 'WilyMachineBitingHeadStartLine', 0x5097: 'WilyMachineBitingHeadSpawn'})
C[0x503E] = '''Carry if the object is within 4 px of the target at $28/$29 on both axes.	;[ok]'''
C[0x5063] = '''Start a line (LineStepInit) from the object to (E, D), keeping the target at
$28/$29 and LineStep's state at $2D-$33.	;[ok]'''

C[0x50AF] = '''Type 51: never placed; the cannon's shot (WilyMachineCannonShotSpawn, from type 48's cannon).
Flies left 6 px a frame (frames 7-9); hit points $FE. While Mirror Buster is
the current weapon (wCurrentWeapon $0A), a player shot touching it (frame 7's
hitbox, JumpCheckShotHit) costs 8 Mirror Buster energy ($DFAD) and sends it back
($09 = $FF): right at 6 px a frame (frames $0C-$0E); at X $70, unless the
machine is still flashing ($CC5D), it writes 2 to $CC5C - the only damage the
Wily Machine takes in phase 2 - and goes off screen. Removed off screen and
when the boss is beaten.	;[ok]'''
NAMES.update({0x50C2: 'WilyMachineCannonShotInit', 0x50D7: 'WilyMachineCannonShotSpeed', 0x5113: 'WilyMachineCannonShotMove', 0x5172: 'WilyMachineCannonShotMoveReflected',
 0x5196: 'WilyMachineCannonShotSpawn'})
C[0x5196] = '''Spawn a type 51 at object C (the cannon), with its tile base, and run
WilyMachineCannonShotInit on it.	;[ok]'''

C[0x51BB] = '''Type 52: never placed; thrown by type 49 (WilyMachineCuttingWheelSpawn) - a spiked wheel
(sound $11 at spawn, as type 1's Cutting Wheel). $CC08 & 7 picks a leftward
velocity (WilyMachineCuttingWheelVelocities): 0-3 lobs (Y -5 to -6 px a frame), 4-7 low throws.
Falls under gravity through walls; between Y $68 and $77 the lobs bounce and
the low throws (bit 2) land on Y $68 and roll. Removed at screen X $90-$EF.
Frames 0-1 every 2 frames.	;[ok]
Will: the Wily fight uses another version of the Cutting Wheel; this is it.	;[?]'''
NAMES.update({0x51CE: 'WilyMachineCuttingWheelInit', 0x51F1: 'WilyMachineCuttingWheelVelocities', 0x5243: 'WilyMachineCuttingWheelMove'})

C[0x527A] = '''The Wily Machine types' animations, all on FrameTable_0D_52C4: this one runs
through all 22 frames (only the unused $4981 uses it); then type 49, type 48
(the cockpit), type 50, type 51, type 51 sent back, Dr. Wily falling, landed.	;[ok]'''
C[0x5476] = '''Background tiles $00-$4F of the Wily Machine room, streamed in by type 48: its
blockset draws the machine with these (gfx/wily_machine/room.png). Not the
same bytes as bank $06's Wily Machine cutscene tiles, which only look alike.	;[ok]'''
C[0x5976] = '''16 tiles streamed over tiles $00-$0F when phase 2 begins: the dome is gone
(gfx/wily_machine/room_dome_open.png).	;[ok]'''

C[0x5A76] = '''Quick Man (type 46), the boss behind Wily 2's first teleporter. State $27: 0
drop in; 1 intro poses while the bar fills; 4 run 2 px a frame (within X
$1C-$88) for 120 frames, then 3: two jumps at Mega Man (X speed half his
distance, a random Y speed from QuickManJumpSpeeds). On one of the jumps,
picked at random ($2B: the first 2 times in 4, the second 1 in 4, none 1 in
4), once he is falling he sets $CCF6 = $30 | (direction * 2 + 1)
(GetDirectionToPoint): three type 47s fly out. Killed: B = 0 only (type 47
ends the fight). Time Stopper (wFreezeFlags bit 3) stops him and takes a hit
point every 50 frames; other freezes just stop him.	;[ok]'''
NAMES.update({0x5AB1: 'QuickManTimeStopperDamage', 0x5AC8: 'QuickManFrame', 0x5B14: 'QuickManIntro',
 0x5B64: 'QuickManJump', 0x5C13: 'QuickManRun', 0x5C8C: 'QuickManSetFrame', 0x5CA5: 'QuickManStartJump',
 0x5CE2: 'QuickManStartRun', 0x5CFC: 'QuickManJumpSpeeds'})

C[0x5EC2] = '''Type 47, three placed beside Quick Man: his Quick Boomerangs, parked off
screen. Each parked one that sees $CCF6 takes a direction from it and counts
the high nibble down, so the three fan out 22.5 degrees apart: from the boss
position it flies 2 px a frame (QuickBoomerangVelocities, 16 directions) for
32 frames, holds 20, then flies at Mega Man until it leaves the screen, and
parks. Frames 0-3 every 4 frames. Every frame it runs CheckBossDead; once he is
beaten it parks, the first one sets wStageState 2 ($CCF7) and the victory
countdown starts once ($CCF8), B = 2. Time Stopper holds it (still ending the
fight); other freezes stop it.	;[ok]'''
NAMES.update({0x5F16: 'QuickBoomerangHold', 0x5F19: 'QuickBoomerangTimeStopped', 0x5F25: 'QuickBoomerangFrame',
 0x5FA3: 'QuickBoomerangPark', 0x5FC8: 'QuickBoomerangBossBeatenInFlight', 0x5FFB: 'QuickBoomerangFly',
 0x605F: 'QuickBoomerangTurn', 0x6099: 'QuickBoomerangBossBeaten', 0x60CC: 'QuickBoomerangVictory',
 0x60DD: 'QuickBoomerangAnimate', 0x60F3: 'QuickBoomerangStep', 0x612B: 'QuickBoomerangSetVelocity',
 0x6157: 'QuickBoomerangVelocities'})
C[0x6157] = '''X, Y speed (8.8) for 16 directions clockwise from up, 2 px a frame.	;[ok]'''

C[0x61C3] = '''Type 53, placed in Wily 2's two teleporter hubs (lights 0-3 in the four-teleporter
hub, 0-4 in the five-teleporter one), param = the teleporter:
its light. Placed by TeleporterLightPositions (X + 5, Y - $15) and drawn,
blinking every 12 frames, only while that teleporter's bit in wWilyProgress
(TeleporterLightBits: Quick Man, Bubble Man, Flash Man, Heat Man, Enker) is
clear - so it marks the teleporters whose boss is still to beat. Never hurts.
Killed: removed.	;[ok]'''
NAMES.update({0x61D3: 'TeleporterLightPositions', 0x61DD: 'TeleporterLightSetPosition',
 0x61FF: 'TeleporterLightUpdate', 0x623B: 'TeleporterLightBits'})
C[0x625A] = '''Two stray bytes after the empty frame, which ends at its zero grid byte.	;[ok]'''

C[0x625C] = '''Type 56, placed once in each of Wily 2's teleporter hubs: the "DR.WILY TELEPORT SYSTEM"
sign. Spawned at screen (X $4B, Y $1D); blinks (frame 1, the sign, and frame
0, empty, 24 frames each; stops while anything is frozen). Every frame OBP1 =
$04 while the screen is black (BGP $FF), else $84. Killed: removed.	;[ok]'''

NAMES.update({0x62D2: 'GetDirectionToPoint'})
C[0x62D2] = '''A = the direction of point (C, B) from (E, D), 0-7 clockwise from up (0 up,
2 right, 4 down, 6 left); within $18 px counts as level on that axis. The
same code as bank $09's unused GetDirectionToPoint_09
($7CF3).	;[ok]'''

# ---- after step 5.6, from Will: types 49 and 50 have no official names, so they
# are named by role; Wily's landed frames are his bow after the fight (they
# use 7-bit tile numbers, $CE57, so tools/objframes.py needs its "7" option).
NAMES[0x4DC9] = 'WilyMachineLowerCannonRoutine'
C[0x4DC9] = "The lower cannon (no official name - Will).\t;[ok]\n" + C[0x4DC9]
C[0x4F06] = "The biting head (no official name - Will).\t;[ok]\n" + C[0x4F06]
C[0x51BB] = "The Wily fight's version of the Cutting Wheel (Will; the ending draws CUTTING\nWHEEL with these tiles).\t;[ok]\n" + C[0x51BB]
C[0x4B9F] = """Dr. Wily has landed: he bows (frames $13/$14 - Will) until the victory
jingle's timer runs out, then the fade-out.\t;[ok]"""

# Step 7.3d: the last provisional Func_ labels, renamed in the source (which
# has been hand-edited since; do not regenerate it from this config).
NAMES.update({
 0x4981: 'WilyMachineAnimateUnused',
 0x4F13: 'WilyMachineBitingHeadBeaten',
 0x4F29: 'WilyMachineBitingHeadClearFreeze',
 0x4F4E: 'WilyMachineBitingHeadUpdate',
 0x4F6F: 'WilyMachineBitingHeadAnimate',
 0x4F75: 'WilyMachineBitingHeadEndFrame',
 0x50BC: 'WilyMachineCannonShotRemove',
 0x50BF: 'WilyMachineCannonShotClearFreeze',
 0x50DF: 'WilyMachineCannonShotUpdate',
 0x5211: 'WilyMachineCuttingWheelUpdate',
 0x5A88: 'QuickManClearFreeze',
 0x5A8B: 'QuickManInit',
 0x5B11: 'QuickManEndFrame',
 0x6049: 'QuickBoomerangEndFrame',
})
