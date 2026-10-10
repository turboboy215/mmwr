;Mega Man: Dr. Wily's Revenge disassembly - object type 31, CutManRollingCutter
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "CutManRollingCutter (type 31)", ROMX[$52CD], BANK[$3]

;Type 31, placed once beside Cut Man: his Rolling Cutter, parked off screen
;until he sets $CCF6. Then it appears at him ($CCF2/$CCF3, 8 px toward Mega Man;
;sound $0E), flies straight sideways about 1.5 px a frame to the room edge
;(sound $14), and homes back on Cut Man; within 8 px of him it clears $CCF6
;(the cutter is home) and parks. Spins through frames 0-3 every 6 frames. Every
;frame it runs CheckBossDead; once he is beaten it parks, sets wStageState 2 and
;calls StartVictoryCountdown every frame (B = 2). Stops while anything is
;frozen.	;[ok]
CutManRollingCutterRoutine:	;$52CD
	ld a, b
	or a
	jr z, .l52DF
	dec a
	jr z, .l5320
	dec a
	jp z, .l52DC
	dec a
	jp z, CutManRollingCutterClearFreeze
.l52DC
	ld b, $00
	ret
.l52DF
	xor a
	ld [wStageSelectAnimPhase], a
	ld e, $00
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	ld a, $24
	add a, c
	ld l, a
	ld [hl], e
	ld a, $34
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $3F
	add a, c
	ld l, a
	ld [hl], $00
	ld de, CutManRollingCutterAnim
	call AnimateObjectFacing_03
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
.l5320
	ld a, [wFreezeFlags]
	or a
	jp nz, CutManRollingCutterFrozen
	call CheckBossDead_03
	ld a, [$C101]
	or a
	jr nz, .l533E
	ld a, $3F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l533E
	dec [hl]
	ld a, $14
	call JumpQueueSound
.l533E
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp z, .l5353
	dec a
	jr z, .l53C0
	dec a
	jp z, .l5438
	dec a
	jp z, StartVictoryCountdown_03
	ret
.l5353
	ld a, [$CCF5]
	or a
	jr nz, .l5394
	ld a, [wStageSelectAnimPhase]
	or a
	jr z, .l53AD
	ld a, $0F
	add a, c
	ld l, a
	ld a, [$CCF3]
	ld [hl], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$CCF2]
	ld [hl], a
	ld a, $0E
	call JumpQueueSound
	call ObjLibFunc_000_03
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $0D
	add a, c
	ld l, a
	ld a, d
	or a
	jr z, .l5388
	ld a, $08
	jr .l538A
.l5388
	ld a, $F8
.l538A
	add a, [hl]
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	jr .l53AD
.l5394
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $02
	ld [wStageState], a
	ld e, $00
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
.l53AD
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
.l53C0
	call CutManRollingCutterSpin
	ld a, [$CCF5]
	or a
	jr nz, .l53DE
	call CutManRollingCutterCheckEdge
	ld a, e
	or a
	jr z, .l5400
	ld a, $14
	call JumpQueueSound
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	jp .l5425
.l53DE
	ld a, $02
	ld [wStageState], a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld b, $01
	jp .l5425
.l5400
	ld a, $29
	add a, c
	ld l, a
	ld d, $01
	ld a, [hl]
	xor $01
	ld [hl], a
	jr z, .l540D
	inc d
.l540D
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l541E
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	jr .l5425
.l541E
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
.l5425
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
.l5438
	call CutManRollingCutterSpin
	ld a, [$CCF5]
	or a
	jr z, .l5466
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	inc l
	ld [hl], $00
	ld a, $02
	ld [wStageState], a
	ld b, $01
	jp .l5425
.l5466
	call CutManRollingCutterHomeDirection
	ld a, e
	or a
	jr nz, .l5489
	ld e, a
	ld [wStageSelectAnimPhase], a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], e
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], $00
	inc l
	ld [hl], $00
	jp .l5425
.l5489
	ld a, $29
	add a, c
	ld l, a
	ld d, $01
	ld a, [hl]
	xor $01
	ld [hl], a
	jr z, .l5496
	inc d
