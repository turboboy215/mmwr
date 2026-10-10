;Mega Man: Dr. Wily's Revenge disassembly - object type 32, IceMan
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "IceMan (type 32)", ROMX[$4D5B], BANK[$3]

;Ice Man (type 32), the boss of his stage. State $27: 0 drop in; 1 intro poses
;while the bar fills; 2 attack: shoot, rise 25 px, shoot, sink to Y $65, twice -
;four shots, each a write of $CCF6 = 1 (sound $1B) answered by one of the three
;type 33s; 3 walk 1 px a frame for 30 frames in direction $2E; 4 slide to a
;stop, reverse $2E and attack again. So he paces back and forth whatever Mega
;Man does. Killed: B = 0 only (the type 33s end the fight). Frozen: nothing
;moves.	;[ok]
IceManRoutine:	;$4D5B
	ld a, b
	or a
	jr z, .l4D6D
	dec a
	jr z, .l4D93
	dec a
	jp z, .l4D6A
	dec a
	jp z, IceManClearFreeze
.l4D6A
	ld b, $00
	ret
.l4D6D
	call InitBoss_03
	ld a, $34
	add a, c
	ld l, a
	ld [hl], $20
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $26
	inc l
	ld [hl], $50
	inc l
	ld [hl], $03
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
.l4D93
	ld a, [wFreezeFlags]
	or a
	jp nz, IceManClearFreeze
	call StoreBossPosition_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4DBA
	dec a
	jr z, .l4DE0
	ld b, a
	call UpdateBossEnergy_03
	ld a, b
	dec a
	jp z, .l4E24
	dec a
	jp z, .l4EE1
	dec a
	jp z, .l4F53
	ret
.l4DBA
	call DropBossIn_03
	or a
	jr z, .l4DDD
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl], a
	inc l
	ld [hl], a
	inc l
	ld [hl], a
	ld a, $2E
	add a, c
	ld l, a
	xor a
	ld [hl], a
	inc l
	ld [hl], a
.l4DDD
	ld b, $01
	ret
.l4DE0
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $08
	jr z, .l4E01
	cp $3C
	jr z, .l4E0A
	cp $44
	jr z, .l4E13
	call FillBossEnergy_03
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $7B
	jr z, .l4E1C
	inc [hl]
.l4DFE
	ld b, $01
	ret
.l4E01
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	jr .l4DFE
.l4E0A
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $01
	jr .l4DFE
.l4E13
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	jr .l4DFE
.l4E1C
	inc [hl]
	ld [hl], $00
	call IceManStartAttack
	jr .l4DFE
.l4E24
	ld a, $35
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4E59
	dec a
	jr z, .l4E8D
	dec a
	jr z, .l4E59
	dec a
	jr z, .l4EB4
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4E47
	inc [hl]
	ld a, $35
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret
.l4E47
	ld a, $35
	add a, c
	ld l, a
	ld [hl], $00
	call IceManStartWalk
	ld b, $01
	ret
.l4E53
	call IceManFaceMegaMan
	ld b, $01
	ret
.l4E59
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4E6B
	ld a, $01
	ld [wStageSelectAnimPhase], a
	ld a, $1B
	call JumpQueueSound
.l4E6B
	ld [hl], $07
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $0A
	jr nc, .l4E79
	inc [hl]
	jr .l4E53
.l4E79
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $35
	add a, c
	ld l, a
	inc [hl]
	jp .l4E53
.l4E8D
	ld e, $0A
	call ObjStepY_03
	call ObjMoveY_03
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $28
	jp c, .l4E53
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $35
	add a, c
	ld l, a
	inc [hl]
	jp .l4E53
