;Mega Man: Dr. Wily's Revenge disassembly - the ending: the bank's routine kit
;Part of ROM bank $0E (see banks/bank0e.asm). Confidence tags: [ok] verified
;here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Ending Kit", ROMX[$4000], BANK[$E]

;The bank's entry: StageFrameLoop.ending (bank $00) pages bank $0E in and
;jumps here at the end of the game. Nothing returns.	;[ok]
StartEnding:	;$4000
	jp SkullShipScene

;$4003-$455A: the kit. Most of these routines are byte-for-byte copies of
;bank $00/$01/$08 routines (bank $0B carries the same kit at the same
;addresses); a copy keeps its original's name with an _0E suffix.
;
;FarCallBank1_0E: call the bank $01 routine at HL from this bank, through
;the trampoline below copied to wBank1Trampoline. Bank $0C's FarCallBank1,
;byte for byte. HL here is always a ROM0 jump stub.	;[ok]
FarCallBank1_0E:	;$4003
	push hl
	ld hl, Bank1TrampolineCode_0E
	ld de, wBank1Trampoline
	ld bc, Bank1TrampolineCodeEnd_0E - Bank1TrampolineCode_0E
	call JumpFill
	pop hl
	ld a, l
	ld [wBank1Trampoline + Bank1TrampolineCode_0E.target - Bank1TrampolineCode_0E], a
	ld a, h
	ld [wBank1Trampoline + Bank1TrampolineCode_0E.target - Bank1TrampolineCode_0E + 1], a
	jp wBank1Trampoline

;Copied to wBank1Trampoline and run there; position-independent.	;[ok]
Bank1TrampolineCode_0E:	;$401C
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
Bank1TrampolineCodeEnd_0E:

;Hide all 40 sprites (Y = $A0). HideAllSpritesAlt ($166E), byte for byte.	;[ok]
HideAllSpritesAlt_0E:	;$4033
	ld hl, wShadowOAM
	ld de, $0004
	ld bc, $28A0
.l403C
	ld [hl], c
	add hl, de
	dec b
	jr nz, .l403C
	ret

;Turn the LCD off inside VBlank. DisableLCD ($15EA), byte for byte.	;[ok]
DisableLCD_0E:	;$4042
	ldh a, [rLCDC]
	and $80
	ret z
.l4047
	ldh a, [rLY]
	cp $91
	jr c, .l4047
	cp $97
	jr nc, .l4047
	ldh a, [rLCDC]
	and $7F
	ldh [rLCDC], a
	ret

;Set up a chunked copy of BC bytes from HL to DE, A bytes per
;CopyQueuedTiles_0E call. Bank $08's QueueTileCopy, byte for byte.	;[ok]
QueueTileCopy_0E:	;$4058
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

;Copy the next chunk of the queued copy through JumpCopyVRAM. Returns
;carry when a chunk was copied, NC once nothing is left. Bank $08's
;CopyQueuedTiles with one more byte, the `scf` before the return (bank $0D's
;copy at $D:4739 has it too).	;[ok]
CopyQueuedTiles_0E:	;$4074
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
	jr z, .l40C9
	ld a, b
	or a
	jr nz, .l408E
	ld a, c
	cp h
	jr c, .l4091
.l408E
	ld c, h
	ld b, $00
.l4091
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
.l40C9
	ret

;Unused here: a copy of AccumulatePlayerDX ($D84E = this frame's X movement of
;Mega Man, added to the 16-bit $D80D). Nothing in bank $0E calls it.	;[ok]
AccumulatePlayerDX_0E:	;$40CA
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

;SetPlayerScreenX's twin: GetPlayerScreenX_0E, then wPlayerX = E. The corridor
;scene;uses it to place its (unseen) player position.	;[ok]
SetPlayerScreenX_0E:	;$40EC
	call GetPlayerScreenX_0E
	ld a, e
	ld [wPlayerX], a
	ret

;GetPlayerScreenX, byte for byte: from the 16-bit $D80D, the on-screen X in E
;and the scroll state in C/$D85D (0 scrolling, 1 at the left limit, 2 at the
;right).	;[ok]
GetPlayerScreenX_0E:	;$40F4
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

;Clamp DE between wScrollMinX and wScrollMaxX. ClampToScrollLimits
;($3226), byte for byte.	;[ok]
ClampToScrollLimits_0E:	;$4122
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

;Write A to VRAM at DE (WriteVRAMByteAlwaysSafe_0E with HL = DE; HL kept).	;[ok]
WriteVRAMByteAtDE_0E:	;$4138
	push hl
	ld l, e
	ld h, d
	call WriteVRAMByteAlwaysSafe_0E
	pop hl
	ret

