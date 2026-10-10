;Mega Man: Dr. Wily's Revenge disassembly - the first cutscene's saucer scene
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Wily Saucer Scene", ROMX[$4922], BANK[$B]

;Dr. Wily's saucer (named by the picture), on a dark grey screen: SFX_UFO; it
;drifts in from the right at 1/2 px a frame to X $50; 120 frames; the dome
;lifts 24 px, showing Wily; 60 frames; his face alternates between two frames
;12 times (laughing?); the dome closes; 30 frames; the saucer flies off to the
;left at 2 px a frame. Scratch: three sprite records (dome, base, Wily) at
;wShotCount, +$08, +$16; +$0F the base's 8-frame light toggle; +$10 the dome's
;lift; +$12 a sub-pixel accumulator; +$13/+$14 the saucer's X/Y; +$1E the face
;count; +$1F set once the dome starts to open.	;[ok]
WilySaucerScene:	;$4922
	ld a, $00	;AudioStopAll
	call JumpCallBank1Routine
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call DisableLCD_0B
	call HideAllSpritesAlt_0B
	call LoadSaucerSceneGfx
	ld hl, SaucerDomeRecord
	ld de, wShotCount
	ld bc, $0007
	call JumpFill
	ld hl, SaucerBaseRecord
	ld de, wShotCount + $08
	ld bc, $0007
	call JumpFill
	ld hl, SaucerWilyRecord
	ld de, wShotCount + $16
	ld bc, $0007
	call JumpFill
	call InitSpriteSystem_0B
	ld a, $10
	call JumpAllocSprite
	ld [wShotCount + $04], a
	ld a, $0A
	call JumpAllocSprite
	ld [wShotCount + $0C], a
	ld a, $09
	call JumpAllocSprite
	ld [wShotCount + $1A], a
	ld a, $02
	ld [wAudioBank], a
	ld a, $01	;bank $02: SFX_UFO
	call JumpQueueSound
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ld a, $E4
	ldh [rOBP0], a
	ld a, $C4
	ldh [rOBP1], a
	ld a, $AA
	ld [wShadowBGP], a
	xor a
	ld [wShotCount + $1F], a
	ld [wShotCount + $10], a
	ld a, $C8
	ld [wShotCount + $13], a
	ld a, $46
	ld [wShotCount + $14], a
.flyIn
	call SaucerSceneFrame
	ld hl, wShotCount + $12
	ld a, $80
	add a, [hl]
	ld [hl], a
	jr nc, .flyIn
	ld a, [wShotCount + $13]
	add a, $FF
	ld [wShotCount + $13], a
	cp $50
	jr nc, .flyIn
	ld b, $78
	call SaucerSceneWait
	xor a
	ld [wShotCount + $1E], a
	inc a
	ld [wShotCount + $1F], a
.openDome
	call SaucerSceneFrame
	ld hl, wShotCount + $12
	ld a, $FF
	add a, [hl]
	ld [hl], a
	jr nc, .openDome
	ld a, [wShotCount + $10]
	add a, $01
	ld [wShotCount + $10], a
	cp $18
	jr c, .openDome
	ld b, $3C
	call SaucerSceneWait
.laugh
	call SaucerSceneFrame
	ld hl, wShotCount + $12
	ld a, $19
	add a, [hl]
	ld [hl], a
	jr nc, .laugh
	ld a, [wShotCount + $1E]
	inc a
	ld [wShotCount + $1E], a
	cp $0C
	jr c, .laugh
	xor a
	ld [wShotCount + $1E], a
.closeDome
	call SaucerSceneFrame
	ld hl, wShotCount + $12
	ld a, $FF
	add a, [hl]
	ld [hl], a
	jr nc, .closeDome
	ld a, [wShotCount + $10]
	or a
	jr z, .domeShut
	add a, $FF
	ld [wShotCount + $10], a
	jr .closeDome
.domeShut
	ld b, $1E
	call SaucerSceneWait
.flyOut
	call SaucerSceneFrame
	ld hl, wShotCount + $12
	ld a, $FF
	add a, [hl]
	ld [hl], a
	jr nc, .flyOut
	ld a, [wShotCount + $13]
	add a, $FE
	ld [wShotCount + $13], a
	cp $D0
	jr z, .done
	cp $D1
	jr z, .done
	jr nz, .flyOut
.done
	ret

;Read the joypad until a button in B is held - no frame wait. Nothing calls
;it.	;[ok]
WaitForButtonHeld_0B:	;$4A41
	ld hl, JumpReadJoypad
	push bc
	call FarCallBank1_0B
	pop bc
	ldh a, [hJoypadHeld]
	and b
	jr z, WaitForButtonHeld_0B
	ret

;Draw the saucer and Wily, then wait a frame.	;[ok]
SaucerSceneFrame:	;$4A4F
	call DrawSaucer
	call DrawSaucerWily
	call CastleCutsceneWaitFrame
	ret

