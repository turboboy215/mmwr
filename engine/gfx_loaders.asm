;Mega Man: Dr. Wily's Revenge disassembly - tile and graphics loaders
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "LoadFontTiles", ROM0[$03C3]

;$03C3: copy the 30 tiles at FontTiles - the A-Z font and the four bar tiles
;after it - to wherever DE points. The caller picks the VRAM destination.	;[ok]
LoadFontTiles::	;$03C3
	ld hl,FontTiles
	ld bc,FontTilesEnd - FontTiles
	call CopyVRAM
	ret

SECTION "Graphics Loaders", ROM0[$2245]

;$2245-$22F4: four full-screen pictures from bank $06, drawn with the LCD off.
;Bank $01 calls them in sequence at $1:6418, $6441, $646A and $6493 (and each has
;a stub, $018F-$0198). Each loads its tiles to $9000 (the castle also loads extra
;tiles to $8800) and copies a 20x18 map with CopyTilemap20x18.	;[ok]
;Dr. Wily's skull castle.	;[ok]
LoadWilyCastleScreen:
	ld a,6
	bankswitch
	ld de,VRAM_TILES2
	ld hl,GfxRef_WilyCastle
	call GetGfxBlock
	call FuncFill
	ld de,VRAM_TILES1
	ld hl,GfxRef_WilyCastleExtra
	call GetGfxBlock
	call FuncFill
	ld de,TILEMAP0
	ld hl,GfxRef_WilyCastleTilemap
	call TripleDeref
	call CopyTilemap20x18
	ld a,1
	bankswitch
	ret

;A skull-faced flying machine - named by the picture.	;[?]
LoadSkullShipScreen:
	ld a,6
	bankswitch
	ld de,VRAM_TILES2
	ld hl,GfxRef_SkullShip
	call GetGfxBlock
	call FuncFill
	ld de,TILEMAP0
	ld hl,GfxRef_SkullShipTilemap
	call TripleDeref
	call CopyTilemap20x18
	ld a,1
	bankswitch
	ret

;The Wily Machine, the final boss (Will): phase 1 with its dome, phase 2 with
;the dome gone and Dr. Wily visible inside.	;[ok]
LoadWilyMachinePhase1Screen:
	ld a,6
	bankswitch
	ld de,VRAM_TILES2
	ld hl,GfxRef_WilyMachine
	call GetGfxBlock
	call FuncFill
	ld de,TILEMAP0
	ld hl,GfxRef_WilyMachinePhase1Tilemap
	call TripleDeref
	call CopyTilemap20x18
	ld a,1
	bankswitch
	ret

LoadWilyMachinePhase2Screen:
	ld a,6
	bankswitch
	ld de,VRAM_TILES2
	ld hl,GfxRef_WilyMachine
	call GetGfxBlock
	call FuncFill
	ld de,TILEMAP0
	ld hl,GfxRef_WilyMachinePhase2Tilemap
	call TripleDeref
	call CopyTilemap20x18
	ld a,1
	bankswitch
	ret

;Copy a 20x18 map from HL to the BG map at DE, skipping the 12 off-screen
;columns of each row. Plain writes - LCD off.	;[ok]
CopyTilemap20x18:
	ld c,$12
.loop1
	ld b,$14
.loop2
	ld a,[hli]
	ld [de],a
	inc de
	dec b
	ld a,b
	or a
	jr nz,.loop2
	ld a,$C
	add e
	ld e,a
	ld a,0
	adc d
	ld d,a
	dec c
	ld a,c
	or a
	jr nz,.loop1
	ret

;Load Mega Man's sprite tiles to $8000 and the item pickups' to $8800 (bank
;$04). Called by InitPlayer.	;[ok]
LoadPlayerTiles:	;$230F
	ld a,BANK(GfxPtr_MegaMan)
	bankswitch

	; load Mega Man's sprite into vram
	ld de,VRAM_TILES0
	ld hl,GfxRef_MegaMan
	call GetGfxBlock
	call FuncFill

	; load item pickup sprites into vram
	ld de,VRAM_TILES1
	ld hl,GfxRef_ItemPickup
	call GetGfxBlock
	call FuncFill

	ld a,1
	bankswitch
	ret

;Load the HUD's tiles (bank $04): the energy bar at $9650 and the digits and
;letters at $9500. Called by bank $01's HUD setup.	;[ok]
LoadHUDTiles:	;$2338
	ld a,BANK(GfxPtr_HealthBar)
	bankswitch

	; load Mega Man's health bar graphics into vram
	ld de,$9650
	ld hl,GfxRef_HealthBar
	call GetGfxBlock
	call FuncFill

	; load Mega Man's live counter 7-segment graphics into vram
	ld de,$9500
	ld hl,GfxRef_HUD
	call GetGfxBlock
	call FuncFill

	ld a,1
	bankswitch
	ret

