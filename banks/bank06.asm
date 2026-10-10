;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $06
;Section layout ported from the iimarckus/megaman skeleton; all labels are this
;project's own. Confidence tags: [ok] verified here, [dc] corroborated by Data
;Crystal, [?] unverified guess. See docs/CONVENTIONS.md.

SECTION "bank6",ROMX,BANK[$6]

GfxPtr_TitleLogo:
	dw TitleLogoGfx
GfxPtr_MenuFont:
	dw MenuFontGfx
GfxPtr_TitleLogoTilemap:
	dw TitleLogoTilemapPtr
GfxPtr_TitleScreenText:
	dw TitleScreenTextPtr
GfxPtr_GameOverText:
	dw GameOverTextPtr
GfxPtr_PasswordText:
	dw PasswordTextPtr
GfxPtr_EndingText:
	dw EndingTextPtr
GfxPtr_StageSelectBG:
	dw StageSelectBGGfx
GfxPtr_StageSelectTopTilemap:
	dw StageSelectTopTilemapPtr
GfxPtr_StageSelectBottomTilemap:
	dw StageSelectBottomTilemapPtr
GfxPtr_WeaponGet:
	dw WeaponGetGfx
GfxPtr_WeaponGetExtra:
	dw WeaponGetExtraGfx
GfxPtr_WeaponGetTilemap:
	dw WeaponGetTilemapGfx
GfxPtr_WilyCastle:
	dw WilyCastleGfx
GfxPtr_WilyCastleExtra:
	dw WilyCastleExtraGfx
GfxPtr_WilyCastleTilemap:
	dw WilyCastleTilemapPtr
GfxPtr_SkullShip:
	dw SkullShipGfx
GfxPtr_SkullShipTilemap:
	dw SkullShipTilemapPtr
GfxPtr_WilyMachine:
	dw WilyMachineGfx
GfxPtr_WilyMachinePhase1Tilemap:
	dw WilyMachinePhase1TilemapPtr
GfxPtr_WilyMachinePhase2Tilemap:
	dw WilyMachinePhase2TilemapPtr

;Graphics records: a byte count, then the tiles (read by GetGfxBlock). Tilemap
;records: a pointer to the map (read by TripleDeref). Everything in this bank
;is plain - no compression - and every byte from $4149 on is accounted for.	;[ok]

;$402A: the title-screen tiles (logo), loaded to $9000 by LoadTitleScreen and by
;LoadTextScreenBase; and the menu font, loaded to $8800 by both, to $9200 by
;LoadStageSelectScreen and to $8A00 by the weapon-get screen.	;[ok]
TitleLogoGfx:
	dw MenuFontTiles - TitleLogoTiles, TitleLogoTiles
MenuFontGfx:
	dw StageSelectBGGfx - MenuFontTiles, MenuFontTiles

;$4032: the title logo tilemap, drawn by CopyTilemapRect: a width (20) and
;height (10) byte, then the tiles. iimarckus's label sat three bytes late.	;[ok]
TitleLogoTilemapPtr:
	dw TitleLogoTilemap

;$18034: pointers to the four screen-text groups below, reached through slots 3-6
;of the bank's pointer table.	;[ok]
TitleScreenTextPtr::	dw TitleScreenText
GameOverTextPtr::	dw GameOverText
PasswordTextPtr::	dw PasswordText
EndingTextPtr::		dw EndingText

;Screen text. Each record is a BG tilemap destination followed by a $00-terminated
;string; a group ends with a null destination. Emitted through the `screen`
;charmap - see constants/charmap.inc. Step 1.5 believed this was the only text
;in the game, from a sweep in two encodings; step 2.4 found three more - the
;weapon-get strings at bank $00 $21C7, "AND CARRY" in bank $01 and the ending's
;enemy roll call in bank $0E (docs/ROMMAP.md). Apart from those and the bank $00
;stage-name table and the cartridge header title.	;[ok]
MACRO screentext
	dw \1
	db \2, 0
ENDM
MACRO endscreentext
	dw 0
ENDM

SETCHARMAP screen