.l4EB4
	ld e, $F6
	call ObjStepY_03
	call ObjMoveY_03
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $28
	jp c, .l4E53
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $35
	add a, c
	ld l, a
	inc [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $65
	jp .l4E53
.l4EE1
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0B
	jr c, .l4EFC
	ld [hl], $00
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	xor $01
	add a, $04
	ld [hl], a
	call IceManSetWalkFrame
.l4EFC
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4F15
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $1E
	jr nc, .l4F26
	ld a, $0D
	add a, c
	ld l, a
	inc [hl]
	jr .l4F40
.l4F15
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $1E
	jr nc, .l4F26
	ld a, $0D
	add a, c
	ld l, a
	dec [hl]
	jr .l4F40
.l4F26
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl], a
	inc l
	ld [hl], a
	inc l
	ld [hl], $10
	inc l
	ld [hl], $06
	ld a, $0C
	add a, c
	ld l, a
	ld [hl], $10
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
.l4F40
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
.l4F53
	call IceManSetWalkFrame
	ld a, $28
	add a, c
	ld l, a
	ld [hl], a
	xor $01
	ld [hl], a
	jr z, .l4F67
	call IceManSlideStep
	ld a, e
	or a
	jr z, .l4F83
.l4F67
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4F79
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld [hl], a
	jp .l4F40
.l4F79
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub b
	ld [hl], a
	jp .l4F40
.l4F83
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	call IceManStartAttack
	ld b, $01
	ret

IceManSlideStep:	;$4F91
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l4FAE
	ld [hl], a
	ld b, a
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld b, a
	and $0F
	ld [hl], a
	ld a, b
	swap a
	and $0F
	ld b, a
	ld e, $01
	ret
.l4FAE
	ld [hl], a
	ld e, $00
	ret

IceManFaceMegaMan:	;$4FB2
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $2B
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, [wPlayerX]
	sub e
	jr c, .l4FD2
	ld a, $08
	add a, b
	ld b, a
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], $00
.l4FD2
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

IceManSetWalkFrame:	;$4FD8
	ld a, $2B
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4FE9
	ld a, $08
	add a, b
	ld b, a
.l4FE9
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

IceManStartAttack:	;$4FEF
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl], a
	inc l
	inc l
	ld [hl], a
	inc l
	ld [hl], a
	ret

IceManStartWalk:	;$5001
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $0C
	inc l
	inc l
	ld [hl], $00
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ret

IceManClearFreeze:	;$5018
	ld a, $20
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $22
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ret

FrameTable_03_5026:	;$5026
	dw Frame_03_5046, Frame_03_5057, Frame_03_5068, Frame_03_5079
	dw Frame_03_508D, Frame_03_509E, Frame_03_50AF, Frame_03_50C3
	dw Frame_03_50D4, Frame_03_5057, Frame_03_5068, Frame_03_5079
	dw Frame_03_50E5, Frame_03_50F6, Frame_03_5107, Frame_03_511B

Frame_03_5046:	;$5046
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

Frame_03_5057:	;$5057
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11
	db $80

Frame_03_5068:	;$5068
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $12, $01, $02, $13, $14, $15, $16, $07, $17
	db $80

Frame_03_5079:	;$5079
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $18, $19, $1A
	db $0D, $18, $1B
	db $80

Frame_03_508D:	;$508D
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24
	db $80

Frame_03_509E:	;$509E
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $25, $26, $27, $28, $29, $2A, $2B, $2C, $2D
	db $80

Frame_03_50AF:	;$50AF
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $A7, $2E, $2F, $30, $31, $32, $34, $35, $36
	db $18, $08, $33
	db $80

Frame_03_50C3:	;$50C3
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
	db $80

Frame_03_50D4:	;$50D4
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $80

Frame_03_50E5:	;$50E5
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $9E, $9D, $9C, $A1, $A0, $9F, $A4, $A3, $A2
	db $80

Frame_03_50F6:	;$50F6
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $A7, $A6, $A5, $AA, $A9, $A8, $AD, $AC, $AB
	db $80

Frame_03_5107:	;$5107
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $AF, $AE, $27, $B2, $B1, $B0, $B6, $B5, $B4
	db $F8, $08, $B3
	db $80

Frame_03_511B:	;$511B
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $B9, $B8, $B7, $BC, $BB, $BA, $BF, $BE, $BD
	db $80
