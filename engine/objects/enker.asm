;Mega Man: Dr. Wily's Revenge disassembly - object type 38, Enker
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Enker (type 38)", ROMX[$5C5A], BANK[$9]

;Enker (type 38), the boss in Wily 2's fifth teleporter room. A state machine
;in $27: drop in, intro (bar fills, palette flashes), then at random walk, jump
;once or twice, or jump long; at a room edge, or after jumping, he absorbs: for
;120 frames Mega Man's shots are pulled toward his spear and the damage they
;would do is counted in $37 (sound $2B). Then he fires a type 39 whose power
;tier comes from that count (EnkerSpawnShot). Ice Slasher does nothing to him.
;Killed: wStageState 2 and the bar emptied.	;[ok]
;Offset $19 = 0 (shots do damage) only while jumping or absorbing with the Mega
;Buster equipped, so other weapons and other moments do not hurt him.	;[?]
EnkerRoutine:	;$5C5A
	ld a, b
	or a
	jr z, EnkerInit
	dec a
	jr z, EnkerUpdate
	dec a
	jp z, .l5C69
	dec a
	jp z, EnkerClearFreeze
.l5C69
	ld a, $01
	ld [$CCF5], a
	ld a, $02
	ld [wStageState], a
	call UpdateBossEnergy_09
	ld a, $C4
	ldh [rOBP1], a
	ld b, $00
	ret

;ObjClearFreeze (B = 1): ends Ice Slasher's freeze at once in mode 3, so it
;holds him one frame at most. EnkerRunState also jumps here while wFreezeFlags
;is set, skipping his state machine for the frame.	;[ok]
EnkerClearFreeze:	;$5C7D
	jp ObjClearFreeze_09

EnkerInit:	;$5C80
	call InitBoss_09
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_6039)
	inc l
	ld [hl], HIGH(FrameTable_6039)
	inc l
	ld [hl], $00
	ld b, $01
	ret

EnkerUpdate:	;$5C92
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	cp $05
	jr nz, .l5CB6
	ld a, $35
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $18
	add a, c
	ld l, a
	ld a, d
	sub [hl]
	ld d, a
	or a
	jr z, .l5CAF
	ld a, $2B
	call JumpQueueSound
.l5CAF
	ld a, $37
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
.l5CB6
	call EnkerRunState
	ld a, $18
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $35
	add a, c
	ld l, a
	ld [hl], d
	ld d, $01
	ld a, [wCurrentWeapon]
	or a
	jr nz, .l5CDA
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	cp $04
	jr c, .l5CDA
	cp $06
	jr nc, .l5CDA
	ld d, $00
.l5CDA
	ld a, $19
	add a, c
	ld l, a
	ld [hl], d
	ret

EnkerRunState:	;$5CE0
	ld a, [wFreezeFlags]
	or a
	jp nz, EnkerClearFreeze
	call StoreBossPosition_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5D0D
	dec a
	jr z, .l5D27
	ld b, a
	call UpdateBossEnergy_09
	ld a, b
	dec a
	jp z, EnkerChooseAction
	dec a
	jp z, EnkerWalk
	dec a
	jp z, EnkerJump
	dec a
	jp z, EnkerAbsorb
	jp EnkerFire
.l5D0D
	call DropBossIn_09
	or a
	jr z, .l5D24
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $24
	add a, c
	ld l, a
	ld [hl], $00
.l5D24
	ld b, $01
	ret
.l5D27
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $3C
	jp z, EnkerIntroPose
	jr c, EnkerIntroWait
	cp $8C
	jr z, EnkerIntroStopFlash
	jr c, .l5D40
	cp $B4
	jr z, EnkerIntroEnd
	jr EnkerIntroWait
.l5D40
	call FillBossEnergy_09

EnkerFlashPalette:	;$5D43
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	jr nz, EnkerIntroWait
	ld [hl+], a
	inc [hl]
	ld a, [hl]
	dec a
	jr z, .l5D5E
	dec a
	jr z, .l5D64
	ld a, $24
	ldh [rOBP1], a
	ld [hl], $00
	jr EnkerIntroWait
