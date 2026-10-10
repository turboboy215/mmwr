;Mega Man: Dr. Wily's Revenge disassembly - object type 2, ScrewDriver
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ScrewDriver (type 2)", ROMX[$5982], BANK[$3]

;Screw Driver (Will; the ending lists SCREW DRIVER).	;[ok]
;Type 2, placed in Cut Man (10), Fire Man (5) and Wily 3 (7). Never moves.
;Param & 3: 0 upright; 1-3 upside down (frames 5-9), raised 8 or 15 px. When Mega
;Man is within $30 px it opens over about 30 frames and fires five enemy shots
;(ScrewDriverFireShot: up, up-right, right, up-left, left - or the downward fan when
;upside down), then closes, re-arming while he is near. Frozen: frame kept.	;[ok]
ScrewDriverRoutine:	;$5982
	ld a, b
	or a
	jr z, .l5993
	dec a
	jr z, .l59D6
	dec a
	jr z, .l5990
	dec a
	jp z, .l5A9B
.l5990
	ld b, $00
	ret
.l5993
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	ld d, $00
	ld e, $00
	jr z, .l59B0
	ld d, $F8
	ld e, $05
	cp $01
	jr z, .l59B0
	ld d, $F1
	ld e, $05
	cp $03
	jr z, .l59B0
.l59B0
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $CF
	inc l
	ld [hl], $5A
	inc l
	ld [hl], e
	ld b, $01
	ret
.l59D6
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5A9B
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	ld b, a
	or a
	jr nz, .l5A04
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l59F1
	cpl
.l59F1
	cp $30
	jp nc, .l5A9B
	ld a, $09
	add a, c
	ld l, a
	inc [hl]
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $1E
	jp .l5A9B
.l5A04
	ld a, $27
	add a, c
	ld l, a
	dec [hl]
	jp nz, .l5A9B
	ld [hl], $04
	ld a, b
	cp $02
	jr nc, .l5A25
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $02
	jr c, .l5A9B
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
	jr .l5A9B
.l5A25
	cp $03
	jr nc, .l5A89
	ld [hl], $06
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $05
	jr c, .l5A9B
	ld [hl], $02
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr nz, .l5A77
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	ld d, $01
	or a
	jr z, .l5A4D
	ld d, $09
.l5A4D
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub $02
	ld e, a
	ld a, $0F
	add a, c
	ld l, a
	ld a, d
	add a, [hl]
	ld d, a
	ld a, $00
	call ScrewDriverFireShot
	ld a, $02
	call ScrewDriverFireShot
	ld a, $04
	call ScrewDriverFireShot
	ld a, $0E
	call ScrewDriverFireShot
	ld a, $0C
	call ScrewDriverFireShot
	jr .l5A9B
.l5A77
	cp $06
	jr c, .l5A9B
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $01
	jr .l5A9B
.l5A89
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
.l5A9B
	ld a, $29
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ld b, $01
	ret

ScrewDriverFireShot:	;$5AAF
	push bc
	push de
	push hl
	ld b, a
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5ABD
	ld a, $08
.l5ABD
	add a, b
	cp $10
	jr c, .l5AC4
	sub $10
.l5AC4
	ld l, $03
	ld b, $66
	call JumpFireEnemyShot
	pop hl
	pop de
	pop bc
	ret

FrameTable_03_5ACF:	;$5ACF
	dw Frame_03_5AE3, Frame_03_5AED, Frame_03_5AFA, Frame_03_5B07
	dw Frame_03_5B14, Frame_03_5B21, Frame_03_5B2B, Frame_03_5B38
	dw Frame_03_5B45, Frame_03_5B52

Frame_03_5AE3:	;$5AE3
	db $F8, $07, $01, $08	;hitbox
	db $F8, $01, $21	;dx, dy, 2x1
	db $00, $01
	db $80

Frame_03_5AED:	;$5AED
	db $F8, $07, $FC, $09	;hitbox
	db $F8, $FB, $21	;dx, dy, 2x1
	db $00, $01
	db $04, $08, $07
	db $80

Frame_03_5AFA:	;$5AFA
	db $F8, $07, $F9, $08	;hitbox
	db $F8, $F9, $21	;dx, dy, 2x1
	db $00, $01
	db $04, $08, $06
	db $80

Frame_03_5B07:	;$5B07
	db $F8, $07, $F9, $08	;hitbox
	db $F8, $F9, $21	;dx, dy, 2x1
	db $02, $03
	db $04, $08, $06
	db $80

Frame_03_5B14:	;$5B14
	db $F8, $07, $F9, $08	;hitbox
	db $F8, $F9, $21	;dx, dy, 2x1
	db $04, $05
	db $04, $08, $06
	db $80

Frame_03_5B21:	;$5B21
	db $F8, $07, $00, $07	;hitbox
	db $F8, $FF, $21	;dx, dy, 2x1
	db $40, $41
	db $80

Frame_03_5B2B:	;$5B2B
	db $F8, $07, $FE, $0B	;hitbox
	db $F8, $04, $21	;dx, dy, 2x1
	db $40, $41
	db $04, $F8, $47
	db $80

Frame_03_5B38:	;$5B38
	db $F8, $07, $FE, $0D	;hitbox
	db $F8, $06, $21	;dx, dy, 2x1
	db $40, $41
	db $04, $F8, $46
	db $80

Frame_03_5B45:	;$5B45
	db $F8, $07, $FE, $0D	;hitbox
	db $F8, $06, $21	;dx, dy, 2x1
	db $42, $43
	db $04, $F8, $46
	db $80

Frame_03_5B52:	;$5B52
	db $F8, $07, $FE, $0D	;hitbox
	db $F8, $06, $21	;dx, dy, 2x1
	db $44, $45
	db $04, $F8, $46
	db $80
