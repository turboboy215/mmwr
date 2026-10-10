;Mega Man: Dr. Wily's Revenge disassembly - graphics pointer tables
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Graphics Pointers", ROM0[$02E7]

GfxRef_MegaMan:	;[?]
	dw GfxPtr_MegaMan
GfxRef_ItemPickup:	;[?]
	dw GfxPtr_ItemPickup

GfxRef_MegaBusterShot:	;[dc]
	dw GfxPtr_MegaBusterShot
GfxRef_RollingCutter:	;[dc]
	dw GfxPtr_RollingCutter
GfxRef_ThunderBeam:	;[dc]
	dw GfxPtr_ThunderBeam
GfxRef_IceSlasher:	;[dc]
	dw GfxPtr_IceSlasher
GfxRef_FireStorm:	;[dc]
	dw GfxPtr_FireStorm
GfxRef_Carry:	;[dc]
	dw GfxPtr_Carry
GfxRef_AtomicFire:	;[dc]
	dw GfxPtr_AtomicFire
GfxRef_TimeStopper:	;[dc]
	dw GfxPtr_TimeStopper
GfxRef_QuickBoomerang:	;[dc]
	dw GfxPtr_QuickBoomerang
GfxRef_BubbleLead:	;[dc]
	dw GfxPtr_BubbleLead
GfxRef_MirrorBuster:	;[dc]
	dw GfxPtr_MirrorBuster

GfxRef_HealthBar:	;[?]
	dw GfxPtr_HealthBar
GfxRef_HUD:	;[?]
	dw GfxPtr_HUD
GfxRef_StageSelect:
	dw GfxPtr_StageSelect
Ptr_00_0307:
	dw GfxPtr_ObjType01
Ptr_00_0309:
	dw GfxPtr_ObjType02
Ptr_00_030B:
	dw GfxPtr_ObjType03
Ptr_00_030D:
	dw GfxPtr_ObjType04
Ptr_00_030F:
	dw GfxPtr_ObjType05
Ptr_00_0311:
	dw GfxPtr_ObjType06
Ptr_00_0313:
	dw GfxPtr_ObjType07
Ptr_00_0315:
	dw GfxPtr_ObjType08
Ptr_00_0317:
	dw GfxPtr_Fan
Ptr_00_0319:
	dw GfxPtr_ObjType10
Ptr_00_031B:
	dw GfxPtr_ObjType11
Ptr_00_031D:
	dw GfxPtr_ObjType12
Ptr_00_031F:
	dw GfxPtr_ObjType13
Ptr_00_0321:
	dw GfxPtr_ObjType14
Ptr_00_0323:
	dw GfxPtr_ObjType15
Ptr_00_0325:
	dw GfxPtr_ObjType16
Ptr_00_0327:
	dw GfxPtr_ObjType17
Ptr_00_0329:
	dw GfxPtr_ObjType18
Ptr_00_032B:
	dw GfxPtr_ObjType19
Ptr_00_032D:
	dw GfxPtr_AppearingBlock
Ptr_00_032F:
	dw GfxPtr_ObjType21
Ptr_00_0331:
	dw GfxPtr_ObjType22
Ptr_00_0333:
	dw GfxPtr_Icicle
Ptr_00_0335:
	dw GfxPtr_ObjType24
Ptr_00_0337:
	dw GfxPtr_ObjType25to28
Ptr_00_0339:
	dw GfxPtr_AtomicFireBlock
Ptr_00_033B:
	dw StagePtr_CutMan
Ptr_00_033D:
	dw StagePtr_IceMan
Ptr_00_033F:
	dw StagePtr_FireMan
Ptr_00_0341:
	dw StagePtr_ElecMan
GfxRef_TitleLogo:
	dw GfxPtr_TitleLogo
GfxRef_MenuFont:
	dw GfxPtr_MenuFont
GfxRef_TitleLogoTilemap:
	dw GfxPtr_TitleLogoTilemap
GfxRef_TitleScreenText:
	dw GfxPtr_TitleScreenText
GfxRef_GameOverText:
	dw GfxPtr_GameOverText
GfxRef_PasswordText:
	dw GfxPtr_PasswordText
GfxRef_EndingText:
	dw GfxPtr_EndingText
GfxRef_StageSelectBG:
	dw GfxPtr_StageSelectBG
GfxRef_StageSelectTopTilemap:
	dw GfxPtr_StageSelectTopTilemap
GfxRef_StageSelectBottomTilemap:
	dw GfxPtr_StageSelectBottomTilemap
