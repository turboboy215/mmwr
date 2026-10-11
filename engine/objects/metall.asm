;Mega Man: Dr. Wily's Revenge disassembly - object type 17, Metall
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Metall (type 17)", ROMX[$769F], BANK[$3]

;Metall (Will; the ending lists METALL).	;[ok]
;Type 17, placed in Elec Man (4), Wily 1 (4) and Wily 3 (5). Faces Mega Man;
;shots bounce off while it is shut (hit points $FE), one hit kills it open.
;Param bit 0 clear (Elec Man): fixed; opens when Mega Man is within 40 px and
;fires three shots, twice, then shuts for 256 frames. Bit 0 set (Wily 1/3):
;falls with block collision; opens when he is near, fires three shots, walks
;toward him 1.3 px a frame for 40 frames, then stops and shuts. The shots fan out
;down, level and up (MetallFireSpread). Removed below the screen.	;[ok]
MetallRoutine:	;$769F
	ld a, b
	or a
	jr z, .l76B2
	dec a
	jr z, .l76DC
	dec a
	jr z, .l76AC
	dec a
	jr z, .l76AF
.l76AC
	ld b, $00
	ret
.l76AF
	jp MetallCheckOnScreen
.l76B2
	call ObjFaceMegaMan_03
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	jr z, .l76CA
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
.l76CA
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld de, Data_03_78A7
	call AnimateObjectFacing_03
	ld b, $01
	ret
.l76DC
	ld a, [wFreezeFlags]
	or a
	jp nz, MetallCheckOnScreen
	ld a, $27
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	jr nz, .l770F
.l76F1
	ld a, b
	or a
	jp z, MetallFixedWait
	dec a
	jp z, MetallFixedOpen
	dec a
	jp z, MetallFixedShut
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld b, a
	jr .l76F1
.l770F
	ld a, b
	dec a
	jr z, .l774D
	dec a
	jp z, .l779F
	ld de, Frame_03_78E0
	call ObjFallWithCollision_03
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $1E
	jr nc, .l772F
	inc [hl]
	jr .l7748
.l772F
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l773B
	cpl
	inc a
.l773B
	cp $28
	jr nc, .l7748
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	inc l
	ld [hl], $00
.l7748
	ld b, $04
	jp MetallSetFrame
.l774D
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $01
	call ObjFaceMegaMan_03
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld b, $06
	ld a, [hl]
	cp $14
	jr c, .l779C
	cp $28
	jp z, MetallFireSpread
	cp $3C
	jr c, .l7793
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $24
	add a, c
	ld l, a
	bit 0, [hl]
	ld de, $FEB4
	jr z, .l7785
	ld de, $014C
.l7785
	ld a, $1C
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $1E
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
.l7793
	ld de, Data_03_78A7
	call AnimateObjectFacing_03
	jp MetallCheckOnScreen
.l779C
	jp MetallSetFrame
.l779F
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $28
	jr c, .l77BD
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ld [hl], $00
	jr .l77C3
.l77BD
	ld de, Frame_03_78E0
	call ObjFallWithCollision_03
.l77C3
	ld de, Data_03_78A7
	call AnimateObjectFacing_03
	jr MetallCheckOnScreen

MetallSetFrame:	;$77CB
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	add a, b
	ld b, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b

MetallCheckOnScreen:	;$77D7
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $F0
	jr nc, .l77E4
	cp $85
	jr nc, .l77E7
.l77E4
	jp ObjSyncAndCheckOnScreen_03
.l77E7
	ld b, $00
	ret

;Fixed Metall (param bit 0 clear), state 0: shut (hit points $FE), face Mega
;Man; when he is within $28 px, state 1.	;[ok]
MetallFixedWait:	;$77EA
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	call ObjFaceMegaMan_03
	ld b, $04
	ld e, $28
	call ObjCheckPlayerWithinX_03
	or a
	jp z, MetallSetFrame
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $29
	add a, c
	ld l, a
	ld [hl], $00
	jp MetallSetFrame

;Fixed Metall, state 1: open (hit points 1), facing Mega Man; at count $1A it
;fires MetallFireSpread, at $29 it shuts (state 2).	;[ok]
MetallFixedOpen:	;$780D
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $01
	call ObjFaceMegaMan_03
	ld b, $08
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $1A
	jp z, MetallFireSpread
	cp $29
	jp c, MetallSetFrame
	xor a
	ld [hl+], a
	ld e, [hl]
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	ld [hl], $02
	jp MetallSetFrame

