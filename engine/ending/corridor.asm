;Mega Man: Dr. Wily's Revenge disassembly - the ending: scene 3, the corridor
;Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Ending Corridor", ROMX[$7041], BANK[$E]

;Scene 3. The corridor intro (UpdateCorridorIntro, with the stars still
;running) until it sets $CC03; then Mega Man walks while the corridor
;scrolls, until he reaches his last look (standing, 12). Then wait 360
;frames, fade BGP to black (60 frames a step; the E values loaded beside
;them are never used), show the closing text (CallBank1Routine 6,
;LoadEndingScreen), set BGP $AB, $57, $03 12 frames apart, and stay there
;for good.	;[ok]
CorridorScene:	;$7041
	call InitCorridorScene
.l7044
	call PasswordWaitFrame_0E
	call JumpBeginSpriteFrame
	call UpdateStars
	call UpdateCorridorIntro
	ld a, [$CC00]
	ld l, a
	ld a, [$CC01]
	ld h, a
	inc hl
	ld a, l
	ld [$CC00], a
	ld a, h
	ld [$CC01], a
	ld a, [$CC03]
	or a
	jr z, .l7044
.l7067
	call PasswordWaitFrame_0E
	call JumpBeginSpriteFrame
	call UpdateCorridorMegaMan
	call QueueLeftScrollColumn_0E
	ld a, [$CC00]
	ld l, a
	ld a, [$CC01]
	ld h, a
	inc hl
	ld a, l
	ld [$CC00], a
	ld a, h
	ld [$CC01], a
	ld a, [$C66B]
	cp $0C
	jr nz, .l7067
	ld b, $F0
	call PasswordWaitFrames_0E
	ld b, $78
	call PasswordWaitFrames_0E
	ld a, $F9
	ld e, $E5
	call SetBGPWait60
	ld a, $FE
	ld e, $FA
	call SetBGPWait60
	ld a, $FF
	ld e, $FF
	call SetBGPWait60
	ld a, $06
	call JumpCallBank1Routine
	xor a
	ld [wShadowSCX], a
	call PasswordWaitFrame_0E
	ld a, $AB
	call SetBGPWait12
	ld a, $57
	call SetBGPWait12
	ld a, $03
	call SetBGPWait12
.l70C5
	call PasswordWaitFrame_0E
	jr .l70C5

;wShadowBGP = A, then wait 12 frames.	;[ok]
SetBGPWait12:	;$70CA
	ld b, $0C
	ld [wShadowBGP], a
	jp PasswordWaitFrames_0E

;wShadowBGP = A, then wait 60 frames.	;[ok]
SetBGPWait60:	;$70D2
	ld b, $3C
	ld [wShadowBGP], a
	jp PasswordWaitFrames_0E

;Set up scene 3: queue CorridorTiles to $9000 (63 tiles, $03F0 bytes - 11
;more than CorridorTiles holds, so the last tile ends in the bank's $FF
;fill), BGP black, wStageBank = $0E for the scroll-column code, and the
;floor rows at BG rows 16-17.	;[ok]
InitCorridorScene:	;$70DA
	xor a
	ld [$CC03], a
	ld [$C680], a
	ld hl, CorridorTiles
	ld de, VRAM_TILES2
	ld bc, $03F0
	ld a, $20
	call QueueTileCopy_0E
	ld a, $FF
	ld [wShadowBGP], a
	ld a, $0E
	ld [wStageBank], a
	call PasswordWaitFrame_0E
	ld hl, CorridorFloorTilemap
	ld de, TILEMAP0 + 16 * 32
	ld bc, $0040
	call JumpCopyVRAM
	ret

;BG rows 16-17: the corridor floor below the scrolling room.	;[ok]
CorridorFloorTilemap:	;$7109
	INCBIN "gfx/tilemaps/ending_corridor_floor.tilemap"

;Mega Man at ($70, $58) in record $C640: step 0, frame offset from
;CorridorStepTab, step counter 1, look 0.	;[ok]
InitCorridorMegaMan:	;$7149
	ld a, $70
	ld [$C64D], a
	ld a, $58
	ld [$C64F], a
	ld a, $00
	ld [$C66A], a
	ld a, [CorridorStepTab]
	ld [$C669], a
	ld a, $01
	ld [$C668], a
	ld a, $00
	ld [$C66B], a
	ret

