;Mega Man: Dr. Wily's Revenge disassembly - object type 30, CutMan
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "CutMan (type 30)", ROMX[$4744], BANK[$3]

;Cut Man (type 30), the boss of his stage. State $27: 0 drop in; 1 fill the bar
;(120 frames); 2 walk 1 px a frame, turning toward Mega Man only at a room edge,
;and jump when he is within $20 px; 3 jump arc (random X speed), landing at Y
;$65; 4 throw: face Mega Man and at frame 30 set $CCF6 = 1, which sends the
;type 31 placed beside him; 5 stand until frame 120, then walk or jump. He
;throws when his timer ($2D: 60 at landing, then 30-240 frames at random) runs
;out on the ground with the cutter home; frames with the cutter on his head are
;used while $CCF6 is 0. Killed: B = 0 only - type 31 ends the fight. Ice Slasher
;does nothing to him.	;[ok]
CutManRoutine:	;$4744
	ld a, b
	or a
	jr z, .l4756
	dec a
	jr z, .l4787
	dec a
	jp z, .l4753
	dec a
	jp z, CutManClearFreeze
.l4753
	ld b, $00
	ret
.l4756
	call InitBoss_03
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $34
	add a, c
	ld l, a
	ld [hl], $20
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $C0
	inc l
	ld [hl], $4A
	ld a, $35
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
	ld b, $01
	ret
.l4787
	ld a, [wFreezeFlags]
	or a
	jp nz, CutManClearFreeze
	ld a, $35
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4797
	dec [hl]
.l4797
	call StoreBossPosition_03
	ld a, [wStageSelectAnimPhase]
	xor $01
	ld e, a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, CutManDropIn
	dec a
	jr z, CutManIntro
	ld b, a
	call UpdateBossEnergy_03
	ld a, b
	dec a
	jp z, CutManWalk
	dec a
	jp z, CutManJump
	dec a
	jp z, CutManThrow
	jp CutManWaitAfterThrow

CutManCheckJumpTimer:	;$47C4
	ld a, $35
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret

CutManDropIn:	;$47CB
	call DropBossIn_03
	or a
	jr z, .l47EB
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	dec l
	ld [hl], $01
	dec l
	ld [hl], $00
	dec l
	ld [hl], $0F
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $3C
.l47EB
	ld b, $01
	ret

CutManIntro:	;$47EE
	call CutManAnimateStand
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $78
	jr c, .l4825
	ld [hl], $00
	dec l
	ld [hl], $00
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	call CutManStartWalk
.l4812
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
.l4825
	call FillBossEnergy_03
	jr .l4812

CutManWalk:	;$482A
	call ObjCheckOutsideArena_03
	ld a, d
	or a
	jr z, .l4842
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	jr .l484A
.l4842
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
.l484A
	call ObjMoveX_03
	call CutManCheckJumpTimer
	jr nz, .l485F
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	cp $02
	jr z, .l4867
	cp $03
	jr z, .l4867
.l485F
	call CutManCheckThrowTimer
	call CutManAnimateWalk
	jr .l486A
.l4867
	call CutManStartJump
.l486A
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

CutManJump:	;$487D
	call ObjArcStep_03
	call ObjCheckOutsideArena_03
	ld a, d
	or a
	jr nz, .l488A
	call ObjMoveX_03
.l488A
	call ObjMoveY_03
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l48D7
	ld [hl], $65
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $35
	add a, c
	ld l, a
	ld [hl], $14
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	call CutManCheckJumpTimer
	jr nz, .l48CA
	ld a, e
	sub $02
	jr c, .l48CA
	ld a, e
	sub $04
	jr nc, .l48CA
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	call CutManStartJump
	jr z, .l48E7
.l48CA
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	call CutManStartWalk
.l48D7
	call CutManCheckThrowTimer
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
.l48E7
	call CutManSetJumpFrame
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

CutManThrow:	;$48FD
	call ObjGetPlayerZoneX_03
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	ld e, a
	sub $1E
	jr nc, .l4914
	ld b, $00
	jr .l4926
.l4914
	ld a, $01
	ld [wStageSelectAnimPhase], a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, e
	sub $32
	jr nc, .l494C
	ld b, $01
.l4926
	ld e, $1C
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4932
	ld e, $1E
.l4932
	ld a, $17
	add a, c
	ld l, a
	ld a, e
	add a, b
	ld [hl], a
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
.l494C
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $0F
	ret

CutManWaitAfterThrow:	;$495F
	call CutManAnimateStand
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $78
	jr c, .l4991
	ld [hl], $00
	dec l
	ld [hl], $00
	call ObjGetPlayerZoneX_03
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ld a, e
	cp $02
	jr z, .l498E
	cp $03
	jr z, .l498E
	call CutManStartWalk
	jr .l4991
