;Mega Man: Dr. Wily's Revenge disassembly - object type 23, Icicle
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Icicle (type 23)", ROMX[$757B], BANK[$3]

;The icicle (type 23), placed seven times in Ice Man. Hidden for +08 x 8 frames
;(the spawn record's extra byte), then grows in place, harmless, through frames
;0-2 (20 frames each), then falls with gravity and block collision; when it hits
;something it plays sound $2B and stays, harmless, until it leaves the screen
;sideways. Time Stopper does not stop it. Shots bounce off.	;[ok]
IcicleRoutine:	;$757B
	ld a, b
	or a
	jr z, IcicleInit
	dec a
	jr z, IcicleUpdate
	dec a
	jr z, IcicleRemove
	dec a
	jr z, IcicleUpdate

IcicleRemove:	;$7588
	ld b, $00
	ret

;Unused: a lone ret nothing reaches.	;[ok]
Unused_03_758B:	;$758B
	ret

IcicleInit:	;$758C
	push hl
	ld a, $08
	add a, c
	ld l, a
	ld l, [hl]
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld e, l
	ld d, h
	pop hl
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld de, Data_03_7656
	call AnimateObjectFacing_03
	ld b, $01
	ret

IcicleUpdate:	;$75AA
	ld a, [wFreezeFlags]
	and $F7
	jp nz, .l75EE
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l7603
	dec a
	jr z, .l7622
	dec a
	jp z, .l7648
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	or d
	jr nz, .l75E8
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld l, c
	push hl
	ld a, $04
	call JumpAllocSprite
	ld e, a
	pop hl
	ld c, l
	ld a, $10
	add a, c
	ld l, a
	ld [hl], e
	jr .l75EE
.l75E8
	dec de
	ld [hl], d
	dec l
	ld [hl], e
	jr .l75EE
.l75EE
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $E0
	jr nc, .l75FC
	cp $C0
	jp nc, IcicleRemove
.l75FC
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret
.l7603
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jr c, .l761A
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
	jr .l75EE
.l761A
	ld de, Data_03_7656
	call AnimateObjectFacing_03
	jr .l75EE
.l7622
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $05
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $03
	call ObjApplyGravity_03
	ld de, Frame_03_7687
	call ObjMoveWithCollision_03
	bit 1, a
	jr z, .l75EE
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $2B
	call JumpQueueSound
	jr .l75EE
.l7648
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $06
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04
	jr .l75EE

Data_03_7656:	;$7656
	dw FrameTable_03_765F
	db 20	;frames per step
	db $00, $01, $02, $03, $04, $FF

FrameTable_03_765F:	;$765F
	dw Frame_03_7669, Frame_03_7673, Frame_03_767D, Frame_03_7687
	dw Frame_03_7693

Frame_03_7669:	;$7669
	db $00, $00, $00, $00	;hitbox
	db $F8, $F8, $21	;dx, dy, 2x1
	db $00, $01
	db $80

Frame_03_7673:	;$7673
	db $00, $00, $00, $00	;hitbox
	db $F8, $F8, $21	;dx, dy, 2x1
	db $02, $03
	db $80

Frame_03_767D:	;$767D
	db $00, $00, $00, $00	;hitbox
	db $F8, $F8, $21	;dx, dy, 2x1
	db $04, $05
	db $80

Frame_03_7687:	;$7687
	db $F9, $06, $F9, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $06, $07, $08, $09
	db $80

Frame_03_7693:	;$7693
	db $F7, $08, $F8, $0A	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $06, $07, $0A, $0B
	db $80
