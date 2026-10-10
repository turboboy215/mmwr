;Mega Man: Dr. Wily's Revenge disassembly - object type 6, Bigeye
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Bigeye (type 6)", ROMX[$5CAC], BANK[$3]

;Bigeye (Will; the ending lists BIGEYE).	;[ok]
;Type 6, placed once each in Cut Man, Ice Man, Elec Man and Wily 1, three times
;in Wily 3. A big hopper: lands, sits in a short pose for 120 frames, rises to a
;tall pose for 12, then jumps at Mega Man (sound $1F) - a long low jump or, about
;40% of the time, a high one (BigeyeJumpVelocities). Falls with block collision,
;bouncing off walls. Removed off screen; frozen: no movement.	;[ok]
;Offset $19 is 1 in the short pose, and the collision pass skips shot damage
;while it is set, so it can only be hurt when tall.	;[?]
BigeyeRoutine:	;$5CAC
	ld a, b
	or a
	jr z, .l5CBD
	dec a
	jr z, .l5CC9
	dec a
	jr z, .l5CBA
	dec a
	jp z, .l5D5D
.l5CBA
	ld b, $00
	ret
.l5CBD
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $F9
	inc l
	ld [hl], $5D
	ld b, $01
	ret
.l5CC9
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5D5D
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5CDF
	call ObjFaceMegaManOnScreen_03
	ld d, $02
	jr .l5D4A
.l5CDF
	cp $01
	jr nz, .l5CF9
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $78
	jr c, .l5CF5
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
.l5CF5
	ld d, $00
	jr .l5D4A
.l5CF9
	call ObjFaceMegaManOnScreen_03
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0C
	jr c, .l5D48
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	call JumpRNG
	cp $99
	ld a, $00
	jr nc, .l5D16
	inc a
.l5D16
	ld b, h
	add a, a
	add a, a
	add a, LOW(BigeyeJumpVelocities)
	ld l, a
	ld a, $00
	adc a, HIGH(BigeyeJumpVelocities)
	ld h, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	ld h, b
	ld a, $24
	add a, c
	ld l, a
	bit 0, [hl]
	call nz, JumpNegateDE
	ld a, $1C
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ldh a, [hBank1CallIndex]
	ld [hl+], a
	ldh a, [$FF92]
	ld [hl+], a
	ld a, $1F
	call JumpQueueSound
.l5D48
	ld d, $02
.l5D4A
	push de
	call BigeyeMove
	pop de
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	add a, d
	ld d, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], d
.l5D5D
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	bit 1, a
	ld e, $00
	jr nz, .l5D6A
	ld e, $01
.l5D6A
	ld a, $19
	add a, c
	ld l, a
	ld [hl], e
	ld de, $D811
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	ld e, [hl]
	add a, [hl]
	ld d, a
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], d
	jp ObjCheckOnScreen_03

BigeyeJumpVelocities:	;$5D82
	db $00, $FF
	db $00, $FC
	db $A0, $FE
	db $00, $FD

BigeyeMove:	;$5D8A
	call ObjApplyGravity_03
	ld a, $1F
	add a, c
	ld l, a
	bit 7, [hl]
	jr z, .l5DA9
	ld a, [hl-]
	ld d, a
	ld e, [hl]
	ld a, $0E
	add a, c
	ld l, a
	ld a, [hl+]
	add a, e
	ld a, [hl+]
	adc a, d
	ld d, a
	ld a, [Frame_03_5E39 + 2]
	add a, d
	cp $90
	jr nc, .l5DEF
.l5DA9
	ld de, Frame_03_5E39
	call ObjMoveWithCollision_03
	jr z, .l5DF8
	bit 0, a
	jr z, .l5DC4
	ld a, $1C
	add a, c
	ld l, a
	ld a, [hl+]
	ld d, [hl]
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ld [hl], d
	dec l
	ld [hl], e
.l5DC4
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5DF8
	ldh a, [$FFB0]
	bit 1, a
	jr z, .l5DF8
	ld a, $1F
	add a, c
	ld l, a
	bit 7, [hl]
	jr nz, .l5DEF
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
.l5DEF
	ld a, $1E
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
.l5DF8
	ret

FrameTable_03_5DF9:	;$5DF9
	dw Frame_03_5E01, Frame_03_5E1D, Frame_03_5E39, Frame_03_5E59

Frame_03_5E01:	;$5E01
	db $F8, $07, $EC, $13	;hitbox
	db $F4, $ED, $45	;dx, dy, 4x5
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0D, $0E, $0F, $FF, $10, $11, $12, $FF
	db $80

Frame_03_5E1D:	;$5E1D
	db $F8, $07, $EC, $13	;hitbox
	db $ED, $ED, $45	;dx, dy, 4x5
	db $83, $82, $81, $80, $87, $86, $85, $84, $8B, $8A, $89, $88, $FF, $8F, $8E, $8D, $FF, $92, $91, $90
	db $80

Frame_03_5E39:	;$5E39
	db $F8, $07, $E4, $13	;hitbox
	db $F4, $E5, $46	;dx, dy, 4x6
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $FF, $0C, $FF, $FF, $0D, $0E, $0F, $FF, $10, $11, $12, $FF
	db $80

Frame_03_5E59:	;$5E59
	db $F8, $07, $E4, $13	;hitbox
	db $ED, $E5, $46	;dx, dy, 4x6
	db $83, $82, $81, $80, $87, $86, $85, $84, $8B, $8A, $89, $88, $FF, $FF, $8C, $FF, $FF, $8F, $8E, $8D, $FF, $92, $91, $90
	db $80
