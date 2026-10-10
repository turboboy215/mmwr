;Mega Man: Dr. Wily's Revenge disassembly - sprite system
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Sprite System", ROM0[$2BC7]

;$2BC7: set up the sprite system's tables (described below): the OAM pool
;$CE28-$CE4F (0-$27) with its pointer $CE50 = $36 - 26 entries pooled, 14 kept
;out; the OAM offset tables $CF00 and $CF28 (0, 4, ... $9C), $CF50 (14
;ascending) and $CF5E-$CF77 (26 descending, $9C down to $38) that
;BeginSpriteFrame picks between; $CE58 = 0; the handle pool $D240 (0-$3F) and
;its pointer $D280 = $40; empty holder and waiting lists ($D281-$D289 = $FE);
;and $D100, handle -> record offset (0, 2, 4 ...). Called by LoadRoom. Banks
;$0C and $0E have variants.	;[ok]
InitSpriteSystem:	;$2BC7
	ld hl, $CE28
	ld b, $28
	xor a
.l2BCD
	ld [hl+], a
	inc a
	dec b
	jr nz, .l2BCD
	ld a, $36
	ld [$CE50], a
	ld hl, $CF00
	ld b, $28
	xor a
.l2BDD
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l2BDD
	ld hl, $CF28
	ld b, $28
	xor a
.l2BE9
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l2BE9
	ld hl, $CF50
	ld b, $0E
	xor a
.l2BF5
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l2BF5
	ld hl, $CF77
	ld b, $1A
	ld a, $38
.l2C02
	ld [hl-], a
	add a, $04
	dec b
	jr nz, .l2C02
	xor a
	ld [$CE58], a
	ld hl, $D240
	ld b, $40
	xor a
.l2C12
	ld [hl+], a
	inc a
	dec b
	jr nz, .l2C12
	ld a, $40
	ld [$D280], a
	ld a, $FE
	ld hl, $D281
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld hl, $D100
	ld b, $40
	xor a
.l2C30
	ld [hl+], a
	add a, $02
	dec b
	jr nz, .l2C30
	ret


;Start a frame's sprites. RotateSpriteOAM first; then the 26 pooled entries'
;OAM offsets ($CF0E-$CF27) are refilled in ascending OAM order on frames where
;$DF86 is odd and descending on even ones, so overlapping sprites take turns at
;priority, and each of those OAM entries is hidden (Y = $A0) to be drawn
;afresh. With $CE58 set (Mega Man's death burst takes every entry) all 40
;($CF00-$CF27) are refilled and hidden: from $CF28 (ascending) or from $CF50
;(the 14 normally kept out ascending, then the 26 descending). Called every stage frame by
;DelayFrameWithSprites, and by the ending through JumpBeginSpriteFrame.	;[ok]
BeginSpriteFrame:	;$2C37
	call RotateSpriteOAM
	ld a,[$DF86]
	bit 0,a
	ld de,$CF36
	jr nz,.next
	ld de,$CF5E
.next
	ld b,$1A
	ld c,$E
	ld a,[$CE58]
	or a
	jr z,.next2
	ld b,$28
	ld c,0
	ld hl,-14		;not an address: DE -= 14
	add hl,de
	ld e,l
	ld d,h
.next2
	ld h,$CF
	ld l,c
	ld a,[de]
	inc e
	ld [hl],a
	ld h,$C0
	ld l,a
	ld [hl],$A0
	inc c
	dec b
	jr nz,.next2
	ret

;$2C6B-$2F7F: the sprite system. Objects do not own OAM entries directly. Each
;holds a sprite handle (0-$3F; $40 means none) from AllocSprite, and each handle
;owns a chain of OAM entries taken from a pool. When the pool runs dry, a sprite
;waits, and RotateSpriteOAM moves entries round-robin from the oldest holders to
;the waiting sprites every frame - the game's sprite flicker. Hang traps stop the
;game if the bookkeeping is ever inconsistent.	;[ok]
;Tables: $D100 handle -> record offset; $D000+ records (OAM count, chain head);
;$D240 handle pool with pointer $D280; holder list head/tail $D281/$D282,
;waiting list $D284/$D285, links at $D2xx; OAM pool $CE28-$CE4F with pointer
;$CE50 (26 entries pooled at start, 14 kept out), links $CExx, OAM offsets $CFxx.
;Set up by InitSpriteSystem.	;[?]

;Draw object C (high byte B) with its sprite handle (offset $10), if flag bit 2
;is set. Builds the attribute byte in $D3EA from the flags - palette flashing
;while the offset-$20 counter runs, palette by bit 3, bit 4 -> attribute bit 7 -
;sets the tile base from offset $05 and the position from offsets $0D/$0F, and
;calls DrawMetasprite on the current frame's data. Called at the end of the
;collision pass.	;[?]
DrawObjectSprite:	;$2C6B
	push bc
	ld h, b
	ld a, $11
	add a, c
	ld l, a
	ld e, [hl]
	bit 2, e
	jr z, .l2CD3
	ld a, $20
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l2C89
	dec [hl]
	swap a
	srl a
	and $10
	xor $10
	jr .l2C90
.l2C89
	ld a, $10
	bit 3, e
	jr z, .l2C90
	xor a
.l2C90
	bit 4, e
	jr z, .l2C96
	set 7, a
.l2C96
	ld d, a
	ld a, [$D3ED]
	and $80
	or d
	ld [$D3EA], a
	xor a
	bit 5, e
	jr z, .l2CA7
	ld a, $01
.l2CA7
	ld [$CE57], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA2], a
	inc l
	inc l
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $10
	add a, c
	ld l, a
	ld e, [hl]
	ld a, [$CE53]
	add a, $04
	ld l, a
	ld a, [$CE54]
	adc a, $00
	ld h, a
	ld a, e
	call DrawMetasprite
