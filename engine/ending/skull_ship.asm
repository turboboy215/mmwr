;Mega Man: Dr. Wily's Revenge disassembly - the ending: scene 1, the skull ship
;Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Ending Skull Ship", ROMX[$455B], BANK[$E]

;Scene 1. Sound off (CallBank1Routine 0), LCD off, the skull ship screen
;(JumpLoadSkullShipScreen), this scene's sprite tiles, 8x16 sprites; fade
;in, then run until FadeOutSkullShip has blacked the screen out and all four
;explosion groups have stopped ($CC02 = $1F), and go on to the roll call.
;$CC00/$CC01 count frames from the start of the scene.	;[ok]
SkullShipScene:	;$455B
	ld a, $00
	call JumpCallBank1Routine
	di
	call DisableLCD_0E
	ld a, [wShadowLCDC]
	and $7F
	ld [wShadowLCDC], a
	call HideAllSpritesAlt_0E
	ld a, $0A
	ld [wAudioBank], a
	ld hl, JumpLoadSkullShipScreen
	call FarCallBank1_0E
	ld hl, SkullShipSpriteTiles
	ld de, VRAM_TILES0
	ld bc, SkullShipSpriteTilesEnd - SkullShipSpriteTiles
	call JumpFill
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	ld a, $87
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	ei
	call FadeInBG_0E
	ld a, $90
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
	call InitSkullShipScene
	xor a
	ld [$CC00], a
	ld [$CC01], a
.l45BC
	call PasswordWaitFrame_0E
	call JumpBeginSpriteFrame
	call JumpReadJoypad
	call UpdateExplosionGroup0
	call UpdateExplosionGroup1
	call UpdateExplosionGroup2
	call UpdateExplosionGroup3
	call UpdateSkullShipCraft
	call FadeOutSkullShip
	ld a, [$CC00]
	ld l, a
	ld a, [$CC01]
	ld h, a
	inc hl
	ld a, l
	ld [$CC00], a
	ld a, h
	ld [$CC01], a
	ld a, [$CC02]
	cp $1F
	jr nz, .l45BC
	jp RollCallScene

;From frame 300: move the small craft (record $C700) left a pixel a frame
;and draw SkullShipCraftFrame, until its X wraps into $A0-$DF (off the left
;edge).	;[ok]
UpdateSkullShipCraft:	;$45F2
	ld a, [$CC00]
	sub $2C
	ld a, [$CC01]
	sbc a, $01
	ret c
	ld hl, $C700
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $E0
	jr nc, .l460D
	cp $A0
	ret nc
.l460D
	add a, $FF
	ld [hl+], a
	ldh [$FFA2], a
	inc l
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	ld hl, SkullShipCraftFrame
	call JumpDrawMetasprite
	ret

;Until $CC02 is set: every 10 frames ($CC06) count $CC03 up; BGP $E4 for
;120 frames, then $F9, $FE and $FF (black) 120 frames each; on black set
;$CC02 = $10, which tells the explosion groups to stop.	;[ok]
FadeOutSkullShip:	;$4622
	ld a, [$CC02]
	or a
	ret nz
	ld hl, $CC06
	dec [hl]
	jr nz, .l4633
	ld [hl], $0A
	ld hl, $CC03
	inc [hl]
.l4633
	ld hl, $CC03
	ld a, [hl]
	cp $0C
	ld e, $E4
	jr c, .l4650
	cp $18
	ld e, $F9
	jr c, .l4650
	cp $24
	ld e, $FE
	jr c, .l4650
	ld e, $FF
	ld a, $10
	ld [$CC02], a
.l4650
	ld a, e
	ld [wShadowBGP], a
	ret

