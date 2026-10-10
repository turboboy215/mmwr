;Mega Man: Dr. Wily's Revenge disassembly - object type 25, ScwormSpawn
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ScwormSpawn (type 25)", ROMX[$5966], BANK[$9]

;What Scworm spawns (named from the code).	;[ok]
;Object type 25: never placed; spawned by type 24, with DE = the parent's $09.
;Waits 90 frames (exploding if the parent is gone), then jumps at Mega Man (X
;speed by distance plus a random part, Y speed about -3) under gravity with
;block collision. A wall stops it; after landing it sits 180 frames, then
;explodes (3 in 4) or jumps again. Off screen or killed: removed (no explosion
;when killed).	;[ok]
ScwormSpawnRoutine:	;$5966
	ld a, b
	or a
	jr z, ScwormSpawnInit
	dec a
	jr z, ScwormSpawnUpdate
	dec a
	jr z, ScwormSpawnRemove
	dec a
	jr z, ScwormSpawnFrozen

ScwormSpawnRemove:	;$5973
	ld b, $00
	ret

ScwormSpawnExplode:	;$5976
	ld l, c
	push hl
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, $04
	call JumpCallBank1Routine
	pop hl
	ld c, l
	jr ScwormSpawnRemove

;Mode 3 (Ice Slasher): no movement, only ScwormSpawnCheckOnScreen.	;[ok]
ScwormSpawnFrozen:	;$5989
	jp ScwormSpawnCheckOnScreen

ScwormSpawnInit:	;$598C
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld de, Data_09_5B1B
	call AnimateObjectFacing_09
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
	ld a, $01
	ld [$CC44], a
	ld b, $01
	ret

ScwormSpawnUpdate:	;$59C3
	ld a, [wFreezeFlags]
	or a
	jp nz, ScwormSpawnCheckOnScreen
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, ScwormSpawnAirborne
	dec a
	jp z, ScwormSpawnLanded
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $5A
	jr nc, .l59F4
	ld a, $28
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, [de]
	or a
	jp z, ScwormSpawnExplode
	ld de, Data_09_5B1B
	call AnimateObjectFacing_09
	jr ScwormSpawnCheckOnScreen
.l59F4
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	call ScwormSpawnSetJumpVelocity

;Step the jumping animation unless offset $2A is set (it hit a wall or the
;ceiling), then ScwormSpawnCheckOnScreen.	;[ok]
ScwormSpawnAnimate:	;$59FD
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, Data_09_5B24
	call z, AnimateObjectFacing_09

;Update the stage X (offset $0A) from the screen X and the scroll, then
;ObjCheckOnScreen: the body of ObjSyncAndCheckOnScreen, written inline.	;[ok]
ScwormSpawnCheckOnScreen:	;$5A09
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
	jp ObjCheckOnScreen_09

ScwormSpawnAirborne:	;$5A1C
	call ObjApplyGravity_09
	ld a, $17
	add a, c
	ld l, a
	push hl
	ld e, [hl]
	ld d, $00
	ld hl, FrameTable_5B2A
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call ObjMoveWithCollision_09
	jr z, ScwormSpawnAnimate
	ldh a, [$FFB0]
	ld d, a
	bit 0, d
	jr z, .l5A47
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	jr .l5A71
.l5A47
	ld a, $1E
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld e, [hl]
	ld [hl], $00
	bit 7, e
	jr nz, .l5A69
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	jr ScwormSpawnAnimate
.l5A69
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $01
	jr ScwormSpawnAnimate
.l5A71
	jr .l5A69

ScwormSpawnLanded:	;$5A73
	call ScwormSpawnMoveLanded
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $B4
	jp c, ScwormSpawnAnimate
	call JumpRNG
	cp $40
	jp nc, ScwormSpawnExplode
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	jp ScwormSpawnAnimate

Data_09_5A92:	;$5A92
	dw $FF40, $FD00
	dw $FEF0, $FC40
	dw $FE80, $FCC0
	dw $FD80, $FD00

ScwormSpawnSetJumpVelocity:	;$5AA2
	ld a, [wPlayerX]
	ld e, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld d, $00
	sub e
	jr nc, .l5AB3
	inc d
	cpl
	inc a
.l5AB3
	ld b, $00
	cp $1E
	jr c, .l5AC4
	inc b
	cp $3C
	jr c, .l5AC4
	inc b
	cp $5A
	jr c, .l5AC4
	inc b
.l5AC4
	ld a, d
	ldh [$FF93], a
	push hl
	ld a, b
	ld b, h
	add a, a
	add a, a
	add a, LOW(Data_09_5A92)
	ld l, a
	ld a, $00
	adc a, HIGH(Data_09_5A92)
	ld h, a
	call JumpRNG
	add a, [hl]
	ld e, a
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	ld h, b
	ldh a, [$FF93]
	or a
	call nz, JumpNegateDE
	ld a, $1C
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ldh a, [hBank1CallIndex]
	ld [hl+], a
	ldh a, [$FF92]
	ld [hl+], a
	pop hl
	ret

;After landing: gravity and ObjMoveWithCollision; on a hit, zero the
;velocity (offsets $1C-$1F).	;[ok]
ScwormSpawnMoveLanded:	;$5AF9
	call ObjApplyGravity_09
	ld a, $17
	add a, c
	ld l, a
	push hl
	ld e, [hl]
	ld d, $00
	ld hl, FrameTable_5B2A
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	call ObjMoveWithCollision_09
	ret z
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret

Data_09_5B1B:	;$5B1B
	dw FrameTable_5B2A
	db 17	;frames per step
	db $01, $02, $03, $04, $05, $FF
Data_09_5B24:	;$5B24
	dw FrameTable_5B2A
	db 15	;frames per step
	db $04, $05, $FF

FrameTable_5B2A:	;$5B2A
	dw Frame_5B36, Frame_5B40, Frame_5B49, Frame_5B52
	dw Frame_5B5B, Frame_5B67

Frame_5B36:	;$5B36
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $00, $80
	db $80

Frame_5B40:	;$5B40
	db $FC, $03, $FA, $06	;hitbox
	db $FC, $00, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_5B49:	;$5B49
	db $FC, $03, $FA, $06	;hitbox
	db $FD, $00, $11	;dx, dy, 1x1
	db $01
	db $80

Frame_5B52:	;$5B52
	db $FC, $03, $FA, $06	;hitbox
	db $FB, $00, $11	;dx, dy, 1x1
	db $81
	db $80

Frame_5B5B:	;$5B5B
	db $FC, $03, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $FF, $02, $03, $04
	db $80

Frame_5B67:	;$5B67
	db $FC, $03, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $82, $FF, $84, $83
	db $80
