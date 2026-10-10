;Mega Man: Dr. Wily's Revenge disassembly - object type 35, ElecManShot
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ElecManShot (type 35)", ROMX[$62CC], BANK[$3]

;Type 35: never placed; Elec Man's shot (ElecManFireShot runs ElecManShotInit
;with E = his facing, tile base his + $3C). It draws a 7-tile chain
;(DrawMetaspriteList) that slides one entry every 2 frames along a zig-zag
;path 32 px tall (ElecManShotPathLeft/Right), its 8x8 hitbox at the chain's
;head; every 14 entries the chain's base moves 40 px on. Removed when the base
;reaches X $C0. Under wFreezeFlags it stops but is still drawn.	;[ok]
;That makes it the Thunder Beam, Elec Man's weapon.	;[?]
;Modes 2 and 3 (moving up or down 8 px every 3 frames, with FrameTable_03_6507)
;are never used: the only caller passes 0 or 1.	;[ok]
ElecManShotRoutine:	;$62CC
	ld a, b
	or a
	jr z, ElecManShotInit
	dec a
	jp z, ElecManShotFrame
	dec a
	jr z, .l62DA
	dec a
	jr z, .l62DD
.l62DA
	ld b, $00
	ret
.l62DD
	jp ObjClearFreeze_03

ElecManShotInit:	;$62E0
	ld a, $09
	add a, c
	ld l, a
	ld a, e
	and $03
	ld [hl], a
	dec a
	jr z, .l62F8
	dec a
	jr z, ElecManShotInitUp
	dec a
	jr z, ElecManShotInitDown
	ld de, ElecManShotPathLeft
	ld b, $D8
	jr .l62FD
.l62F8
	ld de, ElecManShotPathRight
	ld b, $28
.l62FD
	ld a, $28
	add a, c
	ld l, a
	ld [hl], b
	inc l
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $2C
	add a, c
	ld e, a
	ld d, h
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	inc e
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	ld l, c
	push hl
	call JumpFreeSprite
	ld a, $07
	call JumpAllocSprite
	pop hl
	ld c, l
	ld e, a
	ld a, $10
	add a, c
	ld l, a
	ld [hl], e
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $FF
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $46
	inc l
	ld [hl], $63
	jr ElecManShotDrawChain

ElecManShotFrames:	;$6346
	dw ElecManShotHitbox

ElecManShotHitbox:	;$6348
	db $FC, $03, $FC, $03

ElecManShotUpVelocity:	;$634C
	db $00, $00, $E0, $FF
ElecManShotDownVelocity:	;$6350
	db $00, $00, $20, $00

ElecManShotInitUp:	;$6354
	ld de, ElecManShotUpVelocity
	jr ElecManShotInitVertical

ElecManShotInitDown:	;$6359
	ld de, ElecManShotDownVelocity

ElecManShotInitVertical:	;$635C
	call ObjSetVelocity_03
	ld a, $27
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $07
	inc l
	ld [hl], $65
	jr ElecManShotSyncAndCheckOnScreen

ElecManShotFrame:	;$6370
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	cp $02
	jr c, ElecManShotDrawChain
	ld a, [wFreezeFlags]
	or a
	jp nz, ElecManShotSyncAndCheckOnScreen
	jp ElecManShotMoveVertical

ElecManShotSyncAndCheckOnScreen:	;$6383
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
	jp ObjCheckOnScreen_03

ElecManShotDrawChain:	;$6396
	ld a, [wFreezeFlags]
	or a
	jp nz, .l63C1
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $02
	jr c, .l63C1
	ld [hl], $00
	ld a, $25
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0E
	jr c, .l63C1
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
.l63C1
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	ld e, a
	ld a, $25
	add a, c
	ld l, a
	ld a, [hl]
	add a, $07
	sub e
	ld e, a
	ld d, $00
	ld a, $29
	add a, c
	ld l, a
	ld b, h
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	add hl, de
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, b
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	inc l
	ld a, [hl]
	add a, d
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], d
	ld l, c
	push hl
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	add a, $04
	ldh [$FFA4], a
	inc l
	ld a, [hl]
	add a, $0C
	ldh [$FFA5], a
	ld a, $10
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $25
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	add a, [hl]
	ld d, $00
	ld e, a
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, b
	call JumpDrawMetaspriteList
	pop hl
	ld c, l
	ld a, $01
	ld [$CC44], a
	ld b, $01
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	cp $C0
	ret c
	ld b, $00
	ret

ElecManShotPathLeft:	;$6440
	db $00, $00, $08
	db $00, $08, $09
	db $F8, $08, $0A
	db $F8, $00, $0B
	db $F8, $F8, $4B
	db $F0, $F0, $0C
	db $F0, $E8, $49
	db $E8, $E8, $4A
	db $E8, $F0, $08
	db $E8, $F8, $09
	db $E0, $F8, $0A
	db $E0, $F0, $0D
	db $D8, $F0, $06
	db $D8, $F8, $07
	db $D8, $00, $08
	db $D8, $08, $09
	db $D0, $08, $0A
	db $D0, $00, $0B
	db $D0, $F8, $4B
	db $C8, $F0, $0C
	db $C8, $E8, $49
	db $C0, $E8, $4A
ElecManShotPathRight:	;$6482
	db $00, $00, $88
	db $00, $08, $89
	db $08, $08, $8A
	db $08, $00, $8B
	db $08, $F8, $CB
	db $10, $F0, $8C
	db $10, $E8, $C9
	db $18, $E8, $CA
	db $18, $F0, $88
	db $18, $F8, $89
	db $20, $F8, $8A
	db $20, $F0, $8D
	db $28, $F0, $86
	db $28, $F8, $87
	db $28, $00, $88
	db $28, $08, $89
	db $30, $08, $8A
	db $30, $00, $8B
	db $30, $F8, $CB
	db $38, $F0, $8C
	db $38, $E8, $C9
	db $40, $E8, $CA

ElecManShotMoveVertical:	;$64C4
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l6501
	ld [hl], $00
	ld a, $1F
	add a, c
	ld l, a
	bit 7, [hl]
	ld e, $08
	jr z, .l64DC
	ld e, $F8
.l64DC
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl], a
	ld a, $25
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l64EF
	ld [hl], $00
.l64EF
	ld e, [hl]
	ld a, $09
	add a, c
	ld l, a
	bit 0, [hl]
	jr z, .l64FC
	ld a, $02
	sub e
	ld e, a
.l64FC
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
.l6501
	call ObjMoveByVelocity_03
	jp ElecManShotSyncAndCheckOnScreen

FrameTable_03_6507:	;$6507
	dw Frame_03_650D, Frame_03_651B, Frame_03_6529

Frame_03_650D:	;$650D
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $00, $01, $02, $03, $04, $05
	db $80

Frame_03_651B:	;$651B
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $04, $05, $00, $01, $02, $03
	db $80

Frame_03_6529:	;$6529
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $02, $03, $04, $05, $00, $01
	db $80
