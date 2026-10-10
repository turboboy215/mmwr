BANK = 1
END = 0x738D
HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $01
;Section layout ported from the iimarckus/megaman skeleton; all labels are this
;project's own. Confidence tags: [ok] verified here, [dc] corroborated by Data
;Crystal, [?] unverified guess. See docs/CONVENTIONS.md.

SECTION "bank1",ROMX,BANK[$1]
'''

ENTRIES = [0x67EA,0x5943,0x5A87,0x553A,0x66DA,0x5F68,0x542C,0x57D5,0x5C08,0x4429,0x543A,
 0x66D6,0x5416,0x40B7,0x5A5F,0x4FD0,0x5939,0x66C5,0x6156,0x4000,0x672D,0x5967,0x55E4,
 0x5F8F,0x62D1,0x4140,0x42AE,0x574E,0x57A1,0x60AF,0x5450,
 # weapon handlers from WeaponTab
 0x443F,0x444F,0x4496,0x44C6,0x4594,0x461D,0x47C6,0x47EA,0x4808,0x4841,0x48E8,0x494F,
 0x4A19,0x4A5A,0x4BBA,0x4BFC,0x4C6A,0x4CA6,0x4D26,0x4D48,0x4E53,0x4E5A,
 # unreferenced code
 0x4494, 0x6411, 0x643B, 0x6464, 0x648D, 0x66CA,
 # code template copied to RAM
 0x608E,
]

L = lambda **k: k
DATA = [
 (0x4007, 0x40B7, 'WeaponTab', 'raw', {}),     # filled in below
 (0x41DA, 0x41E6, None, 'db', L(width=2)),
 (0x41E6, 0x41F1, None, 'db', L(width=11)),
 (0x444B, 0x444F, None, 'dw', L(width=2)),
 (0x44A2, 0x44C6, None, 'dw', L(width=2)),
 (0x4588, 0x4590, None, 'anim', {}),
 (0x4590, 0x4594, None, 'dw', L(width=2)),
 (0x45EA, 0x45F0, None, 'db', {}),
 (0x4615, 0x461D, None, 'dw', L(width=2, labels={0x4619: 'Data_01_4619'})),
 (0x46F4, 0x4736, None, 'db', L(width=3)),
 (0x4736, 0x4778, None, 'db', L(width=3)),
 (0x47D5, 0x47D9, None, 'dw', L(width=2)),
 (0x47FC, 0x4808, None, 'anim', {}),
 (0x483D, 0x4841, None, 'dw', L(width=2)),
 (0x4869, 0x4877, None, 'anim', {}),
 (0x48CC, 0x48DC, None, 'db', L(width=2)),
 (0x48DC, 0x48E8, None, 'anim', {}),
 (0x49A8, 0x49AF, None, 'anim', {}),
 (0x4A38, 0x4A4D, None, 'db', L(width=4, labels={0x4A3B: 'Data_01_4A3B', 0x4A3E: 'Data_01_4A3E',
        0x4A41: 'Data_01_4A41', 0x4A45: 'Data_01_4A45', 0x4A49: 'Data_01_4A49'})),
 (0x4A4D, 0x4A51, None, 'dw', L(width=2)),
 (0x4B78, 0x4B8A, None, 'anim', {}),
 (0x4B8A, 0x4BBA, None, 'db', L(width=2, labels={0x4B9A: 'Data_01_4B9A', 0x4BAA: 'Data_01_4BAA'})),
 (0x4C2B, 0x4C31, None, 'dw', {}),
 (0x4C62, 0x4C6A, None, 'anim', {}),
 (0x4C76, 0x4CA6, None, 'dw', L(width=2)),
 (0x4D1E, 0x4D26, None, 'anim', {}),
 (0x4D44, 0x4D48, None, 'dw', L(width=2)),
 (0x4E0A, 0x4E11, None, 'anim', {}),
 (0x4ECC, 0x4EDF, None, 'anim', {}),
 (0x4F3E, 0x4F47, None, 'db', L(width=3, labels={0x4F41: 'Data_01_4F41', 0x4F44: 'Data_01_4F44'})),
 (0x5098, 0x536C, None, 'frames', L(tables=[0x5098,0x50D0,0x5100,0x5138,0x51B3,0x51E3,0x523B,0x5267,0x5293,0x52BD])),
 (0x53AB, 0x53BB, None, 'db', {}),
 (0x5411, 0x5416, None, 'db', {}),
 (0x54D9, 0x54DE, None, 'db', {}),
 (0x5729, 0x572C, None, 'db', {}),
 (0x58BC, 0x5939, None, 'frames', L(tables=[0x58BC], frames=[0x58D0])),
 (0x5964, 0x5967, None, 'db', {}),
 (0x5A59, 0x5A5A, None, 'db', {}),
 (0x5AA2, 0x5AD2, None, 'db', L(width=4)),
 (0x5B44, 0x5B48, None, 'dw', L(width=2)),
 (0x5B48, 0x5C08, None, 'dw', L(width=2)),
 (0x5C7C, 0x5C84, None, 'dw', {}),
 (0x5C84, 0x5C9C, None, 'db', L(width=6, labels={0x5C8A: 'Data_01_5C8A', 0x5C90: 'Data_01_5C90', 0x5C96: 'Data_01_5C96'})),
 (0x5DB5, 0x5DCB, None, 'dw', {}),
 (0x5E5C, 0x5E70, None, 'db', L(width=10)),
 (0x5EB7, 0x5EBF, None, 'db', {}),
 (0x5EF8, 0x5EFD, None, 'db', {}),
 (0x5F1B, 0x5F31, None, 'raw', L(lines=['\tSETCHARMAP menu', '\tdb "P "\t;Mega Buster', '\tdb "CU"\t;Rolling Cutter', '\tdb "EL"\t;Thunder Beam', '\tdb "IC"\t;Ice Slasher', '\tdb "FI"\t;Fire Storm', '\tdb "CA"\t;Carry', '\tdb "HE"\t;Atomic Fire', '\tdb "FL"\t;Time Stopper', '\tdb "QU"\t;Quick Boomerang', '\tdb "BU"\t;Bubble Lead', '\tdb "EN"\t;Mirror Buster', '\tSETCHARMAP main'])),
 (0x5FAA, 0x5FAF, None, 'raw', L(lines=['\tdb 7\t;tiles per row (non-zero = pending)', '\tdw $9C00, $C109\t;BG map row, buffer row'])),
 (0x5FAF, 0x5FB4, None, 'raw', L(lines=['\tdb 7', '\tdw $9C07, $C110'])),
 (0x5FB4, 0x5FB9, None, 'raw', L(lines=['\tdb 6', '\tdw $9C0E, $C117'])),
 (0x6091, 0x609B, None, 'db', L(width=2)),
 (0x609B, 0x60AF, None, 'db', L(width=2)),
 (0x611A, 0x612A, 'MenuCursorTile', 'raw', L(lines=[
     '\tdb $00,$00,$40,$40,$60,$60,$70,$50,$78,$48,$70,$50,$60,$60,$40,$40',
     'MenuCursorTileEnd:'])),
 (0x63F7, 0x63FA, None, 'raw', L(lines=['\tSETCHARMAP getscreen', '\tdb "AND"', '\tSETCHARMAP main'])),
 (0x63FA, 0x63FF, None, 'raw', L(lines=['\tSETCHARMAP getscreen', '\tdb "CARRY"', '\tSETCHARMAP main'])),
 (0x63FF, 0x6411, None, 'dw', {}),
 (0x650B, 0x652B, None, 'db', {}),
 (0x6600, 0x6670, None, 'db', L(width=4, labels={0x6620: 'Data_01_6620', 0x6640: 'Data_01_6640'})),
 (0x69B5, 0x69D6, None, 'db', L(width=11, labels={0x69C0: 'Data_01_69C0', 0x69CB: 'Data_01_69CB'})),
 (0x6AE6, 0x6AEE, None, 'db', {}),
 (0x6D10, 0x6D20, None, 'db', L(width=2, labels={a: 'Data_01_%04X' % a for a in range(0x6D12, 0x6D20, 2)})),
 (0x6E92, 0x6E9E, None, 'dw', L(width=2)),
 (0x6F20, 0x6F2C, None, 'dw', L(width=2)),
 (0x701C, 0x72D4, None, 'frames', L(tables=[0x701C], hitbox=False)),
]

# WeaponTab: 11 records of 16 bytes, written out field by field
import struct
_rom = ROM
_wl = []
for i in range(11):
    r = _rom[0x4007 + i*16: 0x4007 + i*16 + 16]
    _wl.append('\tdb $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X, $%02X' % tuple(r[:10]))
    _wl.append('\tdw @@%04X, @@%04X' % (r[10] | r[11] << 8, r[12] | r[13] << 8))
    _wl.append('\tdb $%02X, $%02X' % (r[14], r[15]))
DATA[0] = (0x4007, 0x40B7, 'WeaponTab', 'raw', {'lines': _wl})

NAMES = {0x60AF: 'TitleScreen'}
LOCALNAMES = {}
COMMENTS = {}
OPER = {
 0x489A: 'LOW(@@48CC)', 0x489D: 'HIGH(@@48CC)',
 0x4A8B: 'LOW(@@4A3E)', 0x4A8E: 'HIGH(@@4A3E)',
 0x4AC1: 'LOW(@@4A38)', 0x4AC4: 'HIGH(@@4A38)',
 0x4ADC: 'LOW(@@4A3B)', 0x4ADF: 'HIGH(@@4A3B)',
 0x54B8: 'LOW(@@54D9)', 0x54BB: 'HIGH(@@54D9)',
 0x5A8E: 'LOW(@@5AA2)', 0x5A91: 'HIGH(@@5AA2)',
 0x6E7A: 'LOW(@@6E92)', 0x6E7D: 'HIGH(@@6E92)',
 0x6F0F: 'LOW(@@6F20)', 0x6F12: 'HIGH(@@6F20)',
 0x5EE2: 'LOW(@@5EF8)', 0x5EE7: 'HIGH(@@5EF8)',
 0x6054: 'LOW(@@6091)', 0x6059: 'HIGH(@@6091)',
 0x4E96: 'LOW(@@52DB + 4)', 0x4E99: 'HIGH(@@52DB + 4)',
 0x559C: '@@5411 - 1',
 0x5715: '@@58BC - 4',
 0x63AC: '@@63FF - 2',
 0x6111: 'VRAM_TILES0', 0x6114: 'MenuCursorTileEnd - MenuCursorTile',
}
INLINE = {}

# ======================================================================
# names and comments
# ======================================================================
WEAPONS = ['MegaBuster', 'RollingCutter', 'ThunderBeam', 'IceSlasher', 'FireStorm', 'Carry',
           'AtomicFire', 'TimeStopper', 'QuickBoomerang', 'BubbleLead', 'MirrorBuster']
_fire = [0x443F,0x4496,0x4594,0x47C6,0x4808,0x48E8,0x4A19,0x4BBA,0x4C6A,0x4D26,0x4E53]
_upd  = [0x444F,0x44C6,0x461D,0x47EA,0x4841,0x494F,0x4A5A,0x4BFC,0x4CA6,0x4D48,0x4E5A]
for _i, _w in enumerate(WEAPONS):
    NAMES[_fire[_i]] = 'Fire' + _w
    NAMES[_upd[_i]] = 'Update' + _w + 'Shot'

N = {
 0x4928: 'AddCarrySolidBox',
 0x493B: 'DestroyCarryShot',
 0x49AF: 'CheckPlayerOnCarry',
 0x49EA: 'CheckCarryInWall',
 0x4A07: 'CheckCarryCorner',
 0x4A51: 'AtomicFireNoEnergy',
 0x4B5F: 'UpdateAtomicFireFlight',
 0x4E11: 'CheckBubbleLeadFront',
 0x4EDF: 'UpdateReflectedShot',
 0x5048: 'AnimateShotOnList',
 0x572C: 'ItemLeftScreen',
 0x5730: 'ItemCollected',
 0x5732: 'EndItem',
 0x5749: 'RemoveItem',
 0x5824: 'CheckItemAgainstStage',
 0x5A5A: 'RemoveExplosion',
 0x5DD0: 'CountLowSixBits',
 0x64B6: 'FillZoomRowBG',
 0x64C9: 'FillZoomRowWindow',
 0x64DA: 'Fill8Bytes',
 0x65AB: 'KeepChosenBossSprites',
 0x66C5: 'ClearNoDamageFlag',
 0x66D6: 'RoomFreeHurtSpark',
 0x6841: 'PlayerControlMove',
 0x68A8: 'PlayerControlEnd',
 0x68BE: 'HandlePlayerDamage',
 0x6976: 'EndHurtSpark',
 0x6986: 'DrawHurtSpark',
 0x69D6: 'ClimbDownLadderTop',
 0x69EC: 'ChooseHurtAnim',
 0x6A10: 'ChoosePlayerAnim',
 0x6A16: 'ChooseMotionAnim',
 0x6A7B: 'SetPlayerAnim',
 0x6A9B: 'ChooseLadderAnim',
 0x6AD6: 'ChooseAirAnim',
 0x6AEE: 'AccumulatePlayerDX',
 0x6B10: 'StartJump',
 0x6B24: 'UpdatePlayerAir',
 0x6BE8: 'UpdatePlayerLadder',
 0x6D20: 'CheckPlayerFloorCeiling',
 0x6D7B: 'CheckPlayerWalls',
 0x6D95: 'BlockPlayerX',
 0x6DAA: 'CheckPlayerWallsLeft',
 0x6DBF: 'CheckPlayerWallsMid',
 0x7359: 'StepTeleportBeam',
 0x7372: 'TeleportBeamNotDone',
 0x7374: 'StepTeleportBeamFast',
 0x4000: 'InstallWeaponHooks',
 0x40B7: 'EquipWeapon',
 0x411E: 'InstallFireHook',
 0x412F: 'InstallShotHook',
 0x4140: 'TryFireWeapon',
 0x4190: 'PlaceShotAtBuster',
 0x41B8: 'PlaceNewShot',
 0x41BB: 'InitNewShot',
 0x41DA: 'BusterOffsets',
 0x41F1: 'SpendWeaponEnergy',
 0x420B: 'NegateDEIfFacingLeft',
 0x4218: 'CheckShotTouchesPlayer',
 0x423A: 'SetShotVelocity',
 0x424E: 'SetShotVelocityX',
 0x4259: 'SetShotVelocityY',
 0x4264: 'AddShotToHitList',
 0x4289: 'AddShotToHitList2',
 0x42AE: 'UpdateShots',
 0x431E: 'MoveShot',
 0x4339: 'CheckShotOnScreen',
 0x4358: 'DrawShot',
 0x43E8: 'AllocShot',
 0x4412: 'FreeShot',
 0x4429: 'FreeAllShots',
 0x444B: 'MegaBusterVelocity',
 0x4494: 'Unused_01_4494',
 0x44A2: 'RollingCutterArc',
 0x456A: 'AimShotAtPlayer',
 0x4588: 'RollingCutterAnim',
 0x4590: 'ThunderBeamVelocity',
 0x4615: 'ThunderBeamUpVelocity',
 0x4619: 'ThunderBeamDownVelocity',
 0x46F4: 'ThunderBeamBoltRight',
 0x4736: 'ThunderBeamBoltLeft',
 0x47D5: 'IceSlasherVelocity',
 0x47D9: 'AnimateIceSlasher',
 0x47FC: 'IceSlasherAnimRight',
 0x4802: 'IceSlasherAnimLeft',
 0x483D: 'FireStormVelocity',
 0x4869: 'FireStormAnimRight',
 0x4870: 'FireStormAnimLeft',
 0x48CC: 'FireStormOrbit',
 0x48DC: 'FireStormShieldAnim',
 0x49A8: 'CarryAnim',
 0x4A38: 'AtomicFireTilesets',
 0x4A3B: 'AtomicFireDamage',
 0x4A3E: 'AtomicFireCosts',
 0x4A41: 'AtomicFirePalettes1',
 0x4A45: 'AtomicFirePalettes2',
 0x4A49: 'AtomicFirePalettes3',
 0x4A4D: 'AtomicFireVelocity',
 0x4B48: 'AnimateAtomicFire',
 0x4B78: 'AtomicFireAnim1',
 0x4B7E: 'AtomicFireAnim2',
 0x4B84: 'AtomicFireAnim3',
 0x4B8A: 'TimeStopperLayout1',
 0x4B9A: 'TimeStopperLayout2',
 0x4BAA: 'TimeStopperLayout3',
 0x4BE0: 'EndTimeStopper',
 0x4C2B: 'TimeStopperLayouts',
 0x4C31: 'DrawTimeStopper',
 0x4C62: 'TimeStopperAnim',
 0x4C76: 'QuickBoomerangPath',
 0x4D1E: 'QuickBoomerangAnim',
 0x4D44: 'BubbleLeadVelocity',
 0x4E0A: 'BubbleLeadAnim',
 0x4ECC: 'MirrorBusterAnimLeft',
 0x4ED3: 'MirrorBusterAnimRight',
 0x4EDA: 'MirrorBusterAnimUnused',
 0x4EFF: 'SetShotFrameFromVelocity',
 0x4F3E: 'DirectionFramesUp',
 0x4F41: 'DirectionFramesLevel',
 0x4F44: 'DirectionFramesDown',
 0x4F47: 'AllocShotSlot',
 0x4F6E: 'ReflectCapturedShots',
 0x4FCA: 'ClearCapturedShots',
 0x4FD0: 'CaptureEnemyShot',
 0x4FF8: 'ApplyShotGravity',
 0x5045: 'AnimateShot',
 0x5092: 'AnimateShot2',
 0x536C: 'LoadWeaponHUD',
 0x5372: 'LoadWeaponLetterTiles',
 0x538C: 'CopyLetterTile',
 0x53AB: 'BlankTile',
 0x53BB: 'SetShotFrameAndStore',
 0x53C2: 'SetShotFrame',
 0x53E6: 'SetShotFrame2AndStore',
 0x53ED: 'SetShotFrame2',
 0x5411: 'ItemTilesets',
 0x5416: 'InitItems',
 0x542C: 'InitPlacedItems',
 0x543A: 'ResetPlacedItems',
 0x5450: 'PlacedItemRoutine',
 0x548D: 'SpawnPlacedItem',
 0x54D9: 'PlacedItemTypes',
 0x54DE: 'SetPlacedItemState',
 0x54EE: 'FindPlacedItem',
 0x5509: 'RollItemDrop',
 0x553A: 'SpawnItem',
 0x55E4: 'UpdateItems',
 0x563B: 'UpdateItem',
 0x5729: 'Unused_01_5729',
 0x574E: 'CollectItem',
 0x57A1: 'RefillTick',
 0x57AB: 'RefillStep',
 0x57D5: 'FreeAllItems',
 0x57F2: 'SetItemBox',
 0x5897: 'ApplyItemGravity',
 0x58BC: 'ItemFrames',
 0x5939: 'SpawnExplosion',
 0x5943: 'SpawnDeathExplosion',
 0x5964: 'ExplosionParams',
 0x5967: 'UpdateExplosions',
 0x59B8: 'UpdateExplosion',
 0x5A5F: 'InitExplosions',
 0x5A75: 'SpawnPlayerDeathBurst',
 0x5A87: 'SpawnExplosionBurst',
 0x5AA2: 'BurstParticles',
 0x5AD2: 'SpawnExplosionParticle',
 0x5B32: 'GetParticleVelocity',
 0x5B44: 'ParticleVelocityNone',
 0x5B48: 'ParticleVelocities',
 0x5C08: 'FreeAllExplosions',
 0x5C25: 'DrawTileGrid',
 0x5C7C: 'ExplosionFrames',
 0x5C9C: 'PauseMenu',
 0x5D10: 'PauseMenuInput',
 0x5D9E: 'DrawPauseMenuLetters',
 0x5DB5: 'PauseMenuLetterPositions',
 0x5DCB: 'CountLeftColumnWeapons',
 0x5DDD: 'CountRightColumnWeapons',
 0x5DF0: 'DrawPauseMenu',
 0x5E5C: 'BlankMenuRow',
 0x5E70: 'GetMenuRowAddress',
 0x5E84: 'DrawPauseMenuEntry',
 0x5EA0: 'GetWeaponUnlockBit',
 0x5EB7: 'BitMasks',
 0x5EBF: 'DrawMenuEnergyBar',
 0x5EF8: 'MenuBarTiles',
 0x5EFD: 'GetWeaponLetters',
 0x5F1B: 'WeaponLetters',
 0x5F68: 'InitHUD',
 0x5F8F: 'UpdateHUD',
 0x5FA1: 'QueueHUDCopy',
 0x5FAA: 'HUDCopyWeaponBar',
 0x5FAF: 'HUDCopyHealthBar',
 0x5FB4: 'HUDCopyLives',
 0x6027: 'DrawHUDBar',
 0x6070: 'InstallHUDSplit',
 0x608E: 'HUDSplitJump',
 0x6091: 'HUDBarTiles',
 0x609B: 'HUDDigitTiles',
 0x610A: 'LoadTitleCursor',
 0x612A: 'UpdateTitleCursor',
 0x6156: 'StageSelect',
 0x62D1: 'WeaponGet',
 0x63F7: 'AndText',
 0x63FA: 'CarryText',
 0x63FF: 'WeaponAwardBits',
 0x6411: 'ShowWilyCastle',
 0x643B: 'ShowSkullShip',
 0x6464: 'ShowWilyMachinePhase1',
 0x648D: 'ShowWilyMachinePhase2',
 0x64E3: 'PlaceStageSelectCursor',
 0x650B: 'StageSelectCursorCorners',
 0x652B: 'BlinkStageSelectCursor',
 0x655C: 'StageSelectInput',
 0x65DB: 'InitStarfield',
 0x65F7: 'CopyBytesB',
 0x6600: 'StarfieldFar',
 0x6620: 'StarfieldMid',
 0x6640: 'StarfieldNear',
 0x6670: 'ScrollStarfield',
 0x66A3: 'ScrollStarLayer',
 0x66CA: 'Unused_01_66CA',
 0x66D6: 'FreeHurtSpark',
 0x66DA: 'InitPlayer',
 0x66F9: 'CheckCarrySideCollision',
 0x672D: 'UpdatePlayer',
 0x6764: 'UpdatePlayerState',
 0x67EA: 'PlayerControl',
 0x68AB: 'ReadPlayerJoypad',
 0x6941: 'SpawnHurtSpark',
 0x6959: 'UpdateHurtSpark',
 0x6BC0: 'StopPlayer',
 0x6BCE: 'GrabLadder',
 0x6D10: 'PlayerProbes',
 0x6F4B: 'DrawPlayer',
 0x701C: 'MegaManFrames',
 0x72D4: 'UpdateTeleport',
}
NAMES.update(N)
# frame tables, by owner
_ft = {0x5098: 'RollingCutter', 0x50D0: 'ThunderBeam', 0x5100: 'IceSlasher', 0x5138: 'FireStorm',
       0x51B3: 'Carry', 0x51E3: 'AtomicFire', 0x523B: 'TimeStopper', 0x5267: 'QuickBoomerang',
       0x5293: 'BubbleLead', 0x52BD: 'MirrorBuster'}
for _a, _w in _ft.items(): NAMES[_a] = _w + 'Frames'
# frames: name them <owner>Frame<n> in table order
_rom2 = ROM
_starts = sorted(_ft) + [0x536C]
for _k, _a in enumerate(sorted(_ft)):
    _n = 0; _p = _a
    _seenf = []
    while True:
        _v = _rom2[_p] | _rom2[_p+1] << 8
        if _v in _seenf or not (0x5098 <= _v < 0x536C): break
        if _p >= min([x for x in _starts if x > _a]): break
        if any(_v == t for t in _ft): break
        _seenf.append(_v); _p += 2
        # stop when the table runs into its first frame
        if _p >= min(_seenf): break
    for _n, _v in enumerate(_seenf):
        NAMES.setdefault(_v, '%sFrame%d' % (_ft[_a], _n))
NAMES.update({0x58D0: 'ItemFrameUnused', 0x58D9: 'ItemFrameExtraLife',
  0x5921: 'ItemFrameBigHealth1', 0x592D: 'ItemFrameBigHealth2',
  0x58F7: 'ItemFrameSmallHealth1', 0x5900: 'ItemFrameSmallHealth2',
  0x5909: 'ItemFrameBigEnergy1', 0x5915: 'ItemFrameBigEnergy2',
  0x58E5: 'ItemFrameSmallEnergy1', 0x58EE: 'ItemFrameSmallEnergy2'})
del NAMES[0x66D6]
NAMES.update({
 0x697E: 'FreeHurtSpark',
 0x4345: 'CheckPositionOnScreen',
 0x43C9: 'DrawShotFrame',
 0x45F0: 'FireThunderBeamSides',
 0x46B0: 'DrawThunderBeam',
 0x4778: 'UpdateThunderBeamSide',
 0x4877: 'UpdateFireStormShield',
 0x4A55: 'ResetShotPalette',
 0x4E3D: 'CheckShotTile',
 0x588F: 'CheckItemTile',
 0x5F31: 'ReloadObjectTilesAfterMenu',
 0x5FB9: 'UpdateHUDWeaponBar',
 0x5FE2: 'UpdateHUDHealthBar',
 0x6002: 'UpdateHUDLivesAndBoss',
 0x6CB7: 'MovePlayerY',
 0x6CC9: 'ApplyPlayerGravity',
 0x6DE8: 'CheckTileAbovePlayer',
 0x6DF4: 'CheckTileBelowPlayer',
 0x6E00: 'CheckPlayerLanding',
 0x6E2C: 'CheckPlayerProbe',
 0x6E3A: 'CheckPlayerFeet',
 0x6E47: 'MovePlayerX',
 0x6E9E: 'ClampPlayerSpeedX',
 0x6EE5: 'SetWalkVelocity',
 0x6F2C: 'SetClimbVelocity',
})
# Mega Man's frames, in first-use order
_mm = []
for _p in range(0x701C, 0x7080, 2):
    _v = _rom2[_p] | _rom2[_p+1] << 8
    if _v not in _mm: _mm.append(_v)
for _n, _v in enumerate(_mm): NAMES[_v] = 'MegaManFrame%d' % _n

# the HUD copy requests are (db pending/width, dw VRAM row, dw buffer row)
for _a in (0x5FAA, 0x5FAF, 0x5FB4):
    pass

C = {}
C[0x4000] = '''$4000: the bank's entry point, called at the start of every stage (and on a
restart) from bank $00: install the two weapon hooks. Bank $01 has no entry
table; this three-instruction stub is what sits at $4000.	;[ok]'''
C[0x4007] = '''$4007: one 16-byte record per weapon, in wCurrentWeapon order (Mega Buster,
Rolling Cutter, Thunder Beam, Ice Slasher, Fire Storm, Carry, Atomic Fire, Time
Stopper, Quick Boomerang, Bubble Lead, Mirror Buster). EquipWeapon copies one out:
  db tileset	;-> $C22B, LoadObjectTiles type for each shot's sprite
  db max shots	;-> $C22C, TryFireWeapon refuses to fire past it
  db state	;-> $C22D, a new shot's offset $00 (non-zero = slot in use)
  db damage	;-> $C203 (and $C204), copied to each shot's offset $0B
  db x1, x2, y1, y2	;-> $C205-$C208, the shots' hitbox (often reset per frame)
  db cost	;-> $C22E, energy SpendWeaponEnergy takes per shot
  db pierce	;-> $C235, how a hit treats the shot (wWeaponPierce)
  dw fire, update	;-> `jp` at wWeaponFire and wWeaponUpdate
  db 0, 0	;unused
