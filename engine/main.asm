;Mega Man: Dr. Wily's Revenge disassembly - main game flow
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Game Flow", ROM0[$0855]

;$0855: start a fresh game. Gives Mega Man the buster, clears progress and
;the scroll, runs the title screen (bank $01 $60AF) and the screen after it,
;then falls into the main flow: pick a stage, play it, repeat. The soft reset in
;ReadJoypad lands just before this, at $0605.	;[ok]
NewGame::	;$0855
	ld a, $01
	ld [wWeaponsUnlocked1], a
	xor a
	ld [wWeaponsUnlocked2], a
	ld [wCurrentWeapon], a
	ld sp, STACK_TOP
	call ClearRamCode
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	ld [wWilyStageSet], a
	ld [wBossesDefeated], a
	ld [wWilyProgress], a
	ld [wHubTeleporter], a
	ld [wScreenCounter], a
	ld a, $FF
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld [$DF9F], a
	ld a, $02
	ld [wAudioBank], a
	call AudioInit
	call TitleScreen
	call ClearNoDamageFlag
	ldh a, [hJoypadHeld]
	ld [$DFD1], a
	call CheckPasswordEntry
	ld a, [wBossesDefeated]
	push af
	call ResetGameState
	pop af
	ld [wBossesDefeated], a
.nextStage
	xor a
	ld [wRestartPoint], a
	ld [wScreenCounter], a
	ld [$C100], a
	ld [$DFC9], a
	ld a, $01
	ld [$DCD0], a
.pickStage
	ld a, [wBossesDefeated]
	and $0F
	cp $0F
	jr z, .wilyCastle
	xor a
	ld [wWilyStageSet], a
	ld a, [$DCD0]
	or a
	call nz, StageSelect
	jp .enterStage
.wilyCastle
	ld a, $01
	ld [wWilyStageSet], a
	ld a, [wWilyProgress]
	bit 7, a
	jr nz, .laterWilyStage
	ld a, [$DCD0]
	or a
	jr z, .l08F7
	ld a, $0B
	bankswitch
	call $4000
	ld a, $01
	bankswitch
.l08F7
	ld a, $01
	ld [wSelectedStage], a
	jr .enterStage

;Wily 1 cleared (wWilyProgress bit 7): Wily 2 from restart point 0, or 1 when
;the low five bits are $0F; Wily 3 once they are $1F (all five hub bosses),
;after the bank $0B cutscene when $DCD0 is set, with $DFC9 = $FF from restart
;point 3 on.	;[ok]
.laterWilyStage	;$08FE
	ld a, [wWilyProgress]
	and $1F
	cp $1F
	jr z, .l091A
	cp $0F
	jr z, .l090E
	xor a
	jr .l0910
.l090E
	ld a, $01
.l0910
	ld [wRestartPoint], a
	ld a, $02
	ld [wSelectedStage], a
	jr .enterStage
.l091A
	ld a, [$DCD0]
	or a
	jr z, .l0933
	ld a, $0B
	bankswitch
	call $4000
	ld a, $01
	bankswitch
.l0933
	ld a, $03
	ld [wSelectedStage], a
	ld a, [wRestartPoint]
	cp $03
	jr c, .l0944
	ld a, $FF
	ld [$DFC9], a
.l0944
	jr .enterStage
.enterStage
	xor a
	ld [$DF94], a
	call AudioStopAll
	call DisableLCD
	ld a, [wShadowLCDC]
	and $7B
	ld [wShadowLCDC], a
	call LoadTitleScreen
	call ResetAndLoadStage
	ld hl, $DFC9
	ld a, [hl]
	or a
	jr z, .l096C
	ld [hl], $00
	ld [wShadowBGP], a
	ldh [rBGP], a
.l096C
	call HideAllSpritesAlt

