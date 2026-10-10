;Mega Man: Dr. Wily's Revenge disassembly - the ending: scene 2, the roll call
;Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Ending Roll Call", ROMX[$4B06], BANK[$E]

;Scene 2. From black: sound $02, then after 150 frames sound $28; load the
;ending font to $9000, the space sprites to $8800 and the roll-call enemies
;to $8000; then every frame the shuttle (later Mega Man), the stars and the
;roll call, until the script is done ($CC18), and on to the corridor. BGP
;$CF draws the blank BG black.	;[ok]
RollCallScene:	;$4B06
	ld a, $FF
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld [wShadowBGP], a
	ld b, $1E
	call PasswordWaitFrames_0E
	ld a, $02
	call JumpQueueSound
	ld b, $96
	call PasswordWaitFrames_0E
	ld a, $28
	call JumpQueueSound
	ld de, VRAM_TILES2
	ld hl, EndingFontTiles
	ld bc, EndingFontTilesEnd - EndingFontTiles
	call JumpCopyVRAM
	ld de, VRAM_TILES1
	ld hl, EndingSpaceSpriteTiles
	ld bc, EndingSpaceSpriteTilesEnd - EndingSpaceSpriteTiles
	call JumpCopyVRAM
	ld de, VRAM_TILES0
	ld hl, RollCallEnemyTiles
	ld bc, RollCallEnemyTilesEnd - RollCallEnemyTiles
	call JumpCopyVRAM
	call InitRollCallScene
	ld b, $1E
	call PasswordWaitFrames_0E
	ld a, $90
	ldh [rOBP0], a
	ld a, $CF
	ld [wShadowBGP], a
.l4B58
	call PasswordWaitFrame_0E
	call JumpBeginSpriteFrame
	call UpdateShuttleAndMegaMan
	call UpdateStars
	ld a, $84
	ldh [rOBP1], a
	call UpdateRollCall
	ld a, [$CC00]
	ld l, a
	ld a, [$CC01]
	ld h, a
	inc hl
	ld a, l
	ld [$CC00], a
	ld a, h
	ld [$CC01], a
	ld a, [$CC18]
	or a
	jr z, .l4B58
	jp CorridorScene

;Set up scene 2: the sprite system, 11 star records at $C600 (kind, handle,
;Y, X; one OAM entry each) with UpdateStars run 255 times so the sky starts
;full, the shuttle record at $C640 (X $C0, Y $58, 5 OAM entries), the script
;pointer ($CC1A/$CC1B), a 12-entry sprite for the roll call ($CC10), and a
;blank BG map.	;[ok]
InitRollCallScene:	;$4B85
	call InitSpriteSystem_0E
	xor a
	ld [$CC00], a
	ld [$CC01], a
	ld [$CC18], a
	ld hl, $C600
	ld b, $0B
.l4B97
	xor a
	ld [hl+], a
	push hl
	push bc
	ld a, $01
	call JumpAllocSprite
	pop bc
	pop hl
	ld [hl+], a
	inc l
	inc l
	dec b
	jr nz, .l4B97
	xor a
	ld [$C632], a
	call JumpRNG
	and $1F
	add a, $14
	ld [$C633], a
	ld b, $FF
.l4BB8
	push bc
	call UpdateStars
	pop bc
	dec b
	jr nz, .l4BB8
	ld hl, $C640
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	inc l
	inc l
	ld [hl], $58
	ld l, c
	push hl
	ld a, $05
	call JumpAllocSprite
	ld b, a
	pop hl
	ld c, l
	ld a, $10
	add a, c
	ld l, a
	ld [hl], b
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld hl, RollCallScript
	ld a, l
	ld [$CC1A], a
	ld a, h
	ld [$CC1B], a
	xor a
	ld [$CC03], a
	ld a, $0C
	call JumpAllocSprite
	ld [$CC10], a
	ld de, TILEMAP0
	ld b, $12
.l4BFF
	push bc
	push de
	ld hl, BlankTextRow20
	ld bc, $0014
	call JumpCopyVRAM
	pop de
	ld hl, $0020
	add hl, de
	ld e, l
	ld d, h
	pop bc
	dec b
	jr nz, .l4BFF
	ret

;Font tile 0, the space, for blanking BG rows.	;[ok]
BlankTextRow20:	;$4C16
	ds 20, 0	;font tile 0 is the blank

