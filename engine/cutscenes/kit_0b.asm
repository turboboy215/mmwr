;Mega Man: Dr. Wily's Revenge disassembly - bank $0B's helper kit
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.
;
;$4003-$4515 is a kit of helpers that bank $0E carries as well, near-identical
;(up to $455B there); bank $0C holds pieces of it (FarCallBank1,
;Bank1TrampolineCode, InitSpriteSystem_0C) and bank $08 the tile-copy pair. Routines
;that match a counterpart elsewhere carry its name with _0B added. Nothing in
;this bank calls QueueTileCopy_0B, CopyQueuedTiles_0B, AccumulatePlayerDX_0B,
;SetPlayerScreenX_0B, ClampToScrollLimits_0B, WriteVRAMByteAtDE_0B,
;QueueLeftScrollColumn_0B,
;DrawSpriteRecordIndirect_0B, AnimateAndDrawObject_0B (and so its helpers and
;DrawMetaspriteRows16_0B) or DrawMetaspriteRows16NoFlip_0B.	;[ok]

SECTION "Bank 0B Kit", ROMX[$4000], BANK[$B]

;$4000: bank $00 calls here (`call $4000` with bank $0B paged in) to play a
;Wily cutscene.	;[ok]
Entry_0B_4000:	;$4000
	jp PlayWilyCutscene

;Call the ROM0 routine at HL with bank $01 paged in, then page the current
;bank back in. Copies Bank1TrampolineCode_0B to wBank1Trampoline ($C0B0),
;patches HL into its `call` and jumps to it. Bank $00's screen loaders end with
;`ld a, 1 / bankswitch` because bank $01 normally calls them; through the
;trampoline, running from WRAM, they return to this bank. The cutscenes use it
;for every ROM0 call that may switch banks. Same code as bank $0C's FarCallBank1.	;[ok]
FarCallBank1_0B:	;$4003
	push hl
	ld hl, Bank1TrampolineCode_0B
	ld de, wBank1Trampoline
	ld bc, Bank1TrampolineCodeEnd_0B - Bank1TrampolineCode_0B
	call JumpFill
	pop hl
	ld a, l
	ld [wBank1Trampoline + Bank1TrampolineCode_0B.target - Bank1TrampolineCode_0B], a
	ld a, h
	ld [wBank1Trampoline + Bank1TrampolineCode_0B.target - Bank1TrampolineCode_0B + 1], a
	jp wBank1Trampoline

;Copied to wBank1Trampoline and run there; position-independent. Same as bank
;$0C's Bank1TrampolineCode.	;[ok]
Bank1TrampolineCode_0B:	;$401C
	ld a, [wCurrentBank]
	push af
	ld a, $01
	bankswitch
	db $CD	;call
.target
	dw $0000	;patched with HL
	pop af
	bankswitch
	ret
Bank1TrampolineCodeEnd_0B:

;Hide all 40 shadow-OAM sprites (Y = $A0). Byte-identical to bank $00's
;HideAllSpritesAlt (and bank $0C's PasswordHideSprites).	;[ok]
HideAllSpritesAlt_0B:	;$4033
	ld hl, wShadowOAM
	ld de, $0004
	ld bc, $28A0
.loop
	ld [hl], c
	add hl, de
	dec b
	jr nz, .loop
	ret

;If the LCD is on, wait for LY 145-150 (VBlank) and switch it off. Byte-identical
;to bank $00's DisableLCD.	;[ok]
DisableLCD_0B:	;$4042
	ldh a, [rLCDC]
	and $80
	ret z
.waitVBlank
	ldh a, [rLY]
	cp $91
	jr c, .waitVBlank
	cp $97
	jr nc, .waitVBlank
	ldh a, [rLCDC]
	and $7F
	ldh [rLCDC], a
	ret

;Set up a chunked copy of BC bytes from HL to DE, A bytes at a time, for
;CopyQueuedTiles_0B. Byte-identical to bank $08's QueueTileCopy. Not called in
;this bank.	;[ok]
QueueTileCopy_0B:	;$4058
	ld [wTileCopyChunk], a
	ld a, l
	ld [wTileCopySource], a
	ld a, h
	ld [wTileCopySource + 1], a
	ld a, e
	ld [wTileCopyDest], a
	ld a, d
	ld [wTileCopyDest + 1], a
	ld a, c
	ld [wTileCopyLeft], a
	ld a, b
	ld [wTileCopyLeft + 1], a
	ret

;Copy the next chunk of the queued copy through JumpCopyVRAM. As bank $08's
;CopyQueuedTiles, plus a `scf`: returns carry when it copied a chunk, NC when
;nothing was left. Not called in this bank.	;[ok]
CopyQueuedTiles_0B:	;$4074
	ld a, [wTileCopyChunk]
	ld h, a
	ld a, [wTileCopyLeft]
	ld c, a
	ld a, [wTileCopyLeft + 1]
	ld b, a
	ld e, c
	ld d, b
	ld a, b
	or c
	jr z, .done
	ld a, b
	or a
	jr nz, .fullChunk
	ld a, c
	cp h
	jr c, .gotLength
.fullChunk
	ld c, h
	ld b, $00
.gotLength
	ld a, e
	sub c
	ld [wTileCopyLeft], a
	ld a, d
	sbc a, b
	ld [wTileCopyLeft + 1], a
	ld a, [wTileCopySource]
	ld l, a
	ld a, [wTileCopySource + 1]
	ld h, a
	ld a, [wTileCopyDest]
	ld e, a
	ld a, [wTileCopyDest + 1]
	ld d, a
	push hl
	push de
	push bc
	call JumpCopyVRAM
	pop bc
	pop de
	pop hl
	add hl, bc
	ld a, l
	ld [wTileCopySource], a
	ld a, h
	ld [wTileCopySource + 1], a
	ld l, e
	ld h, d
	add hl, bc
	ld a, l
	ld [wTileCopyDest], a
	ld a, h
	ld [wTileCopyDest + 1], a
	scf
.done
	ret

;Byte-identical to bank $01's AccumulatePlayerDX: $D84E = how far Mega Man moved in X
;this frame; add it to the 16-bit $D80D (the old value saved at $D852). Not
;called in this bank.	;[ok]
AccumulatePlayerDX_0B:	;$40CA
	ld a, [$D81C]
	ld e, a
	ld a, [wPlayerX]
	sub e
	ld e, a
	ld d, $00
	jr nc, .l40D8
	dec d
.l40D8
	ld bc, $D852
	ld hl, $D80D
	ld a, [hl]
	ld [bc], a
	inc bc
	add a, e
	ld [hl+], a
	ld a, [hl]
	ld [bc], a
	adc a, d
	ld [hl], a
	ld a, e
	ld [$D84E], a
	ret

;GetPlayerScreenX_0B, then wPlayerX = E. Bank $00's SetPlayerScreenX, calling the local copy.
;Not called in this bank.	;[ok]
SetPlayerScreenX_0B:	;$40EC
	call GetPlayerScreenX_0B
	ld a, e
	ld [wPlayerX], a
	ret

;Byte-identical to bank $00's GetPlayerScreenX: from the
;16-bit $D80D and wScrollMaxX, returns E and sets $D85D to 0, 1 or 2.	;[ok]
GetPlayerScreenX_0B:	;$40F4
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	or a
	ld a, e
	jr nz, .l4106
	cp $50
	ld c, $01
	jr c, .l411C
.l4106
	ld hl, wScrollMaxX
	sub [hl]
	ld e, a
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l4118
	ld a, $50
	add a, e
	ld e, a
	ld c, $02
	jr .l411C
.l4118
	ld c, $00
	ld e, $50
.l411C
	ld a, c
	ld [$D85D], a
	or a
	ret

;Clamp DE between the scroll limits wScrollMinX/wScrollMaxX. Byte-identical to
;bank $00's ClampToScrollLimits. Not called in this bank.	;[ok]
ClampToScrollLimits_0B:	;$4122
	ld hl, wScrollMinX
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l4134
	inc hl
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l4137
.l4134
	ld d, [hl]
	dec hl
	ld e, [hl]
.l4137
	ret

;[DE] = A, through WriteVRAMByteAlwaysSafe_0B. Not called in this bank.	;[ok]
WriteVRAMByteAtDE_0B:	;$4138
	push hl
	ld l, e
	ld h, d
	call WriteVRAMByteAlwaysSafe_0B
	pop hl
	ret

;[HL] = A, waiting for HBlank (interrupts off meanwhile); D is preserved.
;Byte-identical to bank $00's WriteVRAMByte.alwaysSafe.	;[ok]
WriteVRAMByteAlwaysSafe_0B:	;$4140
	push de
	ld d, a
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and $03
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and $03
	jr nz, .waitHBlank
	ld [hl], d
	ei
	pop de
	ret

;The left-edge half of bank $00's QueueScrollColumn, which streams a column of
;blocks into the BG map as the stage scrolls: when $D84F is set and SCX crossed
;an 8-pixel boundary since $D854, look up the column 16 px left of the screen
;and leave its 8 tile pairs at $DDD0, the BG map address at $D866 and $10 in
;$D865. Bank $00's version also does the right edge (its .leftEdge path is this
;routine step for step); bank $0E's QueueLeftScrollColumn_0E is the same. Not
;called in this bank.	;[ok]
QueueLeftScrollColumn_0B:	;$4153
	ld a, [$D84F]
	or a
	ret z
	ld a, [$D854]
	ld c, a
	ld a, [wShadowSCX]
	ld b, a
	xor c
	and $08
	ret z
	ld a, b
	add a, $F0
	srl a
	srl a
	srl a
	ld c, a
	ld a, [wShadowSCY]
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld b, $98
	add hl, bc
	ld a, l
	ld [$D866], a
	ld a, h
	ld [$D867], a
	ld a, [wShadowSCX]
	add a, $F0
	ld e, a
	ld a, [wShadowSCY]
	ld d, a
	ld a, e
	swap a
	and $0F
	ld e, a
	ld a, d
	and $F0
	or e
	bit 0, c
	ld c, a
	ld e, $00
	ld b, $DE
	jr z, .l41E1
	ld a, [$D80D]
	ld l, a
	ld a, [$D80E]
	ld h, a
	ld de, $FFA0
	add hl, de
	ld e, $02
	push de
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	ld h, $00
	ld a, [wRoomRowPtrs]
	ld e, a
	ld a, [wRoomRowPtrs + 1]
	ld d, a
	add hl, de
	ld a, [wRoomWidth]
	ld e, a
	ld d, $00
	ld a, $08
	push bc
