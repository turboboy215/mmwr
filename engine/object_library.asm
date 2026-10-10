;Mega Man: Dr. Wily's Revenge disassembly - the object library
;
;1794 bytes of helpers for object routines that banks $03, $09 and $0D each carry
;a copy of, identical except for the addresses (bank $03 has it at $4042, $09 at
;$4048, $0D at $401B). Each bank includes this file in its own pinned section with
;OBJBANK set to its suffix, so every label here ends in {OBJBANK}: _09 for bank $09.
;Local labels are numbered by offset from the start of the library, so they mean
;the same in every copy. Added in step 5.2; confidence tags as elsewhere.

;Compare Mega Man's X with the object's (offset $0D) widened by offset $34:
;E = 4/3/2/1 for "well left", "just left", "just right", "well right" of it, and
;D = 1 on the right-hand side. Not called in bank $09.	;[ok]
ObjLibFunc_000{OBJBANK}:	;+$000
	ld a, $34
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld d, [hl]
	ld a, [wPlayerX]
	ld b, a
	add a, e
	cp d
	jr c, .o01F
	ld a, b
	cp d
	jr c, .o024
	sub e
	cp d
	jr c, .o029
	ld e, $01
	ld d, $01
	ret
.o01F
	ld e, $04
	ld d, $00
	ret
.o024
	ld e, $03
	ld d, $00
	ret
.o029
	ld e, $02
	ld d, $01
	ret

;Add E (a speed in 1/16 pixels) to the sub-pixel counter at offset $1C; the
;whole pixels that carry out go to offset $1D, for ObjMoveX.	;[ok]
ObjStepX{OBJBANK}:	;+$02E
	ld a, $1C
	add a, c
	ld l, a
	call AddSubpixel{OBJBANK}
	ld e, a
	ld a, $1D
	add a, c
	ld l, a
	ld [hl], e
	ret

;Move the object's screen X (offset $0D) by offset $1D pixels: right if offset
;$2F is non-zero, else left.	;[ok]
ObjMoveX{OBJBANK}:	;+$03C
	ld a, $1D
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, d
	or a
	jr z, .o052
	ld a, [hl]
	add a, b
	ld [hl], a
	ret
.o052
	ld a, [hl]
	sub b
	ld [hl], a
	ret

;A = (E + [HL]) / 16, keeping the remainder in [HL]: a 4.4 fixed-point step.	;[ok]
AddSubpixel{OBJBANK}:	;+$056
	ld a, e
	add a, [hl]
	ld e, a
	and $0F
	ld [hl], a
	ld a, e
	swap a
	and $0F
	ret

;The vertical counterpart of ObjStepX: E is a signed speed (positive = up),
;the sub-pixel counter is offset $1E, and offset $1F gets the signed pixel step
;(negative = up).	;[ok]
ObjStepY{OBJBANK}:	;+$062
	ld a, $1E
	add a, c
	ld l, a
	ld a, e
	bit 7, a
	jr z, .o073
	xor a
	sub e
	ld e, a
	call AddSubpixel{OBJBANK}
	jr .o079
.o073
	call AddSubpixel{OBJBANK}
	ld e, a
	xor a
	sub e
.o079
	ld e, a
	ld a, $1F
	add a, c
	ld l, a
	ld [hl], e
	ret

;Add offset $1F to the object's Y (offset $0F).	;[ok]
ObjMoveY{OBJBANK}:	;+$080
	ld a, $1F
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld [hl], a
	ret

;A = 1 if Mega Man has not passed the line E pixels from the object: his X is
;below its X + E (D != 0) or at least its X - E (D = 0); else 0. Used by
;bank $03's type 17, not by bank $09.	;[ok]
ObjLibFunc_08D{OBJBANK}:	;+$08D
	ld a, d
	or a
	jr z, .o0A1
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	ld a, [wPlayerX]
	cp e
	jr nc, .o0AE
.o09E
	ld a, $01
	ret
.o0A1
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub e
	ld e, a
	ld a, [wPlayerX]
	cp e
	jr nc, .o09E
.o0AE
	xor a
	ret

