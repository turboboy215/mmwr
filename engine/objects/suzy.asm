;Mega Man: Dr. Wily's Revenge disassembly - object type 21, Suzy
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Suzy (type 21)", ROMX[$72E1], BANK[$3]

;Suzy, also called Adhering Suzy or Octopus Battery (Will; the ending lists
;SUZY).	;[ok]
;Type 21, placed in Ice Man (6), Elec Man (15), Fire Man (10) and Wily 1 (6).
;Moves in a straight line until a wall: param bits 0-1 pick the axis (nonzero =
;vertical), bits 2-3 the direction (nonzero = up/right). It opens (15 frames),
;moves 1.5 px a frame testing a point 8 px ahead (CheckSolidPoint); at a wall it
;reverses, closes (15 frames), rests 120 frames and goes again. Not removed off
;screen while moving. wFreezeFlags pauses it; Ice Slasher does nothing.	;[ok]
SuzyRoutine:	;$72E1
	ld a, b
	or a
	jr z, .l72F2
	dec a
	jr z, .l7332
	dec a
	jr z, .l72EE
	dec a
	jr z, .l72F1
.l72EE
	ld b, $00
	ret
.l72F1
	ret
.l72F2
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $65
	inc l
	ld [hl], $74
	inc l
	ld [hl], $02
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	ld d, a
	and $03
	ld e, a
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], e
	srl d
	srl d
	ld a, $2E
	add a, c
	ld l, a
	ld a, d
	and $03
	ld [hl+], a
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
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
	ld b, $01
	ret
.l7332
	ld a, [wFreezeFlags]
	or a
	jp nz, .l73CE
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l734A
	dec a
	jr z, .l7364
	dec a
	jr z, .l737E
	dec a
	jr z, .l73B4
.l734A
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $78
	jr c, .l73CE
	xor a
	ld [hl], a
	ld e, $01
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	jr .l73CE
.l7364
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0F
	jr c, .l73CE
	xor a
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	jr .l73CE
.l737E
	call SuzyMove
	or a
	jr nz, .l7397
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
	ld b, $01
	ret
.l7397
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl+], a
	ld [hl], a
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $01
	jr .l73CE
.l73B4
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0F
	jr c, .l73CE
	ld e, $00
	ld [hl], e
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	jr .l73CE
.l73CE
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
	jr nc, .l73E8
	cp $C0
	jp nc, .l72EE
.l73E8
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret

SuzyMove:	;$73EF
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7425
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7412
	ld e, $00
	ld d, $F8
	call SuzyCheckSolidAhead
	or a
	ret nz
	ld e, $18
	call ObjStepY_03
	call ObjMoveY_03
	xor a
	ret
.l7412
	ld e, $00
	ld d, $08
	call SuzyCheckSolidAhead
	or a
	ret nz
	ld e, $E8
	call ObjStepY_03
	call ObjMoveY_03
	xor a
	ret
.l7425
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7438
	ld e, $08
	ld d, $00
	call SuzyCheckSolidAhead
	or a
	ret nz
	jr .l7441
.l7438
	ld e, $F8
	ld d, $00
	call SuzyCheckSolidAhead
	or a
	ret nz
.l7441
	ld e, $18
	call ObjStepX_03
	call ObjMoveX_03
	xor a
	ret

SuzyCheckSolidAhead:	;$744B
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	inc l
	inc l
	ld a, [hl]
	add a, d
	ld d, a
	push bc
	push hl
	call JumpCheckSolidPoint
	pop hl
	pop bc
	jr c, .l7462
	xor a
	ret
.l7462
	ld a, $01
	ret

FrameTable_03_7465:	;$7465
	dw Frame_03_746D, Frame_03_7479, Frame_03_7485, Frame_03_7479

Frame_03_746D:	;$746D
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $80, $40, $C0
	db $80

Frame_03_7479:	;$7479
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $01, $81, $40, $C0
	db $80

Frame_03_7485:	;$7485
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $02, $82, $41, $C1
	db $80
