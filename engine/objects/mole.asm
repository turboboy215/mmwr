;Mega Man: Dr. Wily's Revenge disassembly - object type 18, Mole
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Mole (type 18)", ROMX[$796B], BANK[$3]

;Mole (Will; the ending lists MOLE): the placed object is the controller that
;spawns the moles.	;[ok]
;Type 18, placed twice per room in Wily 1. The placed one is an invisible
;controller: it spawns type 18 children (a thin 8x24 sprite) while the camera is
;over a range of +08 columns from its own (or ending at it, by param bit 0);
;if another controller exists it removes itself. Each of four slots spawns a
;child at a fixed screen point (MoleSpawnPoints) - two at the top moving down,
;two at the bottom moving up, about 0.5 px a frame, speeding up to 4 px a frame
;(and harmless) where both its probes are solid - and waits 30 frames after it
;is gone. Live slots are bits of $CC5A.	;[ok]
MoleRoutine:	;$796B
	ld a, $09
	add a, c
	ld l, a
	bit 7, [hl]
	jp nz, MoleChildRoutine
	ld a, b
	or a
	jr z, .l7987
	dec a
	jr z, .l79E2
	dec a
	jr z, .l7981
	dec a
	jr z, .l7984
.l7981
	ld b, $00
	ret
.l7984
	jp ObjClearFreeze_03
.l7987
	ld a, $12
	call FindObjectsOfType_03
	ld a, [$CC00]
	cp $FF
	jr z, .l79A2
	ld a, [$CC02]
	cp $FF
	jr z, .l79A2
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	jr .l79DF
.l79A2
	ld a, $06
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	dec d
	ld a, $02
	add a, c
	ld l, a
	ld a, [hl]
	bit 0, e
	jr z, .l79B7
	sub d
.l79B7
	ld e, a
	add a, d
	ld d, a
	inc d
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], $03
	inc l
	ld [hl], $06
	inc l
	ld [hl], $09
	ld a, $10
	add a, c
	ld l, a
	push hl
	push bc
	ld a, [hl]
	call JumpFreeSprite
	pop bc
	pop hl
	ld [hl], $40
.l79DF
	ld b, $01
	ret
.l79E2
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	cp $01
	jr z, .l7981
	ld a, [wFreezeFlags]
	or a
	jp nz, .l79F5
	call MoleSpawnChildren
.l79F5
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $01
	ld b, a
	ld [$CC44], a
	ret

MoleSpawnChildren:	;$7A08
	ld a, $28
	add a, c
	ld l, a
	ld e, [hl]
	ld a, [$CC5A]
	ld [hl+], a
	cpl
	and e
	and $0F
	ldh [$FF95], a
	xor a
.l7A18
	ld [$CC08], a
	ld b, a
	ld a, $29
	add a, c
	ld l, a
	ld a, b
	add a, l
	ld l, a
	ldh a, [$FF95]
	rra
	ldh [$FF95], a
	jr nc, .l7A2E
	ld [hl], $1E
	jr .l7A75
.l7A2E
	ld a, [hl]
	or a
	jr z, .l7A35
	dec [hl]
	jr .l7A75
.l7A35
	ld a, b
	call MoleSlotToMask
	ld a, [$CC5A]
	and b
	jr nz, .l7A75
	ld b, h
	ld a, [$CC08]
	add a, a
	ld l, a
	ld h, $00
	ld de, MoleSpawnPoints
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, b
	ld a, [$D811]
	add a, e
	ld b, a
	ld a, [$D812]
	adc a, $00
	srl a
	rr b
	srl a
	rr b
	srl a
	rr b
	srl a
	rr b
	ld a, $2D
	add a, c
	ld l, a
	ld a, b
	cp [hl]
	jr c, .l7A75
	inc l
	cp [hl]
	jr c, MoleSpawnChild
.l7A75
	ld a, [$CC08]
	inc a
	cp $04
	jr c, .l7A18
	ret

MoleSpawnPoints:	;$7A7E
	db $68, $00, $70, $86
	db $78, $00, $80, $86

MoleSpawnChild:	;$7A86
	ld l, c
	push hl
	ld a, $12
	ld [$CC07], a
	ld a, e
	ld [$CC0D], a
	ld a, d
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_03
	call MoleInitChild
	pop hl
	ld c, l
	ret

MoleGetSlotMask:	;$7AA6
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]

;B = the bit for mole slot A & 3 (ObjLibBitMasks_03), as in $CC5A.	;[ok]
MoleSlotToMask:	;$7AAB
	and $03
	add a, LOW(ObjLibBitMasks_03)
	ld e, a
	ld a, $00
	adc a, HIGH(ObjLibBitMasks_03)
	ld d, a
	ld a, [de]
	ld b, a
	ret

MoleInitChild:	;$7AB8
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $80
	call MoleGetSlotMask
	ld a, [$CC5A]
	or b
	ld [$CC5A], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	ld e, a
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], e
	ld b, $01
	ret

MoleChildFrozen:	;$7AD8
	call ObjClearFreeze_03
	jp MoleChildCheckOnScreen

MoleChildRoutine:	;$7ADE
	ld a, b
	or a
	jr z, MoleInitChild
	dec a
	jr z, MoleChildUpdate
	dec a
	jr z, MoleRemoveChild
	dec a
	jr z, MoleChildFrozen

MoleRemoveChild:	;$7AEB
	call MoleGetSlotMask
	ld a, b
	cpl
	ld b, a
	ld a, [$CC5A]
	and b
	ld [$CC5A], a
	ld b, $00
	ret

MoleChildUpdate:	;$7AFB
	ld a, [wFreezeFlags]
	or a
	jp nz, MoleChildCheckOnScreen
	push hl
	ld b, $00
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC2C], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0D], a
	ld e, a
	inc l
	inc l
	ld a, [hl]
	ld [$CC0F], a
	add a, $03
	ld d, a
	push bc
	call JumpCheckSolidPoint
	pop bc
	jr nc, .l7B27
	inc b
.l7B27
	ld a, [$CC0D]
	ld e, a
	ld a, [$CC0F]
	sub $03
	ld d, a
	push bc
	call JumpCheckSolidPoint
	pop bc
	jr nc, .l7B39
	inc b
.l7B39
	ld a, b
	cp $02
	ld a, $15
	jr c, .l7B42
	ld a, $14
.l7B42
	ld [$CC11], a
	ld a, [$CC2C]
	add a, a
	add a, a
	add a, b
	ld e, a
	ld d, $00
	ld hl, MoleChildSpeeds
	add hl, de
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld a, $0E
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	adc a, [hl]
	ld [hl+], a
	ld a, $11
	add a, c
	ld l, a
	ld a, [$CC11]
	ld [hl], a
	ld a, $2C
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $24
	add a, c
	ld l, a
	ld [hl], e
	ld de, Data_03_7B90
	call AnimateObjectFacing_03

MoleChildCheckOnScreen:	;$7B79
	call ObjSyncAndCheckOnScreen_03
	ld a, b
	or a
	jp z, MoleRemoveChild
	ret

MoleChildSpeeds:	;$7B82
	db $8C, $00, $69, $00
	db $00, $04, $00, $00
	db $74, $FF, $97, $FF
	db $00, $FC

Data_03_7B90:	;$7B90
	dw FrameTable_03_7B97
	db 5	;frames per step
	db $00, $02, $04, $FF

FrameTable_03_7B97:	;$7B97
	dw Frame_03_7BC4, Frame_03_7BA3, Frame_03_7BCF, Frame_03_7BAE
	dw Frame_03_7BDA, Frame_03_7BB9

Frame_03_7BA3:	;$7BA3
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $01, $02, $00
	db $80

Frame_03_7BAE:	;$7BAE
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $03, $04, $00
	db $80

Frame_03_7BB9:	;$7BB9
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $05, $06, $00
	db $80

Frame_03_7BC4:	;$7BC4
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $40, $42, $41
	db $80

Frame_03_7BCF:	;$7BCF
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $40, $44, $43
	db $80

Frame_03_7BDA:	;$7BDA
	db $FC, $03, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $40, $46, $45
	db $80