.l5D5E
	ld a, $48
	ldh [rOBP1], a
	jr z, EnkerIntroWait
.l5D64
	ld a, $90
	ldh [rOBP1], a
	jr z, EnkerIntroWait

;Intro, frame 60: show frame 4.	;[ok]
EnkerIntroPose:	;$5D6A
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04

;Intro: nothing more this frame (B = 1).	;[ok]
EnkerIntroWait:	;$5D70
	ld b, $01
	ret

;Intro, frame 140: frame 2 and the normal palette (rOBP1 = $C4).	;[ok]
EnkerIntroStopFlash:	;$5D73
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $C4
	ldh [rOBP1], a
	ld b, $01
	ret

;Intro, frame 180: on to state 2 (EnkerChooseAction), with $2B = 3 and the
;timer $28 cleared.	;[ok]
EnkerIntroEnd:	;$5D80
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret

EnkerChooseAction:	;$5D95
	push hl
	call JumpRNG
	pop hl
	and $03
	ld b, a
	ld a, $36
	add a, c
	ld l, a
	ld [hl], b
	ld a, b
	or a
	jr z, .l5DB3
	dec a
	jr z, .l5DBD
	dec a
	jr z, .l5DB7
	call EnkerSetLongJump
	ld e, $04
	jr .l5DC2
.l5DB3
	ld e, $03
	jr .l5DC2
.l5DB7
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00
.l5DBD
	call EnkerSetShortJump
	ld e, $04
.l5DC2
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld b, $01
	ret

EnkerWalk:	;$5DCA
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $61
	ld a, $1D
	add a, c
	ld l, a
	ld [hl], $02
	call ObjCheckArenaEdge_09
	ld a, d
	or a
	jr nz, .l5DE2
	call ObjMoveX_09
	jr .l5DED
.l5DE2
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	call EnkerStartAbsorb
.l5DED
	call EnkerAnimateWalk
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

EnkerStartAbsorb:	;$5E03
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	ld a, $37
	add a, c
	ld l, a
	ld [hl], $00
	ret

EnkerJump:	;$5E10
	call ObjArcStep_09
	call ObjCheckArenaEdge_09
	ld a, d
	or a
	jr nz, .l5E1D
	call ObjMoveX_09
.l5E1D
	call ObjMoveY_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l5E67
	ld [hl], $65
	ld a, $36
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l5E43
	dec a
	jr z, .l5E4B
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	call EnkerStartAbsorb
	jr .l5E67
.l5E43
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	jr .l5E67
.l5E4B
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5E5A
	inc a
	ld [hl], a
	call EnkerSetShortJump
	jr .l5E67
.l5E5A
	xor a
	ld [hl], a
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	xor $01
	ld [hl], a
	call EnkerStartAbsorb
.l5E67
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l5E74
	inc d
.l5E74
	ld a, $17
	add a, c
	ld l, a
	ld a, d
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

EnkerPullShots:	;$5E8D
	ld l, c
	push hl
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld a, [hl]
	sub $16
	ld d, a
	ld c, $39
.l5E9C
	ld h, $C2
	ld l, c
	ld a, [hl]
	or a
	jr z, .l5EC1
	ld a, $04
	add a, c
	ld l, a
	ld a, e
	sub [hl]
	ld b, $01
	jr nc, .l5EAF
	ld b, $FF
.l5EAF
	ld a, [hl]
	add a, b
	ld [hl], a
	ld a, $08
	add a, c
	ld l, a
	ld a, d
	sub [hl]
	ld b, $01
	jr nc, .l5EBE
	ld b, $FF
.l5EBE
	ld a, [hl]
	add a, b
	ld [hl], a
.l5EC1
	ld a, $20
	add a, c
	ld c, a
	cp $99
	jr c, .l5E9C
	pop hl
	ld c, l
	ret

EnkerAbsorb:	;$5ECC
	call EnkerPullShots
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $65
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $50
	jr nc, .l5EE1
	inc d
