;Mega Man: Dr. Wily's Revenge disassembly - object type 1, CuttingWheel
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "CuttingWheel (type 1)", ROMX[$55DB], BANK[$3]

;Cutting Wheel (Will; the ending lists CUTTING WHEEL). Another version of it
;is used in the fight against Dr. Wily.	;[ok]
;Type 1, placed in Cut Man (12) and Wily 3 (7). Param & 3 picks a top X speed
;(CuttingWheelMaxSpeeds: 1.3, 1.9 or 3 px a frame); 0 never moves, only faces Mega Man
;and animates. Sound $11 at spawn. When Mega Man is within $30 px it falls under
;gravity with block collision, bouncing: walls reverse it, each landing bounces
;it at 3/4 speed (below $0080 it rolls), and on the ground it accelerates toward
;its facing. Params 1-2 face the way they move; 3 always faces Mega Man and so
;chases him. Removed off screen with sound $13. Frozen: no movement.	;[ok]
CuttingWheelRoutine:	;$55DB
	ld a, b
	or a
	jr z, .l55EB
	dec a
	jr z, CuttingWheelFrame
	dec a
	jr z, .l55E8
	dec a
	jr z, CuttingWheelSyncAndCheckOnScreen
.l55E8
	ld b, $00
	ret
.l55EB
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	jr z, .l5607
	dec a
	add a, a
	add a, LOW(CuttingWheelMaxSpeeds)
	ld e, a
	ld a, $00
	adc a, HIGH(CuttingWheelMaxSpeeds)
	ld d, a
	ld a, $2A
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
.l5607
	ld de, Data_03_5791
	call AnimateObjectFacing_03
	ld a, $11
	call JumpQueueSound
	ld b, $01
	ret

CuttingWheelMaxSpeeds:	;$5615
	db $50, $01, $E0, $01, $00, $03

CuttingWheelFrame:	;$561B
	ld a, [wFreezeFlags]
	or a
	jp nz, CuttingWheelSyncAndCheckOnScreen
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	jr nz, CuttingWheelUpdate

CuttingWheelFaceAndAnimate:	;$562B
	call CuttingWheelSetFacing
	ld de, Data_03_5791
	call AnimateObjectFacing_03

CuttingWheelSyncAndCheckOnScreen:	;$5634
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
	call CuttingWheelCheckOnScreen
	ld a, b
	or a
	jr nz, .l5650
	ld a, $13
	call JumpQueueSound
.l5650
	ret

CuttingWheelCheckOnScreen:	;$5651
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $90
	jr nc, .l566E
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $D6
	jr nc, .l5667
	cp $CA
	jr nc, .l566E
.l5667
	ld a, $01
	ld [$CC44], a
	ld b, a
	ret
.l566E
	ld b, $00
	ret

CuttingWheelUpdate:	;$5671
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l56A8
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l5684
	cpl
.l5684
	cp $30
	jr nc, .l56AB
	ld a, $09
	add a, c
	ld l, a
	inc [hl]
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $24
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $29
	add a, c
	ld l, a
	ld [hl], b
	jr .l56AB
.l56A8
	call CuttingWheelBounceMove
.l56AB
	jp CuttingWheelFaceAndAnimate

CuttingWheelBounceMove:	;$56AE
	call ObjApplyGravity_03
	ld de, Frame_03_579F
	call ObjMoveWithCollision_03
	jr z, .l5715
	bit 0, a
	jr z, .l56CC
	ld a, $1C
	add a, c
	ld l, a
	ld a, [hl+]
	ld d, [hl]
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ld [hl], d
	dec l
	ld [hl], e
.l56CC
	ldh a, [$FFB0]
	bit 1, a
	jr z, .l5715
	ld a, $1F
	add a, c
	ld l, a
	bit 7, [hl]
	jr nz, .l570C
	ld a, [hl-]
	or a
	jr nz, .l56EE
	ld a, [hl]
	cp $80
	jr nc, .l56EE
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $01
	call CuttingWheelAccelerateX
	jr .l570C
.l56EE
	ld a, [hl+]
	ld d, [hl]
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ld b, d
	ld a, e
	sra d
	rr e
	sra d
	rr e
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld [hl], a
	dec l
	ld [hl], e
	call CuttingWheelAccelerateX
	jr .l5715
.l570C
	ld a, $1E
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
.l5715
	ret

CuttingWheelAccelerateX:	;$5716
	ld a, $24
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $1C
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	bit 0, b
	jr z, .l5730
	ld a, $B0
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	jr .l5738
.l5730
	ld a, $50
	add a, e
	ld e, a
	ld a, $FF
	adc a, d
	ld d, a
.l5738
	ldh [$FF92], a
	ld a, e
	ldh [hBank1CallIndex], a
	bit 7, d
	jr z, .l5748
	ld a, d
	cpl
	ld d, a
	ld a, e
	cpl
	ld e, a
	inc de
.l5748
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl+]
	sub e
	ld a, [hl]
	sbc a, d
	jr c, .l575C
	ld a, $1C
	add a, c
	ld l, a
	ldh a, [hBank1CallIndex]
	ld [hl+], a
	ldh a, [$FF92]
	ld [hl], a
.l575C
	ret

CuttingWheelSetFacing:	;$575D
	ld d, $00
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5773
.l5767
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l578B
	jr .l578A
.l5773
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	cp $03
	jr z, .l5767
	ld a, $1C
	add a, c
	ld l, a
	ld a, [hl+]
	or [hl]
	jr z, .l5767
	bit 7, [hl]
	jr nz, .l578B
.l578A
	inc d
.l578B
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ret

Data_03_5791:	;$5791
	dw FrameTable_03_5797
	db 3	;frames per step
	db $00, $02, $FF

FrameTable_03_5797:	;$5797
	dw Frame_03_579F, Frame_03_57AB, Frame_03_57B7, Frame_03_57C3

Frame_03_579F:	;$579F
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_03_57AB:	;$57AB
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_03_57B7:	;$57B7
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_03_57C3:	;$57C3
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80
