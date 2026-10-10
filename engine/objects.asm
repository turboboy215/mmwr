;Mega Man: Dr. Wily's Revenge disassembly - object system
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Object System", ROM0[$252B]

;$252B: run every active object for a frame. Each object's routine is called
;in mode 1 (CallObjectRoutine). If it returns B = 0 the object is simply
;removed; if its hit points (offset $18) are 0 its routine runs again in mode 2
;(killed) and it is removed with an explosion at its position - SpawnDeathExplosion,
;or ExplodeBoss for an object with flag bit 6. Removing takes it off the list at
;$C380, returns its slot (FreeObjectSlot) and sprite handle (FreeSprite), and -
;for an object that came from a spawn record (offset $04 not $FF) - sets the
;record's slot byte back to $FF so it can spawn again. Called by StageFrameLoop.	;[ok]
UpdateObjects:	;$252B
	ld a, [$C398]
	or a
	ret z
	ld b, a
	xor a
	ld [$C3E2], a
.l2535
	ld hl, $C3E2
	ld a, [hl]
	ld l, $98
	cp [hl]
	ret nc
	add a, $80
	ld l, a
	ld a, [hl]
	cp $FF
	ret z
	ld l, $00
	ld h, a
	srl h
	rr l
	srl h
	rr l
	ld de, $C600
	add hl, de
	ld b, $01
	call CallObjectRoutine
	ld c, l
	ld a, $D1
	ld [$D3EB], a
	ld a, b
	or a
	jr z, .l2588
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, .l25E2
	ld a, $11
	add a, c
	ld l, a
	ld a, [hl]
	and $40
	ld [hl], a
	ld l, c
	ld b, $02
	call CallObjectRoutine
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ld [$D3EB], a
	inc l
	ld a, [hl+]
	ld [$D3EC], a
	ld l, c
.l2588
	ld e, l
	ld d, h
	ld hl, $C3E2
	ld a, [hl]
	add a, $80
	ld b, a
	ld l, $98
	dec [hl]
	ld a, [hl]
	add a, $80
	ld l, a
	ld c, [hl]
	push hl
	ld l, b
	ld b, [hl]
	ld [hl], c
	pop hl
	ld [hl], $FF
	call FreeObjectSlot
	ld c, e
	ld h, d
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	call FreeSprite
	ld a, [$CC40]
	ld c, a
	ld a, [$CC41]
	ld h, a
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	cp $FF
	jr z, .l25C9
	ld a, $12
	add a, c
	ld l, a
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, $FF
	inc de
	ld [de], a
.l25C9
	ld a, [$D3EB]
	cp $D1
	jr z, .l25E0
	ld a, $11
	add a, c
	ld l, a
	bit 6, [hl]
	jr z, .l25DD
	call ExplodeBoss
	jr .l25E0
.l25DD
	call SpawnDeathExplosion
.l25E0
	jr .l25E6
.l25E2
	ld hl, $C3E2
	inc [hl]
.l25E6
	jp .l2535

;$25E9: a boss (flag bit 6) has been killed: an explosion burst of $0C at the
;boss position in $CCF2/$CCF3 (SpawnExplosionBurst). In the Wily castle (all
;four robot masters beaten) before all five hub bosses are (wWilyProgress low
;bits not $1F), it also drops a big health pickup (SpawnItem type 2) at the
;boss's X clamped to $18-$88, with lifetime and speeds $FE/$80/$FA.	;[ok]
ExplodeBoss:	;$25E9
	ld a, [$CCF2]
	ld e, a
	ld a, [$CCF3]
	ld d, a
	ld b, $0C
	call SpawnExplosionBurst
	ld a, [wBossesDefeated]
	and $0F
	cp $0F
	ret nz
	ld a, [wWilyProgress]
	and $1F
	cp $1F
	ret z
	ld a, $FE
	ld [$D4B9], a
	ld a, $80
	ld [$D4BA], a
	ld a, $FA
	ld [$D4BB], a
	ld a, [$D3EB]
	cp $18
	jr nc, .l2620
	ld a, $18
	jr .l2626
