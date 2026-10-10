;Mega Man: Dr. Wily's Revenge disassembly - item pickups and the meter refill
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Items", ROMX[$5411], BANK[$1]

;$5411: LoadObjectTiles type for item types 1-5 (indexed from $5410).	;[ok]
ItemTilesets:	;$5411
	db $04, $04, $01, $04, $01

;Item slots, $D400 page: ten $10-byte records from $D417, a free list at
;$D40C (pointer $D416) and the live list from $D400 (count $D40B).	;[ok]
InitItems:	;$5416
	ld hl, $D40C
	ld a, l
	ld [$D416], a
	ld b, $0A
	ld a, $17
.l5421
	ld [hl+], a
	add a, $10
	dec b
	jr nz, .l5421
	xor a
	ld [$D40B], a
	ret

;Once per game ($DFD4): start the placed-item list empty.	;[ok]
InitPlacedItems:	;$542C
	ld hl, $DFD4
	ld a, [hl]
	or a
	jr nz, ResetPlacedItems
	dec [hl]
	ld a, $C3
	ld [$D4C2], a
	ret

;Forget placed items that were spawned but not collected (state 1), so they
;come back; collected ones (state 2) stay gone.	;[ok]
ResetPlacedItems:	;$543A
	ld a, [$D4C2]
	ld b, a
	ld hl, $D4C5
.l5441
	ld a, l
	cp b
	ret nc
	ld a, [hl]
	cp $02
	jr z, .l544B
	ld [hl], $00
.l544B
	inc l
	inc l
	inc l
	jr .l5441

;Object type 8's routine (ObjectTypeTab points here, bank $01). Only the
;spawn call (B = 0) does anything: it turns the object into an item pickup
;(SpawnPlacedItem) and ends with B = 0, which removes the object.	;[ok]
PlacedItemRoutine:	;$5450
	dec b
	jr z, .l548A
	dec b
	jr z, .l548A
	dec b
	jr z, .l548A
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $0A
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ldh [hBank1CallIndex], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FF92], a
	ld a, $02
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	ld d, a
	and $0F
	ldh [$FF93], a
	ld a, d
	and $F0
	ld d, a
	ld a, [wRoomID]
	and $0F
	or d
	ld d, a
	call SpawnPlacedItem
.l548A
	ld b, $00
	ret

;Spawn a placed item unless the placed-item list ($D4C3, 3 bytes per item:
;position, state) says it was already taken. Its type comes from
;PlacedItemTypes.	;[ok]
SpawnPlacedItem:	;$548D
	call FindPlacedItem
	jr nc, .l54A6
	ld a, [$D4C2]
	cp $F3
.l5497
	jr nc, .l5497
	ld [hl], e
	inc l
	ld [hl], d
	inc l
	ld [hl], $01
	inc l
	ld a, l
	ld [$D4C2], a
	jr .l54AA
.l54A6
	ld a, [hl]
	or a
	ret nz
	inc [hl]
.l54AA
	ldh a, [hBank1CallIndex]
	ld b, a
	ld a, [$D850]
	add a, b
	ld [$D3EB], a
	ldh a, [$FF93]
	ld b, a
	dec a
	add a, LOW(PlacedItemTypes)
	ld l, a
	ld a, HIGH(PlacedItemTypes)
	adc a, $00
	ld h, a
	ldh a, [$FF92]
	add a, [hl]
	ld [$D3EC], a
	ld a, $FF
	ld [$D4B9], a
	ld a, $00
	ld [$D4BA], a
	ld a, $00
	ld [$D4BB], a
	call SpawnItem
	ret

PlacedItemTypes:	;$54D9
	db $01, $02, $06, $03, $06

;Mark placed item DE as collected (B != 0) or not yet spawned.	;[ok]
SetPlacedItemState:	;$54DE
	push bc
	call FindPlacedItem
	pop bc
	ret c
	ld a, b
	or a
	ld d, $00
	jr z, .l54EC
	ld d, $02
.l54EC
	ld [hl], d
	ret