;Load the equipped weapon's shot tiles (wCurrentWeapon, bank $04) to $8720,
;from a (db tile count, dw source) record. Called by bank $01's weapon code.	;[ok]
LoadWeaponShotTiles:	;$2361
	ld a,BANK(GfxPtr_MegaBusterShot)
	bankswitch

	; load current weapon bullet into vram
	ld a,[wCurrentWeapon] ; current weapon
	ld hl,.bullets
	call GetTablePointer
	call DoubleDeref
	ld a,[hli]
	swap a
	ld b,a
	and $F0
	ld c,a
	ld a,b
	and $F
	ld b,a
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld de,$8720
	call CopyVRAM

	ld a,1
	bankswitch
	ret

.bullets
	dw GfxRef_MegaBusterShot
	dw GfxRef_RollingCutter
	dw GfxRef_ThunderBeam
	dw GfxRef_IceSlasher
	dw GfxRef_FireStorm
	dw GfxRef_Carry
	dw GfxRef_AtomicFire
	dw GfxRef_TimeStopper
	dw GfxRef_QuickBoomerang
	dw GfxRef_BubbleLead
	dw GfxRef_MirrorBuster

;$23A8: load the selected stage's background tiles from bank $0C. The stage is
;wSelectedStage, plus 4 in the Wily castle, so 1-8 as in StageLoadTab. Its
;tileset is a list of 4-byte records, ended by a $00:
;  db count	;tiles to copy, 16 bytes each
;  db first	;first tile number, counted from $9000
;  dw source	;in bank $0C
;Called by LoadStage. Returns with bank $01 paged in.	;[ok]
LoadStageTiles:	;$23A8
	ld e, 0
	ld a, [wWilyStageSet]
	or a
	jr z, .gotStage
	ld e, 4
.gotStage
	ld a, $0C
	bankswitch
	ld a, [wSelectedStage]
	add a, e
	ld hl, StageTilesetPtrs - 2	;the stage number is one-based
	call GetTablePointer
	call DoubleDeref
.record
	ld a, [hli]
	or a
	jr z, .done
	push hl
	swap a
	ld c, a
	and $0F
	ld b, a
	ld a, c
	and $F0
	ld c, a
	ld a, [hli]
	swap a
	ld e, a
	and $0F
	add a, HIGH(VRAM_TILES2)
	ld d, a
	ld a, e
	and $F0
	ld e, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call FuncFill
	pop hl
	ld de, 3
	add hl, de
	jr .record
.done
	ld a, $01
	bankswitch
	ret

;$23F9: make sure object type A's sprite tiles are in VRAM, and return the tile
;number they start at.
;A 12-entry cache at $C3C4 holds (type, first tile) pairs. If the type is there,
;return its tile with NZ. Otherwise claim the first empty entry, look the type up
;in ObjectTilesetPtrs (in bank $04 for types below $1E, bank $07 from $1E up),
;copy its tiles to the next free sprite tile - $C3B3 is the allocator, starting
;at $8B and counting up through $FF - and return that tile number.
;Returns carry if all 12 entries are taken, and also when the tiles would not
;fit - the allocator is below $80, or the count runs past $FF (there `ret c`
;leaves the entry claimed but nothing loaded). The tile number is passed back
;through hBank1CallIndex, which this borrows as scratch. Called from $26D0 and
;from bank $01 at $1:5F60.	;[ok]
LoadObjectTiles:	;$23F9
	ld b, a
	ld c, 12
	ld hl, $C3C4
.search
	ld a, b
	cp [hl]
	jr z, .cached
	ld a, [hl]
	or a
	jr z, .load
	inc hl
	inc hl
	dec c
	jr nz, .search
	scf
	ret
.cached
	inc hl
	ld a, [hl]
	or a
	ret
.load
	ld a, b
	cp $1E
	jr c, .bank04
	ld a, $07
	bankswitch
	jr .gotBank
.bank04
	ld a, $04
	bankswitch
.gotBank
	ld [hl], b
	inc hl
	ld a, [$C3B3]
	ld [hl], a
	ldh [hBank1CallIndex], a
	ld a, b
	ld hl, ObjectTilesetPtrs - 2	;types are one-based
	call GetTablePointer
	call DoubleDeref
	ld a, [hl]
	or a
	jr nz, .copy
	push hl
	ld a, $01
	bankswitch
	pop hl
	ld a, [hl]
	or a
	ret
.copy
	ld c, a
	ld a, [$C3B3]
	cp $80
	ret c
	ld b, a
	add a, c
	jr z, .fits
	ret c
.fits
	ld [$C3B3], a
	ld a, b
	sub $80
	swap a
	ld e, a
	and $0F
	add a, HIGH(VRAM_TILES1)
	ld d, a
	ld a, e
	and $F0
	ld e, a
	inc hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CopyTiles
	ld a, $01
	bankswitch
	ldh a, [hBank1CallIndex]
	or a
	ret