.l2CD3
	pop bc
	ld h, b
	ret

;Like DrawMetasprite but the data at HL is only the (dx, dy, tile) list - no
;header and no grid - drawn at the position already in $FFA4/$FFA5.	;[ok]
DrawMetaspriteList:	;$2CD6
	cp $40
	jp nc, DrawMetasprite.l2DF5
	ld e, a
	ld d, $D1
	ld a, [de]
	ld e, a
	dec d
	inc e
	ld a, [de]
	cp $FE
	jp z, DrawMetasprite.l2DF5
	ldh [$FF99], a
	push bc
	ld e, l
	ld d, h
	jp DrawMetasprite.l2D95

;Write sprite handle A's OAM entries for the metasprite at HL. Format:
;  db dx, dy		;added to $FFA2 + 8 (X) and $FFA3 + $10 (Y)
;  db cols << 4 | rows	;a grid of tile bytes follows, $FF = gap
;  ...
;  db dx, dy, tile ...	;then free-placed tiles, ended by $80
;Tile bytes: bits 0-5 (0-6 if $CE57 is set) are added to the base in $CE55;
;bit 7 sets X flip and bit 6 Y flip on top of $D3EA. Stops early when the
;handle's OAM chain runs out. Handles $40 and up, and handles with no chain,
;draw nothing. Clears $CE57 on the way out.	;[ok]
DrawMetasprite:	;$2CF0
	cp $40
	jp nc, .l2DF5
	ld e, a
	ld d, $D1
	ld a, [de]
	ld e, a
	dec d
	inc e
	ld a, [de]
	cp $FE
	jp z, .l2DF5
	ldh [$FF99], a
	ldh a, [$FFA2]
	add a, [hl]
	add a, $08
	ldh [$FFA4], a
	inc hl
	ldh a, [$FFA3]
	add a, [hl]
	add a, $10
	ldh [$FFA5], a
	ldh [$FF92], a
	inc hl
	push bc
	ld a, [hl+]
	ld b, a
	swap a
	and $0F
	ld c, a
	ld a, b
	and $0F
	ld b, a
	or c
	jp z, .l2DF4
	ld e, l
	ld d, h
.l2D28
	push bc
	ldh a, [$FFA4]
	ldh [hBank1CallIndex], a
.l2D2D
	ldh a, [$FF99]
	cp $FE
	jp z, .l2DF3
	ld l, a
	ld a, [de]
	cp $FF
	jr z, .l2D81
	push de
	ld d, a
	ld h, $CE
	ld a, [hl]
	ldh [$FF99], a
	ld h, $CF
	ld l, [hl]
	ld h, $C0
	ldh a, [$FF92]
	ld [hl+], a
	ldh a, [hBank1CallIndex]
	ld [hl+], a
	ld a, [$CE57]
	and $01
	jr nz, .l2D6D
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l2D65
	set 5, a
.l2D65
	bit 6, d
	jr z, .l2D7F
	set 6, a
	jr .l2D7F
.l2D6D
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l2D7F
	set 5, a
.l2D7F
	ld [hl+], a
	pop de
