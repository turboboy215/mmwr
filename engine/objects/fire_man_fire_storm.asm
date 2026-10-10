;Mega Man: Dr. Wily's Revenge disassembly - object type 37, FireManFireStorm
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FireManFireStorm (type 37)", ROMX[$69A3], BANK[$3]

;Type 37, placed beside Fire Man - and beside Elec Man: Fire Man's Fire Storm,
;parked off screen. When he sets $CCF6 it clears it, appears $12 px from him
;toward Mega Man, holds 20 frames and flies 2 px a frame to the edge, then parks.
;While parked it runs CheckBossDead; once the boss is beaten it sets wStageState
;2 and calls StartVictoryCountdown every frame (B = 2). Elec Man never writes
;$CCF6, so in his room it never fires: it is there to end his fight.	;[ok]
FireManFireStormRoutine:	;$69A3
	ld a, b
	or a
	jr z, .l69B8
	dec a
	jr z, .l69DD
	dec a
	jp z, .l69B2
	dec a
	jp z, .l69B5
.l69B2
	ld b, $00
	ret
.l69B5
	jp ObjClearFreeze_03
.l69B8
	xor a
	ld [wStageSelectAnimPhase], a
	ld e, $00
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $B0
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
	ld de, Data_03_6ACA
	call AnimateObjectFacing_03
	ld b, $01
	ret
.l69DD
	ld a, [wFreezeFlags]
	or a
	jp nz, .l69B5
	call CheckBossDead_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l69FC
	dec a
	jp z, .l6A6D
	dec a
	jp z, .l6A88
	dec a
	jp z, StartVictoryCountdown_03
	ret
.l69FC
	ld b, $01
	ld a, [$CCF5]
	or a
	jr nz, .l6A0B
	ld a, [wStageSelectAnimPhase]
	or a
	ret z
	jr .l6A24
.l6A0B
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, $02
	ld [wStageState], a
	ld e, $C0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], e
	jr .l6A5A
.l6A24
	xor a
	ld [wStageSelectAnimPhase], a
	ld d, a
	ld b, $EE
	ld a, [wPlayerX]
	ld e, a
	ld a, [$CCF2]
	cp e
	jr nc, .l6A39
	ld d, $01
	ld b, $12
.l6A39
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], d
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$CCF2]
	add a, b
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [$CCF3]
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
.l6A5A
	ld b, $01
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
	ret
.l6A6D
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $14
	jr c, .l6A7F
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
.l6A7F
	ld de, Data_03_6ACA
	call AnimateObjectFacing_03
	ld b, $01
	ret
.l6A88
	ld b, $FE
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6A94
	ld b, $02
.l6A94
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld [hl], a
	cp $C0
	jr c, .l6AB1
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $C0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], b
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], b
.l6AB1
	ld de, Data_03_6ACA
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

Data_03_6ACA:	;$6ACA
	dw FrameTable_03_6AD1
	db 4	;frames per step
	db $00, $02, $04, $FF

FrameTable_03_6AD1:	;$6AD1
	dw Frame_03_6ADD, Frame_03_6B07, Frame_03_6AEB, Frame_03_6B15
	dw Frame_03_6AF9, Frame_03_6B23

Frame_03_6ADD:	;$6ADD
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $00, $01, $02, $03, $40, $41
	db $80

Frame_03_6AEB:	;$6AEB
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $04, $05, $06, $07, $44, $45
	db $80

Frame_03_6AF9:	;$6AF9
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $08, $09, $0A, $0B, $48, $49
	db $80

Frame_03_6B07:	;$6B07
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $81, $80, $83, $82, $C1, $C0
	db $80

Frame_03_6B15:	;$6B15
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $85, $84, $87, $86, $C5, $C4
	db $80

Frame_03_6B23:	;$6B23
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $89, $88, $8B, $8A, $C9, $C8
	db $80

Frame_03_6B31:	;$6B31
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $0C, $0D, $0E, $0F
	db $80

Frame_03_6B3D:	;$6B3D
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $10, $11, $12, $13
	db $80
