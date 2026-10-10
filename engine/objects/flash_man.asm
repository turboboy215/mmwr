;Mega Man: Dr. Wily's Revenge disassembly - object type 42, FlashMan
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FlashMan (type 42)", ROMX[$6CFE], BANK[$9]

;Flash Man (type 42), the boss behind Wily 2's third teleporter. Drops in,
;poses while his bar fills, then walks toward Mega Man 1 px a frame, jumping at
;him at a room edge or after losing hit points. When his attack timer ($2D)
;wraps he poses, spawns a type 54 (FlashManSpawnFreeze), then fires six enemy
;shots 10 frames apart (FlashManFireShot). Holds still while wFreezeFlags bits
;0-3 are set; bit 4, which his own type 54 sets, does not stop him. Killed: B =
;0 only; the type 43 in his room ends the fight.	;[ok]
FlashManRoutine:	;$6CFE
	ld a, b
	or a
	jr z, .l6D10
	dec a
	jr z, .l6D32
	dec a
	jp z, .l6D0D
	dec a
	jp z, FlashManClearFreeze
.l6D0D
	ld b, $00
	ret
.l6D10
	call InitBoss_09
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_7044)
	inc l
	ld [hl], HIGH(FrameTable_7044)
	inc l
	ld [hl], $0A
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
.l6D32
	ld a, [wFreezeFlags]
	and $0F
	jp nz, FlashManClearFreeze
	call StoreBossPosition_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6D5C
	dec a
	jr z, .l6D76
	ld b, a
	call UpdateBossEnergy_09
	ld a, b
	dec a
	jp z, .l6DDF
	dec a
	jp z, .l6E4C
	dec a
	jp z, .l6EC1
	jp .l6F4B
.l6D5C
	call DropBossIn_09
	or a
	jr z, .l6D73
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
.l6D73
	ld b, $01
	ret
.l6D76
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld b, [hl]
	ld a, $17
	add a, c
	ld l, a
	ld a, b
	cp $3C
	jr c, .l6D73
	jr z, .l6DD8
	cp $42
	jr z, .l6DD8
	ld b, a
	call FillBossEnergy_09
	ld a, b
	cp $48
	jr z, .l6DD8
	cp $4E
	jr z, .l6DD8
	cp $54
	jr z, .l6DD8
	cp $5A
	jr z, .l6DD8
	cp $60
	jr z, .l6DDB
	cp $90
	jr nz, .l6DC5
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	call FlashManStartWalk
	ld a, $18
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], b
	inc hl
	ld [hl], $00
.l6DC5
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
.l6DD8
	inc [hl]
	jr .l6DC5
.l6DDB
	ld [hl], $00
	jr .l6DC5
.l6DDF
	call ObjCheckOutsideArena_09
	ld a, d
	or a
	call nz, FlashManStartJump
	ld a, $18
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld a, b
	cp [hl]
	call nz, FlashManStartJump
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6E04
	ld a, $0D
	add a, c
	ld l, a
	inc [hl]
	jr .l6E09
.l6E04
	ld a, $0D
	add a, c
	ld l, a
	dec [hl]
.l6E09
	call FlashManAnimateWalk
	call FlashManTickAttackTimer
	or a
	jr nz, .l6E39
	push hl
	call JumpRNG
	pop hl
	and $1F
	ld b, a
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], b
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
.l6E39
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
.l6E4C
	call ObjArcStep_09
	call ObjCheckOutsideArena_09
	ld a, d
	or a
	jr nz, .l6E59
	call ObjMoveX_09
.l6E59
	call ObjMoveY_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l6E70
	ld [hl], $65
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
	call FlashManStartWalk
.l6E70
	ld e, $0A
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6E7C
	ld e, $15
