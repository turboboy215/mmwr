;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $04
;Sprite graphics: Mega Man, his weapons, the HUD, and the sprite tiles of object
;types 1-29. Every tile run is a PNG under gfx/sprites/, converted by rgbgfx at
;build time (step 3.1). Confidence tags: [ok] verified here, [dc] corroborated by
;Data Crystal, [?] guess. See docs/CONVENTIONS.md.

SECTION "bank4",ROMX[$4000],BANK[$4]

;$4000: graphics pointer table, 42 entries. Bank $00 points at each slot (the
;GfxRef_* and GfxRef_StageSelect-Ptr_00_0339 words), not at the targets directly.
;Entries 3-13 are the weapons in the same order as the unlock bits at
;$DFA1/$DFA2. Slots 16-41 are the object-type tilesets that LoadObjectTiles
;reaches through ObjectTilesetPtrs; their names give the object type.	;[ok]
GfxPtr_MegaMan:	;[ok]
	dw MegaManGfxHeader
GfxPtr_ItemPickup:	;[ok]
	dw ItemPickupGfxHeader
GfxPtr_MegaBusterShot:	;[ok]
	dw MegaBusterShotGfxHeader
GfxPtr_RollingCutter:	;[ok]
	dw RollingCutterGfxHeader
GfxPtr_ThunderBeam:	;[ok]
	dw ThunderBeamGfxHeader
GfxPtr_IceSlasher:	;[ok]
	dw IceSlasherGfxHeader
GfxPtr_FireStorm:	;[ok]
	dw FireStormGfxHeader
GfxPtr_Carry:	;[ok]
	dw CarryGfxHeader
GfxPtr_AtomicFire:	;[ok]
	dw AtomicFireGfxHeader
GfxPtr_TimeStopper:	;[ok]
	dw TimeStopperGfxHeader
GfxPtr_QuickBoomerang:	;[ok]
	dw QuickBoomerangGfxHeader
GfxPtr_BubbleLead:	;[ok]
	dw BubbleLeadGfxHeader
GfxPtr_MirrorBuster:	;[ok]
	dw MirrorBusterGfxHeader
GfxPtr_HealthBar:	;[ok]
	dw HealthBarGfxHeader
GfxPtr_HUD:	;[ok]
	dw HUDGfxHeader
GfxPtr_StageSelect:	;[ok]
	dw StageSelectGfxHeader
GfxPtr_ObjType01:
	dw ObjGfxType01
GfxPtr_ObjType02:
	dw ObjGfxType02
GfxPtr_ObjType03:
	dw ObjGfxType03
GfxPtr_ObjType04:
	dw ObjGfxType04
GfxPtr_ObjType05:
	dw ObjGfxType05
GfxPtr_ObjType06:
	dw ObjGfxType06
GfxPtr_ObjType07:
	dw ObjGfxType07
GfxPtr_ObjType08:
	dw ObjGfxType08
GfxPtr_Fan:
	dw FanGfx
GfxPtr_ObjType10:
	dw ObjGfxType10
GfxPtr_ObjType11:
	dw ObjGfxType11
GfxPtr_ObjType12:
	dw ObjGfxType12
GfxPtr_ObjType13:
	dw ObjGfxType13
GfxPtr_ObjType14:
	dw ObjGfxType14
GfxPtr_ObjType15:
	dw ObjGfxType15
GfxPtr_ObjType16:
	dw ObjGfxType16
GfxPtr_ObjType17:
	dw ObjGfxType17
GfxPtr_ObjType18:
	dw ObjGfxType18
GfxPtr_ObjType19:
	dw ObjGfxType19
GfxPtr_AppearingBlock:
	dw AppearingBlockGfx
GfxPtr_ObjType21:
	dw ObjGfxType21
GfxPtr_ObjType22:
	dw ObjGfxType22
GfxPtr_Icicle:
	dw IcicleGfx
GfxPtr_ObjType24:
	dw ObjGfxType24
GfxPtr_ObjType25to28:
	dw ObjGfxType25to28
GfxPtr_AtomicFireBlock:
	dw AtomicFireBlockGfx

;Two-word headers: byte count, then the tiles.
MegaManGfxHeader:
	dw 114*16
	dw MegaManTiles
ItemPickupGfxHeader:
	dw 11*16
	dw ItemPickupTiles

;$405C: Mega Man, 114 tiles. gfx/sprites/mega_man.png.	;[ok]
MegaManTiles:
	INCBIN "gfx/sprites/mega_man.2bpp"

;$477C: energy pellets and capsules, 11 tiles. gfx/sprites/item_pickup.png.	;[ok]
ItemPickupTiles:
	INCBIN "gfx/sprites/item_pickup.2bpp"

;Weapon shots: one-byte tile count, then the tiles. In unlock-bit order; checked
;by rendering each run (step 3.1).	;[ok]
MegaBusterShotGfxHeader:
	db 1
	dw MegaBusterShotTiles
RollingCutterGfxHeader:
	db 4
	dw RollingCutterTiles