;Copy C whole tiles (C * 16 bytes) from HL to DE through CopyVRAM.	;[ok]
CopyTiles:	;$247D
	ld a, c
	swap a
	ld c, a
	and $0F
	ld b, a
	ld a, c
	and $F0
	ld c, a
	jp CopyVRAM

;Bank $0C tileset for each stage, indexed one-based by LoadStageTiles. Entry 8
;is the unused fourth Wily slot - the alternate Fire Man stage - and it has a
;tileset of its own, Ptr_0C_400E, which nothing else points at.	;[ok]
StageTilesetPtrs:	;$248B
	dw Ptr_00_03B3	;1 Cut Man
	dw Ptr_00_03B5	;2 Ice Man
	dw Ptr_00_03B9	;3 Elec Man
	dw Ptr_00_03B7	;4 Fire Man
	dw Ptr_00_03BB	;5 Wily 1
	dw Ptr_00_03BD	;6 Wily 2
	dw Ptr_00_03BF	;7 Wily 3
	dw Ptr_00_03C1	;8 unused (alternate Fire Man)

;Sprite tiles for each object type, indexed one-based by LoadObjectTiles. Each
;target is a (count, source) record in bank $04 (types 1-$1D) or $07 ($1E-$38).
;56 entries, the same count as ObjectTypeTab.	;[ok]
ObjectTilesetPtrs:	;$249B
	dw Ptr_00_0307, Ptr_00_0309, Ptr_00_030B, Ptr_00_030D	;1-4
	dw Ptr_00_030F, Ptr_00_0311, Ptr_00_0313, Ptr_00_0315	;5-8
	dw Ptr_00_0317, Ptr_00_0319, Ptr_00_031B, Ptr_00_031D	;9-12
	dw Ptr_00_031F, Ptr_00_0321, Ptr_00_0323, Ptr_00_0325	;13-16
	dw Ptr_00_0327, Ptr_00_0329, Ptr_00_032B, Ptr_00_032D	;17-20
	dw Ptr_00_032F, Ptr_00_0331, Ptr_00_0333, Ptr_00_0335	;21-24
	dw Ptr_00_0337, Ptr_00_0337, Ptr_00_0337, Ptr_00_0337	;25-28
	dw Ptr_00_0339	;29 ($1D)
	dw GfxRef_CutMan, GfxRef_BossRollingCutter, GfxRef_IceMan	;30-32 ($1E-), bank $07
	dw GfxRef_BossIceSlasher, GfxRef_ElecMan, GfxRef_ObjType35, GfxRef_FireMan	;33-36
	dw GfxRef_BossFireStorm, GfxRef_Enker, GfxRef_ObjType39, GfxRef_BubbleMan	;37-40
	dw GfxRef_BossBubbleLead, GfxRef_FlashMan, GfxRef_BossRollingCutter, GfxRef_HeatMan	;41-44
	dw GfxRef_BossAtomicFire, GfxRef_QuickMan, GfxRef_BossQuickBoomerang, GfxRef_WilyMachineParts	;45-48
	dw GfxRef_WilyMachineParts, GfxRef_WilyMachineParts, GfxRef_WilyMachineParts, Ptr_00_0307	;49-52
	dw GfxRef_TeleporterLight, GfxRef_TeleporterLight, GfxRef_BossDoor, GfxRef_TeleportSystemSign	;53-56

;Like GetGfxBlock but for a record with a one-byte count (an object tileset's
;tile count): HL = a bank $00 reference, followed as DoubleDeref does to
;(db count, dw source); returns BC = count and HL = source. Four callers in
;LoadStageSelectBosses.	;[ok]
GetGfxBlockShort:	;$250B
	call DoubleDeref
	ld a, [hli]
	ld c, a
	ld b, $00
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

;The graphics loaders' lookup: HL = a bank $00 reference (a GfxRef_ word),
;followed through the bank's own pointer slot (DoubleDeref) to a
;(dw size, dw source) record; returns BC = the size in bytes and HL = the
;source, ready for FuncFill or CopyVRAM. The bank must be paged in.	;[ok]
GetGfxBlock:	;$2516
	call DoubleDeref
	ld a,[hli]
	ld c,a
	ld a,[hli]
	ld b,a
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ret

;HL = [[[HL]]]: one more level than DoubleDeref, for the bank $06/$07 slots
;that point at a pointer (tilemaps, text groups, sprite frames). Also follows a
;song pointer for PlayStage.	;[ok]
TripleDeref:	;$2521
	ld a,[hli]
	ld h,[hl]
	ld l,a
;HL = [[HL]]: follow a bank $00 reference through the pointer it names - a
;GfxRef_ word to the graphics bank's slot and on to its target, a table entry
;to its record. Falls out of TripleDeref.	;[ok]
DoubleDeref:	;$2524
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ret