;SaucerSceneFrame B times.	;[ok]
SaucerSceneWait:	;$4A59
	push bc
	call SaucerSceneFrame
	pop bc
	dec b
	jr nz, SaucerSceneWait
	ret

;Draw the dome at the saucer's X, Y - lift, and the base 12 px lower, switching
;its frame every 8 frames; falls through to DrawSaucerWily.	;[ok]
DrawSaucer:	;$4A62
	ld a, [wShotCount + $13]
	ld [wShotCount + $02], a
	ld a, [wShotCount + $14]
	ld b, a
	ld a, [wShotCount + $10]
	sub b
	cpl
	inc a
	ld [wShotCount + $03], a
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld a, [wShotCount + $13]
	ld [wShotCount + $0A], a
	ld a, [wShotCount + $14]
	add a, $0C
	ld [wShotCount + $0B], a
	ld a, [wShotCount + $0F]
	inc a
	ld b, a
	and $0F
	cp $08
	ld a, b
	jr c, .gotCounter
	xor $10
	and $10
.gotCounter
	ld [wShotCount + $0F], a
	ld hl, SaucerBaseMetasprite2
	ld a, [wShotCount + $0F]
	and $10
	jr z, .gotFrame
	ld hl, SaucerBaseMetasprite1
.gotFrame
	ld a, l
	ld [wShotCount + $0D], a
	ld a, h
	ld [wShotCount + $0E], a
	ld hl, wShotCount + $08
	call DrawSpriteRecord_0B

;Draw Wily at the saucer's X + 4, Y: SaucerWilyMetasprite1, or on odd face
;counts once the dome is opening, SaucerWilyMetasprite2.	;[ok]
DrawSaucerWily:	;$4AB7
	ld a, [wShotCount + $1F]
	or a
	ld hl, SaucerWilyMetasprite1
	jr z, .gotFace
	ld a, [wShotCount + $1E]
	and $01
	ld hl, SaucerWilyMetasprite1
	jr z, .gotFace
	ld hl, SaucerWilyMetasprite2
.gotFace
	ld a, l
	ld [wShotCount + $1B], a
	ld a, h
	ld [wShotCount + $1C], a
	ld a, [wShotCount + $13]
	add a, $04
	ld [wShotCount + $18], a
	ld a, [wShotCount + $14]
	add a, $00
	ld [wShotCount + $19], a
	ld hl, wShotCount + $16
	jp DrawSpriteRecord_0B

;BG tiles $8800-$97FF all colour 3, BG map 0 cleared, SaucerTiles to $8420
;(sprite tiles $42-$51). The sprite tiles from $8000 are still the stage
;select's, so Wily is drawn from WilyStageSelectTiles.	;[ok]
LoadSaucerSceneGfx:	;$4AEB
	ld hl, $8800
	ld bc, $1000
	ld a, $FF
	call JumpFuncMemset
	ld hl, $9800
	ld bc, $0400
	xor a
	call JumpFuncMemset
	ld hl, SaucerTiles
	ld de, $8420
	ld bc, SaucerTilesEnd - SaucerTiles
	call JumpFill
	ret

;The saucer's frames, tile base $42, in the object-frame layout: the records
;point past the hitbox, which nothing reads. The dome; its top row is the four
;free-placed tiles.	;[ok]
SaucerDomeFrame:	;$4B0D
	db $E8, $17, $F8, $07	;hitbox (unused)
SaucerDomeMetasprite:	;$4B11
	db $E8, $F8, $62	;dx, dy, 6x2
	db $02, $03, $04, $84, $83, $82, $05, $06, $07, $87, $86, $85
	db $08, $F8, $00
	db $10, $F8, $01
	db $18, $F8, $81
	db $20, $F8, $80
	db $80

;The base, two frames of its lights.	;[ok]
SaucerBaseFrame1:	;$4B2D
	db $E8, $17, $FC, $03	;hitbox (unused)
SaucerBaseMetasprite1:	;$4B31
	db $E8, $FC, $61	;dx, dy, 6x1
	db $08, $09, $0A, $8A, $89, $88
	db $08, $08, $0E
	db $10, $08, $0F
	db $18, $08, $8F
	db $20, $08, $8E
	db $80

SaucerBaseFrame2:	;$4B47
	db $E8, $17, $FC, $03	;hitbox (unused)
SaucerBaseMetasprite2:	;$4B4B
	db $E8, $FC, $61	;dx, dy, 6x1
	db $0B, $0C, $0D, $8D, $8C, $8B
	db $08, $08, $0E
	db $10, $08, $0F
	db $18, $08, $8F
	db $20, $08, $8E
	db $80

;16 sprite tiles of the saucer, loaded to $8420.	;[ok]
SaucerTiles:	;$4B61
	INCBIN "gfx/cutscenes/wily_saucer.2bpp"
SaucerTilesEnd:
