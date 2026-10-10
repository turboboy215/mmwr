;Mega Man: Dr. Wily's Revenge disassembly - object type 39, EnkerShot
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "EnkerShot (type 39)", ROMX[$5B73], BANK[$9]

;Object type 39: never placed; Enker's shot (EnkerSpawnShot runs EnkerShotInit
;on it). $CC08 = a power tier from the damage Enker absorbed picks, from
;EnkerShotTiers, its X speed (1.5 / 2 / 2.5 px/frame), $1A (2 / 4 / 8) and its
;size (1, 2 or 3 tiles tall). Hit points $FE (shots bounce off). Moves straight;
;removed off screen; Time Stopper holds it.	;[ok]
;$1A is probably the damage it does to Mega Man; that would make this the Mirror
;Buster, Enker's weapon.	;[?]
EnkerShotRoutine:	;$5B73
	ld a, b
	or a
	jr z, EnkerShotInit
	dec a
	jp z, EnkerShotUpdate
	dec a
	jp z, .l5B83
	dec a
	jp z, .l5B86
.l5B83
	ld b, $00
	ret
.l5B86
	ld a, $22
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ret

EnkerShotInit:	;$5B8E
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_5C12)
	inc l
	ld [hl], HIGH(FrameTable_5C12)
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $50
	ld b, $00
	jr nc, .l5BA3
	inc b
.l5BA3
	ld a, $24
	add a, c
	ld l, a
	ld [hl], b
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jr c, .l5BB3
	xor a
	ld [hl], a
.l5BB3
	push hl
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, EnkerShotTiers
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, b
	or a
	jr z, .l5BCC
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
.l5BCC
	ld a, e
	ldh [hBank1CallIndex], a
	ld a, d
	ldh [$FF92], a
	ld e, l
	ld d, h
	pop hl
	ld a, $1C
	add a, c
	ld l, a
	ldh a, [hBank1CallIndex]
	ld [hl+], a
	ldh a, [$FF92]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld a, $1A
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl], a
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld a, $17
	add a, c
	ld l, a
	ld a, [de]
	add a, b
	ld [hl], a
	ld b, $01
	ret

EnkerShotTiers:	;$5BF9
	db $80, $FE, $02, $00, $00, $FE, $04, $02
	db $80, $FD, $08, $04

EnkerShotUpdate:	;$5C05
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5C0F
	call ObjMoveByVelocity_09
.l5C0F
	jp ObjSyncAndCheckOnScreen_09

FrameTable_5C12:	;$5C12
	dw Frame_5C1E, Frame_5C3C, Frame_5C27, Frame_5C45
	dw Frame_5C31, Frame_5C4F

Frame_5C1E:	;$5C1E
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_5C27:	;$5C27
	db $FC, $03, $F8, $07	;hitbox
	db $FC, $F8, $12	;dx, dy, 1x2
	db $01, $41
	db $80

Frame_5C31:	;$5C31
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $02, $03, $42
	db $80

Frame_5C3C:	;$5C3C
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $80
	db $80

Frame_5C45:	;$5C45
	db $FC, $03, $F8, $07	;hitbox
	db $FC, $F8, $12	;dx, dy, 1x2
	db $81, $C1
	db $80

Frame_5C4F:	;$5C4F
	db $FC, $03, $F4, $0C	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $82, $83, $C2
	db $80