;Find placed item DE in the list; carry if absent, else HL at its state.	;[ok]
FindPlacedItem:	;$54EE
	ld a, [$D4C2]
	ld b, a
	ld hl, $D4C3
.l54F5
	ld a, l
	cp b
	jr nc, .l5507
	ld a, [hl+]
	cp e
	jr nz, .l5503
	ld a, [hl+]
	cp d
	jr nz, .l5504
	or a
	ret
.l5503
	inc l
.l5504
	inc l
	jr .l54F5
.l5507
	scf
	ret

;An enemy died: maybe drop an item. One roll of FuncRNG: below $9A nothing;
;$9A extra life; $9B-$9D big health; $9E-$B5 small health; $B6-$BF big energy;
;$C0 and up small energy. Drops pop upwards and vanish after $FE frames.	;[ok]
RollItemDrop:	;$5509
	ld a, [$D40B]
	cp $0A
	ret nc
	call FuncRNG
	cp $9A
	ret c
	ld b, $01
	cp $9B
	jr c, .l552B
	inc b
	cp $9E
	jr c, .l552B
	inc b
	cp $B6
	jr c, .l552B
	inc b
	cp $C0
	jr c, .l552B
	inc b
.l552B
	ld a, $FE
	ld [$D4B9], a
	ld a, $60
	ld [$D4BA], a
	ld a, $FC
	ld [$D4BB], a

;Spawn an item of type B at ($D3EB, $D3EC) with the lifetime and speeds in
;$D4B9-$D4BB.	;[ok]
SpawnItem:	;$553A
	ld a, e
	ld [$D4BC], a
	ld a, d
	ld [$D4BD], a
	ld a, b
	ld [$D4B7], a
	ld a, [$D3EB]
	ld e, a
	ld a, [$D3EC]
	ld d, a
	ld a, [$D4B7]
	call SetItemBox
	ld a, [$D4B9]
	cp $FF
	jr z, .l557F
	ldh a, [$FF9A]
	ld e, a
	ldh a, [$FF9C]
	call CheckSolidAt
	ret c
	ldh a, [$FF9B]
	ld e, a
	ldh a, [$FF9C]
	call CheckSolidAt
	ret c
	ldh a, [$FF9A]
	ld e, a
	ldh a, [$FF9D]
	call CheckSolidAt
	ret c
	ldh a, [$FF9B]
	ld e, a
	ldh a, [$FF9D]
	call CheckSolidAt
	ret c
.l557F
	ld a, [$D280]
	cp $80
	ret nc
	ld h, $D4
	ld a, [$D416]
	ld l, a
	inc a
	ld [$D416], a
	ld c, [hl]
	ld l, $0B
	ld a, [hl]
	inc [hl]
	ld l, a
	ld [hl], c
	ld a, [$D4B7]
	ld e, a
	ld d, $00
	ld hl, ItemTilesets - 1
	add hl, de
	ld a, [hl]
	push bc
	call AllocSprite
	pop bc
	ld [$D28A], a
	ld h, $D4
	ld l, c
	ld a, [$D4B9]
	ld [hl], a
	inc l
	ld b, $00
	ld [hl], b
	inc l
	ld [hl], b
	inc l
	ld [hl], b
	inc l
	ld a, [$D3EB]
	ld [hl+], a
	ld a, [$D4BA]
	ld [hl+], a
	ld [hl], b
	inc l
	ld a, [$D4BB]
	ld [hl+], a
	ld a, [$D3EC]
	ld [hl+], a
	ld a, [$D4B7]
	ld [hl+], a
	ld a, [$D28A]
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl], b
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$D4BC]
	ld [hl], a
	inc l
	ld a, [$D4BD]
	ld [hl], a
	ret

;Every frame: run the refill if one is going, then move, draw and expire the
;items, collecting those Mega Man touches.	;[ok]
UpdateItems:	;$55E4
	ld a, [wFreezeFlags]
	bit 1, a
	call nz, RefillTick
	ld e, $00
	ld a, [wHurtTimer]
	cp $5A
	jr nc, .l55FC
	ld a, [$D838]
	or a
	jr nz, .l55FC
	inc e