;[HL] = A after waiting for HBlank, whatever the LCD state. The same 19
;bytes as WriteVRAMByte.alwaysSafe ($18A0).	;[ok]
WriteVRAMByteAlwaysSafe_0E:	;$4140
	push de
	ld d, a
	di
.l4143
	ldh a, [rSTAT]
	and $03
	jr z, .l4143
.l4149
	ldh a, [rSTAT]
	and $03
	jr nz, .l4149
	ld [hl], d
	ei
	pop de
	ret

;When this frame scrolled ($D84F non-zero) across an 8-pixel boundary of
;SCX (compared with $D854), queue the BG tile column 16 pixels left of the
;screen for the VBlank handler: its map address in $D866/$D867, its tiles in
;the $DDD0 buffer and their count in $D865, from the blocks in the $DE00 grid
;(the grid column is refilled from the room layout first when needed). The
;stage engine's QueueScrollColumn does the same for both directions, and
;bank $00's VBlankDrawColumn copies it out.	;[ok]
QueueLeftScrollColumn_0E:	;$4153
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
	ld a, [wRoomHeight]
.l41F2
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
	jr nz, .l41F2
	ld a, [wRoomHeight]
	add a, a
	ld [$D865], a
	ret

;Wait one frame, reading the joypad. Bank $0C's PasswordWaitFrame (the
;password-specific name is inherited; the code is the generic frame wait).	;[ok]
PasswordWaitFrame_0E:	;$4213
	ld b, $01

;Wait B frames (JumpDelayFrame through FarCallBank1_0E), reading the
;joypad each one. Bank $0C's PasswordWaitFrames.	;[ok]
PasswordWaitFrames_0E:	;$4215
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1_0E
	call JumpReadJoypad
	pop bc
	dec b
	jr nz, PasswordWaitFrames_0E
	ret

;Unused here: read the joypad until a button in B is held - no frame
;wait in between. Bank $0B has the same 14 bytes ($B:4A41).	;[ok]
WaitForButtons_0E:	;$4224
	ld hl, JumpReadJoypad
	push bc
	call FarCallBank1_0E
	pop bc
	ldh a, [hJoypadHeld]
	and b
	jr z, WaitForButtons_0E
	ret

;Fade the background in from black: wShadowBGP $FE, $F9, $E4, three
;frames each.	;[ok]
FadeInBG_0E:	;$4232
	ld b, $03
	call PasswordWaitFrames_0E
	ld a, $FE
	ld [wShadowBGP], a
	ld b, $03
	call PasswordWaitFrames_0E
	ld a, $F9
	ld [wShadowBGP], a
	ld b, $03
	call PasswordWaitFrames_0E
	ld a, $E4
	ld [wShadowBGP], a
	ret

;Unused: the four BGP steps FadeInBG_0E writes inline ($FF, $FE, $F9, $E4).
;Nothing reads them; bank $0B has the same four bytes ($B:5583).	;[ok]
Data_0E_4251:	;$4251
	db $FF, $FE, $F9, $E4

;Set up the sprite system's tables as InitSpriteSystem does, with three
;differences: all 40 OAM entries are pooled ($CE50 = $28, $CF77 counts down
;40 entries from 0), $CE58 = $FF, and the $CF50 loop runs 256 times (B = 0),
;filling $CF50-$D04F. Bank $0C has an unreferenced copy (InitSpriteSystem_0C).	;[ok]
InitSpriteSystem_0E:	;$4255
	ld hl, $CE28
	ld b, $28
	xor a
.l425B
	ld [hl+], a
	inc a
	dec b
	jr nz, .l425B
	ld a, $28
	ld [$CE50], a
	ld hl, $CF00
	ld b, $28
	xor a
.l426B
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l426B
	ld hl, $CF28
	ld b, $28
	xor a
.l4277
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l4277
	ld hl, $CF50
	ld b, $00
	xor a
.l4283
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l4283
	ld hl, $CF77
	ld b, $28
	ld a, $00
.l4290
	ld [hl-], a
	add a, $04
	dec b
	jr nz, .l4290
	ld a, $FF
	ld [$CE58], a
	ld hl, $D240
	ld b, $40
	xor a
.l42A1
	ld [hl+], a
	inc a
	dec b
	jr nz, .l42A1
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
.l42BF
	ld [hl+], a
	add a, $02
	dec b
	jr nz, .l42BF
	ret

;Unused here (as in bank $0C): draw a metasprite from a parameter block at
;HL - attribute (-> $D3EA), tile base (-> $CE55), X, Y, a pointer to the
;sprite handle, the metasprite pointer - with JumpDrawMetasprite.	;[ok]
DrawSpriteRecordIndirectHandle_0E:	;$42C6
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