.l41D3
	push af
	ld a, [hl]
	ld [bc], a
	add hl, de
	ld a, c
	add a, $10
	ld c, a
	pop af
	dec a
	jr nz, .l41D3
	pop bc
	pop de
.l41E1
	ld a, [wBlocksetPtr]
	add a, e
	ld e, a
	ld a, [wBlocksetPtr + 1]
	adc a, $00
	ld d, a
	ld hl, $DDD0
	ld a, $08
.l41F1
	push af
	push hl
	ld b, $DE
	ld a, [bc]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, de
	ld a, [hl+]
	ld b, [hl]
	pop hl
	ld [hl+], a
	ld [hl], b
	inc l
	ld a, c
	add a, $10
	ld c, a
	pop af
	dec a
	jr nz, .l41F1
	ld a, $10
	ld [$D865], a
	ret

;Set up the sprite system's tables (see engine/sprites.asm): as bank $00's
;InitSpriteSystem, but with all 40 OAM entries in the pool ($CE50 = $28, not $36;
;$CE58 = $FF, not 0). The third offset loop runs 256 times (B = 0), on past
;$CF77 to $D04F; the next loop rewrites $CF50-$CF77. Byte-identical to bank $0C's
;InitSpriteSystem_0C.	;[ok]
InitSpriteSystem_0B:	;$4210
	ld hl, $CE28
	ld b, $28
	xor a
