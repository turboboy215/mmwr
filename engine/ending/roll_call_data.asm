;Mega Man: Dr. Wily's Revenge disassembly - the ending: the roll call's data
;Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Ending Roll Call Data", ROMX[$4FA8], BANK[$E]

;The roll call script: (frame number, entry) pairs, entries into the
;tables below (one-based). An enemy every 450 frames from frame 1160.
;DRILLUN (3) and PICOPICO (16) have full entries - name, sprite, tiles -
;but the script skips them, so the ending never shows them.	;[ok]
;Both are unused enemies (Will): Drillun matches its official artwork, a drill
;with a green cap and eyes; nothing is known of Picopico beyond the name, which
;recalls Picopico-kun, a boss of the NES Mega Man 2.	;[?]
RollCallScript:	;$4FA8
	dw $0488	;SUZY
	db 1
	dw $064A	;CHANGKEY
	db 2
	dw $080C	;CUTTING WHEEL
	db 4
	dw $09CE	;SCREW DRIVER
	db 5
	dw $0B90	;SUPER CUTTER
	db 6
	dw $0D52	;METALL
	db 7
	dw $0F14	;GABYOALL
	db 8
	dw $10D6	;SCWORM
	db 9
	dw $1298	;MOLE
	db 10
	dw $145A	;PIPI
	db 11
	dw $161C	;SNIPER JOE
	db 12
	dw $17DE	;BIGEYE
	db 13
	dw $19A0	;KAMINARI GORO
	db 14
	dw $1B62	;CHANGKEY MAKER
	db 15
	dw $1D24	;BUNBY HERI
	db 17
	dw $1EE6	;CUTMAN
	db 18
	dw $20A8	;ELECMAN
	db 19
	dw $226A	;ICEMAN
	db 20
	dw $242C	;FIREMAN
	db 21
	dw $25EE	;BUBBLEMAN
	db 22
	dw $27B0	;HEATMAN
	db 23
	dw $2972	;QUICKMAN
	db 24
	dw $2B34	;FLASHMAN
	db 25
	dw $2CF6	;ENKER
	db 26
RollCallScriptEnd:

;Per entry: its name. UpdateRollCall indexes this table from entry 1 at
;RollCallTextPtrs - 2; the byte pairs before it are the script's tail.	;[ok]
RollCallTextPtrs:	;$4FF0
	dw RollCallTextSuzy
	dw RollCallTextChangkey
	dw RollCallTextDrillun
	dw RollCallTextCuttingWheel
	dw RollCallTextScrewDriver
	dw RollCallTextSuperCutter
	dw RollCallTextMetall
	dw RollCallTextGabyoall
	dw RollCallTextScworm
	dw RollCallTextMole
	dw RollCallTextPipi
	dw RollCallTextSniperJoe
	dw RollCallTextBigeye
	dw RollCallTextKaminariGoro
	dw RollCallTextChangkeyMaker
	dw RollCallTextPicopico
	dw RollCallTextBunbyHeri
	dw RollCallTextCutMan
	dw RollCallTextElecMan
	dw RollCallTextIceMan
	dw RollCallTextFireMan
	dw RollCallTextBubbleMan
	dw RollCallTextHeatMan
	dw RollCallTextQuickMan
	dw RollCallTextFlashMan
	dw RollCallTextEnker

