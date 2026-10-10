;Mega Man: Dr. Wily's Revenge disassembly - object type 22, ElectricBeam
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "ElectricBeam (type 22)", ROMX[$7491], BANK[$3]

;Electric beam (Will): an obstacle rather than an enemy, so not in the
;ending's list.	;[ok]
;Type 22, placed in Elec Man (11), Wily 1 (4) and Wily 3 (7). A stationary 48x16
;bar - 16x48 upright if param bit 0 is set - that is on for 80 frames (animated,
;hurts, sound 3 when it turns on) and off for 80 (blank, harmless). Always immune
;to shots. Never removed off screen. Holds its state while frozen.	;[ok]
ElectricBeamRoutine:	;$7491
	ld a, b
	or a
	jr z, .l74A4
	dec a
	jr z, .l74C5
	dec a
	jr z, .l749E
	dec a
	jr z, .l74A1
.l749E
	ld b, $00
	ret
.l74A1
	jp ObjClearFreeze_03
.l74A4
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
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $03
	call JumpQueueSound
	ld de, Data_03_7512
	call AnimateObjectFacing_03
	ld b, $01
	ret
.l74C5
	ld a, [wFreezeFlags]
	or a
	jp nz, .l74A1
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $50
	jr c, .l74F1
	cp $A0
	jr c, .l74E3
	ld [hl], $00
	ld a, $03
	call JumpQueueSound
	jr .l74FD
.l74E3
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $00
	jr .l74FD
.l74F1
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $04
	ld de, Data_03_7512
	call AnimateObjectFacing_03
.l74FD
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $04
	ld e, $85
	jr nz, .l750A
	ld e, $80
.l750A
	ld a, $11
	add a, c
	ld l, a
	ld [hl], e
	ld b, $01
	ret

Data_03_7512:	;$7512
	dw FrameTable_03_7518
	db 6	;frames per step
	db $00, $02, $FF

FrameTable_03_7518:	;$7518
	dw Frame_03_7522, Frame_03_754A, Frame_03_7536, Frame_03_755E
	dw Frame_03_7572

Frame_03_7522:	;$7522
	db $F0, $1F, $00, $0F	;hitbox
	db $F0, $00, $62	;dx, dy, 6x2
	db $00, $01, $00, $01, $00, $01, $02, $03, $02, $03, $02, $03
	db $80

Frame_03_7536:	;$7536
	db $F0, $1F, $00, $0F	;hitbox
	db $F0, $00, $62	;dx, dy, 6x2
	db $04, $05, $04, $05, $04, $05, $06, $07, $06, $07, $06, $07
	db $80

Frame_03_754A:	;$754A
	db $00, $0F, $F0, $1F	;hitbox
	db $00, $F0, $26	;dx, dy, 2x6
	db $08, $09, $0A, $0B, $08, $09, $0A, $0B, $08, $09, $0A, $0B
	db $80

Frame_03_755E:	;$755E
	db $00, $0F, $F0, $1F	;hitbox
	db $00, $F0, $26	;dx, dy, 2x6
	db $0C, $0D, $0E, $0F, $0C, $0D, $0E, $0F, $0C, $0D, $0E, $0F
	db $80

Frame_03_7572:	;$7572
	db $08, $08, $08, $08	;hitbox
	db $00, $FC, $11	;dx, dy, 1x1
	db $FF
	db $80
