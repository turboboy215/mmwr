;Mega Man: Dr. Wily's Revenge disassembly - object type 40, BubbleMan
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "BubbleMan (type 40)", ROMX[$6639], BANK[$9]

;Bubble Man (type 40), the boss behind Wily 2's second teleporter. Sinks in,
;fills his bar, then repeats: on the floor he fires (writes 1 to $CCF6, up to
;three times), rises toward where Mega Man was, sinks back; while level with
;Mega Man he fires the other shot ($CCF6 = 2) every 32 frames. He spawns
;nothing - the five type 41s placed in his room answer $CCF6. Killed: B = 0 only;
;the type 41s end the fight. Ice Slasher does nothing to him.	;[ok]
BubbleManRoutine:	;$6639
	ld a, b
	or a
	jr z, .l664B
	dec a
	jr z, .l666F
	dec a
	jp z, .l6648
	dec a
	jp z, BubbleManClearFreeze
.l6648
	ld b, $00
	ret
.l664B
	xor a
	ld [wScreenCounter], a
	call InitBoss_09
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_6901)
	inc l
	ld [hl], HIGH(FrameTable_6901)
	inc l
	ld [hl], $06
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
.l666F
	ld a, [wFreezeFlags]
	or a
	jp nz, BubbleManClearFreeze
	call StoreBossPosition_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6694
	dec a
	jr z, .l66B8
	ld b, a
	call UpdateBossEnergy_09
	ld a, b
	dec a
	jp z, .l66FE
	dec a
	jp z, .l675F
	jp .l67A8
.l6694
	call BubbleManSinkIn
	or a
	jr z, .l66B5
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld e, $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
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
.l66B5
	ld b, $01
	ret
.l66B8
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $3C
	jr c, .l66B5
	jp z, .l66F7
	cp $42
	jr c, .l66B5
	jp z, .l66F7
	call FillBossEnergy_09
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $90
	jr c, .l66F4
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	push hl
	call JumpRNG
	pop hl
	and $03
	cp $03
	jr nz, .l66EB
	ld a, $01
.l66EB
	ld e, a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], $00
.l66F4
	ld b, $01
	ret
.l66F7
	ld a, $17
	add a, c
	ld l, a
	inc [hl]
	jr .l66F4
.l66FE
	call BubbleManSwim
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $30
	jp c, .l673C
.l670B
	ld a, $0F
	add a, c
	ld l, a
	ld a, [wPlayerY]
	add a, $08
	cp [hl]
	jr c, .l6733
	sub $10
	cp [hl]
	jr nc, .l6733
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $01
	dec hl
	ld a, [hl]
	or a
	jr nz, .l672C
	ld a, $02
	ld [wStageSelectAnimPhase], a
.l672C
	ld a, [hl]
	inc a
	and $1F
	ld [hl], a
	jr .l6749
.l6733
	ld a, $2A
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
	jr .l6749
.l673C
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $2A
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
.l6749
	call BubbleManAnimateSwim
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
.l675F
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $0F
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $66
	jp c, .l670B
	ld [hl], $65
	push hl
	call JumpRNG
	pop hl
	and $03
	cp $03
	jr nz, .l6781
	ld a, $01
.l6781
	ld e, a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld e, $00
	call BubbleManSetFrame
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
.l67A8
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl+]
	or a
	jp z, .l67F5
	ld a, [hl]
	or a
	jr nz, .l67C2
	ld a, $01
	ld [wStageSelectAnimPhase], a
.l67C2
	inc [hl]
	ld a, [hl]
	cp $0A
	jr nc, .l67CF
	ld e, $05
	call BubbleManSetFrame
	jr .l67E2
.l67CF
	cp $20
	jr nc, .l67DA
	ld e, $00
	call BubbleManSetFrame
	jr .l67E2
.l67DA
	ld [hl], $00
	dec hl
	dec [hl]
	ld a, [hl]
	or a
	jr z, .l67F5
.l67E2
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
.l67F5
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	call BubbleManStartRise
	jr .l67E2

BubbleManSetFrame:	;$6800
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l680C
	ld a, $08
	add a, e
	ld e, a
.l680C
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

BubbleManSinkIn:	;$6812
	ld a, [$CCF4]
	or a
	jr z, .l682E
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jr c, .l6823
	ld [hl], $00
.l6823
	inc [hl]
	ld a, [hl]
	sub $66
	jr c, .l682E
	ld [hl], $65
	ld a, $01
	ret
.l682E
	ld a, [wPlayerY]
	sub $60
	jr c, .l683A
	ld a, $01
	ld [$CCF4], a
.l683A
	xor a
	ret

BubbleManSwim:	;$683C
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6852
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $88
	jr nc, .l685E
	call BubbleManStepX
	jr .l685E
.l6852
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $1C
	jr c, .l685E
	call BubbleManStepX
.l685E
	call BubbleManStepUp
	ret

BubbleManStartRise:	;$6862
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l686E
	xor $FF
.l686E
	srl a
	srl a
	srl a
	ld e, a
	ld a, $32
	add a, c
	ld l, a
	ld [hl], $06
	dec hl
	ld [hl], e
	ld a, $2A
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
	ret

BubbleManStepX:	;$6885
	ld a, $31
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $1C
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld d, a
	and $0F
	ld [hl], a
	ld a, d
	swap a
	and $0F
	ld d, a
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l68AA
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ret
.l68AA
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ret

