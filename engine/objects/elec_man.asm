;Mega Man: Dr. Wily's Revenge disassembly - object type 34, ElecMan
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ElecMan (type 34)", ROMX[$5E79], BANK[$3]

;Elec Man (type 34), the boss of his stage. State $27: 0 drop in; 1 intro poses
;while the bar fills; 2 run 1 px a frame to the next of X $76, $50, $2A, $50
;(ElecManTargetX, in turn); 3 face Mega Man and fire a type 35 (sound $1D,
;ElecManFireShot), then run on. While running, if Mega Man is in his shooting
;pose (wShootTimer) and timer $33 is out, he jumps at him. He never writes
;$CCF6: the type 37 placed in his room does nothing but end the fight. Killed:
;B = 0 only. Ice Slasher does nothing to him.	;[ok]
ElecManRoutine:	;$5E79
	ld a, b
	or a
	jr z, .l5E8B
	dec a
	jr z, .l5EAF
	dec a
	jp z, .l5E88
	dec a
	jp z, ElecManClearFreeze
.l5E88
	ld b, $00
	ret
.l5E8B
	call InitBoss_03
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $A9
	inc l
	ld [hl], $60
	inc l
	ld [hl], $00
	ld a, $2C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld a, $33
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $33
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret
.l5EAF
	ld a, [wFreezeFlags]
	or a
	jp nz, ElecManClearFreeze
	ld a, $33
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5EBF
	dec [hl]
.l5EBF
	inc l
	ld a, [hl]
	or a
	jr z, .l5EC5
	dec [hl]
.l5EC5
	call StoreBossPosition_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5EF5
	dec a
	jr z, .l5F18
	call UpdateBossEnergy_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jp z, ElecManShoot
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, ElecManAirborne
	call ElecManCheckJump
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	cp $02
	jr z, .l5F69
.l5EF5
	call DropBossIn_03
	or a
	jr z, .l5F15
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], $04
	inc l
	ld [hl], $01
.l5F15
	ld b, $01
	ret
.l5F18
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $08
	jr c, .l5F39
	cp $3C
	jr c, .l5F42
	cp $44
	jr c, .l5F4B
	call FillBossEnergy_03
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $7B
	jr z, .l5F54
	inc [hl]
.l5F36
	ld b, $01
	ret
.l5F39
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	jr .l5F36
.l5F42
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	jr .l5F36
.l5F4B
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $03
	jr .l5F36
.l5F54
	ld [hl], $06
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], $00
	call ElecManNextTarget
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	call GiveBossFullEnergy_03
	ret
.l5F69
	ld a, $35
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, b
	ld b, $00
	ld de, $FF00
	cp [hl]
	jr z, .l5FA7
	jr c, .l5F82
	ld b, $01
	ld de, $0100
.l5F82
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], b
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	call ElecManAnimateRun
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
.l5FA7
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l5FC0
	inc d
.l5FC0
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
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

;Unused: nothing calls it. Faces Mega Man.	;[ok]
ElecManFaceMegaManUnused:	;$5FD8
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l5FE3
	inc d
.l5FE3
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ret

ElecManShoot:	;$5FE9
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $07
	call z, ElecManFireShot
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $06
	jr c, .l601F
	cp $10
	jr c, .l6023
	ld [hl], $06
	call ElecManNextTarget
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
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
.l601F
	ld e, $00
	jr .l6025
.l6023
	ld e, $01
.l6025
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	add a, a
	ld d, a
	ld a, $17
	add a, c
	ld l, a
	ld a, $0A
	add a, e
	add a, d
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

ElecManAnimateRun:	;$604A
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	ret c
	ld [hl], $00
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	ld b, a
	ld d, $00
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l606A
	ld d, $02
.l606A
	ld a, $17
	add a, c
	ld l, a
	ld a, $04
	add a, b
	add a, d
	ld [hl], a
	ret

;Unused: nothing calls it. Updates the stage X; B = 1.	;[ok]
ElecManSyncStageXUnused:	;$6074
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

ElecManNextTarget:	;$6087
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	ld de, ElecManTargetX
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	inc a
	and $03
	ld [hl], a
	ld a, $35
	add a, c
	ld l, a
	ld [hl], b
	ret

;Mode 3 (Ice Slasher), and every frame while wFreezeFlags is set: end the freeze at once.	;[ok]
ElecManClearFreeze:	;$60A2
	jp ObjClearFreeze_03

ElecManTargetX:	;$60A5
	db $76, $50, $2A, $50