.l6E7C
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	call FlashManTickAttackTimer
	or a
	jr nz, .l6EAE
	push hl
	call JumpRNG
	pop hl
	and $1F
	ld b, a
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], b
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
.l6EAE
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
.l6EC1
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6EEA
	call ObjArcStep_09
	call ObjCheckOutsideArena_09
	ld a, d
	or a
	jr nz, .l6ED6
	call ObjMoveX_09
.l6ED6
	call ObjMoveY_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l6EEA
	ld [hl], $65
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
.l6EEA
	ld a, $2B
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	jr z, .l6F0A
	cp $0C
	jr z, .l6F0A
	cp $12
	jr z, .l6F0A
	cp $18
	jr z, .l6F0A
	cp $1E
	jr z, .l6F14
	cp $28
	jr nc, .l6F22
	jr .l6F38
.l6F0A
	ld a, $30
	add a, c
	ld l, a
	inc [hl]
	call FlashManSetPoseFrame
	jr .l6F38
.l6F14
	call FlashManSpawnFreeze
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $02
	call FlashManSetPoseFrame
	jr .l6F38
.l6F22
	ld a, $30
	add a, c
	ld l, a
	ld [hl], $09
	call FlashManSetPoseFrame
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
.l6F38
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
.l6F4B
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0A
	jr nz, .l6F70
	ld [hl], $00
	inc hl
	ld a, [hl]
	inc [hl]
	cp $06
	jr nz, .l6F63
	call FlashManStartWalk
	jr .l6F70
.l6F63
	push hl
	ld hl, FlashManShotDirections
	ld d, $00
	ld e, a
	add hl, de
	ld b, [hl]
	pop hl
	call FlashManFireShot
.l6F70
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

FlashManFireShot:	;$6F83
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub $14
	ld e, a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $04
	ld d, a
	push bc
	push de
	push hl
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6FA8
	ld a, $08
	add a, b
	and $0F
	ld b, a
	ld a, e
	add a, $28
	ld e, a
.l6FA8
	ld a, b
	ld l, $03
	ld b, $66
	call JumpFireEnemyShot
	pop hl
	pop de
	pop bc
	ret

FlashManSetPoseFrame:	;$6FB4
	ld d, $00
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6FC0
	ld d, $0B
.l6FC0
	ld a, $30
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld d, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], d
	ret

FlashManTickAttackTimer:	;$6FCD
	ld a, $2D
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	ret

FlashManStartJump:	;$6FD4
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $31
	add a, c
	ld l, a
	ld [hl], $04
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

FlashManStartWalk:	;$6FF5
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $07
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
	ld [hl], b
	ld a, $1D
	add a, c
	ld l, a
	ld [hl], $01
	ret

FlashManAnimateWalk:	;$7012
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $07
	ret nz
	ld [hl], a
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	xor $01
	ld [hl], a
	ld b, a
	ld e, $07
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7033
	ld e, $12
.l7033
	ld a, $17
	add a, c
	ld l, a
	ld a, e
	add a, b
	ld [hl], a
	ret

;ObjClearFreeze (B = 1): ends Ice Slasher's freeze at once in mode 3. The
;update also jumps here while wFreezeFlags & $0F is set, so he holds still.	;[ok]
FlashManClearFreeze:	;$703B
	jp ObjClearFreeze_09

FlashManShotDirections:	;$703E
	db $0C, $0D, $0B, $0D, $0C, $0B

FrameTable_7044:	;$7044
	dw Frame_7070, Frame_7087, Frame_70A1, Frame_7199
	dw Frame_71AD, Frame_71C1, Frame_71D5, Frame_70B5
	dw Frame_70CC, Frame_70E3, Frame_7100, Frame_7070
	dw Frame_7087, Frame_711D, Frame_71E9, Frame_71FD
	dw Frame_7211, Frame_7225, Frame_7131, Frame_7148
	dw Frame_715F, Frame_717C

Frame_7070:	;$7070
	db $FC, $03, $F4, $0B	;hitbox
	db $EE, $F4, $43	;dx, dy, 4x3
	db $FF, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B
	db $0E, $F9, $00
	db $80