;$096F: enter the selected stage and run it. Sets palettes and interrupts
;(VBlank + STAT), starts the stage's music from StageMusicTab, then runs the
;per-frame loop until wStageState says something happened:
;  0  keep playing
;  1  boss room entered - switch to Audio1_Boss
;  2  boss beaten - BossDefeated plays the victory jingle, sets the timer, -> 3
;  3  count wVictoryTimer down, then mark the boss defeated and move on
;Clearing the third Wily stage leaves for the ending in bank $0E.	;[ok]
PlayStage::	;$096F
	xor a
	ld [wFreezeFlags], a
	ld a, $01
	bankswitch
	call AudioInit
	call InitHitboxViewer
	xor a
	ldh [rBGP], a
	ld [wShadowBGP], a
	ld [$DF9F], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $03
	ldh [rIE], a
	call EnableLCD
	ei
	call AudioInit
	ld a, $02
	ld [wAudioBank], a
	ld e, $00
	ld a, [wWilyStageSet]
	or a
	jr z, .l09AB
	ld e, $04
.l09AB
	ld a, [wSelectedStage]
	add a, e
	add a, a
	ld hl, StageMusicTab - 2		;one-based, like StageLoadTab
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [wAudioBank]
	bankswitch
	call TripleDeref
	ld a, $01
	bankswitch
	xor a
	call AudioLoadSong
	ld [wMusicSlot], a
	call DelayFrame
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $1C
	ldh [rOBP0], a
	ld a, $C4
	ldh [rOBP1], a
	ld a, $E4
	ld [$DF9F], a
	ld a, $C2
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	jr StageFrameLoop.firstFrame

;$09F5: stage music, indexed one-based from StageMusicTab - 2 by the same stage
;number LoadStage uses. Each entry is a pointer into AudioSoundTabPtrs, which
;FetchSongPointer-style double indirection turns into the song's data in the
;audio bank. Resolved against bank $02's SoundTab:	;[ok]
;  1-4  CutMan, IceMan, ElecMan, FireMan       (SoundTab 20-23)
;  5-6  Wily1 - the first two Wily stages share it   (SoundTab 33)
;  7    Wily2                                         (SoundTab 36)
;  8    SoundTab 39, one of the DoNotUse labels that fall through into
;       Audio1_EndGameAlt. No path in this code ever selects stage 8: the Wily
;       branch only sets stages 1-3, and clearing the third goes to the ending.
StageMusicTab::
	dw AudioSoundTabPtrs + 2 * 20, AudioSoundTabPtrs + 2 * 21
	dw AudioSoundTabPtrs + 2 * 22, AudioSoundTabPtrs + 2 * 23
	dw AudioSoundTabPtrs + 2 * 33, AudioSoundTabPtrs + 2 * 33
	dw AudioSoundTabPtrs + 2 * 36, AudioSoundTabPtrs + 2 * 39

;$0A05: one frame of a stage. PlayStage enters at .firstFrame; every later
;frame starts here.	;[ok]
StageFrameLoop::	;$0A05
	call DelayFrameWithSprites
	ld hl, $DF86
	inc [hl]
	inc hl
	dec [hl]
	call UpdatePlayer
	ld a, [$D869]
	or a
	jr nz, StageFrameLoop
	call wHookB
	call SetPlayerHitbox
	call UpdateSpawnWindow
	call UpdateObjects
	call UpdateEnemyShots
	call UpdateExplosions
	call UpdateItems
	call UpdateHUD
.firstFrame
	call UpdateRestartPoint
	ld a, [wStageBank]
	bankswitch
	call wStageHook
	ld a, $01
	bankswitch
	call CheckRoomExits
	ld a, [wStageState]
	or a
	jp z, StageFrameLoop
	dec a
	jp z, .bossFight
	dec a
	jp z, BossDefeated
	ld a, [wVictoryTimer]
	ld l, a
	ld a, [wVictoryTimer + 1]
	ld h, a
	ld a, h
	and $1F
	or l
	jr z, .stageCleared
	dec hl
	ld a, l
	ld [wVictoryTimer], a
	ld a, h
	ld [wVictoryTimer + 1], a
	jp StageFrameLoop