.l55FC
	ld a, e
	ld [$D4B8], a
	ld hl, $D40B
	ld a, [hl]
	or a
	ret z
	ld b, a
	ld l, $00
.l5609
	ld h, $D4
	ld a, [hl+]
	ld c, l
	push bc
	ld l, a
	call UpdateItem
	ld a, b
	or a
	jr nz, .l5635
	pop bc
	dec c
	push bc
	ld l, $0B
	dec [hl]
	ld l, [hl]
	ld a, [hl]
	ld l, c
	ld b, [hl]
	ld [hl], a
	ld a, [$D416]
	dec a
	ld l, a
	ld [hl], b
	ld [$D416], a
	ld l, c
	push hl
	ld a, $0A
	add a, b
	ld l, a
	ld a, [hl]
	call FreeSprite
	pop hl
.l5635
	pop bc
	ld l, c
	dec b
	jr nz, .l5609
	ret

;Item at L: count down its lifetime ($FF = a placed item, which never
;expires or falls), fall and land, draw it - alternating its two frames on bit
;3 of $DF86 - and collect it if it touches Mega Man. B = 0 when it should
;go.	;[ok]
UpdateItem:	;$563B
	ld c, l
	ld a, [wFreezeFlags]
	and $03
	jp nz, .l566F
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, .l5651
	dec [hl]
	jp z, RemoveItem
.l5651
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA0], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA1], a
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, .l566F
	ld a, $05
	add a, c
	ld l, a
	call ApplyItemGravity
.l566F
	ld a, $04
	add a, c
	ld l, a
	ld a, [$D851]
	add a, [hl]
	ld [hl], a
	ld e, a
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	call SetItemBox
	ld h, $D4
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, .l5696
	push bc
	call CheckItemAgainstStage
	pop bc
.l5696
	ldh a, [$FFA2]
	ld e, a
	ldh a, [$FFA3]
	ld d, a
	ld a, e
	cp $E0
	jr nc, .l56A6
	cp $B0
	jp nc, ItemLeftScreen
.l56A6
	ld a, d
	cp $F0
	jr nc, .l56B0
	cp $88
	jp nc, ItemLeftScreen
.l56B0
	ld a, [$D4B8]
	or a
	jr z, .l56DE
	ld a, [wFreezeFlags]
	bit 1, a
	jr nz, .l56DE
	ld hl, $D841
	ldh a, [$FF9B]
	cp [hl]
	jr c, .l56DE
	inc hl
	ldh a, [$FF9A]
	cp [hl]
	jr nc, .l56DE
	inc hl
	ldh a, [$FF9D]
	cp [hl]
	jr c, .l56DE
	inc hl
	ldh a, [$FF9C]
	cp [hl]
	jr nc, .l56DE
	ld h, $D4
	call CollectItem
	jr ItemCollected
.l56DE
	ld h, $D4
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	ld l, e
	ld h, d
	call HitboxViewerCheck
	ld a, $10
	ld [$D3EA], a
	ld a, $80
	ld [$CE55], a
	ld h, $D4
	ld a, $0A
	add a, c
	ld l, a
	ld a, [hl]
	push af
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	ld e, a
	ld a, [$DF86]
	rrca
	rrca
	rrca
	and $01
	add a, e
	add a, a
	ld e, a
	ld d, $00
	ld hl, ItemFrames - 4
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $0004
	add hl, de
	pop af
	call DrawMetasprite
	ld h, $D4
	ld b, $01
	ret

;$5729: three bytes after UpdateItem's `ret` that nothing reaches - a `jr`
;back to $5726 and a $00.	;[ok]
Unused_01_5729:	;$5729
	db $18, $FB, $00

;UpdateItem's exits: the item left the screen (B = 0) or was collected
;(B = 1). A placed item's list entry is updated to match, then the item goes.	;[ok]
ItemLeftScreen:	;$572C
	ld b, $00
	jr EndItem

;Collected: B = 1.	;[ok]
ItemCollected:	;$5730
	ld b, $01

