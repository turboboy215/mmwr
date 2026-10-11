#The object library's config for tools/bankgen.py, by offset from its start
#(step 5.3): taken from tools/bankgen/bank09.py, where it was worked out in step
#5.2. A bank config calls lib(base) to get its names, comments, operand
#overrides, dead entry points and data items at that bank's addresses.
HEAD = ";Mega Man: Dr. Wily's Revenge disassembly - the object library\n;\n;1794 bytes of helpers for object routines that banks $03, $09 and $0D each carry\n;a copy of, identical except for the addresses (bank $03 has it at $4042, $09 at\n;$4048, $0D at $401B). Each bank includes this file in its own pinned section with\n;OBJBANK set to its suffix, so every label here ends in {OBJBANK}: _09 for bank $09.\n;Local labels are numbered by offset from the start of the library, so they mean\n;the same in every copy. Added in step 5.2; confidence tags as elsewhere.\n"
LEN = 0x702
NAMES = {0x171: 'GiveBossFullEnergy',
 0: 'ObjGetPlayerZoneX',
 46: 'ObjStepX',
 60: 'ObjMoveX',
 86: 'AddSubpixel',
 98: 'ObjStepY',
 128: 'ObjMoveY',
 141: 'ObjCheckPlayerWithinX',
 176: 'ObjArcStep',
 198: 'ObjCheckOutsideArena',
 216: 'ObjCheckArenaEdge',
 245: 'BossKilled',
 256: 'StartVictoryCountdown',
 271: 'InitBoss',
 332: 'StoreBossPosition',
 349: 'FillBossEnergy',
 380: 'UpdateBossEnergy',
 395: 'CheckBossDead',
 418: 'DropBossIn',
 466: 'ObjCheckOnScreenX',
 502: 'ObjFaceMegaMan',
 521: 'HangObjectsFull',
 523: 'SpawnChildObject',
 721: 'ObjFallAndMove',
 750: 'ObjSetVelocity',
 767: 'ObjMoveByVelocity',
 793: 'FindObjectsOfType',
 856: 'SwapObjectOrder',
 954: 'ShiftDERight6',
 979: 'CheckPlayerOnObject',
 1035: 'PushPlayer',
 1048: 'CheckPlayerInBox',
 1067: 'ObjSyncAndCheckOnScreen',
 1086: 'LineStepInit',
 1156: 'LineStep',
 1226: 'ObjLibBitMasks',
 1234: 'ObjFallWithCollision',
 1259: 'AnimateObjectFacing',
 1271: 'AnimateObject',
 1335: 'ObjCheckOnScreen',
 1367: 'ObjApplyGravity',
 1398: 'ObjMoveWithCollision',
 1467: 'ObjMoveCollide',
 1480: 'ObjMoveCollideY',
 1588: 'ObjMoveCollideX',
 1696: 'ObjFaceMegaManOnScreen',
 1720: 'ObjCountTimer',
 1745: 'GetObjectHitbox',
 1784: 'ObjClearFreeze'}