.l2620
	cp $88
	jr c, .l2626
	ld a, $88
.l2626
	ld [$D3EB], a
	ld b, $02
	jp SpawnItem

;$262E: remove every active object without running it: free each slot on the
;list at $C380 and its sprite handle (offset $10). CheckRoomExits calls it on
;the way into a new room.	;[ok]
ClearAllObjects:	;$262E
	ld a, [$C398]
	or a
	ret z
	ld c, a
	ld hl, $C380
.l2637
	ld b, [hl]
	ld [hl], $FF
	inc hl
	push hl
	call FreeObjectSlot
	ld l, b
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C610
	add hl, de
	ld a, [hl]
	push bc
	call FreeSprite
	pop bc
	pop hl
	dec c
	jr nz, .l2637
	ret

;$2657: set up the objects for a room: reset the spawn-record pointer to
;$C400, UpdateCamera, empty the active list, build the slot free list
;($C399-$C3B0 = 0-23, pointer $C3B1 = $99), copy the spawn list at HL in
;(LoadSpawnList), then find the records inside the spawn window ($D856-$D857)
;and keep the first and the one past the last in $D859/$D85A. Called by
;LoadRoom.	;[ok]
InitStageObjects:	;$2657
	push hl
	ld a, $00
	ld [$C3BE], a
	ld a, $C4
	ld [$C3BF], a
	call UpdateCamera
	xor a
	ld [$C398], a
	ld hl, $C399
	ld b, $18
	xor a
.l266F
	ld [hl+], a
	inc a
	dec b
	jr nz, .l266F
	ld a, $99
	ld [$C3B1], a
	pop hl
	call LoadSpawnList
	ld hl, $C400
	ld c, $00
	ld a, [$D856]
	cp $F0
	jr nc, .l269F
	ld d, a
	ld a, [$C3B2]
	ld b, a
.l268E
	ld a, [hl]
	cp d
	jr nc, .l269F
	ld a, l
	add a, $08
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc c
	ld a, c
	cp b
	jr c, .l268E
.l269F
	ld a, c
	ld [$D859], a
	cp b
	jr nc, .l26BC
	ld a, [$D857]
	ld d, a
.l26AA
	ld a, [hl]
	cp d
	jr nc, .l26BB
	ld a, l
	add a, $08
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc c
	ld a, c
	cp b
	jr c, .l26AA
.l26BB
	ld a, c
.l26BC
	ld [$D85A], a
	ret

;$26C0: copy a room's object spawn list into 8-byte records at $C400, loading
;each type's sprite tiles on the way (LoadObjectTiles; HangNoObjectTiles if
;they do not fit). Input records are (type, x, y, extra), ended by $00; a
;record's second byte starts as $81 when its X is inside the spawn window, else
;0, and its third (the object slot) as $FF. The tile allocator $C3B3 is reset
;to $8B first; $C3B2 counts the records.	;[ok]
LoadSpawnList:	;$26C0
	ld a, $8B
	ld [$C3B3], a
	xor a
	ld [$C3B2], a
.l26C9
	ld a, [hl+]
	or a
	ret z
	ld [$C3B5], a
	push hl
	call LoadObjectTiles
	ld [$C3B4], a
	pop hl
	jp c, HangNoObjectTiles
	ld a, [wStageBank]
	bankswitch
	ld a, [hl+]
	ld b, a
	ld [$C3C0], a
	ld a, [hl+]
	ld [$C3C1], a
	ld a, [hl+]
	ld [$C3C2], a
	push hl
	ld c, $00
	ld hl, $D856
	ld a, b
	cp [hl]
	jr c, .l2700
	inc hl
	cp [hl]
	jr nc, .l2700
	ld c, $81