MetallFireSpread:	;$7835
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0B
	call MetallFireShot
	ld a, $0C
	call MetallFireShot
	ld a, $0D
	call MetallFireShot
	jp MetallSetFrame

MetallFireShot:	;$7851
	push bc
	push de
	push hl
	ld b, a
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7863
	ld a, $08
	add a, b
	and $0F
	ld b, a
.l7863
	ld a, b
	ld l, $03
	ld b, $66
	call JumpFireEnemyShot
	pop hl
	pop de
	pop bc
	ret

;Fixed Metall, state 2: shut (hit points $FE). After the first volley ($29 = 0)
;it reopens after 30 frames with $29 = 2; after the second, it waits 256 frames
;and goes to state 3, which MetallRoutine resets to state 0.	;[ok]
MetallFixedShut:	;$786F
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	call ObjFaceMegaMan_03
	ld b, $04
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl-]
	or a
	jr nz, .l7896
	inc [hl]
	ld a, [hl]
	cp $1E
	jp c, MetallSetFrame
	xor a
	ld [hl+], a
	ld [hl], $02
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	jp MetallSetFrame
.l7896
	inc [hl]
	ld a, [hl]
	or a
	jp nz, MetallSetFrame
	ld [hl+], a
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	jp MetallSetFrame

Data_03_78A7:	;$78A7
	dw FrameTable_03_78AD
	db 15	;frames per step
	db $00, $02, $FF

FrameTable_03_78AD:	;$78AD
	dw Frame_03_78E0, Frame_03_7935, Frame_03_78F4, Frame_03_7949
	dw Frame_03_78C1, Frame_03_7916, Frame_03_78CF, Frame_03_7924
	dw Frame_03_7908, Frame_03_795D

Frame_03_78C1:	;$78C1
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $32	;dx, dy, 3x2
	db $00, $01, $FF, $02, $03, $04
	db $80

Frame_03_78CF:	;$78CF
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $01, $31	;dx, dy, 3x1
	db $07, $08, $09
	db $01, $F8, $05
	db $09, $F8, $06
	db $80

Frame_03_78E0:	;$78E0
	db $F8, $07, $F4, $07	;hitbox
	db $F8, $F1, $32	;dx, dy, 3x2
	db $00, $01, $FF, $02, $03, $04
	db $01, $10, $0A
	db $09, $10, $0B
	db $80

Frame_03_78F4:	;$78F4
	db $F8, $07, $F4, $07	;hitbox
	db $F8, $F1, $32	;dx, dy, 3x2
	db $00, $01, $FF, $02, $03, $04
	db $01, $10, $0C
	db $09, $10, $0D
	db $80

Frame_03_7908:	;$7908
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $32	;dx, dy, 3x2
	db $0E, $0F, $10, $11, $12, $13
	db $80

Frame_03_7916:	;$7916
	db $F8, $07, $F8, $07	;hitbox
	db $F0, $F9, $32	;dx, dy, 3x2
	db $FF, $81, $80, $84, $83, $82
	db $80

Frame_03_7924:	;$7924
	db $F8, $07, $F8, $07	;hitbox
	db $F0, $01, $31	;dx, dy, 3x1
	db $89, $88, $87
	db $07, $F8, $86
	db $0F, $F8, $85
	db $80

Frame_03_7935:	;$7935
	db $F8, $07, $F4, $07	;hitbox
	db $F0, $F1, $32	;dx, dy, 3x2
	db $FF, $81, $80, $84, $83, $82
	db $07, $10, $8B
	db $0F, $10, $8A
	db $80

Frame_03_7949:	;$7949
	db $F8, $07, $F4, $07	;hitbox
	db $F0, $F1, $32	;dx, dy, 3x2
	db $FF, $81, $80, $84, $83, $82
	db $07, $10, $8D
	db $0F, $10, $8C
	db $80

Frame_03_795D:	;$795D
	db $F8, $07, $F8, $07	;hitbox
	db $F0, $F9, $32	;dx, dy, 3x2
	db $90, $8F, $8E, $93, $92, $91
	db $80