;Sound $02 (the enemy explosion's) on every 128th frame, or at random
;(RNG < $18) on other frames.	;[ok]
PlayRandomExplosionSound:	;$4655
	ld a, [wFrameCounter]
	and $7F
	jr z, .l4664
	ld e, $18
	call JumpRNG
	cp e
	jr nc, .l4669
.l4664
	ld a, $02
	call JumpQueueSound
.l4669
	ret

;The four explosion groups, records $C600/$C640/$C680/$C6C0. Group 0
;also plays the random explosion sound once the explosions have begun
;($CC05) and until the fade is done.	;[ok]
UpdateExplosionGroup0:	;$466A
	ld a, [$CC05]
	or a
	jr z, .l4677
	ld a, [$CC02]
	or a
	call z, PlayRandomExplosionSound
.l4677
	ld hl, $C600
	jr UpdateExplosionGroup

UpdateExplosionGroup1:	;$467C
	ld hl, $C640
	jr UpdateExplosionGroup

UpdateExplosionGroup2:	;$4681
	ld hl, $C680
	jr UpdateExplosionGroup

UpdateExplosionGroup3:	;$4686
	ld hl, $C6C0

;Explosion group C: wait for its start delay (offset $27); then, once the
;screen is black ($CC02), stop at the end of its cycle - set its bit
;(ExplosionGroupBits by group number, offset $09) in $CC02 and play sound
;$02 - or else animate (SkullShipExplosionAnim) and draw.	;[ok]
UpdateExplosionGroup:	;$4689
	ld c, l
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4694
	dec [hl]
	ret
.l4694
	ld a, $01
	ld [$CC05], a
	ld a, [$CC02]
	or a
	jr z, .l46C9
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l46C9
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $FF
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	add a, LOW(ExplosionGroupBits)
	ld e, a
	ld a, $00
	adc a, HIGH(ExplosionGroupBits)
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [$CC02]
	or e
	ld [$CC02], a
	ld a, $02
	call JumpQueueSound
	ret
.l46C9
	ld de, SkullShipExplosionAnim
	call AnimateObjectGetFrame_0E
	call DrawExplosionGroup
	ret

;Group number -> its bit in $CC02.	;[ok]
ExplosionGroupBits:	;$46D3
	db $01, $02, $04, $08, $10, $20, $40, $80

;Draw explosion group C's current frame four times, at the group's four
;positions in ExplosionGroupPositions, with the sprite handles at offsets
;$28-$2B.	;[ok]
DrawExplosionGroup:	;$46DB
	xor a
	ld [$D3EA], a
	ld [$CE55], a
	ld [$CE57], a
	ld a, $28
	add a, c
	ld l, a
	push hl
	ld a, $09
	add a, c
	ld l, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, ExplosionGroupPositions
	add hl, de
	pop de
	ld b, $04
.l46FB
	push bc
	ld a, [hl+]
	ldh [$FFA2], a
	ld a, [hl+]
	ldh [$FFA3], a
	push hl
	ld a, [$CE53]
	ld l, a
	ld a, [$CE54]
	ld h, a
	ld a, [de]
	inc e
	push de
	call DrawMetasprite16_0E
	pop de
	pop hl
	pop bc
	dec b
	jr nz, .l46FB
	ret

;Four (x, y) positions per explosion group, 8 bytes a group.	;[ok]
ExplosionGroupPositions:	;$4718
	db $28, $40, $48, $50, $58, $20, $78, $40	;group 0: (x, y) x 4
	db $38, $20, $38, $50, $58, $40, $68, $60	;group 1: (x, y) x 4
	db $28, $60, $48, $40, $58, $60, $68, $30	;group 2: (x, y) x 4
	db $38, $40, $48, $66, $68, $70, $88, $60	;group 3: (x, y) x 4

;Set up scene 1: the sprite system, the four explosion groups (start delays
;60, 68, 76 and 84 frames) and the craft at (64, 96) with a 10-entry sprite.	;[ok]
InitSkullShipScene:	;$4738
	xor a
	ld [$CC02], a
	ld [$CC05], a
	call InitSpriteSystem_0E
	ld e, $3C
	ld d, $00
	ld hl, $C600
	call InitExplosionGroup
	ld e, $44
	ld d, $01
	ld hl, $C640
	call InitExplosionGroup
	ld e, $4C
	ld d, $02
	ld hl, $C680
	call InitExplosionGroup
	ld e, $54
	ld d, $03
	ld hl, $C6C0
	call InitExplosionGroup
	ld hl, $C700
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld a, $40
	ld [hl+], a
	inc l
	ld a, $60
	ld [hl+], a
	ld l, c
	push hl
	ld a, $0A
	call JumpAllocSprite
	ld b, a
	pop hl
	ld c, l
	ld a, $10
	add a, c
	ld l, a
	ld [hl], b
	ld a, $0A
	ld [$CC06], a
	xor a
	ld [$CC03], a
	ld [$CC07], a
	ret

;Explosion group at HL: start delay E, group number D, four sprite handles
;of four OAM entries each at offsets $28-$2B.	;[ok]
InitExplosionGroup:	;$4795
	ld c, l
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld a, $09
	add a, c
	ld l, a
	ld [hl], d
	ld b, $04
	ld a, $28
	add a, c
	ld l, a
.l47A6
	push hl
	push bc
	ld a, $04
	call JumpAllocSprite
	pop bc
	pop hl
	ld [hl+], a
	dec b
	jr nz, .l47A6
	ret

;The explosion: frames 0-7, four frames each.	;[ok]
SkullShipExplosionAnim:	;$47B4
	dw SkullShipExplosionFrames
	db 4	;frames per step
	db $00, $01, $02, $03, $04, $05, $06, $07, $FF

;8x16 metasprites (DrawMetasprite16_0E format, no hitbox).	;[ok]
SkullShipExplosionFrames:	;$47C0
	dw SkullShipExplosionFrame0, SkullShipExplosionFrame1, SkullShipExplosionFrame2, SkullShipExplosionFrame3
	dw SkullShipExplosionFrame4, SkullShipExplosionFrame5, SkullShipExplosionFrame6, SkullShipExplosionFrame7

SkullShipExplosionFrame0:	;$47D0
	db $F8, $F8, $21	;dx, dy, 2x1
	db $10, $12
	db $80

SkullShipExplosionFrame1:	;$47D6
	db $F8, $F8, $21	;dx, dy, 2x1
	db $14, $16
	db $80

SkullShipExplosionFrame2:	;$47DC
	db $F8, $F8, $21	;dx, dy, 2x1
	db $18, $1A
	db $80

SkullShipExplosionFrame3:	;$47E2
	db $F8, $F8, $21	;dx, dy, 2x1
	db $1C, $1E
	db $80

SkullShipExplosionFrame4:	;$47E8
	db $F8, $F8, $21	;dx, dy, 2x1
	db $20, $22
	db $80

SkullShipExplosionFrame5:	;$47EE
	db $F8, $F8, $21	;dx, dy, 2x1
	db $24, $26
	db $80

SkullShipExplosionFrame6:	;$47F4
	db $F8, $F8, $21	;dx, dy, 2x1
	db $28, $2A
	db $80

SkullShipExplosionFrame7:	;$47FA
	db $F8, $F8, $21	;dx, dy, 2x1
	db $2C, $2E
	db $80

;The small craft that flies off left in scene 1 (tiles $0C/$0E).	;[ok]
SkullShipCraftFrame:	;$4800
	db $F8, $F8, $21	;dx, dy, 2x1
	db $0C, $0E
	db $80

;Scene 1's sprite tiles at $8000: a large and a small craft ($00-$0F; only
;$0C/$0E are drawn), then the explosion frames ($10-$2F).	;[ok]
SkullShipSpriteTiles:	;$4806
	INCBIN "gfx/ending/skull_ship_sprites.2bpp"
SkullShipSpriteTilesEnd:
