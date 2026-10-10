;Mega Man: Dr. Wily's Revenge disassembly - object type 7, BunbyHeli
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "BunbyHeli (type 7)", ROMX[$6B49], BANK[$3]

;Bunby Heli (Will; the ending misspells it BUNBY HERI).	;[ok]
;Type 7, placed in Ice Man (14), Fire Man (13) and Wily 1 (6). A flier: cruises
;0.5 px a frame at a height from BunbyHeliCruiseHeights (param & 3), heading right if
;it spawned at the right edge, else left. When Mega Man is not more than 32 px
;ahead it dives at the Y he had (1.5 px a frame), climbs back to its height and
;cruises on toward him. Always faces him. Removed off screen sideways; frozen:
;no movement.	;[ok]
BunbyHeliRoutine:	;$6B49
	ld a, b
	or a
	jr z, BunbyHeliInit
	dec a
	jr z, BunbyHeliUpdate
	dec a
	jr z, BunbyHeliRemove
	dec a
	jr z, BunbyHeliFrozen

BunbyHeliRemove:	;$6B56
	ld b, $00
	ret

;Mode 3 (Ice Slasher): no movement, only the off-screen check.	;[ok]
BunbyHeliFrozen:	;$6B59
	jp BunbyHeliCheckOnScreenX

BunbyHeliInit:	;$6B5C
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	add a, LOW(BunbyHeliCruiseHeights)
	ld e, a
	ld a, $00
	adc a, HIGH(BunbyHeliCruiseHeights)
	ld d, a
	ld a, $2A
	add a, c
	ld l, a
	ld a, [de]
	ld d, a
	ld [hl], d
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $27
	add a, c
	ld l, a
	xor a
	ld [hl], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $D0
	ld d, $00
	jr c, .l6B8A
	ld d, $01
.l6B8A
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], d
	ld de, BunbyHeliAnim
	call AnimateObjectFacing_03
	ld b, $01
	ret

BunbyHeliCruiseHeights:	;$6B98
	db $20, $30, $40, $50

BunbyHeliUpdate:	;$6B9C
	ld a, [wFreezeFlags]
	or a
	jp nz, BunbyHeliCheckOnScreenX
	call ObjFaceMegaMan_03
	ld de, BunbyHeliAnim
	call AnimateObjectFacing_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6BBB
	dec a
	jr z, BunbyHeliDive
	dec a
	jp z, BunbyHeliClimb
.l6BBB
	call BunbyHeliStepX
	ld a, $0D
	add a, c
	ld l, a
	ld d, [hl]
	ld a, [wPlayerX]
	ld e, a
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6BD7
	ld a, d
	add a, $20
	cp e
	jr c, BunbyHeliCheckOnScreenX
	jr .l6BDD
.l6BD7
	ld a, d
	sub $20
	cp e
	jr nc, BunbyHeliCheckOnScreenX
.l6BDD
	ld a, $27
	add a, c
	ld l, a
	ld a, $01
	ld [hl], a
	call BunbyHeliSetDiveTarget

BunbyHeliCheckOnScreenX:	;$6BE7
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
	jr nc, .l6C01
	cp $C0
	jp nc, BunbyHeliRemove
.l6C01
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret

BunbyHeliDive:	;$6C08
	call BunbyHeliStepX
	call BunbyHeliStepY
	ld a, $0F
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld d, [hl]
	ld a, e
	sub d
	jr nc, .l6C1E
	cpl
	inc a
.l6C1E
	cp $04
	jr nc, BunbyHeliCheckOnScreenX
	jr .l6C24
.l6C24
	ld a, $27
	add a, c
	ld l, a
	ld a, $02
	ld [hl], a
	jr BunbyHeliCheckOnScreenX

BunbyHeliClimb:	;$6C2D
	ld a, $0F
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp e
	ld d, $00
	jr nc, .l6C3D
	inc d
.l6C3D
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], d
	call BunbyHeliStepX
	call BunbyHeliStepY
	ld a, $2A
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	jr nc, .l6C57
	cpl
	inc a
.l6C57
	cp $04
	jr nc, BunbyHeliCheckOnScreenX
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $27
	add a, c
	ld l, a
	ld e, $00
	ld [hl], e
	ld a, $24
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], d
	jp BunbyHeliCheckOnScreenX

BunbyHeliSetDiveTarget:	;$6C74
	ld d, $00
	ld a, $0F
	add a, c
	ld l, a
	ld a, [wPlayerY]
	cp $E0
	jr c, .l6C83
	ld a, $04
.l6C83
	ld e, a
	cp [hl]
	jr nc, .l6C88
	inc d
.l6C88
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], d
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	ret

BunbyHeliStepX:	;$6C93
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	ret z
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6CAA
	ld a, $0D
	add a, c
	ld l, a
	inc [hl]
	ret
.l6CAA
	ld a, $0D
	add a, c
	ld l, a
	dec [hl]
	ret

BunbyHeliStepY:	;$6CB0
	ld d, $01
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6CBB
	inc d
.l6CBB
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6CCB
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ret
.l6CCB
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ret

BunbyHeliAnim:	;$6CD3
	dw FrameTable_03_6CD9
	db 3	;frames per step
	db $00, $02, $FF

FrameTable_03_6CD9:	;$6CD9
	dw Frame_03_6CE1, Frame_03_6CFD, Frame_03_6CEF, Frame_03_6D0B

Frame_03_6CE1:	;$6CE1
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $00, $01, $02, $03, $04, $05
	db $80

Frame_03_6CEF:	;$6CEF
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $81, $80, $02, $03, $04, $05
	db $80

Frame_03_6CFD:	;$6CFD
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $00, $01, $83, $82, $85, $84
	db $80

Frame_03_6D0B:	;$6D0B
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $81, $80, $83, $82, $85, $84
	db $80