GfxRef_WeaponGet:
	dw GfxPtr_WeaponGet
GfxRef_WeaponGetExtra:
	dw GfxPtr_WeaponGetExtra
GfxRef_WeaponGetTilemap:
	dw GfxPtr_WeaponGetTilemap
GfxRef_WilyCastle:
	dw GfxPtr_WilyCastle
GfxRef_WilyCastleExtra:
	dw GfxPtr_WilyCastleExtra
GfxRef_WilyCastleTilemap:
	dw GfxPtr_WilyCastleTilemap
GfxRef_SkullShip:
	dw GfxPtr_SkullShip
GfxRef_SkullShipTilemap:
	dw GfxPtr_SkullShipTilemap
GfxRef_WilyMachine:
	dw GfxPtr_WilyMachine
GfxRef_WilyMachinePhase1Tilemap:
	dw GfxPtr_WilyMachinePhase1Tilemap
GfxRef_WilyMachinePhase2Tilemap:
	dw GfxPtr_WilyMachinePhase2Tilemap
GfxRef_CutMan:
	dw GfxPtr_CutMan
GfxRef_BossRollingCutter:
	dw GfxPtr_BossRollingCutter
GfxRef_IceMan:
	dw GfxPtr_IceMan
GfxRef_BossIceSlasher:
	dw GfxPtr_BossIceSlasher
GfxRef_ElecMan:
	dw GfxPtr_ElecMan
GfxRef_ObjType35:
	dw GfxPtr_ObjType35
GfxRef_FireMan:
	dw GfxPtr_FireMan
GfxRef_BossFireStorm:
	dw GfxPtr_BossFireStorm
GfxRef_Enker:
	dw GfxPtr_Enker
GfxRef_ObjType39:
	dw GfxPtr_ObjType39
GfxRef_BubbleMan:
	dw GfxPtr_BubbleMan
GfxRef_BossBubbleLead:
	dw GfxPtr_BossBubbleLead
GfxRef_FlashMan:
	dw GfxPtr_FlashMan
GfxRef_HeatMan:
	dw GfxPtr_HeatMan
GfxRef_BossAtomicFire:
	dw GfxPtr_BossAtomicFire
GfxRef_QuickMan:
	dw GfxPtr_QuickMan
GfxRef_BossQuickBoomerang:
	dw GfxPtr_BossQuickBoomerang
GfxRef_WilyMachineParts:
	dw GfxPtr_WilyMachineParts
GfxRef_TeleporterLight:
	dw GfxPtr_TeleporterLight
GfxRef_BossDoor:
	dw GfxPtr_BossDoor
GfxRef_TeleportSystemSign:
	dw GfxPtr_TeleportSystemSign
GfxRef_StageSelectFireManTileList:
	dw GfxPtr_StageSelectFireManTileList
GfxRef_StageSelectCutManTileList:
	dw GfxPtr_StageSelectCutManTileList
GfxRef_StageSelectIceManTileList:
	dw GfxPtr_StageSelectIceManTileList
GfxRef_StageSelectElecManTileList:
	dw GfxPtr_StageSelectElecManTileList
GfxRef_StageSelectFireManFrames:
	dw GfxPtr_StageSelectFireManFrames
GfxRef_StageSelectCutManFrames:
	dw GfxPtr_StageSelectCutManFrames
GfxRef_StageSelectIceManFrames:
	dw GfxPtr_StageSelectIceManFrames
GfxRef_StageSelectElecManFrames:
	dw GfxPtr_StageSelectElecManFrames
GfxRef_StageSelectTopRowArc:
	dw GfxPtr_StageSelectTopRowArc
GfxRef_StageSelectBottomRowArc:
	dw GfxPtr_StageSelectBottomRowArc
Ptr_00_03AB:
	dw StagePtr_Wily1
Ptr_00_03AD:
	dw StagePtr_Wily2
Ptr_00_03AF:
	dw StagePtr_Wily3
Ptr_00_03B1:
	dw StagePtr_FireManAlt
Ptr_00_03B3:
	dw Ptr_0C_4000
Ptr_00_03B5:
	dw Ptr_0C_4002
Ptr_00_03B7:
	dw Ptr_0C_4004
Ptr_00_03B9:
	dw Ptr_0C_4006
Ptr_00_03BB:
	dw Ptr_0C_4008
Ptr_00_03BD:
	dw Ptr_0C_400A
Ptr_00_03BF:
	dw Ptr_0C_400C
Ptr_00_03C1:
	dw Ptr_0C_400E
