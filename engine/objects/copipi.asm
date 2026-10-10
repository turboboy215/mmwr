;Mega Man: Dr. Wily's Revenge disassembly - object type 28, Copipi
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Copipi (type 28)", ROMX[$5753], BANK[$9]

;Copipi, the chicks in Pipi's egg (Will). Not in the ending's list; spelled to
;match PIPI.	;[ok]
;Object type 28: never placed; six at once from a type 27, with $CC08 = 0-5
;picking a target offset from CopipiTargets. Moves 2 px along a line (LineStep)
;on odd frames only, and can only be shot on those frames. Near its target it
;re-aims at Mega Man and keeps going until off screen. Killed: removed.	;[ok]
CopipiRoutine:	;$5753
	ld a, b
	or a
	jr z, CopipiInit
	dec a
	jr z, CopipiUpdate
	dec a
	jr z, .l5760
	dec a
	jr z, .l5763
.l5760
	ld b, $00
	ret
.l5763
	jp ObjSyncAndCheckOnScreen_09

CopipiInit:	;$5766
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	add a, a
	ld e, a
	ld d, $00
	ld b, h
	ld hl, CopipiTargets
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, b
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	add a, e
	ld e, a
	inc l
	ld a, [hl]
	add a, d
	ld d, a
	call CopipiSetTarget
	ld de, Data_09_58A2
	call AnimateObjectFacing_09
	ld b, $01
	ret

CopipiTargets:	;$5791
	db $DA, $F0, $E6, $DC, $F2, $CE, $00, $20
	db $11, $D8, $1E, $E0, $2F, $E8, $10, $18

CopipiUpdate:	;$57A1
	ld a, [$DF86]
	ld e, a
	and $01
	jr nz, .l57B2
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $04
	jp .l584D
.l57B2
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $05
	ld a, [wFreezeFlags]
	or a
	jp nz, .l584D
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l57F9
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld a, e
	sub [hl]
	jr nc, .l57D9
	cpl
	inc a
.l57D9
	cp $04
	jr nc, .l57F9
	inc l
	ld a, d
	sub [hl]
	jr nc, .l57E4
	cpl
	inc a
.l57E4
	cp $04
	jr nc, .l57F9
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	ld d, a
	call CopipiSetTarget
.l57F9
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl+]
	ld b, a
	ld de, wLineToX
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld l, c
	push hl
	call LineStep_09
	call LineStep_09
	pop hl
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ld a, $2D
	add a, c
	ld l, a
	ld a, b
	ld [hl+], a
	ld de, wLineToX
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
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ld de, Data_09_58A2
	call AnimateObjectFacing_09
.l584D
	ld a, $28
	add a, c
	ld l, a
	ld a, [$D851]
	add a, [hl]
	ld [hl], a
	jp ObjSyncAndCheckOnScreen_09

CopipiSetTarget:	;$5859
	ld l, c
	push hl
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	inc l
	ld h, [hl]
	ld l, a
	ld c, $01
	call LineStepInit_09
	pop hl
	ld c, l
	ld a, $2D
	add a, c
	ld l, a
	ld a, $02
	ld [hl+], a
	ld de, wLineToX
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
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld a, e
	cp [hl]
	ld e, $00
	jr nc, .l589C
	inc e
.l589C
	ld a, $24
	add a, c
	ld l, a
	ld [hl], e
	ret

Data_09_58A2:	;$58A2
	dw FrameTable_58A8
	db 6	;frames per step
	db $00, $02, $FF

FrameTable_58A8:	;$58A8
	dw Frame_58B0, Frame_58B9, Frame_58C2, Frame_58CB

Frame_58B0:	;$58B0
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $0B
	db $80

Frame_58B9:	;$58B9
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $8B
	db $80

Frame_58C2:	;$58C2
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $0C
	db $80

Frame_58CB:	;$58CB
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $8C
	db $80