.l2700
	ld a, c
	ldh [hBank1CallIndex], a
	ld a, [$C3BE]
	ld l, a
	ld a, [$C3BF]
	ld h, a
	ld a, [$C3C0]
	ld [hl+], a
	ldh a, [hBank1CallIndex]
	ld [hl], a
	inc hl
	ld [hl], $FF
	inc hl
	ld a, [$C3B4]
	ld [hl+], a
	ld a, [$C3C1]
	ld [hl+], a
	ld a, [$C3B5]
	ld [hl+], a
	ld a, [$C3C2]
	ld [hl+], a
	inc hl
	ld a, l
	ld [$C3BE], a
	ld a, h
	ld [$C3BF], a
	pop hl
	ld a, [$C3B2]
	inc a
	ld [$C3B2], a
	jr .l26C9

;$2739-$2BC5: five `jr` loops that hang the game on purpose - assertion traps
;for an internal limit being exceeded. One of them is never jumped to.	;[ok]
HangNoFreeSlot:	;$2739
	jr HangNoFreeSlot

;Take an object slot number from the free list at $C399-$C3B2 into B, via the
;pointer at $C3B1. If all 24 are in use it hangs (HangNoFreeSlot). Reachable
;through the stub at $0174.	;[ok]
AllocObjectSlot:	;$273B
	ld a, [$C3B1]
	ld l, a
	ld h, $C3
	ld b, [hl]
	inc a
	cp $B3
	jr nc, HangNoFreeSlot
	ld [$C3B1], a
	ret

;Return slot B to the free list. Reachable through the stub at $0177.	;[ok]
FreeObjectSlot:	;$274B
	ld a, [$C3B1]
	dec a
	ld l, a
	ld h, $C3
	ld [hl], b
	ld [$C3B1], a
	ret

HangTooManyObjects:	;$2757
	jr HangTooManyObjects

;Create an object from the 8-byte spawn record at HL, with A replacing the
;record's byte 2. Builds a 28-byte header in $CC00-$CC1B - routine address and
;bank from ObjectTypeTab; a sprite handle from AllocSprite, sized by the first
;byte of the type's 8-byte record at $34D3 ($40, no sprite, if that is 0); and
;position offsets and the offset $18/$1A/$11/$03 bytes from the same record - allocates a slot ($C600 + slot*$40), copies the header in, zeroes the
;next 11 bytes and runs the object's routine once. Hangs if 24 objects are
;already active (HangTooManyObjects). Returns the slot number. Called at $29FA.	;[ok]
SpawnObject:	;$2759
	push af
	inc hl
	ld a, l
	ld [$CC12], a
	ld a, h
	ld [$CC13], a
	dec hl
	ld de, $CC02
	ld bc, $0008
	call FuncFill
	pop af
	ld [$CC04], a
	ld hl, $C398
	ld a, [hl]
	cp $18
	jr nc, HangTooManyObjects
	inc [hl]
	call AllocObjectSlot
	ld hl, $C398
	ld a, [hl]
	add a, $7F
	ld l, a
	ld [hl], b
	ld a, b
	ld [$C3DE], a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C600
	add hl, de
	ld a, l
	ld [$CC40], a
	ld a, h
	ld [$CC41], a
	ld a, [$CC07]
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld hl, ObjectTypeTab - 4	;types are one-based
	add hl, de
	ld a, [hl+]
	ld [$CC00], a
	ld a, [hl+]
	ld [$CC01], a
	ld a, [hl+]
	ld [$CC1B], a
	xor a
	ld [$CC09], a
	ld a, [$CC02]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	ld [$CC0A], a
	ld a, h
	ld [$CC0B], a
	ld a, [$CC06]
	and $F0
	ld [$CC0F], a
	ld a, [$CC07]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, ObjectStatsTab - 8	;types are one-based
	add hl, de
	ld a, [hl+]
	push hl
	or a
	jr nz, .l27EA
	ld a, $40
	jr .l27ED
