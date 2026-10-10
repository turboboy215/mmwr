;Mega Man: Dr. Wily's Revenge disassembly - object type 56, TeleportSystemSign
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "TeleportSystemSign (type 56)", ROMX[$625C], BANK[$D]

;Type 56, placed once in each of Wily 2's teleporter hubs: the "DR.WILY TELEPORT SYSTEM"
;sign. Spawned at screen (X $4B, Y $1D); blinks (frame 1, the sign, and frame
;0, empty, 24 frames each; stops while anything is frozen). Every frame OBP1 =
;$04 while the screen is black (BGP $FF), else $84. Killed: removed.	;[ok]
TeleportSystemSignRoutine:	;$625C
	ld a, b
	or a
	jr z, .l626C
	dec a
	jr z, .l6278
	dec a
	jr z, .l6269
	dec a
	jr z, .l6278
.l6269
	ld b, $00
	ret
.l626C
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $4B
	inc l
	inc l
	ld [hl], $1D
	jr .l627F
.l6278
	ld a, [wFreezeFlags]
	or a
	jp nz, .l6285
.l627F
	ld de, Data_0D_62A5
	call AnimateObjectFacing_0D
.l6285
	ld a, [wShadowBGP]
	cp $FF
	ld a, $04
	jr z, .l6290
	ld a, $84
.l6290
	ldh [rOBP1], a
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

Data_0D_62A5:	;$62A5
	dw FrameTable_0D_62AB
	db 24	;frames per step
	db $01, $00, $FF

FrameTable_0D_62AB:	;$62AB
	dw Frame_0D_62AF, Frame_0D_62C9

Frame_0D_62AF:	;$62AF
	db $00, $00, $00, $00	;hitbox
	db $F0, $FC, $63	;dx, dy, 6x3
	db $00, $01, $02, $03, $FF, $FF, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $FF
	db $80

Frame_0D_62C9:	;$62C9
	db $00, $00, $00, $00	;hitbox
	db $EC, $0C, $11	;dx, dy, 1x1
	db $FF
	db $80