;One frame of a jump arc: X speed offset $31, Y speed offset $32 (positive =
;rising), which drops by offset $33 each frame. Follow with ObjMoveX/ObjMoveY.	;[ok]
ObjArcStep{OBJBANK}:	;+$0B0
	ld a, $31
	add a, c
	ld l, a
	ld e, [hl]
	call ObjStepX{OBJBANK}
	ld a, $33
	add a, c
	ld l, a
	ld d, [hl]
	dec l
	ld a, [hl]
	sub d
	ld e, a
	ld [hl], e
	call ObjStepY{OBJBANK}
	ret

;D = 1 if the object's X is outside $1C-$85 (the edges of a boss room).	;[ok]
ObjCheckOutsideArena{OBJBANK}:	;+$0C6
	ld d, $01
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, e
	sub $1C
	ret c
	ld a, e
	sub $86
	ret nc
	ld d, $00
	ret

;D = 1 if the object has reached the room edge it is heading for (offset $2F
;non-zero = right: X $86 and up; else X below $1C).	;[ok]
ObjCheckArenaEdge{OBJBANK}:	;+$0D8
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld d, $01
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .o0EE
	ld a, e
	cp $86
	ret nc
	ld d, $00
	ret
.o0EE
	ld a, e
	cp $1C
	ret c
	ld d, $00
	ret

;A boss's killed call: wStageState 2 (boss beaten), the bar updated, and B = 0
;so the object goes.	;[ok]
BossKilled{OBJBANK}:	;+$0F5
	ld a, $02
	ld [wStageState], a
	call UpdateBossEnergy{OBJBANK}
	ld b, $00
	ret

;wStageState 3: start the victory countdown. B = 2.	;[ok]
StartVictoryCountdown{OBJBANK}:	;+$100
	ld a, $03
	ld [wStageState], a
	xor a
	ld [wStageSelectAnimPhase], a
	ld [$CCF1], a
	ld b, $02
	ret

;Set up a boss fight: hide the boss bar ($C100/$C101 zero), put the boss at
;(X $80, Y $B0 - off screen), remember it at $CCFA, wStageState 1 (boss room),
;lock Mega Man's controls ($D845) and face him right.	;[ok]
InitBoss{OBJBANK}:	;+$10F
	xor a
	ld [$CCF5], a
	ld [$C100], a
	ld [$C101], a
	ld [$CCF4], a
	inc a
	ld [$CCF1], a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $B0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $80
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	push hl
	ld de, $CCFA
	ld a, c
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	pop hl
	ld a, $01
	ld [wStageState], a
	ld a, $FF
	ld [$D845], a
	ld a, $01
	ld [wPlayerFacing], a
	ret

;Keep the boss's position at $CCF2/$CCF3, where the death burst is spawned.	;[ok]
StoreBossPosition{OBJBANK}:	;+$14C
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CCF2], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CCF3], a
	ret

;Boss intro: show the boss bar and fill it two points a frame; once full, give
;the boss $13 hit points and unlock Mega Man's controls.	;[ok]
FillBossEnergy{OBJBANK}:	;+$15D
	ld a, $01
	ld [$C100], a
	ld a, [$C101]
	cp $98
	jr nc, GiveBossFullEnergy{OBJBANK}
	add a, $02
	ld [$C101], a
	push af
	pop af
	ret

;The bar is full: give the boss $13 hit points and unlock Mega Man's controls
;($D845 = 0). Bank $03 calls this part directly.	;[ok]
GiveBossFullEnergy{OBJBANK}:	;+$171
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $13
	xor a
	ld [$D845], a
	ret

;Boss bar = hit points x 8.	;[ok]
UpdateBossEnergy{OBJBANK}:	;+$17C
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	sla a
	sla a
	sla a
	ld [$C101], a
	ret

;Check the boss remembered at $CCFA: NZ while it has hit points; at 0, empty
;the bar and set $CCF5.	;[ok]
CheckBossDead{OBJBANK}:	;+$18B
	push hl
	ld de, $CCFA
	ld a, [de]
	add a, $18
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ld a, [hl]
	pop hl
	or a
	ret nz
	ld [$C101], a
	inc a
	ld [$CCF5], a
	ret

;Boss entrance: once Mega Man is down in the room (Y $60 and up), drop the
;boss from the top 3 pixels a frame until it reaches Y $65; A = 1 when it has
;landed.	;[ok]
DropBossIn{OBJBANK}:	;+$1A2
	ld a, $C4
	ldh [rOBP1], a
	ld a, [$CCF4]
	or a
	jr z, .o1C4
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jr c, .o1B7
	ld [hl], $00