.l27EA
	call AllocSprite
.l27ED
	ld [$CC10], a
	ld a, $10
	ld [$CC14], a
	xor a
	ld [$CC17], a
	pop hl
	ld e, [hl]
	inc hl
	ld b, [hl]
	ld d, $00
	bit 7, e
	jr z, .l2804
	dec d
.l2804
	push hl
	ld hl, $CC0A
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	ld hl, $CC0F
	ld a, [hl]
	add a, b
	ld [hl], a
	pop hl
	inc hl
	ld a, [hl+]
	ld [$CC18], a
	xor a
	ld [$CC19], a
	ld a, [hl+]
	ld [$CC1A], a
	ld a, [hl+]
	ld [$CC11], a
	ld a, [hl+]
	ld [$CC03], a
	ld hl, $CC00
	ld a, [$CC40]
	ld e, a
	ld a, [$CC41]
	ld d, a
	ld bc, $001C
	call FuncFill
	ld h, d
	ld l, e
	xor a
	ld bc, $000B
	call FuncMemset
	ld a, [$CC40]
	ld l, a
	ld a, [$CC41]
	ld h, a
	ld b, $00
	call CallObjectRoutine
	ld a, [$C3DE]
	ret

;Run object HL's routine for this frame. Saves the object pointer in $CC40,
;updates its screen X (offset $0D = offset $0A minus the scroll at $D811), pages
;in the object's bank (OBJ_BANK, offset $1B) and jumps to the address held in the
;object's first two bytes, with .handlerReturn pushed as the return address.
;B selects a mode; with B = 1 and the freeze timer at offset $22 running, it
;counts that timer down, sets flag bit 3 and passes B = 3 instead.	;[ok]
CallObjectRoutine:	;$2855
	push hl
	ld a, l
	ld [$CC40], a
	ld a, h
	ld [$CC41], a
	ld c, l
	ld a, $12
	add a, c
	ld l, a
	ld a, [hl+]
	ld e, a
	ld d, [hl]
	ld a, [de]
	ld [$CC44], a
	ld a, $0A
	add a, c
	ld l, a
	ld a, [$D811]
	ld e, a
	ld a, [hl]
	sub e
	ld e, a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld de, .handlerReturn
	push de
	ld l, c
	push hl
	ld a, b
	cp $01
	jr nz, .l289D
	ld a, $22
	add a, c
	ld l, a
	ld a, [hl+]
	ld e, a
	or [hl]
	jr z, .l289D
	ld d, [hl]
	dec de
	ld [hl], d
	dec l
	ld [hl], e
	ld a, $11
	add a, c
	ld l, a
	set 3, [hl]
	ld b, $03
	jr .l28A3
.l289D
	ld a, $11
	add a, c
	ld l, a
	res 3, [hl]
.l28A3
	ld a, $1B
	add a, c
	ld l, a
	ld a, [hl]
	bankswitch
	pop hl
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a
	push de
	ret

;The handler returns here (CallObjectRoutine pushed this address), and the
;object banks $03, $09 and $0D also jump to ObjectHandlerDone directly with A
;set - each has two such jumps, at the same offsets in all three banks. It
;restores the bank, runs the collision pass on the object, and returns B = 0
;when the object is gone or [$CC44] was clear.	;[?]
.handlerReturn	;$28B5
	ld a, $01
ObjectHandlerDone::	;$28B7
	bankswitch
	push bc
	ld a, [$CC40]
	ld c, a
	ld a, [$CC41]
	ld b, a
	call ObjectCollisionPass
	pop bc
	ld a, [$CC40]
	add a, $04
	ld l, a
	ld a, [$CC41]
	ld h, a
	ld a, [hl]
	inc a
	jr z, .l28E0
	ld a, [$CC44]
	or a
	jr nz, .l28E0
	ld b, $00
.l28E0
	pop hl
	ret