.l5496
	ld a, e
	dec a
	jr z, .l54B5
	dec a
	jr z, .l54BB
	dec a
	jr z, .l54C4
	dec a
	jr z, .l54CA
	dec a
	jr z, .l54D3
	dec a
	jr z, .l54D9
	dec a
	jr z, .l54E2
	call CutManRollingCutterMoveLeft
	call CutManRollingCutterMoveUp
	jp .l5425
.l54B5
	call CutManRollingCutterMoveUp
	jp .l5425
.l54BB
	call CutManRollingCutterMoveRight
	call CutManRollingCutterMoveUp
	jp .l5425
.l54C4
	call CutManRollingCutterMoveRight
	jp .l5425
.l54CA
	call CutManRollingCutterMoveRight
	call CutManRollingCutterMoveDown
	jp .l5425
.l54D3
	call CutManRollingCutterMoveDown
	jp .l5425
.l54D9
	call CutManRollingCutterMoveLeft
	call CutManRollingCutterMoveDown
	jp .l5425
.l54E2
	call CutManRollingCutterMoveLeft
	jp .l5425

CutManRollingCutterMoveLeft:	;$54E8
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ret

CutManRollingCutterMoveRight:	;$54F0
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ret

CutManRollingCutterMoveUp:	;$54F8
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ret

CutManRollingCutterMoveDown:	;$5500
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ret

;While wFreezeFlags is set: a lone ret - the cutter holds still (B stays 1).	;[ok]
CutManRollingCutterFrozen:	;$5508
	ret

;Mode 3 (Ice Slasher): end the freeze at once.	;[ok]
CutManRollingCutterClearFreeze:	;$5509
	jp ObjClearFreeze_03

CutManRollingCutterHomeDirection:	;$550C
	ld a, $0D
	add a, c
	ld l, a
	ld d, [hl]
	ld a, [$CCF2]
	add a, $08
	sub d
	jr c, .l5530
	ld a, [$CCF2]
	sub $08
	sub d
	jr nc, .l5543
	call CutManRollingCutterCompareY
	ld a, e
	or a
	ret z
	dec a
	jr z, .l552D
	ld e, $05
	ret
.l552D
	ld e, $01
	ret
.l5530
	call CutManRollingCutterCompareY
	ld a, e
	or a
	jr z, .l553D
	dec a
	jr z, .l5540
	ld e, $06
	ret
.l553D
	ld e, $07
	ret
.l5540
	ld e, $08
	ret
.l5543
	call CutManRollingCutterCompareY
	ld a, e
	or a
	jr z, .l5550
	dec a
	jr z, .l5553
	ld e, $04
	ret
.l5550
	ld e, $03
	ret
.l5553
	ld e, $02
	ret

CutManRollingCutterCompareY:	;$5556
	ld a, $0F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, [$CCF3]
	add a, $08
	sub d
	jr c, .l556E
	ld a, [$CCF3]
	sub $08
	sub d
	jr nc, .l5571
	ld e, $00
	ret
.l556E
	ld e, $01
	ret
.l5571
	ld e, $02
	ret

CutManRollingCutterCheckEdge:	;$5574
	ld e, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub $8C
	jr nc, .l5583
	ld a, [hl]
	sub $10
	ret nc
.l5583
	ld e, $01
	ret

CutManRollingCutterSpin:	;$5586
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	sub $06
	ret c
	xor a
	ld [hl], a
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	inc a
	and $03
	ld [hl], a
	ret

CutManRollingCutterAnim:	;$559B
	dw FrameTable_03_55A3
	db 6	;frames per step
	db $00, $01, $02, $03, $FF

FrameTable_03_55A3:	;$55A3
	dw Frame_03_55AB, Frame_03_55B7, Frame_03_55C3, Frame_03_55CF

Frame_03_55AB:	;$55AB
	db $FA, $06, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $80, $01, $81
	db $80

Frame_03_55B7:	;$55B7
	db $FA, $06, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $02, $03, $42, $43
	db $80

Frame_03_55C3:	;$55C3
	db $FA, $06, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $41, $C1, $40, $C0
	db $80

Frame_03_55CF:	;$55CF
	db $FA, $06, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $83, $82, $C3, $C2
	db $80