;Common exit: a placed item's list entry follows B, then the item goes.	;[ok]
EndItem:	;$5732
	ld h, $D4
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	cp $FF
	jr nz, RemoveItem
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push bc
	call SetPlacedItemState
	pop bc

;Remove the item: B = 0.	;[ok]
RemoveItem:	;$5749
	ld h, $D4
	ld b, $00
	ret

;Collect item C: type 1 is an extra life (sound $10, at most 9 shown), 2 and 3
;health (10 or 2 points), 4 and 5 weapon energy (10 or 2, none for the buster).
;Energy is given out by RefillStep, one point at a time.	;[ok]
CollectItem:	;$574E
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l5761
	dec a
	jr z, .l5773
	dec a
	jr z, .l5777
	dec a
	jr z, .l577E
	jr .l5782
.l5761
	ld a, $10
	call QueueSound
	ld hl, wLives
	ld a, [hl]
	inc a
	cp $0A
	jr c, .l5771
	ld a, $0A
.l5771
	ld [hl], a
	ret
.l5773
	ld d, $0A
	jr .l5779
.l5777
	ld d, $02
.l5779
	ld hl, wEnergy
	jr .l578E
.l577E
	ld d, $0A
	jr .l5784
.l5782
	ld d, $02
.l5784
	ld a, [wCurrentWeapon]
	or a
	ret z
	add a, $A3
	ld l, a
	ld h, $DF
.l578E
	ld a, d
	ld [$D4C1], a
	ld a, l
	ld [$D4BF], a
	ld a, h
	ld [$D4C0], a
	ld hl, wFreezeFlags
	set 1, [hl]
	jr RefillStep

;Every 4th frame while wFreezeFlags bit 1 is set, give one more point.	;[ok]
RefillTick:	;$57A1
	ld hl, $D4BE
	inc [hl]
	ld a, [hl]
	cp $04
	ret c
	xor a
	ld [hl], a

;One point: $D4C1 points left, $D4BF/$D4C0 the meter. Each point adds 8 and
;plays sound $12, up to $98; then wFreezeFlags bit 1 is cleared.	;[ok]
RefillStep:	;$57AB
	ld hl, $D4C1
	ld a, [hl]
	or a
	jr z, .l57CF
	dec [hl]
	ld a, [$D4BF]
	ld l, a
	ld a, [$D4C0]
	ld h, a
	ld a, [hl]
	cp $98
	jr nc, .l57CF
	ld a, $12
	call QueueSound
	ld a, $08
	add a, [hl]
	ld [hl], a
	cp $98
	ret c
	ld [hl], $98
	ret
.l57CF
	ld hl, wFreezeFlags
	res 1, [hl]
	ret

;Free every item and its sprite.	;[ok]
FreeAllItems:	;$57D5
	ld hl, $D40B
	ld a, [hl]
	or a
	ret z
	ld [hl], $00
	ld b, a
	ld l, $00
.l57E0
	ld a, [hl+]
	ld c, l
	push bc
	add a, $0A
	ld l, a
	ld a, [hl]
	call FreeSprite
	ld h, $D4
	pop bc
	ld l, c
	dec b
	jr nz, .l57E0
	ret

;The item's box around (E, D) into $FF9A-$FF9D: -4..+2 for the small ones
;(types 3 and 5), -8..+6 for the others.	;[ok]
SetItemBox:	;$57F2
	push bc
	ld b, a
	ld a, e
	ldh [$FFA2], a
	ld a, d
	ldh [$FFA3], a
	ld a, b
	ld de, $02FC
	ld bc, $02FC
	cp $03
	jr z, .l580F
	cp $05
	jr z, .l580F
	ld de, $06F8
	ld bc, $06F8
.l580F
	ld hl, $FF9A
	ldh a, [$FFA2]
	add a, e
	ld [hl+], a
	ldh a, [$FFA2]
	add a, d
	ld [hl+], a
	ldh a, [$FFA3]
	add a, c
	ld [hl+], a
	ldh a, [$FFA3]
	add a, b
	ld [hl+], a
	pop bc
	ret

