;Mega Man: Dr. Wily's Revenge disassembly - object type 29, AtomicFireBlock
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "AtomicFireBlock (type 29)", ROMX[$6575], BANK[$9]

;The Atomic Fire block (type 29), placed four times in Wily 3: it takes
;damage only while Atomic Fire is the current weapon. Its real hit points (4)
;are kept in $28; every frame $18 is set from them when Atomic Fire is equipped,
;else to $13, so other weapons' damage is undone. The frame shows the damage
;taken (four stages). Killed: removed. Frozen: the freeze is cleared.	;[ok]
AtomicFireBlockRoutine:	;$6575
	ld a, b
	or a
	jr z, .l6588
	dec a
	jr z, .l65A9
	dec a
	jr z, .l6582
	dec a
	jr z, .l6585
.l6582
	ld b, $00
	ret
.l6585
	jp ObjClearFreeze_09
.l6588
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_6601)
	inc l
	ld [hl], HIGH(FrameTable_6601)
	inc l
	ld [hl], $00
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $04
	call AtomicFireBlockSetHP
	call AtomicFireBlockSetFrame
	ld b, $01
	ret
.l65A9
	ld a, [wFreezeFlags]
	and $F7
	jp nz, .l65C4
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl-]
	cp $06
	jr nz, .l65C4
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
.l65C4
	call AtomicFireBlockSetFrame
	call AtomicFireBlockSetHP
	ld b, $01
	ret

AtomicFireBlockSetFrame:	;$65CD
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	ld e, $03
	cp $02
	jr c, .l65E6
	ld e, $02
	cp $03
	jr c, .l65E6
	ld e, $01
	cp $04
	jr c, .l65E6
	ld e, $00
.l65E6
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

AtomicFireBlockSetHP:	;$65EC
	ld a, $29
	add a, c
	ld l, a
	ld a, [wCurrentWeapon]
	ld [hl-], a
	ld e, $13
	cp $06
	jr nz, .l65FB
	ld e, [hl]
.l65FB
	ld a, $18
	add a, c
	ld l, a
	ld [hl], e
	ret

FrameTable_6601:	;$6601
	dw Frame_6609, Frame_6615, Frame_6621, Frame_662D

Frame_6609:	;$6609
	db $F8, $07, $F8, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_6615:	;$6615
	db $F8, $07, $F8, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_6621:	;$6621
	db $F8, $07, $F8, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $08, $09, $0A, $0B
	db $80

Frame_662D:	;$662D
	db $F8, $07, $F8, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $0C, $0D, $0E, $0F
	db $80
