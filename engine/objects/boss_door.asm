;Mega Man: Dr. Wily's Revenge disassembly - object type 55, BossDoor
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "BossDoor (type 55)", ROMX[$7B36], BANK[$9]

;The boss door (type 55), placed once in each robot-master stage. A state
;machine in $09, one frame step every 7 frames with sound $0D: grows in (state
;5), waits for Mega Man at screen X $58-$67 (0), shrinks to nothing (1), waits
;for him at X $28-$37 (2), grows back (3) and stays (4). Never removed off
;screen. Killed: removed.	;[ok]
BossDoorRoutine:	;$7B36
	ld a, b
	or a
	jr z, .l7B47
	dec a
	jr z, .l7B70
	dec a
	jr z, .l7B43
	dec a
	jr z, .l7B70
.l7B43
	ld b, $00
	ret
.l7B46
	ret
.l7B47
	ld a, $29
	add a, c
	ld l, a
	ldh a, [rOBP1]
	ld [hl+], a
	ld a, [wShadowBGP]
	ld [hl+], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_7C8D)
	inc l
	ld [hl], HIGH(FrameTable_7C8D)
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $05
	jp BossDoorKeep
.l7B70
	ld a, [wFreezeFlags]
	and $01
	jp nz, .l7B46
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, BossDoorShrink
	dec a
	jr z, BossDoorWaitPassed
	dec a
	jr z, BossDoorRegrow
	dec a
	jp z, BossDoorStay
	dec a
	jp z, BossDoorGrowIn
	ld l, c
	push hl
	ld hl, Data_09_7BAD
	call CheckPlayerInBox_09
	pop hl
	ld c, l
	jr c, BossDoorKeep
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01

BossDoorKeep:	;$7BA6
	ld a, $01
	ld b, a
	ld [$CC44], a
	ret

Data_09_7BAD:	;$7BAD
	db $58, $68
	db $30, $6F
Data_09_7BB1:	;$7BB1
	db $28, $38
	db $30, $6F

BossDoorShrink:	;$7BB5
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7BC0
	dec [hl]
	jr .l7BD9
.l7BC0
	ld [hl], $06
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $04
	jr nz, .l7BD3
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
	jr .l7BD9
.l7BD3
	inc [hl]
	ld a, $0D
	call JumpQueueSound
.l7BD9
	jr BossDoorKeep

BossDoorWaitPassed:	;$7BDB
	ld l, c
	push hl
	ld hl, Data_09_7BB1
	call CheckPlayerInBox_09
	pop hl
	ld c, l
	jr c, .l7BF3
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $03
.l7BF3
	jr BossDoorKeep

BossDoorRegrow:	;$7BF5
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7C00
	dec [hl]
	jr .l7C18
.l7C00
	ld [hl], $06
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l7C12
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $04
	jr .l7C18
.l7C12
	dec [hl]
	ld a, $0D
	call JumpQueueSound
.l7C18
	jp BossDoorKeep

;State 4: the door has grown back; it stays (BossDoorKeep).	;[ok]
BossDoorStay:	;$7C1B
	jp BossDoorKeep

BossDoorGrowIn:	;$7C1E
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7C29
	dec [hl]
	jr .l7C41
.l7C29
	ld [hl], $06
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l7C3B
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	jr .l7C41
.l7C3B
	dec [hl]
	ld a, $0D
	call JumpQueueSound
.l7C41
	jp BossDoorKeep

;Unused: nothing calls it. Writes background tiles $78/$79 down 8 rows at the
;door's position (BossDoorGetBGAddress) - perhaps an earlier way of drawing
;the door into the background.	;[ok]
BossDoorDrawBGUnused:	;$7C44
	ld l, c
	push hl
	call BossDoorGetBGAddress
	ld a, $08
.l7C4B
	push af
	ld e, l
	ld d, h
	ld hl, Data_09_7C64
	ld bc, $0002
	push de
	call JumpCopyVRAM
	pop de
	ld hl, $0020
	add hl, de
	pop af
	dec a
	jr nz, .l7C4B
	pop hl
	ld c, l
	ret

Data_09_7C64:	;$7C64
	db $78, $79

;HL = the BG map address ($9800 + row * 32 + column) of the tile under the
;point (X - 8, Y - 8) from the object's offsets $0D/$0F, allowing for the
;scroll (wShadowSCX/wShadowSCY). Only BossDoorDrawBGUnused calls it.	;[ok]
BossDoorGetBGAddress:	;$7C66
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	inc l
	add a, $F8
	ld e, a
	ld a, [hl]
	add a, $F8
	ld d, a
	ld a, [wShadowSCX]
	add a, e
	srl a
	srl a
	srl a
	ld c, a
	ld a, [wShadowSCY]
	add a, d
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld b, $98
	add hl, bc
	ret

FrameTable_7C8D:	;$7C8D
	dw Frame_7C99, Frame_7CB1, Frame_7CC5, Frame_7CD5
	dw Frame_7CE1, Frame_7CEA

Frame_7C99:	;$7C99
	db $F8, $07, $F8, $37	;hitbox
	db $F8, $F8, $28	;dx, dy, 2x8
	db $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
	db $80

Frame_7CB1:	;$7CB1
	db $F8, $07, $F8, $27	;hitbox
	db $F8, $F8, $26	;dx, dy, 2x6
	db $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
	db $80

Frame_7CC5:	;$7CC5
	db $F8, $07, $F8, $17	;hitbox
	db $F8, $F8, $24	;dx, dy, 2x4
	db $00, $01, $00, $01, $00, $01, $00, $01
	db $80

Frame_7CD5:	;$7CD5
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $00, $01
	db $80

Frame_7CE1:	;$7CE1
	db $00, $00, $00, $00	;hitbox
	db $F8, $F8, $11	;dx, dy, 1x1
	db $FF
	db $80

Frame_7CEA:	;$7CEA
	db $F8, $07, $F8, $37	;hitbox
	db $F8, $F8, $11	;dx, dy, 1x1
	db $FF
	db $80

;Unused: nothing calls it. The same code as bank $0D's GetDirectionToPoint:
;A = the direction of point (C, B) from (E, D), 0-7 clockwise from up
;(0 up, 2 right, 4 down, 6 left); within $18 px counts as level on that axis.	;[ok]
GetDirectionToPoint_09:	;$7CF3
	ld a, e
	add a, $18
	sub c
	jr c, .l7D08
	ld a, e
	sub $18
	sub c
	jr nc, .l7D1D
	ld a, d
	sub b
	jr c, .l7D05
	xor a
	ret
.l7D05
	ld a, $04
	ret
.l7D08
	ld a, d
	add a, $18
	sub b
	jr c, .l7D17
	ld a, d
	sub $18
	sub b
	jr nc, .l7D1A
	ld a, $02
	ret
.l7D17
	ld a, $03
	ret
.l7D1A
	ld a, $01
	ret
.l7D1D
	ld a, d
	add a, $18
	sub b
	jr c, .l7D2C
	ld a, d
	sub $18
	sub b
	jr nc, .l7D2F
	ld a, $06
	ret
.l7D2C
	ld a, $05
	ret
.l7D2F
	ld a, $07
	ret