Frame_7087:	;$7087
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $0D, $0E, $0F, $10, $FF, $11, $12, $13, $14, $15, $16, $17
	db $00, $F8, $0C
	db $0D, $F9, $00
	db $80

Frame_70A1:	;$70A1
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $18, $19, $1A, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23
	db $80

Frame_70B5:	;$70B5
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $39, $3A, $3B, $FF, $FF, $3C, $3D, $FF, $FF, $3E, $3F, $40
	db $0B, $F9, $00
	db $80

Frame_70CC:	;$70CC
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $FF, $41, $42, $43, $44, $45, $46, $47, $FF, $48, $49, $FF
	db $0B, $F8, $00
	db $80

Frame_70E3:	;$70E3
	db $FC, $03, $F4, $0B	;hitbox
	db $F8, $F4, $33	;dx, dy, 3x3
	db $4C, $4D, $FF, $4E, $4F, $50, $52, $53, $54
	db $F0, $05, $4A
	db $F8, $05, $4B
	db $F8, $10, $51
	db $02, $FA, $00
	db $80

Frame_7100:	;$7100
	db $FC, $03, $F4, $0B	;hitbox
	db $F6, $F4, $34	;dx, dy, 3x4
	db $0E, $0F, $10, $11, $55, $13, $27, $28, $FF, $29, $2A, $FF
	db $F8, $00, $0D
	db $F8, $F8, $0C
	db $05, $F9, $00
	db $80

Frame_711D:	;$711D
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $9B, $9A, $99, $98, $9F, $9E, $9D, $9C, $A3, $A2, $A1, $A0
	db $80

Frame_7131:	;$7131
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $FF, $BB, $BA, $B9, $FF, $BD, $BC, $FF, $C0, $BF, $BE, $FF
	db $0D, $F9, $80
	db $80

Frame_7148:	;$7148
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $C3, $C2, $C1, $FF, $C7, $C6, $C5, $C4, $FF, $C9, $C8, $FF
	db $0D, $F8, $80
	db $80

Frame_715F:	;$715F
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $33	;dx, dy, 3x3
	db $FF, $CD, $CC, $D0, $CF, $CE, $D4, $D3, $D2
	db $0E, $FA, $80
	db $18, $05, $CB
	db $20, $05, $CA
	db $18, $10, $D1
	db $80

Frame_717C:	;$717C
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $90, $8F, $8E, $93, $D5, $91, $FF, $A8, $A7, $FF, $AA, $A9
	db $18, $00, $8D
	db $0B, $F9, $80
	db $18, $F8, $8C
	db $80

Frame_7199:	;$7199
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $18, $2B, $2C, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23
	db $80

Frame_71AD:	;$71AD
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $18, $19, $1A, $1B, $1C, $32, $33, $1F, $20, $21, $22, $23
	db $80

Frame_71C1:	;$71C1
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $2D, $2E, $2F, $30, $31, $32, $33, $34, $35, $36, $37, $38
	db $80

Frame_71D5:	;$71D5
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $2D, $2E, $2F, $30, $31, $1D, $1E, $34, $35, $36, $37, $38
	db $80

Frame_71E9:	;$71E9
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $9B, $AC, $AB, $98, $9F, $9E, $9D, $9C, $A3, $A2, $A1, $A0
	db $80

Frame_71FD:	;$71FD
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $9B, $9A, $99, $98, $9F, $B3, $B2, $9C, $A3, $A2, $A1, $A0
	db $80

Frame_7211:	;$7211
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $B0, $AF, $AE, $AD, $B4, $B3, $B2, $B1, $B8, $B7, $B6, $B5
	db $80

Frame_7225:	;$7225
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $B0, $AF, $AE, $AD, $B4, $9E, $9D, $B1, $B8, $B7, $B6, $B5
	db $80
