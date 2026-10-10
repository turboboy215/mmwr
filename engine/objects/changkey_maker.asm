;Mega Man: Dr. Wily's Revenge disassembly - object type 12, ChangkeyMaker
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ChangkeyMaker (type 12)", ROMX[$4BC0], BANK[$9]

;Changkey Maker (Will; the ending lists CHANGKEY MAKER).	;[ok]
;Object type 12, placed in Fire Man (nine), Wily 1 and Wily 3. Spawn: tile
;base + 8, first throw after 60 frames. Faces Mega Man; when he is within 100 px
;sideways it takes a throw pose (16 frames) and throws a type 11 (ChangkeyMakerThrowChangkey),
;then animates 120 frames before it can throw again. Frozen (Ice Slasher or Time
;Stopper): does nothing. Never removed off screen. Killed: removed.	;[ok]
ChangkeyMakerRoutine:	;$4BC0
	ld a, b
	or a
	jr z, .l4BD1
	dec a
	jr z, .l4BF0
	dec a
	jr z, .l4BCD
	dec a
	jr z, .l4BD0
.l4BCD
	ld b, $00
	ret
.l4BD0
	ret
.l4BD1
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $08
	ld [hl], a
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $3C
	ld de, Data_09_4D33
	call AnimateObjectFacing_09
	ld b, $01
	ret
.l4BF0
	ld a, [wFreezeFlags]
	or a
	jp nz, .l4C6B
	call ObjFaceMegaMan_09
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl-]
	or a
	jr nz, .l4C41
	ld a, [hl]
	or a
	jr nz, .l4C57
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l4C12
	cpl
	inc a
.l4C12
	cp $64
	jr nc, .l4C65
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4C21
	dec [hl]
	jr .l4C65
.l4C21
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $01
	ld a, d
	or a
	jr z, .l4C36
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $05
	call ChangkeyMakerThrowChangkey
	jr .l4C6B
.l4C36
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04
	call ChangkeyMakerThrowChangkey
	jr .l4C6B
.l4C41
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $0F
	jr nz, .l4C6B
	ld [hl-], a
	ld [hl-], a
	ld [hl], $01
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	jr .l4C6B
.l4C57
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $78
	jr c, .l4C65
	xor a
	ld [hl-], a
	ld [hl-], a
	ld [hl-], a
.l4C65
	ld de, Data_09_4D33
	call AnimateObjectFacing_09
.l4C6B
	ld b, $01
	ret

;Spawn a type 11 15 px up and 15 px (left) / 23 px (right) out, with param 1
;and this object's original tile base, and run ChangkeyInit on it. Its X speed is
;picked from ChangkeyMakerThrowSpeeds by Mega Man's distance (0.5 to 2.125 px/frame),
;moved -1..+2 rows at random (JumpRNG); Y speed -3 px/frame.	;[ok]
ChangkeyMakerThrowChangkey:	;$4C6E
	ld b, h
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	ld [$CC59], a
	ld e, a
	ld d, $00
	ld hl, ChangkeyMakerThrowOffsets
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, b
	ld a, $0B
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [$CC0D], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [$CC0F], a
	ld a, $01
	ld [$CC06], a
	xor a
	ld [$CC08], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	sub $08
	ld [$CC05], a
	call SpawnChildObject_09
	call ChangkeyInit
	ld a, [$CC0D]
	ld e, a
	ld a, [wPlayerX]
	sub e
	jr nc, .l4CC1
	cpl
	inc a
.l4CC1
	ld hl, ChangkeyMakerThrowSpeeds - 3
	ld d, $00
	ld b, $06
.l4CC8
	inc hl
	inc hl
	inc hl
	cp [hl]
	jr c, .l4CD3
	inc d
	dec b
	jr nz, .l4CC8
	dec d
.l4CD3
	call JumpRNG
	and $03
	cp $03
	jr nz, .l4CDE
	ld a, $FF
.l4CDE
	add a, d
	cp $F0
	jr nc, .l4CEB
	cp $06
	jr c, .l4CEC
	ld a, $05
	jr .l4CEC
.l4CEB
	xor a
.l4CEC
	ld e, a
	ld d, $00
	ld hl, ChangkeyMakerThrowSpeeds + 1
	add hl, de
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, [$CC59]
	or a
	call nz, JumpNegateDE
	ld a, [$CC42]
	ld c, a
	ld a, [$CC43]
	ld h, a
	ld a, $1C
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], $00
	inc l
	ld [hl], $FD
	ld a, [$CC40]
	ld c, a
	ld a, [$CC41]
	ld h, a
	ret

ChangkeyMakerThrowOffsets:	;$4D1D
	db $F1, $F1
	db $17, $F1

ChangkeyMakerThrowSpeeds:	;$4D21
	db $14
	dw $FF80
	db $28
	dw $FF00
	db $46
	dw $FEC0
	db $5A
	dw $FE80
	db $6E
	dw $FE00
	db $78
	dw $FDE0

Data_09_4D33:	;$4D33
	dw FrameTable_4D39
	db 20	;frames per step
	db $00, $02, $FF

FrameTable_4D39:	;$4D39
	dw Frame_4D45, Frame_4D91, Frame_4D5D, Frame_4DA9
	dw Frame_4D75, Frame_4DC1

Frame_4D45:	;$4D45
	db $F0, $0F, $F0, $0F	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $00, $01, $02, $03, $04, $05, $06, $07, $FF, $08, $09, $0A, $0B, $0C, $0D, $0E
	db $80

Frame_4D5D:	;$4D5D
	db $F0, $0F, $F0, $0F	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $00, $0F, $10, $11, $04, $05, $06, $07, $FF, $08, $09, $0A, $0B, $0C, $0D, $0E
	db $80

Frame_4D75:	;$4D75
	db $E4, $03, $F0, $0F	;hitbox
	db $E4, $F0, $54	;dx, dy, 5x4
	db $FF, $12, $13, $14, $FF, $15, $16, $17, $18, $FF, $19, $1A, $1B, $1C, $FF, $1D, $1E, $1F, $20, $21
	db $80

Frame_4D91:	;$4D91
	db $F0, $0F, $F0, $0F	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $83, $82, $81, $80, $87, $86, $85, $84, $8A, $89, $88, $FF, $8E, $8D, $8C, $8B
	db $80

Frame_4DA9:	;$4DA9
	db $F0, $0F, $F0, $0F	;hitbox
	db $F0, $F0, $44	;dx, dy, 4x4
	db $91, $90, $8F, $80, $87, $86, $85, $84, $8A, $89, $88, $FF, $8E, $8D, $8C, $8B
	db $80

Frame_4DC1:	;$4DC1
	db $FB, $1B, $F0, $0F	;hitbox
	db $F4, $F0, $54	;dx, dy, 5x4
	db $FF, $94, $93, $92, $FF, $FF, $98, $97, $96, $95, $FF, $9C, $9B, $9A, $99, $A1, $A0, $9F, $9E, $9D
	db $80