;password entry
PasswordText::	;$403C
	screentext TILEMAP0 + $105, "PASS WORD"
	screentext TILEMAP0 + $145, "ERROR !!"
	endscreentext

;ending
EndingText::	;$4055
	screentext TILEMAP0 + $045, "THANK YOU"
	screentext TILEMAP0 + $084, "FOR PLAYING"
	screentext TILEMAP0 + $0E4, "PRESENTED BY"
	screentext TILEMAP0 + $126, "CAPCOM"
	endscreentext

;game over / continue menu
GameOverText::	;$4089
	screentext TILEMAP0 + $025, "GAME OVER"
	screentext TILEMAP0 + $0A5, "A BUTTON"
	screentext TILEMAP0 + $0C3, "STAGE SELECT"
	screentext TILEMAP0 + $125, "B BUTTON"
	screentext TILEMAP0 + $145, "CONTINUE"
	screentext TILEMAP0 + $1A3, "START BUTTON"
	screentext TILEMAP0 + $1C5, "GAME END"
	endscreentext

;title screen, including the US-only Capcom U.S.A. credit
TitleScreenText::	;$40E1
	screentext TILEMAP0 + $144, "  GAME START"
	screentext TILEMAP0 + $166, "PASS WORD"
	screentext TILEMAP0 + $1A0, "©CAPCOM CO.,LTD.1991"
	screentext TILEMAP0 + $1C0, "©CAPCOM U.S.A.,"
	screentext TILEMAP0 + $1EC, "INC.1991"
	screentext TILEMAP0 + $200, "LICENSED BY NINTENDO"
	endscreentext

SETCHARMAP main

;$4149: title logo map, 20x10, with the header CopyTilemapRect reads.
TitleLogoTilemap:	;$4149
INCBIN "gfx/tilemaps/title_logo.tilemap"
;$4213: twenty more $6C (blank) bytes - an 11th row the 10-row header never
;draws.	;[ok]
TitleLogoTilemapUnusedRow:
	ds 20, $6C

;$4227: gfx/screens/title_logo.png (110 tiles) and menu_font.png (64 tiles).
;32 of the title tiles are never placed by TitleLogoTilemap (75-95, 98-107 and
;109). Among them is the word WORLD drawn in the logo's style - Will points out
;the game is Rockman World in Japan, so the logo was probably meant to read
;"Mega Man World" at one point - plus a copyright sign, a period and a small
;arrow. The European ROM has the same unused tiles; Rockman World's own WORLD is
;drawn differently, so this one was made for the English logo. See
;docs/UNUSED.md.	;[ok]
TitleLogoTiles:
	INCBIN "gfx/screens/title_logo.2bpp"
MenuFontTiles:
	INCBIN "gfx/screens/menu_font.2bpp"

;$4D07: stage-select records, read by LoadStageSelectScreen.	;[ok]
StageSelectBGGfx:
	dw StageSelectBGTilesEnd - StageSelectBGTiles, StageSelectBGTiles
StageSelectTopTilemapPtr:
	dw StageSelectTopTilemap
StageSelectBottomTilemapPtr:
	dw StageSelectBottomTilemap
;Weapon-get screen records, read by LoadWeaponGetScreen.	;[ok]
WeaponGetGfx:
	dw WeaponGetTilesEnd - WeaponGetTiles, WeaponGetTiles
WeaponGetExtraGfx:
	dw WeaponGetExtraTilesEnd - WeaponGetExtraTiles, WeaponGetExtraTiles
;The weapon-get map is copied as plain bytes (FuncFill), so it is a graphics-style
;record: 18 full 32-tile rows.
WeaponGetTilemapGfx:
	dw WeaponGetTilemapEnd - WeaponGetTilemap, WeaponGetTilemap

;$4D1B: stage-select background tiles, 57, loaded to $9000 over the font copy at
;$9200. gfx/screens/stage_select_bg.png.	;[ok]
StageSelectBGTiles:
	INCBIN "gfx/screens/stage_select_bg.2bpp", 0, 57 * 16
StageSelectBGTilesEnd:

;$50AB: the two halves of the stage-select portrait grid, 20x9 each, drawn by
;CopyTilemap20x9 into BG map 0 and BG map 1 (the window).	;[ok]
StageSelectTopTilemap:
INCBIN "gfx/tilemaps/stage_select_top.tilemap"
StageSelectBottomTilemap:
INCBIN "gfx/tilemaps/stage_select_bottom.tilemap"
;$5213: three more 20-byte rows after the bottom half (a row of $01, a row of
;$00, a row of $01) that CopyTilemap20x9 never reaches.	;[ok]
StageSelectBottomTilemapUnusedRows:
	ds 20, $01
	ds 20, $00
	ds 20, $01

;$524F: weapon-get screen, Mega Man in cutaway: 128 tiles to $9000 and 20 to
;$8800. gfx/screens/weapon_get.png, weapon_get_extra.png.	;[ok]
WeaponGetTiles:
	INCBIN "gfx/screens/weapon_get.2bpp"
WeaponGetTilesEnd:
WeaponGetExtraTiles:
	INCBIN "gfx/screens/weapon_get_extra.2bpp"
WeaponGetExtraTilesEnd:
;$5B8F: its 32x18 map.
WeaponGetTilemap:
INCBIN "gfx/tilemaps/weapon_get.tilemap"
WeaponGetTilemapEnd:

;$5DCF: records for the four cutscene pictures that bank $01 shows in sequence
;(LoadWilyCastleScreen, 227A, 22A3, 22CC called from $1:6418, $6441, $646A, $6493).	;[ok]
WilyCastleGfx:
	dw WilyCastleTilesEnd - WilyCastleTiles, WilyCastleTiles
WilyCastleExtraGfx:
	dw WilyCastleExtraTilesEnd - WilyCastleExtraTiles, WilyCastleExtraTiles
WilyCastleTilemapPtr:
	dw WilyCastleTilemap
SkullShipGfx:
	dw SkullShipTilesEnd - SkullShipTiles, SkullShipTiles
SkullShipTilemapPtr:
	dw SkullShipTilemap
WilyMachineGfx:
	dw WilyMachineTilesEnd - WilyMachineTiles, WilyMachineTiles
WilyMachinePhase1TilemapPtr:
	dw WilyMachinePhase1Tilemap
WilyMachinePhase2TilemapPtr:
	dw WilyMachinePhase2Tilemap

;$5DE7: Dr. Wily's skull castle on a rocky shore. Maps are 20x18, drawn by
;CopyTilemap20x18. gfx/screens/wily_castle*.png.	;[ok]
WilyCastleTiles:
	INCBIN "gfx/screens/wily_castle.2bpp"
WilyCastleTilesEnd:
WilyCastleExtraTiles:
	INCBIN "gfx/screens/wily_castle_extra.2bpp"
WilyCastleExtraTilesEnd:
WilyCastleTilemap:
INCBIN "gfx/tilemaps/wily_castle.tilemap"

;$690F: a skull-faced flying machine on black. Named by what it shows; which
;scene it is has not been confirmed. gfx/screens/skull_ship.png.	;[?]
SkullShipTiles:
	INCBIN "gfx/screens/skull_ship.2bpp"
SkullShipTilesEnd:
SkullShipTilemap:
INCBIN "gfx/tilemaps/skull_ship.tilemap"

;$7237: the Wily Machine, the final boss, on the right of the screen - identified
;by Will. Two maps: phase 1 with its armoured dome, and phase 2 with the dome
;gone, where Dr. Wily himself is visible inside. gfx/screens/wily_machine.png.	;[ok]
WilyMachineTiles:
	INCBIN "gfx/screens/wily_machine.2bpp", 0, 107 * 16
WilyMachineTilesEnd:
WilyMachinePhase1Tilemap:
INCBIN "gfx/tilemaps/wily_machine_phase1.tilemap"
WilyMachinePhase2Tilemap:
INCBIN "gfx/tilemaps/wily_machine_phase2.tilemap"

;$7BB7-$7FFF: unused, all $FF.	;[ok]
	ds $8000 - $7BB7, $FF