.l5EE1
	ld a, $17
	add a, c
	ld l, a
	ld a, $04
	add a, d
	ld [hl], a
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $78
	jp nc, .l5F28
	ld a, $37
	add a, c
	ld l, a
	call EnkerGetShotTier
	ld a, b
	or a
	jr z, .l5F45
	dec a
	jr c, .l5F06
	dec a
	jp z, EnkerFlashPalette
.l5F06
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	jr c, .l5F17
	ld [hl], $00
	ld a, $38
	add a, c
	ld l, a
	inc [hl]
.l5F17
	ld a, $38
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	ld a, $D0
	jr z, .l5F24
	ld a, $4C
.l5F24
	ldh [rOBP1], a
	jr .l5F45
.l5F28
	ld [hl], $00
	call EnkerGetSide
	ld a, $17
	add a, c
	ld l, a
	ld a, $02
	add a, d
	ld [hl], a
	ld a, $C4
	ldh [rOBP1], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $06
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $00
.l5F45
	ld b, $01
	ret

EnkerGetShotTier:	;$5F48
	ld a, $37
	add a, c
	ld l, a
	ld a, [hl]
	cp $02
	ld b, $00
	jr c, .l5F59
	inc b
	cp $04
	jr c, .l5F59
	inc b
.l5F59
	ret

EnkerFire:	;$5F5A
	ld a, $2D
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	jr c, .l5F86
	jr z, .l5F92
	ld a, $27
	call FindObjectsOfType_09
	ld a, [$CC00]
	cp $FF
	jr z, .l5F7E
	add a, $0D
	ld e, a
	ld a, [$CC01]
	ld d, a
	ld a, [de]
	cp $A0
	jr c, .l5FB3
.l5F7E
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	jr .l5FBE
.l5F86
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	add a, $02
	ld [hl], a
	jr .l5FBE
.l5F92
	call EnkerGetSide
	ld a, d
	add a, a
	add a, LOW(Data_09_5FC1)
	ld e, a
	ld a, $00
	adc a, HIGH(Data_09_5FC1)
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld b, a
	inc l
	inc l
	ld a, [de]
	add a, [hl]
	ld d, a
	ld e, b
	call EnkerGetShotTier
	call EnkerSpawnShot
.l5FB3
	call EnkerGetSide
	ld a, $17
	add a, c
	ld l, a
	ld a, d
	add a, $06
	ld [hl], a
.l5FBE
	ld b, $01
	ret

Data_09_5FC1:	;$5FC1
	db $F4, $00, $0C, $00

;D = 1 if Enker is in the left half of the screen (X < $50), else 0. Used for
;his facing frame and the shot's start offset.	;[ok]
EnkerGetSide:	;$5FC5
	ld d, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $50
	jr nc, .l5FD1
	inc d
.l5FD1
	ret

EnkerSpawnShot:	;$5FD2
	ld l, c
	push hl
	ld a, $27
	ld [$CC07], a
	ld a, e
	ld [$CC0D], a
	ld a, d
	ld [$CC0F], a
	ld a, b
	ld [$CC08], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $3F
	ld [$CC05], a
	call SpawnChildObject_09
	call EnkerShotInit
	pop hl
	ld c, l
	ret

EnkerSetShortJump:	;$5FF8
	ld a, $31
	add a, c
	ld l, a
	ld [hl], $10
	inc l
	ld [hl], $4E
	inc l
	ld [hl], $03
	ret

EnkerSetLongJump:	;$6005
	ld a, $31
	add a, c
	ld l, a
	ld [hl], $20
	inc l
	ld [hl], $4E
	inc l
	ld [hl], $03
	ret

EnkerAnimateWalk:	;$6012
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	ret c
	xor a
	ld [hl+], a
	inc [hl]
	ld a, [hl]
	and $03
	ld [hl], a
	ld e, a
	ld d, $00
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l602F
	ld d, $04
.l602F
	ld a, $17
	add a, c
	ld l, a
	ld a, $08
	add a, e
	add a, d
	ld [hl], a
	ret

