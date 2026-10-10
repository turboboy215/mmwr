;Mega Man: Dr. Wily's Revenge disassembly - the first Wily cutscene
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Castle Cutscene", ROMX[$4516], BANK[$B]

;Play a Wily cutscene. Saves SP in wShotSlots (the skip in the wait routines
;returns through it). wWilyProgress & $1F = $1F (before Wily 3): the skull-ship
;cutscene. Otherwise (before Wily 1) the first cutscene:
; - the stage select, all four portraits empty and Dr. Wily in the middle
;   (WilyStageSelectTilemap over the normal screen), StageSelect music, the
;   cursor round the middle slot blinking, until Start;
; - SFX_Shing and 120 frames of palette flashing. E is set to $E4 or 0 by the
;   frame count but never used: OBP0 and BGP get the counter itself (0-$10).
;   A missing `ld a, e`?	;[?]
; - WilySaucerScene, then CastleBeamDownScene.
;Then $DFCF = $FF, which makes the first cutscene skippable from now on.	;[ok]
PlayWilyCutscene:	;$4516
	ld hl, $0000
	add hl, sp
	ld a, l
	ld [wShotSlots], a
	ld a, h
	ld [wShotSlots + 1], a
	ld a, [wWilyProgress]
	and $1F
	cp $1F
	jp z, SkullShipCutscene
	call DisableLCD_0B
	call HideAllSpritesAlt_0B
	ld hl, JumpLoadStageSelectScreen
	call FarCallBank1_0B
	ld hl, WilyStageSelectTilemap
	ld de, $9800
	call CopyTilemap20x18_0B
	ld hl, WilyStageSelectTiles
	ld de, $8000
	ld bc, WilyStageSelectTilesEnd - WilyStageSelectTiles
	call JumpFill
	call InitSpriteSystem_0B
	call DrawWilyPortrait
	call DrawWilyStageCursor
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $E4
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
	xor a
	ld [$CCFC], a
	ld [wStageSelectTimer], a
	ld [wStageSelectFrame], a
	ld [wScreenCounter], a
	ldh [rOBP0], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	xor a
	ldh [rBGP], a
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ld a, $0A
	ld [wAudioBank], a
	ld a, $26	;bank $0A: StageSelect
	call JumpQueueSound
	ei
	ld a, $E4
	ldh [rBGP], a
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
.waitStart
	ld hl, JumpDelayFrame
	call FarCallBank1_0B
	call BlinkStageSelectCursor_0B
	ld hl, JumpReadJoypad
	call FarCallBank1_0B
	ldh a, [hJoypadPressed]
	bit 3, a
	jp z, .waitStart
	ld a, $00	;AudioStopAll
	call JumpCallBank1Routine
	ld a, $2B	;SFX_Shing
	call JumpQueueSound
	ld b, $78
.flash
	push bc
	call CastleCutsceneWaitFrame
	pop bc
	ld a, c
	cp $08
	ld e, $E4
	jr c, .setPalette
	ld e, $00
	cp $10
	jr c, .setPalette
	ld c, $FF
.setPalette
	ldh [rOBP0], a
	ld [wShadowBGP], a
	inc c
	dec b
	jr nz, .flash
	call WilySaucerScene
	call CastleBeamDownScene
	ld hl, $DFCF
	ld [hl], $FF
	ld a, $02
	ld [wAudioBank], a
	ret