.o1B7
	inc [hl]
	inc [hl]
	inc [hl]
	ld a, [hl]
	sub $66
	jr c, .o1C4
	ld [hl], $65
	ld a, $01
	ret
.o1C4
	ld a, [wPlayerY]
	sub $60
	jr c, .o1D0
	ld a, $01
	ld [$CCF4], a
.o1D0
	xor a
	ret

;Update the object's stage X (offset $0A) from its screen X and the scroll;
;B = 0 if it is off screen sideways (X $C0-$DF), else B = 1 and $CC44 set.	;[ok]
ObjCheckOnScreenX{OBJBANK}:	;+$1D2
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
	ld a, e
	cp $E0
	jr nc, .o1EC
	cp $C0
	jp nc, .o1F3
.o1EC
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret
.o1F3
	ld b, $00
	ret

;Offset $24 (facing) = 1 if Mega Man is to the right of the object, else 0.	;[ok]
ObjFaceMegaMan{OBJBANK}:	;+$1F6
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .o203
	inc d
.o203
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ret

;Hang: 24 objects are already active.	;[ok]
HangObjectsFull{OBJBANK}:	;+$209
	jr HangObjectsFull{OBJBANK}

;Spawn an object of type [$CC07] from inside an object routine. Takes a slot
;like SpawnObject and builds the record from ObjectTypeTab and ObjectStatsTab,
;at the position the caller left in $CC0D/$CC0F (with $CC05-$CC08), without a
;spawn list. This is how objects make other objects (projectiles, the parts of a
;boss) - the route outside SpawnObject that step 4.4 inferred. Mode 0 is not
;called: the record is returned in C (and $CC42/$CC43), and every caller runs
;the child's own init routine on it.	;[ok]
SpawnChildObject{OBJBANK}:	;+$20B
	ld a, $FF
	ld [$CC04], a
	ld hl, $C398
	ld a, [hl]
	cp $18
	jr nc, HangObjectsFull{OBJBANK}
	inc [hl]
	call JumpAllocObjectSlot
	ld hl, $C398
	ld a, [hl]
	add a, $7F
	ld l, a
	ld [hl], b
	ld a, b
	ld l, $00
	ld h, a
	srl h
	rr l
	srl h
	rr l
	ld de, $C600
	add hl, de
	ld a, l
	ld [$CC42], a
	ld a, h
	ld [$CC43], a
	ld a, [$CC07]
	dec a
	add a, a
	add a, a
	ld e, a
	ld a, [ObjectTablePtrs + 2]
	add a, e
	ld l, a
	ld a, [ObjectTablePtrs + 3]
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld [$CC00], a
	ld a, [hl+]
	ld [$CC01], a
	ld a, [hl+]
	ld [$CC1B], a
	xor a
	ld [$CC09], a
	ld hl, ObjectTablePtrs
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [$CC07]
	dec a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, de
	ld a, [hl+]
	push hl
	or a
	jr nz, .o278
	ld a, $40
	jr .o27B
.o278
	call JumpAllocSprite
.o27B
	ld [$CC10], a
	ld a, $10
	ld [$CC14], a
	xor a
	ld [$CC17], a
	pop hl
	inc hl
	inc hl
	ld a, [hl+]
	ld [$CC18], a
	xor a
	ld [$CC19], a
	ld a, [hl+]
	ld [$CC1A], a
	ld a, [hl+]
	ld [$CC11], a
	ld a, [hl+]
	ld [$CC03], a
	ld hl, $CC00
	ld a, [$CC42]
	ld e, a
	ld a, [$CC43]
	ld d, a
	ld bc, $001C
	call JumpFill
	ld h, d
	ld l, e
	xor a
	ld bc, $000B
	call JumpFuncMemset
	ld a, [$CC42]
	ld c, a
	ld a, [$CC43]
	ld h, a
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

;ObjApplyGravity, then ObjMoveByVelocity.	;[ok]
ObjFallAndMove{OBJBANK}:	;+$2D1
	call ObjApplyGravity{OBJBANK}
	ld a, $0C
	add a, c
	ld l, a
	ld a, $1C
	add a, c
	ld e, a
	ld d, h
	ld a, [de]
	inc e
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	inc e
	adc a, [hl]
	ld [hl+], a
	ld a, [de]
	inc e
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	inc e
	adc a, [hl]
	ld [hl+], a
	ret