ThunderBeamGfxHeader:
	db 14
	dw ThunderBeamTiles
IceSlasherGfxHeader:
	db 8
	dw IceSlasherTiles
FireStormGfxHeader:
	db 10
	dw FireStormTiles
CarryGfxHeader:
	db 12
	dw CarryTiles
AtomicFireGfxHeader:
	db 12
	dw AtomicFireTiles
TimeStopperGfxHeader:
	db 3
	dw TimeStopperTiles
QuickBoomerangGfxHeader:
	db 2
	dw QuickBoomerangTiles
BubbleLeadGfxHeader:
	db 10
	dw BubbleLeadTiles
MirrorBusterGfxHeader:
	db 9
	dw MirrorBusterTiles

MegaBusterShotTiles:
	INCBIN "gfx/sprites/mega_buster_shot.2bpp"
RollingCutterTiles:
	INCBIN "gfx/sprites/rolling_cutter.2bpp"
ThunderBeamTiles:
	INCBIN "gfx/sprites/thunder_beam.2bpp"
IceSlasherTiles:
	INCBIN "gfx/sprites/ice_slasher.2bpp"
FireStormTiles:
	INCBIN "gfx/sprites/fire_storm.2bpp"
CarryTiles:
	INCBIN "gfx/sprites/carry.2bpp"
AtomicFireTiles:
	INCBIN "gfx/sprites/atomic_fire.2bpp"
TimeStopperTiles:
	INCBIN "gfx/sprites/time_stopper.2bpp"
QuickBoomerangTiles:
	INCBIN "gfx/sprites/quick_boomerang.2bpp"
BubbleLeadTiles:
	INCBIN "gfx/sprites/bubble_lead.2bpp"
MirrorBusterTiles:
	INCBIN "gfx/sprites/mirror_buster.2bpp"

;HUD graphics, two-word headers like Mega Man's. HealthBarTiles and HUDTiles are
;used together (Will).
HealthBarGfxHeader:
	; health bar, and 3/4 of Mega Man's face
	dw 11*16
	dw HealthBarTiles
HUDGfxHeader:
	; 1/4 of Mega Man's face, 7-segment lives count, and "WPN"
	dw 16*16
	dw HUDTiles
StageSelectGfxHeader:
	dw 8*16
	dw StageSelectTiles

;$4DA9: gfx/sprites/health_bar.png.	;[ok]
HealthBarTiles:
	INCBIN "gfx/sprites/health_bar.2bpp"

;$4E59: the rest of the HUD - the last quarter of Mega Man's face, the
;seven-segment lives digits and "WPN". Called the seven-segment digits until
;Will pointed out it is the HUD. gfx/sprites/hud.png.	;[ok]
HUDTiles:
	INCBIN "gfx/sprites/hud.2bpp"

;$4F59: two bytes nothing points at.	;[?]
Data_04_4F59:
	db 4,8

;$4F5B: the stage-select sprites, identified by Will: the ring is the cursor
;(on the stage select and the password screen), and the three dots are the
;stars that fly past in the background when a stage is chosen. Corroborated
;here: the only loader, LoadStageSelectSprites, is called by bank $01's
;stage-select setup at $1:6181, and that screen turns on 8x16 sprites (it ORs
;$64 into wShadowLCDC), so the 8 tiles are four 8x16 sprites - each image with
;a blank lower half. gfx/sprites/stage_select.png, laid out as 8x8 tiles.	;[ok]
StageSelectTiles:
	INCBIN "gfx/sprites/stage_select.2bpp"

;$4FDB: object-type tileset records, one-byte tile count and a pointer, read by
;LoadObjectTiles. Named by the object type(s) whose ObjectTilesetPtrs entry
;leads here. Type 8 has a count of 0 and loads nothing. Types 25-28 share one
;record, which reuses five of type 24's six tiles; type 11 loads the first eight
;of type 12's.	;[ok]
ObjGfxType01:
	db 8
	dw ObjTilesType01
ObjGfxType02:
	db 8
	dw ObjTilesType02
ObjGfxType03:
	db 2
	dw ObjTilesType03
ObjGfxType04:
	db 32
	dw ObjTilesType04
ObjGfxType05:
	db 12
	dw ObjTilesType05
ObjGfxType06:
	db 19
	dw ObjTilesType06
ObjGfxType08:
	db 0, $80	;count 0, so the $80 is never read
ObjGfxType07:
	db 6
	dw ObjTilesType07
FanGfx:
	db 8
	dw FanTiles
ObjGfxType10:
	db 29
	dw ObjTilesType10
ObjGfxType11:
	db 8
	dw ObjTilesType12
ObjGfxType12:
	db 42
	dw ObjTilesType12
ObjGfxType13:
	db 8
	dw ObjTilesType13
ObjGfxType14:
	db 1
	dw ObjTilesType14
ObjGfxType15:
	db 26
	dw ObjTilesType15
ObjGfxType16:
	db 10
	dw ObjTilesType16
