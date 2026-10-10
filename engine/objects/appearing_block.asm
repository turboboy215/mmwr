;Mega Man: Dr. Wily's Revenge disassembly - object type 20, AppearingBlock
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "AppearingBlock (type 20)", ROMX[$6ED9], BANK[$3]

;The appearing blocks (type 20), placed in Elec Man (5) and Wily 3 (2). One
;object runs a whole schedule of blocks (AppearingBlockSchedules[param]), using
;a second object slot as scratch for each block's countdown and age. Once Mega
;Man is within 160 px a timer counts up and wraps at the schedule's cycle
;length; each entry's block appears when the timer reaches its start frame and
;stays for its duration (180 frames in every entry) - drawn with a 3-step appear
;animation, made solid with AddSolidBox and sounding $1E on its first frame -
;while its column is inside the spawn window. Time Stopper and Ice Slasher do
;not stop it. Killed: frees the scratch slot.	;[ok]
AppearingBlockRoutine:	;$6ED9
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl+]
	ldh [$FFAA], a
	ld a, [hl+]
	ldh [$FFAB], a
	ld a, b
	or a
	jr z, AppearingBlockInit
	dec a
	jp z, AppearingBlockUpdate
	dec a
	jr z, .l6EF2
	dec a
	jp z, AppearingBlockUpdate
.l6EF2
	ld a, $27
	add a, c
	ld l, a
	ld b, [hl]
	call JumpFreeObjectSlot
	call AppearingBlockFreeUnusedSprites
	ld b, $00
	ret

;Unused: nothing calls it. B = 1.	;[ok]
Unused_03_6F00:	;$6F00
	ld b, $01
	ret

AppearingBlockInit:	;$6F03
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $A9
	inc l
	ld [hl], $72
	inc l
	ld [hl], $00
	push hl
	push bc
	call JumpAllocObjectSlot
	ld e, b
	pop bc
	pop hl
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld b, h
	ld l, e
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C600
	add hl, de
	ld e, l
	ld d, h
	ld h, b
	ld a, $28
	add a, c
	ld l, a
	ld a, e
	ld [hl+], a
	ldh [$FFAA], a
	ld a, d
	ld [hl], a
	ldh [$FFAB], a
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $0F
	push hl
	add a, a
	ld l, a
	ld h, $00
	ld de, AppearingBlockSchedules
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	pop hl
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	call AppearingBlockCountSchedule
	ld a, $30
	add a, c
	ld l, a
	ld [hl], b
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	call AppearingBlockLoadScratch
	ld a, $32
	add a, c
	ld e, a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], e
	ld b, $01
	ret

AppearingBlockUpdate:	;$6F74
	ld a, [wFreezeFlags]
	and $F5
	jp nz, .l7054
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l6FC9
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l6F90
	cpl
	inc a
.l6F90
	cp $A0
	jp nc, .l7054
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
	ldh a, [$FFAA]
	ld e, a
	ldh a, [$FFAB]
	ld d, a
	ld b, $18
	xor a
.l6FA7
	ld [de], a
	inc e
	ld [de], a
	inc e
	dec b
	jr nz, .l6FA7
	ld l, c
	push hl
	call AppearingBlockLoadScratch
	ld a, $32
	add a, c
	ld e, a
	ld a, $30
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], e
	pop hl
	ld c, l
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	jp .l7054
.l6FC9
	ld a, $2A
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	inc de
	inc l
	ld a, [hl+]
	sub e
	ld a, [hl-]
	dec l
	sbc a, d
	jr nc, .l6FDC
	ld de, $0000
.l6FDC
	ld a, d
	ldh [$FFA7], a
	ld [hl-], a
	ld a, e
	ldh [$FFA6], a
	ld [hl-], a
	ld a, $2E
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push de
	ld a, $30
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFAE], a
	xor a
	ldh [$FFAF], a
	call AppearingBlockLoadScratch
	ld a, $32
	add a, c
	ld e, a
	ld l, e
	dec l
	ld [hl], e
	pop de
	ld l, c
.l7002
	ld a, e
	ldh [$FFAC], a
	ld a, d
	ldh [$FFAD], a
	ld a, [hl]
	or a
	jr nz, .l702F
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	ldh a, [$FFA6]
	sub c
	ldh a, [$FFA7]
	sbc a, b
	jr c, .l703B
	ld a, [de]
	add a, c
	ld c, a
	ld a, $00
	adc a, b
	ld b, a
	ldh a, [$FFA6]
	sub c
	ldh a, [$FFA7]
	sbc a, b
	jr nc, .l703B
	ld a, [de]
	ld [hl+], a
	xor a
	ld [hl+], a
	jr .l703D
