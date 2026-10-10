#Config for tools/bankgen.py: ROM bank $03 (step 5.3). See the note in
#tools/bankgen.py: this bootstrapped the bank, and the .asm files it wrote are
#now the source of truth.
import sys as _sys
_sys.path.insert(0, 'tools/bankgen')
from objlib import lib as _lib
BANK = 3
END = 0x7BE5
LIB = 0x4042
_ln, _lc, _lo, _ld, _ldata = _lib(LIB)

HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $03
;
;One of the three object banks ($03, $09, $0D): code for 22 object types,
;reached only through ObjectTypeTab. 100% source since step 5.3. The bank is:
;
;  $4000-$4041  the entry table: one `jp` per object type, in ObjectTypeTab
;               order
;  $4042-$4743  the object library, engine/object_library.asm (shared with
;               banks $09 and $0D; its labels end in {OBJBANK}, _03 here)
;  $4744-$7BE4  the 22 objects' routines and data, one file per type in
;               engine/objects/, in ROM order: the four robot masters of the
;               first half (Cut Man, Ice Man, Elec Man, Fire Man) with their
;               shots, and the enemies and stage objects of their stages
;  $7BE5-$7FFF  unused, all $FF
;
;Object modes are as in bank $09: B = 0 spawn, 1 frame, 2 killed, 3 frozen by
;Ice Slasher; B = 0 on return removes the object. The robot masters do not end
;their own fights: the shot objects placed beside them do (types 31, 33, 37).
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$7BE5-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 3 Free Space", ROMX[$7BE5], BANK[$3]
	ds $8000 - $7BE5, $FF