BubbleManStepUp:	;$68B2
	ld a, $32
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $1E
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld d, a
	and $0F
	ld [hl], a
	ld a, d
	swap a
	and $0F
	ret z
	ld d, a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ret

BubbleManAnimateSwim:	;$68D0
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	jr c, .l68E5
	ld [hl], $00
	inc hl
	ld a, [hl]
	xor $01
	ld d, a
	ld [hl], d
	inc hl
	jr .l68EB
.l68E5
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl+]
	ld d, a
.l68EB
	inc hl
	ld a, [hl]
	or a
	jr nz, .l68F7
	ld a, $06
	add a, d
	ld e, a
	jp BubbleManSetFrame
.l68F7
	ld a, $03
	add a, d
	ld e, a
	jp BubbleManSetFrame

;ObjClearFreeze (B = 1): ends Ice Slasher's freeze at once in mode 3. The
;update also jumps here while wFreezeFlags is set, so he does nothing that
;frame.	;[ok]
BubbleManClearFreeze:	;$68FE
	jp ObjClearFreeze_09

FrameTable_6901:	;$6901
	dw Frame_6921, Frame_6938, Frame_694C, Frame_6964
	dw Frame_697E, Frame_6998, Frame_69AF, Frame_69C9
	dw Frame_69E3, Frame_6938, Frame_694C, Frame_69FA
	dw Frame_6A14, Frame_6A2E, Frame_6A45, Frame_6A5F

Frame_6921:	;$6921
	db $FC, $03, $F4, $0B	;hitbox
	db $F2, $F4, $33	;dx, dy, 3x3
	db $FF, $01, $02, $03, $04, $05, $06, $07, $08
	db $08, $F8, $00
	db $18, $10, $09
	db $80

Frame_6938:	;$6938
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $EC, $34	;dx, dy, 3x4
	db $0A, $0B, $FF, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14
	db $80

Frame_694C:	;$694C
	db $FC, $03, $F4, $0B	;hitbox
	db $F2, $EC, $44	;dx, dy, 4x4
	db $FF, $1D, $FF, $FF, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $09
	db $80

Frame_6964:	;$6964
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F8, $43	;dx, dy, 4x3
	db $3F, $40, $41, $42, $FF, $43, $44, $45, $46, $47, $48, $49
	db $08, $F8, $33
	db $10, $F8, $34
	db $80

Frame_697E:	;$697E
	db $FC, $03, $F4, $0B	;hitbox
	db $F8, $F8, $23	;dx, dy, 2x3
	db $4B, $4C, $4E, $4F, $50, $51
	db $00, $F8, $29
	db $08, $F8, $2A
	db $F8, $00, $4A
	db $10, $00, $4D
	db $80

Frame_6998:	;$6998
	db $FC, $03, $F4, $0B	;hitbox
	db $F2, $FC, $32	;dx, dy, 3x2
	db $17, $18, $19, $1A, $1B, $1C
	db $00, $F8, $15
	db $08, $F8, $16
	db $18, $08, $09
	db $80

Frame_69AF:	;$69AF
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F8, $43	;dx, dy, 4x3
	db $35, $36, $37, $38, $FF, $39, $3A, $FF, $3B, $3C, $3D, $3E
	db $08, $F8, $33
	db $10, $F8, $34
	db $80

Frame_69C9:	;$69C9
	db $FC, $03, $F4, $0B	;hitbox
	db $F8, $F8, $23	;dx, dy, 2x3
	db $2C, $2D, $2F, $30, $31, $32
	db $00, $F8, $29
	db $08, $F8, $2A
	db $F8, $00, $2B
	db $10, $00, $2E
	db $80

Frame_69E3:	;$69E3
	db $FC, $03, $F4, $0B	;hitbox
	db $F6, $F4, $33	;dx, dy, 3x3
	db $82, $81, $FF, $85, $84, $83, $88, $87, $86
	db $08, $F8, $80
	db $F8, $10, $89
	db $80

Frame_69FA:	;$69FA
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F8, $43	;dx, dy, 4x3
	db $C2, $C1, $C0, $BF, $C5, $C4, $C3, $FF, $C9, $C8, $C7, $C6
	db $08, $F8, $B4
	db $10, $F8, $B3
	db $80

Frame_6A14:	;$6A14
	db $FC, $03, $F4, $0B	;hitbox
	db $F8, $F8, $23	;dx, dy, 2x3
	db $CC, $CB, $CF, $CE, $D1, $D0
	db $00, $F8, $AA
	db $08, $F8, $A9
	db $F8, $00, $CD
	db $10, $00, $CA
	db $80

Frame_6A2E:	;$6A2E
	db $FC, $03, $F4, $0B	;hitbox
	db $F6, $FC, $32	;dx, dy, 3x2
	db $99, $98, $97, $9C, $9B, $9A
	db $F8, $08, $89
	db $08, $F8, $96
	db $10, $F8, $95
	db $80

Frame_6A45:	;$6A45
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F8, $43	;dx, dy, 4x3
	db $B8, $B7, $B6, $B5, $FF, $BA, $B9, $FF, $BE, $BD, $BC, $BB
	db $08, $F8, $B4
	db $10, $F8, $B3
	db $80

Frame_6A5F:	;$6A5F
	db $FC, $03, $F4, $0B	;hitbox
	db $F8, $F8, $23	;dx, dy, 2x3
	db $AD, $AC, $B0, $AF, $B2, $B1
	db $00, $F8, $AA
	db $08, $F8, $A9
	db $F8, $00, $AE
	db $10, $00, $AB
	db $80