.l4216
	ld [hl+], a
	inc a
	dec b
	jr nz, .l4216
	ld a, $28
	ld [$CE50], a
	ld hl, $CF00
	ld b, $28
	xor a
.l4226
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l4226
	ld hl, $CF28
	ld b, $28
	xor a
.l4232
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l4232
	ld hl, $CF50
	ld b, $00
	xor a
.l423E
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l423E
	ld hl, $CF77
	ld b, $28
	ld a, $00
.l424B
	ld [hl-], a
	add a, $04
	dec b
	jr nz, .l424B
	ld a, $FF
	ld [$CE58], a
	ld hl, $D240
	ld b, $40
	xor a
.l425C
	ld [hl+], a
	inc a
	dec b
	jr nz, .l425C
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
.l427A
	ld [hl+], a
	add a, $02
	dec b
	jr nz, .l427A
	ret

;DrawSpriteRecord_0B for an 8-byte record whose handle is read through a
;pointer: db attributes, tile base, X, Y / dw handle pointer, metasprite.	;[ok]
DrawSpriteRecordIndirectHandle_0B:	;$4281
	ld a, [hl+]
	ld [$D3EA], a
	ld a, [hl+]
	ld [$CE55], a
	ld a, [hl+]
	ldh [$FFA2], a
	ld a, [hl+]
	ldh [$FFA3], a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	jp JumpDrawMetasprite

;DrawSpriteRecord_0B with every field read through a pointer: five pointers
;(attributes, tile base, X, Y, handle), then the metasprite. Not called in this
;bank.	;[ok]
DrawSpriteRecordIndirect_0B:	;$429C
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld [$D3EA], a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld [$CE55], a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ldh [$FFA2], a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ldh [$FFA3], a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	jp JumpDrawMetasprite

;Draw the sprite record at HL, 7 bytes: db attributes ($D3EA), tile base
;($CE55), X ($FFA2), Y ($FFA3), sprite handle / dw metasprite - through
;JumpDrawMetasprite. All of this bank's scene sprites are drawn this way.	;[ok]
DrawSpriteRecord_0B:	;$42C7
	ld a, [hl+]
	ld [$D3EA], a
	ld a, [hl+]
	ld [$CE55], a
	ld a, [hl+]
	ldh [$FFA2], a
	ld a, [hl+]
	ldh [$FFA3], a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	jp JumpDrawMetasprite

;Animate object C with the animation record at DE (AnimateObjectFramePtr_0B) and
;draw its frame with DrawMetaspriteRows16_0B: handle from offset $10, X from
;$0D, Y from $0F. Unlike bank $00's DrawObjectSprite it does not skip a hitbox
;or set $D3EA/$CE55. Not called in this bank.	;[ok]
AnimateAndDrawObject_0B:	;$42DE
	call AnimateObjectFramePtr_0B
	ld l, c
	push hl
	ld a, $10
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ldh [$FFA2], a
	inc l
	ld a, [hl+]
	ldh [$FFA3], a
	ld a, [$CE53]
	ld l, a
	ld a, [$CE54]
	ld h, a
	ld a, e
	call DrawMetaspriteRows16_0B
	pop hl
	ld c, l
	ret

;AnimateObject_0B, then $CE53/$CE54 = the current frame's pointer (the frame
;table at offset $15, indexed by the frame at $17).	;[ok]
AnimateObjectFramePtr_0B:	;$4302
	push hl
	call AnimateObject_0B
	ld a, $15
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
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
	pop hl
	ret