;The corridor intro, state $C680:
; 0  copy the queued tiles (Mega Man still drawn by UpdateShuttleAndMegaMan)
;    -> 2
; 2  set the stage engine up for the corridor: blockset, layout (70 x 9),
;    row pointers, scroll limits, scroll X $02F0 -> 3
; 3  after 120 frames draw the screen (DrawCorridorScreen) -> 4
; 4  walk for 180 frames, the BG still black -> 5
; 5  walk while OBP1 fades the stars out over 120 frames -> 1
; 1  walk while BGP fades the corridor in over 121 frames; set $CC03	;[ok]
UpdateCorridorIntro:	;$7169
	ld a, [$C680]
	dec a
	jr z, .l7192
	cp $03
	jp z, .l729C
	cp $04
	jp z, .l72B4
	call UpdateShuttleAndMegaMan
	ld a, [$C680]
	dec a
	dec a
	jp z, .l71C0
	dec a
	jp z, .l7283
	call CopyQueuedTiles_0E
	ret c
	ld a, $02
	ld [$C680], a
	ret
.l7192
	call UpdateCorridorMegaMan
	call QueueLeftScrollColumn_0E
	ld hl, $C681
	ld a, [hl]
	cp $79
	jr nc, .l71BA
	inc [hl]
	ld d, $FF
	cp $28
	jr c, .l71B5
	ld d, $FE
	cp $50
	jr c, .l71B5
	ld d, $F9
	cp $78
	jr c, .l71B5
	ld d, $E4
.l71B5
	ld a, d
	ld [wShadowBGP], a
	ret
.l71BA
	ld a, $01
	ld [$CC03], a
	ret
.l71C0
	xor a
	ld [$D84E], a
	ld [$D826], a
	ld [$D827], a
	ld [$D828], a
	ld [$D829], a
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	ld [$DDFB], a
	ld a, $F0
	ld [$D80D], a
	ld a, $02
	ld [$D80E], a
	ld a, [$D80D]
	ld [$D852], a
	ld a, [$D80E]
	ld [$D853], a
	ld a, [CorridorBlockCount]
	ld [wBlockCount], a
	ld a, LOW(CorridorBlocks)
	ld [wBlocksetPtr], a
	ld a, HIGH(CorridorBlocks)
	ld [wBlocksetPtr + 1], a
	ld a, LOW(CorridorLayout)
	ld [wRoomLayoutPtr], a
	ld a, HIGH(CorridorLayout)
	ld [wRoomLayoutPtr + 1], a
	xor a
	ld [wRoomXOffset], a
	ld [wRoomXOffset + 1], a
	ld a, [wRoomLayoutPtr]
	ld l, a
	ld a, [wRoomLayoutPtr + 1]
	ld h, a
	ld a, [hl+]
	ld [wRoomWidth], a
	ld a, [hl+]
	ld [wRoomHeight], a
	ld a, $50
	ld [wScrollMinX], a
	ld a, $00
	ld [wScrollMinX + 1], a
	ld a, [wRoomWidth]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	sub $50
	ld [wScrollMaxX], a
	ld a, h
	sbc a, $00
	ld [wScrollMaxX + 1], a
	ld a, $58
	ld [wPlayerY], a
	call SetPlayerScreenX_0E
	ld a, [wPlayerX]
	ld [$D81C], a
	call GetPlayerScreenX_0E
	ld a, c
	ld [$D85D], a
	ld [$D85E], a
	ld a, [wRoomLayoutPtr]
	ld l, a
	ld a, [wRoomLayoutPtr + 1]
	ld h, a
	ld e, [hl]
	inc hl
	inc hl
	ld d, $00
	ld bc, wRoomRowPtrs
	ld a, [wRoomHeight]
.l726C
	push af
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	inc bc
	add hl, de
	pop af
	dec a
	jr nz, .l726C
	ld a, $03
	ld [$C680], a
	ld a, $78
	ld [$C682], a
	ret
.l7283
	ld hl, $C682
	ld a, [hl]
	or a
	jr z, .l728C
	dec [hl]
	ret
.l728C
	call DrawCorridorScreen
	xor a
	ld [$C681], a
	call InitCorridorMegaMan
	ld a, $04
	ld [$C680], a
	ret
.l729C
	call UpdateCorridorMegaMan
	call QueueLeftScrollColumn_0E
	ld hl, $C681
	inc [hl]
	ld a, [hl]
	cp $B4
	ret c
	xor a
	ld [$C681], a
	ld a, $05
	ld [$C680], a
	ret
