;Mega Man: Dr. Wily's Revenge disassembly - object type 52, WilyMachineCuttingWheel
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "WilyMachineCuttingWheel (type 52)", ROMX[$51BB], BANK[$D]

;The Wily fight's version of the Cutting Wheel (Will; the ending draws CUTTING
;WHEEL with these tiles).	;[ok]
;Type 52: never placed; thrown by type 49 (WilyMachineCuttingWheelSpawn) - a spiked wheel
;(sound $11 at spawn, as type 1's Cutting Wheel). $CC08 & 7 picks a leftward
;velocity (WilyMachineCuttingWheelVelocities): 0-3 lobs (Y -5 to -6 px a frame), 4-7 low throws.
;Falls under gravity through walls; between Y $68 and $77 the lobs bounce and
;the low throws (bit 2) land on Y $68 and roll. Removed at screen X $90-$EF.
;Frames 0-1 every 2 frames.	;[ok]
;Will: the Wily fight uses another version of the Cutting Wheel; this is it.	;[?]
WilyMachineCuttingWheelRoutine:	;$51BB
	ld a, b
	or a
	jr z, WilyMachineCuttingWheelInit
	dec a
	jr z, WilyMachineCuttingWheelUpdate
	dec a
	jr z, .l51C8
	dec a
	jr z, .l51CB
.l51C8
	ld b, $00
	ret
.l51CB
	jp ObjClearFreeze_0D

WilyMachineCuttingWheelInit:	;$51CE
	ld a, $11
	call JumpQueueSound
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	ld [hl], a
	add a, a
	add a, a
	add a, LOW(WilyMachineCuttingWheelVelocities)
	ld e, a
	ld a, $00
	adc a, HIGH(WilyMachineCuttingWheelVelocities)
	ld d, a
	call ObjSetVelocity_0D
	ld de, Data_0D_5438
	call AnimateObjectFacing_0D
	ld b, $01
	ret

WilyMachineCuttingWheelVelocities:	;$51F1
	db $C0, $FE, $20, $FA
	db $00, $FF, $00, $FB
	db $80, $FE, $80, $FA
	db $30, $FF, $80, $FA
	db $00, $FE, $00, $FE
	db $00, $FE, $00, $FE
	db $00, $FE, $00, $FE
	db $80, $FE, $00, $FD

;Mode 1: move and animate unless frozen, then the stage X; removed at screen
;X $90-$EF.	;[ok]
WilyMachineCuttingWheelUpdate:	;$5211
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5221
	call WilyMachineCuttingWheelMove
	ld de, Data_0D_5438
	call AnimateObject_0D
.l5221
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
	ld a, e
	cp $F0
	jr nc, .l523C
	cp $90
	ld a, $00
	jr nc, .l523E
.l523C
	ld a, $01
.l523E
	ld b, a
	ld [$CC44], a
	ret

WilyMachineCuttingWheelMove:	;$5243
	call ObjFallAndMove_0D
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld e, l
	cp $78
	jr nc, .l5279
	cp $68
	jr c, .l5279
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	bit 2, a
	jr z, .l5269
	ld l, e
	ld [hl], $68
	ld a, $1E
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	jr .l5279
.l5269
	ld a, $1E
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld a, [hl]
	cpl
	ld d, a
	ld a, e
	cpl
	ld e, a
	inc de
	ld [hl], d
	dec l
	ld [hl], e
.l5279
	ret