;The roll call, state $CC03:
; 0  wait for the script's next frame number (against $CC00); take its entry
;    ($CC04); queue the entry's tileset (RollCallTilesetIds) to $8000, 32
;    bytes a frame -> 1, or with none -> 2
; 1  copy the queued tiles -> 2
; 2  after 10 frames write the name (RollCallTextPtrs; each line while LY is
;    in $40-$85), start the sprite (RollCallFramePtrs) at X $E0, Y $20 -> 3
; 3  move right a pixel a frame, pausing 120 frames at X $50; at X $B4-$CF
;    -> 4 after 30 frames
; 4  blank the name rows; -> 0, or set $CC18 when the script is done	;[ok]
UpdateRollCall:	;$4C2A
	ld a, [$CC03]
	dec a
	jr z, .l4C88
	dec a
	jp z, .l4C97
	dec a
	jp z, .l4D19
	dec a
	jp z, .l4D72
	ld a, [$CC1A]
	ld l, a
	ld a, [$CC1B]
	ld h, a
	ld a, [$CC00]
	ld e, a
	ld a, [$CC01]
	ld d, a
	ld a, [hl+]
	sub e
	ld e, a
	ld a, [hl+]
	sbc a, d
	or e
	ret nz
	ld a, [hl+]
	ld [$CC04], a
	ld b, a
	ld a, l
	ld [$CC1A], a
	ld a, h
	ld [$CC1B], a
	ld a, $01
	ld [$CC03], a
	ld l, b
	ld h, $00
	ld de, RollCallTilesetIds - 1
	add hl, de
	ld a, [hl]
	or a
	jr z, .l4C8C
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld de, RollCallTilesets - 4
	add hl, de
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, VRAM_TILES0
	ld a, $20
	jp QueueTileCopy_0E
.l4C88
	call CopyQueuedTiles_0E
	ret c
.l4C8C
	ld a, $0A
	ld [$CC05], a
	ld a, $02
	ld [$CC03], a
	ret
.l4C97
	ld hl, $CC05
	ld a, [hl]
	or a
	jr z, .l4CA0
	dec [hl]
	ret
.l4CA0
	ld a, [$CC04]
	ld l, a
	ld h, $00
	add hl, hl
	ld de, RollCallTextPtrs - 2
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
.l4CAE
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld bc, $0000
	push hl
.l4CB6
	ld a, [hl+]
	or a
	jr z, .l4CC1
	cp $FF
	jr z, .l4CC1
	inc c
	jr .l4CB6
.l4CC1
	ld [$CC06], a
	ld a, l
	ld [$CC07], a
	ld a, h
	ld [$CC08], a
	pop hl
.l4CCD
	ldh a, [rLY]
	cp $86
	jr nc, .l4CCD
	ldh a, [rLY]
	cp $40
	jr c, .l4CCD
	call JumpCopyVRAM
	ld a, [$CC06]
	or a
	jr z, .l4CEC
	ld a, [$CC07]
	ld l, a
	ld a, [$CC08]
	ld h, a
	jr .l4CAE
.l4CEC
	ld a, [$CC04]
	ld l, a
	ld h, $00
	add hl, hl
	ld de, RollCallFramePtrs - 2
	add hl, de
	ld a, [hl+]
	ld [$CC15], a
	ld a, [hl+]
	ld [$CC16], a
	ld a, $E0
	ld [$CC0D], a
	ld a, $20
	ld [$CC0F], a
	ld a, $78
	ld [$CC0E], a
	ld a, $00
	ld [$CC05], a
	ld a, $03
	ld [$CC03], a
	ret
.l4D19
	ld hl, $CC05
	ld a, [hl]
	or a
	jr z, .l4D22
	dec [hl]
	ret
.l4D22
	ld hl, $CC0D
	ld a, [hl]
	cp $D0
	jr nc, .l4D2E
	cp $B4
	jr nc, .l4D67
.l4D2E
	cp $50
	jr nz, .l4D3E
	ld hl, $CC0E
	ld a, [hl]
	or a
	jr z, .l4D3E
	dec [hl]
	ld e, $00
	jr .l4D40
.l4D3E
	ld e, $01
.l4D40
	ld hl, $CC0D
	ld a, [hl]
	add a, e
	ld [hl+], a
	ldh [$FFA2], a
	inc l
	ld a, [hl]
	ldh [$FFA3], a
	xor a
	ld [$D3EA], a
	ld [$CE55], a
	ld a, $01
	ld [$CE57], a
	ld a, [$CC15]
	ld l, a
	ld a, [$CC16]
	ld h, a
	ld a, [$CC10]
	call DrawMetasprite16NoFlip_0E
	ret
