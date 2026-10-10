;Mega Man: Dr. Wily's Revenge disassembly - object type 15, KaminariGoro
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "KaminariGoro (type 15)", ROMX[$5151], BANK[$9]

;Kaminari Goro, also called Lightning Lord (Will; the ending lists KAMINARI
;GORO). In the code the platform (this type) and the figure on it
;(type 14, KaminariGoroThrower) are separate objects.	;[ok]
;Object type 15, placed three times in Elec Man's stage. Spawn: tile base +$11,
;circle centre at (X+4, Y), direction from Mega Man's side, and one type 14
;(KaminariGoroSpawnThrower). A platform that moves round a circle of radius about 28 px
;(96 steps, one per 8 frames, KaminariGoroOrbitOffsets; paused by Time Stopper) and
;carries Mega Man standing on it. Refills its hit points to $64 every frame.
;Modes 1 and 3 are the same (Ice Slasher does nothing). Killed or off screen:
;removed.	;[ok]
KaminariGoroRoutine:	;$5151
	ld a, b
	or a
	jr z, KaminariGoroInit
	dec a
	jr z, KaminariGoroUpdate
	dec a
	jr z, .l515E
	dec a
	jr z, KaminariGoroUpdate
.l515E
	ld b, $00
	ret

;Unused: nothing calls it. The scroll correction from the top of
;KaminariGoroUpdate (add $D851, the negated camera movement, to the orbit
;centre X at $2A and the old X at $2E) without the hit-point refill, freeze
;test or timer, then KaminariGoroMoveAndCarry.	;[ok]
KaminariGoroScrollUnused:	;$5161
	ld a, $2A
	add a, c
	ld l, a
	ld a, [$D851]
	ld d, a
	add a, [hl]
	ld [hl], a
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	jp KaminariGoroMoveAndCarry

KaminariGoroInit:	;$5175
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $11
	ld [hl], a
	ld a, $28
	add a, c
	ld l, a
	ld a, $FF
	ld [hl+], a
	ld [hl], $00
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld a, e
	add a, $04
	ld [hl], a
	inc l
	ld [hl], d
	ld d, $00
	ld a, e
	cp $E0
	jr nc, .l51A6
	ld a, [wPlayerX]
	cp e
	jr nc, .l51A6
	inc d
.l51A6
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], d
	call ObjFaceMegaManOnScreen_09
	ld de, Data_09_5379
	call AnimateObjectFacing_09
	call KaminariGoroSpawnThrower
	jr KaminariGoroMoveAndCarry

KaminariGoroOrbitTimerArgs:	;$51B9
	db $28, $07, $5F

KaminariGoroUpdate:	;$51BC
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $64
	ld a, $2A
	add a, c
	ld l, a
	ld a, [$D851]
	ld d, a
	add a, [hl]
	ld [hl], a
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ld a, [wFreezeFlags]
	or a
	jp nz, KaminariGoroMoveAndCarry
	ld de, KaminariGoroOrbitTimerArgs
	call ObjCountTimer_09

KaminariGoroMoveAndCarry:	;$51E0
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl+]
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	ld de, Frame_5387
	call CheckPlayerOnObject_09
	push af
	call KaminariGoroSetOrbitPosition
	ld a, $0D
	add a, c
	ld l, a
	ld a, $2E
	add a, c
	ld e, a
	ld d, h
	ld a, [de]
	cp [hl]
	jr z, .l520B
	ld b, $00
	jr nc, .l5206
	inc b
.l5206
	ld a, $24
	add a, c
	ld l, a
	ld [hl], b
.l520B
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5218
	ld de, Data_09_5379
	call AnimateObjectFacing_09
.l5218
	pop af
	jr nc, .l5233
	ld a, $0D
	add a, c
	ld e, a
	ld a, $2E
	add a, c
	ld l, a
	ld d, h
	ld a, [de]
	sub [hl]
	ld b, a
	inc e
	inc e
	inc l
	ld a, [de]
	sub [hl]
	ld d, a
	ld e, b
	ld b, h
	call PushPlayer_09
	ld h, b
