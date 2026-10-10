;Mega Man: Dr. Wily's Revenge disassembly - object type 44, HeatMan
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "HeatMan (type 44)", ROMX[$746A], BANK[$9]

;Heat Man (type 44), the boss behind Wily 2's fourth teleporter. Drops in and
;fills his bar, then stands; every 128 frames he writes 3 to $CCF6, which sends
;the three type 45s in his room at Mega Man. Hit, he takes no further damage
;(hit points $FE) for a random wait (HeatManSlideDelays), then slides 4 px a
;frame to where Mega Man was, re-forms and stands again. Holds still while
;anything is frozen. Killed: B = 0 only; the type 45s end the fight.	;[ok]
HeatManRoutine:	;$746A
	ld a, b
	or a
	jr z, .l747F
	dec a
	jr z, .l749F
	dec a
	jp z, .l7479
	dec a
	jp z, .l747C
.l7479
	ld b, $00
	ret
.l747C
	jp ObjClearFreeze_09
.l747F
	call InitBoss_09
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_7767)
	inc l
	ld [hl], HIGH(FrameTable_7767)
	inc l
	ld [hl], $00
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
	ret
.l749F
	ld a, [wFreezeFlags]
	or a
	jp nz, .l747C
	call StoreBossPosition_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l74D1
	dec a
	jr z, .l74F6
	ld b, a
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	and $80
	jr nz, .l74C1
	call UpdateBossEnergy_09
.l74C1
	ld a, b
	dec a
	jp z, .l755B
	dec a
	jp z, .l7621
	dec a
	jp z, .l765C
	jp .l76D8
.l74D1
	call DropBossIn_09
	or a
	jr z, .l74F3
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld e, $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], e
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
.l74F3
	jp .l7709
.l74F6
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $3C
	jr c, .l74F3
	jp z, .l7538
	cp $42
	jr c, .l74F3
	jp z, .l7538
	cp $48
	jr c, .l74F3
	jr z, .l7538
	call FillBossEnergy_09
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $96
	jr c, .l753F
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	inc hl
	ld [hl], $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $35
	add a, c
	ld l, a
	ld [hl], e
.l7535
	jp .l7709
.l7538
	ld a, $17
	add a, c
	ld l, a
	inc [hl]
	jr .l7535
.l753F
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	jr nz, .l7535
	ld [hl], a
	inc hl
	ld a, [hl]
	and $01
	xor $01
	ld [hl], a
	add a, $04
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	jr .l7535
.l755B
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl+]
	ld d, a
	ld a, [hl]
	or a
	jr z, .l75A4
	dec a
	jr z, .l75B7
	dec a
	jr z, .l75CA
	dec a
	jr z, .l75B7
	dec a
	jr z, .l75A4
	dec a
	jr z, .l7591
	call ObjFaceMegaMan_09
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $35
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $18
	add a, c
	ld l, a
	ld [hl], e
	jp .l7621
.l7591
	ld a, d
	and $07
	jp nz, .l760B
	inc [hl]
	dec hl
	xor a
	ld [hl], a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $10
	jp .l760B
.l75A4
	ld a, d
	and $07
	jp nz, .l760B
	inc [hl]
	dec hl
	xor a
	ld [hl], a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $11
	jp .l760B
.l75B7
	ld a, d
	and $07
	jp nz, .l760B
	inc [hl]
	dec hl
	xor a
	ld [hl], a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $12
	jp .l760B
.l75CA
	ld a, $2E
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $24
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, b
	or a
	jr z, .l75E5
	ld a, [hl]
	cp d
	jr nc, .l7600
	add a, $04
	ld [hl], a
	jr .l75EC
.l75E5
	ld a, [hl]
	cp d
	jr c, .l7600
	sub $04
	ld [hl], a
.l75EC
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	jr nz, .l760B
	ld [hl], $00
	ld a, $30
	add a, c
	ld l, a
	ld e, $15
	ld [hl], e
	jr .l760B
.l7600
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $13
.l760B
	call HeatManSetSlideFrame
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
	jp .l7709
.l7621
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld d, [hl]
	ld a, $30
	add a, c
	ld l, a
	ld a, d
	and $07
	jr nz, .l7645
	inc [hl]
	ld a, [hl]
	and $03
	jr nz, .l7645
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	inc hl
	ld [hl], $00
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $03
.l7645
	ld e, [hl]
	call HeatManSetFrame
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
	jp .l7709
.l765C
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $07
	jr z, .l766C
	jr nc, .l767A
	ld e, $06
	jr .l76C2
.l766C
	call JumpRNG
	bit 4, a
	ld a, $03
	jr z, .l7677
	ld a, $83
.l7677
	ld [wStageSelectAnimPhase], a
.l767A
	ld a, [hl]
	cp $11
	jr nc, .l7683
	ld e, $07
	jr .l76C2
.l7683
	and $7F
	ld [hl], a
	call ObjFaceMegaMan_09
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $35
	add a, c
	ld l, a
	ld a, e
	cp [hl]
	jr nz, .l769A
	ld e, $03
	jr .l76C2
.l769A
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	push hl
	call JumpRNG
	and $03
	ld hl, HeatManSlideDelays
	ld d, $00
	ld e, a
	add hl, de
	ld e, [hl]
	pop hl
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld [hl], $FE
	ld a, $35
	add a, c
	ld l, a
	ld [hl], e
	ld e, $03
.l76C2
	call HeatManSetFrame
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
	jp .l7709
.l76D8
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l771C
	dec [hl]
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	jr nz, .l76F9
	ld [hl], a
	inc hl
	ld a, [hl]
	and $01
	xor $01
	ld [hl], a
	add a, $04
	ld e, a
	call HeatManSetFrame