Carry, Atomic Fire and Time Stopper also (Atomic Fire instead) spend energy in
their own routines: Carry and Time Stopper drain over time, Atomic Fire by
charge level.	;[ok]'''
C[0x40B7] = '''$40B7: switch to weapon wCurrentWeapon: reinstall the hooks, zero the shot
count and shoot timer, copy the weapon's WeaponTab record into wWeaponDamage-wWeaponPierce
(building the two `jp`s), clear the three shot slots, reset the Mirror Buster
capture list and load the weapon's HUD letters. Called on stage load and by the
pause menu when the choice changes.	;[ok]'''
C[0x411E] = '''Point wHookA at TryFireWeapon. UpdatePlayer calls wHookA when Mega Man is
able to act ($675D), which answers who calls the $C0AA hook.	;[ok]'''
C[0x412F] = '''Point wHookB at UpdateShots. StageFrameLoop calls wHookB every frame.	;[ok]'''
C[0x4140] = '''wHookA: fire the equipped weapon if B was pressed (held, for Quick Boomerang)
and nothing forbids it - the game not frozen (wFreezeFlags & $53), fewer than the
weapon's maximum shots alive, weapon energy left (the buster needs none) and
the shoot timer below 8. Sets the shoot timer to $10, spends the energy, takes
a shot slot, places it at the buster and jumps to the weapon's fire routine with
A = wCurrentWeapon and C = the slot.	;[ok]'''
C[0x4190] = '''Put shot C at the buster: Mega Man's position (wPlayerX, wPlayerY) plus the
BusterOffsets pair for his state (wPlayerMotion) and facing (wPlayerFacing).	;[ok]'''
C[0x41B8] = '''PlaceShotAtBuster, then fall into InitNewShot.	;[ok]'''
C[0x41BB] = '''Shot C's damage from wWeaponDamage, its facing from wPlayerFacing, and offsets $0F-$15
zeroed (frame, animation counters, age, weapon scratch).	;[ok]'''
C[0x41DA] = '''$41DA: (dx, dy) from Mega Man to the buster, indexed by (state * 2 + facing):
standing left/right, airborne left/right, on a ladder left/right.	;[ok]'''
C[0x41E6] = '''$41E6: eleven bytes, one per weapon, that nothing reads. The values (4, $0E,
$1D, $1B, $1C, 0, 4, 4, 4, 4, 4) look like sound IDs but have not been
checked.	;[?]'''
C[0x41F1] = '''Subtract the weapon's cost ($C22E) from its meter, stopping at zero. The Mega
Buster (weapon 0) is free.	;[ok]'''
C[0x420B] = '''Negate DE when Mega Man faces left (wPlayerFacing = 0).	;[ok]'''
C[0x4218] = '''Carry if shot C is inside a box around Mega Man (X -6..+6, Y -8..+12). Used
to catch the Rolling Cutter on its way back.	;[ok]'''
C[0x423A] = '''Set shot C's velocity from HL: dw X speed (mirrored when facing left), dw Y
speed. Speeds are 8.8 fixed point.	;[ok]'''
C[0x424E] = '''Shot C's X speed = DE (offsets $01 low, $03 high).	;[ok]'''
C[0x4259] = '''Shot C's Y speed = DE (offsets $05 low, $07 high).	;[ok]'''
C[0x4264] = '''If shot C still does damage (offset $0B, low six bits), append (pointer to
that byte, X, Y) to the hit list at $C209; $C202 is the list's write pointer.
The collision pass in bank $00 ($1093) tests enemies against this list with
the hitbox at $C205-$C208, and on a hit takes the damage from offset $0B and
weakens or removes the shot there (see wWeaponPierce).	;[ok]'''
C[0x4289] = '''The same for the second hit list at $C21D (pointer $C216, hitbox
$C219-$C21C). Thunder Beam's side bolts, the Fire Storm shield and reflected
Mirror Buster shots use it.	;[ok]'''
C[0x42AE] = '''wHookB, every frame: update and draw the three shot slots ($C239, $C259,
$C279, $20 bytes each). Sets the sprite tile base ($72) and palette, resets both
hit lists, and for each live shot - unless the game is frozen (wFreezeFlags bits 0-1)
- counts its age (offset $12) and calls the weapon's update through wWeaponUpdate: NZ
keeps the shot and draws it, Z frees it. Then terminates the hit lists and sets
their non-empty flags ($C204, $C218). With the Mirror Buster equipped it also
fires back whatever was caught.
Shot record: $00 power (0 = free), $01/$03 X speed, $02/$04 X (sub, pixel),
$05/$07 Y speed, $06/$08 Y, $0A sprite handle, $0B damage ($80 once deflected), $0C facing,
$0D-$0E metasprite, $0F frame, $10-$11 animation counter and step, $12 age,
$13 onwards per weapon.	;[ok]'''
C[0x431E] = '''Move shot C by its velocity (X also by the scroll in $D850), then fall into
the on-screen test: NZ while it is on screen, Z once it has left.	;[ok]'''
C[0x4339] = '''NZ if shot C's position is on screen, Z if not.	;[ok]'''
C[0x4345] = '''NZ if (E, D) lies on screen (X below $AC or above $F4, Y below $90).	;[ok]'''
C[0x4358] = '''Draw shot C. Offers its box to the hitbox viewer first. The Mega Buster's
pellet is written straight into its OAM entry (tile $65); Thunder Beam and
Time Stopper have their own drawing; everything else is a metasprite.	;[ok]'''
C[0x43C9] = '''Draw shot C's current metasprite (offsets $0D-$0E) at its position.	;[ok]'''
C[0x43E8] = '''Claim a free shot slot (the first wins if all are taken), give it the weapon's
power and a sprite handle for its tileset, and count it. Returns C = slot.	;[ok]'''
C[0x4412] = '''Free shot C, if live: clear it, release its sprite handle, uncount it.	;[ok]'''
C[0x4429] = '''Free the shots and zero the count. The loop stops at $60, so only the first
two slots are freed - the third ($C279) is skipped, though the count is still
zeroed. Called on pause and stage load.	;[ok]'''
C[0x4494] = '''$4494: `xor a / ret` that nothing reaches - it follows FireMegaBuster's
update routine's `ret`.	;[ok]'''
C[0x44A2] = '''Rolling Cutter's outward arc: nine (dw X speed, dw Y speed) steps, five frames
each, before it turns for home.	;[ok]'''
C[0x456A] = '''Start a line step from shot C to Mega Man (LineStepInit), for the Rolling
Cutter's return.	;[ok]'''
C[0x4594] = '''Thunder Beam fires three bolts: this one forward, then FireThunderBeamSides
adds one going up and one going down.	;[ok]'''
C[0x45F0] = '''The up and down bolts (offset $15 = 1 and 2), on the second hit list.	;[ok]'''
C[0x46B0] = '''Draw a Thunder Beam bolt: the forward one is a (dx, dy, tile) list walked by
frame; the side ones use ThunderBeamFrames.	;[ok]'''
C[0x46F4] = '''The forward bolt as (dx, dy, tile) triples, one table per facing.	;[ok]'''
C[0x47D9] = '''Animate the Ice Slasher for its facing.	;[ok]'''
C[0x4808] = '''Fire Storm: a fireball forward plus a shield of flame that circles Mega Man
($3C frames).	;[ok]'''
C[0x4877] = '''The circling shield: eight positions around Mega Man (FireStormOrbit), on the
second hit list.	;[ok]'''
C[0x48CC] = '''(dx, dy) around Mega Man for the Fire Storm shield.	;[ok]'''
C[0x48E8] = '''Carry: a platform placed in front of Mega Man (closer when he is
airborne).	;[ok]'''
C[0x494F] = '''The Carry platform: 8 energy every $3C frames, gone (with an explosion) at 0
or when a wall probe hits.	;[ok]'''
C[0x4A19] = '''Atomic Fire: holding B charges (offset $12), releasing fires. The charge
level picks tileset, damage, cost and palette cycle from the tables below.	;[ok]'''
C[0x4A38] = '''Atomic Fire, per charge level (0-2): tileset, hit flags (also read by bank
$00 at $0CC8), cost; then three palette cycles and the shot's speed.	;[ok]'''
C[0x4A55] = '''Restore OBP0 to $1C after Atomic Fire's palette cycling.	;[ok]'''
C[0x4BBA] = '''Time Stopper: sets wFreezeFlags bit 3 (time stopped) and puts up eight sprites;
drains 8 energy every $19 frames until empty.	;[ok]'''
C[0x4BE0] = '''Time runs again: free the eight sprites and clear wFreezeFlags bit 3.	;[ok]'''
C[0x4C31] = '''Draw the Time Stopper's eight sprites at one of three layouts.	;[ok]'''
C[0x4C6A] = '''Quick Boomerang: fired while B is held; it flies a twelve-step curve.	;[ok]'''
C[0x4C76] = '''Quick Boomerang's curve: twelve (dw X speed, dw Y speed) steps.	;[ok]'''
C[0x4D26] = '''Bubble Lead: a bubble that falls under gravity (ApplyShotGravity) and is
stopped and turned by walls and floors.	;[ok]'''
C[0x4E3D] = '''Collision tile at shot C's position plus (E, D).	;[ok]'''
C[0x4E53] = '''Mirror Buster has no shot of its own. While B is held, its update puts a
shield in front of Mega Man; enemy shots that hit it are caught
(CaptureEnemyShot) and sent back.	;[ok]'''
C[0x4EDA] = '''$4EDA: a third Mirror Buster animation that nothing points at.	;[ok]'''
C[0x4EFF] = '''Pick shot C's frame from the signs of its velocity, through the three
DirectionFrames tables.	;[ok]'''
C[0x4F47] = '''Claim a free shot slot like AllocShot, but return carry if there is none.	;[ok]'''
C[0x4F6E] = '''Mirror Buster: launch every caught enemy shot back as a shot of our own,
velocity reversed, 4 energy each, while energy lasts.	;[ok]'''
C[0x4FCA] = '''Empty the capture list ($C299 is its write pointer, records from $C29A).	;[ok]'''
C[0x4FD0] = '''Called by the enemy-shot code (bank $00 $3830) when the Mirror Buster
blocked enemy shot C: record its velocity and position for
ReflectCapturedShots.	;[ok]'''
C[0x4FF8] = '''Add $17 to shot C's Y speed, capped at $0120, and bleed off 1/64 of its X
speed.	;[ok]'''
C[0x5045] = '''Advance shot C's animation. DE = an animation record:
  dw frame table, db frames per step, db frame, frame, ..., $FF (loop)
and set its frame (SetShotFrameAndStore). AnimateShot2 does the same for a
shot on the second hit list.	;[ok]'''
C[0x5098] = '''Weapon frame tables, one per weapon, and the frames they point at. A frame
is a 4-byte hitbox (x1, x2, y1, y2 relative to the shot; SetShotFrame copies it
to the hit list's hitbox) followed by a DrawMetasprite metasprite.	;[ok]'''
C[0x536C] = '''Load the equipped weapon's two HUD letters, then redraw the HUD.	;[ok]'''
C[0x5372] = '''Copy the font tiles for the equipped weapon's two letters to $9600 and
$9610.	;[ok]'''
C[0x538C] = '''Copy the tile for character A (a screen-charmap code; $70 is the blank) to
DE.	;[ok]'''
C[0x53BB] = '''Store frame A at offset $0F, then set it: look the frame up in table DE,
copy its hitbox to $C205-$C208 and point offset $0D at its metasprite.	;[ok]'''
C[0x53E6] = '''The same, but the hitbox goes to $C219-$C21C (second hit list).	;[ok]'''
C[0x5411] = '''$5411: LoadObjectTiles type for item types 1-5 (indexed from $5410).	;[ok]'''
C[0x5416] = '''Item slots, $D400 page: ten $10-byte records from $D417, a free list at
$D40C (pointer $D416) and the live list from $D400 (count $D40B).	;[ok]'''
C[0x542C] = '''Once per game ($DFD4): start the placed-item list empty.	;[ok]'''
C[0x543A] = '''Forget placed items that were spawned but not collected (state 1), so they
come back; collected ones (state 2) stay gone.	;[ok]'''
C[0x5450] = '''Object type 8's routine (ObjectTypeTab points here, bank $01). Only the
spawn call (B = 0) does anything: it turns the object into an item pickup
(SpawnPlacedItem) and ends with B = 0, which removes the object.	;[ok]'''
C[0x548D] = '''Spawn a placed item unless the placed-item list ($D4C3, 3 bytes per item:
position, state) says it was already taken. Its type comes from
PlacedItemTypes.	;[ok]'''
C[0x54DE] = '''Mark placed item DE as collected (B != 0) or not yet spawned.	;[ok]'''
C[0x54EE] = '''Find placed item DE in the list; carry if absent, else HL at its state.	;[ok]'''
C[0x5509] = '''An enemy died: maybe drop an item. One roll of FuncRNG: below $9A nothing;
$9A extra life; $9B-$9D big health; $9E-$B5 small health; $B6-$BF big energy;
$C0 and up small energy. Drops pop upwards and vanish after $FE frames.	;[ok]'''
C[0x553A] = '''Spawn an item of type B at ($D3EB, $D3EC) with the lifetime and speeds in
$D4B9-$D4BB.	;[ok]'''
C[0x55E4] = '''Every frame: run the refill if one is going, then move, draw and expire the
items, collecting those Mega Man touches.	;[ok]'''
C[0x5729] = '''$5729: three bytes after UpdateItem's `ret` that nothing reaches.	;[ok]'''
C[0x574E] = '''Collect item C: type 1 is an extra life (sound $10, at most 9 shown), 2 and 3
health (10 or 2 points), 4 and 5 weapon energy (10 or 2, none for the buster).
Energy is given out by RefillStep, one point at a time.	;[ok]'''
C[0x57A1] = '''Every 4th frame while wFreezeFlags bit 1 is set, give one more point.	;[ok]'''
C[0x57AB] = '''One point: $D4C1 points left, $D4BF/$D4C0 the meter. Each point adds 8 and
plays sound $12, up to $98; then wFreezeFlags bit 1 is cleared.	;[ok]'''
C[0x57D5] = '''Free every item and its sprite.	;[ok]'''
C[0x58BC] = '''Item frames: two per type (they alternate), types 1-5, indexed from $58B8.
The first frame, a lone tile, is not in the table.	;[ok]'''
C[0x5939] = '''CallBank1Routine index 4: one explosion at (E, D).	;[ok]'''
C[0x5943] = '''CallBank1Routine index 2, and the collision pass when an enemy dies: an
explosion at ($D3EB, $D3EC), maybe an item drop (unless $CCF1 is set), and
sound $02.	;[ok]'''
C[0x5967] = '''Move, animate and expire the explosions ($D300 page: twelve $10-byte records
from $D31A, free-list pointer $D319, count $D30C).	;[ok]'''
C[0x5A75] = '''Mega Man died: sound $0F and twelve particles flying out from him - unless
he fell off the bottom of the screen (Y $80 and up).	;[ok]'''
C[0x5A87] = '''CallBank1Routine index 1: B explosion particles at (E, D), each with its
direction from BurstParticles.	;[ok]'''
C[0x5AD2] = '''Spawn one explosion: A = direction (index into ParticleVelocities, $FF for
none), HL = 3 parameter bytes, (E, D) = position. Carry if all twelve are in
use.	;[ok]'''
C[0x5C25] = '''Write a B-row by C-column grid of tiles from DE into OAM at ($FF92, $FF91)
with tile base $FF93; the explosions' drawing.	;[ok]'''
C[0x5C9C] = '''The pause menu, from PlayerControl on Start. Frees the shots, loads the font,
draws the weapon list and slides the window up over the playfield; the d-pad
moves the selection (blinking), A, B or Start closes it. Choosing a different
weapon calls EquipWeapon. Then slides back and restores the object tiles the
font overwrote.	;[ok]'''
C[0x5D10] = '''One frame of pause-menu input. Up/down walk the unlocked weapons; left/right
jump between the two columns of six.	;[ok]'''
C[0x5D9E] = '''Draw weapon A's two letters (B = 1) or blanks (B = 0) at its place in the
menu - the selection blinks by alternating the two.	;[ok]'''
C[0x5DCB] = '''Count the unlocked weapons in the left column (bits 0-5 of
wWeaponsUnlocked1).	;[ok]'''
C[0x5DDD] = '''Count the unlocked weapons in the right column (the rest).	;[ok]'''
C[0x5DF0] = '''Draw the pause menu's six rows into the window map ($9C40 on): each row has
a left and a right weapon with its letters and energy bar.	;[ok]'''
C[0x5E84] = '''Weapon A's letters and energy bar into the row buffer at DE (blank if not
unlocked).	;[ok]'''
C[0x5EA0] = '''HL = the unlock byte for weapon A, A = its bit.	;[ok]'''
C[0x5EB7] = '''$5EB7: single-bit masks. Bank $00 also indexes this from $5EB6.	;[ok]'''
C[0x5EBF] = '''Five bar tiles for an energy value A (a tile per 8 points, $98 = full).	;[ok]'''
C[0x5EFD] = '''Write weapon A's two letters to DE (blanks if B = 0).	;[ok]'''
C[0x5F1B] = '''Two letters per weapon for the pause menu and the HUD, in the `menu` charmap
(the font loaded at $8900): the first letters of the robot master each weapon
comes from - P for the Mega Buster, CA for Carry, HE (Heat Man), FL (Flash Man)
and EN (Enker) for the three Wily weapons.	;[ok]'''
C[0x5F31] = '''After the pause menu: the font was loaded over sprite tiles $90 and up, so
rewind the object-tile cache ($C3C4) to the first tileset that reached them and
reload it and everything after.	;[ok]'''
C[0x5F68] = '''Build the HUD: install the window split, draw all three parts, copy the
buffer to the window map and load the weapon letters.	;[ok]'''
C[0x5F8F] = '''Every frame, one of three HUD parts in turn ($C107): weapon bar, health bar,
lives and boss bar. Each fills its piece of the $C109 buffer and queues a
copy for VBlank.	;[ok]'''
C[0x5FA1] = '''Queue the 5-byte copy request at HL for VBlank (to $C102, done by
VBlankCopyHUD).	;[ok]'''
C[0x6002] = '''Lives digit (HUDDigitTiles) and, while $C100 is set, the boss's bar from
$C101.	;[ok]'''
C[0x6027] = '''Draw a two-row energy bar for value A into DE (blank if B = 0).	;[ok]'''
C[0x6070] = '''Install the HUD's window split: `jp HUDSplitHandler` into the STAT handler slot
(wRamCode) and LYC $7F.	;[ok]'''
C[0x608E] = '''Copied to wRamCode by InstallHUDSplit; never run from here.	;[ok]'''
C[0x60AF] = '''$1:60AF: the title screen. Starts the title music (ID $2A, bank $0A), ignores
input for 120 frames, then waits for Start. Leaves wAudioBank on $02.	;[ok]'''
C[0x610A] = '''Load the menu cursor tile and set OBP0.	;[ok]'''
C[0x612A] = '''Title menu: up, down or Select toggle $CC00 (sound $0B) and move the cursor
sprite between the two lines.	;[ok]'''
C[0x6156] = '''The stage select, called by the game flow. Starts on the first undefeated
robot master, then: move the cursor, blink it, Start on an undefeated one. The
screen then zooms (window slides) to the boss intro: starfield, the boss's
sprite, TypeBossName. Leaves wSelectedStage one-based.	;[ok]'''
C[0x62D1] = '''The weapon-get screen after a boss: music $29, scroll the picture in, type
the text, award the weapon (WeaponAwardBits) - and after the fourth robot
master, Carry too ("AND CARRY").	;[ok]'''
C[0x63F7] = '''"AND" and "CARRY", ASCII + $80, typed on the weapon-get screen after the
last robot master. The award table below starts inside "CARRY": it is
indexed from $63FD, one-based.	;[ok]'''
C[0x63FF] = '''Weapon unlock bits awarded per stage (1-4) and per Wily teleporter (5-9):
dw wWeaponsUnlocked1 | wWeaponsUnlocked2 << 8.	;[ok]'''
C[0x6411] = '''Four routines nothing calls: each shows one cutscene picture (Wily's castle,
the skull ship, the Wily Machine phase 1 and 2) and waits for Start - a
picture viewer, perhaps for testing.	;[ok]'''
C[0x64E3] = '''Put the stage-select cursor's four corner sprites round portrait
wSelectedStage.	;[ok]'''
C[0x652B] = '''Cycle OBP0 every 8 frames so the cursor blinks.	;[ok]'''
C[0x655C] = '''Stage-select input: left/right and up/down flip the column and row bits of
wSelectedStage, with sound $0B.	;[ok]'''
C[0x65DB] = '''Boss intro: copy the three starfield layers into shadow OAM ($C030).	;[ok]'''
C[0x6600] = '''Starfield sprites, three layers (OAM entries); ScrollStarfield moves them at
different speeds.	;[ok]'''
C[0x6670] = '''Move the starfield layers diagonally.	;[ok]'''
C[0x66CA] = '''$66CA: unreachable. Waits forever while bit 7 of $D80E is clear.	;[ok]'''
C[0x66DA] = '''Mega Man at the start of a stage: state 1 (alive), facing right, the buster
unlocked.	;[ok]'''
C[0x66F9] = '''With Carry out, stop Mega Man walking into the side of the platform.	;[ok]'''
C[0x672D] = '''Mega Man's frame, from the stage loop: state and controls, Carry, scroll
tracking, then draw him, his hurt spark, and fire the weapon (wHookA) if he can.	;[ok]'''
C[0x6764] = '''Mega Man's life state (wPlayerState): 1 alive, 2 just died (start the death burst,
take OAM entries for it, $F0-frame timer), 3 dying (on to LoseLife when the
timer runs out). While alive, also run the teleport and the stage-clear exit.	;[ok]'''
C[0x67EA] = '''Controls: Start opens the pause menu (not while shots are out, except with
the Mirror Buster); otherwise walk, jump, climb, take damage.	;[ok]'''
C[0x68AB] = '''Copy the joypad to wPlayerPressed and wPlayerHeld, unless $D845 says
controls are locked.	;[ok]'''
C[0x6941] = '''Mega Man was hit: start the three-frame hit spark at his position.	;[ok]'''
C[0x697E] = '''Release the hit spark's sprite.	;[ok]'''
C[0x6BC0] = '''Zero Mega Man's velocities.	;[ok]'''
C[0x6BCE] = '''Grab a ladder: state 2, X snapped to the ladder's column.	;[ok]'''
C[0x6CB7] = '''Add the Y speed ($D828-$D829) to Mega Man's Y ($D823-$D825).	;[ok]'''
C[0x6CC9] = '''Gravity: Y speed += $34, or $12 under water (wUnderwater), capped at +$0340 and
-$0341.	;[ok]'''
C[0x6D10] = '''Collision probes, (dx, dy) from Mega Man: head, feet and sides.	;[ok]'''
C[0x6E00] = '''If his feet are on something and he is not rising, land (sound $08 the
first frame): state 1 on the ground, 0 in the air.	;[ok]'''
C[0x6E47] = '''Add the X speed to Mega Man's X, with the slide/ice adjustment from
$6E92.	;[ok]'''
C[0x6E9E] = '''Clamp the X speed to $F0 ($C0 under water).	;[ok]'''
C[0x6EE5] = '''Facing and walking speed from left/right.	;[ok]'''
C[0x6F2C] = '''Ladder: up -$A0, down +$A0, else 0.	;[ok]'''
C[0x6F4B] = '''Draw Mega Man into shadow OAM from $C000: frame (wPlayerAnim + facing) from
MegaManFrames, at his position, flipped by $D80B; unused entries hidden.	;[ok]'''
C[0x701C] = '''Mega Man's frames: a pointer per (animation, facing) - wPlayerAnim is even, wPlayerFacing
adds the facing - and the metasprites.	;[ok]'''
C[0x72D4] = '''Teleport (wTeleportState): 1 the beam drops in from the top until it lands and turns
into Mega Man, 2 and 3 the beam leaves.	;[ok]'''
COMMENTS = C