;Per entry: its metasprite, drawn with DrawMetasprite16_0E (from
;RollCallFramePtrs - 2). All nine robot masters share RollCallFrameBoss,
;a 4x2 head drawn from each one's own 16 tiles.	;[ok]
RollCallFramePtrs:	;$5024
	dw RollCallFrameSuzy	;SUZY: type 21's tiles
	dw RollCallFrameChangkey	;CHANGKEY: type 11's tiles (also in 12's)
	dw RollCallFrameDrillun	;DRILLUN: type 13's tiles
	dw RollCallFrameCuttingWheel	;CUTTING WHEEL: the Wily Machine parts' tiles (types 48-51, $7:75C3), not type 1's
	dw RollCallFrameScrewDriver	;SCREW DRIVER: type 2's tiles (2 of 4)
	dw RollCallFrameSuperCutter	;SUPER CUTTER: type 5's tiles
	dw RollCallFrameMetall	;METALL: type 17's tiles (8 of 12)
	dw RollCallFrameGabyoall	;GABYOALL: type 3's tiles
	dw RollCallFrameScworm	;SCWORM: type 24's tiles
	dw RollCallFrameMole	;MOLE: type 18's tiles
	dw RollCallFramePipi	;PIPI: type 19's tiles
	dw RollCallFrameSniperJoe	;SNIPER JOE: tiles found nowhere else
	dw RollCallFrameBigeye	;BIGEYE: type 6's tiles, byte for byte
	dw RollCallFrameKaminariGoro	;KAMINARI GORO: type 15's tiles (7 of 14)
	dw RollCallFrameChangkeyMaker	;CHANGKEY MAKER: type 12's tiles
	dw RollCallFramePicopico	;PICOPICO: tiles found nowhere else
	dw RollCallFrameBunbyHeri	;BUNBY HERI: type 7's tiles (5 of 6)
	dw RollCallFrameBoss	;CUTMAN
	dw RollCallFrameBoss	;ELECMAN
	dw RollCallFrameBoss	;ICEMAN
	dw RollCallFrameBoss	;FIREMAN
	dw RollCallFrameBoss	;BUBBLEMAN
	dw RollCallFrameBoss	;HEATMAN
	dw RollCallFrameBoss	;QUICKMAN
	dw RollCallFrameBoss	;FLASHMAN
	dw RollCallFrameBoss	;ENKER

;Per entry: the RollCallTilesets entry loaded to $8000 before it is shown,
;0 for none (the first 14 use RollCallEnemyTiles, loaded with the scene).	;[ok]
RollCallTilesetIds:	;$5058
	db 0	;SUZY
	db 0	;CHANGKEY
	db 0	;DRILLUN
	db 0	;CUTTING WHEEL
	db 0	;SCREW DRIVER
	db 0	;SUPER CUTTER
	db 0	;METALL
	db 0	;GABYOALL
	db 0	;SCWORM
	db 0	;MOLE
	db 0	;PIPI
	db 0	;SNIPER JOE
	db 0	;BIGEYE
	db 0	;KAMINARI GORO
	db 1	;CHANGKEY MAKER
	db 2	;PICOPICO
	db 3	;BUNBY HERI
	db 4	;CUTMAN
	db 5	;ELECMAN
	db 6	;ICEMAN
	db 7	;FIREMAN
	db 8	;BUBBLEMAN
	db 9	;HEATMAN
	db 10	;QUICKMAN
	db 11	;FLASHMAN
	db 12	;ENKER

;Tilesets 1-12: dw byte count, source. 1-3 are the same 36 tiles.	;[ok]
RollCallTilesets:	;$5072
	dw RollCallEnemyTiles2End - RollCallEnemyTiles2, RollCallEnemyTiles2	;1
	dw RollCallEnemyTiles2End - RollCallEnemyTiles2, RollCallEnemyTiles2	;2
	dw RollCallEnemyTiles2End - RollCallEnemyTiles2, RollCallEnemyTiles2	;3
	dw RollCallCutManTilesEnd - RollCallCutManTiles, RollCallCutManTiles	;4
	dw RollCallElecManTilesEnd - RollCallElecManTiles, RollCallElecManTiles	;5
	dw RollCallIceManTilesEnd - RollCallIceManTiles, RollCallIceManTiles	;6
	dw RollCallFireManTilesEnd - RollCallFireManTiles, RollCallFireManTiles	;7
	dw RollCallBubbleManTilesEnd - RollCallBubbleManTiles, RollCallBubbleManTiles	;8
	dw RollCallHeatManTilesEnd - RollCallHeatManTiles, RollCallHeatManTiles	;9
	dw RollCallQuickManTilesEnd - RollCallQuickManTiles, RollCallQuickManTiles	;10
	dw RollCallFlashManTilesEnd - RollCallFlashManTiles, RollCallFlashManTiles	;11
	dw RollCallEnkerTilesEnd - RollCallEnkerTiles, RollCallEnkerTiles	;12

;The names, in the rollcall charmap: dw BG map address, then the text, ended
;by 0 or by $FF for another (address, text) line.	;[ok]
RollCallTextSuzy:	;$50A2
	SETCHARMAP rollcall
	dw TILEMAP0 + 6 * 32 + 8
	db "SUZY", 0
RollCallTextChangkey:	;$50A9
	dw TILEMAP0 + 6 * 32 + 6
	db "CHANGKEY", 0
