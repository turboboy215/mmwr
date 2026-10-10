;Mega Man: Dr. Wily's Revenge disassembly - object type 36, FireMan
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FireMan (type 36)", ROMX[$6537], BANK[$3]

;Fire Man (type 36), the boss of his stage (and of the unused alternate one).
;State $27: 0 drop in; 1 intro poses while the bar fills; 4 pick a spot $30 px
;from Mega Man on Fire Man's side (the far side if that is off the room); 2 walk
;there 1 px a frame; on arrival, if Mega Man is exactly $30 away (he has not
;moved), 3 attack: $CCF6 = 1 asks the type 37 for a shot (sound $1C), 30 frames
;in the attack pose, 50 standing, then back to 4. Killed: B = 0 only (type 37
;ends the fight). Frozen: nothing moves.	;[ok]
FireManRoutine:	;$6537
	ld a, b
	or a
	jr z, .l6549
	dec a
	jr z, .l6564
	dec a
	jp z, .l6546
	dec a
	jp z, FireManFrozen
.l6546
	ld b, $00
	ret
.l6549
	call InitBoss_03
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $C4
	inc l
	ld [hl], $67
	ld e, $00
	inc l
	ld [hl], e
	ld a, $29
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld b, $01
	ret
.l6564
	ld a, [wFreezeFlags]
	or a
	jp nz, FireManFrozen
	call FireManClampTargetX
	call StoreBossPosition_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l658D
	dec a
	jr z, FireManIntro
	ld b, a
	call UpdateBossEnergy_03
	ld a, b
	dec a
	jp z, FireManWalk
	dec a
	jp z, FireManAttack
	dec a
	jp z, FireManChooseMove
.l658D
	call DropBossIn_03
	or a
	jr z, .l65A9
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $29
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret
.l65A9
	call FireManAnimatePair
	ld b, $01
	ret

FireManClampTargetX:	;$65AF
	ld a, $30
	add a, c
	ld l, a
	ld a, [hl]
	cp $96
	jr c, .l65BC
	ld a, $1C
	jr .l65C1
.l65BC
	cp $8A
	ret c
	ld a, $8A
.l65C1
	ld [hl], a
	ret

FireManIntro:	;$65C3
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp $06
	jr c, .l65FB
	cp $3C
	jr c, .l6604
	cp $44
	jr c, .l65FB
	call FillBossEnergy_03
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp $98
	jr c, .l6610
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $18
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2A
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], $0B
	inc l
	ld [hl], b
	inc l
	ld [hl], $00
.l65F8
	ld b, $01
	ret
.l65FB
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04
	jr .l65F8
.l6604
	inc [hl]
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	call FireManAnimatePair
	jr .l65F8
.l6610
	inc [hl]
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $05
	call FireManAnimatePair
	jr .l65F8

FireManAnimatePair:	;$661C
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $07
	ret nz
	ld [hl+], a
	ld a, [hl]
	xor $01
	ld [hl+], a
	inc l
	add a, [hl]
	ld b, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

FireManWalk:	;$6633
	call FireManWalkCheckStub
	or a
	jr nz, FireManToAttack
	ld a, $30
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld b, $01
	ld e, $01
	cp d
	jr z, FireManToChoose
	jr c, .l6650
	ld b, $FF
	ld e, $00
.l6650
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld [hl], a
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], e
	call FireManAnimateWalk
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

;FireManStartAttack (state 3), update the stage X; B = 1.	;[ok]
FireManToAttack:	;$6672
	call FireManStartAttack
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

;FireManStartChoose (state 4), update the stage X; B = 1. Reached on arriving at
;the target X and after the attack's 80 frames.	;[ok]
FireManToChoose:	;$6688
	call FireManStartChoose
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

FireManAttack:	;$669E
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $1E
	jr c, .l66AE
	cp $50
	jr c, FireManAttackStand
	jr FireManToChoose
.l66AE
	ld b, $07
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l66BC
	ld b, $09
.l66BC
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], b
	call FireManAnimatePair
	ld b, $01
	ret

FireManChooseMove:	;$66C7
	call FireManSetTargetX
	call FireManCheckAttackDistance
	or a
	jr nz, FireManToAttack
	jr FireManToWalk

;Attack frames 30-79: the standing pair of frames (FireManAnimatePair, facing
;Mega Man), update the stage X; B = 1.	;[ok]
FireManAttackStand:	;$66D2
	ld b, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l66E0
	ld b, $02
.l66E0
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], b
	call FireManAnimatePair
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

;FireManStartWalk (state 2), update the stage X; B = 1.	;[ok]
FireManToWalk:	;$66FB
	call FireManStartWalk
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

FireManStartAttack:	;$6711
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $01
	ld [wStageSelectAnimPhase], a
	ld a, $1C
	call JumpQueueSound
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
	ld a, $32
	add a, c
	ld l, a
	ld [hl], $06
	ret

FireManStartWalk:	;$6731
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $18
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ret

FireManStartChoose:	;$6743
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $01
	ret

;Returns A = 0, always: FireManWalk's `or a / jr nz, FireManToAttack` after
;the call is never taken. A check that does nothing in this build.	;[ok]
FireManWalkCheckStub:	;$6756
	xor a
	ret

FireManCheckAttackDistance:	;$6758
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l6764
	cpl
	inc a
.l6764
	cp $30
	jr z, .l676A
	xor a
	ret
.l676A
	ld a, $01
	or a
	ret