;Velocity (offsets $1C-$1F: X, then Y, 8.8 fixed point) from the 4 bytes at
;DE.	;[ok]
ObjSetVelocity{OBJBANK}:	;+$2EE
	ld a, $1C
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ret

;Add the velocity to the position (offsets $0C-$0F: X, then Y, 8.8).	;[ok]
ObjMoveByVelocity{OBJBANK}:	;+$2FF
	ld a, $1C
	add a, c
	ld e, a
	ld d, h
	ld a, $0C
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	inc de
	adc a, [hl]
	ld [hl+], a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	inc de
	adc a, [hl]
	ld [hl+], a
	ret

;List every active object of type A (offset $07) at $CC00, as record
;pointers, ending with $FF.	;[ok]
FindObjectsOfType{OBJBANK}:	;+$319
	ld l, c
	push hl
	ld c, a
	ld hl, $CC00
	ld a, [$C398]
	or a
	jr z, .o353
	ld b, a
	ld de, $C380
.o329
	ld a, [de]
	inc de
	cp $FF
	jr z, .o353
	push de
	push hl
	ld l, $00
	ld h, a
	srl h
	rr l
	srl h
	rr l
	ld de, $C607
	add hl, de
	ld a, [hl]
	cp c
	jr nz, .o34E
	ld d, h
	ld a, l
	and $C0
	pop hl
	ld [hl+], a
	ld [hl], d
	inc hl
	jr .o34F
.o34E
	pop hl
.o34F
	pop de
	dec b
	jr nz, .o329
.o353
	ld [hl], $FF
	pop hl
	ld c, l
	ret

;Swap objects HL and DE in the active list (draw order). Carry if either is
;not there. Not called in bank $09.	;[ok]
SwapObjectOrder{OBJBANK}:	;+$358
	ld l, c
	push hl
	ld a, d
	sub $C6
	ld d, a
	call ShiftDERight6{OBJBANK}
	ld a, e
	ldh [hBank1CallIndex], a
	ld e, c
	ld a, h
	sub $C6
	ld d, a
	call ShiftDERight6{OBJBANK}
	ld a, e
	ldh [$FF92], a
	ld a, $FF
	ldh [$FF93], a
	ldh [$FF94], a
	ld a, [$C398]
	or a
	jr z, .o3B6
	ld b, a
	ld de, $C380
.o37F
	ld a, [de]
	cp $FF
	jr z, .o39A
	ld hl, $FF91
	cp [hl]
	jr nz, .o38F
	ld a, e
	ldh [$FF93], a
	jr .o396
.o38F
	inc l
	cp [hl]
	jr nz, .o396
	ld a, e
	ldh [$FF94], a
.o396
	inc de
	dec b
	jr nz, .o37F
.o39A
	ldh a, [$FF93]
	cp $FF
	jr z, .o3B6
	ld e, a
	ldh a, [$FF94]
	cp $FF
	jr z, .o3B6
	ld d, a
	ld h, $C3
	ld l, e
	ldh a, [$FF92]
	ld [hl], a
	ld l, d
	ldh a, [hBank1CallIndex]
	ld [hl], a
	pop hl
	ld c, l
	or a
	ret
.o3B6
	pop hl
	ld c, l
	scf
	ret

;DE >>= 6.	;[ok]
ShiftDERight6{OBJBANK}:	;+$3BA
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e
	ret

;Carry if Mega Man is standing on the box at DE (x1, x2, y1, relative to the
;object at $FF91/$FF92): on the ground, his feet at its top, overlapping it.	;[ok]
CheckPlayerOnObject{OBJBANK}:	;+$3D3
	ld a, [wPlayerMotion]
	or a
	ret z
	inc de
	inc de
	ld a, [de]
	ld l, a
	ldh a, [$FF92]
	add a, l
	sub $0D
	ld l, a
	ld a, [wPlayerY]
	cp l
	jr nz, .o409
	ldh a, [hBank1CallIndex]
	ld b, a
	dec de
	ld a, [de]
	dec de
	add a, b
	cp $D0
	jr c, .o3F4
	xor a
.o3F4
	ld l, a
	ld a, [$D841]
	cp l
	jr nc, .o409
	ld a, [de]
	add a, b
	cp $D0
	jr c, .o402
	xor a
.o402
	ld l, a
	ld a, [$D842]
	cp l
	ccf
	ret
.o409
	or a
	ret