;$28E2: when the camera's block column ($D855) differs from last frame's
;($D858), slide the window of spawn records ($D859 up to $D85A) to match the
;spawn window $D856-$D857: records leaving it get their second byte cleared,
;records entering it get $81 (or 1 if it was already set). Then every record in
;the window whose second byte has bit 7 and whose slot is still $FF is spawned
;(SpawnObject) and the slot stored; the second byte becomes 1. Called by
;StageFrameLoop.	;[ok]
UpdateSpawnWindow:	;$28E2
	ld a, [$C3B2]
	or a
	ret z
	ld b, a
	ld hl, $D858
	ld a, [$D855]
	cp [hl]
	jp z, .l29CD
	ld [hl], a
	jr c, .l2958
	ld a, [$D859]
	cp b
	jr nc, .l2922
	ld c, a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C400
	add hl, de
	ld a, [$D856]
	ld e, a
.l290A
	ld a, [hl]
	cp e
	jr nc, .l291E
	inc hl
	ld [hl], $00
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc c
	ld a, c
	cp b
	jr c, .l290A
.l291E
	ld a, c
	ld [$D859], a
.l2922
	ld a, [$D85A]
	cp b
	jr nc, .l2956
	ld c, a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C400
	add hl, de
	ld a, [$D857]
	ld e, a
.l2937
	ld a, [hl]
	cp e
	jr nc, .l2952
	inc hl
	ld a, [hl]
	or a
	ld a, $01
	jr nz, .l2944
	ld a, $81
.l2944
	ld [hl], a
	ld a, l
	add a, $07
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc c
	ld a, c
	cp b
	jr c, .l2937
.l2952
	ld a, c
	ld [$D85A], a
.l2956
	jr .l29CD
.l2958
	ld a, [$D859]
	or a
	jr z, .l2996
	ld c, a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C400
	add hl, de
	ld a, [$D856]
	ld e, a
	ld a, c
	cp b
	jr c, .l2976
	ld a, l
	sub $08
	jr .l2987
.l2976
	ld a, [hl]
	cp e
	jr c, .l2991
	inc hl
	ld a, [hl]
	or a
	ld a, $01
	jr nz, .l2983
	ld a, $81
.l2983
	ld [hl], a
	ld a, l
	sub $09
.l2987
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	dec c
	bit 7, c
	jr z, .l2976
.l2991
	inc c
	ld a, c
	ld [$D859], a
.l2996
	ld a, [$D85A]
	or a
	jr z, .l29CD
	ld c, a
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C400
	add hl, de
	ld a, [$D857]
	ld e, a
	ld a, c
	cp b
	jr c, .l29B4
	ld a, l
	sub $08
	jr .l29BE
.l29B4
	ld a, [hl]
	cp e
	jr c, .l29C8
	inc hl
	ld [hl], $00
	ld a, l
	sub $09
.l29BE
	ld l, a
	ld a, h
	sbc a, $00
	ld h, a
	dec c
	bit 7, c
	jr z, .l29B4
.l29C8
	inc c
	ld a, c
	ld [$D85A], a
.l29CD
	ld a, [$D859]
	ld c, a
	ld a, [$D85A]
	ld b, a
	cp c
	jr z, .l2A12
	ld l, c
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, $C400
	add hl, de
.l29E2
	ld d, [hl]
	inc hl
	ld a, [hl]
	ld [hl], $01
	inc hl
	ld e, a
	or a
	jr nz, .l29EC
.l29EC
	bit 7, e
	jr z, .l2A05
	ld a, [hl]
	cp $FF
	jr nz, .l2A05
	push hl
	push bc
	dec hl
	dec hl
	ld a, c
	call SpawnObject
	pop bc
	pop hl
	ld [hl], a
	ld d, h
	ld a, l
	add a, $04
	ld e, a
.l2A05
	ld a, l
	add a, $06
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	inc c
	ld a, c
	cp b
	jr c, .l29E2
