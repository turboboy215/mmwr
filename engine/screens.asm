;Mega Man: Dr. Wily's Revenge disassembly - text and title screen loaders
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Screen Loader 01BD", ROM0[$01BD]

;$01BD: another loader for the skull-ship picture (bank $06 SkullShip tiles to
;$9000 and its map to $9800), through the VRAM-safe CopyVRAM. Reachable only
;through the stub at $01B3, which nothing calls. Its map copy,
;CopyTilemapRowsUnskipped, writes 18 runs of 20 bytes back to back without
;skipping the 12 off-screen columns, so it would draw the picture sheared;
;LoadSkullShipScreen ($227A) is the version the game uses. Unused.	;[ok]
LoadSkullShipScreenAlt:	;$01BD
	ld a,6
	bankswitch
	ld de,VRAM_TILES2
	ld hl,GfxRef_SkullShip
	call GetGfxBlock
	call CopyVRAM
	ld de,TILEMAP0
	ld hl,GfxRef_SkullShipTilemap
	call TripleDeref
	call CopyTilemapRowsUnskipped
	ld a,1
	bankswitch
	ret

;Copy 18 runs of 20 bytes from HL to DE with CopyVRAM, back to back - a
;20x18 map copy that forgets the 12-column skip, so each row after the first
;lands 12 tiles too far left. Only LoadSkullShipScreenAlt calls it.	;[ok]
CopyTilemapRowsUnskipped:	;$01E6
	ld c,$12
.loop
	push bc
	ld bc,$0014
	call CopyVRAM
	pop bc
	dec c
	jr nz,.loop
	ret

SECTION "Text Screens", ROM0[$1A13]

;$1A13-$1A51: three text screens that are drawn with the LCD still on. Each
;loads the shared text-screen tiles, blanks the BG map and draws one of the
;bank $06 text groups. Each returns with bank $01 paged in.	;[ok]

;The game-over / continue menu ("GAME OVER", "A BUTTON / STAGE SELECT", ...).
;Called from $0F3B.	;[ok]
LoadGameOverScreen:	;$1A13
	call LoadTextScreenBase
	ld hl, GfxRef_GameOverText
	call TripleDeref
	call DrawTextList
	ld a, $01
	bankswitch
	ret

;The password screen ("PASS WORD", "ERROR !!"). CallBank1Routine index 5.	;[ok]
LoadPasswordScreen:	;$1A28
	call LoadTextScreenBase
	ld hl, GfxRef_PasswordText
	call TripleDeref
	call DrawTextList
	ld a, $01
	bankswitch
	ret

;The closing "THANK YOU FOR PLAYING / PRESENTED BY CAPCOM" text.
;CallBank1Routine index 6.	;[ok]
LoadEndingScreen:	;$1A3D
	call LoadTextScreenBase
	ld hl, GfxRef_EndingText
	call TripleDeref
	call DrawTextList
	ld a, $01
	bankswitch
	ret

;Page in bank $06, copy the two text-screen tile blocks (bank $06 records 0
;and 1: $06E0 bytes to $9000, $0400 bytes to $8800) and fill BG map 0 with
;tile $6C, the space character in the screen charmap. Uses the VRAM-safe
;routines, so it works with the LCD on. Leaves bank $06 paged in.	;[ok]
LoadTextScreenBase:	;$1A52
	ld a, $06
	bankswitch
	ld de, VRAM_TILES2
	ld hl, GfxRef_TitleLogo
	call GetGfxBlock
	call CopyVRAM
	ld de, VRAM_TILES1
	ld hl, GfxRef_MenuFont
	call GetGfxBlock
	call CopyVRAM
	ld hl, TILEMAP0
	ld bc, $0400
	ld a, $6C	;the screen charmap's space
	jp MemsetVRAM