;Mega Man beams down in front of Dr. Wily's castle: the castle screen fades in
;with WilyIntro; the beam drops from above the screen at X $20, accelerating
;($60/256 px a frame per frame, at most 16 px a frame) to Y $78; the warp frames;
;SFX_Land and the standing pose. When the music posts $E1 to SongCue (a track
;event, Audio2_EventCue - the scene waits on the song), 120 frames, the warp
;frames again, SFX_Teleport, the beam rises 16 px a frame off the top, 60
;frames, fade to white.	;[ok]
CastleBeamDownScene:	;$45F2
	ld a, $0A
	ld [wAudioBank], a
	ld a, $00	;AudioStopAll
	call JumpCallBank1Routine
	call CastleCutsceneWaitFrame
	call DisableLCD_0B
	call HideAllSpritesAlt_0B
	ld hl, JumpLoadWilyCastleScreen
	call FarCallBank1_0B
	ld hl, CastleSceneTiles
	ld de, $8000
	ld bc, CastleSceneTilesEnd - CastleSceneTiles
	call JumpFill
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ld a, $E0
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ld a, $27	;bank $0A: WilyIntro
	call JumpQueueSound
	ld b, $1E
	call CastleCutsceneWaitFrames
	ld b, $03
	call CastleCutsceneWaitFrames
	ld a, $FE
	ld [wShadowBGP], a
	ld b, $03
	call CastleCutsceneWaitFrames
	ld a, $F9
	ld [wShadowBGP], a
	ld b, $03
	call CastleCutsceneWaitFrames
	ld a, $E4
	ld [wShadowBGP], a
	ld hl, CastleBeamRecord
	ld de, wShotCount
	ld bc, $0007
	call JumpFill
	call InitSpriteSystem_0B
	ld a, $0A
	call JumpAllocSprite
	ld [wShotCount + $04], a
	xor a
	ld [wShotCount + $13], a
	ld [wShotCount + $14], a
	ld [SongCue], a
.fall
	call CastleCutsceneWaitFrame
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld de, $0060
	ld a, [wShotCount + $13]
	ld l, a
	ld a, [wShotCount + $14]
	ld h, a
	add hl, de
	ld a, h
	cp $11
	jr c, .gotSpeed
	ld h, $10
.gotSpeed
	ld d, h
	ld a, l
	ld [wShotCount + $13], a
	ld a, h
	ld [wShotCount + $14], a
	ld hl, wShotCount + $03
	ld a, [hl]
	add a, d
	ld [hl], a
	cp $E0
	jr nc, .fall
	cp $78
	jr c, .fall
	ld [hl], $78
	call StartTeleportFrames
.warpIn
	call CastleCutsceneWaitFrame
	call HideAllSpritesAlt_0B
	call StepTeleportFrames
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld a, [wTeleportState]
	cp $FF
	jr nz, .warpIn
	ld a, $08	;SFX_Land
	call JumpQueueSound
	ld a, LOW(MegaManStandMetasprite)
	ld [wShotCount + $05], a
	ld a, HIGH(MegaManStandMetasprite)
	ld [wShotCount + $06], a
.waitCue
	call CastleCutsceneWaitFrame
	call HideAllSpritesAlt_0B
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld hl, SongCue
	ld a, [hl]
	cp $E1
	jp nz, .waitCue
	ld b, $78
	call CastleCutsceneWaitFrames
	call StartTeleportFrames
.warpOut
	call CastleCutsceneWaitFrame
	call HideAllSpritesAlt_0B
	call StepTeleportFrames
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld a, [wTeleportState]
	cp $FF
	jr nz, .warpOut
	xor a
	ld [SongCue], a
	ld a, $21	;SFX_Teleport
	call JumpQueueSound
	ld a, LOW(TeleportBeamMetasprite)
	ld [wShotCount + $05], a
	ld a, HIGH(TeleportBeamMetasprite)
	ld [wShotCount + $06], a
.rise
	call CastleCutsceneWaitFrame
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld hl, wShotCount + $03
	ld a, [hl]
	add a, $F0
	ld [hl], a
	cp $96
	jr c, .rise
	cp $D0
	jr nc, .rise
	ld [hl], $00
	ld b, $3C
	call CastleCutsceneWaitFrames
	call FadeToWhite_0B
	ld b, $04
	call CastleCutsceneWaitFrames
	ret

;Fade BGP to white: $E4, $90, $40, $00, 6 frames apart.	;[ok]
FadeToWhite_0B:	;$4741
	ld a, $E4
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $90
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $40
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $00
	ld [wShadowBGP], a
	ret

