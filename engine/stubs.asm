;Mega Man: Dr. Wily's Revenge disassembly - the $0150 jump-stub table
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Jump Stubs", ROM0[$0150]

;$0150: a table of three-byte `jp` stubs, so code in any bank can reach ROM0
;routines at fixed addresses. The first one is where the header jumps.
Start::	;$0150
	jp Init
JumpFireEnemyShot::	;$0153
	jp FireEnemyShot
JumpCheckSolidPoint::	;$0156, used by the object banks
	jp CheckSolidPoint
JumpRNG::	;called by the audio engine in banks $02/$0A
	jp FuncRNG
JumpNegateDE::	;$015C
	jp NegateDE
JumpGetTablePointer::	;$015F
	jp GetTablePointer
JumpFill::	;called by the audio engine in banks $02/$0A
	jp FuncFill
JumpCopyVRAM::	;$0165
	jp CopyVRAM
JumpLoadFontTiles::	;$0168
	jp LoadFontTiles
JumpFuncMemset::	;$016B
	jp FuncMemset
JumpQueueSound::	;$016E
	jp QueueSound
JumpSpawnExplosionBurst::	;$0171
	jp SpawnExplosionBurst
JumpAllocObjectSlot::	;$0174
	jp AllocObjectSlot
JumpFreeObjectSlot::	;$0177
	jp FreeObjectSlot
JumpAllocSprite::	;$017A
	jp AllocSprite
JumpFreeSprite::	;$017D
	jp FreeSprite
JumpDrawMetasprite::	;$0180
	jp DrawMetasprite
JumpAddSolidBox::	;$0183, used by the object banks
	jp AddSolidBox
JumpDrawMetaspriteList::	;$0186
	jp DrawMetaspriteList
JumpLineStepInit::	;$0189
	jp LineStepInit
JumpLineStep::	;$018C
	jp LineStep
JumpLoadWilyCastleScreen::	;$018F
	jp LoadWilyCastleScreen
JumpLoadSkullShipScreen::	;$0192
	jp LoadSkullShipScreen
JumpLoadWilyMachinePhase1Screen::	;$0195
	jp LoadWilyMachinePhase1Screen
JumpLoadWilyMachinePhase2Screen::	;$0198
	jp LoadWilyMachinePhase2Screen
JumpLoadStageSelectScreen::	;$019B
	jp LoadStageSelectScreen
JumpDelayFrame::	;$019E
	jp DelayFrame
JumpReadJoypad::	;$01A1
	jp ReadJoypad
JumpCallBank1Routine::	;$01A4
	jp CallBank1Routine
JumpPlayStage::	;$01A7
	jp PlayStage
JumpLoadRestartPoint::	;$01AA
	jp LoadRestartPoint
JumpCheckShotHit::	;$01AD, used by bank $0D (the Wily Machine's cannon shot)
	jp CheckShotHit
JumpBeginSpriteFrame::	;$01B0, used by the ending (bank $0E)
	jp BeginSpriteFrame
JumpLoadSkullShipScreenAlt:	;$01B3, nothing calls it
	jp LoadSkullShipScreenAlt
JumpCallBank1Routine2::	;$01B6
	jp CallBank1Routine