HEADER = r''';Mega Man: Dr. Wily's Revenge disassembly - ROM bank $01
;
;The resident bank: bank $00 pages it back in whenever it is done with another,
;so it holds everything that runs during play and the menus around it. 100%
;source since step 5.1, split by subsystem into the files below (in ROM order);
;every chunk is its own SECTION pinned to its original address, so the include
;order does not matter.
;
;  $4000-$5410  engine/weapons.asm, data/weapon_frames.asm: WeaponTab, firing,
;               the shot engine, the eleven weapons, their animations and frames
;  $5411-$5938  engine/items.asm: item drops and placed items, the refill
;  $5939-$5C9B  engine/explosions.asm: explosions and death bursts
;  $5C9C-$5F67  engine/pause_menu.asm: the weapon menu
;  $5F68-$60AE  engine/hud.asm: the window HUD (energy bars, lives)
;  $60AF-$6155  engine/title_menu.asm: the title screen
;  $6156-$66C4  engine/stage_select_menu.asm, engine/weapon_get_screen.asm,
;               engine/picture_viewer.asm: stage select and boss intro, the
;               weapon-get screen, four unused picture viewers
;  $66C5-$738C  engine/player.asm, data/megaman_frames.asm: Mega Man - life
;               state, controls, physics, drawing, teleport
;  $738D-$7FFF  unused
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.
'''
FOOTER = r'''
;$738D-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 1 Free Space", ROMX[$738D], BANK[$1]
	ds $8000 - $738D, $FF
'''
CHUNKS = {
 0x4000: ('engine/weapons.asm', 'Weapons'),
 0x5098: ('data/weapon_frames.asm', 'Weapon Frames'),
 0x536C: ('engine/weapons.asm', 'Weapon Letters and Frames'),
 0x5411: ('engine/items.asm', 'Items'),
 0x5939: ('engine/explosions.asm', 'Explosions'),
 0x5C9C: ('engine/pause_menu.asm', 'Pause Menu'),
 0x5F68: ('engine/hud.asm', 'HUD'),
 0x60AF: ('engine/title_menu.asm', 'Title Menu'),
 0x6156: ('engine/stage_select_menu.asm', 'Stage Select Menu'),
 0x62D1: ('engine/weapon_get_screen.asm', 'Weapon Get Screen'),
 0x6411: ('engine/picture_viewer.asm', 'Picture Viewer'),
 0x64B6: ('engine/stage_select_menu.asm', 'Stage Select Helpers'),
 0x66C5: ('engine/player.asm', 'Player'),
 0x701C: ('data/megaman_frames.asm', 'Mega Man Frames'),
 0x72D4: ('engine/player.asm', 'Teleport'),
}
def _fh(title):
    return (";Mega Man: Dr. Wily's Revenge disassembly - %s\n"
            ";Part of ROM bank $01 (step 5.1). Every section is pinned to its original\n"
            ";address, so the include order in banks/bank01.asm does not affect the ROM.\n"
            ";Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.\n") % title