COMMENTS = {0x171: '''The bar is full: give the boss $13 hit points and unlock Mega Man\'s controls
($D845 = 0). Bank $03 calls this part directly.	;[ok]''',
 0: "Compare Mega Man's X with the object's (offset $0D) widened by offset $34:\n"
    'E = 4/3/2/1 for "well left", "just left", "just right", "well right" of it, and\n'
    'D = 1 on the right-hand side. Not called in bank $09.\t;[ok]',
 46: 'Add E (a speed in 1/16 pixels) to the sub-pixel counter at offset $1C; the\n'
     'whole pixels that carry out go to offset $1D, for ObjMoveX.\t;[ok]',
 60: "Move the object's screen X (offset $0D) by offset $1D pixels: right if offset\n"
     '$2F is non-zero, else left.\t;[ok]',
 86: 'A = (E + [HL]) / 16, keeping the remainder in [HL]: a 4.4 fixed-point step.\t;[ok]',
 98: 'The vertical counterpart of ObjStepX: E is a signed speed (positive = up),\n'
     'the sub-pixel counter is offset $1E, and offset $1F gets the signed pixel step\n'
     '(negative = up).\t;[ok]',
 128: "Add offset $1F to the object's Y (offset $0F).\t;[ok]",
 141: "A = 1 if Mega Man has not passed the line E pixels from the object: his X is\nbelow its X + E (D != 0) or at least its X - E (D = 0); else 0. Used by\nbank $03's type 17, not by bank $09.\t;[ok]",
 176: 'One frame of a jump arc: X speed offset $31, Y speed offset $32 (positive =\n'
      'rising), which drops by offset $33 each frame. Follow with ObjMoveX/ObjMoveY.\t;[ok]',
 198: "D = 1 if the object's X is outside $1C-$85 (the edges of a boss room).\t;[ok]",
 216: 'D = 1 if the object has reached the room edge it is heading for (offset $2F\n'
      'non-zero = right: X $86 and up; else X below $1C).\t;[ok]',
 245: "A boss's killed call: wStageState 2 (boss beaten), the bar updated, and B = 0\n"
      'so the object goes.\t;[ok]',
 256: 'wStageState 3: start the victory countdown. B = 2.\t;[ok]',
 271: 'Set up a boss fight: hide the boss bar ($C100/$C101 zero), put the boss at\n'
      '(X $80, Y $B0 - off screen), remember it at $CCFA, wStageState 1 (boss room),\n'
      "lock Mega Man's controls ($D845) and face him right.\t;[ok]",
 332: "Keep the boss's position at $CCF2/$CCF3, where the death burst is spawned.\t;[ok]",
 349: 'Boss intro: show the boss bar and fill it two points a frame; once full, give\n'
      "the boss $13 hit points and unlock Mega Man's controls.\t;[ok]",
 380: 'Boss bar = hit points x 8.\t;[ok]',
 395: 'Check the boss remembered at $CCFA: NZ while it has hit points; at 0, empty\n'
      'the bar and set $CCF5.\t;[ok]',
 418: 'Boss entrance: once Mega Man is down in the room (Y $60 and up), drop the\n'
      'boss from the top 3 pixels a frame until it reaches Y $65; A = 1 when it has\n'
      'landed.\t;[ok]',
 466: "Update the object's stage X (offset $0A) from its screen X and the scroll;\n"
      'B = 0 if it is off screen sideways (X $C0-$DF), else B = 1 and $CC44 set.\t;[ok]',
 502: 'Offset $24 (facing) = 1 if Mega Man is to the right of the object, else 0.\t;[ok]',
 521: 'Hang: 24 objects are already active.\t;[ok]',
 523: 'Spawn an object of type [$CC07] from inside an object routine. Takes a slot\n'
      'like SpawnObject and builds the record from ObjectTypeTab and ObjectStatsTab,\n'
      'at the position the caller left in $CC0D/$CC0F (with $CC05-$CC08), without a\n'
      'spawn list. This is how objects make other objects (projectiles, the parts of a\n'
      'boss) - the route outside SpawnObject that step 4.4 inferred. Mode 0 is not\n'
      'called: the record is returned in C (and $CC42/$CC43), and every caller runs\n'
      "the child's own init routine on it.\t;[ok]",
 721: 'ObjApplyGravity, then ObjMoveByVelocity.\t;[ok]',
 750: 'Velocity (offsets $1C-$1F: X, then Y, 8.8 fixed point) from the 4 bytes at\nDE.\t;[ok]',
 767: 'Add the velocity to the position (offsets $0C-$0F: X, then Y, 8.8).\t;[ok]',
 793: 'List every active object of type A (offset $07) at $CC00, as record\n'
      'pointers, ending with $FF.\t;[ok]',
 856: 'Swap objects HL and DE in the active list (draw order). Carry if either is\n'
      'not there. Not called in bank $09.\t;[ok]',
 954: 'DE >>= 6.\t;[ok]',
 979: 'Carry if Mega Man is standing on the box at DE (x1, x2, y1, relative to the\n'
      'object at $FF91/$FF92): on the ground, his feet at its top, overlapping it.\t;[ok]',
 1035: 'Move Mega Man: D pixels down, E into his X push ($D831).\t;[ok]',
 1048: 'NC if Mega Man (wPlayerX, wPlayerY) is inside the box at HL (x1, x2, y1,\n'
       'y2: x1 <= X < x2, y1 <= Y < y2); carry if he is outside it.\t;[ok]',
 1067: 'Update the stage X, then ObjCheckOnScreen.\t;[ok]',
 1086: "Copies of bank $00's LineStepInit and LineStep, on the same RAM.\t;[ok]",
 1226: 'Single-bit masks. Nothing in bank $09 reads them.\t;[ok]',
 1234: 'Gravity, then ObjMoveWithCollision with the probes at DE; a blocked\n'
       'direction loses its speed. Not called in bank $09.\t;[ok]',
 1259: 'AnimateObject, then add the facing (offset $24) to the frame: frame tables\n'
       'list each frame twice, left and right.\t;[ok]',
 1271: 'Animate object C. DE = an animation record, the format bank $01 uses:\n'
       '  dw frame table, db frames per step, db frame, frame, ..., $FF (loop)\n'
       'Points OBJ_FRAMES (offset $15) at the table, counts offset $25 and steps\n'
       'offset $26, and puts the frame number in OBJ_FRAME (offset $17).\t;[ok]',
 1335: 'B = 0 if the object is off screen (Y $90 and up, or X $C0-$DF), else B = 1\n'
       'and $CC44 set.\t;[ok]',
 1367: 'Gravity: Y speed (offsets $1E-$1F) += $30, capped at $0350.\t;[ok]',
 1398: 'Move by the velocity with block collision. DE = four probe offsets (x1, x2,\n'
       'y1, y2) around the object. Works on a copy at $FFA6-$FFAF, moving a block at a\n'
       'time and backing out of solid ones (CheckSolidPoint); returns $FFB0: bit 1 hit\n'
       'something vertically, bit 0 horizontally (NZ if either).\t;[ok]',
 1480: 'The vertical half of ObjMoveCollide.\t;[ok]',
 1588: 'The horizontal half.\t;[ok]',
 1696: 'Like ObjFaceMegaMan, but facing right whenever the object is off the left\n'
       'edge (X $C0 and up).\t;[ok]',
 1720: 'A two-level counter. DE = (offset, limit 1, limit 2): count the byte at that\n'
       'offset; when it passes limit 1, reset it and count the next byte, which wraps\n'
       'past limit 2. Returns the second byte (Z when it wrapped to 0).\t;[ok]',
 1745: "The object's hitbox on screen from its current frame ($CE53): C-E across,\n"
       'B-D down. Not called in bank $09.\t;[ok]',
 1784: 'Clear the freeze timer (offsets $22-$23); B = 1.\t;[ok]'}
OPER = {579: 'ObjectTablePtrs + 2', 584: 'ObjectTablePtrs + 3', 606: 'ObjectTablePtrs'}
DEAD = [0, 141, 856, 1234, 1745]
DATA = [(1226, 1234, None, 'db', [{}])]

def lib(base):
    """(names, comments, oper, dead, data) at a bank's addresses."""
    return ({base + k: v + '{OBJBANK}' for k, v in NAMES.items()},
            {base + k: v for k, v in COMMENTS.items()},
            {base + k: v for k, v in OPER.items()},
            [base + k for k in DEAD],
            [(base + s, base + e, n, k) + tuple(x) for s, e, n, k, x in DATA])
