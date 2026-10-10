;Mega Man: Dr. Wily's Revenge disassembly - object type 16, IcePlatform
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "IcePlatform (type 16)", ROMX[$6DE7], BANK[$3]

;The ice platform (type 16), placed in Ice Man (5) and Wily 3 (3): it melts
;while Mega Man stands on it. Each frame his feet are on its top edge it counts
;$27 up (the count never resets); the frame steps 0-3 at counts 30, 50 and 70,
;each with a lower top edge, and at 90 it is gone. Time Stopper and Ice Slasher
;do not stop it. Shots bounce off (hit points $FE).	;[ok]
IcePlatformRoutine:	;$6DE7
	ld a, b
	or a
	jr z, IcePlatformInit
	dec a
	jr z, IcePlatformUpdate
	dec a
	jr z, IcePlatformRemove
	dec a
	jr z, IcePlatformUpdate

IcePlatformRemove:	;$6DF4
	ld b, $00
	ret

;Unused: a lone ret nothing reaches.	;[ok]
Unused_03_6DF7:	;$6DF7
	ret

IcePlatformInit:	;$6DF8
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $A3
	inc l
	ld [hl], $6E
	inc l
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret

IcePlatformUpdate:	;$6E0D
	ld a, [wFreezeFlags]
	and $F7
	jp nz, .l6E3E
	call IcePlatformCheckStoodOn
	jr nc, .l6E1F
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
.l6E1F
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	ld e, $00
	cp $1E
	jr c, .l6E39
	inc e
	cp $32
	jr c, .l6E39
	inc e
	cp $46
	jr c, .l6E39
	inc e
	cp $5A
	jr nc, IcePlatformRemove
.l6E39
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
.l6E3E
	ld b, $01
	ret

IcePlatformCheckStoodOn:	;$6E41
	push hl
	push bc
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	push de
	ld a, $17
	add a, c
	ld l, a
	ld e, [hl]
	ld d, $00
	ld hl, IcePlatformFrames
	add hl, de
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop bc
	ld de, $FF9A
	ld a, [hl+]
	add a, c
	ld [de], a
	inc e
	ld a, [hl+]
	add a, c
	ld [de], a
	inc e
	ld a, [hl+]
	add a, b
	ld [de], a
	inc e
	ld a, [hl+]
	add a, b
	ld [de], a
	ldh a, [$FF9C]
	ld b, a
	ld a, [wPlayerY]
	add a, $0D
	cp b
	jr nz, .l6E9F
	ldh a, [$FF9A]
	cp $E0
	jr c, .l6E80
	xor a
.l6E80
	ld e, a
	ldh a, [$FF9B]
	cp $E0
	jr c, .l6E88
	xor a
.l6E88
	ld d, a
	ld a, [wPlayerX]
	ld b, a
	add a, $FA
	cp e
	jr c, .l6E95
	cp d
	jr c, .l6E9C
.l6E95
	ld a, b
	add a, $06
	cp e
	jr c, .l6E9F
	cp d
.l6E9C
	pop bc
	pop hl
	ret
.l6E9F
	xor a
	pop bc
	pop hl
	ret

IcePlatformFrames:	;$6EA3
	dw Frame_03_6EAB, Frame_03_6EB7, Frame_03_6EC3, Frame_03_6ECF

Frame_03_6EAB:	;$6EAB
	db $F8, $07, $F8, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_03_6EB7:	;$6EB7
	db $F8, $07, $FB, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $02, $03
	db $80

Frame_03_6EC3:	;$6EC3
	db $F8, $07, $00, $08	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $06, $07, $02, $03
	db $80

Frame_03_6ECF:	;$6ECF
	db $F8, $07, $02, $08	;hitbox
	db $F8, $00, $21	;dx, dy, 2x1
	db $08, $09
	db $80