RollCallTextDrillun:	;$50B4
	dw TILEMAP0 + 6 * 32 + 6
	db "DRILLUN", 0
RollCallTextCuttingWheel:	;$50BE
	dw TILEMAP0 + 6 * 32 + 6
	db "CUTTING", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 6
	db "WHEEL", 0
RollCallTextScrewDriver:	;$50D0
	dw TILEMAP0 + 6 * 32 + 7
	db "SCREW", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 7
	db "DRIVER", 0
RollCallTextSuperCutter:	;$50E1
	dw TILEMAP0 + 6 * 32 + 7
	db "SUPER", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 7
	db "CUTTER", 0
RollCallTextMetall:	;$50F2
	dw TILEMAP0 + 6 * 32 + 7
	db "METALL", 0
RollCallTextGabyoall:	;$50FB
	dw TILEMAP0 + 6 * 32 + 6
	db "GABYOALL", 0
RollCallTextScworm:	;$5106
	dw TILEMAP0 + 6 * 32 + 7
	db "SCWORM", 0
RollCallTextMole:	;$510F
	dw TILEMAP0 + 6 * 32 + 8
	db "MOLE", 0
RollCallTextPipi:	;$5116
	dw TILEMAP0 + 6 * 32 + 8
	db "PIPI", 0
RollCallTextSniperJoe:	;$511D
	dw TILEMAP0 + 6 * 32 + 7
	db "SNIPER", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 7
	db "JOE", 0
RollCallTextBigeye:	;$512C
	dw TILEMAP0 + 6 * 32 + 7
	db "BIGEYE", 0
RollCallTextKaminariGoro:	;$5135
	dw TILEMAP0 + 6 * 32 + 6
	db "KAMINARI", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 6
	db "GORO", 0
RollCallTextChangkeyMaker:	;$5147
	dw TILEMAP0 + 6 * 32 + 6
	db "CHANGKEY", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 6
	db "MAKER", 0
RollCallTextPicopico:	;$515A
	dw TILEMAP0 + 6 * 32 + 6
	db "PICOPICO", 0
RollCallTextBunbyHeri:	;$5165
	dw TILEMAP0 + 6 * 32 + 7
	db "BUNBY", $FF	;next line
	dw TILEMAP0 + 7 * 32 + 7
	db "HERI", 0
RollCallTextCutMan:	;$5174
	dw TILEMAP0 + 6 * 32 + 6
	db "CUTMAN", 0
RollCallTextElecMan:	;$517D
	dw TILEMAP0 + 6 * 32 + 6
	db "ELECMAN", 0
RollCallTextIceMan:	;$5187
	dw TILEMAP0 + 6 * 32 + 6
	db "ICEMAN", 0
RollCallTextFireMan:	;$5190
	dw TILEMAP0 + 6 * 32 + 6
	db "FIREMAN", 0
RollCallTextBubbleMan:	;$519A
	dw TILEMAP0 + 6 * 32 + 6
	db "BUBBLEMAN", 0
RollCallTextHeatMan:	;$51A6
	dw TILEMAP0 + 6 * 32 + 6
	db "HEATMAN", 0
RollCallTextQuickMan:	;$51B0
	dw TILEMAP0 + 6 * 32 + 6
	db "QUICKMAN", 0
RollCallTextFlashMan:	;$51BB
	dw TILEMAP0 + 6 * 32 + 6
	db "FLASHMAN", 0
RollCallTextEnker:	;$51C6
	dw TILEMAP0 + 6 * 32 + 6
	db "ENKER", 0
	SETCHARMAP main

;The roll call's metasprites, then the shuttle's, big Mega Man's and the
;stars'. Tile bytes are added whole to the tile base (no flip bits).	;[ok]
RollCallFrameSuzy:	;$51CE
	db $F8, $F8, $21	;dx, dy, 2x1
	db $00, $02
	db $80

RollCallFrameChangkey:	;$51D4
	db $F8, $F8, $21	;dx, dy, 2x1
	db $04, $06
	db $80

RollCallFrameDrillun:	;$51DA
	db $F8, $F8, $21	;dx, dy, 2x1
	db $08, $0A
	db $80

RollCallFrameCuttingWheel:	;$51E0
	db $F8, $F8, $21	;dx, dy, 2x1
	db $0C, $0E
	db $80