FILEHEAD = {
 'engine/weapons.asm': _fh('weapons and shots'),
 'data/weapon_frames.asm': _fh("the weapons' frame tables and frames"),
 'engine/items.asm': _fh('item pickups and the meter refill'),
 'engine/explosions.asm': _fh('explosions'),
 'engine/pause_menu.asm': _fh('the pause (weapon) menu'),
 'engine/hud.asm': _fh('the HUD'),
 'engine/title_menu.asm': _fh('the title screen'),
 'engine/stage_select_menu.asm': _fh('the stage select and boss intro'),
 'engine/weapon_get_screen.asm': _fh('the weapon-get screen'),
 'engine/picture_viewer.asm': _fh('unused cutscene picture viewers'),
 'engine/player.asm': _fh('Mega Man'),
 'data/megaman_frames.asm': _fh("Mega Man's frames"),
}
OPER[0x4163] = 'LOW(wWeaponMaxShots)'
OPER[0x4179] = 'LOW(wShootTimer)'
C[0x4140] = C[0x4140].replace('wHookA: fire', 'wHookA: count the shoot timer down, then fire')
C[0x66CA] = '''$66CA: unreachable. Returns if bit 7 of $D80E is clear, and otherwise hangs -
the same kind of trap as the sprite system's.	;[ok]'''
C[0x66C5] = '''Clear $DF93, which PlayerControl reads (it stops contact damage while set).
Called by the game flow after the title screen.	;[ok]'''
C[0x66D6] = '''Stage load: just FreeHurtSpark.	;[ok]'''
C[0x5A5A] = '''UpdateExplosion's exit for a finished or off-screen explosion: B = 0.	;[ok]'''
C[0x572C] = '''UpdateItem's exits: the item left the screen (B = 0) or was collected
(B = 1). A placed item's list entry is updated to match, then the item goes.	;[ok]'''
C[0x5749] = '''Remove the item: B = 0.	;[ok]'''
C[0x5824] = '''Item against the stage: rising into a ceiling stops it; falling into the floor
pushes it back up out of the block and marks it landed (offset $0C).	;[ok]'''
C[0x5DD0] = '''Count the set bits among the low six of E.	;[ok]'''
C[0x6841] = '''PlayerControl once Mega Man may move: by wPlayerMotion - in the air, on a
ladder, or on the ground (walk, jump on A, climb down on Down at a ladder
top).	;[ok]'''
C[0x68A8] = '''Common exit: choose the animation.	;[ok]'''
C[0x68BE] = '''Damage and knockback. $D838 is the damage waiting to be taken (spikes and
the collision pass add to it): 8 health per unit, death at 0 (wPlayerState 2).
A hit plays sound $06, starts the hit spark and sets wHurtTimer to $88, then
Mega Man is pushed back (velocity from $D834) while it is above $59. With $CCF5
set (not traced) damage is ignored and health never drops below 1.	;[ok]'''
C[0x6976] = '''Hit spark finished: release its sprite.	;[ok]'''
C[0x6986] = '''Draw the hit spark's current frame at Mega Man.	;[ok]'''
C[0x69D6] = '''Climb down from the top of a ladder: Y + 6, then GrabLadder.	;[ok]'''
C[0x69EC] = '''Hurt animations: knocked back ($1A, $1C under water) while wHurtTimer is
above $5A; afterwards he blinks, every 4 frames hidden (animation $2A).	;[ok]'''
C[0x6A16] = '''Choose wPlayerAnim from what Mega Man is doing: jumping, climbing, walking
(a four-step cycle from $6AE6) or standing (with an occasional blink), and the
shooting versions of each while wShootTimer runs.	;[ok]'''
C[0x6AE6] = '''Walking animation cycle, plain and shooting.	;[ok]'''
C[0x6AEE] = '''$D84E = how far Mega Man moved in X this frame; add it to the 16-bit
$D80D.	;[ok]'''
C[0x6B10] = '''A pressed: leave the ground with a 10-frame rise ($D84A).	;[ok]'''
C[0x6B24] = '''In the air: while A is held and the rise timer runs, keep the jump speed
($D84B, less under water); gravity, movement, walls and ceiling, landing. Up
over a ladder (block 1) grabs it.	;[ok]'''
C[0x6BE8] = '''On a ladder: climb with Up and Down (SetClimbVelocity), get off at the top or
bottom; A lets go.	;[ok]'''
C[0x6D20] = '''Vertical collision: while rising, stop at a ceiling (head probes); while
falling, at a floor (feet probes) - moving Mega Man a pixel at a time out of
the block.	;[ok]'''
C[0x6D7B] = '''Horizontal collision: walking into a wall puts Mega Man back where he was
this frame and zeroes his X speed. Carry if he was stopped.	;[ok]'''
C[0x6DBF] = '''The same test with the probes for a ladder.	;[ok]'''
C[0x7359] = '''Teleport beam animation steps: E = the frame, carry once it is done.	;[ok]'''
C[0x64B6] = '''Stage-select zoom: fill a row of the BG map (top half) or the window map
(bottom half) with tile $01, following the slide ($CCFC).	;[ok]'''
C[0x65AB] = '''After a stage is chosen: copy the chosen portrait's sprites (a block of
shadow OAM per stage) with CopyToShadowOAM.	;[?]'''
C[0x4928] = '''Register the Carry platform as a solid box (AddSolidBox) at its position.	;[ok]'''
C[0x493B] = '''The platform is gone: an explosion where it was, Z to free the shot.	;[ok]'''
C[0x49AF] = '''Carry if Mega Man is standing on the platform; carries him up with it as it
rises ($D833).	;[?]'''
C[0x49EA] = '''Carry if any of the platform's four corners is in a solid block.	;[ok]'''
C[0x4A51] = '''Not enough energy for the charge level: cancel (cost 0, palette back).	;[ok]'''
C[0x4B5F] = '''Atomic Fire in flight.	;[ok]'''
C[0x4E11] = '''Carry if the Bubble Lead's probes on its front side hit a solid block.	;[ok]'''
C[0x4EDF] = '''A reflected shot in flight (Mirror Buster), on the second hit list.	;[ok]'''
C[0x68BE] = '''Damage and knockback. $D838 is the damage waiting to be taken (spikes and
the collision pass add to it): 8 health per unit, death when health reaches 0
(wPlayerState 2). A hit plays sound $06, starts the hit spark and sets
wHurtTimer to $88; Mega Man is then pushed back (velocity from $D834) while it
is $59 or more. With $CCF5 set (not traced) the hurt state is cancelled, and a
hit that would take health below zero leaves 1.	;[ok]'''
C[0x69EC] = '''Hurt animations: while wHurtTimer is $5A or more he is knocked back,
alternating $1A and $1C every 4 frames; after that he blinks, animation $2A
(a frame with no tiles) every other 4 frames.	;[ok]'''
C[0x6B24] = '''In the air. During the 10-frame rise ($D84A), holding A keeps the full jump
speed (-$2E0, -$2B0 under water); letting go early cuts it to $D84B, a speed
that has been growing by $49 a frame since take-off - so a short press gives
a short jump. Then gravity, movement, walls and ceiling, landing; Up over a
ladder (block 1) grabs it.	;[ok]'''
C[0x6DBF] = '''Horizontal collision with the probes nearer his middle, used in the air.	;[ok]'''
C[0x4A38] = '''Atomic Fire, per charge level (0-2): tileset, damage (1, 2, 5), cost; then
three palette cycles and the shot's speed. Bank $00's boss-damage code
(ApplyBossDamageTab) finds the charge level by matching wWeaponDamage against the
damage row, and scales the boss damage by 1, 2 or 5 to match.	;[ok]'''