.stageCleared
	xor a
	ld [$DFD4], a
	ld a, [wWilyStageSet]
	ld e, $00
	or a
	jr z, .l0A80
	ld e, $04
.l0A80
	ld a, [wBossesDefeated]
	ld b, a
	ld a, [wSelectedStage]
	dec a
	and $03
	add a, e
	ld e, a
	ld d, $00
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	or b
	ld [wBossesDefeated], a
	ld a, e
	cp $06
	jp z, .ending
	call AudioStopAll
	call WeaponGet
	call AudioStopAll
	ld a, $0C
	bankswitch
	ld a, $0A
	ld [wAudioBank], a
	ld a, $2E
	call QueueSound
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	ld a, [wBossesDefeated]
	and $F0
	call z, ShowPasswordEntry
	call AudioStopAll
	ld a, $02
	ld [wAudioBank], a
	ld a, $01
	bankswitch
.afterStageClear
	ld a, $00
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ld [wFreezeFlags], a
	ld [$C100], a
	call ClearStageRAM
	ld a, [wBossesDefeated]
	and $0F
	cp $0F
	jr nz, .l0B02
	ld a, [wWilyProgress]
	cp $8F
	jr z, .l0AFD
	or a
	jr nz, .l0B00
.l0AFD
	call RefillWeaponEnergy
.l0B00
	jr .l0B05
.l0B02
	call RefillWeaponEnergy
.l0B05
	call AudioStopAll
	ld a, [wHubTeleporter]
	or a
	jr z, .l0B24
	ld b, a
	ld e, a
	ld d, $00
	ld hl, BitMasks - 1
	add hl, de
	ld e, [hl]
	ld a, [wWilyProgress]
	or e
	ld [wWilyProgress], a
	ld a, b
	cp $05

	jp nz, NewGame.nextStage
.l0B24
	ld a, $98
	ld [wEnergy], a
	xor a
	ld [wCurrentWeapon], a
	jp NewGame.nextStage
.ending
	ld a, $0E
	bankswitch
	jp $4000
.bossFight
	ld hl, AudioSoundTabPtrs + 2 * 24	;SoundTab 24, Audio1_Boss
	call FetchSongPointer
	xor a
	call AudioLoadSong
	ld [wMusicSlot], a
	jp StageFrameLoop

;$0B4B: the boss is down. Play the victory jingle, then give the player
;$01E0 frames - eight seconds - before the stage ends.	;[ok]
BossDefeated::	;$0B4B
	ld a, $01
	ld [$DF41], a
	ld hl, AudioSoundTabPtrs + 2 * 25	;SoundTab 25, Audio1_Victory
	call FetchSongPointer
	call AudioLoadSound
	ld [wMusicSlot], a
	ld a, $03
	ld [wStageState], a
	ld a, $E0
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	jp StageFrameLoop

;$0B6E: HL points at an AudioSoundTabPtrs entry; page in the audio bank and
;follow it to the song's data, ready for AudioLoadSong. Also resets
;wStageState.	;[ok]
FetchSongPointer::	;$0B6E
	xor a
	ld [wStageState], a
	ld a, [wAudioBank]
	bankswitch
	call DoubleDeref
	ld a, $01
	bankswitch
	ret

;$0B87: wipe per-game state - the $33 bytes at $C100, all progress, every
;energy meter full, three lives.	;[ok]
ResetGameState::	;$0B87
	di
	ld bc, $0033
	ld hl, $C100
	xor a
	call FuncMemset
	ei
	ld a, $98
	ld [wEnergy], a
	call RefillWeaponEnergy
	xor a
	ld [wRestartPoint], a
	ld [wBossesDefeated], a
	ld [wWilyProgress], a
	ld [wHubTeleporter], a
	call $0CCC
	ret

;$0BAC: fill the ten weapon meters (wEnergy + 1 onward) to $98.	;[ok]
RefillWeaponEnergy::	;$0BAC
	ld a, $98
	ld hl, $DFA4
	ld bc, $000A
	call FuncMemset
	ret