.l2D81
	inc de
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec c
	jr nz, .l2D2D
	ldh a, [$FF92]
	add a, $08
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, .l2D28
.l2D95
	ldh a, [$FF99]
	cp $FE
	jr z, .l2DF4
	ld l, a
	ld a, [de]
	cp $80
	jr z, .l2DF4
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	ld a, [de]
	inc de
	push de
	ld d, a
	ld h, $CE
	ld a, [hl]
	ldh [$FF99], a
	ld h, $CF
	ld l, [hl]
	ld h, $C0
	ldh a, [$FFA5]
	add a, b
	ld [hl+], a
	ldh a, [$FFA4]
	add a, c
	ld [hl+], a
	ld a, [$CE57]
	and $01
	jr nz, .l2DDD
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l2DD5
	set 5, a
.l2DD5
	bit 6, d
	jr z, .l2DEF
	set 6, a
	jr .l2DEF
.l2DDD
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l2DEF
	set 5, a
.l2DEF
	ld [hl+], a
	pop de
	jr .l2D95
.l2DF3
	pop bc
.l2DF4
	pop bc
.l2DF5
	xor a
	ld [$CE57], a
	ret

;Take B entries from the OAM pool and chain them. Returns the chain head in A
;with NC, or A = $FE and carry if fewer than B are free.	;[ok]
AllocOAMSlots:	;$2DFA
	ld a, [$CE50]
	sub $51
	cpl
	cp b
	ld a, $FE
	ret c
	ld h, $CE
	ld e, $51
	ld a, [$CE50]
.l2E0B
	ld l, a
	ld d, [hl]
	ld l, e
	ld [hl], d
	ld e, d
	inc a
	dec b
	jr nz, .l2E0B
	ld [$CE50], a
	ld l, e
	ld [hl], $FE
	ld a, [$CE51]
	or a
	ret

;Return sprite handle A's OAM chain to the pool, hiding each entry (Y = $A0),
;and mark the handle as having no chain.	;[ok]
FreeOAMSlots:	;$2E1F
	push bc
	ld l, a
	ld h, $D1
	ld l, [hl]
	dec h
	ld a, [$CE50]
	ld d, a
	inc l
	ld a, [hl]
	ld [hl], $FE
	ld h, $CE
	ld b, $C0
.l2E31
	cp $FE
	jr z, .l2E44
	dec d
	ld l, d
	ld [hl], a
	ld l, a
	ld h, $CF
	ld c, [hl]
	ld a, $A0
	ld [bc], a
	ld h, $CE
	ld a, [hl]
	jr .l2E31
.l2E44
	ld a, d
	ld [$CE50], a
	pop bc
	ret

;Append handle A to the list of sprites holding OAM ($D281 head, $D282 tail).
;QueueSpriteWaiting does the same for the waiting list ($D284/$D285).	;[ok]
QueueSpriteHolding:	;$2E4A
	ld hl, $D282
.l2E4D
	ld b, a
	ld a, [hl]
	cp $FE
	jr nz, .l2E5A
	ld [hl], b
	dec l
	ld [hl], b
	ld l, b
	ld [hl], $FE
	ret
.l2E5A
	ld [hl], b
	ld l, a
	ld [hl], b
	ld l, b
	ld [hl], $FE
	ret

QueueSpriteWaiting:	;$2E61
	ld hl, $D285
	jr QueueSpriteHolding.l2E4D

;Two hang traps: no holder to take entries from, and an allocation that
;failed after the pool was checked.	;[ok]
HangNoSpriteToEvict:	;$2E66
	jr HangNoSpriteToEvict

HangOAMAllocFailed:	;$2E68
	jr HangOAMAllocFailed

;Run once per frame (from BeginSpriteFrame). For each sprite that was waiting when
;it started: if the pool has room, give it its entries and move it to the
;holders; if not, take the oldest holder, free its entries, send it to the back
;of the waiting list, and try again.	;[ok]
RotateSpriteOAM:	;$2E6A
	ld hl, $D284
	ld a, [hl]
	cp $FE
	ret z
	ld a, [$D285]
	ld [$D286], a
.l2E77
	ld hl, $D284
	ld a, [hl]
	ld c, a
	ld l, c
	ld h, $D1
	ld l, [hl]
	dec h
	ld b, [hl]
	ld a, [$CE50]
	sub $51
	cpl
	cp b
	jr nc, .l2EB5
	ld hl, $D281
	ld a, [hl]
	cp $FE
	jr z, HangNoSpriteToEvict
	ld c, a
	inc l
	cp [hl]
	jr nz, .l2E9F
	ld [hl], $FE
	dec l
	ld [hl], $FE
	jr .l2EAB
.l2E9F
	ld l, a
	ld a, [hl]
	ld [$D281], a
	cp $FE
	jr nz, .l2EAB
	ld [$D282], a
.l2EAB
	ld a, c
	call FreeOAMSlots
	ld a, c
	call QueueSpriteWaiting
	jr .l2E77
