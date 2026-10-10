;Mega Man: Dr. Wily's Revenge disassembly - object type 4, SniperJoe
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "SniperJoe (type 4)", ROMX[$61CB], BANK[$9]

;Sniper Joe (Will; the ending lists SNIPER JOE).	;[ok]
;Object type 4, placed in Cut Man, Ice Man, Fire Man, Wily 1 and Wily 3. Faces
;Mega Man and fires a horizontal enemy shot (SniperJoeFireShot) on steps 2, 4 and 6
;of an 8-step cycle; on step 0 its hit points read $FE, so shots bounce off.
;Param bit 0 gives a jumping version that hops toward Mega Man under gravity
;with block collision. Does nothing while more than $5E px from the middle of
;the screen. Removed below the screen; frozen: nothing; killed: removed.	;[ok]
SniperJoeRoutine:	;$61CB
	ld a, b
	or a
	jr z, .l61F3
	dec a
	jr z, .l6226
	dec a
	jr z, .l61D9
	dec a
	jp z, .l61DC
.l61D9
	ld b, $00
	ret
.l61DC
	call SniperJoeSaveScreenX
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld a, e
	and $F0
	cp $F0
	jr z, .l61F0
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
.l61F0
	jp SniperJoeEndFrame
.l61F3
	call SniperJoeInitStageX
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $78
	ld a, $18
	add a, c
	ld l, a
	ld e, [hl]
	ld [hl], $FE
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], $01
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_6466)
	inc l
	ld [hl], HIGH(FrameTable_6466)
	ld b, $01
	ret
.l6226
	call SniperJoeSaveScreenX
	call SniperJoeCheckFar
	jp c, SniperJoeEndFrameFar
	ld a, [wFreezeFlags]
	or a
	jp nz, SniperJoeEndFrame
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	cp $FE
	jr z, .l6245
	ld e, a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], e
.l6245
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	jp nz, SniperJoeUpdateJumper

SniperJoeUpdateShootCycle:	;$624F
	ld a, $27
	add a, c
	ld l, a
	dec [hl]
	jr nz, .l627C
	ld a, $09
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $08
	jr c, .l6262
	xor a
	ld [hl], a
.l6262
	ld b, a
	add a, LOW(Data_09_6352)
	ld e, a
	ld a, $00
	adc a, HIGH(Data_09_6352)
	ld d, a
	ld a, $27
	add a, c
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, b
	or a
	jr z, .l627C
	bit 0, a
	jr nz, .l627C
	call SniperJoeFireShot
.l627C
	call ObjFaceMegaManOnScreen_09
	ld a, $24
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $09
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l62A1
	ld a, e
	ld e, $09
	cp $02
	jr z, .l62A1
	cp $04
	jr z, .l62A1
	cp $06
	jr z, .l62A1
	dec e
.l62A1
	ld a, e
	add a, LOW(Data_09_635A)
	ld e, a
	ld a, $00
	adc a, HIGH(Data_09_635A)
	ld d, a
	ld a, [de]
	add a, b
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l62C6
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l62C6
	ld e, $FE
	jr .l62CB
.l62C6
	ld a, $2A
	add a, c
	ld l, a
	ld e, [hl]
.l62CB
	ld a, $18
	add a, c
	ld l, a
	ld [hl], e

;End of every frame: flags bits 0 and 2 set when near, cleared when far
;(SniperJoeCheckFar), then SniperJoeSetFlags.	;[ok]
SniperJoeEndFrame:	;$62D0
	call SniperJoeCheckFar
	ld e, $05
	jr nc, SniperJoeSetFlags

;Too far from the middle of the screen: clear flags bits 0 and 2.	;[ok]
SniperJoeEndFrameFar:	;$62D7
	ld e, $00

