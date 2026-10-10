;Mega Man: Dr. Wily's Revenge disassembly - the second Wily cutscene
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Skull Ship Cutscene", ROMX[$52F9], BANK[$B]

;The second cutscene, before Wily 3: the castle fades in; 60 frames; SFX_UFO;
;60 frames; a saucer, one tile, rises from the castle at X $50, Y $50 swaying
;from side to side (MoveSaucerDot) until it is off the top. Then
;SkullShipArrivalScene.	;[ok]
SkullShipCutscene:	;$52F9
	di
	call DisableLCD_0B
	ld a, [wShadowLCDC]
	and $7F
	ld [wShadowLCDC], a
	call HideAllSpritesAlt_0B
	ld a, $0A
	ld [wAudioBank], a
	ld hl, JumpLoadWilyCastleScreen
	call FarCallBank1_0B
	ld hl, CastleSceneTiles
	ld de, $8000
	ld bc, 1 * 16	;only the first tile, the saucer dot
	call JumpFill
	ld hl, SkullShipSceneTiles
	ld de, $8010
	ld bc, SkullShipSceneTilesEnd - SkullShipSceneTiles
	call JumpFill
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ei
	call SkullShipFadeIn
	ld b, $3C
	call SkullShipWaitFrames
	ld a, $01	;bank $0A: SFX_UFO
	call JumpQueueSound
	ld b, $3C
	call SkullShipWaitFrames
	ld a, $84
	ldh [rOBP0], a
	ld a, $C4
	ldh [rOBP1], a
	call InitSpriteSystem_0B
	ld hl, SaucerDotRecord
	ld de, wShotCount
	ld bc, $0007
	call JumpFill
	ld a, $01
	call JumpAllocSprite
	ld [wShotCount + $04], a
	xor a
	ld [wShotCount + $1D], a
.rise
	call SkullShipWaitFrame
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	call MoveSaucerDot
	jr nc, .rise
	jr SkullShipArrivalScene

;The saucer dot's sprite record.	;[ok]
SaucerDotRecord:	;$5386
	db $00, $00, $50, $50, $00	;attributes, tile base, X, Y, sprite handle
	dw SaucerDotMetasprite	;metasprite

;Fade to black and show the skull ship (LoadSkullShipScreen) still black, with
;seven twinkling stars; SFX_UFO. 60 frames, then the saucer dot rises from the
;bottom (X $50, Y $8F), swaying, until it is within 4 px of X $50 and above Y
;$50 - it reaches the ship. Sound off, WilyIntro, the ship fades in over 128
;frames, and the dot is moved off screen. When the music posts $E1 to
;SongCue, 120 frames; then $DFD0 = $FF (skippable from now on) and back.
;Scratch: the dot's record at wShotCount; +$08-$0E the stars' counters, seeded
;from JumpRNG; +$16 the fade counter; +$1D the sway index; +$1F a sub-pixel
;accumulator. $CC00 is a second sub-pixel accumulator here.	;[ok]
SkullShipArrivalScene:	;$538D
	call FadeToBlack_0B
	xor a	;AudioStopAll
	call JumpCallBank1Routine
	call SkullShipWaitFrame
	di
	call DisableLCD_0B
	ld hl, JumpLoadSkullShipScreen
	call FarCallBank1_0B
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ei
	ld a, $01	;SFX_UFO
	call JumpQueueSound
	call JumpRNG
	ld hl, wShotCount + $08
	ld b, $07
.seed
	ld [hl+], a
	rlc a
	dec b
	jr nz, .seed
	ld b, $3C
.stars
	push bc
	call SkullShipWaitFrame
	call TwinkleStars
	pop bc
	dec b
	jr nz, .stars
	ld a, $50
	ld [wShotCount + $02], a
	ld a, $8F
	ld [wShotCount + $03], a
	xor a
	ld [wShotCount + $1D], a
.flyIn
	call SkullShipWaitFrame
	call MoveSaucerDot
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	call TwinkleStars
	ld a, [wShotCount + $02]
	sub $50
	jr nc, .gotDistance
	cpl
	inc a
.gotDistance
	cp $04
	jr nc, .notThere
	ld a, [wShotCount + $03]
	cp $50
	jr c, .arrived
.notThere
	jr .flyIn
.arrived
	xor a	;AudioStopAll
	call JumpCallBank1Routine
	call SkullShipWaitFrame
	call TwinkleStars
	ld a, $27	;WilyIntro
	call JumpQueueSound
.fadeIn
	call SkullShipWaitFrame
	call TwinkleStars
	ld hl, wShotCount + $16
	inc [hl]
	ld a, [hl]
	ld b, a
	rlc a
	rlc a
	rlc a
	and $03
	ld e, a
	ld d, $00
	ld hl, SkullShipFadeInBGP
	add hl, de
	ld a, [hl]
	ld [wShadowBGP], a
	ldh [rBGP], a
	ld a, b
	cp $80
	jr c, .fadeIn
	ld a, $A0
	ld [wShotCount + $03], a
	ld hl, wShotCount
	call DrawSpriteRecord_0B
	ld a, $E4
	ld [wShadowBGP], a
	ldh [rBGP], a
.waitCue
	call SkullShipWaitFrame
	call TwinkleStars
	ld hl, SongCue
	ld a, [hl]
	cp $E1
	jp nz, .waitCue
	ld [hl], $00
	ld b, $78
.hold
	push bc
	call SkullShipWaitFrame
	call TwinkleStars
	pop bc
	dec b
	jr nz, .hold
	ld a, $FF
	ld [$DFD0], a
	ld a, $02
	ld [wAudioBank], a
	ret