;$0BB8: Mega Man died. Take a life; if any are left, refill health and
;restart from stage selection, otherwise run the game-over screen (bank $0C) and
;act on the player's choice.	;[ok]
LoseLife::	;$0BB8
	call AudioStopAll
	xor a
	ldh [rBGP], a
	ld [wShadowBGP], a
	ld [$DF9F], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld hl, wLives
	dec [hl]
	jr z, .gameOver
.l0BCE
	di
	call ClearStageRAM
	xor a
	ld [wFreezeFlags], a
	ld [$C100], a
	ld sp, STACK_TOP
	xor a
	ld [$DCD0], a
	ld [wHubTeleporter], a
	ld [wCurrentWeapon], a
	ld [wScreenCounter], a
	ld a, $98
	ld [wEnergy], a
	jp NewGame.pickStage
.gameOver
	call AudioStopAll
	ld a, $0C
	bankswitch
	ld a, $0A
	ld [wAudioBank], a
	ld a, $2E
	call QueueSound
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	call ShowPasswordEntry
	ld a, $01
	bankswitch
	call GameOverMenu
	ld a, $02
	ld [wAudioBank], a
	ld a, [$DFD3]
	or a
	jr nz, .l0C48
	xor a
	ld [wHubTeleporter], a
	ld hl, wWeaponsUnlocked1
	ld a, [hl]
	and $3F
	ld [hl+], a
	ld [hl], $00
	call $0CCC
	ld a, [wWilyProgress]
	or a
	jr z, .l0C45
	xor a
	ld [wWilyProgress], a
	ld a, $0F
	ld [wBossesDefeated], a
.l0C45
	jp StageFrameLoop.afterStageClear
.l0C48
	cp $01
	jp nz, Init
	call $0CCC
	xor a
	ld [wRestartPoint], a
	ld hl, wWilyProgress
	ld a, [hl]
	cp $9F
	jr z, .l0C69
	or a
	jr z, .l0C69
	ld [hl], $00
	ld hl, wWeaponsUnlocked1
	ld [hl], $3F
	inc hl
	ld [hl], $00
.l0C69
	call RefillWeaponEnergy
	jp .l0BCE

;$0C6F: if bit 0 of $CC00 is set (presumably PASS WORD chosen on the title
;menu; the menu code in bank $01 is not traced), run the
;password screen in bank $0C (EnterPassword, with the password music $2E), then
;rebuild wBossesDefeated from the weapon bits it leaves in wWeaponsUnlocked1. A
;rejected password leaves $C600 = 1, and this then resets the game outright
;with `jp $0000`. Confirmed in step 3.3 by disassembling bank $0C.	;[ok]
CheckPasswordEntry::	;$0C6F
	ld a, [$CC00]
	and $01
	ret z
	call AudioStopAll
	ld a, $0C
	bankswitch
	ld a, $0A
	ld [wAudioBank], a
	ld a, $2E
	call QueueSound
	call EnterPasswordEntry
	call AudioStopAll
	ld a, $02
	ld [wAudioBank], a
	ld a, $01
	bankswitch
	ld a, [$C600]
	cp $01
	jr nz, .l0CA7
	jp $0000
.l0CA7
	ld a, [wWeaponsUnlocked1]
	rrca
	ld b, a
	and $09
	ld c, a
	bit 1, b
	jr z, .l0CB5
	set 2, c
.l0CB5
	bit 2, b
	jr z, .l0CBB
	set 1, c
.l0CBB
	ld a, c
	ld [wBossesDefeated], a
	cp $0F
	jr nz, .l0CC8
	ld a, $3F
	ld [wWeaponsUnlocked1], a
.l0CC8
	ret





SetStartingLives: ; $CC9
	ld bc,$204
	ld a,3
	ld [wLives],a
	xor a
	ld [wCurrentWeapon],a
	ld [$DFD4],a
	call InitPlacedItems
	ret