.l702F
	dec [hl]
	inc l
	inc [hl]
	ld a, [hl+]
	push hl
	ld h, a
	call AppearingBlockDrawBlock
	pop hl
	jr .l703D
.l703B
	inc l
	inc l
.l703D
	ldh a, [$FFAC]
	ld e, a
	ldh a, [$FFAD]
	ld d, a
	inc de
	inc de
	inc de
	inc de
	inc de
	inc de
	ldh a, [$FFAE]
	ld b, a
	ldh a, [$FFAF]
	inc a
	ldh [$FFAF], a
	cp b
	jr c, .l7002
.l7054
	call AppearingBlockFreeUnusedSprites
	ld a, $01
	ld [$CC44], a
	ld b, $01
	ret

AppearingBlockDrawBlock:	;$705F
	inc de
	inc de
	inc de
	ld a, [$D856]
	ld c, a
	ld a, [$D857]
	ld b, a
	ld a, [de]
	cp c
	ret c
	cp b
	ret nc
	ld a, [$D811]
	ld l, a
	ld a, [de]
	add a, a
	add a, a
	add a, a
	add a, a
	sub l
	add a, $08
	ldh [$FFA2], a
	inc de
	ld a, [de]
	inc de
	add a, a
	add a, a
	add a, a
	add a, a
	ld l, a
	ld a, [de]
	add a, l
	add a, $07
	ldh [$FFA3], a
	ld b, h
	call AppearingBlockLoadSelf
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $10
	ld [$D3EA], a
	push bc
	call AppearingBlockGetSprite
	ldh [hBank1CallIndex], a
	pop bc
	ld a, b
	cp $01
	jr nz, .l70AD
	ld a, $1E
	call JumpQueueSound
.l70AD
	ld hl, Frame_03_72BD + 4
	cp $04
	jr c, .l70C5
	ld hl, Frame_03_72C9 + 4
	cp $08
	jr c, .l70C5
	ld hl, Frame_03_72D5 + 4
	cp $0C
	jr c, .l70C5
	ld hl, Frame_03_72B1 + 4
.l70C5
	push hl
	dec hl
	dec hl
	dec hl
	dec hl
	ldh a, [$FFA2]
	ld c, a
	ldh a, [$FFA3]
	ld b, a
	call JumpAddSolidBox
	pop hl
	ldh a, [hBank1CallIndex]
	jp JumpDrawMetasprite

AppearingBlockLoadSelf:	;$70D9
	ld a, [$CC40]
	ld c, a
	ld a, [$CC41]
	ld h, a
	ret

AppearingBlockLoadScratch:	;$70E2
	ld a, [$CC40]
	ld c, a
	ld a, [$CC41]
	ld h, a
	ld a, $28
	add a, c
	ld l, a
	ld c, [hl]
	inc l
	ld h, [hl]
	ret

AppearingBlockGetSprite:	;$70F2
	ld l, c
	push hl
	call AppearingBlockLoadScratch
	ld a, $30
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld a, [hl]
	inc [hl]
	ld l, a
	cp e
	jr c, .l710B
	push hl
	ld a, $04
	call JumpAllocSprite
	pop hl
	ld [hl], a
.l710B
	ld a, [hl]
	pop hl
	ld c, l
	ret

AppearingBlockFreeUnusedSprites:	;$710F
	ld l, c
	push hl
	call AppearingBlockLoadScratch
	ld a, $30
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld a, [hl-]
	ld [hl], a
	ld l, a
.l711D
	ld a, l
	cp e
	jr nc, .l712B
	ld a, [hl+]
	push hl
	push de
	call JumpFreeSprite
	pop de
	pop hl
	jr .l711D
.l712B
	pop hl
	ld c, l
	ret

AppearingBlockCountSchedule:	;$712E
	ld b, $00
	push hl
	inc de
	inc de
.l7133
	ld a, [de]
	cp $FF
	jr z, .l7143
	inc b
	ld a, $06
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr .l7133
.l7143
	dec de
	ld a, [de]
	ld l, a
	dec de
	ld a, [de]
	ld e, a
	ld d, l
	pop hl
	ret