;Unused here: as DrawSpriteRecordIndirectHandle_0E, but each of the five byte
;fields is a pointer
;to the byte.	;[ok]
DrawSpriteRecordIndirect_0E:	;$42E1
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

;Unused here: as DrawSpriteRecordIndirectHandle_0E, but the sprite handle is the
;byte itself.	;[ok]
DrawSpriteRecord_0E:	;$430C
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

;AnimateObjectGetFrame_0E, then fall into DrawObject16_0E.	;[ok]
AnimateAndDrawObject16_0E:	;$4323
	call AnimateObjectGetFrame_0E

;Draw object C (record page in H) with DrawMetasprite16_0E: handle at
;offset $10, X at $0D, Y at $0F, the frame data at $CE53/$CE54. Keeps C.	;[ok]
DrawObject16_0E:	;$4326
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
	call DrawMetasprite16_0E
	pop hl
	ld c, l
	ret

;AnimateObject_0E with the animation record at DE, then look the new frame
;up in the frame table (offsets $15/$16, frame number at $17) and leave its
;address in $CE53/$CE54.	;[ok]
AnimateObjectGetFrame_0E:	;$4347
	push hl
	call AnimateObject_0E
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

;Animate object C, DE = an animation record (dw frame table, db frames per
;step, frame numbers..., $FF loops). The object library's AnimateObject,
;byte for byte.	;[ok]
AnimateObject_0E:	;$4365
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
	jr nc, .l437E
	ld [hl], $00
	inc l
	inc [hl]
.l437E
	ld a, e
	ldh [$FF93], a
	ld a, d
	ldh [$FF94], a
	ld a, $26
	add a, c
	ld l, a
.l4388
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	cp $FF
	jr nz, .l439E
	ld [hl], $00
	ldh a, [$FF93]
	ld e, a
	ldh a, [$FF94]
	ld d, a
	jr .l4388
.l439E
	ld b, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ret

;DrawMetasprite ($2CF0) for 8x16 sprites: the same code, except that grid
;rows are 16 pixels apart. Sprite handle A, metasprite at HL, position in
;$FFA2/$FFA3, attributes $D3EA, tile base $CE55, $CE57 as there.	;[ok]
DrawMetasprite16_0E:	;$43A5
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
	jp z, .l44A5
	ld e, l
	ld d, h
.l43D9
	push bc
	ldh a, [$FFA4]
	ldh [hBank1CallIndex], a
.l43DE
	ldh a, [$FF99]
	cp $FE
	jp z, .l44A4
	ld l, a
	ld a, [de]
	cp $FF
	jr z, .l4432
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
	jr nz, .l441E
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l4416
	set 5, a
.l4416
	bit 6, d
	jr z, .l4430
	set 6, a
	jr .l4430
.l441E
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l4430
	set 5, a
.l4430
	ld [hl+], a
	pop de
.l4432
	inc de
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec c
	jr nz, .l43DE
	ldh a, [$FF92]
	add a, $10
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, .l43D9
.l4446
	ldh a, [$FF99]
	cp $FE
	jr z, .l44A5
	ld l, a
	ld a, [de]
	cp $80
	jr z, .l44A5
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
	jr nz, .l448E
	ld a, d
	and $3F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l4486
	set 5, a
.l4486
	bit 6, d
	jr z, .l44A0
	set 6, a
	jr .l44A0
.l448E
	ld a, d
	and $7F
	ld e, a
	ld a, [$CE55]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l44A0
	set 5, a
.l44A0
	ld [hl+], a
	pop de
	jr .l4446
.l44A4
	pop bc
.l44A5
	pop bc
	xor a
	ld [$CE57], a
	ret

;DrawMetasprite16_0E without the flip bits: every tile byte is added whole
;to the tile base, and $D3EA is the attribute byte unchanged. Used for the
;roll call's enemies.	;[ok]
DrawMetasprite16NoFlip_0E:	;$44AB
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
	jp z, .l4555
	ld e, l
	ld d, h
.l44DF
	push bc
	ldh a, [$FFA4]
	ldh [hBank1CallIndex], a
.l44E4
	ldh a, [$FF99]
	cp $FE
	jp z, .l4554
	ld l, a
	ld a, [de]
	cp $FF
	jr z, .l450D
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
.l450D
	inc de
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec c
	jr nz, .l44E4
	ldh a, [$FF92]
	add a, $10
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, .l44DF
.l4521
	ldh a, [$FF99]
	cp $FE
	jr z, .l4555
	ld l, a
	ld a, [de]
	cp $80
	jr z, .l4555
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
	jr .l4521
.l4554
	pop bc
.l4555
	pop bc
	xor a
	ld [$CE57], a
	ret
