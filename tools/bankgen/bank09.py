#Config for tools/bankgen.py: ROM bank $09 (step 5.2). See the note in
#tools/bankgen.py: this bootstrapped the bank, and the .asm files it wrote are
#now the source of truth.
BANK = 9
END = 0x7D32

HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $09
;
;One of the three object banks ($03, $09, $0D): code for 24 object types,
;reached only through ObjectTypeTab (every object's OBJ_BANK). 100% source since
;step 5.2. The bank is three parts:
;
;  $4000-$4047  the entry table: one `jp` per object type, in ObjectTypeTab
;               order (slot n is the type listed against it there)
;  $4048-$4749  the object library, engine/object_library.asm - the same 1794
;               bytes of helpers are in banks $03 ($4042) and $0D ($401B), so the
;               file is shared: its labels end in {OBJBANK} (_09 here)
;  $474A-$7D31  the 24 objects' routines and their animation data, one file per
;               object type in engine/objects/, in ROM order
;  $7D32-$7FFF  unused, all $FF
;
;An object routine is called with B = 0 when the object is spawned, 1 every
;frame, 2 when its hit points reach zero, and 3 instead of 1 while it is frozen
;by Ice Slasher; it returns B = 0 to be removed. See CallObjectRoutine.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$7D32-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 9 Free Space", ROMX[$7D32], BANK[$9]
	ds $8000 - $7D32, $FF
'''

# slot -> (type, name)
SLOTS = [
 (0x474A, 10, 'FireBeam'), (0x4AE6, 11, 'Changkey'), (0x4BC0, 12, 'ChangkeyMaker'), (0x4DDD, 13, 'Drillun'),
 (0x4ED7, 14, 'KaminariGoroThrower'), (0x5151, 15, 'KaminariGoro'), (0x53BF, 19, 'Pipi'), (0x58D4, 24, 'Scworm'),
 (0x5966, 25, 'ScwormSpawn'), (0x50E8, 26, 'KaminariGoroShot'), (0x551D, 27, 'PipiEgg'), (0x5753, 28, 'Copipi'),
 (0x5B73, 39, 'EnkerShot'), (0x5C5A, 38, 'Enker'), (0x61CB, 4, 'SniperJoe'), (0x6575, 29, 'AtomicFireBlock'),
 (0x6639, 40, 'BubbleMan'), (0x6A79, 41, 'BubbleManBubbleLead'), (0x6CFE, 42, 'FlashMan'),
 (0x73DD, 43, 'FlashManDefeatWatcher'), (0x746A, 44, 'HeatMan'), (0x793F, 45, 'HeatManAtomicFire'),
 (0x7239, 54, 'FlashManFreeze'), (0x7B36, 55, 'BossDoor'),
]
FILES = {10: 'fire_beam', 11: 'changkey', 12: 'changkey_maker', 13: 'drillun', 14: 'kaminari_goro_thrower', 15: 'kaminari_goro',
 19: 'pipi', 24: 'scworm', 25: 'scworm_spawn', 26: 'kaminari_goro_shot', 27: 'pipi_egg', 28: 'copipi', 39: 'enker_shot',
 38: 'enker', 4: 'sniper_joe', 29: 'atomic_fire_block', 40: 'bubble_man', 41: 'bubble_man_bubble_lead',
 42: 'flash_man', 43: 'flash_man_defeat_watcher', 44: 'heat_man', 45: 'heat_man_atomic_fire', 54: 'flash_man_freeze', 55: 'boss_door'}

LIBDEAD = [0x4048, 0x40D5, 0x43A0, 0x451A, 0x4719]
ENTRIES = [a for a, t, n in SLOTS] + list(range(0x4000, 0x4048, 3)) + LIBDEAD + \
  [0x4DED, 0x58EA, 0x5161, 0x7262, 0x7C44, 0x7CF3]

L = lambda **k: k
def FR(s, e, tables, frames=()):
    return (s, e, None, 'frames', L(tables=tables, frames=list(frames)))
DATA = [
 (0x4512, 0x451A, None, 'db', {}),
 (0x47A0, 0x47A8, None, 'db', L(width=2)),
 (0x481C, 0x4895, None, 'anim', {}),
 FR(0x4895, 0x4AE6, [0x4895, 0x48AD, 0x48BF, 0x48D1], [0x493C]),
 (0x4B82, 0x4B88, None, 'anim', {}),
 FR(0x4B88, 0x4BC0, [0x4B88]),
 (0x4D1D, 0x4D21, None, 'db', L(width=2)),
 (0x4D21, 0x4D33, None, 'raw', L(lines=['\tdb $%02X\n\tdw $%04X' % (ROM[0x4D21 + 3*i], ROM[0x4D22 + 3*i] | ROM[0x4D23 + 3*i] << 8) for i in range(6)])),
 (0x4D33, 0x4D39, None, 'anim', {}),
 FR(0x4D39, 0x4DDD, [0x4D39]),
 (0x4E77, 0x4E7B, None, 'dw', L(width=2)),
 (0x4EA2, 0x4EA6, None, 'db', {}),
 (0x4EA6, 0x4EAD, None, 'anim', {}),
 FR(0x4EAD, 0x4ED7, [0x4EAD]),
 (0x4F7F, 0x4F87, None, 'db', L(width=4)),
 (0x5013, 0x5019, None, 'anim', {}),
 FR(0x5019, 0x5099, [0x5019], [0x5085, 0x508F]),
 (0x514D, 0x5151, None, 'dw', {}),
 (0x51B9, 0x51BC, None, 'db', {}),
 (0x52B9, 0x5379, None, 'db', L(width=16)),
 (0x5379, 0x537F, None, 'anim', {}),
 FR(0x537F, 0x53BF, [0x537F]),
 (0x54CA, 0x54DA, None, 'db', L(width=4)),
 (0x5614, 0x561C, None, 'dw', L(width=2, labels={0x5618: None})),
 (0x5693, 0x5699, None, 'anim', {}),
 FR(0x5699, 0x571D, [0x5699, 0x56A5], [0x56D1]),
 (0x5791, 0x57A1, None, 'db', L(width=8)),
 (0x58A2, 0x58A8, None, 'anim', {}),
 FR(0x58A8, 0x58D4, [0x58A8]),
 (0x5A92, 0x5AA2, None, 'dw', L(width=2)),
 (0x5B1B, 0x5B2A, None, 'anim', {}),
 FR(0x5B2A, 0x5B73, [0x5B2A]),
 (0x5BF9, 0x5C05, None, 'db', {}),
 FR(0x5C12, 0x5C5A, [0x5C12]),
 (0x5FC1, 0x5FC5, None, 'db', {}),
 FR(0x6039, 0x61CB, [0x6039]),
 (0x634A, 0x6352, None, 'db', L(width=2)),
 (0x6352, 0x635A, None, 'db', {}),
 (0x635A, 0x6364, None, 'db', {}),
 (0x63EE, 0x6402, None, 'dw', L(width=2, labels={0x63FE: None})),
 FR(0x6466, 0x6512, [0x6466]),
 FR(0x6601, 0x6639, [0x6601]),
 FR(0x6901, 0x6A79, [0x6901]),
 FR(0x6C9A, 0x6CFE, [0x6C9A]),
 (0x703E, 0x7044, None, 'db', {}),
 FR(0x7044, 0x7239, [0x7044]),
 (0x7352, 0x7358, None, 'dw', {}),
 (0x7377, 0x73A7, None, 'db', L(width=2, labels={0x7387: None, 0x7397: None})),
 (0x73A7, 0x73B1, None, 'anim', {}),
 FR(0x73B1, 0x73DD, [0x73B1]),
 (0x7457, 0x745C, None, 'anim', {}),
 FR(0x745C, 0x746A, [0x745C]),
 (0x773A, 0x773E, None, 'db', {}),
 FR(0x7767, 0x793F, [0x7767]),
 FR(0x7B15, 0x7B36, [0x7B15]),
 (0x7BAD, 0x7BB5, None, 'db', L(width=2, labels={0x7BB1: None})),
 (0x7C64, 0x7C66, None, 'db', {}),
 FR(0x7C8D, 0x7CF3, [0x7C8D]),
]
# sub-labels given as None get provisional names
for _i, _it in enumerate(DATA):
    if len(_it) > 4 and 'labels' in _it[4]:
        _it[4]['labels'] = {k: (v or 'Data_09_%04X' % k) for k, v in _it[4]['labels'].items()}

NAMES = {}
COMMENTS = {}
OPER = {
 # table + computed index: add a, LOW / adc a, HIGH
 0x4784: 'LOW(@@47A0)', 0x4789: 'HIGH(@@47A0)',
 0x525D: 'LOW(@@52B9)', 0x5262: 'HIGH(@@52B9)',
 0x5ACC: 'LOW(@@5A92)', 0x5AD1: 'HIGH(@@5A92)',
 0x5F97: 'LOW(@@5FC1)', 0x5F9C: 'HIGH(@@5FC1)',
 0x6263: 'LOW(@@6352)', 0x6268: 'HIGH(@@6352)',
 0x62A2: 'LOW(@@635A)', 0x62A7: 'HIGH(@@635A)',
 0x631D: 'LOW(@@634A)', 0x6322: 'HIGH(@@634A)',
 # frame tables stored straight into OBJ_FRAMES
 0x5106: 'LOW(@@514D)', 0x5109: 'HIGH(@@514D)',
 0x5540: 'LOW(@@56A5)', 0x5543: 'HIGH(@@56A5)',
 0x58EF: 'LOW(@@5B2A)', 0x58F2: 'HIGH(@@5B2A)',
 0x5B92: 'LOW(@@5C12)', 0x5B95: 'HIGH(@@5C12)',
 0x5C87: 'LOW(@@6039)', 0x5C8A: 'HIGH(@@6039)',
 0x621E: 'LOW(@@6466)', 0x6221: 'HIGH(@@6466)',
 0x658C: 'LOW(@@6601)', 0x658F: 'HIGH(@@6601)',
 0x6656: 'LOW(@@6901)', 0x6659: 'HIGH(@@6901)',
 0x6AB2: 'LOW(@@6C9A)', 0x6AB5: 'HIGH(@@6C9A)',
 0x6D17: 'LOW(@@7044)', 0x6D1A: 'HIGH(@@7044)',
 0x7486: 'LOW(@@7767)', 0x7489: 'HIGH(@@7767)',
 0x7978: 'LOW(@@7B15)', 0x797B: 'HIGH(@@7B15)',
 0x7B56: 'LOW(@@7C8D)', 0x7B59: 'HIGH(@@7C8D)',
 # pointers to a frame's metasprite (past its 4-byte hitbox)
 0x4FD9: '@@5085 + 4', 0x4FDE: '@@508F + 4', 0x566A: '@@56D1 + 4',
 0x7303: '@@73B9 + 4', 0x7309: '@@73C2 + 4', 0x730F: '@@73CB + 4', 0x7314: '@@73D4 + 4',
 # record tables addressed from before their first field
 0x4CC1: '@@4D21 - 3', 0x4CEF: '@@4D21 + 1',
}
INLINE = {}
LOCALNAMES = {}
CHUNKS = {0x4000: ('engine/objects/entry_table_09.asm', 'Bank 9 Entry Table'),
          0x4048: ('engine/object_library.asm', 'Object Library 09')}
FILEHEAD = {}
def _fh(title, extra=''):
    return (";Mega Man: Dr. Wily's Revenge disassembly - %s\n"
            ";Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is\n"
            ";pinned to its original address. Confidence tags: [ok] verified here, [dc]\n"
            ";corroborated by Data Crystal, [?] guess.\n%s") % (title, extra)
FILEHEAD['engine/objects/entry_table_09.asm'] = _fh("bank $09's entry table")
FILEHEAD['engine/object_library.asm'] = (
 ";Mega Man: Dr. Wily's Revenge disassembly - the object library\n"
 ";\n"
 ";1794 bytes of helpers for object routines that banks $03, $09 and $0D each carry\n"
 ";a copy of, identical except for the addresses (bank $03 has it at $4042, $09 at\n"
 ";$4048, $0D at $401B). Each bank includes this file in its own pinned section with\n"
 ";OBJBANK set to its suffix, so every label here ends in {OBJBANK}: _09 for bank $09.\n"
 ";Local labels are numbered by offset from the start of the library, so they mean\n"
 ";the same in every copy. Added in step 5.2; confidence tags as elsewhere.\n")
for _a, _t, _n in sorted(SLOTS):
    _f = 'engine/objects/%s.asm' % FILES[_t]
    CHUNKS[_a] = (_f, '%s (type %d)' % (_n, _t))
    FILEHEAD[_f] = _fh('object type %d, %s' % (_t, _n))

SHARED = ('engine/object_library.asm', 0x4048, 0x474A, 'OBJBANK', '_09')

_LIB = {
 0x4048: 'ObjGetPlayerZoneX', 0x4076: 'ObjStepX', 0x4084: 'ObjMoveX', 0x409E: 'AddSubpixel',
 0x40AA: 'ObjStepY', 0x40C8: 'ObjMoveY', 0x40D5: 'ObjCheckPlayerWithinX', 0x40F8: 'ObjArcStep',
 0x410E: 'ObjCheckOutsideArena', 0x4120: 'ObjCheckArenaEdge', 0x413D: 'BossKilled',
 0x4148: 'StartVictoryCountdown', 0x4157: 'InitBoss', 0x4194: 'StoreBossPosition',
 0x41A5: 'FillBossEnergy', 0x41B9: 'GiveBossFullEnergy', 0x41C4: 'UpdateBossEnergy', 0x41D3: 'CheckBossDead',
 0x41EA: 'DropBossIn', 0x421A: 'ObjCheckOnScreenX', 0x423E: 'ObjFaceMegaMan',
 0x4251: 'HangObjectsFull', 0x4253: 'SpawnChildObject', 0x4319: 'ObjFallAndMove',
 0x4336: 'ObjSetVelocity', 0x4347: 'ObjMoveByVelocity', 0x4361: 'FindObjectsOfType',
 0x43A0: 'SwapObjectOrder', 0x4402: 'ShiftDERight6', 0x441B: 'CheckPlayerOnObject',
 0x4453: 'PushPlayer', 0x4460: 'CheckPlayerInBox', 0x4473: 'ObjSyncAndCheckOnScreen',
 0x4486: 'LineStepInit', 0x44CC: 'LineStep', 0x4512: 'ObjLibBitMasks',
 0x451A: 'ObjFallWithCollision', 0x4533: 'AnimateObjectFacing', 0x453F: 'AnimateObject',
 0x457F: 'ObjCheckOnScreen', 0x459F: 'ObjApplyGravity', 0x45BE: 'ObjMoveWithCollision',
 0x4603: 'ObjMoveCollide', 0x4610: 'ObjMoveCollideY', 0x467C: 'ObjMoveCollideX',
 0x46E8: 'ObjFaceMegaManOnScreen', 0x4700: 'ObjCountTimer', 0x4719: 'GetObjectHitbox',
 0x4740: 'ObjClearFreeze',
}
for _a, _n in _LIB.items(): NAMES[_a] = _n + '{OBJBANK}'
for _a, _t, _n in SLOTS:
    NAMES[_a] = _n + 'Routine'
for _i in range(24):
    NAMES[0x4000 + 3 * _i] = 'Entry_09_%04X' % (0x4000 + 3 * _i)

# ObjectTablePtrs: the stats table pointer, then the type table pointer
OPER.update({0x42A6: 'ObjectTablePtrs', 0x428B: 'ObjectTablePtrs + 2', 0x4290: 'ObjectTablePtrs + 3'})

C = COMMENTS
C[0x4048] = '''Compare Mega Man's X with the object's (offset $0D) widened by offset $34:
E = 4/3/2/1 for "well left", "just left", "just right", "well right" of it, and
D = 1 on the right-hand side. Not called in bank $09.	;[ok]'''
C[0x4076] = '''Add E (a speed in 1/16 pixels) to the sub-pixel counter at offset $1C; the
whole pixels that carry out go to offset $1D, for ObjMoveX.	;[ok]'''
C[0x4084] = '''Move the object's screen X (offset $0D) by offset $1D pixels: right if offset
$2F is non-zero, else left.	;[ok]'''
C[0x409E] = '''A = (E + [HL]) / 16, keeping the remainder in [HL]: a 4.4 fixed-point step.	;[ok]'''
C[0x40AA] = '''The vertical counterpart of ObjStepX: E is a signed speed (positive = up),
the sub-pixel counter is offset $1E, and offset $1F gets the signed pixel step
(negative = up).	;[ok]'''
C[0x40C8] = '''Add offset $1F to the object's Y (offset $0F).	;[ok]'''
C[0x40D5] = '''A = 1 if Mega Man has not passed the line E pixels from the object: his X is
below its X + E (D != 0) or at least its X - E (D = 0); else 0. Used by
bank $03's type 17, not by bank $09.	;[ok]'''
C[0x40F8] = '''One frame of a jump arc: X speed offset $31, Y speed offset $32 (positive =
rising), which drops by offset $33 each frame. Follow with ObjMoveX/ObjMoveY.	;[ok]'''
C[0x410E] = '''D = 1 if the object's X is outside $1C-$85 (the edges of a boss room).	;[ok]'''
C[0x4120] = '''D = 1 if the object has reached the room edge it is heading for (offset $2F
non-zero = right: X $86 and up; else X below $1C).	;[ok]'''
C[0x413D] = '''A boss's killed call: wStageState 2 (boss beaten), the bar updated, and B = 0
so the object goes.	;[ok]'''
C[0x4148] = '''wStageState 3: start the victory countdown. B = 2.	;[ok]'''
C[0x4157] = '''Set up a boss fight: hide the boss bar ($C100/$C101 zero), put the boss at
(X $80, Y $B0 - off screen), remember it at $CCFA, wStageState 1 (boss room),
lock Mega Man's controls ($D845) and face him right.	;[ok]'''
C[0x4194] = '''Keep the boss's position at $CCF2/$CCF3, where the death burst is spawned.	;[ok]'''
C[0x41A5] = '''Boss intro: show the boss bar and fill it two points a frame; once full, give
the boss $13 hit points and unlock Mega Man's controls.	;[ok]'''
C[0x41C4] = '''Boss bar = hit points x 8.	;[ok]'''
C[0x41D3] = '''Check the boss remembered at $CCFA: NZ while it has hit points; at 0, empty
the bar and set $CCF5.	;[ok]'''
C[0x41EA] = '''Boss entrance: once Mega Man is down in the room (Y $60 and up), drop the
boss from the top 3 pixels a frame until it reaches Y $65; A = 1 when it has
landed.	;[ok]'''
C[0x421A] = '''Update the object's stage X (offset $0A) from its screen X and the scroll;
B = 0 if it is off screen sideways (X $C0-$DF), else B = 1 and $CC44 set.	;[ok]'''
C[0x423E] = '''Offset $24 (facing) = 1 if Mega Man is to the right of the object, else 0.	;[ok]'''
C[0x4251] = '''Hang: 24 objects are already active.	;[ok]'''
C[0x4253] = '''Spawn an object of type [$CC07] from inside an object routine. Takes a slot
like SpawnObject and builds the record from ObjectTypeTab and ObjectStatsTab,
at the position the caller left in $CC0D/$CC0F (with $CC05-$CC08), without a
spawn list. This is how objects make other objects (projectiles, the parts of a
boss) - the route outside SpawnObject that step 4.4 inferred. Mode 0 is not
called: the record is returned in C (and $CC42/$CC43), and every caller runs
the child's own init routine on it.	;[ok]'''
C[0x4319] = '''ObjApplyGravity, then ObjMoveByVelocity.	;[ok]'''
C[0x4336] = '''Velocity (offsets $1C-$1F: X, then Y, 8.8 fixed point) from the 4 bytes at
DE.	;[ok]'''
C[0x4347] = '''Add the velocity to the position (offsets $0C-$0F: X, then Y, 8.8).	;[ok]'''
C[0x4361] = '''List every active object of type A (offset $07) at $CC00, as record
pointers, ending with $FF.	;[ok]'''
C[0x43A0] = '''Swap objects HL and DE in the active list (draw order). Carry if either is
not there. Not called in bank $09.	;[ok]'''
C[0x4402] = '''DE >>= 6.	;[ok]'''
C[0x441B] = '''Carry if Mega Man is standing on the box at DE (x1, x2, y1, relative to the
object at $FF91/$FF92): on the ground, his feet at its top, overlapping it.	;[ok]'''
C[0x4453] = '''Move Mega Man: D pixels down, E into his X push ($D831).	;[ok]'''
C[0x4460] = '''NC if Mega Man (wPlayerX, wPlayerY) is inside the box at HL (x1, x2, y1,
y2: x1 <= X < x2, y1 <= Y < y2); carry if he is outside it.	;[ok]'''
C[0x4473] = '''Update the stage X, then ObjCheckOnScreen.	;[ok]'''
C[0x4486] = '''Copies of bank $00's LineStepInit and LineStep, on the same RAM.	;[ok]'''
C[0x4512] = '''Single-bit masks. Nothing in bank $09 reads them.	;[ok]'''
C[0x451A] = '''Gravity, then ObjMoveWithCollision with the probes at DE; a blocked
direction loses its speed. Not called in bank $09.	;[ok]'''
C[0x4533] = '''AnimateObject, then add the facing (offset $24) to the frame: frame tables
list each frame twice, left and right.	;[ok]'''
C[0x453F] = '''Animate object C. DE = an animation record, the format bank $01 uses:
  dw frame table, db frames per step, db frame, frame, ..., $FF (loop)
Points OBJ_FRAMES (offset $15) at the table, counts offset $25 and steps
offset $26, and puts the frame number in OBJ_FRAME (offset $17).	;[ok]'''
C[0x457F] = '''B = 0 if the object is off screen (Y $90 and up, or X $C0-$DF), else B = 1
and $CC44 set.	;[ok]'''
C[0x459F] = '''Gravity: Y speed (offsets $1E-$1F) += $30, capped at $0350.	;[ok]'''
C[0x45BE] = '''Move by the velocity with block collision. DE = four probe offsets (x1, x2,
y1, y2) around the object. Works on a copy at $FFA6-$FFAF, moving a block at a
time and backing out of solid ones (CheckSolidPoint); returns $FFB0: bit 1 hit
something vertically, bit 0 horizontally (NZ if either).	;[ok]'''
C[0x4610] = '''The vertical half of ObjMoveCollide.	;[ok]'''
C[0x467C] = '''The horizontal half.	;[ok]'''
C[0x46E8] = '''Like ObjFaceMegaMan, but facing right whenever the object is off the left
edge (X $C0 and up).	;[ok]'''
C[0x4700] = '''A two-level counter. DE = (offset, limit 1, limit 2): count the byte at that
offset; when it passes limit 1, reset it and count the next byte, which wraps
past limit 2. Returns the second byte (Z when it wrapped to 0).	;[ok]'''
C[0x4719] = '''The object's hitbox on screen from its current frame ($CE53): C-E across,
B-D down. Not called in bank $09.	;[ok]'''
C[0x4740] = '''Clear the freeze timer (offsets $22-$23); B = 1.	;[ok]'''

# ---- step 5.2: the 24 object routines (read in this session; see
# docs/PROGRESS.md). Placement is from the stage spawn lists (step 4.3), spawners
# from the SpawnChildObject callers ($CC07 writes), which cover the whole ROM.
C[0x474A] = '''Object type 10, placed six times in Fire Man's stage. Spawn: variant = param
(offset $06) & 3 into $28, moved by FireBeamSpawnOffsets. Variants 0-2 loop a
34-step animation (6 frames a step) on their own frame table: a strip that grows
from 2 to 6 tiles (0 upward, 1 leftward, 2 rightward), flickers, shrinks and
stays empty for 11 steps. Variant 3 steps 8 px right every 6 frames for 7 steps,
then jumps back 56 px. Flags $85 (immune to shots) unless Ice Slasher is
equipped ($05). Frozen, or under Time Stopper: no animation, flags $05/$07, so
it can be hit. Killed or off screen: removed. Will's render: fire pillars and
horizontal flames.	;[ok]'''
NAMES.update({0x476F: 'FireBeamInit', 0x47A8: 'FireBeamUpdate', 0x475A: 'FireBeamFrozen',
 0x47C0: 'FireBeamSetImmunity', 0x47A0: 'FireBeamSpawnOffsets'})
C[0x47C0] = '''Flags (offset $11) = $05 if Ice Slasher is the current weapon, else $85
(immune); then ObjSyncAndCheckOnScreen.	;[ok]'''

C[0x4AE6] = '''Object type 11: placed seven times in Fire Man's stage, and thrown by type 12.
Spawn: offset $2A = param bit 0 picks the mode. Mode 0 (placed): goes to Y 0
and drops 2 px a frame to Y $B0, then starts again from the top, through walls.
Mode 1 (thrown, with the velocity type 12 gives it): falls under gravity
(ObjFallAndMove) and is removed at Y $90. Always faces Mega Man; two frames,
15 frames each. Ice Slasher holds mode 0 still; mode 1 clears the freeze and
keeps moving. Killed, or off screen sideways: removed.	;[ok]'''
NAMES.update({0x4B05: 'ChangkeyInit', 0x4B21: 'ChangkeyUpdate', 0x4AF6: 'ChangkeyFrozen',
 0x4B7C: 'ChangkeyUpdateThrown', 0x4B6F: 'ChangkeyCheckOffScreen'})

C[0x4BC0] = '''Object type 12, placed in Fire Man (nine), Wily 1 and Wily 3. Spawn: tile
base + 8, first throw after 60 frames. Faces Mega Man; when he is within 100 px
sideways it takes a throw pose (16 frames) and throws a type 11 (ChangkeyMakerThrowChangkey),
then animates 120 frames before it can throw again. Frozen (Ice Slasher or Time
Stopper): does nothing. Never removed off screen. Killed: removed.	;[ok]'''
C[0x4C6E] = '''Spawn a type 11 15 px up and 15 px (left) / 23 px (right) out, with param 1
and this object's original tile base, and run ChangkeyInit on it. Its X speed is
picked from ChangkeyMakerThrowSpeeds by Mega Man's distance (0.5 to 2.125 px/frame),
moved -1..+2 rows at random (JumpRNG); Y speed -3 px/frame.	;[ok]'''
NAMES.update({0x4C6E: 'ChangkeyMakerThrowChangkey', 0x4D1D: 'ChangkeyMakerThrowOffsets', 0x4D21: 'ChangkeyMakerThrowSpeeds'})

C[0x4DDD] = '''Drillun (type 13; Will, from its official artwork - a drill with a green cap
and eyes - and the ending's DRILLUN entry). Unused: no stage places it, no
SpawnChildObject call spawns it, and the ending's script skips its entry.	;[ok]
The code: a solid object (AddSolidBox, X-8..X+7, Y-8..Y) that falls under
gravity until the point below it is solid, then rises 1.5 px a frame to Y $20
and falls again, moving Mega Man by its Y change when he stands on it.
CheckPlayerOnObject is called with no box set up (compare type 15), so that
part cannot work as written. Modes 1 and 3 are the same. Killed: removed.	;[ok]'''
NAMES.update({0x4DEE: 'DrillunInit', 0x4E06: 'DrillunUpdate', 0x4E1A: 'DrillunMove',
 0x4E52: 'DrillunFall', 0x4E7B: 'DrillunRise', 0x4E2F: 'DrillunCarryPlayer',
 0x4E8F: 'DrillunAddSolidBox', 0x4E77: 'DrillunRiseVelocity', 0x4EA2: 'DrillunSolidBox'})

C[0x4ED7] = '''Object type 14: never placed; each type 15 spawns one, and stores its own
record pointer in this object's $2E/$2F. Rides 16 px above the parent. Counts
$2A from 50 to 100 while facing Mega Man (drawing a type 26 frame beside itself
from 25 on), then spawns a type 26 (KaminariGoroThrowerSpawnShot) and holds a throw pose for
20 frames; it throws again only after the type 26 has gone off screen and
written $A5 to its $28. Frozen: no AI. Returns B = the parent's $09 (its
on-screen flag), so it goes when the parent does. Killed: frees its extra
sprite and is removed.	;[ok]'''
NAMES.update({0x4EFE: 'KaminariGoroThrowerInit', 0x4F87: 'KaminariGoroThrowerFollowParent', 0x4FA4: 'KaminariGoroThrowerDrawShotFrame',
 0x5099: 'KaminariGoroThrowerSpawnShot', 0x4FE8: 'KaminariGoroThrowerStartThrow', 0x4F7F: 'KaminariGoroThrowerShotFrameOffsets'})

C[0x5151] = '''Object type 15, placed three times in Elec Man's stage. Spawn: tile base +$11,
circle centre at (X+4, Y), direction from Mega Man's side, and one type 14
(KaminariGoroSpawnThrower). A platform that moves round a circle of radius about 28 px
(96 steps, one per 8 frames, KaminariGoroOrbitOffsets; paused by Time Stopper) and
carries Mega Man standing on it. Refills its hit points to $64 every frame.
Modes 1 and 3 are the same (Ice Slasher does nothing). Killed or off screen:
removed.	;[ok]'''
NAMES.update({0x5175: 'KaminariGoroInit', 0x51BC: 'KaminariGoroUpdate', 0x51E0: 'KaminariGoroMoveAndCarry',
 0x524B: 'KaminariGoroSetOrbitPosition', 0x527E: 'KaminariGoroSpawnThrower', 0x52B9: 'KaminariGoroOrbitOffsets',
 0x51B9: 'KaminariGoroOrbitTimerArgs'})

C[0x53BF] = '''Object type 19, placed in Wily 1 and Wily 3. Waits off screen (X $C0, not
shootable) until no type 27 or 28 exists, 60 frames have passed and Mega Man is
in its box; then flies in at Y $18 from the side he faces away from, $0133
px/frame. Within $1C px of him it drops one type 27 (PipiTryDrop). Leaving the
screen resets it. Frozen: nothing. Killed: removed.	;[ok]'''
NAMES.update({0x53DC: 'PipiReset', 0x53EF: 'PipiUpdate', 0x546B: 'PipiWaitToEnter',
 0x54DA: 'PipiTryDrop'})

C[0x58D4] = '''Object type 24, placed seven times in Ice Man's stage and in Wily 1/3. Never
moves. Every 128 frames, while Mega Man is within about $8C px and nothing is
frozen, it spawns a type 25 above itself, skipping 1 time in 4 (JumpRNG). Its
$09 is 1 while alive; children still waiting to jump explode when it reads 0.
Ice Slasher does not stop it. Killed: removed.	;[ok]'''
NAMES.update({0x58EB: 'ScwormInit', 0x58FD: 'ScwormUpdate'})

C[0x5966] = '''Object type 25: never placed; spawned by type 24, with DE = the parent's $09.
Waits 90 frames (exploding if the parent is gone), then jumps at Mega Man (X
speed by distance plus a random part, Y speed about -3) under gravity with
block collision. A wall stops it; after landing it sits 180 frames, then
explodes (3 in 4) or jumps again. Off screen or killed: removed (no explosion
when killed).	;[ok]'''
NAMES.update({0x598C: 'ScwormSpawnInit', 0x59C3: 'ScwormSpawnUpdate', 0x5976: 'ScwormSpawnExplode',
 0x5AA2: 'ScwormSpawnSetJumpVelocity', 0x5A1C: 'ScwormSpawnAirborne', 0x5A73: 'ScwormSpawnLanded',
 0x5973: 'ScwormSpawnRemove'})

C[0x50E8] = '''Object type 26: never placed; type 14's shot (KaminariGoroThrowerSpawnShot points its
$28/$29 at the thrower's $28 and runs KaminariGoroShotInit). Moves 1.5 px a frame the way
it faces; Time Stopper holds it. Off screen: removed, writing $A5 to the
thrower's $28. Killed: removed without telling the thrower. There is no mode 0
case.	;[ok]'''
NAMES.update({0x50F8: 'KaminariGoroShotInit', 0x510D: 'KaminariGoroShotUpdate'})

C[0x551D] = '''Object type 27: never placed; dropped by type 19 (PipiEggInit). Falls under
gravity through walls until it is next to Mega Man or a point beside its base is
solid; then it bursts: it splits into two halves that fly apart in mirrored
arcs and spawns six type 28s (PipiEggSpawnCopipis). Off screen or killed: frees its
second sprite and is removed. Frozen: nothing.	;[ok]'''
NAMES.update({0x553C: 'PipiEggInit', 0x552A: 'PipiEggRemove', 0x556D: 'PipiEggFall',
 0x561C: 'PipiEggUpdateHalves', 0x571D: 'PipiEggSpawnCopipis', 0x574A: 'PipiEggSpawnCopipi'})

C[0x5753] = '''Object type 28: never placed; six at once from a type 27, with $CC08 = 0-5
picking a target offset from CopipiTargets. Moves 2 px along a line (LineStep)
on odd frames only, and can only be shot on those frames. Near its target it
re-aims at Mega Man and keeps going until off screen. Killed: removed.	;[ok]'''
NAMES.update({0x5766: 'CopipiInit', 0x57A1: 'CopipiUpdate', 0x5859: 'CopipiSetTarget',
 0x5791: 'CopipiTargets'})

C[0x5B73] = '''Object type 39: never placed; Enker's shot (EnkerSpawnShot runs EnkerShotInit
on it). $CC08 = a power tier from the damage Enker absorbed picks, from
EnkerShotTiers, its X speed (1.5 / 2 / 2.5 px/frame), $1A (2 / 4 / 8) and its
size (1, 2 or 3 tiles tall). Hit points $FE (shots bounce off). Moves straight;
removed off screen; Time Stopper holds it.	;[ok]
$1A is probably the damage it does to Mega Man; that would make this the Mirror
Buster, Enker's weapon.	;[?]'''
NAMES.update({0x5B8E: 'EnkerShotInit', 0x5C05: 'EnkerShotUpdate', 0x5BF9: 'EnkerShotTiers'})

C[0x5C5A] = '''Enker (type 38), the boss in Wily 2's fifth teleporter room. A state machine
in $27: drop in, intro (bar fills, palette flashes), then at random walk, jump
once or twice, or jump long; at a room edge, or after jumping, he absorbs: for
120 frames Mega Man's shots are pulled toward his spear and the damage they
would do is counted in $37 (sound $2B). Then he fires a type 39 whose power
tier comes from that count (EnkerSpawnShot). Ice Slasher does nothing to him.
Killed: wStageState 2 and the bar emptied.	;[ok]
Offset $19 = 0 (shots do damage) only while jumping or absorbing with the Mega
Buster equipped, so other weapons and other moments do not hurt him.	;[?]'''
NAMES.update({0x5C80: 'EnkerInit', 0x5C92: 'EnkerUpdate', 0x5CE0: 'EnkerRunState',
 0x5D43: 'EnkerFlashPalette', 0x5D95: 'EnkerChooseAction', 0x5DCA: 'EnkerWalk',
 0x5E03: 'EnkerStartAbsorb', 0x5E10: 'EnkerJump', 0x5E8D: 'EnkerPullShots',
 0x5ECC: 'EnkerAbsorb', 0x5F48: 'EnkerGetShotTier', 0x5F5A: 'EnkerFire',
 0x5FD2: 'EnkerSpawnShot', 0x5FF8: 'EnkerSetShortJump', 0x6005: 'EnkerSetLongJump',
 0x6012: 'EnkerAnimateWalk'})

C[0x61CB] = '''Object type 4, placed in Cut Man, Ice Man, Fire Man, Wily 1 and Wily 3. Faces
Mega Man and fires a horizontal enemy shot (SniperJoeFireShot) on steps 2, 4 and 6
of an 8-step cycle; on step 0 its hit points read $FE, so shots bounce off.
Param bit 0 gives a jumping version that hops toward Mega Man under gravity
with block collision. Does nothing while more than $5E px from the middle of
the screen. Removed below the screen; frozen: nothing; killed: removed.	;[ok]'''
NAMES.update({0x630C: 'SniperJoeFireShot', 0x624F: 'SniperJoeUpdateShootCycle',
 0x6408: 'SniperJoeMoveAirborne', 0x653F: 'SniperJoeInitStageX', 0x654E: 'SniperJoeSaveScreenX',
 0x6559: 'SniperJoeTrackStageX', 0x6512: 'SniperJoeCheckFar'})

C[0x6575] = '''The Atomic Fire block (type 29), placed four times in Wily 3: it takes
damage only while Atomic Fire is the current weapon. Its real hit points (4)
are kept in $28; every frame $18 is set from them when Atomic Fire is equipped,
else to $13, so other weapons' damage is undone. The frame shows the damage
taken (four stages). Killed: removed. Frozen: the freeze is cleared.	;[ok]'''
NAMES.update({0x65CD: 'AtomicFireBlockSetFrame', 0x65EC: 'AtomicFireBlockSetHP'})

C[0x6639] = '''Bubble Man (type 40), the boss behind Wily 2's second teleporter. Sinks in,
fills his bar, then repeats: on the floor he fires (writes 1 to $CCF6, up to
three times), rises toward where Mega Man was, sinks back; while level with
Mega Man he fires the other shot ($CCF6 = 2) every 32 frames. He spawns
nothing - the five type 41s placed in his room answer $CCF6. Killed: B = 0 only;
the type 41s end the fight. Ice Slasher does nothing to him.	;[ok]'''
NAMES.update({0x6800: 'BubbleManSetFrame', 0x6812: 'BubbleManSinkIn', 0x683C: 'BubbleManSwim',
 0x6862: 'BubbleManStartRise', 0x6885: 'BubbleManStepX', 0x68B2: 'BubbleManStepUp',
 0x68D0: 'BubbleManAnimateSwim'})

C[0x6A79] = '''Type 41, five placed in Bubble Man's room: his shots, parked off screen (Y
$C0) until he asks. The first idle one to see $CCF6 = 1 fires a bouncing shot
from him toward Mega Man; $CCF6 = 2 gives a straight shot, 2 px a frame. Once
CheckBossDead reports him beaten, the first one sets wStageState 2 and starts the
victory countdown - his own killed call does neither. Ice Slasher does nothing
to them.	;[ok]'''
NAMES.update({0x6BFF: 'BubbleManBubbleLeadPlaceAtBoss', 0x6C12: 'BubbleManBubbleLeadOnBossDead',
 0x6C45: 'BubbleManBubbleLeadStartVictory', 0x6C56: 'BubbleManBubbleLeadAnimateStraight',
 0x6C7F: 'BubbleManBubbleLeadAnimateBounce'})

C[0x6CFE] = '''Flash Man (type 42), the boss behind Wily 2's third teleporter. Drops in,
poses while his bar fills, then walks toward Mega Man 1 px a frame, jumping at
him at a room edge or after losing hit points. When his attack timer ($2D)
wraps he poses, spawns a type 54 (FlashManSpawnFreeze), then fires six enemy
shots 10 frames apart (FlashManFireShot). Holds still while wFreezeFlags bits
0-3 are set; bit 4, which his own type 54 sets, does not stop him. Killed: B =
0 only; the type 43 in his room ends the fight.	;[ok]'''
NAMES.update({0x6F83: 'FlashManFireShot', 0x6FB4: 'FlashManSetPoseFrame',
 0x6FCD: 'FlashManTickAttackTimer', 0x6FD4: 'FlashManStartJump', 0x6FF5: 'FlashManStartWalk',
 0x7012: 'FlashManAnimateWalk', 0x703E: 'FlashManShotDirections'})

C[0x7239] = '''Type 54: never placed; spawned by Flash Man (FlashManSpawnFreeze). For 90
frames it sets wFreezeFlags bit 4, which stops Mega Man (StopPlayer) - cleared
while he is being hurt - and draws eight one-tile sprites at fixed screen
positions, cycling three layouts. Then, or when killed, it frees them, clears
bit 4 and is removed.	;[ok]
Flash Man freezing Mega Man is his Time Stopper.	;[?]'''
NAMES.update({0x7246: 'FlashManFreezeRemove', 0x7264: 'FlashManFreezeInit',
 0x728A: 'FlashManFreezeUpdate', 0x7358: 'FlashManSpawnFreeze', 0x7352: 'FlashManFreezeLayouts'})

C[0x73DD] = '''Type 43, placed beside Flash Man: parked off screen (Y $C0) with no movement
or attack. Once CheckBossDead reports the boss beaten it sets wStageState 2 and
calls StartVictoryCountdown every 32 frames - Flash Man's own killed call does
neither. A reduced copy of type 41's end-of-fight code.	;[ok]'''

C[0x746A] = '''Heat Man (type 44), the boss behind Wily 2's fourth teleporter. Drops in and
fills his bar, then stands; every 128 frames he writes 3 to $CCF6, which sends
the three type 45s in his room at Mega Man. Hit, he takes no further damage
(hit points $FE) for a random wait (HeatManSlideDelays), then slides 4 px a
frame to where Mega Man was, re-forms and stands again. Holds still while
anything is frozen. Killed: B = 0 only; the type 45s end the fight.	;[ok]'''
NAMES.update({0x773E: 'HeatManSetFrame', 0x7750: 'HeatManSetSlideFrame', 0x773A: 'HeatManSlideDelays'})

C[0x793F] = '''Type 45, three placed in Heat Man's room: his fireballs, parked off screen (Y
$C0). When he writes a count to $CCF6, each takes one (its spread) and jumps
from him toward Mega Man under gravity, sits on the floor 50 frames, and parks
again. Once he is beaten the first one sets wStageState 2 and starts the
victory countdown. Immune to shots (flags $85).	;[ok]'''
NAMES.update({0x7A96: 'HeatManAtomicFireMoveToBoss', 0x7AA7: 'HeatManAtomicFireBossBeaten',
 0x7ADA: 'HeatManAtomicFireStartVictory', 0x7AEB: 'HeatManAtomicFireAddSpread',
 0x7AFC: 'HeatManAtomicFireAnimate'})

C[0x7B36] = '''The boss door (type 55), placed once in each robot-master stage. A state
machine in $09, one frame step every 7 frames with sound $0D: grows in (state
5), waits for Mega Man at screen X $58-$67 (0), shrinks to nothing (1), waits
for him at X $28-$37 (2), grows back (3) and stays (4). Never removed off
screen. Killed: removed.	;[ok]'''
NAMES.update({0x7BA6: 'BossDoorKeep', 0x7BB5: 'BossDoorShrink', 0x7BDB: 'BossDoorWaitPassed',
 0x7BF5: 'BossDoorRegrow', 0x7C1E: 'BossDoorGrowIn'})
C[0x7C44] = '''Unused: nothing calls it. Writes background tiles $78/$79 down 8 rows at the
door's position (BossDoorGetBGAddress) - perhaps an earlier way of drawing
the door into the background.	;[ok]'''
C[0x7CF3] = '''Unused: nothing calls it. The same code as bank $0D's GetDirectionToPoint:
A = the direction of point (C, B) from (E, D), 0-7 clockwise from up
(0 up, 2 right, 4 down, 6 left); within $18 px counts as level on that axis.	;[ok]'''

# ---- names from Will after step 5.2, checked against the ending's roll call
# (bank $0E, ASCII - $20, at $50A4-$51CC; not yet source).
_WILL = {
 0x61CB: "Sniper Joe (Will; the ending lists SNIPER JOE).",
 0x474A: "Fire beams, which come in several directions (Will). Not in the ending's list.",
 0x4AE6: "Changkey (Will; the ending lists CHANGKEY).",
 0x4BC0: "Changkey Maker (Will; the ending lists CHANGKEY MAKER).",
 0x5151: "Kaminari Goro, also called Lightning Lord (Will; the ending lists KAMINARI\nGORO). In the code the platform (this type) and the figure on it\n(type 14, KaminariGoroThrower) are separate objects.",
 0x4ED7: "The part of Kaminari Goro that rides type 15 and throws (named from the code).",
 0x50E8: "Kaminari Goro's shot (named from the code).",
 0x53BF: "Pipi (Will; the ending lists PIPI, which is the spelling used here).",
 0x551D: "Pipi's egg (Will: Pipi drops eggs with Copipi inside).",
 0x5753: "Copipi, the chicks in Pipi's egg (Will). Not in the ending's list; spelled to\nmatch PIPI.",
 0x58D4: "Scworm (Will; the ending lists SCWORM).",
 0x5966: "What Scworm spawns (named from the code).",
}
for _a, _t in _WILL.items():
    C[_a] = _t + '\t;[ok]\n' + C[_a]
# step 5.3: the library label bank $03 needs (comment as in objlib.py)
C[0x41B9] = '''The bar is full: give the boss $13 hit points and unlock Mega Man's controls
($D845 = 0). Bank $03 calls this part directly.	;[ok]'''

# Step 7.3c: the 46 labels left provisional by step 5.2, named.
NAMES.update({
 0x47D3: 'FireBeamAnimateUp',
 0x47DB: 'FireBeamAnimateLeft',
 0x47E3: 'FireBeamAnimateRight',
 0x47EB: 'FireBeamStepRight',
 0x4AF3: 'ChangkeyRemove',
 0x4B02: 'ChangkeyHold',
 0x4B66: 'ChangkeyAnimateThrown',
 0x4DED: 'Unused_09_4DED',
 0x4F1C: 'KaminariGoroThrowerUpdate',
 0x4F22: 'KaminariGoroThrowerStep',
 0x4F51: 'KaminariGoroThrowerAnimate',
 0x4F57: 'KaminariGoroThrowerShowShot',
 0x4F6B: 'KaminariGoroThrowerCheckParent',
 0x4FF8: 'KaminariGoroThrowerHoldThrow',
 0x50F2: 'KaminariGoroShotRemove',
 0x50F5: 'KaminariGoroShotClearFreeze',
 0x512C: 'KaminariGoroShotCheckOnScreen',
 0x5161: 'KaminariGoroScrollUnused',
 0x553B: 'PipiEggFrozen',
 0x555A: 'PipiEggUpdate',
 0x5565: 'PipiEggCheckOnScreen',
 0x5675: 'PipiEggMoveHalves',
 0x58EA: 'Unused_09_58EA',
 0x5989: 'ScwormSpawnFrozen',
 0x59FD: 'ScwormSpawnAnimate',
 0x5A09: 'ScwormSpawnCheckOnScreen',
 0x5AF9: 'ScwormSpawnMoveLanded',
 0x5C7D: 'EnkerClearFreeze',
 0x5D6A: 'EnkerIntroPose',
 0x5D70: 'EnkerIntroWait',
 0x5D73: 'EnkerIntroStopFlash',
 0x5D80: 'EnkerIntroEnd',
 0x5FC5: 'EnkerGetSide',
 0x62D0: 'SniperJoeEndFrame',
 0x62D7: 'SniperJoeEndFrameFar',
 0x62D9: 'SniperJoeSetFlags',
 0x6364: 'SniperJoeUpdateJumper',
 0x6402: 'SniperJoeJumpChosen',
 0x6405: 'SniperJoeAirborneDone',
 0x68FE: 'BubbleManClearFreeze',
 0x703B: 'FlashManClearFreeze',
 0x7262: 'Unused_09_7262',
 0x7C1B: 'BossDoorStay',
 0x7C44: 'BossDoorDrawBGUnused',
 0x7C66: 'BossDoorGetBGAddress',
 0x7CF3: 'GetDirectionToPoint_09',
})