.l76F9
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
.l7709
	ld e, $65
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $10
	jr c, .l7714
.l7714
	ld a, $11
	add a, c
	ld l, a
	ld [hl], e
	ld b, $01
	ret
.l771C
	call ObjFaceMegaMan_09
	ld a, $2E
	add a, c
	ld l, a
	ld a, [wPlayerX]
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	xor a
	inc hl
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $13
	jr .l76F9

HeatManSlideDelays:	;$773A
	db $1E, $3C, $5A, $78

HeatManSetFrame:	;$773E
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7748
	ld a, $08
.l7748
	add a, e
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

HeatManSetSlideFrame:	;$7750
	ld a, $30
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l775F
	ld a, $06
.l775F
	add a, e
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

FrameTable_7767:	;$7767
	dw Frame_77DE, Frame_779F, Frame_77B3, Frame_77CA
	dw Frame_77F2, Frame_780A, Frame_7822, Frame_7836
	dw Frame_788C, Frame_784D, Frame_7861, Frame_7878
	dw Frame_78A0, Frame_78B8, Frame_78D0, Frame_78E4
	dw Frame_78FB, Frame_790F, Frame_792B, Frame_78FB
	dw Frame_790F, Frame_792B, Frame_78FB, Frame_790F
	dw Frame_792B, Frame_78FB, Frame_790F, Frame_792B

Frame_779F:	;$779F
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $FF, $15, $16, $FF, $17, $18, $19, $97, $1A, $1B, $1C, $1D
	db $80

Frame_77B3:	;$77B3
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14
	db $06, $F8, $0B
	db $10, $F8, $0B
	db $80

Frame_77CA:	;$77CA
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $00, $01, $02, $FF, $03, $04, $05, $06, $07, $08, $09, $0A
	db $80

Frame_77DE:	;$77DE
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F0, $34	;dx, dy, 3x4
	db $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $FF, $28
	db $80

Frame_77F2:	;$77F2
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $EC, $44	;dx, dy, 4x4
	db $29, $2A, $2B, $2C, $2D, $01, $2E, $2F, $30, $04, $05, $31, $32, $33, $34, $35
	db $80

Frame_780A:	;$780A
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $EC, $44	;dx, dy, 4x4
	db $36, $37, $38, $39, $3A, $01, $3B, $3C, $3D, $04, $05, $3E, $3F, $40, $41, $42
	db $80

Frame_7822:	;$7822
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $FF, $43, $44, $45, $46, $47, $49, $4A, $4B
	db $F8, $10, $48
	db $80

Frame_7836:	;$7836
	db $FC, $03, $F4, $01	;hitbox
	db $ED, $EC, $34	;dx, dy, 3x4
	db $FF, $4C, $4D, $FF, $4E, $4F, $50, $51, $52, $53, $54, $55
	db $18, $18, $56
	db $80

Frame_784D:	;$784D
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $FF, $96, $95, $FF, $17, $99, $98, $97, $9D, $9C, $9B, $9A
	db $80

Frame_7861:	;$7861
	db $FC, $03, $F4, $0C	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8E, $8D, $8C, $91, $90, $8F, $94, $93, $92
	db $04, $F8, $0B
	db $0E, $F8, $0B
	db $80

Frame_7878:	;$7878
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $FF, $82, $81, $80, $86, $85, $84, $83, $8A, $89, $88, $87
	db $80

Frame_788C:	;$788C
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F0, $34	;dx, dy, 3x4
	db $A0, $9F, $9E, $A3, $A2, $A1, $A6, $A5, $A4, $A8, $FF, $A7
	db $80

Frame_78A0:	;$78A0
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $EC, $44	;dx, dy, 4x4
	db $AC, $AB, $AA, $A9, $AF, $AE, $81, $AD, $B1, $85, $84, $B0, $B5, $B4, $B3, $B2
	db $80

Frame_78B8:	;$78B8
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $EC, $44	;dx, dy, 4x4
	db $B9, $B8, $B7, $B6, $BC, $BB, $81, $BA, $BE, $85, $84, $BD, $C2, $C1, $C0, $BF
	db $80

Frame_78D0:	;$78D0
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $C4, $C3, $FF, $C7, $C6, $C5, $CB, $CA, $C9
	db $18, $10, $C8
	db $80

Frame_78E4:	;$78E4
	db $FC, $03, $F4, $0B	;hitbox
	db $FD, $EC, $34	;dx, dy, 3x4
	db $CD, $CC, $FF, $CF, $CE, $FF, $D2, $D1, $D0, $D5, $D4, $D3
	db $F8, $18, $D6
	db $80

Frame_78FB:	;$78FB
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $E8, $26	;dx, dy, 2x6
	db $5A, $5B, $5C, $5D, $5A, $5B, $5C, $5D, $5A, $5B, $5C, $5D
	db $80

Frame_790F:	;$790F
	db $F8, $07, $F4, $0B	;hitbox
	db $00, $F0, $24	;dx, dy, 2x4
	db $5A, $5B, $5C, $5D, $5A, $5B, $5C, $5D
	db $F0, $08, $5A
	db $F8, $08, $5B
	db $F0, $10, $5C
	db $F8, $10, $5D
	db $80

Frame_792B:	;$792B
	db $F0, $0F, $F8, $07	;hitbox
	db $E8, $F8, $62	;dx, dy, 6x2
	db $5A, $5B, $5A, $5B, $5A, $5B, $5C, $5D, $5C, $5D, $5C, $5D
	db $80