FireManAnimateWalk:	;$676E
	ld a, $32
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	ret c
	ld [hl], $00
	ld a, $2E
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	ld [hl+], a
	ld d, a
	ld e, $0B
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l678F
	ld e, $0F
.l678F
	ld a, e
	add a, d
	ld d, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], d
	ret

FireManSetTargetX:	;$6798
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	ld b, a
	ld e, [hl]
	cp e
	jr c, .l67B1
	ld a, b
	sub $30
	jr c, .l67AD
	cp $1C
	jr nc, .l67BA
.l67AD
	add a, $60
	jr .l67BA
.l67B1
	ld a, b
	add a, $30
	cp $8A
	jr c, .l67BA
	sub $60
.l67BA
	ld d, a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], d
	ret

FireManFrozen:	;$67C1
	jp ObjClearFreeze_03

FrameTable_03_67C4:	;$67C4
	dw Frame_03_67EA, Frame_03_6801, Frame_03_6897, Frame_03_68AE
	dw Frame_03_6944, Frame_03_695B, Frame_03_6972, Frame_03_6818
	dw Frame_03_6838, Frame_03_68C5, Frame_03_68E5, Frame_03_6858
	dw Frame_03_6871, Frame_03_6881, Frame_03_6871, Frame_03_6905
	dw Frame_03_691E, Frame_03_692E, Frame_03_691E

Frame_03_67EA:	;$67EA
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $04, $05, $06, $07, $08, $09, $0A, $0B, $0C
	db $04, $F8, $00
	db $0C, $F8, $01
	db $80

Frame_03_6801:	;$6801
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $04, $05, $06, $07, $08, $09, $0A, $0B, $0C
	db $04, $F8, $02
	db $0C, $F8, $03
	db $80

Frame_03_6818:	;$6818
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $FC, $32	;dx, dy, 3x2
	db $1D, $1E, $1F, $20, $0B, $21
	db $03, $F0, $00
	db $0B, $F0, $01
	db $FE, $F8, $04
	db $06, $F8, $05
	db $0E, $F8, $06
	db $F8, $00, $1C
	db $80

Frame_03_6838:	;$6838
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $FC, $32	;dx, dy, 3x2
	db $1D, $1E, $1F, $20, $0B, $21
	db $03, $F0, $02
	db $0B, $F0, $03
	db $FE, $F8, $04
	db $06, $F8, $05
	db $0E, $F8, $06
	db $F8, $00, $1C
	db $80

Frame_03_6858:	;$6858
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $22, $23, $24, $25, $27, $28, $2A, $2B
	db $F8, $10, $26
	db $10, $10, $29
	db $10, $18, $2C
	db $80

Frame_03_6871:	;$6871
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $2D, $2E, $2F, $30, $31, $32, $33, $34
	db $80

Frame_03_6881:	;$6881
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $22, $23, $24, $35, $36, $37, $39, $3A
	db $10, $10, $38
	db $10, $18, $3B
	db $80

Frame_03_6897:	;$6897
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $86, $85, $84, $89, $88, $87, $8C, $8B, $8A
	db $04, $F8, $81
	db $0C, $F8, $80
	db $80

Frame_03_68AE:	;$68AE
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $86, $85, $84, $89, $88, $87, $8C, $8B, $8A
	db $04, $F8, $83
	db $0C, $F8, $82
	db $80

Frame_03_68C5:	;$68C5
	db $F4, $0B, $FC, $0B	;hitbox
	db $F4, $FC, $32	;dx, dy, 3x2
	db $9F, $9E, $9D, $A1, $8B, $A0
	db $05, $F0, $81
	db $0D, $F0, $80
	db $02, $F8, $86
	db $0A, $F8, $85
	db $12, $F8, $84
	db $18, $00, $9C
	db $80

Frame_03_68E5:	;$68E5
	db $F4, $0B, $FC, $0B	;hitbox
	db $F4, $FC, $32	;dx, dy, 3x2
	db $9F, $9E, $9D, $A1, $8B, $A0
	db $05, $F0, $83
	db $0D, $F0, $82
	db $02, $F8, $86
	db $0A, $F8, $85
	db $12, $F8, $84
	db $18, $00, $9C
	db $80

Frame_03_6905:	;$6905
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $A3, $A2, $A5, $A4, $A8, $A7, $AB, $AA
	db $F8, $10, $A9
	db $10, $10, $A6
	db $F8, $18, $AC
	db $80

Frame_03_691E:	;$691E
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $AE, $AD, $B0, $AF, $B2, $B1, $B4, $B3
	db $80

Frame_03_692E:	;$692E
	db $FA, $05, $F4, $0B	;hitbox
	db $F8, $EC, $24	;dx, dy, 2x4
	db $A3, $A2, $B5, $A4, $B7, $B6, $BA, $B9
	db $F8, $10, $B8
	db $F8, $18, $BB
	db $80

Frame_03_6944:	;$6944
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0D, $0E, $0F, $10, $11, $12, $9B, $0B, $13
	db $04, $F8, $00
	db $0C, $F8, $01
	db $80

Frame_03_695B:	;$695B
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $14, $15, $16, $17, $18, $19, $1A, $8B, $1B
	db $05, $F9, $00
	db $0D, $F9, $01
	db $80

Frame_03_6972:	;$6972
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $14, $15, $16, $17, $18, $19, $1A, $8B, $1B
	db $05, $F9, $02
	db $0D, $F9, $03
	db $80

Frame_03_6989:	;$6989
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $04, $05, $06, $07, $08, $09, $3C, $3D, $3E
	db $04, $F8, $00
	db $0C, $F8, $01
	db $0C, $12, $3F
	db $80