FrameTable_03_60A9:	;$60A9
	dw Frame_03_60C5, Frame_03_6161, Frame_03_60D6, Frame_03_60E7
	dw Frame_03_60FB, Frame_03_610C, Frame_03_618B, Frame_03_619C
	dw Frame_03_611D, Frame_03_6172, Frame_03_6136, Frame_03_614D
	dw Frame_03_61AD, Frame_03_61C4

Frame_03_60C5:	;$60C5
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

Frame_03_60D6:	;$60D6
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $09, $0A, $04, $0B, $0C, $0D, $0E
	db $80

Frame_03_60E7:	;$60E7
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $10, $11, $12, $13, $14, $15, $0C, $0D, $0E
	db $F8, $00, $0F
	db $80

Frame_03_60FB:	;$60FB
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $20, $04, $21, $22, $23, $24
	db $80

Frame_03_610C:	;$610C
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $25, $26, $27, $28, $29, $2A
	db $80

Frame_03_611D:	;$611D
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $24	;dx, dy, 2x4
	db $17, $18, $1A, $1B, $1D, $1E, $FF, $1F
	db $F8, $00, $16
	db $10, $00, $19
	db $10, $08, $1C
	db $80

Frame_03_6136:	;$6136
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $2C, $2D, $2E, $2F, $30, $31, $32, $33, $34
	db $03, $F8, $2B
	db $10, $F8, $2B
	db $80

Frame_03_614D:	;$614D
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $23	;dx, dy, 2x3
	db $35, $36, $38, $39, $B4, $3A
	db $F8, $08, $37
	db $10, $10, $3B
	db $80

Frame_03_6161:	;$6161
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $80

Frame_03_6172:	;$6172
	db $FA, $05, $F4, $0B	;hitbox
	db $FC, $F4, $24	;dx, dy, 2x4
	db $98, $97, $9B, $9A, $9E, $9D, $9F, $FF
	db $F8, $00, $99
	db $10, $00, $96
	db $F8, $08, $9C
	db $80

Frame_03_618B:	;$618B
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $A1, $84, $A0, $A4, $A3, $A2
	db $80

Frame_03_619C:	;$619C
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $A7, $A6, $A5, $AA, $A9, $A8
	db $80

Frame_03_61AD:	;$61AD
	db $FA, $05, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $AE, $AD, $AC, $B1, $B0, $AF, $B4, $B3, $B2
	db $00, $F8, $AB
	db $0D, $F8, $AB
	db $80

Frame_03_61C4:	;$61C4
	db $FA, $05, $F4, $0B	;hitbox
	db $FC, $F4, $23	;dx, dy, 2x3
	db $B6, $B5, $B9, $B8, $BA, $34
	db $10, $08, $B7
	db $F8, $10, $BB
	db $80

ElecManCheckJump:	;$61D8
	ld a, $33
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret nz
	ld a, [wShootTimer]
	or a
	ret z
	pop de
	ld a, [wPlayerX]
	ld e, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp e
	ld de, ElecManJumpLeftVelocity
	jr nc, .l61F7
	ld de, ElecManJumpRightVelocity
.l61F7
	call ObjSetVelocity_03
	ld a, $2C
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

ElecManJumpLeftVelocity:	;$6213
	db $40, $FF, $80, $FB
ElecManJumpRightVelocity:	;$6217
	db $C0, $00, $80, $FB

ElecManAirborne:	;$621B
	call ObjApplyGravity_03
	call ObjMoveByVelocity_03
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $16
	jr nc, .l622E
	ld a, $16
	jr .l6234
.l622E
	cp $89
	jr c, .l6234
	ld a, $89
.l6234
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $65
	jr c, .l6250
	ld a, $33
	add a, c
	ld l, a
	ld [hl], $14
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $0F
	add a, c
	ld l, a
	ld a, $65
.l6250
	ld [hl], a
	ld a, $1D
	add a, c
	ld l, a
	ld a, [hl]
	rlca
	xor $01
	and $01
	ld e, a
	ld a, $24
	add a, c
	ld l, a
	ld [hl], e
	ld a, e
	add a, $08
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
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

ElecManFireShot:	;$627D
	ld a, $33
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret nz
	ld [hl], $28
	ld a, $1D
	call JumpQueueSound
	ld l, c
	push hl
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	ld d, $EF
	or a
	jr z, .l6299
	ld d, $10
.l6299
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [$CC0D], a
	ld a, $23
	ld [$CC07], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $3C
	ld [$CC05], a
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	push af
	call SpawnChildObject_03
	pop af
	and $01
	ld e, a
	call ElecManShotInit
	pop hl
	ld c, l
	ret