.l4D67
	ld a, $1E
	ld [$CC05], a
	ld a, $04
	ld [$CC03], a
	ret
.l4D72
	ld hl, $CC05
	ld a, [hl]
	or a
	jr z, .l4D7B
	dec [hl]
	ret
.l4D7B
	ldh a, [rLY]
	cp $86
	jr nc, .l4D7B
	ldh a, [rLY]
	cp $40
	jr c, .l4D7B
	ld de, TILEMAP0 + 6 * 32 + 6
	ld hl, BlankTextRow10
	ld bc, $000A
	call JumpCopyVRAM
	ld de, TILEMAP0 + 7 * 32 + 6
	ld hl, BlankTextRow10
	ld bc, $000A
	call JumpCopyVRAM
	xor a
	ld [$CC03], a
	ld a, [$CC1A]
	ld l, a
	ld a, [$CC1B]
	ld h, a
	ld a, l
	sub LOW(RollCallScriptEnd)
	ld a, h
	sbc a, HIGH(RollCallScriptEnd)
	jr c, .l4DB8
	ld a, $01
	ld [$CC18], a
.l4DB8
	ret

;Ten blank tiles: one name line.	;[ok]
BlankTextRow10:	;$4DB9
	ds 10, 0

;Record $C640, from frame 300: the shuttle (tile base $86) flies in from
;X $C0 half a pixel a frame; at X $70 it stops and OBP0 fades it to black
;over 60 frames. At frame 730 its sprite is swapped for a 9-entry one, and
;from then it is Mega Man (tile base $96), standing at ($70, $58) while
;OBP0 fades him in.	;[ok]
UpdateShuttleAndMegaMan:	;$4DC3
	ld hl, $C640
	ld c, l
	xor a
	ld [$D3EA], a
	ld a, $01
	ld [$CE57], a
	ld a, $86
	ld [$CE55], a
	ld a, [$CC00]
	sub $2C
	ld a, [$CC01]
	sbc a, $01
	ret c
	ld a, [$CC00]
	sub $DA
	ld e, a
	ld a, [$CC01]
	sbc a, $02
	jp nc, .l4E6A
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l4E23
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $71
	jr nc, .l4E10
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $3C
	inc l
	ld [hl], $00
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	jr .l4E1C
.l4E10
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	add a, $80
	ld [hl+], a
	ld a, [hl]
	adc a, $FF
	ld [hl], a
.l4E1C
	ld de, ShuttleAnim
	call AnimateAndDrawObject16_0E
	ret
.l4E23
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4E2E
	dec [hl]
	jr .l4E48
.l4E2E
	inc l
	inc [hl]
	ld a, [hl]
	ld e, $90
	cp $14
	jr c, .l4E45
	ld e, $E5
	cp $28
	jr c, .l4E45
	ld e, $FA
	cp $3C
	jr c, .l4E45
	ld e, $FF
.l4E45
	ld a, e
	ldh [rOBP0], a
.l4E48
	ld de, ShuttleAnim
	call AnimateAndDrawObject16_0E
	ret
.l4E4F
	ld l, c
	push hl
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	push hl
	call JumpFreeSprite
	ld a, $09
	call JumpAllocSprite
	pop hl
	ld [hl], a
	pop hl
	ld c, l
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ret
.l4E6A
	or e
	jr z, .l4E4F
	ld a, $96
	ld [$CE55], a
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $3C
	jr nc, .l4E88
	inc [hl]
	ld e, $FA
	cp $14
	jr c, .l4E8A
	ld e, $E5
	cp $28
	jr c, .l4E8A
.l4E88
	ld e, $90
.l4E8A
	ld a, e
	ldh [rOBP0], a
	jr .l4E8F
.l4E8F
	ldh a, [rOBP0]
	cp $FF
	ret z
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $70
	inc l
	inc l
	ld [hl], $58
	ld a, $01
	ld [$CE57], a
	ld de, EndingMegaManStandAnim
	call AnimateAndDrawObject16_0E
	ret

;Big Mega Man's walk cycles (four frames of 24 each) and his standing
;frame. Only EndingMegaManStandAnim is used: the corridor scene picks
;EndingMegaManFrames entries itself (UpdateCorridorMegaMan).	;[ok]
EndingMegaManWalkAnim0:	;$4EAA
	dw EndingMegaManFrames
	db 24	;frames per step
	db $00, $01, $02, $03, $FF