FrameTable_6039:	;$6039
	dw Frame_6059, Frame_6112, Frame_6073, Frame_612C
	dw Frame_608A, Frame_6143, Frame_60A7, Frame_6160
	dw Frame_60CA, Frame_60E2, Frame_60FA, Frame_60E2
	dw Frame_6183, Frame_619B, Frame_61B3, Frame_619B

Frame_6059:	;$6059
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $01, $02, $03, $04, $05, $06, $08, $09, $FF, $FF, $0A, $FF
	db $08, $F8, $00
	db $F8, $10, $07
	db $80

Frame_6073:	;$6073
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $01, $02, $03, $0B, $0C, $0D, $0F, $10, $11
	db $08, $F8, $00
	db $F8, $10, $0E
	db $80

Frame_608A:	;$608A
	db $F8, $FF, $D4, $0B	;hitbox
	db $F4, $EC, $34	;dx, dy, 3x4
	db $1F, $20, $FF, $21, $22, $23, $24, $25, $26, $27, $28, $29
	db $00, $E8, $1C
	db $00, $F0, $1D
	db $00, $F8, $1E
	db $80

Frame_60A7:	;$60A7
	db $CC, $00, $F4, $0B	;hitbox
	db $E8, $F4, $33	;dx, dy, 3x3
	db $01, $02, $12, $17, $0C, $0D, $18, $19, $1A
	db $08, $F8, $00
	db $E0, $08, $13
	db $E8, $08, $14
	db $F0, $08, $15
	db $F8, $08, $16
	db $18, $10, $1B
	db $80

Frame_60CA:	;$60CA
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $2A, $2B, $FF, $2C, $2D, $2E, $2F, $30, $31, $32, $33, $FF, $34, $35, $36
	db $80

Frame_60E2:	;$60E2
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $2A, $2B, $FF, $2C, $2D, $2E, $2F, $30, $37, $38, $33, $FF, $39, $3A, $FF
	db $80

Frame_60FA:	;$60FA
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $2A, $2B, $FF, $2C, $2D, $2E, $2F, $30, $3B, $3C, $33, $FF, $3D, $3E, $FF
	db $80

Frame_6112:	;$6112
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $34	;dx, dy, 3x4
	db $83, $82, $81, $86, $85, $84, $FF, $89, $88, $FF, $8A, $FF
	db $08, $F8, $80
	db $18, $10, $87
	db $80

Frame_612C:	;$612C
	db $FC, $03, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $83, $82, $81, $8D, $8C, $8B, $91, $90, $8F
	db $08, $F8, $80
	db $18, $10, $8E
	db $80

Frame_6143:	;$6143
	db $00, $07, $D4, $0B	;hitbox
	db $F4, $EC, $34	;dx, dy, 3x4
	db $FF, $A0, $9F, $A3, $A2, $A1, $A6, $A5, $A4, $A9, $A8, $A7
	db $10, $E8, $9C
	db $10, $F0, $9D
	db $10, $F8, $9E
	db $80

Frame_6160:	;$6160
	db $00, $33, $F4, $0B	;hitbox
	db $00, $F4, $33	;dx, dy, 3x3
	db $92, $82, $81, $8D, $8C, $97, $9A, $99, $98
	db $08, $F8, $80
	db $18, $08, $96
	db $20, $08, $95
	db $28, $08, $94
	db $30, $08, $93
	db $F8, $10, $9B
	db $80

Frame_6183:	;$6183
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $AB, $AA, $FF, $AF, $AE, $AD, $AC, $B3, $B2, $B1, $B0, $B6, $B5, $B4, $FF
	db $80

Frame_619B:	;$619B
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $AB, $AA, $FF, $AF, $AE, $AD, $AC, $B3, $B8, $B7, $B0, $FF, $BA, $B9, $FF
	db $80

Frame_61B3:	;$61B3
	db $FC, $03, $F4, $0B	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $FF, $AB, $AA, $FF, $AF, $AE, $AD, $AC, $B3, $BC, $BB, $B0, $FF, $BE, $BD, $FF
	db $80