.l498E
	call CutManStartJump
.l4991
	call CutManCheckThrowTimer
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

CutManCheckThrowTimer:	;$49A7
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l49D4
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, CutManResetThrowTimer
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret nz
	call CutManResetThrowTimer
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ret
.l49D4
	dec [hl]
	ret

CutManResetThrowTimer:	;$49D6
	ld a, $2D
	add a, c
	ld l, a
	push hl
	ld e, $07
	call CutManRandomDelay
	pop hl
	ld [hl], e
	ret

CutManStartJump:	;$49E3
	push hl
	call JumpRNG
	pop hl
	and $07
	add a, $08
	ld e, a
	ld a, $31
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], $3C
	inc l
	ld [hl], $03
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $01
	ret

CutManStartWalk:	;$4A05
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $07
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $1D
	add a, c
	ld l, a
	ld [hl], $01
	ret

CutManRandomDelay:	;$4A1E
	call JumpRNG
	and e
	add a, $B8
	ld l, a
	ld a, $4A
	adc a, $00
	ld h, a
	ld e, [hl]
	ret

CutManAnimateWalk:	;$4A2C
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $07
	ret nz
	ld [hl], a
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	inc a
	and $03
	ld b, a
	ld [hl], b
	ld e, $04
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4A4C
	ld e, $08
.l4A4C
	ld d, $00
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4A58
	ld d, $08
.l4A58
	ld a, $17
	add a, c
	ld l, a
	ld a, e
	add a, b
	add a, d
	ld [hl], a
	ret

CutManSetJumpFrame:	;$4A61
	ld b, $00
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4A6D
	ld b, $01
.l4A6D
	ld e, $00
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4A79
	ld e, $02
.l4A79
	ld a, $17
	add a, c
	ld l, a
	ld a, b
	add a, e
	ld [hl], a
	ret

CutManAnimateStand:	;$4A81
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $0F
	ret nz
	ld [hl], a
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	ld b, a
	ld e, $14
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4AA0
	ld e, $16
.l4AA0
	ld d, $00
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4AAC
	ld d, $04
.l4AAC
	ld a, $17
	add a, c
	ld l, a
	ld a, e
	add a, b
	add a, d
	ld [hl], a
	ret

;Mode 3 (Ice Slasher), and every frame while wFreezeFlags is set: end the freeze at once.	;[ok]
CutManClearFreeze:	;$4AB5
	jp ObjClearFreeze_03

CutManThrowDelays:	;$4AB8
	db $1E, $3C, $5A, $78, $96, $B4, $D2, $F0

FrameTable_03_4AC0:	;$4AC0
	dw Frame_03_4CA3, Frame_03_4D44, Frame_03_4B7D, Frame_03_4C08
	dw Frame_03_4C5E, Frame_03_4C75, Frame_03_4C8C, Frame_03_4C75
	dw Frame_03_4CFF, Frame_03_4D16, Frame_03_4D2D, Frame_03_4D16
	dw Frame_03_4B4A, Frame_03_4B5B, Frame_03_4B6C, Frame_03_4B5B
	dw Frame_03_4BD8, Frame_03_4BE9, Frame_03_4BF7, Frame_03_4BE9
	dw Frame_03_4C19, Frame_03_4C30, Frame_03_4CBA, Frame_03_4CD1
	dw Frame_03_4B00, Frame_03_4B11, Frame_03_4B8E, Frame_03_4B9F
	dw Frame_03_4C47, Frame_03_4B33, Frame_03_4CE8, Frame_03_4BC1

Frame_03_4B00:	;$4B00
	db $FA, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

Frame_03_4B11:	;$4B11
	db $FA, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $09, $0A, $0B, $06, $07, $08
	db $80

Frame_03_4B22:	;$4B22
	db $F6, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $37, $38, $39, $3A, $3B, $3C, $06, $07, $08
	db $80

Frame_03_4B33:	;$4B33
	db $08, $01, $F6, $0B	;hitbox
	db $F5, $F4, $23	;dx, dy, 2x3
	db $17, $18, $1B, $1C, $1D, $1E
	db $10, $00, $19
	db $F8, $08, $1A
	db $10, $10, $1F
	db $80

Frame_03_4B4A:	;$4B4A
	db $F6, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $20, $21, $22, $23, $24, $25, $26, $27, $28
	db $80

Frame_03_4B5B:	;$4B5B
	db $F6, $01, $F4, $0B	;hitbox
	db $F4, $F4, $23	;dx, dy, 2x3
	db $29, $2A, $2B, $2C, $D9, $2E
	db $10, $08, $2D
	db $80