;Fade BGP to black: $E4, $F9, $FE, $FF, 6 frames apart.	;[ok]
FadeToBlack_0B:	;$4765
	ld a, $E4
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $F9
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $FE
	ld [wShadowBGP], a
	ld b, $06
	call CastleCutsceneWaitFrames
	ld a, $FF
	ld [wShadowBGP], a
	ret

;Start the warp frames: wTeleportState = 1, its counter $DFCD = 0 - Mega Man's
;teleport RAM, reused.	;[ok]
StartTeleportFrames:	;$4789
	ld a, $01
	ld [wTeleportState], a
	xor a
	ld [$DFCD], a
	ret

;Step the warp frames and point the beam record's metasprite at the frame;
;wTeleportState = $FF when done.	;[ok]
StepTeleportFrames:	;$4793
	call GetTeleportFrame
	jr nc, .store
	ld a, $FF
	ld [wTeleportState], a
.store
	ld a, e
	ld [wShotCount + $05], a
	ld a, d
	ld [wShotCount + $06], a
	ret

;Count $DFCD up: DE = TeleportWarpMetasprite1 for counts 1-3,
;TeleportWarpMetasprite2 for 4-7, TeleportBeamMetasprite for 8-11; carry at
;12.	;[ok]
GetTeleportFrame:	;$47A6
	ld hl, $DFCD
	inc [hl]
	ld a, [hl]
	ld de, TeleportWarpMetasprite1
	cp $04
	jr c, .notDone
	ld de, TeleportWarpMetasprite2
	cp $08
	jr c, .notDone
	ld de, TeleportBeamMetasprite
	cp $0C
	jr c, .notDone
	scf
	ret
.notDone
	or a
	ret

;The castle scene's metasprites, tile base 0 (CastleSceneTiles).
;Mega Man standing (the free tile is the top of his helmet).	;[ok]
MegaManStandMetasprite:	;$47C4
	db $F4, $F4, $33	;dx, dy, 3x3
	db $02, $03, $04, $05, $06, $07, $08, $09, $0A
	db $08, $F8, $01
	db $80

;The teleport beam.	;[ok]
TeleportBeamMetasprite:	;$47D4
	db $FC, $EC, $14	;dx, dy, 1x4
	db $0B, $0B, $0B, $0B
	db $80

;Two frames of the beam turning into Mega Man (or back).	;[ok]
TeleportWarpMetasprite1:	;$47DC
	db $F4, $E7, $34	;dx, dy, 3x4
	db $FF, $0E, $FF, $0D, $0E, $8D, $0D, $0E, $8D, $0C, $0F, $8C
	db $80

TeleportWarpMetasprite2:	;$47EC
	db $F4, $EC, $32	;dx, dy, 3x2
	db $0D, $0E, $8D, $0C, $0F, $8C
	db $80

;17 sprite tiles for the castle scene: Mega Man, the beam (tiles 11-15 are
;also bank $04's Mega Man tiles 103-107), and in tile 0 the saucer dot that
;SkullShipCutscene uses.	;[ok]
CastleSceneTiles:	;$47F6
	INCBIN "gfx/cutscenes/castle_mega_man.2bpp"
CastleSceneTilesEnd:

;Initial sprite records for the saucer scene (copied to wShotCount, +$08,
;+$16) and the castle scene. Named by what they show.	;[ok]
SaucerDomeRecord:	;$4906
	db $00, $42, $C8, $46, $00	;attributes, tile base, X, Y, sprite handle
	dw SaucerDomeMetasprite	;metasprite

SaucerBaseRecord:	;$490D
	db $00, $42, $C8, $5E, $00	;attributes, tile base, X, Y, sprite handle
	dw SaucerBaseMetasprite1	;metasprite

SaucerWilyRecord:	;$4914
	db $10, $08, $C8, $00, $00	;attributes, tile base, X, Y, sprite handle
	dw SaucerWilyMetasprite1	;metasprite

CastleBeamRecord:	;$491B
	db $00, $00, $20, $E8, $00	;attributes, tile base, X, Y, sprite handle
	dw TeleportBeamMetasprite	;metasprite