;Move Mega Man: D pixels down, E into his X push ($D831).	;[ok]
PushPlayer{OBJBANK}:	;+$40B
	ld hl, wPlayerY
	ld a, [hl]
	add a, d
	ld [hl], a
	ld hl, $D831
	ld a, [hl]
	add a, e
	ld [hl], a
	ret

;NC if Mega Man (wPlayerX, wPlayerY) is inside the box at HL (x1, x2, y1,
;y2: x1 <= X < x2, y1 <= Y < y2); carry if he is outside it.	;[ok]
CheckPlayerInBox{OBJBANK}:	;+$418
	ld a, [wPlayerX]
	cp [hl]
	ret c
	inc hl
	cp [hl]
	ccf
	ret c
	inc hl
	ld a, [wPlayerY]
	cp [hl]
	ret c
	inc hl
	cp [hl]
	ccf
	ret

;Update the stage X, then ObjCheckOnScreen.	;[ok]
ObjSyncAndCheckOnScreen{OBJBANK}:	;+$42B
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
	jp ObjCheckOnScreen{OBJBANK}

;Copies of bank $00's LineStepInit and LineStep, on the same RAM.	;[ok]
LineStepInit{OBJBANK}:	;+$43E
	ld a, $02
	ld [wLineError], a
	ld a, l
	ld [wLineFromX], a
	ld a, h
	ld [wLineFromY], a
	ld a, e
	ld [wLineToX], a
	ld a, d
	ld [wLineToY], a
	ld b, $01
	ld a, l
	cpl
	inc a
	add a, e
	jr c, .o464
	cpl
	inc a
	push af
	ld a, $01
	cpl
	inc a
	ld b, a
	pop af
.o464
	ld [wLineDX], a
	ld a, b
	ld [wLineStepX], a
	ld b, $01
	ld a, h
	cpl
	inc a
	add a, d
	jr c, .o47C
	cpl
	inc a
	ld h, a
	ld a, $01
	cpl
	inc a
	ld b, a
	ld a, h
.o47C
	ld [wLineDY], a
	ld a, b
	ld [wLineStepY], a
	ret

LineStep{OBJBANK}:	;+$484
	ld a, [wLineDX]
	ld hl, wLineDY
	cp [hl]
	jr nc, .o4AC
	ld a, b
	ld hl, wLineDX
	add a, [hl]
	jr c, .o49B
	ld b, a
	ld hl, wLineDY
	sub [hl]
	jr c, .o4A4
.o49B
	ld b, a
	ld a, e
	ld hl, wLineStepX
	add a, [hl]
	ld e, a
	jr nc, .o4A4
.o4A4
	ld a, d
	ld hl, wLineStepY
	add a, [hl]
	ld d, a
	jr .o4C7
.o4AC
	ld a, b
	ld hl, wLineDY
	add a, [hl]
	jr c, .o4BA
	ld b, a
	ld hl, wLineDX
	sub [hl]
	jr c, .o4C1
.o4BA
	ld b, a
	ld a, d
	ld hl, wLineStepY
	add a, [hl]
	ld d, a
.o4C1
	ld a, e
	ld hl, wLineStepX
	add a, [hl]
	ld e, a
.o4C7
	ld a, c
	or a
	ret

;Single-bit masks. Nothing in bank $09 reads them.	;[ok]
ObjLibBitMasks{OBJBANK}:	;+$4CA
	db $01, $02, $04, $08, $10, $20, $40, $80

;Gravity, then ObjMoveWithCollision with the probes at DE; a blocked
;direction loses its speed. Not called in bank $09.	;[ok]
ObjFallWithCollision{OBJBANK}:	;+$4D2
	push de
	call ObjApplyGravity{OBJBANK}
	pop de
	call ObjMoveWithCollision{OBJBANK}
	ret z
	bit 0, a
	jr z, .o4E3
	ld a, $1C
	jr .o4E5
.o4E3
	ld a, $1E
.o4E5
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ret

;AnimateObject, then add the facing (offset $24) to the frame: frame tables
;list each frame twice, left and right.	;[ok]
AnimateObjectFacing{OBJBANK}:	;+$4EB
	call AnimateObject{OBJBANK}
	ld a, $24
	add a, c
	ld e, a
	ld d, h
	ld a, [de]
	add a, [hl]
	ld [hl], a
	ret