Frame_03_4B6C:	;$4B6C
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $2F, $30, $FF, $31, $32, $33, $34, $35, $36
	db $80

Frame_03_4B7D:	;$4B7D
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14
	db $80

Frame_03_4B8E:	;$4B8E
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $80

Frame_03_4B9F:	;$4B9F
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $8B, $8A, $89, $88, $87, $86
	db $80

Frame_03_4BB0:	;$4BB0
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B9, $B8, $B7, $BC, $BB, $BA, $88, $87, $86
	db $80

Frame_03_4BC1:	;$4BC1
	db $FA, $05, $F6, $0B	;hitbox
	db $FB, $F4, $23	;dx, dy, 2x3
	db $98, $97, $9C, $9B, $9E, $9D
	db $F8, $00, $99
	db $10, $08, $9A
	db $F8, $10, $9F
	db $80

Frame_03_4BD8:	;$4BD8
	db $FE, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $A2, $A1, $A0, $A5, $A4, $A3, $A8, $A7, $A6
	db $80

Frame_03_4BE9:	;$4BE9
	db $FE, $09, $F4, $0B	;hitbox
	db $FC, $F4, $23	;dx, dy, 2x3
	db $AA, $A9, $AC, $AB, $AE, $59
	db $80

Frame_03_4BF7:	;$4BF7
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $FF, $B0, $AF, $B3, $B2, $B1, $B6, $B5, $B4
	db $80

Frame_03_4C08:	;$4C08
	db $F6, $09, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8E, $8D, $8C, $91, $90, $8F, $94, $93, $92
	db $80

Frame_03_4C19:	;$4C19
	db $FA, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $06, $F8, $15
	db $0E, $F8, $95
	db $80

Frame_03_4C30:	;$4C30
	db $FA, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $09, $0A, $0B, $06, $07, $08
	db $06, $F8, $16
	db $0E, $F8, $96
	db $80

Frame_03_4C47:	;$4C47
	db $FA, $05, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $37, $38, $39, $3A, $3B, $3C, $06, $07, $08
	db $06, $F8, $15
	db $0E, $F8, $95
	db $80

Frame_03_4C5E:	;$4C5E
	db $F8, $05, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $20, $21, $22, $23, $24, $25, $26, $27, $28
	db $02, $FB, $15
	db $0A, $FB, $95
	db $80

Frame_03_4C75:	;$4C75
	db $F6, $01, $EE, $0B	;hitbox
	db $F4, $F4, $23	;dx, dy, 2x3
	db $29, $2A, $2B, $2C, $D9, $2E
	db $01, $F9, $16
	db $09, $F9, $96
	db $10, $08, $2D
	db $80

Frame_03_4C8C:	;$4C8C
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $2F, $30, $FF, $31, $32, $33, $34, $35, $36
	db $01, $FB, $15
	db $09, $FB, $95
	db $80

Frame_03_4CA3:	;$4CA3
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14
	db $03, $F8, $15
	db $0B, $F8, $95
	db $80

Frame_03_4CBA:	;$4CBA
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $02, $F8, $15
	db $0A, $F8, $95
	db $80

Frame_03_4CD1:	;$4CD1
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $8B, $8A, $89, $88, $87, $86
	db $02, $F8, $16
	db $0A, $F8, $96
	db $80

Frame_03_4CE8:	;$4CE8
	db $F6, $05, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B9, $B8, $B7, $BC, $BB, $BA, $88, $87, $86
	db $02, $F8, $15
	db $0A, $F8, $95
	db $80

Frame_03_4CFF:	;$4CFF
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $A2, $A1, $A0, $A5, $A4, $A3, $A8, $A7, $A6
	db $06, $FB, $15
	db $0E, $FB, $95
	db $80

Frame_03_4D16:	;$4D16
	db $FE, $09, $EE, $0B	;hitbox
	db $FC, $F4, $23	;dx, dy, 2x3
	db $AA, $A9, $AC, $AB, $AE, $59
	db $FF, $F9, $16
	db $07, $F9, $96
	db $F8, $08, $AD
	db $80

Frame_03_4D2D:	;$4D2D
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $FF, $B0, $AF, $B3, $B2, $B1, $B6, $B5, $B4
	db $07, $FB, $15
	db $0F, $FB, $95
	db $80

Frame_03_4D44:	;$4D44
	db $F6, $09, $EE, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8E, $8D, $8C, $91, $90, $8F, $94, $93, $92
	db $05, $F8, $15
	db $0D, $F8, $95
	db $80