;Item against the stage: rising into a ceiling stops it; falling into the floor
;pushes it back up out of the block and marks it landed (offset $0C).	;[ok]
CheckItemAgainstStage:	;$5824
	ld a, $07
	add a, c
	ld l, a
	bit 7, [hl]
	jr z, .l5850
	ldh a, [$FF9A]
	ld e, a
	ldh a, [$FF9C]
	call CheckItemTile
	jr c, .l583F
	ldh a, [$FF9B]
	ld e, a
	ldh a, [$FF9C]
	call CheckItemTile
	ret nc
.l583F
	ld a, $05
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	ldh a, [$FFA0]
	ld [hl+], a
	ld [hl], $00
	inc l
	ldh a, [$FFA1]
	ld [hl], a
	ret
.l5850
	ldh a, [$FF9A]
	ld e, a
	ld b, a
	ldh a, [$FF9D]
	inc a
	call CheckItemTile
	jr c, .l5867
	ldh a, [$FF9B]
	ld b, a
	ld e, a
	ldh a, [$FF9D]
	inc a
	call CheckItemTile
	ret nc
.l5867
	push bc
	ldh a, [$FF9D]
	ld c, a
.l586B
	ld e, b
	ld a, c
	call CheckItemTile
	jr nc, .l5875
	dec c
	jr .l586B
.l5875
	ldh a, [$FF9D]
	sub c
	ld d, a
	pop bc
	ld h, $D4
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld [hl], a
	ldh a, [$FFA3]
	sub d
	ldh [$FFA3], a
	ld a, $0C
	add a, c
	ld l, a
	ld [hl], $01
	ret

;CheckSolidAt, keeping B and C and leaving H = $D4.	;[ok]
CheckItemTile:	;$588F
	push bc
	call CheckSolidAt
	pop bc
	ld h, $D4
	ret

;Item gravity: Y speed += $34, capped at $0340, then add it to Y.	;[ok]
ApplyItemGravity:	;$5897
	ld a, [hl+]
	add a, $34
	ld e, a
	inc l
	ld a, [hl]
	adc a, $00
	ld d, a
	bit 7, a
	jr nz, .l58AF
	ld a, e
	sub $41
	ld a, d
	sbc a, $03
	jr c, .l58AF
	ld de, $0340
.l58AF
	ld [hl], d
	dec l
	dec l
	ld [hl], e
	inc l
	ld a, [hl]
	add a, e
	ld [hl+], a
	inc l
	ld a, [hl]
	adc a, d
	ld [hl], a
	ret

;Item frames: two per type (they alternate), types 1-5, indexed from $58B8.
;The first frame, a lone tile, is not in the table.	;[ok]
ItemFrames:	;$58BC
	dw ItemFrameExtraLife, ItemFrameExtraLife, ItemFrameBigHealth1, ItemFrameBigHealth2
	dw ItemFrameSmallHealth1, ItemFrameSmallHealth2, ItemFrameBigEnergy1, ItemFrameBigEnergy2
	dw ItemFrameSmallEnergy1, ItemFrameSmallEnergy2

ItemFrameUnused:	;$58D0
	db $00, $00, $00, $00	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

ItemFrameExtraLife:	;$58D9
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $01, $81, $02, $82
	db $80

ItemFrameSmallEnergy1:	;$58E5
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $03
	db $80

ItemFrameSmallEnergy2:	;$58EE
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $04
	db $80

ItemFrameSmallHealth1:	;$58F7
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $05
	db $80

ItemFrameSmallHealth2:	;$5900
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $06
	db $80

ItemFrameBigEnergy1:	;$5909
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $07, $87, $47, $C7
	db $80

ItemFrameBigEnergy2:	;$5915
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $09, $89, $49, $C9
	db $80

ItemFrameBigHealth1:	;$5921
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $08, $88, $48, $C8
	db $80

ItemFrameBigHealth2:	;$592D
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $0A, $8A, $4A, $CA
	db $80
