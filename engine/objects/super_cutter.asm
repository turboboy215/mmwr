;Mega Man: Dr. Wily's Revenge disassembly - object type 5, SuperCutter
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "SuperCutter (type 5)", ROMX[$57CF], BANK[$3]

;Super Cutter (Will; the ending lists SUPER CUTTER).	;[ok]
;Type 5, placed in Cut Man (5) and Wily 3 (8). Sits at its spawn point until
;Mega Man is within $30 px, slides 32 px toward his side, then circles its spawn
;point at radius $20 (SuperCutterCircleOffsets, a step every 6 frames), always facing
;him. Its hit points are reset every frame: $14 while Ice Slasher is the weapon,
;else $FE (shots bounce off). Never removed off screen by itself. Frozen: holds
;still ($CC00 used as a frozen flag). No attack.	;[ok]
SuperCutterRoutine:	;$57CF
	ld a, b
	or a
	jr z, .l57FC
	dec a
	jr z, SuperCutterFrame
	dec a
	jr z, .l57DC
	dec a
	jr z, .l57DF
.l57DC
	ld b, $00
	ret
.l57DF
	ld a, $FF
	ld [$CC00], a
	ld a, $2A
	add a, c
	ld l, a
	ld a, [$D851]
	add a, [hl]
	ld [hl], a
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp z, SuperCutterWait
	dec a
	jp z, SuperCutterSlideOut
	jr SuperCutterPlaceAndFace
.l57FC
	ld a, $28
	add a, c
	ld l, a
	ld a, $FF
	ld [hl+], a
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
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], $00
	call ObjFaceMegaManOnScreen_03
	ld de, Data_03_5926
	call AnimateObjectFacing_03
	jp SuperCutterPlaceAndFace

SuperCutterAngleTimer:	;$5821
	db $28, $05, $0F

SuperCutterFrame:	;$5824
	ld a, [wFreezeFlags]
	ld [$CC00], a
	ld a, $2A
	add a, c
	ld l, a
	ld a, [$D851]
	add a, [hl]
	ld [hl], a
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, SuperCutterWait
	dec a
	jr z, SuperCutterSlideOut
	ld a, [wFreezeFlags]
	or a
	jp nz, SuperCutterPlaceAndFace
	ld de, Data_03_5926
	call AnimateObjectFacing_03
	ld de, SuperCutterAngleTimer
	call ObjCountTimer_03

;Put it on its circle at the current angle (SuperCutterPlaceOnCircle) and face
;;Mega Man, then SuperCutterSetHPAndKeepAlive. Reached from init, from mode 3
;;and while frozen in the circling state, and after each animation step.	;[ok]
SuperCutterPlaceAndFace:	;$5851
	call SuperCutterPlaceOnCircle
	call ObjFaceMegaManOnScreen_03

SuperCutterSetHPAndKeepAlive:	;$5857
	ld a, [wCurrentWeapon]
	cp $03
	ld e, $14
	jr z, .l5862
	ld e, $FE
.l5862
	ld a, $18
	add a, c
	ld l, a
	ld [hl], e
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp $D1
	jr nc, .l5874
	cp $CF
	jr nc, .l5879
.l5874
	ld a, $01
	ld [$CC44], a
.l5879
	ld b, $01
	ret

SuperCutterWait:	;$587C
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l5887
	cpl
.l5887
	cp $30
	jr c, SuperCutterNextState
	ld de, $0000
	call SuperCutterPlaceAtOffset
	jr SuperCutterSetHPAndKeepAlive

SuperCutterNextState:	;$5893
	ld a, $09
	add a, c
	ld l, a
	inc [hl]
	call ObjFaceMegaManOnScreen_03
	jr SuperCutterSetHPAndKeepAlive

SuperCutterSlideOut:	;$589D
	ld a, [$CC00]
	or a
	jp nz, .l58AA
	ld de, Data_03_5926
	call AnimateObjectFacing_03
.l58AA
	ld a, $2C
	add a, c
	ld l, a
	inc [hl]
	ld e, [hl]
	ld a, [$CC00]
	or a
	jr z, .l58B7
	dec [hl]
.l58B7
	ld b, $04
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l58C7
	ld a, e
	cpl
	inc a
	ld e, a
	ld b, $0C
.l58C7
	ld a, $29
	add a, c
	ld l, a
	ld [hl], b
	ld d, $00
	call SuperCutterPlaceAtOffset
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	cp $20
	jr nc, SuperCutterNextState
	jp SuperCutterSetHPAndKeepAlive

SuperCutterPlaceOnCircle:	;$58DD
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	add a, LOW(SuperCutterCircleOffsets)
	ld e, a
	ld a, $00
	adc a, HIGH(SuperCutterCircleOffsets)
	ld d, a
	ld a, [de]
	inc de
	ld b, a
	ld a, [de]
	ld d, a
	ld e, b

SuperCutterPlaceAtOffset:	;$58F1
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

SuperCutterCircleOffsets:	;$5904
	db $00, $E0
	db $0C, $E2
	db $17, $E9
	db $1E, $F4
	db $20, $00
	db $1E, $0C
	db $17, $17
	db $0C, $1E
	db $00, $20
	db $F4, $1E
	db $E9, $17
	db $E2, $0C
	db $E0, $00
	db $E2, $F4
	db $E9, $E9
	db $F4, $E2
	db $00, $E0

Data_03_5926:	;$5926
	dw FrameTable_03_592E
	db 10	;frames per step
	db $04, $02, $00, $02, $FF

FrameTable_03_592E:	;$592E
	dw Frame_03_593A, Frame_03_595E, Frame_03_5946, Frame_03_596A
	dw Frame_03_5952, Frame_03_5976

Frame_03_593A:	;$593A
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_03_5946:	;$5946
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_03_5952:	;$5952
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $08, $09, $0A, $0B
	db $80

Frame_03_595E:	;$595E
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_03_596A:	;$596A
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80

Frame_03_5976:	;$5976
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $89, $88, $8B, $8A
	db $80