.l72B4
	call UpdateCorridorMegaMan
	call QueueLeftScrollColumn_0E
	ld hl, $C681
	ld a, [hl]
	cp $78
	jr nc, .l72DB
	inc [hl]
	ld e, $90
	cp $1E
	jr c, .l72D7
	ld e, $E5
	cp $3C
	jr c, .l72D7
	ld e, $FA
	cp $5A
	jr c, .l72D7
	ld e, $FF
.l72D7
	ld a, e
	ldh [rOBP1], a
	ret
.l72DB
	xor a
	ld [$C681], a
	ld a, $01
	ld [$C680], a
	ret

;Draw 8 rows of 12 blocks of the corridor into the BG map from column 30
;(wrapping), starting at the block column the clamped scroll X - $60 is in.	;[ok]
DrawCorridorScreen:	;$72E5
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	call ClampToScrollLimits_0E
	ld a, e
	sub $60
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	ld a, e
	ld [$D871], a
	ld a, d
	ld [$D872], a
	ld hl, wRoomRowPtrs
	ld de, TILEMAP0 + 30
	ld b, $08
.l7318
	ld a, [hl+]
	push hl
	ld h, [hl]
	ld l, a
	push de
	ld a, [$D871]
	add a, l
	ld l, a
	ld a, [$D872]
	adc a, h
	ld h, a
	ld c, $0C
.l7329
	push bc
	call DrawBlockAlwaysSafe
	pop bc
	ld a, e
	push af
	and $E0
	ld e, a
	pop af
	inc a
	and $1F
	or e
	ld e, a
	dec c
	jr nz, .l7329
	pop de
	ld a, e
	add a, $40
	ld e, a
	jr nc, .l7344
	inc d
.l7344
	pop hl
	inc hl
	dec b
	jr nz, .l7318
	ret

;DrawBlock ($3496) with every VRAM write through the always-safe HBlank
;wait, so it can run with the LCD on: block [HL] to the map at DE, recorded
;in the $DE00 grid. Returns HL + 1.	;[ok]
DrawBlockAlwaysSafe:	;$734A
	push de
	rr d
	rr e
	ld a, e
	rr d
	rr e
	and $0F
	ld d, a
	ld a, e
	and $F0
	or d
	ld e, a
	ld d, $DE
	ld a, [hl+]
	ld [de], a
	pop de
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, [wBlocksetPtr]
	ld c, a
	ld a, [wBlocksetPtr + 1]
	ld b, a
	add hl, bc
	ld a, [hl+]
	call WriteVRAMByteAtDE_0E
	push de
	ld a, e
	add a, $20
	ld e, a
	jr nc, .l737C
	inc d
.l737C
	ld c, e
	ld b, d
	ld a, [hl+]
	call WriteVRAMByteAtDE_0E
	pop de
	inc e
	ld a, [hl+]
	call WriteVRAMByteAtDE_0E
	inc c
	ld a, [hl+]
	ld l, c
	ld h, b
	call WriteVRAMByteAlwaysSafe_0E
	pop hl
	ret

;Scroll the corridor, pick Mega Man's look (GetCorridorLook, kept in
;$C66B), and below 12 walk: he moves right a pixel for each pixel scrolled,
;and every 7 of them steps the walk cycle (CorridorStepTab) and moves back 7
;- so he stays in place while the corridor passes. Draws frame look + step
;from EndingMegaManFrames.	;[ok]
UpdateCorridorMegaMan:	;$7391
	call ScrollCorridor
	call GetCorridorLook
	ld a, e
	ld [$C66B], a
	cp $0C
	jr nc, .l73E0
	ld a, [$D84F]
	ld b, a
	cpl
	inc a
	ld hl, $C64D
	add a, [hl]
	ld [hl], a
	ld hl, $C668
	ld a, b
	add a, [hl]
	ld [hl], a
	jr nz, .l73D8
	ld a, [$C66A]
	inc a
	cp $04
	jr c, .l73BB
	xor a
.l73BB
	ld [$C66A], a
	ld e, a
	ld d, $00
	ld hl, CorridorStepTab
	add hl, de
	add hl, de
	ld a, [hl]
	ld [$C669], a
	inc hl
	ld a, [$C64D]
	sub [hl]
	ld [$C64D], a
	inc hl
	inc hl
	ld a, [hl]
	ld [$C668], a
.l73D8
	ld a, [$C66B]
	ld b, a
	ld a, [$C669]
	add a, b
