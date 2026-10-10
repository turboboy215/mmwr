;Mega Man: Dr. Wily's Revenge disassembly - helpers shared by the Wily Machine types (48-52)
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Wily Machine Helpers", ROMX[$478F], BANK[$D]

;The object's screen X (offset $0D) and Y ($0F) from the two bytes at DE.	;[ok]
ObjSetPosition:	;$478F
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl+], a
	inc l
	ld a, [de]
	ld [hl], a
	ret

;Start filling the boss bar (bank $00 draws $C101 as its length): $3A = B
;(never read), $3C/$3D = DE, the state to go to when it is full; $C101 = 0;
;a 3-entry sprite for the animation that plays meanwhile; state ObjFillBossBar.	;[ok]
ObjStartBossBarFill:	;$479A
	ld a, $3A
	add a, c
	ld l, a
	ld [hl], b
	inc l
	ld [hl], $00
	inc l
	ld [hl], e
	inc l
	ld [hl], d
	xor a
	ld [$C101], a
	call AllocVisorLightSprite
	ld de, ObjFillBossBar
	jp ObjSetState

;State: draw the visor light and every 5 frames add 8 to $C101, with sound
;7, until it reaches $98; then free the sprite, give the object $13 hit points
;and go to the state saved at $3C/$3D. Used by types 48 and 49.	;[ok]
ObjFillBossBar:	;$47B3
	call DrawVisorLight
	ld a, $3B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l47C0
	dec [hl]
	ret
.l47C0
	ld [hl], $04
	ld a, $07
	call JumpQueueSound
	ld a, [$C101]
	add a, $08
	ld [$C101], a
	cp $98
	ret c
	call FreeVisorLightSprite
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $13
	ld a, $3C
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	jp ObjSetState

;The state pointer: the frame code of types 48-50 jumps to the address at
;offsets $3E/$3F (pushing its own continuation as the return address). This
;sets it to DE.	;[ok]
ObjSetState:	;$47E5
	ld a, $3E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ret

;An explosion burst (CallBank1Routine 1, SpawnExplosionBurst, B = $0C) at
;X = E, Y = D.	;[ok]
SpawnExplosionBurstAt:	;$47ED
	ld l, c
	push hl
	ld b, $0C
	ld a, $01
	call JumpCallBank1Routine
	pop hl
	ld c, l
	ret

;Take an object slot (AllocObjectSlot) without putting it in the active list -
;so no routine runs for it - and return its record address in DE ($C600 +
;slot * $40). Type 48 uses one to hold its cannon's position and sprite.	;[ok]
AllocPartRecord:	;$47F9
	ld l, c
	push hl
	call JumpAllocObjectSlot
	ld l, $00
	ld h, b
	srl h
	rr l
	srl h
	rr l
	ld de, $C600
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ld c, l
	ret

;Get a 3-entry sprite handle into offset $30 for the visor light (the light on
;the Wily Machine's visor that animates while the boss bar fills - Will), and
;start it at frame 0 (offset $2D) with a 5-frame step ($2C).	;[ok]
AllocVisorLightSprite:	;$4812
	ld l, c
	push hl
	ld a, $03
	call JumpAllocSprite
	ld b, a
	pop hl
	ld c, l
	ld a, $30
	add a, c
	ld l, a
	ld [hl], b
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], $00
	ret

;Step and draw the visor light (Will: part of the Wily Machine's visor): 9 frames (VisorLightFrames), one
;every 5 frames, drawn at the fixed screen point (X $74, Y $47) with the
;object's tile base + $69 and attributes $10.	;[ok]
DrawVisorLight:	;$482E
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4839
	dec [hl]
	jr .l4847
.l4839
	ld [hl], $04
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	inc a
	cp $09
	jr c, .l4846
	xor a
.l4846
	ld [hl], a
.l4847
	ld l, c
	push hl
	ld a, $10
	ld [$D3EA], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $69
	ld [$CE55], a
	ld a, $74
	ldh [$FFA2], a
	ld a, $47
	ldh [$FFA3], a
	ld a, $30
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $2D
	add a, c
	ld l, a
	ld e, [hl]
	ld d, $00
	ld hl, VisorLightFrames
	add hl, de
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	call JumpDrawMetasprite
	pop hl
	ld c, l
	ret

;Free the visor light's sprite handle (offset $30).	;[ok]
FreeVisorLightSprite:	;$487B
	ld l, c
	push hl
	ld a, $30
	add a, c
	ld l, a
	ld a, [hl]
	call JumpFreeSprite
	pop hl
	ld c, l
	ret

;Nine 3x1 metasprites (no hitbox), DrawMetasprite format.	;[ok]
VisorLightFrames:	;$4888
	dw Frame_0D_489A, Frame_0D_48A1, Frame_0D_48A8, Frame_0D_48AF
	dw Frame_0D_48B6, Frame_0D_48BD, Frame_0D_48C4, Frame_0D_48CB
	dw Frame_0D_48D2

Frame_0D_489A:	;$489A
	db $F4, $FC, $31	;dx, dy, 3x1
	db $00, $FF, $FF
	db $80

Frame_0D_48A1:	;$48A1
	db $F4, $FC, $31	;dx, dy, 3x1
	db $01, $FF, $FF
	db $80

Frame_0D_48A8:	;$48A8
	db $F6, $FC, $31	;dx, dy, 3x1
	db $02, $FF, $FF
	db $80

Frame_0D_48AF:	;$48AF
	db $F4, $FC, $31	;dx, dy, 3x1
	db $03, $04, $FF
	db $80

Frame_0D_48B6:	;$48B6
	db $F8, $FC, $31	;dx, dy, 3x1
	db $05, $06, $FF
	db $80

Frame_0D_48BD:	;$48BD
	db $F4, $FC, $31	;dx, dy, 3x1
	db $FF, $07, $08
	db $80

Frame_0D_48C4:	;$48C4
	db $F2, $FC, $31	;dx, dy, 3x1
	db $FF, $FF, $09
	db $80

Frame_0D_48CB:	;$48CB
	db $F4, $FC, $31	;dx, dy, 3x1
	db $FF, $FF, $0A
	db $80

Frame_0D_48D2:	;$48D2
	db $F4, $FC, $31	;dx, dy, 3x1
	db $FF, $FF, $FF
	db $80
