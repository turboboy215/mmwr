;Mega Man: Dr. Wily's Revenge disassembly - object type 11, Changkey
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Changkey (type 11)", ROMX[$4AE6], BANK[$9]

;Changkey (Will; the ending lists CHANGKEY).	;[ok]
;Object type 11: placed seven times in Fire Man's stage, and thrown by type 12.
;Spawn: offset $2A = param bit 0 picks the mode. Mode 0 (placed): goes to Y 0
;and drops 2 px a frame to Y $B0, then starts again from the top, through walls.
;Mode 1 (thrown, with the velocity type 12 gives it): falls under gravity
;(ObjFallAndMove) and is removed at Y $90. Always faces Mega Man; two frames,
;15 frames each. Ice Slasher holds mode 0 still; mode 1 clears the freeze and
;keeps moving. Killed, or off screen sideways: removed.	;[ok]
ChangkeyRoutine:	;$4AE6
	ld a, b
	or a
	jr z, ChangkeyInit
	dec a
	jr z, ChangkeyUpdate
	dec a
	jr z, ChangkeyRemove
	dec a
	jr z, ChangkeyFrozen

;Remove the object (B = 0): when killed, and from ChangkeyCheckOffScreen
;once it reaches Y $90.	;[ok]
ChangkeyRemove:	;$4AF3
	ld b, $00
	ret

ChangkeyFrozen:	;$4AF6
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret z
	call ObjClearFreeze_09
	jr ChangkeyUpdate

;While wFreezeFlags is set: no movement or animation, only
;ChangkeyCheckOffScreen.	;[ok]
ChangkeyHold:	;$4B02
	jp ChangkeyCheckOffScreen

ChangkeyInit:	;$4B05
	ld a, $06
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $2A
	add a, c
	ld l, a
	ld a, e
	and $01
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld de, Data_09_4B82
	call AnimateObjectFacing_09
	ld b, $01
	ret

ChangkeyUpdate:	;$4B21
	ld a, [wFreezeFlags]
	or a
	jp nz, ChangkeyHold
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, ChangkeyUpdateThrown
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4B47
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $00
	jp .l4B5A
.l4B47
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, $02
	ld [hl], a
	cp $B0
	jp c, .l4B5A
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
.l4B5A
	call ObjFaceMegaMan_09
	ld de, Data_09_4B82
	call AnimateObjectFacing_09
	jp ObjCheckOnScreenX_09

;Thrown Changkey (offset $2A = 1), after it has moved: face Mega Man,
;animate, and fall into ChangkeyCheckOffScreen.	;[ok]
ChangkeyAnimateThrown:	;$4B66
	call ObjFaceMegaMan_09
	ld de, Data_09_4B82
	call AnimateObjectFacing_09

ChangkeyCheckOffScreen:	;$4B6F
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $90
	jp nc, ChangkeyRemove
	jp ObjCheckOnScreenX_09

ChangkeyUpdateThrown:	;$4B7C
	call ObjFallAndMove_09
	jp ChangkeyAnimateThrown

Data_09_4B82:	;$4B82
	dw FrameTable_4B88
	db 15	;frames per step
	db $00, $02, $FF

FrameTable_4B88:	;$4B88
	dw Frame_4B90, Frame_4BA8, Frame_4B9C, Frame_4BB4

Frame_4B90:	;$4B90
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_4B9C:	;$4B9C
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_4BA8:	;$4BA8
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_4BB4:	;$4BB4
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80