;Animate object C. DE = an animation record, the format bank $01 uses:
;  dw frame table, db frames per step, db frame, frame, ..., $FF (loop)
;Points OBJ_FRAMES (offset $15) at the table, counts offset $25 and steps
;offset $26, and puts the frame number in OBJ_FRAME (offset $17).	;[ok]
AnimateObject{OBJBANK}:	;+$4F7
	ld a, $15
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, $25
	add a, c
	ld l, a
	inc [hl]
	ld a, [de]
	inc de
	dec a
	cp [hl]
	jr nc, .o510
	ld [hl], $00
	inc l
	inc [hl]
.o510
	ld a, e
	ldh [$FF93], a
	ld a, d
	ldh [$FF94], a
	ld a, $26
	add a, c
	ld l, a
.o51A
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	cp $FF
	jr nz, .o530
	ld [hl], $00
	ldh a, [$FF93]
	ld e, a
	ldh a, [$FF94]
	ld d, a
	jr .o51A
.o530
	ld b, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

;B = 0 if the object is off screen (Y $90 and up, or X $C0-$DF), else B = 1
;and $CC44 set.	;[ok]
ObjCheckOnScreen{OBJBANK}:	;+$537
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $90
	jr nc, .o554
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $E0
	jr nc, .o54D
	cp $C0
	jr nc, .o554
.o54D
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret
.o554
	ld b, $00
	ret

;Gravity: Y speed (offsets $1E-$1F) += $30, capped at $0350.	;[ok]
ObjApplyGravity{OBJBANK}:	;+$557
	ld a, $1E
	add a, c
	ld l, a
	ld a, [hl+]
	add a, $30
	ld e, a
	ld a, $00
	adc a, [hl]
	ld d, a
	bit 7, a
	jr nz, .o572
	ld a, $50
	sub e
	ld a, $03
	sbc a, d
	jr nc, .o572
	ld de, $0350
.o572
	ld [hl], d
	dec l
	ld [hl], e
	ret

;Move by the velocity with block collision. DE = four probe offsets (x1, x2,
;y1, y2) around the object. Works on a copy at $FFA6-$FFAF, moving a block at a
;time and backing out of solid ones (CheckSolidPoint); returns $FFB0: bit 1 hit
;something vertically, bit 0 horizontally (NZ if either).	;[ok]
ObjMoveWithCollision{OBJBANK}:	;+$576
	ld a, e
	ldh [$FFAE], a
	ld a, d
	ldh [$FFAF], a
	ld l, c
	push hl
	ld a, $1C
	add a, c
	ld l, a
	ld de, $FFA6
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	call ObjMoveCollide{OBJBANK}
	pop hl
	ld c, l
	ld a, $0C
	add a, c
	ld l, a
	ld de, $FFAA
	ld a, [de]
	inc e
	ld [hl+], a
	ld a, [de]
	inc e
	ld [hl+], a
	ld a, [de]
	inc e
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ldh a, [$FFB0]
	or a
	ret

ObjMoveCollide{OBJBANK}:	;+$5BB
	xor a
	ldh [$FFB0], a
	call ObjMoveCollideY{OBJBANK}
	call ObjMoveCollideX{OBJBANK}
	ldh a, [$FFB0]
	or a
	ret

;The vertical half of ObjMoveCollide.	;[ok]
ObjMoveCollideY{OBJBANK}:	;+$5C8
	ld hl, $FFA8
	ld a, [hl+]
	ld e, a
	or [hl]
	ret z
	ld d, [hl]
	ld a, d
	ldh [hBank1CallIndex], a
	ld hl, $FFAC
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	ldh [$FF92], a
	adc a, d
	ld [hl+], a
.o5DE
	ldh a, [$FFAE]
	ld l, a
	ldh a, [$FFAF]
	ld h, a
	ldh a, [hBank1CallIndex]
	bit 7, a
	jr nz, .o5EB
	inc hl
.o5EB
	inc hl
	inc hl
	ldh a, [$FFAD]
	add a, [hl]
	ld d, a
	ldh a, [$FFAE]
	ld l, a
	ldh a, [$FFAF]
	ld h, a
	ldh a, [$FFAB]
	add a, [hl]
	ld e, a
	inc hl
	ldh a, [$FFAB]
	add a, [hl]
	ld c, a