RollCallFrameScrewDriver:	;$51E6
	db $F8, $F8, $21	;dx, dy, 2x1
	db $10, $12
	db $80

RollCallFrameSuperCutter:	;$51EC
	db $F8, $F8, $21	;dx, dy, 2x1
	db $14, $16
	db $80

RollCallFrameMetall:	;$51F2
	db $EC, $F0, $52	;dx, dy, 5x2
	db $FF, $FF, $FF, $18, $1A, $1C, $1E, $20, $22, $24
	db $80

RollCallFrameGabyoall:	;$5200
	db $F8, $F8, $21	;dx, dy, 2x1
	db $26, $28
	db $80

RollCallFrameScworm:	;$5206
	db $F0, $F8, $41	;dx, dy, 4x1
	db $2A, $2C, $2E, $30
	db $80

RollCallFrameMole:	;$520E
	db $F0, $F0, $42	;dx, dy, 4x2
	db $32, $FF, $FF, $36, $34, $FF, $FF, $38
	db $80

RollCallFramePipi:	;$521A
	db $E4, $F8, $71	;dx, dy, 7x1
	db $3A, $3C, $3E, $FF, $40, $FF, $42
	db $80

RollCallFrameSniperJoe:	;$5225
	db $F4, $F0, $32	;dx, dy, 3x2
	db $44, $46, $48, $4A, $4C, $4E
	db $80

RollCallFrameBigeye:	;$522F
	db $F0, $E8, $43	;dx, dy, 4x3
	db $50, $52, $54, $56, $58, $5A, $5C, $5E, $60, $62, $64, $FF
	db $80

RollCallFrameKaminariGoro:	;$523F
	db $F0, $F0, $42	;dx, dy, 4x2
	db $66, $68, $6A, $6C, $6E, $70, $72, $74
	db $80

RollCallFrameChangkeyMaker:	;$524B
	db $F0, $F0, $42	;dx, dy, 4x2
	db $00, $02, $04, $06, $08, $0A, $0C, $0E
	db $80

RollCallFramePicopico:	;$5257
	db $F0, $F0, $42	;dx, dy, 4x2
	db $10, $12, $14, $16, $FF, $18, $1A, $FF
	db $80

RollCallFrameBunbyHeri:	;$5263
	db $F8, $F0, $22	;dx, dy, 2x2
	db $1C, $1E, $20, $22
	db $80

RollCallFrameBoss:	;$526B
	db $F0, $F0, $42	;dx, dy, 4x2
	db $00, $02, $04, $06, $08, $0A, $0C, $0E
	db $80

ShuttleFrame0:	;$5277
	db $EC, $F8, $51	;dx, dy, 5x1
	db $00, $02, $04, $06, $08
	db $80

ShuttleFrame1:	;$5280
	db $EC, $F8, $51	;dx, dy, 5x1
	db $00, $02, $04, $06, $0A
	db $80

EndingMegaManFrame0:	;$5289
	db $F4, $E9, $33	;dx, dy, 3x3
	db $2A, $2C, $2E, $00, $02, $04, $06, $08, $0A
	db $80

EndingMegaManFrame1:	;$5296
	db $F4, $E8, $33	;dx, dy, 3x3
	db $2A, $2C, $2E, $0C, $0E, $10, $12, $14, $16
	db $80

EndingMegaManFrame2:	;$52A3
	db $F4, $E9, $33	;dx, dy, 3x3
	db $2A, $2C, $2E, $18, $1A, $1C, $1E, $20, $22
	db $80

EndingMegaManFrame3:	;$52B0
	db $F4, $E8, $33	;dx, dy, 3x3
	db $2A, $2C, $2E, $0C, $0E, $10, $24, $26, $28
	db $80

EndingMegaManFrame4:	;$52BD
	db $F4, $E9, $33	;dx, dy, 3x3
	db $30, $32, $34, $00, $02, $04, $06, $08, $0A
	db $80

EndingMegaManFrame5:	;$52CA
	db $F4, $E8, $33	;dx, dy, 3x3
	db $30, $32, $34, $0C, $0E, $10, $12, $14, $16
	db $80

EndingMegaManFrame6:	;$52D7
	db $F4, $E9, $33	;dx, dy, 3x3
	db $30, $32, $34, $18, $1A, $1C, $1E, $20, $22
	db $80