'''
SLOTS = [(0x4000 + 3*i, ROM[0x4001+3*i] | ROM[0x4002+3*i] << 8) for i in range(22)]
ENTRIES = [t for _, t in SLOTS] + [a for a, _ in SLOTS] + _ld + [a for a in _ln if a not in [x[0] for x in _ldata]]
DATA = list(_ldata)
NAMES = dict(_ln)
COMMENTS = dict(_lc)
OPER = dict(_lo)
# slot address -> (type, name, file)
OBJS = {
 0x4744: (30, 'CutMan', 'cut_man'), 0x4D5B: (32, 'IceMan', 'ice_man'),
 0x512C: (33, 'IceManIceSlasher', 'ice_man_ice_slasher'),
 0x52CD: (31, 'CutManRollingCutter', 'cut_man_rolling_cutter'),
 0x55DB: (1, 'CuttingWheel', 'cutting_wheel'), 0x57CF: (5, 'SuperCutter', 'super_cutter'), 0x5982: (2, 'ScrewDriver', 'screw_driver'),
 0x5B5F: (3, 'Gabyoall', 'gabyoall'), 0x5CAC: (6, 'Bigeye', 'bigeye'), 0x5E79: (34, 'ElecMan', 'elec_man'),
 0x62CC: (35, 'ElecManShot', 'elec_man_shot'), 0x6537: (36, 'FireMan', 'fire_man'),
 0x69A3: (37, 'FireManFireStorm', 'fire_man_fire_storm'), 0x6B49: (7, 'BunbyHeli', 'bunby_heli'),
 0x6D19: (9, 'Fan', 'fan'), 0x6DE7: (16, 'IcePlatform', 'ice_platform'),
 0x6ED9: (20, 'AppearingBlock', 'appearing_block'), 0x72E1: (21, 'Suzy', 'suzy'),
 0x7491: (22, 'ElectricBeam', 'electric_beam'), 0x757B: (23, 'Icicle', 'icicle'),
 0x769F: (17, 'Metall', 'metall'), 0x796B: (18, 'Mole', 'mole'),
}
CHUNKS = {0x4000: ('engine/objects/entry_table_03.asm', 'Bank 3 Entry Table'),
          LIB: ('engine/object_library.asm', 'Object Library 03')}
def _fh(title):
    return (";Mega Man: Dr. Wily's Revenge disassembly - %s\n"
            ";Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is\n"
            ";pinned to its original address. Confidence tags: [ok] verified here, [dc]\n"
            ";corroborated by Data Crystal, [?] guess.\n") % title
FILEHEAD = {'engine/objects/entry_table_03.asm': _fh("bank $03's entry table")}
for _a, (_t, _n, _f) in OBJS.items():
    CHUNKS[_a] = ('engine/objects/%s.asm' % _f, '%s (type %d)' % (_n, _t))
    FILEHEAD['engine/objects/%s.asm' % _f] = _fh('object type %d, %s' % (_t, _n))
    NAMES[_a] = _n + 'Routine'
for _a, _t in SLOTS:
    NAMES[_a] = 'Entry_03_%04X' % _a
from objlib import HEAD as _lh
FILEHEAD['engine/object_library.asm'] = _lh
SHARED = ('engine/object_library.asm', LIB, LIB + 0x702, 'OBJBANK', '_03')

L = lambda **k: k
def _sched(s, e):
    # the appearing-block schedules: (dw frame, db $B4, column, row, 0) records,
    # each list ended by a frame count and $FF
    out = []; p = s; first = True
    while p < e:
        if not first: out.append('Data_03_%04X:\t;$%04X' % (p, p))
        first = False
        while ROM[p + 2] != 0xFF:
            assert ROM[p + 2] == 0xB4 and ROM[p + 5] == 0, hex(p)
            out.append('\tdw $%04X\n\tdb $B4, $%02X, $%02X, $00' % (ROM[p] | ROM[p+1] << 8, ROM[p+3], ROM[p+4]))
            p += 6
        out.append('\tdw $%04X\n\tdb $FF' % (ROM[p] | ROM[p+1] << 8)); p += 3
    assert p == e
    return out
def FR(s, e, tables, frames=()):
    return (s, e, None, 'frames', L(tables=tables, frames=list(frames)))
DATA += [
 (0x4AB8, 0x4AC0, None, 'db', {}),
 FR(0x4AC0, 0x4D5B, [0x4AC0]),
 FR(0x5026, 0x512C, [0x5026]),
 (0x528F, 0x5295, None, 'anim', {}),
 FR(0x5295, 0x52CD, [0x5295]),
 (0x559B, 0x55A3, None, 'anim', {}),
 FR(0x55A3, 0x55DB, [0x55A3]),
 (0x5615, 0x561B, None, 'db', {}),
 (0x5791, 0x5797, None, 'anim', {}),
 FR(0x5797, 0x57CF, [0x5797]),
 (0x5821, 0x5824, None, 'db', {}),
 (0x5904, 0x5926, None, 'db', L(width=2)),
 (0x5926, 0x592E, None, 'anim', {}),
 FR(0x592E, 0x5982, [0x592E]),
 FR(0x5ACF, 0x5B5F, [0x5ACF]),
 (0x5C8C, 0x5C94, None, 'db', L(width=2)),
 FR(0x5C94, 0x5CAC, [0x5C94]),
 (0x5D82, 0x5D8A, None, 'db', L(width=2)),
 FR(0x5DF9, 0x5E79, [0x5DF9]),
 (0x60A5, 0x60A9, None, 'db', {}),
 FR(0x60A9, 0x61D8, [0x60A9]),
 (0x6213, 0x621B, None, 'db', L(width=4, labels={0x6217: None})),
 (0x6346, 0x6348, None, 'dw', {}),
 (0x6348, 0x634C, None, 'db', {}),
 (0x634C, 0x6354, None, 'db', L(width=4, labels={0x6350: None})),
 (0x6440, 0x64C4, None, 'db', L(width=3, labels={0x6482: None})),
 FR(0x6507, 0x6537, [0x6507]),
 FR(0x67C4, 0x69A3, [0x67C4]),
 (0x6ACA, 0x6AD1, None, 'anim', {}),
 FR(0x6AD1, 0x6B49, [0x6AD1]),
 (0x6B98, 0x6B9C, None, 'db', {}),
 (0x6CD3, 0x6CD9, None, 'anim', {}),
 FR(0x6CD9, 0x6D19, [0x6CD9]),
 (0x6DA9, 0x6DAF, None, 'anim', {}),
 FR(0x6DAF, 0x6DE7, [0x6DAF]),
 FR(0x6EA3, 0x6ED9, [0x6EA3]),
 (0x714C, 0x715C, None, 'dw', L(width=4)),
 (0x715C, 0x72A9, None, 'raw', L(lines=_sched(0x715C, 0x72A9), labels={a: 'Data_03_%04X' % a for a in (0x7177, 0x7192, 0x71A1, 0x71BC, 0x71D1, 0x7246)})),
 FR(0x72A9, 0x72E1, [0x72A9]),
 FR(0x7465, 0x7491, [0x7465]),
 (0x7512, 0x7518, None, 'anim', {}),
 FR(0x7518, 0x757B, [0x7518]),
 (0x7656, 0x765F, None, 'anim', {}),
 FR(0x765F, 0x769F, [0x765F]),
 (0x78A7, 0x78AD, None, 'anim', {}),
 FR(0x78AD, 0x796B, [0x78AD]),
 (0x7A7E, 0x7A86, None, 'db', L(width=4)),
 (0x7B82, 0x7B90, None, 'db', L(width=4)),
 (0x7B90, 0x7B97, None, 'anim', {}),
 FR(0x7B97, 0x7BE5, [0x7B97]),
]
ENTRIES += [0x5FD8, 0x6074, 0x6DF7, 0x6F00, 0x758B]
for _it in DATA:
    if len(_it) > 4 and 'labels' in _it[4]:
        _it[4]['labels'] = {k: (v or 'Data_03_%04X' % k) for k, v in _it[4]['labels'].items()}
FRAMEPFX = '03_'
OPER.update({0x70AD: '@@72BD + 4', 0x70B4: '@@72C9 + 4', 0x70BB: '@@72D5 + 4', 0x70C2: '@@72B1 + 4'})

# ---- step 5.3: the 22 object routines (read this session). Placement is from
# the stage spawn lists; an object's "param" (+06) is the low nibble of its
# spawn record's Y byte, and +08 is the record's extra byte.
C = COMMENTS
OPER.update({
 0x55F6: 'LOW(@@5615)', 0x55FB: 'HIGH(@@5615)', 0x58E3: 'LOW(@@5904)', 0x58E8: 'HIGH(@@5904)',
 0x5C27: 'LOW(@@5C8C)', 0x5C2C: 'HIGH(@@5C8C)', 0x5D19: 'LOW(@@5D82)', 0x5D1E: 'HIGH(@@5D82)',
 0x6B63: 'LOW(@@6B98)', 0x6B68: 'HIGH(@@6B98)',
 0x7AAD: 'LOW(ObjLibBitMasks_03)', 0x7AB2: 'HIGH(ObjLibBitMasks_03)',
 0x5DA1: '@@5E39 + 2',
})

C[0x4744] = '''Cut Man (type 30), the boss of his stage. State $27: 0 drop in; 1 fill the bar
(120 frames); 2 walk 1 px a frame, turning toward Mega Man only at a room edge,
and jump when he is within $20 px; 3 jump arc (random X speed), landing at Y
$65; 4 throw: face Mega Man and at frame 30 set $CCF6 = 1, which sends the
type 31 placed beside him; 5 stand until frame 120, then walk or jump. He
throws when his timer ($2D: 60 at landing, then 30-240 frames at random) runs
out on the ground with the cutter home; frames with the cutter on his head are
used while $CCF6 is 0. Killed: B = 0 only - type 31 ends the fight. Ice Slasher
does nothing to him.	;[ok]'''
NAMES.update({0x47C4: 'CutManCheckJumpTimer', 0x47CB: 'CutManDropIn', 0x47EE: 'CutManIntro',
 0x482A: 'CutManWalk', 0x487D: 'CutManJump', 0x48FD: 'CutManThrow', 0x495F: 'CutManWaitAfterThrow',
 0x49A7: 'CutManCheckThrowTimer', 0x49D6: 'CutManResetThrowTimer', 0x49E3: 'CutManStartJump',
 0x4A05: 'CutManStartWalk', 0x4A1E: 'CutManRandomDelay', 0x4AB8: 'CutManThrowDelays',
 0x4A2C: 'CutManAnimateWalk', 0x4A61: 'CutManSetJumpFrame', 0x4A81: 'CutManAnimateStand'})

C[0x52CD] = '''Type 31, placed once beside Cut Man: his Rolling Cutter, parked off screen
until he sets $CCF6. Then it appears at him ($CCF2/$CCF3, 8 px toward Mega Man;
sound $0E), flies straight sideways about 1.5 px a frame to the room edge
(sound $14), and homes back on Cut Man; within 8 px of him it clears $CCF6
(the cutter is home) and parks. Spins through frames 0-3 every 6 frames. Every
frame it runs CheckBossDead; once he is beaten it parks, sets wStageState 2 and
calls StartVictoryCountdown every frame (B = 2). Stops while anything is
frozen.	;[ok]'''
NAMES.update({0x54E8: 'CutManRollingCutterMoveLeft', 0x54F0: 'CutManRollingCutterMoveRight',
 0x54F8: 'CutManRollingCutterMoveUp', 0x5500: 'CutManRollingCutterMoveDown', 0x550C: 'CutManRollingCutterHomeDirection',
 0x5556: 'CutManRollingCutterCompareY', 0x5574: 'CutManRollingCutterCheckEdge', 0x5586: 'CutManRollingCutterSpin',
 0x559B: 'CutManRollingCutterAnim'})

C[0x4D5B] = '''Ice Man (type 32), the boss of his stage. State $27: 0 drop in; 1 intro poses
while the bar fills; 2 attack: shoot, rise 25 px, shoot, sink to Y $65, twice -
four shots, each a write of $CCF6 = 1 (sound $1B) answered by one of the three
type 33s; 3 walk 1 px a frame for 30 frames in direction $2E; 4 slide to a
stop, reverse $2E and attack again. So he paces back and forth whatever Mega
Man does. Killed: B = 0 only (the type 33s end the fight). Frozen: nothing
moves.	;[ok]'''
NAMES.update({0x4F91: 'IceManSlideStep', 0x4FB2: 'IceManFaceMegaMan', 0x4FD8: 'IceManSetWalkFrame',
 0x4FEF: 'IceManStartAttack', 0x5001: 'IceManStartWalk', 0x5018: 'IceManClearFreeze'})

C[0x512C] = '''Type 33, three placed beside Ice Man: his Ice Slashers, parked below the
screen (Y $C0). The first parked one to see $CCF6 clears it, moves to him
(Y-2), faces Mega Man and flies straight 1 px a frame until it leaves the
screen, then parks again. Every frame it runs CheckBossDead; once he is beaten
the first one sets wStageState 2 ($CCF7) and starts the victory countdown once
($CCF8), returning B = 2. Stops while anything is frozen.	;[ok]'''
NAMES.update({0x523E: 'IceManIceSlasherCheckOffScreen', 0x524B: 'IceManIceSlasherBossBeaten',
 0x527E: 'IceManIceSlasherVictory', 0x528F: 'IceManIceSlasherAnim'})

C[0x5E79] = '''Elec Man (type 34), the boss of his stage. State $27: 0 drop in; 1 intro poses
while the bar fills; 2 run 1 px a frame to the next of X $76, $50, $2A, $50
(ElecManTargetX, in turn); 3 face Mega Man and fire a type 35 (sound $1D,
ElecManFireShot), then run on. While running, if Mega Man is in his shooting
pose (wShootTimer) and timer $33 is out, he jumps at him. He never writes
$CCF6: the type 37 placed in his room does nothing but end the fight. Killed:
B = 0 only. Ice Slasher does nothing to him.	;[ok]'''
NAMES.update({0x5FE9: 'ElecManShoot', 0x604A: 'ElecManAnimateRun', 0x6087: 'ElecManNextTarget',
 0x60A5: 'ElecManTargetX', 0x61D8: 'ElecManCheckJump', 0x6213: 'ElecManJumpLeftVelocity',
 0x6217: 'ElecManJumpRightVelocity', 0x621B: 'ElecManAirborne', 0x627D: 'ElecManFireShot'})
C[0x5FD8] = '''Unused: nothing calls it. Faces Mega Man.	;[ok]'''
C[0x6074] = '''Unused: nothing calls it. Updates the stage X; B = 1.	;[ok]'''

C[0x62CC] = '''Type 35: never placed; Elec Man's shot (ElecManFireShot runs ElecManShotInit
with E = his facing, tile base his + $3C). It draws a 7-tile chain
(DrawMetaspriteList) that slides one entry every 2 frames along a zig-zag
path 32 px tall (ElecManShotPathLeft/Right), its 8x8 hitbox at the chain's
head; every 14 entries the chain's base moves 40 px on. Removed when the base
reaches X $C0. Under wFreezeFlags it stops but is still drawn.	;[ok]
That makes it the Thunder Beam, Elec Man's weapon.	;[?]
Modes 2 and 3 (moving up or down 8 px every 3 frames, with FrameTable_03_6507)
are never used: the only caller passes 0 or 1.	;[ok]'''
NAMES.update({0x62E0: 'ElecManShotInit', 0x6370: 'ElecManShotFrame',
 0x6383: 'ElecManShotSyncAndCheckOnScreen', 0x6396: 'ElecManShotDrawChain',
 0x64C4: 'ElecManShotMoveVertical', 0x6354: 'ElecManShotInitUp', 0x6359: 'ElecManShotInitDown',
 0x635C: 'ElecManShotInitVertical', 0x6440: 'ElecManShotPathLeft', 0x6482: 'ElecManShotPathRight',
 0x634C: 'ElecManShotUpVelocity', 0x6350: 'ElecManShotDownVelocity', 0x6346: 'ElecManShotFrames',
 0x6348: 'ElecManShotHitbox'})

C[0x6537] = '''Fire Man (type 36), the boss of his stage (and of the unused alternate one).
State $27: 0 drop in; 1 intro poses while the bar fills; 4 pick a spot $30 px
from Mega Man on Fire Man's side (the far side if that is off the room); 2 walk
there 1 px a frame; on arrival, if Mega Man is exactly $30 away (he has not
moved), 3 attack: $CCF6 = 1 asks the type 37 for a shot (sound $1C), 30 frames
in the attack pose, 50 standing, then back to 4. Killed: B = 0 only (type 37
ends the fight). Frozen: nothing moves.	;[ok]'''
NAMES.update({0x65AF: 'FireManClampTargetX', 0x65C3: 'FireManIntro', 0x661C: 'FireManAnimatePair',
 0x6633: 'FireManWalk', 0x669E: 'FireManAttack', 0x66C7: 'FireManChooseMove',
 0x6711: 'FireManStartAttack', 0x6731: 'FireManStartWalk', 0x6743: 'FireManStartChoose',
 0x6758: 'FireManCheckAttackDistance', 0x676E: 'FireManAnimateWalk', 0x6798: 'FireManSetTargetX',
 0x67C1: 'FireManFrozen'})

C[0x69A3] = '''Type 37, placed beside Fire Man - and beside Elec Man: Fire Man's Fire Storm,
parked off screen. When he sets $CCF6 it clears it, appears $12 px from him
toward Mega Man, holds 20 frames and flies 2 px a frame to the edge, then parks.
While parked it runs CheckBossDead; once the boss is beaten it sets wStageState
2 and calls StartVictoryCountdown every frame (B = 2). Elec Man never writes
$CCF6, so in his room it never fires: it is there to end his fight.	;[ok]'''

C[0x55DB] = '''Type 1, placed in Cut Man (12) and Wily 3 (7). Param & 3 picks a top X speed
(CuttingWheelMaxSpeeds: 1.3, 1.9 or 3 px a frame); 0 never moves, only faces Mega Man
and animates. Sound $11 at spawn. When Mega Man is within $30 px it falls under
gravity with block collision, bouncing: walls reverse it, each landing bounces
it at 3/4 speed (below $0080 it rolls), and on the ground it accelerates toward
its facing. Params 1-2 face the way they move; 3 always faces Mega Man and so
chases him. Removed off screen with sound $13. Frozen: no movement.	;[ok]'''
NAMES.update({0x5615: 'CuttingWheelMaxSpeeds', 0x561B: 'CuttingWheelFrame', 0x562B: 'CuttingWheelFaceAndAnimate',
 0x5634: 'CuttingWheelSyncAndCheckOnScreen', 0x5651: 'CuttingWheelCheckOnScreen', 0x5671: 'CuttingWheelUpdate',
 0x56AE: 'CuttingWheelBounceMove', 0x5716: 'CuttingWheelAccelerateX', 0x575D: 'CuttingWheelSetFacing'})

C[0x5982] = '''Type 2, placed in Cut Man (10), Fire Man (5) and Wily 3 (7). Never moves.
Param & 3: 0 upright; 1-3 upside down (frames 5-9), raised 8 or 15 px. When Mega
Man is within $30 px it opens over about 30 frames and fires five enemy shots
(ScrewDriverFireShot: up, up-right, right, up-left, left - or the downward fan when
upside down), then closes, re-arming while he is near. Frozen: frame kept.	;[ok]'''
NAMES.update({0x5AAF: 'ScrewDriverFireShot'})

C[0x5B5F] = '''Type 3, placed in Cut Man (2), Wily 1 and Wily 3. Starts toward Mega Man once
on screen, crawling 0.5 px a frame - 1.5 px when level with him - and turning
at walls and at ledges (no gravity). No attack. It writes 1/2/3 to $DFC5
(spawned/waiting/started), which nothing reads. Frozen: no movement.	;[ok]'''
NAMES.update({0x5C79: 'GabyoallFaceMegaMan', 0x5C8C: 'GabyoallSpeeds'})

C[0x57CF] = '''Type 5, placed in Cut Man (5) and Wily 3 (8). Sits at its spawn point until
Mega Man is within $30 px, slides 32 px toward his side, then circles its spawn
point at radius $20 (SuperCutterCircleOffsets, a step every 6 frames), always facing
him. Its hit points are reset every frame: $14 while Ice Slasher is the weapon,
else $FE (shots bounce off). Never removed off screen by itself. Frozen: holds
still ($CC00 used as a frozen flag). No attack.	;[ok]'''
NAMES.update({0x5904: 'SuperCutterCircleOffsets', 0x5821: 'SuperCutterAngleTimer', 0x5824: 'SuperCutterFrame',
 0x587C: 'SuperCutterWait', 0x5893: 'SuperCutterNextState', 0x589D: 'SuperCutterSlideOut', 0x58DD: 'SuperCutterPlaceOnCircle',
 0x58F1: 'SuperCutterPlaceAtOffset', 0x5857: 'SuperCutterSetHPAndKeepAlive'})

C[0x5CAC] = '''Type 6, placed once each in Cut Man, Ice Man, Elec Man and Wily 1, three times
in Wily 3. A big hopper: lands, sits in a short pose for 120 frames, rises to a
tall pose for 12, then jumps at Mega Man (sound $1F) - a long low jump or, about
40% of the time, a high one (BigeyeJumpVelocities). Falls with block collision,
bouncing off walls. Removed off screen; frozen: no movement.	;[ok]
Offset $19 is 1 in the short pose, and the collision pass skips shot damage
while it is set, so it can only be hurt when tall.	;[?]'''
NAMES.update({0x5D8A: 'BigeyeMove', 0x5D82: 'BigeyeJumpVelocities'})

C[0x6B49] = '''Type 7, placed in Ice Man (14), Fire Man (13) and Wily 1 (6). A flier: cruises
0.5 px a frame at a height from BunbyHeliCruiseHeights (param & 3), heading right if
it spawned at the right edge, else left. When Mega Man is not more than 32 px
ahead it dives at the Y he had (1.5 px a frame), climbs back to its height and
cruises on toward him. Always faces him. Removed off screen sideways; frozen:
no movement.	;[ok]'''
NAMES.update({0x6B5C: 'BunbyHeliInit', 0x6B9C: 'BunbyHeliUpdate', 0x6B56: 'BunbyHeliRemove',
 0x6BE7: 'BunbyHeliCheckOnScreenX', 0x6C08: 'BunbyHeliDive', 0x6C2D: 'BunbyHeliClimb', 0x6C74: 'BunbyHeliSetDiveTarget',
 0x6C93: 'BunbyHeliStepX', 0x6CB0: 'BunbyHeliStepY', 0x6B98: 'BunbyHeliCruiseHeights', 0x6CD3: 'BunbyHeliAnim'})

C[0x6D19] = '''The fan (type 9), placed three times each in Elec Man, Wily 1 and Wily 3.
Facing = param bit 0. Every frame it animates and, while Mega Man is level with
it (Y-10..Y+9) and on its facing side, pushes him 0.5 px a frame that way
($D830). Time Stopper and Ice Slasher do not stop it. Never removed off screen.
Shots bounce off (hit points $FE); it does not hurt.	;[ok]'''
NAMES.update({0x6D90: 'FanCheckPlayerInRow', 0x6DA9: 'FanAnim'})

C[0x6DE7] = '''The ice platform (type 16), placed in Ice Man (5) and Wily 3 (3): it melts
while Mega Man stands on it. Each frame his feet are on its top edge it counts
$27 up (the count never resets); the frame steps 0-3 at counts 30, 50 and 70,
each with a lower top edge, and at 90 it is gone. Time Stopper and Ice Slasher
do not stop it. Shots bounce off (hit points $FE).	;[ok]'''
NAMES.update({0x6DF8: 'IcePlatformInit', 0x6E0D: 'IcePlatformUpdate', 0x6DF4: 'IcePlatformRemove',
 0x6E41: 'IcePlatformCheckStoodOn', 0x6EA3: 'IcePlatformFrames'})
C[0x6DF7] = '''Unused: a lone ret nothing reaches.	;[ok]'''

C[0x6ED9] = '''The appearing blocks (type 20), placed in Elec Man (5) and Wily 3 (2). One
object runs a whole schedule of blocks (AppearingBlockSchedules[param]), using
a second object slot as scratch for each block's countdown and age. Once Mega
Man is within 160 px a timer counts up and wraps at the schedule's cycle
length; each entry's block appears when the timer reaches its start frame and
stays for its duration (180 frames in every entry) - drawn with a 3-step appear
animation, made solid with AddSolidBox and sounding $1E on its first frame -
while its column is inside the spawn window. Time Stopper and Ice Slasher do
not stop it. Killed: frees the scratch slot.	;[ok]'''
NAMES.update({0x6F03: 'AppearingBlockInit', 0x6F74: 'AppearingBlockUpdate',
 0x705F: 'AppearingBlockDrawBlock', 0x70D9: 'AppearingBlockLoadSelf', 0x70E2: 'AppearingBlockLoadScratch',
 0x70F2: 'AppearingBlockGetSprite', 0x710F: 'AppearingBlockFreeUnusedSprites',
 0x712E: 'AppearingBlockCountSchedule', 0x714C: 'AppearingBlockSchedules',
 0x72A9: 'AppearingBlockFrames'})
C[0x6F00] = '''Unused: nothing calls it. B = 1.	;[ok]'''
C[0x714C] = '''One schedule per param (index 0 duplicates 1 and is never used). Each entry:
dw start frame; db duration ($B4 = 180 frames), block column, row, Y offset
(always 0). A list ends with dw cycle length, $FF; the timer runs 0..cycle and
wraps. Columns are spawn-list columns, rows 16-px rows of the room.	;[ok]'''

C[0x72E1] = '''Type 21, placed in Ice Man (6), Elec Man (15), Fire Man (10) and Wily 1 (6).
Moves in a straight line until a wall: param bits 0-1 pick the axis (nonzero =
vertical), bits 2-3 the direction (nonzero = up/right). It opens (15 frames),
moves 1.5 px a frame testing a point 8 px ahead (CheckSolidPoint); at a wall it
reverses, closes (15 frames), rests 120 frames and goes again. Not removed off
screen while moving. wFreezeFlags pauses it; Ice Slasher does nothing.	;[ok]'''
NAMES.update({0x73EF: 'SuzyMove', 0x744B: 'SuzyCheckSolidAhead'})

C[0x7491] = '''Type 22, placed in Elec Man (11), Wily 1 (4) and Wily 3 (7). A stationary 48x16
bar - 16x48 upright if param bit 0 is set - that is on for 80 frames (animated,
hurts, sound 3 when it turns on) and off for 80 (blank, harmless). Always immune
to shots. Never removed off screen. Holds its state while frozen.	;[ok]'''

C[0x757B] = '''The icicle (type 23), placed seven times in Ice Man. Hidden for +08 x 8 frames
(the spawn record's extra byte), then grows in place, harmless, through frames
0-2 (20 frames each), then falls with gravity and block collision; when it hits
something it plays sound $2B and stays, harmless, until it leaves the screen
sideways. Time Stopper does not stop it. Shots bounce off.	;[ok]'''
NAMES.update({0x758C: 'IcicleInit', 0x75AA: 'IcicleUpdate', 0x7588: 'IcicleRemove'})
C[0x758B] = '''Unused: a lone ret nothing reaches.	;[ok]'''

C[0x769F] = '''Type 17, placed in Elec Man (4), Wily 1 (4) and Wily 3 (5). Faces Mega Man;
shots bounce off while it is shut (hit points $FE), one hit kills it open.
Param bit 0 clear (Elec Man): fixed; opens when Mega Man is within 40 px and
fires three shots, twice, then shuts for 256 frames. Bit 0 set (Wily 1/3):
falls with block collision; opens when he is near, fires three shots, walks
toward him 1.3 px a frame for 40 frames, then stops and shuts. The shots fan out
down, level and up (MetallFireSpread). Removed below the screen.	;[ok]'''
NAMES.update({0x77CB: 'MetallSetFrame', 0x77D7: 'MetallCheckOnScreen', 0x7835: 'MetallFireSpread',
 0x7851: 'MetallFireShot'})

C[0x796B] = '''Type 18, placed twice per room in Wily 1. The placed one is an invisible
controller: it spawns type 18 children (a thin 8x24 sprite) while the camera is
over a range of +08 columns from its own (or ending at it, by param bit 0);
if another controller exists it removes itself. Each of four slots spawns a
child at a fixed screen point (MoleSpawnPoints) - two at the top moving down,
two at the bottom moving up, about 0.5 px a frame, speeding up to 4 px a frame
(and harmless) where both its probes are solid - and waits 30 frames after it
is gone. Live slots are bits of $CC5A.	;[ok]'''
NAMES.update({0x7A08: 'MoleSpawnChildren', 0x7A86: 'MoleSpawnChild', 0x7AA6: 'MoleGetSlotMask',
 0x7AB8: 'MoleInitChild', 0x7ADE: 'MoleChildRoutine', 0x7AEB: 'MoleRemoveChild',
 0x7AFB: 'MoleChildUpdate', 0x7AD8: 'MoleChildFrozen', 0x7B79: 'MoleChildCheckOnScreen',
 0x7A7E: 'MoleSpawnPoints', 0x7B82: 'MoleChildSpeeds'})

# ---- names from Will after step 5.3, checked against the ending's roll call
# (bank $0E $50A4, ASCII - $20).
_WILL = {
 0x55DB: "Cutting Wheel (Will; the ending lists CUTTING WHEEL). Another version of it\nis used in the fight against Dr. Wily.",
 0x5982: "Screw Driver (Will; the ending lists SCREW DRIVER).",
 0x5B5F: "Gabyoall (Will; the ending lists GABYOALL).",
 0x57CF: "Super Cutter (Will; the ending lists SUPER CUTTER).",
 0x5CAC: "Bigeye (Will; the ending lists BIGEYE).",
 0x6B49: "Bunby Heli (Will; the ending misspells it BUNBY HERI).",
 0x769F: "Metall (Will; the ending lists METALL).",
 0x796B: "Mole (Will; the ending lists MOLE): the placed object is the controller that\nspawns the moles.",
 0x72E1: "Suzy, also called Adhering Suzy or Octopus Battery (Will; the ending lists\nSUZY).",
 0x7491: "Electric beam (Will): an obstacle rather than an enemy, so not in the\nending's list.",
}
for _a, _t in _WILL.items():
    C[_a] = _t + '\t;[ok]\n' + C[_a]

# Step 7.3d: the last provisional Func_ labels, renamed in the source (which
# has been hand-edited since; do not regenerate it from this config).
NAMES.update({
 0x4AB5: 'CutManClearFreeze',
 0x5508: 'CutManRollingCutterFrozen',
 0x5509: 'CutManRollingCutterClearFreeze',
 0x5851: 'SuperCutterPlaceAndFace',
 0x5FD8: 'ElecManFaceMegaManUnused',
 0x6074: 'ElecManSyncStageXUnused',
 0x60A2: 'ElecManClearFreeze',
 0x6672: 'FireManToAttack',
 0x6688: 'FireManToChoose',
 0x66D2: 'FireManAttackStand',
 0x66FB: 'FireManToWalk',
 0x6756: 'FireManWalkCheckStub',
 0x6B59: 'BunbyHeliFrozen',
 0x6DF7: 'Unused_03_6DF7',
 0x6F00: 'Unused_03_6F00',
 0x758B: 'Unused_03_758B',
 0x77EA: 'MetallFixedWait',
 0x780D: 'MetallFixedOpen',
 0x786F: 'MetallFixedShut',
 0x7AAB: 'MoleSlotToMask',
})