;Flags (offset $11) = (flags & $7A) | E. Then remove it if its Y is $90-$EF
;(below the screen); else SniperJoeTrackStageX, update the stage X from the
;scroll, $CC44 = 1 and B = 1.	;[ok]
SniperJoeSetFlags:	;$62D9
	ld a, $11
	add a, c
	ld l, a
	ld a, [hl]
	and $7A
	or e
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $F0
	jr nc, .l62EF
	cp $90
	jr nc, .l6309
.l62EF
	call SniperJoeTrackStageX
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
	ld b, a
	ret
.l6309
	ld b, $00
	ret

SniperJoeFireShot:	;$630C
	ld l, c
	push hl
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	ld e, a
	ld a, $24
	add a, c
	ld l, a
	ld b, [hl]
	ld a, b
	add a, e
	add a, a
	add a, LOW(Data_09_634A)
	ld e, a
	ld a, $00
	adc a, HIGH(Data_09_634A)
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ldh [hBank1CallIndex], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [de]
	add a, [hl]
	ld d, a
	ldh a, [hBank1CallIndex]
	ld e, a
	ld l, $01
	ld a, b
	or a
	ld a, $0C
	jr z, .l6342
	ld a, $04
.l6342
	ld b, $66
	call JumpFireEnemyShot
	pop hl
	ld c, l
	ret

Data_09_634A:	;$634A
	db $F2, $01
	db $0A, $01
	db $F2, $01
	db $0A, $01

Data_09_6352:	;$6352
	db $78, $0A, $32, $0A, $32, $0A, $32, $14

Data_09_635A:	;$635A
	db $00, $02, $02, $02, $02, $02, $02, $02
	db $04, $06

;The jumping version (param bit 0). Offset $28: 1 airborne
;(SniperJoeMoveAirborne); 2 just landed (back to 0, and after a hop restart the
;shooting cycle: $09 = 0, $27 = 30). On the ground: if it is left of Mega Man
;or at most $30 px right of him, hop, cycling through four velocities
;(Data_09_63EE, offset $29; $2D = 2); further right, jump straight up
;(Data_09_63FE, $2D = 1) unless level with him (within 12 px, $2D = 0). Then
;SniperJoeUpdateShootCycle.	;[ok]
SniperJoeUpdateJumper:	;$6364
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jp z, SniperJoeMoveAirborne
	dec a
	jr nz, .l6389
	ld [hl], $00
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	ld [hl], $00
	cp $02
	jr nz, .l6389
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $1E
.l6389
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	add a, $30
	cp [hl]
	jr nc, .l63C7
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $0F
	add a, c
	ld l, a
	ld a, [wPlayerY]
	sub [hl]
	jr nc, .l63A7
	cpl
	inc a
.l63A7
	cp $0C
	jr nc, .l63B3
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $00
	jr SniperJoeJumpChosen
.l63B3
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $01
	ld de, Data_09_63FE
	call ObjSetVelocity_09
	jr SniperJoeJumpChosen
.l63C7
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $01
	inc l
	ld a, [hl]
	inc [hl]
	cp $04
	jr c, .l63DC
	xor a
	ld [hl], a
.l63DC
	ld b, h
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, Data_09_63EE
	add hl, de
	ld e, l
	ld d, h
	ld h, b
	call ObjSetVelocity_09
	jr SniperJoeJumpChosen

Data_09_63EE:	;$63EE
	dw $00C0, $FE00
	dw $00C0, $FE00
	dw $0120, $FC00
	dw $0120, $FC00
Data_09_63FE:	;$63FE
	dw $0000, $FD20

;jp SniperJoeUpdateShootCycle, after SniperJoeUpdateJumper.	;[ok]
SniperJoeJumpChosen:	;$6402
	jp SniperJoeUpdateShootCycle

;jp SniperJoeUpdateShootCycle, after SniperJoeMoveAirborne.	;[ok]
SniperJoeAirborneDone:	;$6405
	jp SniperJoeUpdateShootCycle

SniperJoeMoveAirborne:	;$6408
	ld a, $2D
	add a, c
	ld l, a
	cp $02
	jr nz, .l641C
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $FF
.l641C
	call ObjApplyGravity_09
	ld de, Frame_6498
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l642D
	ld de, Frame_64E6
