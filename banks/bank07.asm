;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $07
;Boss graphics (step 4.4): the sprite tiles of object types 30-56 - the robot
;masters, the Wily castle bosses and the castle's other objects - and the
;stage-select screen's robot master sprites, which are built out of the same
;tiles. Tiles are PNGs under gfx/bosses/, converted by rgbgfx at build time.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;guess. See docs/CONVENTIONS.md.

SECTION "bank7", ROMX[$4000], BANK[$7]

;$4000: pointer table, 31 entries, reached through the ROM0 slots $036D-$03A9.
;Slots 0-20 are object-type tilesets for LoadObjectTiles (types $1E and up,
;through ObjectTilesetPtrs); slots 21-30 are the stage-select robot masters,
;read by the stage-select code in engine/stage_select.asm. Robot master names:
;each type is spawned in that master's boss room, and the stage select loads the
;same tiles for that master's portrait; the Wily bosses are from step 4.3.	;[ok]
GfxPtr_CutMan:	;type 30
	dw CutManGfx
GfxPtr_BossRollingCutter:	;types 31, 43
	dw BossRollingCutterGfx
GfxPtr_IceMan:	;type 32
	dw IceManGfx
GfxPtr_BossIceSlasher:	;type 33
	dw BossIceSlasherGfx
GfxPtr_ElecMan:	;type 34
	dw ElecManGfx
GfxPtr_ObjType35:	;type 35 - type 33's tiles
	dw ObjType35Gfx
GfxPtr_FireMan:	;type 36
	dw FireManGfx
GfxPtr_BossFireStorm:	;type 37
	dw BossFireStormGfx
GfxPtr_Enker:	;type 38
	dw EnkerGfx
GfxPtr_ObjType39:	;type 39
	dw ObjType39Gfx
GfxPtr_BubbleMan:	;type 40
	dw BubbleManGfx
GfxPtr_BossBubbleLead:	;type 41
	dw BossBubbleLeadGfx
GfxPtr_FlashMan:	;type 42
	dw FlashManGfx
GfxPtr_HeatMan:	;type 44
	dw HeatManGfx
GfxPtr_BossAtomicFire:	;type 45
	dw BossAtomicFireGfx
GfxPtr_QuickMan:	;type 46
	dw QuickManGfx
GfxPtr_BossQuickBoomerang:	;type 47
	dw BossQuickBoomerangGfx
GfxPtr_WilyMachineParts:	;types 48, 49, 50, 51
	dw WilyMachinePartsGfx
GfxPtr_TeleporterLight:	;types 53, 54
	dw TeleporterLightGfx
GfxPtr_BossDoor:	;type 55
	dw BossDoorGfx
GfxPtr_TeleportSystemSign:	;type 56
	dw TeleportSystemSignGfx
GfxPtr_StageSelectFireManTileList:
	dw StageSelectFireManTileListPtr
GfxPtr_StageSelectCutManTileList:
	dw StageSelectCutManTileListPtr
GfxPtr_StageSelectIceManTileList:
	dw StageSelectIceManTileListPtr
GfxPtr_StageSelectElecManTileList:
	dw StageSelectElecManTileListPtr
GfxPtr_StageSelectFireManFrames:
	dw StageSelectFireManFramesPtr
GfxPtr_StageSelectCutManFrames:
	dw StageSelectCutManFramesPtr
GfxPtr_StageSelectIceManFrames:
	dw StageSelectIceManFramesPtr
GfxPtr_StageSelectElecManFrames:
	dw StageSelectElecManFramesPtr
GfxPtr_StageSelectTopRowArc:
	dw StageSelectTopRowArcPtr
GfxPtr_StageSelectBottomRowArc:
	dw StageSelectBottomRowArcPtr

;$403E: tileset records for LoadObjectTiles: a tile count and the tiles.	;[ok]
CutManGfx:
	db 61
	dw CutManTiles
BossRollingCutterGfx:
	db 4
	dw BossRollingCutterTiles
IceManGfx:
	db 64
	dw IceManTiles
BossIceSlasherGfx:
	db 8
	dw BossIceSlasherTiles