;Animate object C. DE = an animation record (dw frame table, db frames per
;step, db frame, ..., $FF). Byte-identical to the object library's
;AnimateObject.	;[ok]
AnimateObject_0B:	;$4320
	ld a, $15
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, $25
	add a, c
	ld l, a
	inc [hl]
	ld a, [de]
	inc de
	dec a
	cp [hl]
	jr nc, .l4339
	ld [hl], $00
	inc l
	inc [hl]
.l4339
	ld a, e
	ldh [$FF93], a
	ld a, d
	ldh [$FF94], a
	ld a, $26
	add a, c
	ld l, a
.l4343
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	cp $FF
	jr nz, .l4359
	ld [hl], $00
	ldh a, [$FF93]
	ld e, a
	ldh a, [$FF94]
	ld d, a
	jr .l4343
.l4359
	ld b, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

;Bank $00's DrawMetasprite with two changes: grid rows are 16 px apart, not 8,
;and the early exits are plain `ret`s that leave $CE57 alone. Reached only
;from AnimateAndDrawObject_0B.	;[ok]
DrawMetaspriteRows16_0B:	;$4360
	cp $40
	ret nc
	ld e, a
	ld d, $D1
	ld a, [de]
	ld e, a
	dec d
	inc e
	ld a, [de]
	cp $FE
	ret z
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
	jp z, .l4460
	ld e, l
	ld d, h
.l4394
	push bc
	ldh a, [$FFA4]
	ldh [hBank1CallIndex], a
.l4399
	ldh a, [$FF99]
	cp $FE
	jp z, .l445F
	ld l, a
	ld a, [de]
	cp $FF
	jr z, .l43ED
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
	jr nz, .l43D9
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l43D1
	set 5, a
.l43D1
	bit 6, d
	jr z, .l43EB
	set 6, a
	jr .l43EB
.l43D9
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l43EB
	set 5, a
.l43EB
	ld [hl+], a
	pop de
.l43ED
	inc de
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec c
	jr nz, .l4399
	ldh a, [$FF92]
	add a, $10
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, .l4394
.l4401
	ldh a, [$FF99]
	cp $FE
	jr z, .l4460
	ld l, a
	ld a, [de]
	cp $80
	jr z, .l4460
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
	jr nz, .l4449
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l4441
	set 5, a
.l4441
	bit 6, d
	jr z, .l445B
	set 6, a
	jr .l445B
.l4449
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l445B
	set 5, a
.l445B
	ld [hl+], a
	pop de
	jr .l4401
.l445F
	pop bc
.l4460
	pop bc
	xor a
	ld [$CE57], a
	ret

;DrawMetaspriteRows16_0B without flips: each tile byte is added whole to the
;tile base and $D3EA is used as it is. Not called in this bank.	;[ok]
DrawMetaspriteRows16NoFlip_0B:	;$4466
	cp $40
	ret nc
	ld e, a
	ld d, $D1
	ld a, [de]
	ld e, a
	dec d
	inc e
	ld a, [de]
	cp $FE
	ret z
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
	jp z, .l4510
	ld e, l
	ld d, h
.l449A
	push bc
	ldh a, [$FFA4]
	ldh [hBank1CallIndex], a
.l449F
	ldh a, [$FF99]
	cp $FE
	jp z, .l450F
	ld l, a
	ld a, [de]
	cp $FF
	jr z, .l44C8
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
	ld a, [$CE55]
	add a, d
	ld [hl+], a
	ld a, [$D3EA]
	ld [hl+], a
	pop de
.l44C8
	inc de
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec c
	jr nz, .l449F
	ldh a, [$FF92]
	add a, $10
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, .l449A
.l44DC
	ldh a, [$FF99]
	cp $FE
	jr z, .l4510
	ld l, a
	ld a, [de]
	cp $80
	jr z, .l4510
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
	ld a, [$CE55]
	add a, d
	ld [hl+], a
	ld a, [$D3EA]
	ld [hl+], a
	pop de
	jr .l44DC
.l450F
	pop bc
.l4510
	pop bc
	xor a
	ld [$CE57], a
	ret