.l2A12
	ret

;Zero $C380-$CDDA: the object lists, spawn records, and all 24 object slots.
;Called at $32FD.	;[ok]
ClearObjectRAM:	;$2A13
	ld hl, $C380
	ld bc, $0A5B
	xor a
	call FuncMemset
	ret

;$2A1E: a weapon has hit object C with D damage; adjust D for the weapon and
;target. A boss (flag bit 6 in $FFB0) goes through ApplyBossDamageTab, which
;ends in ApplyWeaponSideEffects for types the table does not cover; anything
;else falls straight in. Called by the collision pass.	;[ok]
ApplyWeaponToObject:	;$2A1E
	ldh a, [$FFB0]
	bit 6, a
	jp nz, ApplyBossDamageTab

;$2A25: weapon side effects. The Mega Buster against type 3 (Gabyoall) does no
;damage but stops it for $B4 frames (offset $22, the freeze timer); otherwise
;on to TryIceSlasherFreeze.	;[ok]
ApplyWeaponSideEffects:	;$2A25
	ld a, [wCurrentWeapon]
	ld e, a
	cp $00
	jr nz, TryIceSlasherFreeze
	ld a, $07
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jr nz, TryIceSlasherFreeze
	ld a, $22
	add a, c
	ld l, a
	ld [hl], $B4
	jr TryIceSlasherFreeze.l2A51

;$2A3E: Ice Slasher freezes the object: offset $22-$23 = $0138 (312 frames) and
;$C236 = 1, with no damage (D = 0). The timer is what CallObjectRoutine counts
;down. Banks $03 and $0D appear to call it too (`call z` byte patterns at
;four sites, not yet confirmed as code).	;[ok]
TryIceSlasherFreeze:	;$2A3E
	ld a, e
	cp $03
	jr nz, .l2A53
	ld a, $22
	add a, c
	ld l, a
	ld [hl], $38
	inc l
	ld [hl], $01
	ld a, $01
	ld [$C236], a
.l2A51
	ld d, $00
.l2A53
	ret

HangHitboxListFull:	;$2A54
	jr HangHitboxListFull

;$2A56: one object's collision pass, run after its routine (object C, high
;byte B). Skipped while wFreezeFlags has any bit but 0 and 3 set, or when flag
;bits 0-1 are both clear. Its hitbox is the first four bytes of its current
;frame (OBJ_FRAMES, offset $15, indexed by OBJ_FRAME, offset $17) added to its
;screen position. By the flag bits ($FFB0): bit 1 adds the box to the solid-box
;list at $DF00 (HangHitboxListFull past $40 bytes); bit 0 - unless the boss is
;beaten ($CCF5) - tests it against Mega Man's box (HurtPlayerByObject, unless
;damage is already waiting in $D838) and otherwise, unless bit 7 or $DF94, against
;his shots (CheckShotHit, ApplyWeaponToObject, damage off offset $18, sound $09
;and the hit flash). Then HitboxViewerCheck and DrawObjectSprite.	;[ok]
ObjectCollisionPass:	;$2A56
	ld h, b
	ld a, [wCurrentBank]
	push af
	ld a, $1B
	add a, c
	ld l, a
	ld a, [hl]
	bankswitch
	ld a, $15
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push de
	push bc
	inc l
	ld a, [hl]
	add a, a
	add a, e
	ld l, a
	ld a, d
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld [$CE53], a
	ld a, [hl]
	ld [$CE54], a
	ld h, b
	ld a, $11
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFB0], a
	ld e, a
	ld a, [wFreezeFlags]
	and $F6
	jp nz, .l2B8C
	ld a, e
	and $03
	jp z, .l2B8C
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, [$CE53]
	ld l, a
	ld a, [$CE54]
	ld h, a
	ld a, [hl+]
	add a, e
	cp $D0
	jr c, .l2AAE
	xor a