ObjGfxType17:
	db 20
	dw ObjTilesType17
ObjGfxType18:
	db 7
	dw ObjTilesType18
ObjGfxType19:
	db 16
	dw ObjTilesType19
AppearingBlockGfx:
	db 10
	dw AppearingBlockTiles
ObjGfxType21:
	db 3
	dw ObjTilesType21
ObjGfxType22:
	db 16
	dw ObjTilesType22
IcicleGfx:
	db 12
	dw IcicleTiles
ObjGfxType24:
	db 6
	dw ObjTilesType24
ObjGfxType25to28:
	db 5
	dw ObjTilesType25to28
AtomicFireBlockGfx:
	db 16
	dw AtomicFireBlockTiles

;$5028: the tiles, in ROM order. gfx/sprites/obj_typeNN.png.
ObjTilesType01:
	INCBIN "gfx/sprites/obj_type01.2bpp"
ObjTilesType02:
	INCBIN "gfx/sprites/obj_type02.2bpp"
ObjTilesType03:
	INCBIN "gfx/sprites/obj_type03.2bpp"
ObjTilesType04:
	INCBIN "gfx/sprites/obj_type04.2bpp"
ObjTilesType05:
	INCBIN "gfx/sprites/obj_type05.2bpp"
ObjTilesType06:
	INCBIN "gfx/sprites/obj_type06.2bpp", 0 * 16, 19 * 16
ObjTilesType07:
	INCBIN "gfx/sprites/obj_type07.2bpp"
;Type 9: the fan that blows Mega Man away - identified by Will. Placed in Elec
;Man's stage and Wily stages 1 and 3. The PNG keeps its type-number name.	;[ok]
FanTiles:
	INCBIN "gfx/sprites/obj_type09.2bpp"
ObjTilesType10:
	INCBIN "gfx/sprites/obj_type10.2bpp", 0 * 16, 29 * 16
ObjTilesType12:
	INCBIN "gfx/sprites/obj_type12.2bpp"
ObjTilesType13:
	INCBIN "gfx/sprites/obj_type13.2bpp"
ObjTilesType14:
	INCBIN "gfx/sprites/obj_type14.2bpp"
ObjTilesType15:
	INCBIN "gfx/sprites/obj_type15.2bpp"
ObjTilesType16:
	INCBIN "gfx/sprites/obj_type16.2bpp"
ObjTilesType17:
	INCBIN "gfx/sprites/obj_type17.2bpp"
ObjTilesType18:
	INCBIN "gfx/sprites/obj_type18.2bpp"
ObjTilesType19:
	INCBIN "gfx/sprites/obj_type19.2bpp"
;Type 20: the block that appears out of the wall and vanishes again with a sound
;effect - identified by Will. Its ObjectStatsTab flags are $00, so it is not
;visible when spawned, which fits.	;[ok]
AppearingBlockTiles:
	INCBIN "gfx/sprites/appearing_block.2bpp"
ObjTilesType21:
	INCBIN "gfx/sprites/obj_type21.2bpp"
ObjTilesType22:
	INCBIN "gfx/sprites/obj_type22.2bpp"
;Type 23: the icicle in Ice Man's stage that appears with a "shing" and has to
;be stood on to get through - identified by Will. Its ObjectStatsTab record asks
;for 0 OAM entries, so it gets no sprite handle at spawn; how it is drawn is for
;Phase 5.	;[ok]
IcicleTiles:
	INCBIN "gfx/sprites/icicle.2bpp"
ObjTilesType24:
	INCBIN "gfx/sprites/obj_type24.2bpp", 0 * 16, 1 * 16
ObjTilesType25to28:
	INCBIN "gfx/sprites/obj_type24.2bpp", 1 * 16, 5 * 16
;Type 29: a destructible block that only Atomic Fire can break - identified by
;Will. Placed only in Wily stage 3 (four of them). The PNG keeps its type-number
;name.	;[ok]
AtomicFireBlockTiles:
	INCBIN "gfx/sprites/obj_type29.2bpp"

;$63F8-$6FDF: 3048 bytes that nothing points at - alternating 32-byte runs of
;$FF and $00 with a few stray set bits, the pattern of uninitialised memory.
;Filler, not graphics. Written with uninit_fill (macros/filler.inc): here the
;$00 runs sit where address bit 5 is clear. The five stray bytes are each a
;single set bit inside a $00 run.	;[ok]
Unused_04_63F8:
	uninit_fill $6640, $00
	db $80	;stray bit at $6640
	uninit_fill $66C0, $00
	db $02	;stray bit at $66C0
	uninit_fill $6D40, $00
	db $80	;stray bit at $6D40
	uninit_fill $6E80, $00
	db $80	;stray bit at $6E80
	uninit_fill $6F40, $00
	db $80	;stray bit at $6F40
	uninit_fill $6FE0, $00

;$6FE0-$7FFF: unused, all $FF.	;[ok]
	ds $8000 - $6FE0, $FF