.l5233
	ld a, $0D
	add a, c
	ld l, a
	ld a, $2E
	add a, c
	ld e, a
	ld d, h
	ld a, [hl+]
	ld [de], a
	inc l
	inc e
	ld a, [hl]
	ld [de], a
	call ObjCheckOnScreen_09
	ld a, $09
	add a, c
	ld l, a
	ld [hl], b
	ret

KaminariGoroSetOrbitPosition:	;$524B
	ld a, $2D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $29
	add a, c
	ld l, a
	ld a, e
	or a
	ld a, [hl]
	jr z, .l525C
	ld a, $5F
	sub [hl]
.l525C
	add a, a
	add a, LOW(KaminariGoroOrbitOffsets)
	ld e, a
	ld a, $00
	adc a, HIGH(KaminariGoroOrbitOffsets)
	ld d, a
	ld a, [de]
	inc de
	ld b, a
	ld a, [de]
	ld d, a
	ld e, b
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, [hl+]
	add a, d
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ret

KaminariGoroSpawnThrower:	;$527E
	ld l, c
	push hl
	ld a, $0E
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0D], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	sub $11
	ld [$CC05], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC08], a
	call SpawnChildObject_09
	pop de
	push de
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	call KaminariGoroThrowerInit
	pop hl
	ld c, l
	ret

KaminariGoroOrbitOffsets:	;$52B9
	db $00, $E4, $02, $E4, $04, $E4, $05, $E5, $07, $E5, $09, $E5, $0B, $E6, $0C, $E7
	db $0E, $E8, $10, $E9, $11, $EA, $12, $EB, $14, $EC, $15, $EE, $16, $EF, $17, $F0
	db $18, $F2, $19, $F4, $1A, $F5, $1B, $F7, $1B, $F9, $1B, $FB, $1C, $FC, $1C, $FE
	db $1C, $00, $1C, $02, $1C, $04, $1B, $05, $1B, $07, $1B, $09, $1A, $0B, $19, $0C
	db $18, $0E, $17, $10, $16, $11, $15, $12, $14, $14, $12, $15, $11, $16, $10, $17
	db $0E, $18, $0C, $19, $0B, $1A, $09, $1B, $07, $1B, $05, $1B, $04, $1C, $02, $1C
	db $00, $1C, $FE, $1C, $FC, $1C, $FB, $1B, $F9, $1B, $F7, $1B, $F5, $1A, $F4, $19
	db $F2, $18, $F0, $17, $EF, $16, $EE, $15, $EC, $14, $EB, $12, $EA, $11, $E9, $10
	db $E8, $0E, $E7, $0C, $E6, $0B, $E5, $09, $E5, $07, $E5, $06, $E4, $04, $E4, $02
	db $E4, $00, $E4, $FE, $E4, $FC, $E5, $FB, $E5, $F9, $E5, $F7, $E6, $F5, $E7, $F4
	db $E8, $F2, $E9, $F0, $EA, $EF, $EB, $EE, $EC, $EC, $ED, $EB, $EF, $EA, $F0, $E9
	db $F2, $E8, $F4, $E7, $F5, $E6, $F7, $E6, $F9, $E5, $FA, $E5, $FC, $E4, $FE, $E4

Data_09_5379:	;$5379
	dw FrameTable_537F
	db 3	;frames per step
	db $00, $02, $FF

FrameTable_537F:	;$537F
	dw Frame_5387, Frame_53A3, Frame_5395, Frame_53B1

Frame_5387:	;$5387
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $03, $04, $05
	db $80

Frame_5395:	;$5395
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $06, $07, $08
	db $80

Frame_53A3:	;$53A3
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $82, $81, $80, $85, $84, $83
	db $80

Frame_53B1:	;$53B1
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $82, $81, $80, $88, $87, $86
	db $80