ElecManGfx:
	db 74
	dw ElecManTiles
ObjType35Gfx:
	db 8
	dw BossIceSlasherTiles
FireManGfx:
	db 64
	dw FireManTiles
BossFireStormGfx:
	db 20
	dw BossFireStormTiles
EnkerGfx:
	db 67
	dw EnkerTiles
ObjType39Gfx:
	db 1
	dw ObjType39Tiles
BubbleManGfx:
	db 82
	dw BubbleManTiles
BossBubbleLeadGfx:
	db 10
	dw BossBubbleLeadTiles
FlashManGfx:
	db 89
	dw FlashManTiles
HeatManGfx:
	db 87
	dw HeatManTiles
BossAtomicFireGfx:
	db 8
	dw BossAtomicFireTiles
QuickManGfx:
	db 71
	dw QuickManTiles
BossQuickBoomerangGfx:
	db 2
	dw BossQuickBoomerangTiles
WilyMachinePartsGfx:
	db 116
	dw WilyMachinePartsTiles
TeleporterLightGfx:
	db 1
	dw TeleporterLightTiles
BossDoorGfx:
	db 2
	dw BossDoorTiles
TeleportSystemSignGfx:
	db 15
	dw TeleportSystemSignTiles

;$407D: what the stage-select slots point at. For the tile lists and the arcs
;it is a single word, the data's address; for the frames it is the list of
;metasprite pointers itself, indexed by wStageSelectFrame (GetStageSelectFrame).	;[ok]
StageSelectFireManTileListPtr:
	dw StageSelectFireManTileList
StageSelectCutManTileListPtr:
	dw StageSelectCutManTileList
StageSelectIceManTileListPtr:
	dw StageSelectIceManTileList
StageSelectElecManTileListPtr:
	dw StageSelectElecManTileList
StageSelectFireManFramesPtr:
	dw StageSelectFireManFrame0
	dw StageSelectFireManFrame1
	dw StageSelectFireManFrame2
	dw StageSelectFireManFrame3
	dw StageSelectFireManFrame4
	dw StageSelectFireManFrame5
StageSelectCutManFramesPtr:
	dw StageSelectCutManFrame0
	dw StageSelectCutManFrame1
	dw StageSelectCutManFrame2
	dw StageSelectCutManFrame3
StageSelectIceManFramesPtr:
	dw StageSelectIceManFrame0
	dw StageSelectIceManFrame1
	dw StageSelectIceManFrame2
	dw StageSelectIceManFrame3
StageSelectElecManFramesPtr:
	dw StageSelectElecManFrame0
	dw StageSelectElecManFrame1
	dw StageSelectElecManFrame2
	dw StageSelectElecManFrame3
	dw StageSelectElecManFrame4
StageSelectTopRowArcPtr:
	dw StageSelectTopRowArc
StageSelectBottomRowArcPtr:
	dw StageSelectBottomRowArc

;$40AF: tiles, in ROM order. gfx/bosses/*.png.	;[ok]
CutManTiles:	;$40AF, 61 tiles
	INCBIN "gfx/bosses/cut_man.2bpp", 0, 61 * 16
;Type 31: Cut Man's Rolling Cutter - identified by Will. Type 43 (beside Flash
;Man) loads the same tiles.	;[ok]
BossRollingCutterTiles:	;$447F, 4 tiles
	INCBIN "gfx/bosses/obj_type31.2bpp"
IceManTiles:	;$44BF, 64 tiles
	INCBIN "gfx/bosses/ice_man.2bpp"
;Type 33: Ice Man's Ice Slasher - identified by Will; three are placed beside
;him. Type 35, never placed, loads the same tiles.	;[ok]
BossIceSlasherTiles:	;$48BF, 8 tiles
	INCBIN "gfx/bosses/obj_type33.2bpp"
ElecManTiles:	;$493F, 74 tiles
	INCBIN "gfx/bosses/elec_man.2bpp", 0, 74 * 16
FireManTiles:	;$4DDF, 64 tiles
	INCBIN "gfx/bosses/fire_man.2bpp"
;Type 37: the Fire Storm - identified by Will. Placed beside Fire Man (and the
;alternate Fire Man) - and beside Elec Man too, which is not yet explained.	;[ok]
BossFireStormTiles:	;$51DF, 20 tiles
	INCBIN "gfx/bosses/obj_type37.2bpp", 0, 20 * 16
EnkerTiles:	;$531F, 67 tiles
	INCBIN "gfx/bosses/enker.2bpp", 0, 67 * 16
;Type 39: one tile; Will thinks it may be Enker's Mirror Buster. Never placed
;in a spawn list.	;[?]
ObjType39Tiles:	;$574F, 1 tiles
	INCBIN "gfx/bosses/obj_type39.2bpp"
BubbleManTiles:	;$575F, 82 tiles
	INCBIN "gfx/bosses/bubble_man.2bpp", 0, 82 * 16
;Type 41: Bubble Man's Bubble Lead - identified by Will. Five are placed in his
;room, beside him.	;[ok]
BossBubbleLeadTiles:	;$5C7F, 10 tiles
	INCBIN "gfx/bosses/obj_type41.2bpp"
FlashManTiles:	;$5D1F, 89 tiles
	INCBIN "gfx/bosses/flash_man.2bpp", 0, 89 * 16
HeatManTiles:	;$62AF, 87 tiles
	INCBIN "gfx/bosses/heat_man.2bpp", 0, 87 * 16
;Type 45: Heat Man's Atomic Fire - identified by Will; three beside him.	;[ok]
BossAtomicFireTiles:	;$681F, 8 tiles
	INCBIN "gfx/bosses/obj_type45.2bpp"
QuickManTiles:	;$689F, 71 tiles
	INCBIN "gfx/bosses/quick_man.2bpp", 0, 71 * 16
;Type 47: Quick Man's Quick Boomerang - identified by Will; three beside him.	;[ok]
BossQuickBoomerangTiles:	;$6D0F, 2 tiles
	INCBIN "gfx/bosses/obj_type47.2bpp"

;$6D2F: the stage-select robot master sprites. The four robot masters'
;tilesets are loaded into sprite VRAM by LoadStageSelectBosses, each through a tile list:
;a count, then one byte per destination tile - the source tile number in that
;robot master's tileset, or $FF for a blank tile. Fire Man's go to $8080, Cut
;Man's to $8360, Ice Man's to $8580 and Elec Man's to $8820.	;[ok]
StageSelectFireManTileList:
	db 46
	db $FF, $00, $FF, $01, $FF, $02, $FF, $03, $04, $07, $0A, $FF, $05, $08, $0B, $FF
	db $06, $09, $0C, $FF, $0D, $10, $0E, $11, $0F, $12, $13, $FF, $14, $17, $1A, $FF
	db $15, $18, $16, $19, $1B, $FF, $3C, $FF, $3D, $FF, $3E, $FF, $3F, $FF
StageSelectCutManTileList:
	db 34
	db $FF, $15, $FF, $16, $00, $03, $06, $FF, $01, $04, $07, $FF, $02, $05, $08, $FF
	db $0C, $0F, $12, $FF, $0D, $10, $13, $FF, $0E, $11, $14, $FF, $00, $09, $01, $0A
	db $02, $0B
StageSelectIceManTileList:
	db 42
	db $00, $03, $06, $FF, $01, $04, $07, $FF, $02, $05, $08, $FF, $09, $0C, $0F, $FF
	db $0A, $0D, $10, $FF, $0B, $0E, $11, $FF, $12, $13, $16, $FF, $01, $14, $02, $15
	db $17, $FF, $18, $FF, $19, $FF, $1A, $FF, $1B, $FF
StageSelectElecManTileList:
	db 42
	db $00, $03, $06, $FF, $01, $04, $07, $FF, $02, $05, $08, $FF, $00, $0A, $0C, $FF
	db $0D, $FF, $09, $0B, $0E, $FF, $0F, $FF, $10, $13, $11, $14, $12, $15, $16, $FF
	db $17, $1A, $1D, $FF, $18, $1B, $1E, $1F, $19, $1C

;$6DD7: metasprite frames, drawn by DrawSpriteGrid: a byte cols << 4 | rows,
;rows x cols (tile, attributes) pairs - 8x16 sprites, 8 pixels apart across,
;16 down - then any extra sprites as (dx, dy, tile, attributes), ended by $80.
;Fire Man's at the bottom right, Cut Man's top left, Ice Man's top right, Elec
;Man's bottom left; frame 1 is the standing pose, the others the jump into the
;middle when a stage is picked.	;[ok]
StageSelectFireManFrame0:
	db $32	;3 x 2
	db $10, $10, $14, $10, $18, $10
	db $12, $10, $16, $10, $1A, $10
	db $04, $F0, $08, $10	;extra
	db $0C, $F0, $0A, $10	;extra
	db $80
StageSelectFireManFrame1:
	db $32	;3 x 2
	db $10, $10, $14, $10, $18, $10
	db $12, $10, $16, $10, $1A, $10
	db $04, $F0, $08, $10	;extra
	db $0C, $F0, $0A, $10	;extra
	db $1E, $00, $FE, $10	;extra
	db $80
StageSelectFireManFrame2:
	db $32	;3 x 2
	db $1C, $10, $1E, $10, $20, $10
	db $2C, $30, $16, $10, $22, $10
	db $04, $F0, $08, $10	;extra
	db $0C, $F0, $0A, $10	;extra
	db $80
StageSelectFireManFrame3:
	db $32	;3 x 2
	db $24, $10, $28, $10, $2A, $10
	db $26, $10, $16, $30, $2C, $10
	db $05, $F1, $08, $10	;extra
	db $0D, $F1, $0A, $10	;extra
	db $1E, $00, $FE, $10	;extra
	db $80
StageSelectFireManFrame4:
	db $32	;3 x 2
	db $24, $10, $28, $10, $2A, $10
	db $26, $10, $16, $30, $2C, $10
	db $05, $F1, $0C, $10	;extra
	db $0D, $F1, $0E, $10	;extra
	db $1E, $00, $FE, $10	;extra
	db $80
StageSelectFireManFrame5:
	db $32	;3 x 2
	db $10, $10, $14, $10, $18, $10
	db $2E, $10, $30, $10, $32, $10
	db $0C, $18, $34, $10	;extra
	db $04, $F0, $08, $10	;extra
	db $0C, $F0, $0A, $10	;extra
	db $80
StageSelectCutManFrame0:
	db $32	;3 x 2
	db $42, $30, $3E, $30, $3A, $30
	db $44, $30, $40, $30, $3C, $30
	db $02, $F0, $36, $10	;extra
	db $0A, $F0, $36, $30	;extra
	db $80
StageSelectCutManFrame1:
	db $32	;3 x 2
	db $3A, $10, $3E, $10, $42, $10
	db $3C, $10, $40, $10, $44, $10
	db $06, $F0, $36, $10	;extra
	db $0E, $F0, $36, $30	;extra
	db $80
StageSelectCutManFrame2:
	db $32	;3 x 2
	db $52, $10, $54, $10, $56, $10
	db $3C, $10, $40, $10, $44, $10
	db $06, $F0, $38, $10	;extra
	db $0E, $F0, $38, $30	;extra
	db $80
StageSelectCutManFrame3:
	db $32	;3 x 2
	db $4E, $30, $4A, $30, $46, $30
	db $50, $30, $4C, $30, $48, $30
	db $05, $F0, $36, $10	;extra
	db $0D, $F0, $36, $30	;extra
	db $80
StageSelectIceManFrame0:
	db $32	;3 x 2
	db $58, $10, $5C, $10, $60, $10
	db $5A, $10, $5E, $10, $62, $10
	db $0D, $18, $FE, $10	;extra
	db $80
StageSelectIceManFrame1:
	db $32	;3 x 2
	db $64, $10, $68, $10, $6C, $10
	db $66, $10, $6A, $10, $6E, $10
	db $80
StageSelectIceManFrame2:
	db $32	;3 x 2
	db $70, $10, $74, $10, $76, $10
	db $72, $10, $5E, $10, $78, $10
	db $80
StageSelectIceManFrame3:
	db $32	;3 x 2
	db $58, $10, $5C, $10, $60, $10
	db $7A, $10, $7C, $10, $7E, $10
	db $0D, $18, $80, $10	;extra
	db $80
StageSelectElecManFrame0:
	db $32	;3 x 2
	db $8A, $30, $86, $30, $82, $30
	db $8C, $30, $88, $30, $84, $30
	db $80
StageSelectElecManFrame1:
	db $32	;3 x 2
	db $82, $10, $86, $10, $8A, $10
	db $84, $10, $88, $10, $8C, $10
	db $18, $00, $FE, $30	;extra
	db $F8, $00, $FE, $10	;extra
	db $80
StageSelectElecManFrame2:
	db $32	;3 x 2
	db $8E, $10, $86, $10, $94, $10
	db $90, $10, $92, $10, $96, $10
	db $80
StageSelectElecManFrame3:
	db $32	;3 x 2
	db $9A, $10, $9C, $10, $9E, $10
	db $90, $10, $92, $10, $96, $10
	db $F8, $00, $98, $10	;extra
	db $80
StageSelectElecManFrame4:
	db $32	;3 x 2
	db $AA, $30, $A6, $30, $A2, $30
	db $FE, $30, $A8, $30, $A4, $30
	db $18, $00, $A0, $30	;extra
	db $80

;$6F59: the jump into the middle of the screen after a stage is picked: 45
;signed steps (high nibble whole pixels, low nibble sixteenths, accumulated by
;AddFixedPoint44) added to the robot master's Y each frame, until wScreenCounter
;reaches $2C. One arc for each row of the stage select.	;[ok]
StageSelectTopRowArc:
	db $E1, $E3, $E5, $E7, $E9, $EB, $ED, $EF, $F1, $F3, $F5, $F7, $F9, $FB, $FD, $FF
	db $01, $03, $05, $07, $09, $0B, $0D, $0F, $11, $13, $15, $17, $19, $1B, $1D, $1F
	db $21, $23, $25, $27, $29, $2B, $2D, $2F, $31, $33, $35, $37, $00
StageSelectBottomRowArc:
	db $C5, $C7, $C9, $CB, $CD, $CF, $D1, $D3, $D5, $D7, $D9, $DB, $DD, $DF, $E1, $E3
	db $E5, $E7, $E9, $EB, $ED, $EF, $F1, $F3, $F5, $F7, $F9, $FB, $FD, $FF, $01, $03
	db $05, $07, $09, $0B, $0D, $0F, $11, $13, $15, $17, $19, $1B, $00

;Type 48 (49-51 share the tiles): Dr. Wily and the sprite parts of the Wily
;Machine, including the wheel enemy it shoots - identified by Will. 116 tiles,
;almost all of the 117 sprite tiles free ($8B-$FF). The machine's body is
;background, drawn with the cutscene's Wily Machine tiles (docs/LEVELS.md).	;[ok]
WilyMachinePartsTiles:	;$6FB3, 116 tiles
	INCBIN "gfx/bosses/obj_type48.2bpp", 0, 116 * 16
;Types 53/54: the light shown on active teleporters - identified by Will. One
;per teleporter in the Wily 2 hub, its number (0-4) as its Y.	;[ok]
TeleporterLightTiles:	;$76F3, 1 tiles
	INCBIN "gfx/bosses/obj_type53.2bpp"
;Type 55: the boss door - identified by Will. Two tiles of horizontal
;stripes, the same graphic as the shutter blocks in every robot master blockset.
;Each robot master stage places one, before its boss room.	;[ok]
BossDoorTiles:	;$7703, 2 tiles
	INCBIN "gfx/bosses/obj_type55.2bpp"
;The letters of "DR.WILY TELEPORT SYSTEM": type 56, placed once in each Wily 2
;hub, is the sign over the teleporters.	;[ok]
TeleportSystemSignTiles:	;$7723, 15 tiles
	INCBIN "gfx/bosses/teleport_system_sign.2bpp"

;The rest of the bank is $FF.	;[ok]
	ds $8000 - @, $FF