.l642D
	call ObjMoveWithCollision_09
	jr z, SniperJoeAirborneDone
	ldh a, [$FFB0]
	bit 0, a
	jr z, .l6441
	ld a, $1C
	add a, c
	ld l, a
	ld [hl+], a
	xor a
	ld [hl+], a
	jr SniperJoeAirborneDone
.l6441
	ld a, $1F
	add a, c
	ld l, a
	bit 7, [hl]
	jr nz, .l644E
	xor a
	ld [hl+], a
	ld [hl+], a
	jr .l645E
.l644E
	ld a, [hl-]
	cpl
	ld d, a
	ld a, [hl]
	cpl
	ld e, a
	inc de
	sra d
	rr e
	ld [hl], e
	inc l
	ld [hl], d
	jr SniperJoeAirborneDone
.l645E
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $02
	jr SniperJoeAirborneDone

FrameTable_6466:	;$6466
	dw Frame_6476, Frame_64C4, Frame_6487, Frame_64D5
	dw Frame_6498, Frame_64E6, Frame_64B0, Frame_64FE

Frame_6476:	;$6476
	db $F8, $07, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

Frame_6487:	;$6487
	db $F8, $07, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11
	db $80

Frame_6498:	;$6498
	db $F8, $07, $F4, $0B	;hitbox
	db $F6, $F2, $44	;dx, dy, 4x4
	db $12, $13, $14, $FF, $15, $16, $17, $18, $19, $1A, $FF, $FF, $1B, $1C, $FF, $FF
	db $80

Frame_64B0:	;$64B0
	db $F8, $07, $F4, $0B	;hitbox
	db $F6, $F2, $34	;dx, dy, 3x4
	db $09, $0A, $0B, $0C, $0D, $0E, $1D, $1E, $FF, $1B, $1C, $FF
	db $80

Frame_64C4:	;$64C4
	db $F8, $07, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $80

Frame_64D5:	;$64D5
	db $F8, $07, $F4, $0B	;hitbox
	db $F3, $F4, $33	;dx, dy, 3x3
	db $8B, $8A, $89, $8E, $8D, $8C, $91, $90, $8F
	db $80

Frame_64E6:	;$64E6
	db $F8, $07, $F4, $0B	;hitbox
	db $E9, $F2, $44	;dx, dy, 4x4
	db $FF, $94, $93, $92, $98, $97, $96, $95, $FF, $FF, $9A, $99, $FF, $FF, $9C, $9B
	db $80

Frame_64FE:	;$64FE
	db $F8, $07, $F4, $0B	;hitbox
	db $F1, $F2, $34	;dx, dy, 3x4
	db $8B, $8A, $89, $8E, $8D, $8C, $FF, $9E, $9D, $FF, $9C, $9B
	db $80

SniperJoeCheckFar:	;$6512
	xor a
	ldh [hBank1CallIndex], a
	ld a, $31
	add a, c
	ld l, a
	ld a, [$D80F]
	sub [hl]
	ld e, a
	ldh [hBank1CallIndex], a
	inc l
	ld a, [$D810]
	sbc a, [hl]
	ldh [$FF92], a
	ld d, a
	bit 7, a
	jr z, .l6536
	cpl
	ld d, a
	ld a, e
	cpl
	ld e, a
	inc de
	ld a, $FF
	ldh [hBank1CallIndex], a
.l6536
	ld a, d
	or a
	jr nz, .l653D
	ld a, e
	cp $5E
.l653D
	ccf
	ret

SniperJoeInitStageX:	;$653F
	ld a, $0A
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, $31
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ret

SniperJoeSaveScreenX:	;$654E
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $30
	add a, c
	ld l, a
	ld [hl], e
	ret

SniperJoeTrackStageX:	;$6559
	ld a, $30
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub e
	ld e, a
	ld d, $00
	jr nc, .l656A
	dec d
.l656A
	ld a, $31
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	ret