.o600
	ld a, d
	push de
	push bc
	call JumpCheckSolidPoint
	pop bc
	pop de
	jr c, .o619
	ld a, e
	add a, $10
	ccf
	ret nc
	ld e, a
	cp c
	jr c, .o600
	ld e, c
	ld a, d
	call JumpCheckSolidPoint
	ret nc
.o619
	ldh a, [$FFAD]
	ld d, a
	ldh a, [$FF92]
	cp d
	ret z
	ld hl, $FFB0
	set 1, [hl]
	ldh a, [hBank1CallIndex]
	bit 7, a
	jr nz, .o62E
	dec d
	jr .o62F
.o62E
	inc d
.o62F
	ld a, d
	ldh [$FFAD], a
	jr .o5DE

;The horizontal half.	;[ok]
ObjMoveCollideX{OBJBANK}:	;+$634
	ld hl, $FFA6
	ld a, [hl+]
	ld e, a
	or [hl]
	ret z
	ld d, [hl]
	ld a, d
	ldh [hBank1CallIndex], a
	ld hl, $FFAA
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	ldh [$FF92], a
	adc a, d
	ld [hl+], a
.o64A
	ldh a, [$FFAE]
	ld l, a
	ldh a, [$FFAF]
	ld h, a
	ldh a, [hBank1CallIndex]
	bit 7, a
	jr nz, .o657
	inc hl
.o657
	ldh a, [$FFAB]
	add a, [hl]
	ld e, a
	ldh a, [$FFAE]
	ld l, a
	ldh a, [$FFAF]
	ld h, a
	inc hl
	inc hl
	ldh a, [$FFAD]
	add a, [hl]
	ld d, a
	inc hl
	ldh a, [$FFAD]
	add a, [hl]
	ld c, a
.o66C
	ld a, d
	push de
	push bc
	call JumpCheckSolidPoint
	pop bc
	pop de
	jr c, .o685
	ld a, d
	add a, $08
	ccf
	ret nc
	ld d, a
	cp c
	jr c, .o66C
	ld d, c
	ld a, d
	call JumpCheckSolidPoint
	ret nc
.o685
	ldh a, [$FFAB]
	ld d, a
	ldh a, [$FF92]
	cp d
	ret z
	ld hl, $FFB0
	set 0, [hl]
	ldh a, [hBank1CallIndex]
	bit 7, a
	jr nz, .o69A
	dec d
	jr .o69B
.o69A
	inc d
.o69B
	ld a, d
	ldh [$FFAB], a
	jr .o64A

;Like ObjFaceMegaMan, but facing right whenever the object is off the left
;edge (X $C0 and up).	;[ok]
ObjFaceMegaManOnScreen{OBJBANK}:	;+$6A0
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $C0
	jr nc, .o6B1
	ld a, [wPlayerX]
	cp [hl]
	jr c, .o6B2
.o6B1
	inc d
.o6B2
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ret

;A two-level counter. DE = (offset, limit 1, limit 2): count the byte at that
;offset; when it passes limit 1, reset it and count the next byte, which wraps
;past limit 2. Returns the second byte (Z when it wrapped to 0).	;[ok]
ObjCountTimer{OBJBANK}:	;+$6B8
	ld a, [de]
	inc de
	add a, c
	ld l, a
	inc [hl]
	ld a, [de]
	inc de
	cp [hl]
	jr nc, .o6C7
	ld [hl], $00
	inc l
	inc [hl]
	dec l
.o6C7
	inc l
	ld a, [de]
	cp [hl]
	jr nc, .o6CE
	ld [hl], $00
.o6CE
	ld a, [hl]
	or a
	ret

;The object's hitbox on screen from its current frame ($CE53): C-E across,
;B-D down. Not called in bank $09.	;[ok]
GetObjectHitbox{OBJBANK}:	;+$6D1
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, [$CE53]
	ld l, a
	ld a, [$CE54]
	ld h, a
	ld a, [hl+]
	add a, e
	cp $D0
	jr c, .o6E8
	xor a
.o6E8
	ld c, a
	ld a, [hl+]
	add a, e
	cp $D0
	jr c, .o6F0
	xor a
.o6F0
	ld e, a
	ld a, [hl+]
	add a, d
	ld b, a
	ld a, [hl+]
	add a, d
	ld d, a
	ret

;Clear the freeze timer (offsets $22-$23); B = 1.	;[ok]
ObjClearFreeze{OBJBANK}:	;+$6F8
	ld a, $22
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld b, $01
	ret