;The title screen's graphics: the same two tile blocks and blank map as
;LoadTextScreenBase, but with the plain (LCD-off) routines, then the title
;logo tilemap (bank $06 record 2) and the title text group. Called by
;TitleScreen.	;[ok]
;PlayStage also calls it at $0958, on the way into every stage. The title map it
;draws is presumably overwritten by the stage, so that call is probably there
;for the two tile blocks - not yet traced.	;[?]
LoadTitleScreen::	;$1A7D
	ld a, $06
	bankswitch
	ld de, VRAM_TILES2
	ld hl, GfxRef_TitleLogo
	call GetGfxBlock
	call FuncFill
	ld de, VRAM_TILES1
	ld hl, GfxRef_MenuFont
	call GetGfxBlock
	call FuncFill
	ld hl, TILEMAP0
	ld bc, $0400
	ld a, $6C
	call FuncMemset
	ld de, TILEMAP0
	ld hl, GfxRef_TitleLogoTilemap
	call TripleDeref
	call CopyTilemapRect
	ld hl, GfxRef_TitleScreenText
	call TripleDeref
	call DrawTextList
	ld a, $01
	bankswitch
	ret

;Draw a screen-text group from HL: records of a BG map address followed by a
;$00-terminated string, ended by a null address - the format the `screentext`
;macro in bank $06 emits.	;[ok]
DrawTextList:	;$1AC6
	ld e, l
	ld d, h
.record
	ld a, [de]
	inc de
	or a
	ld l, a
	jr nz, .haveAddress
	ld a, [de]
	or a
	ret z
.haveAddress
	ld a, [de]
	inc de
	ld h, a
	call DrawTextString
	jr .record

;Write the $00-terminated string at DE to the BG map at HL, one character per
;HBlank when the LCD is on.	;[ok]
DrawTextString:	;$1AD9
	ld a, [de]
	inc de
	or a
	ret z
	call WriteVRAMByte
	inc hl
	jr DrawTextString

;Copy a rectangular tilemap into the BG map at DE: HL points at a width byte and a
;height byte, then width*height tile numbers row by row. Each row goes through
;CopyVRAM, and DE advances by one 32-tile map row. Used for the title logo.	;[ok]
CopyTilemapRect:	;$1AE3
	ld a,[hli]
	ld c,a
	ld a,[hli]
	ld b,a
.loop
	push bc
	ld b,0
	push de
	call CopyVRAM
	pop de
	push hl
	ld hl,$0020
	add hl,de
	ld e,l
	ld d,h
	pop hl
	pop bc
	dec b
	jr nz,.loop
	ret

;Load the stage-select screen with the LCD off: bank $06 record 1 ($0400 bytes)
;to $9200 and record 7 to $9000, clear both BG maps to tile 0, then fill the
;top 9 rows of each with a 20-wide tilemap (records 8 and 9). Bank $01's
;stage-select setup calls it at $1:617E, just before LoadStageSelectSprites and
;LoadStageSelectBosses; that setup then enables the window on map 1 ($9C00), which is
;presumably where the second tilemap is shown. Also reachable through the stub
;at $019B and as CallBank1Routine index 3, from callers not yet traced - Will
;notes the password screen shares the cursor, so it may be one of them.	;[ok]
LoadStageSelectScreen:	;$1AFC
	ld a, $06
	bankswitch
	ld de, $9200
	ld hl, GfxRef_MenuFont
	call GetGfxBlock
	call FuncFill
	ld de, VRAM_TILES2
	ld hl, GfxRef_StageSelectBG
	call GetGfxBlock
	call FuncFill
	ld hl, TILEMAP0
	ld bc, $0400
	xor a
	call FuncMemset
	ld hl, TILEMAP1
	ld bc, $0400
	xor a
	call FuncMemset
	ld de, TILEMAP0
	ld hl, GfxRef_StageSelectTopTilemap
	call TripleDeref
	call CopyTilemap20x9
	ld de, TILEMAP1
	ld hl, GfxRef_StageSelectBottomTilemap
	call TripleDeref
	call CopyTilemap20x9
	ld a, $01
	bankswitch
	ret

;Copy a 20x9-tile block from HL into the BG map at DE (screen width, 9 rows,
;skipping the 12 off-screen columns of each 32-wide map row). Plain writes, so
;the LCD must be off.	;[ok]
CopyTilemap20x9:	;$1B51
	ld c, 9
.row
	ld b, SCREEN_WIDTH
.col
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	ld a, b
	or a
	jr nz, .col
	ld a, TILEMAP_WIDTH - SCREEN_WIDTH
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	dec c
	ld a, c
	or a
	jr nz, .row
	ret
