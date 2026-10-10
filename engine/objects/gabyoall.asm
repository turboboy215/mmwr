;Mega Man: Dr. Wily's Revenge disassembly - object type 3, Gabyoall
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Gabyoall (type 3)", ROMX[$5B5F], BANK[$3]

;Gabyoall (Will; the ending lists GABYOALL).	;[ok]
;Type 3, placed in Cut Man (2), Wily 1 and Wily 3. Starts toward Mega Man once
;on screen, crawling 0.5 px a frame - 1.5 px when level with him - and turning
;at walls and at ledges (no gravity). No attack. It writes 1/2/3 to $DFC5
;(spawned/waiting/started), which nothing reads. Frozen: no movement.	;[ok]
GabyoallRoutine:	;$5B5F
	ld a, b
	or a
	jr z, .l5B70
	dec a
	jr z, .l5B84
	dec a
	jr z, .l5B6D
	dec a
	jp z, .l5C58
.l5B6D
	ld b, $00
	ret
.l5B70
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $94
	inc l
	ld [hl], $5C
	call GabyoallFaceMegaMan
	ld a, $01
	ld [$DFC5], a
	ld b, $01
	ret
.l5B84
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5C58
	ld a, $21
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5BB5
	push hl
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	pop hl
	cp $F8
	jr nc, .l5BAF
	cp $A8
	jr c, .l5BAF
	cp $C0
	jp nc, .l5B6D
	ld a, $02
	ld [$DFC5], a
	jp .l5C72
.l5BAF
	inc [hl]
	ld a, $03
	ld [$DFC5], a
.l5BB5
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	ld e, $00
	ld a, [wPlayerY]
	add a, $0D
	ld b, a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, $08
	sub b
	jr nc, .l5BCE
	cpl
.l5BCE
	cp $06
	jr nc, .l5BD8
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $01
.l5BD8
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld e, $F8
	jr z, .l5BE4
	ld e, $07
.l5BE4
	ld b, e
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	inc l
	inc l
	ld a, [hl]
	add a, $08
	ld d, a
	push bc
	call JumpCheckSolidPoint
	pop bc
	ld a, [$CC41]
	ld h, a
	jr nc, .l5C12
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld e, a
	inc l
	inc l
	ld d, [hl]
	push bc
	call JumpCheckSolidPoint
	pop bc
	ld a, [$CC41]
	ld h, a
	jr nc, .l5C1A
.l5C12
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
.l5C1A
	ld a, $28
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	add a, e
	add a, a
	add a, LOW(GabyoallSpeeds)
	ld e, a
	ld a, $00
	adc a, HIGH(GabyoallSpeeds)
	ld d, a
	ld a, $1C
	add a, c
	ld l, a
	ld a, [de]
	add a, [hl]
	ld [hl], a
	inc de
	push af
	ld a, $0D
	add a, c
	ld l, a
	pop af
	ld a, [de]
	adc a, [hl]
	ld [hl], a
	ld e, $00
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	jr c, .l5C53
	inc e
	cp $0C
	jr c, .l5C53
	ld [hl], $00
.l5C53
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
.l5C58
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
	ld a, e
	cp $E0
	jr nc, .l5C72
	cp $C0
	jp nc, .l5B6D
.l5C72
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret

GabyoallFaceMegaMan:	;$5C79
	ld a, $0D
	add a, c
	ld l, a
	ld d, $00
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l5C86
	inc d
.l5C86
	ld a, $28
	add a, c
	ld l, a
	ld [hl], d
	ret

GabyoallSpeeds:	;$5C8C
	db $80, $FF
	db $80, $00
	db $80, $FE
	db $80, $01

FrameTable_03_5C94:	;$5C94
	dw Frame_03_5C98, Frame_03_5CA2

Frame_03_5C98:	;$5C98
	db $F8, $07, $00, $07	;hitbox
	db $F8, $01, $21	;dx, dy, 2x1
	db $00, $80
	db $80

Frame_03_5CA2:	;$5CA2
	db $F8, $07, $00, $07	;hitbox
	db $F8, $01, $21	;dx, dy, 2x1
	db $01, $81
	db $80