C[0x443F] = """Mega Buster: sound $04 and a pellet forward at 2 pixels a frame.	;[ok]"""
C[0x444F] = """A pellet an enemy deflected (offset $0B bit 7) flies off diagonally (state
1, no more hits); otherwise it just moves.	;[ok]"""
C[0x4496] = """Rolling Cutter: sound $0E, start the spin animation.	;[ok]"""
C[0x44C6] = """The cutter flies RollingCutterArc, then homes in on Mega Man with a line step
and disappears (sound $14) when it reaches him or leaves the screen.	;[ok]"""
C[0x461D] = """The forward bolt (offset $15 = 0) grows every 3 frames, moving out by
offset $17's step; the side bolts go to UpdateThunderBeamSide.	;[ok]"""
C[0x47C6] = """Ice Slasher: sound $1B, a blade forward at 2 pixels a frame.	;[ok]"""
C[0x47EA] = """Move and animate the blade.	;[ok]"""
C[0x4841] = """The fireball (offset $15 = 0) moves and animates; the shield part goes to
UpdateFireStormShield.	;[ok]"""
C[0x4A5A] = """While B is held, charge (sounds $2F-$31 by level, levels at $78 and $B4
frames) and keep the shot at the buster; on release, fire at the charge level
if there is energy for it.	;[ok]"""
C[0x4BFC] = """Every $19 frames take 8 energy; at 0 time runs again. Animates the
sprites.	;[ok]"""
C[0x4CA6] = """Fly the twelve-step curve, then the shot is gone.	;[ok]"""
C[0x4D48] = """Fall (ApplyShotGravity) until a floor stops it, then travel along it; turned
or stopped by walls.	;[ok]"""
C[0x4E5A] = """With B held (and $DF94 clear) show the shield in front of Mega Man;
otherwise an empty frame. Reflected shots (offset $15 set) are in flight.	;[ok]"""