.l2EB5
	ld h, $D2
	ld l, c
	ld a, [hl]
	ld l, $84
	ld [hl+], a
	cp $FE
	jr nz, .l2EC1
	ld [hl], a
.l2EC1
	ld a, c
	call QueueSpriteHolding
	ld l, c
	ld h, $D1
	ld l, [hl]
	dec h
	ld b, [hl]
	push hl
	call AllocOAMSlots
	pop hl
	jr c, HangOAMAllocFailed
	inc l
	ld [hl], a
	ld a, [$D286]
	cp c
	jp nz, .l2E77
	ret

;Get a sprite handle needing A OAM entries. Returns the handle in A (and B).
;It goes on the holder list if the pool can supply the entries now, otherwise
;on the waiting list. SpawnObject calls it with the first byte of the type's
;$34D3 record; 11 call sites in banks $00 and $01.	;[ok]
AllocSprite:	;$2EDC
	push af
	call AllocSpriteHandle
	ld a, b
	ld [$D28A], a
	ld l, a
	ld h, $D1
	ld l, [hl]
	dec h
	pop af
	ld [hl+], a
	ld b, a
	push hl
	call AllocOAMSlots
	ld [$D28B], a
	ld a, [$D28A]
	jr c, .l2EFD
	call QueueSpriteHolding
	jr .l2F00
.l2EFD
	call QueueSpriteWaiting
.l2F00
	pop hl
	ld a, [$D28B]
	ld [hl], a
	ld b, a
	ld a, [$D28A]
	ret

;Release sprite handle A: return it to the handle pool, free its OAM chain and
;take it off whichever list it is on. A = $40 or more (no sprite) is ignored.
;19 call sites; UpdateObjects and ClearAllObjects use it on retired objects.	;[ok]
FreeSprite:	;$2F0A
	cp $40
	ret nc
	ld b, a
	call FreeSpriteHandle
	ld a, b
	call FreeOAMSlots
	ld hl, $D281
	call UnlinkSprite
	ret nc
	ld hl, $D284
	call UnlinkSprite
	ret nc
	ret

;Remove handle B from the list whose head is at HL (tail at HL+1). Carry if it
;was not on the list.	;[ok]
UnlinkSprite:	;$2F24
	ld c, l
	ld e, $FE
	ld a, [hl]
	cp e
	jr z, .l2F4F
	cp b
	jr nz, .l2F3A
	inc l
	cp [hl]
	jr nz, .l2F37
	ld [hl], e
	dec l
	ld [hl], e
	jr .l2F4D
.l2F37
	dec l
	jr .l2F42
.l2F3A
	ld l, a
	ld a, [hl]
	cp e
	jr z, .l2F4F
	cp b
	jr nz, .l2F3A
.l2F42
	ld d, l
	ld l, a
	ld a, [hl]
	ld l, d
	ld [hl], a
	cp e
	jr nz, .l2F4D
	ld l, c
	inc l
	ld [hl], d
.l2F4D
	or a
	ret
.l2F4F
	scf
	ret

;Hang trap: all 64 handles in use (the pool pointer at $D280 runs from $40 to
;$80).	;[ok]
HangNoSpriteHandle:	;$2F51
	jr HangNoSpriteHandle

;Pop a free handle into B (HangNoSpriteHandle if all 64 are out). FreeSpriteHandle
;pushes B back.	;[ok]
AllocSpriteHandle:	;$2F53
	ld a, [$D280]
	cp $80
	jr nc, HangNoSpriteHandle
	ld l, a
	ld h, $D2
	ld b, [hl]
	inc a
	ld [$D280], a
	ret

FreeSpriteHandle:	;$2F63
	ld a, [$D280]
	dec a
	ld l, a
	ld h, $D2
	ld [hl], b
	ld [$D280], a
	ret

;Return the single OAM entry B to the pool and hide it. Nothing calls this.	;[ok]
FreeOneOAMSlot:	;$2F70
	ld a, [$CE50]
	dec a
	ld l, a
	ld h, $CE
	ld [hl], b
	ld [$CE50], a
	ld l, b
	ld h, $CF
	ld l, [hl]
	ld h, $C0
	ld [hl], $A0
	ret

;$2F83: park every sprite off-screen by writing Y = $A0 to all 40 shadow OAM
;slots. Also the reason StageLoadTab's base is biased - see below.	;[ok]
HideAllSprites::	;$2F83
	ld hl,wShadowOAM
	ld de,4
	ld a,$A0
	ld b,OAM_COUNT
.loop
	ld [hl],a
	add hl,de
	dec b
	jr nz,.loop
	ret