;One schedule per param (index 0 duplicates 1 and is never used). Each entry:
;dw start frame; db duration ($B4 = 180 frames), block column, row, Y offset
;(always 0). A list ends with dw cycle length, $FF; the timer runs 0..cycle and
;wraps. Columns are spawn-list columns, rows 16-px rows of the room.	;[ok]
AppearingBlockSchedules:	;$714C
	dw Data_03_715C, Data_03_715C, Data_03_7177, Data_03_7192
	dw Data_03_71A1, Data_03_71BC, Data_03_71D1, Data_03_7246

Data_03_715C:	;$715C
	dw $001E
	db $B4, $0B, $05, $00
	dw $008C
	db $B4, $0D, $04, $00
	dw $00FA
	db $B4, $0C, $06, $00
	dw $0168
	db $B4, $0F, $05, $00
	dw $01B8
	db $FF
Data_03_7177:	;$7177
	dw $005A
	db $B4, $06, $06, $00
	dw $00C3
	db $B4, $07, $04, $00
	dw $012C
	db $B4, $04, $07, $00
	dw $0195
	db $B4, $04, $05, $00
	dw $01A4
	db $FF
Data_03_7192:	;$7192
	dw $0000
	db $B4, $05, $04, $00
	dw $0078
	db $B4, $08, $05, $00
	dw $00F0
	db $FF
Data_03_71A1:	;$71A1
	dw $003C
	db $B4, $01, $05, $00
	dw $00F0
	db $B4, $03, $05, $00
	dw $01A4
	db $B4, $02, $05, $00
	dw $0258
	db $B4, $04, $05, $00
	dw $02D0
	db $FF
Data_03_71BC:	;$71BC
	dw $00B4
	db $B4, $06, $05, $00
	dw $0168
	db $B4, $04, $05, $00
	dw $021C
	db $B4, $02, $05, $00
	dw $021C
	db $FF
Data_03_71D1:	;$71D1
	dw $0078
	db $B4, $03, $06, $00
	dw $0078
	db $B4, $11, $06, $00
	dw $00B4
	db $B4, $04, $06, $00
	dw $00B4
	db $B4, $14, $05, $00
	dw $00F0
	db $B4, $05, $05, $00
	dw $00F0
	db $B4, $17, $04, $00
	dw $012C
	db $B4, $06, $05, $00
	dw $012C
	db $B4, $1A, $05, $00
	dw $0168
	db $B4, $07, $05, $00
	dw $0168
	db $B4, $1D, $04, $00
	dw $01A4
	db $B4, $08, $04, $00
	dw $01E0
	db $B4, $09, $04, $00
	dw $01E0
	db $B4, $1E, $06, $00
	dw $021C
	db $B4, $0B, $04, $00
	dw $021C
	db $B4, $20, $05, $00
	dw $0258
	db $B4, $0D, $05, $00
	dw $0258
	db $B4, $1F, $03, $00
	dw $0294
	db $B4, $0F, $04, $00
	dw $0294
	db $B4, $23, $05, $00
	dw $0294
	db $FF
Data_03_7246:	;$7246
	dw $0078
	db $B4, $05, $05, $00
	dw $0078
	db $B4, $14, $05, $00
	dw $00F0
	db $B4, $07, $04, $00
	dw $00F0
	db $B4, $17, $04, $00
	dw $0168
	db $B4, $09, $06, $00
	dw $0168
	db $B4, $19, $06, $00
	dw $01E0
	db $B4, $09, $04, $00
	dw $01E0
	db $B4, $19, $04, $00
	dw $0258
	db $B4, $0C, $05, $00
	dw $0258
	db $B4, $1C, $05, $00
	dw $02D0
	db $B4, $0F, $04, $00
	dw $02D0
	db $B4, $1F, $04, $00
	dw $0348
	db $B4, $11, $06, $00
	dw $0348
	db $B4, $1F, $06, $00
	dw $03C0
	db $B4, $11, $04, $00
	dw $03C0
	db $B4, $22, $06, $00
	dw $03C0
	db $FF

AppearingBlockFrames:	;$72A9
	dw Frame_03_72BD, Frame_03_72C9, Frame_03_72D5, Frame_03_72B1

Frame_03_72B1:	;$72B1
	db $F8, $07, $F9, $00	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $00, $01, $08, $09
	db $80

Frame_03_72BD:	;$72BD
	db $F8, $07, $F9, $00	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $02, $03, $08, $09
	db $80

Frame_03_72C9:	;$72C9
	db $F8, $07, $F9, $00	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $04, $05, $08, $09
	db $80

Frame_03_72D5:	;$72D5
	db $F8, $07, $F9, $00	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $06, $07, $08, $09
	db $80