.l73E0
	ld [$C657], a
	ld hl, EndingMegaManFrames
	call JumpGetTablePointer
	ld a, l
	ld [$CE53], a
	ld a, h
	ld [$CE54], a
	xor a
	ld [$D3EA], a
	ld a, $01
	ld [$CE57], a
	ld a, $96
	ld [$CE55], a
	ld hl, $C640
	ld c, l
	call DrawObject16_0E
	ret

;Walk steps: frame offset, then the pixels to move back (also the next
;step's count).	;[ok]
CorridorStepTab:	;$7407
	db 0, 7	;step 0: frame offset, X pull-back
	db 1, 7
	db 2, 7
	db 3, 7
	db 0, 7	;read only for the next step's count
	db $C9	;never read

;E = the look for the scroll X ($D80D): the first CorridorLookTab entry
;whose threshold the scroll X is at or above, 12 past the last.	;[ok]
GetCorridorLook:	;$7412
	ld l, c
	push hl
	ld a, [$D80D]
	ld c, a
	ld a, [$D80E]
	ld b, a
	ld hl, CorridorLookTab
.l741F
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, l
	sub LOW(CorridorLookTabEnd)
	ld a, h
	sbc a, HIGH(CorridorLookTabEnd)
	jr nc, .l7433
	ld a, c
	sub [hl]
	inc hl
	ld a, b
	sbc a, [hl]
	inc hl
	jr c, .l741F
.l7433
	pop hl
	ld c, l
	ret

;As the corridor scrolls (X from $02F0 down), Mega Man's look changes from
;walk cycle 0 to 4 to 8, then 12 (standing) ends the walk.	;[ok]
CorridorLookTab:	;$7436
	dw 0, $0158	;look, while the scroll X is at least this
	dw 4, $00B8
	dw 8, $0051
	dw 12	;the last: standing
CorridorLookTabEnd:

;Scroll the view left by 7/16 of a pixel a frame (6/16 below scroll X
;$60) with a fraction in $CC05, down to scroll X $50. On a step: $D80D and
;$D80F one less, SCX one less, $D84F = $FF, the old SCX in $D854.	;[ok]
ScrollCorridor:	;$7444
	xor a
	ld [$D84F], a
	ld a, [$D80D]
	ld l, a
	ld a, [$D80E]
	ld h, a
	ld a, $50
	sub l
	ld e, a
	ld a, $00
	sbc a, h
	or e
	jr z, .l7498
	ld a, l
	ld [$D852], a
	ld a, h
	ld [$D853], a
	ld b, $70
	ld a, $60
	sub l
	ld e, a
	ld a, $00
	sbc a, h
	jr c, .l746F
	ld b, $60
.l746F
	ld a, [$CC05]
	add a, b
	ld [$CC05], a
	jr nc, .l7498
	dec hl
	ld a, l
	ld [$D80D], a
	ld a, h
	ld [$D80E], a
	ld a, l
	ld [$D80F], a
	ld a, h
	ld [$D810], a
	ld a, $FF
	ld [$D84F], a
	ld e, a
	ld hl, wShadowSCX
	ld a, [hl]
	ld [$D854], a
	add a, e
	ld [hl], a
.l7498
	ret

;The corridor's blockset, written with the stage `block` macro. No
;collision table: nothing walks on it.	;[ok]
CorridorBlockCount:	;$7499
	db 46	;blocks
CorridorBlocks:	;$749A
	block $1F, $1F, $1F, $1F	;$00
	block $00, $01, $03, $04	;$01
	block $02, $01, $05, $04	;$02
	block $06, $07, $08, $09	;$03
	block $12, $20, $0E, $0E	;$04
	block $20, $20, $0E, $0E	;$05
	block $20, $13, $0E, $0E	;$06
	block $15, $15, $0E, $0E	;$07
	block $0E, $0E, $10, $21	;$08
	block $0E, $0E, $21, $21	;$09
	block $0E, $0E, $21, $11	;$0A
	block $0E, $0E, $14, $14	;$0B
	block $0D, $0E, $0D, $0E	;$0C
	block $0E, $0E, $0E, $0E	;$0D
	block $0E, $0F, $0E, $0F	;$0E
	block $1F, $1A, $1D, $1E	;$0F
	block $38, $39, $3C, $3D	;$10
	block $3A, $3B, $3E, $1F	;$11
	block $2D, $2E, $33, $34	;$12
	block $2F, $30, $35, $36	;$13
	block $31, $32, $37, $1F	;$14
	block $1F, $22, $27, $28	;$15
	block $23, $24, $29, $2A	;$16
	block $25, $26, $2B, $2C	;$17
	block $0A, $0B, $0D, $0E	;$18
	block $0B, $0B, $0E, $0E	;$19
	block $0B, $0C, $0E, $0F	;$1A
	block $0A, $0B, $0A, $0B	;$1B
	block $0B, $0B, $0B, $0B	;$1C
	block $0B, $0C, $0B, $0C	;$1D
	block $16, $1F, $1F, $1D	;$1E
	block $1F, $17, $1F, $1F	;$1F
	block $1B, $1D, $1F, $19	;$20
	block $1A, $16, $1B, $1A	;$21
	block $1C, $1F, $1F, $1F	;$22
	block $1F, $1F, $17, $1F	;$23
	block $19, $1F, $1F, $1F	;$24
	block $1F, $1F, $1F, $1A	;$25
	block $18, $1D, $1F, $18	;$26
	block $1F, $1F, $17, $1B	;$27
	block $1A, $1F, $1F, $19	;$28
	block $17, $1F, $1F, $1F	;$29
	block $1A, $1F, $1F, $18	;$2A
	block $0D, $0E, $0A, $0B	;$2B
	block $0E, $0E, $0B, $0B	;$2C
	block $0E, $0F, $0B, $0C	;$2D

;The corridor: 70 blocks wide, 9 high - windows on space, with the Earth in
;the first. (wRoomHeight is 9, so the scroll columns use all nine rows;
;DrawCorridorScreen draws eight.)	;[ok]
CorridorLayout:	;$7552
	db 70, 9	;width, height: 9 rows, so not the stages' `layout` macro
	REDEF LAYOUT_W = 70	;for lrow
	lrow "0B 0B 0B 0B 0B 0B 0B 08 09 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 08 09 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 08 09 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 08 09 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B"
	lrow "15 16 17 00 27 23 25 18 19 1A 00 00 00 00 29 00 00 23 00 00 26 1F 00 18 19 1A 26 25 00 24 00 00 21 1F 00 00 00 00 25 18 19 1A 29 00 00 00 25 00 26 00 00 00 2A 00 28 18 19 1A 1E 23 1E 23 00 00 1F 1F 26 1E 26 1E"
	lrow "12 13 14 00 25 00 23 1B 1C 1D 00 29 2A 00 25 25 00 00 21 00 23 27 21 1B 1C 1D 23 26 21 00 21 27 00 1F 1E 21 00 1F 1E 1B 1C 1D 1E 21 00 1F 1E 25 00 29 21 00 23 00 21 1B 1C 1D 25 00 1E 00 25 00 1E 00 25 25 26 25"
	lrow "10 11 25 27 00 00 28 0C 0D 0E 00 00 00 26 25 00 00 25 00 00 00 26 1F 0C 0D 0E 26 00 26 23 25 27 23 26 26 00 1F 26 26 0C 0D 0E 26 00 1F 26 26 00 00 1E 00 00 25 27 29 0C 0D 0E 1F 1E 20 23 21 25 1E 1F 21 26 1E 23"
	lrow "00 00 00 1F 21 0F 00 1B 1C 1D 00 1F 22 26 1F 2A 26 23 1F 23 26 27 27 1B 1C 1D 1F 23 23 1F 21 25 26 25 00 00 21 25 00 1B 1C 1D 00 00 21 25 00 27 25 00 27 25 00 27 27 1B 1C 1D 21 21 1F 1E 23 2A 2A 1E 1F 21 26 00"
	lrow "1F 26 00 23 27 20 1F 2B 2C 2D 00 2A 25 00 00 25 00 00 1F 00 25 27 21 2B 2C 2D 1E 23 20 00 00 00 25 00 00 23 24 21 21 2B 2C 2D 00 23 24 21 21 1F 21 21 2A 29 00 27 21 2B 2C 2D 2A 26 1F 00 1E 26 25 00 1F 1F 25 26"
	lrow "07 07 07 07 07 07 07 04 05 06 07 07 07 07 07 07 07 07 07 07 07 07 07 04 05 06 07 07 07 07 07 07 07 07 07 07 07 07 07 04 05 06 07 07 07 07 07 07 07 07 07 07 07 07 07 04 05 06 07 07 07 07 07 07 07 07 07 07 07 07"
	lrow "01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02 01 02"
	lrow "03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03 03"

;BG tiles at $9000 for the corridor. 62 whole tiles and 5 bytes of a 63rd;
;its last 11 bytes are the free space's $FF.	;[ok]
CorridorTiles:	;$77CA
	INCBIN "gfx/ending/corridor.2bpp", 0, $7BAF - $77CA