C[0x444F] = """A pellet an enemy deflected (offset $0B bit 7) turns round and flies back up
and away in state 1, which keeps it off the hit list; otherwise it just
moves.	;[ok]"""
C[0x4A5A] = """While B is held, charge (sounds $2F-$31 by level, levels at $78 and $B4
frames) with the shot parked off the bottom of the screen; on release, fire
at the charge level if there is energy for it.	;[ok]"""
C[0x4BFC] = """Every $19 frames take 8 energy; at 0 time runs again. Cycles the sprites
through their three layouts.	;[ok]"""
NAMES.update({
 0x5A59: 'Unused_01_5A59', 0x41E6: 'Unused_01_41E6',
 0x5C84: 'ExplosionFrame0', 0x5C8A: 'ExplosionFrame1', 0x5C90: 'ExplosionFrame2', 0x5C96: 'ExplosionFrame3',
 0x69B5: 'HurtSparkFrame1', 0x69C0: 'HurtSparkFrame2', 0x69CB: 'HurtSparkFrame3',
 0x6AE6: 'WalkCycle',
 0x6D10: 'ProbeHeadLeft', 0x6D12: 'ProbeHeadRight', 0x6D14: 'ProbeFeetLeft', 0x6D16: 'ProbeFeetRight',
 0x6D18: 'ProbeUpperLeft', 0x6D1A: 'ProbeUpperRight', 0x6D1C: 'ProbeLowerLeft', 0x6D1E: 'ProbeLowerRight',
 0x6E92: 'FloorFriction', 0x6F20: 'FloorWalkAccel',
 0x45EA: 'ThunderBeamList2Setup',
})
NAMES.pop(0x6D10 + 0x10000, None)
C[0x5A59] = '''$5A59: a stray zero byte between two routines.	;[ok]'''
C[0x5C84] = '''Explosion frames: (dx, dy) then a 2x2 grid of tiles.	;[ok]'''
C[0x69B5] = '''The hit spark's three metasprites.	;[ok]'''
C[0x6D10] = '''Collision probes, (dx, dy) from Mega Man's centre: head, feet, and two
points either side of his middle.	;[ok]'''
C[0x6E92] = '''Friction per floor type (wFloorType), one step toward zero speed: (moving
left, moving right). Ice is 1.	;[ok]'''
C[0x6F20] = '''Walking acceleration per floor type: (left, right). Ice is 4.	;[ok]'''
C[0x45EA] = '''Copied to $C217-$C21C for the side bolts: $C217, wShotList2Active and
wShotHitbox2.	;[ok]'''
C[0x4778] = '''A side bolt: every 3 frames it moves 8 pixels up or down (by its Y speed's
sign) and steps its frame; on the second hit list.	;[ok]'''
C[0x4A07] = '''One of the Carry corner probes: CheckSolidAt the platform's position plus
(E, D).	;[ok]'''
C[0x4B48] = '''Animate the Atomic Fire shot for its charge level (offset $1A).	;[ok]'''
C[0x5048] = '''AnimateShot's body, with $FF95 choosing the hit list.	;[ok]'''
C[0x5092] = '''AnimateShot for a shot on the second hit list.	;[ok]'''
C[0x53C2] = '''SetShotFrameAndStore without the store: frame A of table DE.	;[ok]'''
C[0x53ED] = '''The same for the second hit list.	;[ok]'''
C[0x563B] = '''Item at L: count down its lifetime ($FF = a placed item, never), fall,
land, draw - blinking (frame counter bit 3) - and collect it if it touches
Mega Man. B = 0 when it should go.	;[ok]'''
C[0x5730] = '''Collected: B = 1.	;[ok]'''
C[0x5732] = '''Common exit: a placed item's list entry follows B, then the item goes.	;[ok]'''
C[0x57F2] = '''The item's box from its centre (E, D): 4 pixels each way for types 3 and 5,
8 for the others, to $FF9A-$FF9D.	;[ok]'''
C[0x588F] = '''CheckSolidAt, keeping B and C and leaving H = $D4.	;[ok]'''
C[0x5897] = '''Item gravity: Y speed += $34, capped at $0340, then add it to Y.	;[ok]'''
C[0x59B8] = '''Explosion C: move it by its velocity (and the scroll), animate it every 3
frames, draw it; B = 0 once it has finished or left the screen.	;[ok]'''
C[0x5A5F] = '''Set up the explosion slots' free list, empty.	;[ok]'''
C[0x5B32] = '''HL = the velocity record for direction A ($FF: none).	;[ok]'''
C[0x5C08] = '''Free every explosion and its sprite.	;[ok]'''
C[0x5E70] = '''DE = window-map address of menu row D (two map rows per menu row) plus E.	;[ok]'''
C[0x5FB9] = '''HUD part 0: the equipped weapon's bar and the weapon letters' tiles.	;[ok]'''
C[0x5FE2] = '''HUD part 1: Mega Man's health bar.	;[ok]'''
C[0x64C9] = '''The window-map half of the same.	;[ok]'''
C[0x64DA] = '''Write A to eight bytes at HL.	;[ok]'''
C[0x65F7] = '''Copy B bytes from DE to HL.	;[ok]'''
C[0x66A3] = '''Move B starfield sprites at HL by (D, E), wrapping X at $A2; the ones in the
portrait band ($38-$71) get tile $FE (hidden) instead of $CCF7.	;[ok]'''
C[0x643B] = '''Show the skull ship and wait for Start.	;[ok]'''
C[0x6464] = '''Show the Wily Machine, phase 1, and wait for Start.	;[ok]'''
C[0x648D] = '''Show the Wily Machine, phase 2, and wait for Start.	;[ok]'''
C[0x6959] = '''Advance the hit spark (a frame every $14 frames, three frames) and draw it;
frozen while the game is.	;[ok]'''
C[0x6A10] = '''Animation: the hurt animations first while wHurtTimer runs.	;[ok]'''
C[0x6A7B] = '''Store animation B. Standing still while shooting becomes $1E (Mega Buster
and Quick Boomerang) or $22 (the other weapons).	;[ok]'''
C[0x6A9B] = '''On a ladder: getting on or off ($18), shooting ($14 or $16), else climbing
($10/$12, alternating with his Y).	;[ok]'''
C[0x6AD6] = '''In the air: $0C, or $0E shooting.	;[ok]'''
C[0x6D95] = '''Blocked: back to last frame's X, X speed zero, carry.	;[ok]'''
C[0x6DAA] = '''Moving left: the screen edge (X below 4) and the left probes.	;[ok]'''
C[0x6DE8] = '''CheckSolidAt 8 pixels above Mega Man.	;[ok]'''
C[0x6DF4] = '''CheckSolidAt $0D pixels below Mega Man (just under his feet).	;[ok]'''
C[0x6E2C] = '''CheckSolidAt Mega Man plus the (dx, dy + 1) at HL.	;[ok]'''
C[0x6E3A] = '''Carry if either foot probe is solid.	;[ok]'''
C[0x7372] = '''Not done yet: no carry.	;[ok]'''
C[0x7374] = '''A faster version of the beam animation, for teleport state 3.	;[ok]'''
C[0x563B] = '''Item at L: count down its lifetime ($FF = a placed item, which never
expires or falls), fall and land, draw it - alternating its two frames on bit
3 of $DF86 - and collect it if it touches Mega Man. B = 0 when it should
go.	;[ok]'''
C[0x57F2] = '''The item's box around (E, D) into $FF9A-$FF9D: -4..+2 for the small ones
(types 3 and 5), -8..+6 for the others.	;[ok]'''
C[0x5E70] = '''DE = $9C00 + D * 32 + E: the window map at row D, column E.	;[ok]'''
C[0x66A3] = '''Move B starfield sprites at HL by D down and E across; Y wraps at $A2, and
stars inside the portrait band (Y $38-$71) get tile $FE instead of $CCF7, which
hides them.	;[ok]'''

C[0x41E6] = """$41E6: eleven bytes, one per weapon, that nothing reads. For nine weapons the
byte is the sound its fire routine plays; Atomic Fire and Time Stopper differ.
Probably a firing-sound table the routines stopped using (UNUSED.md).	;[?]"""
C[0x5729] = """$5729: three bytes after UpdateItem's `ret` that nothing reaches - a `jr`
back to $5726 and a $00.	;[ok]"""
