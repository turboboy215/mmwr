;Mega Man: Dr. Wily's Revenge disassembly - object type 9, Fan
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Fan (type 9)", ROMX[$6D19], BANK[$3]

;The fan (type 9), placed three times each in Elec Man, Wily 1 and Wily 3.
;Facing = param bit 0. Every frame it animates and, while Mega Man is level with
;it (Y-10..Y+9) and on its facing side, pushes him 0.5 px a frame that way
;($D830). Time Stopper and Ice Slasher do not stop it. Never removed off screen.
;Shots bounce off (hit points $FE); it does not hurt.	;[ok]
FanRoutine:	;$6D19
	ld a, b
	or a
	jr z, .l6D2A
	dec a
	jr z, .l6D40
	dec a
	jr z, .l6D26
	dec a
	jr z, .l6D40
.l6D26
	ld b, $00
	ret
.l6D29
	ret
.l6D2A
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	ld b, a
	ld a, $24
	add a, c
	ld l, a
	ld [hl], b
	ld de, FanAnim
	call AnimateObjectFacing_03
	ld b, $01
	ret
.l6D40
	ld a, [wFreezeFlags]
	and $F7
	jp nz, .l6D29
	ld de, FanAnim
	call AnimateObjectFacing_03
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6D6E
	call FanCheckPlayerInRow
	or a
	jr z, .l6D8D
	ld a, $0D
	add a, c
	ld l, a
	ld b, [hl]
	ld a, [wPlayerX]
	add a, $08
	cp b
	jr c, .l6D8D
	ld bc, $0080
	jr .l6D84
.l6D6E
	call FanCheckPlayerInRow
	or a
	jr z, .l6D8D
	ld a, $0D
	add a, c
	ld l, a
	ld b, [hl]
	ld a, [wPlayerX]
	sub $08
	cp b
	jr nc, .l6D8D
	ld bc, $FF80
.l6D84
	ld hl, $D830
	ld a, c
	add a, [hl]
	ld [hl+], a
	ld a, b
	adc a, [hl]
	ld [hl], a
.l6D8D
	ld b, $01
	ret

FanCheckPlayerInRow:	;$6D90
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, $0A
	ld d, a
	sub $14
	ld e, a
	ld a, [wPlayerY]
	cp d
	jr nc, .l6DA7
	cp e
	jr c, .l6DA7
	ld a, $01
	ret
.l6DA7
	xor a
	ret

FanAnim:	;$6DA9
	dw FrameTable_03_6DAF
	db 5	;frames per step
	db $00, $02, $FF

FrameTable_03_6DAF:	;$6DAF
	dw Frame_03_6DB7, Frame_03_6DCF, Frame_03_6DC3, Frame_03_6DDB

Frame_03_6DB7:	;$6DB7
	db $FF, $10, $00, $10	;hitbox
	db $00, $00, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_03_6DC3:	;$6DC3
	db $FF, $10, $00, $10	;hitbox
	db $00, $00, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_03_6DCF:	;$6DCF
	db $FF, $10, $00, $10	;hitbox
	db $00, $00, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_03_6DDB:	;$6DDB
	db $FF, $10, $00, $10	;hitbox
	db $00, $00, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80