;On every other call ($CC00 += $80): add the current SaucerDotWobble entry to
;the dot's X and step the index (0-$3F), and raise the dot 3/8 px (a pixel on
;each carry of +$1F += $60). Carry once it has gone off the top (Y $92-$EF).	;[ok]
MoveSaucerDot:	;$5473
	ld hl, $CC00
	ld a, [hl]
	add a, $80
	ld [hl], a
	ld a, [wShotCount + $1D]
	ld e, a
	jr nc, .notGone
	inc a
	cp $40
	jr c, .gotIndex
	xor a
.gotIndex
	ld [wShotCount + $1D], a
	ld d, $00
	ld hl, SaucerDotWobble
	add hl, de
	ld a, [hl]
	ld hl, wShotCount + $02
	add a, [hl]
	ld [hl+], a
	ld a, [wShotCount + $1F]
	add a, $60
	ld [wShotCount + $1F], a
	jr nc, .notGone
	dec [hl]
	ld a, [hl]
	cp $92
	jr c, .notGone
	cp $F0
	jr nc, .notGone
	scf
	ret
.notGone
	xor a
	ret

;The seven stars, as OAM entries.	;[ok]
SkullShipStars:	;$54AD
	db $20, $18, $01, $10	;Y, X, tile, attributes
	db $38, $1C, $01, $10	;Y, X, tile, attributes
	db $1C, $3C, $01, $10	;Y, X, tile, attributes
	db $22, $64, $01, $10	;Y, X, tile, attributes
	db $1E, $88, $01, $10	;Y, X, tile, attributes
	db $30, $8C, $01, $10	;Y, X, tile, attributes
	db $3A, $A0, $01, $10	;Y, X, tile, attributes
SkullShipHiddenStar:	;$54C9
	db $A0	;Y = $A0: hidden. The other three bytes are the code that follows

;Write the stars straight into shadow OAM entries 8-14 ($C020): each star's
;counter counts up every frame and the star shows when its bits 1-2 are clear,
;2 frames in 8; otherwise its entry is SkullShipHiddenStar.	;[ok]
TwinkleStars:	;$54CA
	ld a, $20
	ldh [hBank1CallIndex], a
	ld a, $C0
	ldh [$FF92], a
	xor a
.loop
	push af
	ld b, a
	ld l, a
	ld h, $00
	ld de, wShotCount + $08
	add hl, de
	inc [hl]
	ld a, [hl]
	and $06
	jr z, .visible
	ld hl, SkullShipHiddenStar
	jr .copy
.visible
	ld l, b
	ld h, $00
	add hl, hl
	add hl, hl
	ld de, SkullShipStars
	add hl, de
.copy
	ldh a, [hBank1CallIndex]
	ld e, a
	ldh a, [$FF92]
	ld d, a
	ld bc, $0004
	call JumpFill
	ld a, e
	ldh [hBank1CallIndex], a
	ld a, d
	ldh [$FF92], a
	pop af
	inc a
	cp $07
	jr c, .loop
	ret

;Wait one frame. Falls into the next with B = 1.	;[ok]
SkullShipWaitFrame:	;$5509
	ld b, $01

;Wait B frames; skippable with A or B once $DFD0 is set, as
;CastleCutsceneWaitFrames.	;[ok]
SkullShipWaitFrames:	;$550B
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1_0B
	call JumpReadJoypad
	pop bc
	ldh a, [hJoypadPressed]
	and $03
	jr nz, .pressed
	dec b
	jr nz, SkullShipWaitFrames
	ret
.pressed
	ld a, [$DFD0]
	or a
	ret z
	ld a, $02
	ld [wAudioBank], a
	ld a, [wShotSlots]
	ld l, a
	ld a, [wShotSlots + 1]
	ld h, a
	ld sp, hl
	ret

;Three sprite tiles to $8010 (tiles 1-3): stars, small to large. They are
;also bank $04's stage-select tiles 2, 4 and 6.	;[ok]
SkullShipSceneTiles:	;$5534
	INCBIN "gfx/cutscenes/skull_ship_stars.2bpp"
SkullShipSceneTilesEnd:

;Fade BGP in from black: $FE, $F9, $E4, 3 frames apart.	;[ok]
SkullShipFadeIn:	;$5564
	ld b, $03
	call SkullShipWaitFrames
	ld a, $FE
	ld [wShadowBGP], a
	ld b, $03
	call SkullShipWaitFrames
	ld a, $F9
	ld [wShadowBGP], a
	ld b, $03
	call SkullShipWaitFrames
	ld a, $E4
	ld [wShadowBGP], a
	ret

;BGP values for the skull ship's fade-in.	;[ok]
SkullShipFadeInBGP:	;$5583
	db $FF, $FE, $F9, $E4

;The saucer dot: tile 0, hitbox first.	;[ok]
SaucerDotFrame:	;$5587
	db $FC, $03, $FC, $03	;hitbox (unused)
SaucerDotMetasprite:	;$558B
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

;64 X offsets for the dot's sway, one every other frame.	;[ok]
SaucerDotWobble:	;$5590
	db 5, 5, 5, 4, 4, 4, 4, 3, 3, 3, 2, 2, 2, 1, 1, 0
	db 0, -1, -1, -2, -2, -2, -3, -3, -3, -4, -4, -4, -4, -5, -5, -5
	db -5, -5, -5, -4, -4, -4, -4, -3, -3, -3, -2, -2, -2, -1, -1, 0
	db 0, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5