.l2AAE
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	add a, e
	cp $D0
	jr c, .l2AB7
	xor a
.l2AB7
	ldh [$FF92], a
	ld e, a
	ld a, [hl+]
	add a, d
	ldh [$FF93], a
	ld a, [hl+]
	add a, d
	ldh [$FF94], a
	ld d, a
	ld h, b
	ldh a, [$FFB0]
	bit 1, a
	jr z, .l2AEB
	push hl
	push de
	ld de, $DF00
	ld a, [de]
	ld e, a
	ld hl, hBank1CallIndex
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, e
	cp $41
	jp nc, HangHitboxListFull
	ld [$DF00], a
	pop de
	pop hl
.l2AEB
	ldh a, [$FFB0]
	bit 0, a
	jp z, .l2B7D
	ld a, [$CCF5]
	or a
	jp nz, .l2B7D
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC46], a
	ldh a, [hBank1CallIndex]
	ld c, a
	ldh a, [$FF93]
	ld b, a
	ld hl, $D838
	ld a, [hl+]
	or [hl]
	jr nz, .l2B2A
	ld hl, $D841
	ld a, e
	cp [hl]
	jr c, .l2B2A
	inc hl
	ld a, c
	cp [hl]
	jr nc, .l2B2A
	inc hl
	ld a, d
	cp [hl]
	jr c, .l2B2A
	inc hl
	ld a, b
	cp [hl]
	jr nc, .l2B2A
	pop bc
	call HurtPlayerByObject
	jr .l2B8D
.l2B2A
	ldh a, [$FFB0]
	bit 7, a
	jp nz, .l2B7D
	ld a, [$DF94]
	or a
	jr nz, .l2B7D
	call CheckShotHit
	jr z, .l2B7D
	pop bc
	push bc
	ld h, b
	ld d, a
	ld a, $19
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, .l2B7D
	ld a, $20
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, .l2B7D
	call ApplyWeaponToObject
	pop bc
	ld h, b
	ld a, d
	or a
	jr z, .l2B7C
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	jr nc, .l2B64
	xor a
.l2B64
	ld [hl], a
	jr z, .l2B8D
	ld a, [$C236]
	or a
	jr z, .l2B7C
	ld a, $09
	call QueueSound
	ld a, $03
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $20
	add a, c
	ld l, a
	ld [hl], e
.l2B7C
	push bc
.l2B7D
	ldh a, [hBank1CallIndex]
	ld e, a
	ldh a, [$FF92]
	ld l, a
	ldh a, [$FF93]
	ld d, a
	ldh a, [$FF94]
	ld h, a
	call HitboxViewerCheck
.l2B8C
	pop bc
.l2B8D
	pop de
	call DrawObjectSprite
	pop af
	bankswitch
	ret

;$2B99 / $2BA0: something touched Mega Man. Adds its damage to $D838 (damage
;waiting to be taken) and sets the knockback speed $D834-$D835 to +$30 or -$30,
;away from the toucher's X in E. HurtPlayerByShot takes the damage from an
;enemy shot's offset $0A (UpdateEnemyShot), HurtPlayerByObject from an object's
;offset $1A (the collision pass).	;[ok]
HurtPlayerByShot:	;$2B99
	push bc
	ld a, $0A
	add a, c
	ld l, a
	jr HurtPlayerByObject.l2BA6

HurtPlayerByObject:	;$2BA0
	push bc
	ld h, b
	ld a, $1A
	add a, c
	ld l, a
.l2BA6
	ld d, [hl]
	ld a, [$D838]
	add a, d
	ld [$D838], a
	ld a, [wPlayerX]
	cp e
	ld de, $0030
	jr nc, .l2BBA
	ld de, $FFD0
.l2BBA
	ld hl, $D834
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl], a
	pop bc
	ret

HangNoObjectTiles:	;$2BC3
	jr HangNoObjectTiles

HangUnused:	;$2BC5
	jr HangUnused