EndingMegaManWalkAnim4:	;$4EB2
	dw EndingMegaManFrames
	db 24	;frames per step
	db $04, $05, $06, $07, $FF
EndingMegaManWalkAnim8:	;$4EBA
	dw EndingMegaManFrames
	db 24	;frames per step
	db $08, $09, $0A, $0B, $FF
EndingMegaManStandAnim:	;$4EC2
	dw EndingMegaManFrames
	db 24	;frames per step
	db $0C, $0C, $0C, $0C, $FF

;Big Mega Man: three walk cycles of four (0-3, 4-7, 8-11; the corridor's
;"looks") and standing (12). Tile base $96.	;[ok]
EndingMegaManFrames:	;$4ECA
	dw EndingMegaManFrame0, EndingMegaManFrame1, EndingMegaManFrame2, EndingMegaManFrame3
	dw EndingMegaManFrame4, EndingMegaManFrame5, EndingMegaManFrame6, EndingMegaManFrame7
	dw EndingMegaManFrame8, EndingMegaManFrame9, EndingMegaManFrame10, EndingMegaManFrame11
	dw EndingMegaManFrame12

;The shuttle: two frames, four frames each.	;[ok]
ShuttleAnim:	;$4EE4
	dw ShuttleFrames
	db 4	;frames per step
	db $00, $01, $FF

ShuttleFrames:	;$4EEA
	dw ShuttleFrame0, ShuttleFrame1

;Spawn stars now and then, and move and draw every live one (OBP1, tile
;base $80).	;[ok]
UpdateStars:	;$4EEE
	call SpawnStar
	ld a, $10
	ld [$D3EA], a
	ld [$CE57], a
	ld a, $80
	ld [$CE55], a
	ld hl, $C600
.l4F01
	ld a, [hl]
	or a
	call nz, MoveAndDrawStar
	ld de, $0004
	add hl, de
	ld a, l
	cp $2C
	jr c, .l4F01
	ret

;Star record HL, kind A: kind 1 moves right 2 pixels a frame, kind 2 one,
;kind 3 one every other frame (bit 7 of the kind toggles). It is removed at
;X $A8-$EF; otherwise drawn with StarFrame1-3.	;[ok]
MoveAndDrawStar:	;$4F10
	push hl
	ld c, l
	ld b, a
	and $03
	ld d, $02
	dec a
	jr z, .l4F29
	ld d, $01
	dec a
	jr z, .l4F29
	ld a, b
	xor $80
	ld [hl], a
	and $80
	jr z, .l4F29
	ld d, $00
.l4F29
	ld a, $03
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl-], a
	cp $A8
	jr c, .l4F3D
	cp $F0
	jr nc, .l4F3D
	ld l, c
	ld [hl], $00
	jr .l4F59
.l4F3D
	ldh [$FFA2], a
	ld a, [hl-]
	ldh [$FFA3], a
	ld e, [hl]
	ld a, b
	and $03
	ld hl, StarFrame1
	dec a
	jr z, .l4F55
	ld hl, StarFrame2
	dec a
	jr z, .l4F55
	ld hl, StarFrame3
.l4F55
	ld a, e
	call DrawMetasprite16_0E
.l4F59
	pop hl
	ret

;Count $C632 up to the random interval $C633 (20-51 frames); then take a
;free star record, give it a random Y (0-$87), a random kind (1, 2 or 3 for RNG
;below $30, below $78, the rest) and X $F8, just off the left edge.	;[ok]
SpawnStar:	;$4F5B
	ld hl, $C632
	inc [hl]
	ld a, [hl]
	inc hl
	cp [hl]
	ret c
	call JumpRNG
	and $1F
	add a, $14
	ld [hl-], a
	ld [hl], $00
	ld hl, $C600
	ld b, $0B
	ld de, $0004
.l4F75
	ld a, [hl]
	or a
	jr z, .l4F7E
	add hl, de
	dec b
	jr nz, .l4F75
	ret
.l4F7E
	call JumpRNG
	ld b, a
	and $0F
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, b
	swap a
	and $0F
	add a, c
	ld e, a
	call JumpRNG
	ld d, $01
	cp $30
	jr c, .l4FA0
	ld d, $02
	cp $78
	jr c, .l4FA0
	ld d, $03
.l4FA0
	ld [hl], d
	inc l
	inc l
	ld [hl], e
	inc l
	ld [hl], $F8
	ret