EndingMegaManFrame7:	;$52E4
	db $F4, $E8, $33	;dx, dy, 3x3
	db $30, $32, $34, $0C, $0E, $10, $24, $26, $28
	db $80

EndingMegaManFrame8:	;$52F1
	db $F4, $E9, $33	;dx, dy, 3x3
	db $36, $32, $34, $00, $02, $04, $06, $08, $0A
	db $80

EndingMegaManFrame9:	;$52FE
	db $F4, $E8, $33	;dx, dy, 3x3
	db $36, $32, $34, $0C, $0E, $10, $12, $14, $16
	db $80

EndingMegaManFrame10:	;$530B
	db $F4, $E9, $33	;dx, dy, 3x3
	db $36, $32, $34, $18, $1A, $1C, $1E, $20, $22
	db $80

EndingMegaManFrame11:	;$5318
	db $F4, $E8, $33	;dx, dy, 3x3
	db $36, $32, $34, $0C, $0E, $10, $24, $26, $28
	db $80

EndingMegaManFrame12:	;$5325
	db $F4, $E9, $33	;dx, dy, 3x3
	db $38, $3A, $3C, $3E, $40, $42, $44, $46, $48
	db $80

StarFrame1:	;$5332
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

StarFrame2:	;$5337
	db $FC, $FC, $11	;dx, dy, 1x1
	db $02
	db $80

StarFrame3:	;$533C
	db $FC, $FC, $11	;dx, dy, 1x1
	db $04
	db $80

;Sprite tiles $80-$E5 at $8800: three stars, the shuttle, big Mega Man,
;three more stars.	;[ok]
EndingSpaceSpriteTiles:	;$5341
	INCBIN "gfx/ending/space_sprites.2bpp", 0, 102 * 16
EndingSpaceSpriteTilesEnd:

;Sprite tiles at $8000 for roll-call entries 1-14, in entry order. Most are
;the in-game enemies' own tile shapes with other colour indices (see
;RollCallFramePtrs).	;[ok]
RollCallEnemyTiles:	;$59A1
	INCBIN "gfx/ending/roll_call_enemies.2bpp", 0, 118 * 16
RollCallEnemyTilesEnd:

;Tileset 1-3: Changkey Maker ($00-$0F), Picopico ($10-$1B) and Bunby Heli
;($1C-$23).	;[ok]
RollCallEnemyTiles2:	;$6101
	INCBIN "gfx/ending/roll_call_enemies_2.2bpp", 0, 36 * 16
RollCallEnemyTiles2End:

;Tilesets 4-12: a 16-tile head per robot master, in roll-call order.	;[ok]
RollCallCutManTiles:	;$6341
	INCBIN "gfx/ending/roll_call_cut_man.2bpp"
RollCallCutManTilesEnd:
RollCallElecManTiles:	;$6441
	INCBIN "gfx/ending/roll_call_elec_man.2bpp"
RollCallElecManTilesEnd:
RollCallIceManTiles:	;$6541
	INCBIN "gfx/ending/roll_call_ice_man.2bpp"
RollCallIceManTilesEnd:
RollCallFireManTiles:	;$6641
	INCBIN "gfx/ending/roll_call_fire_man.2bpp"
RollCallFireManTilesEnd:
RollCallBubbleManTiles:	;$6741
	INCBIN "gfx/ending/roll_call_bubble_man.2bpp"
RollCallBubbleManTilesEnd:
RollCallHeatManTiles:	;$6841
	INCBIN "gfx/ending/roll_call_heat_man.2bpp"
RollCallHeatManTilesEnd:
RollCallQuickManTiles:	;$6941
	INCBIN "gfx/ending/roll_call_quick_man.2bpp"
RollCallQuickManTilesEnd:
RollCallFlashManTiles:	;$6A41
	INCBIN "gfx/ending/roll_call_flash_man.2bpp"
RollCallFlashManTilesEnd:
RollCallEnkerTiles:	;$6B41
	INCBIN "gfx/ending/roll_call_enker.2bpp"
RollCallEnkerTilesEnd:

;The ending's font at $9000: ASCII $20-$5F, with a copyright glyph at `@`.
;See the rollcall charmap.	;[ok]
EndingFontTiles:	;$6C41
	INCBIN "gfx/ending/font.2bpp"
EndingFontTilesEnd:
