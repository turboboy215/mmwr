;Mega Man: Dr. Wily's Revenge disassembly - object type 46, QuickMan
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "QuickMan (type 46)", ROMX[$5A76], BANK[$D]

;Quick Man (type 46), the boss behind Wily 2's first teleporter. State $27: 0
;drop in; 1 intro poses while the bar fills; 4 run 2 px a frame (within X
;$1C-$88) for 120 frames, then 3: two jumps at Mega Man (X speed half his
;distance, a random Y speed from QuickManJumpSpeeds). On one of the jumps,
;picked at random ($2B: the first 2 times in 4, the second 1 in 4, none 1 in
;4), once he is falling he sets $CCF6 = $30 | (direction * 2 + 1)
;(GetDirectionToPoint): three type 47s fly out. Killed: B = 0 only (type 47
;ends the fight). Time Stopper (wFreezeFlags bit 3) stops him and takes a hit
;point every 50 frames; other freezes just stop him.	;[ok]
QuickManRoutine:	;$5A76
	ld a, b
	or a
	jr z, QuickManInit
	dec a
	jr z, QuickManFrame
	dec a
	jp z, .l5A85
	dec a
	jp z, QuickManClearFreeze
.l5A85
	ld b, $00
	ret

;Mode 3 (Ice Slasher), and every frame while wFreezeFlags is set: end the freeze at once.	;[ok]
QuickManClearFreeze:	;$5A88
	jp ObjClearFreeze_0D

;Mode 0: InitBoss_0D, his frame table, $36 (Time Stopper count) = 0, stage X.
;It does not set B, so B returns 0 as passed in - as Ice Man's, Heat Man's and
;Bubble Man's inits do; Cut, Elec, Fire, Flash Man and Enker set B = 1.	;[ok]
QuickManInit:	;$5A8B
	call InitBoss_0D
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_0D_5D00)
	inc l
	ld [hl], HIGH(FrameTable_0D_5D00)
	inc l
	ld [hl], $0B
	ld a, $36
	add a, c
	ld l, a
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

QuickManTimeStopperDamage:	;$5AB1
	ld a, $36
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $32
	jr c, .l5AC5
	ld [hl], $00
	ld a, $18
	add a, c
	ld l, a
	dec [hl]
	call UpdateBossEnergy_0D
.l5AC5
	jp QuickManClearFreeze

QuickManFrame:	;$5AC8
	ld a, [wFreezeFlags]
	bit 3, a
	jr nz, QuickManTimeStopperDamage
	or a
	jp nz, QuickManClearFreeze
	ld a, $36
	add a, c
	ld l, a
	ld [hl], $00
	call StoreBossPosition_0D
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5AF7
	dec a
	jr z, QuickManIntro
	ld b, a
	call UpdateBossEnergy_0D
	ld a, b
	dec a
	jp z, QuickManJump
	dec a
	jp z, QuickManJump
	jp QuickManRun
.l5AF7
	call DropBossIn_0D
	or a
	jr z, QuickManEndFrame
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld e, $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], e

;B = 1.	;[ok]
QuickManEndFrame:	;$5B11
	ld b, $01
	ret

QuickManIntro:	;$5B14
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $3C
	jr c, QuickManEndFrame
	jp z, .l5B55
	cp $42
	jr c, QuickManEndFrame
	jp z, .l5B55
	ld b, a
	call FillBossEnergy_0D
	ld a, b
	cp $48
	jr c, QuickManEndFrame
	jr z, .l5B55
	cp $4E
	jr c, QuickManEndFrame
	jr z, .l5B55
	cp $54
	jr c, QuickManEndFrame
	jr z, .l5B55
	cp $5A
	jr c, QuickManEndFrame
	jr z, .l5B55
	cp $60
	jr c, QuickManEndFrame
	jr z, .l5B5C
	cp $A0
	jr c, .l5B52
	call QuickManStartRun
.l5B52
	ld b, $01
	ret
.l5B55
	ld a, $17
	add a, c
	ld l, a
	inc [hl]
	jr .l5B52
.l5B5C
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	jr .l5B52

QuickManJump:	;$5B64
	call ObjArcStep_0D
	ld a, $0D
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5B79
	ld a, d
	cp $88
	jr nc, .l5B81
.l5B79
	ld a, d
	cp $18
	jr c, .l5B81
	call ObjMoveX_0D
.l5B81
	call ObjMoveY_0D
	ld a, $2B
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $2C
	add a, c
	ld l, a
	ld a, e
	cp [hl]
	jr nz, .l5BC9
	ld a, $1F
	add a, c
	ld l, a
	ld a, [hl]
	and $80
	jr nz, .l5BC9
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5BC9
	ld a, [wStageSelectAnimPhase]
	or a
	jr nz, .l5BC9
	ld [hl], $01
	push bc
	ld a, $0F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, [wPlayerX]
	ld c, a
	ld a, [wPlayerY]
	ld b, a
	call GetDirectionToPoint
	pop bc
	sla a
	inc a
	or $30
	ld [wStageSelectAnimPhase], a
.l5BC9
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l5BE6
	ld [hl], $65
	ld a, $2C
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $02
	jr nz, .l5BE3
	call QuickManStartRun
	jr .l5BE6
.l5BE3
	call QuickManStartJump
.l5BE6
	ld e, $0B
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5BF8
	inc [hl]
	ld a, [hl]
	cp $0A
	jr nc, .l5BF8
	ld e, $0C
.l5BF8
	ld a, $30
	add a, c
	ld l, a
	ld [hl], e
	call QuickManSetFrame
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

QuickManRun:	;$5C13
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5C29
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $88
	jr nc, .l5C35
	add a, $02
	ld [hl], a
	jr .l5C35
.l5C29
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $1C
	jr c, .l5C35
	sub $02
	ld [hl], a
.l5C35
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $78
	jr c, .l5C5F
	ld [hl], $00
	dec hl
	ld [hl], $03
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
	push hl
	call JumpRNG
	and $03
	pop hl
	cp $03
	jr nz, .l5C56
	xor a
.l5C56
	ld d, a
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], d
	call QuickManStartJump
.l5C5F
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	jr nz, .l5C76
	ld [hl], a
	ld a, $30
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0B
	jr c, .l5C76
	ld [hl], $07
.l5C76
	call QuickManSetFrame
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

QuickManSetFrame:	;$5C8C
	ld e, $00
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5C98
	ld e, $06
.l5C98
	ld a, $30
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

QuickManStartJump:	;$5CA5
	call ObjFaceMegaMan_0D
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	ld e, $FF
	cp $7F
	jr c, .l5CBC
	xor e
.l5CBC
	srl a
	ld e, a
	push hl
	push de
	call JumpRNG
	and $03
	ld hl, QuickManJumpSpeeds
	ld d, $00
	ld e, a
	add hl, de
	ld a, [hl]
	pop de
	pop hl
	ld d, a
	ld a, $31
	add a, c
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	ld [hl], $03
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $00
	ret

QuickManStartRun:	;$5CE2
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	inc hl
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $07
	call ObjFaceMegaMan_0D
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ret

QuickManJumpSpeeds:	;$5CFC
	db $3A, $3C, $44, $46

FrameTable_0D_5D00:	;$5D00
	dw Frame_0D_5D26, Frame_0D_5D3D, Frame_0D_5D57, Frame_0D_5E69
	dw Frame_0D_5E7D, Frame_0D_5E91, Frame_0D_5EAB, Frame_0D_5D6B
	dw Frame_0D_5D82, Frame_0D_5D99, Frame_0D_5D82, Frame_0D_5DB0
	dw Frame_0D_5DCD, Frame_0D_5DEA, Frame_0D_5E01, Frame_0D_5E18
	dw Frame_0D_5E01, Frame_0D_5E2F, Frame_0D_5E4C

Frame_0D_5D26:	;$5D26
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $02, $03, $04, $05, $06, $07, $08, $09, $0A
	db $00, $F8, $00
	db $10, $F8, $01
	db $80

Frame_0D_5D3D:	;$5D3D
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0C, $0D, $FF, $0E, $0F, $10, $11, $12, $13
	db $FC, $F8, $00
	db $0C, $F8, $01
	db $F8, $00, $0B
	db $80

Frame_0D_5D57:	;$5D57
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D
	db $10, $F8, $14
	db $80

Frame_0D_5D6B:	;$5D6B
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $30, $31, $32, $33, $34, $35, $36, $37, $38
	db $FF, $F8, $00
	db $0F, $F8, $01
	db $80

Frame_0D_5D82:	;$5D82
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $30, $31, $32, $39, $34, $35, $3A, $3B, $3C
	db $FF, $F8, $00
	db $0F, $F8, $01
	db $80

Frame_0D_5D99:	;$5D99
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $30, $31, $32, $39, $34, $35, $3D, $3E, $3F
	db $FF, $F8, $00
	db $0F, $F8, $01
	db $80

Frame_0D_5DB0:	;$5DB0
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $FF, $FF, $2F, $FF
	db $F8, $00, $26
	db $FE, $F8, $00
	db $0E, $F8, $01
	db $80

Frame_0D_5DCD:	;$5DCD
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $40, $41, $42, $44, $45, $46, $2D, $2E, $FF, $FF, $2F, $FF
	db $F8, $08, $43
	db $FD, $F9, $00
	db $0D, $F9, $01
	db $80

Frame_0D_5DEA:	;$5DEA
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B2, $B1, $B0, $B5, $B4, $B3, $B8, $B7, $B6
	db $01, $F8, $81
	db $11, $F8, $80
	db $80

Frame_0D_5E01:	;$5E01
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B2, $B1, $B0, $B5, $B4, $B9, $BC, $BB, $BA
	db $01, $F8, $81
	db $11, $F8, $80
	db $80

Frame_0D_5E18:	;$5E18
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B2, $B1, $B0, $B5, $B4, $B9, $BF, $BE, $BD
	db $01, $F8, $81
	db $11, $F8, $80
	db $80

Frame_0D_5E2F:	;$5E2F
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $A9, $A8, $A7, $AC, $AB, $AA, $FF, $AE, $AD, $FF, $AF, $FF
	db $18, $00, $A6
	db $02, $F8, $81
	db $12, $F8, $80
	db $80

Frame_0D_5E4C:	;$5E4C
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $C2, $C1, $C0, $C6, $C5, $C4, $FF, $AE, $AD, $FF, $AF, $FF
	db $18, $08, $C3
	db $03, $F9, $81
	db $13, $F9, $80
	db $80

Frame_0D_5E69:	;$5E69
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $20, $16, $17, $18, $19, $1A, $1B, $1C, $1D
	db $10, $F8, $14
	db $80

Frame_0D_5E7D:	;$5E7D
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $1E, $1F, $17, $18, $19, $1A, $1B, $1C, $1D
	db $10, $F8, $14
	db $80

Frame_0D_5E91:	;$5E91
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $15, $21, $17, $18, $19, $1A, $1B, $1C, $1D
	db $10, $F8, $22
	db $10, $FA, $23
	db $10, $02, $24
	db $80

Frame_0D_5EAB:	;$5EAB
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $15, $16, $17, $18, $19, $1A, $1B, $1C, $1D
	db $10, $F8, $14
	db $10, $FA, $24
	db $80
