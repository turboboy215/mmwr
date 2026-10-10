;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $0C
;Stage background tilesets, and the password screens. Step 3.3. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "bankC",ROMX,BANK[$C]

;$4000: one tileset list per stage, reached through StageTilesetPtrs in bank $00.
;Each list is the 4-byte records LoadStageTiles reads (tile count, first tile,
;source), ended by $00: the stage's own tiles at tile 0, then the two shared
;runs at tiles 98 and 112.	;[ok]
Ptr_0C_4000:	dw StageTilesetCutMan
Ptr_0C_4002:	dw StageTilesetIceMan
Ptr_0C_4004:	dw StageTilesetFireMan
Ptr_0C_4006:	dw StageTilesetElecMan
Ptr_0C_4008:	dw StageTilesetWily1
Ptr_0C_400A:	dw StageTilesetWily2
Ptr_0C_400C:	dw StageTilesetWily3
Ptr_0C_400E:	dw StageTilesetFireManAlt

;$4010: entry points. CheckPasswordEntry calls the first; the boss-cleared and
;game-over paths in bank $00 call the second, after queueing the password music
;($2E).	;[ok]
EnterPasswordEntry::	;$4010
	jp EnterPassword
ShowPasswordEntry::	;$4013
	jp ShowPassword

;$4016: call the bank $01 routine at HL from this bank. Copies the 23-byte
;trampoline below to wBank1Trampoline ($C0B0), patches HL into its `call`, and
;jumps to it; the trampoline pages in bank $01, makes the call, and restores
;the bank that was paged in before. Banks $0B and $0E open with the same kit.	;[ok]
FarCallBank1:	;$4016
	push hl
	ld hl, Bank1TrampolineCode
	ld de, wBank1Trampoline
	ld bc, Bank1TrampolineCodeEnd - Bank1TrampolineCode
	call JumpFill
	pop hl
	ld a, l
	ld [wBank1Trampoline + Bank1TrampolineCode.target - Bank1TrampolineCode], a
	ld a, h
	ld [wBank1Trampoline + Bank1TrampolineCode.target - Bank1TrampolineCode + 1], a
	jp wBank1Trampoline

;Copied to $C0B0 and run there; position-independent.
Bank1TrampolineCode:	;$402F
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
Bank1TrampolineCodeEnd:

;$4046: the first four stages' lists, in Ptr_0C order.
StageTilesetCutMan:
	db 80, 0
	dw StageTilesCutMan
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetIceMan:
	db 75, 0
	dw StageTilesIceMan
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetFireMan:
	db 79, 0
	dw StageTilesFireMan
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetElecMan:
	db 76, 0
	dw StageTilesElecMan
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0

;$407A: tiles every stage loads at 98 and 112. gfx/stages/shared_*.png.	;[ok]
StageTilesShared98:
	INCBIN "gfx/stages/shared_98.2bpp"
StageTilesShared112:
	INCBIN "gfx/stages/shared_112.2bpp"

;$422A: gfx/stages/*.png.	;[ok]
StageTilesCutMan:
	INCBIN "gfx/stages/cut_man.2bpp"
StageTilesIceMan:
	INCBIN "gfx/stages/ice_man.2bpp"
StageTilesFireMan:
	INCBIN "gfx/stages/fire_man.2bpp", 0, 79 * 16
StageTilesElecMan:
	INCBIN "gfx/stages/elec_man.2bpp"

;$558A: the Wily stages' lists, and the unused eighth stage's.
StageTilesetWily1:
	db 72, 0
	dw StageTilesWily1
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetWily3:
	db 80, 0
	dw StageTilesWily3
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetFireManAlt:
	db 79, 0
	dw StageTilesFireManAlt
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0
StageTilesetWily2:
	db 76, 0
	dw StageTilesWily2
	db 11, 98
	dw StageTilesShared98
	db 16, 112
	dw StageTilesShared112
	db 0

StageTilesWily1:
	INCBIN "gfx/stages/wily1.2bpp"
StageTilesWily3:
	INCBIN "gfx/stages/wily3.2bpp"

;$5F3E: the tileset of the unused eighth stage slot, the alternate Fire Man
;stage. 79 tiles like Fire Man's own, in the same style, and 18 of them are
;identical to tiles of Fire Man's set; the rest are its own.	;[ok]
StageTilesFireManAlt:
	INCBIN "gfx/stages/fire_man_alt.2bpp", 0, 79 * 16
StageTilesWily2:
	INCBIN "gfx/stages/wily2.2bpp"

;$68EE-$695E: an unreferenced copy of QueueTileCopy and CopyQueuedTiles - the
;same 113 bytes as bank $08 $4008. Nothing in bank $0C calls either. Named with
;_0C like the other banks' copies (QueueTileCopy_0D, CopyQueuedTiles_0D).	;[ok]
QueueTileCopy_0C:	;$68EE
	ld [$D910], a
	ld a, l
	ld [$D911], a
	ld a, h
	ld [$D912], a
	ld a, e
	ld [$D913], a
	ld a, d
	ld [$D914], a
	ld a, c
	ld [$D915], a
	ld a, b
	ld [$D916], a
	ret

CopyQueuedTiles_0C:	;$690A
	ld a, [$D910]
	ld h, a
	ld a, [$D915]
	ld c, a
	ld a, [$D916]
	ld b, a
	ld e, c
	ld d, b
	ld a, b
	or c
	jr z, .l695E
	ld a, b
	or a
	jr nz, .l6924
	ld a, c
	cp h
	jr c, .l6927
.l6924
	ld c, h
	ld b, $00
.l6927
	ld a, e
	sub c
	ld [$D915], a
	ld a, d
	sbc a, b
	ld [$D916], a
	ld a, [$D911]
	ld l, a
	ld a, [$D912]
	ld h, a
	ld a, [$D913]
	ld e, a
	ld a, [$D914]
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
	ld [$D911], a
	ld a, h
	ld [$D912], a
	ld l, e
	ld h, d
	add hl, bc
	ld a, l
	ld [$D913], a
	ld a, h
	ld [$D914], a
.l695E
	ret

;Hide all 40 shadow-OAM sprites (Y = $A0).	;[ok]
PasswordHideSprites:	;$695F
	ld hl, wShadowOAM
	ld de, $0004
	ld bc, $28A0
.l6968
	ld [hl], c
	add hl, de
	dec b
	jr nz, .l6968
	ret

;Turn the LCD on with BG and 8x8 sprites (LCDC $83).	;[ok]
PasswordLCDOn:	;$696E
	ld a, $83
	ld [wShadowLCDC], a
	ldh [rLCDC], a
	ret

;If the LCD is on, wait for LY 145-150 (VBlank) and switch it off.	;[ok]
PasswordLCDOff:	;$6976
	ldh a, [rLCDC]
	and $80
	ret z
.l697B
	ldh a, [rLY]
	cp $91
	jr c, .l697B
	cp $97
	jr nc, .l697B
	ldh a, [rLCDC]
	and $7F
	ldh [rLCDC], a
	ret

;Show the password for the robot masters beaten so far, until A, B or Start.
;Bank $00 calls it after a robot master falls (while the high nibble of
;wBossesDefeated is 0) and at game over.	;[ok]
ShowPassword:	;$698C
	xor a
	ld [$C608], a
	call LoadPasswordScreenGfx
	ld a, [wWeaponsUnlocked1]
	and $1E
	ld hl, PasswordTable
	ld d, $00
	ld e, a
	add hl, de
	call PasswordDrawBalls
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $90
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call PasswordLCDOn
	ei
	ld b, $3C
	call PasswordWaitFrames
.l69BF
	call PasswordWaitFrame
	ldh a, [hJoypadPressed]
	and $0B
	jr z, .l69BF
	ret

;The password screen reached from the title's PASS WORD option (through
;CheckPasswordEntry). Accepted: the extra-life jingle and three seconds' wait, with
;wWeaponsUnlocked1 rebuilt from the password. Rejected: $C600 = 1, the
;"PASS WORD / ERROR !!" screen with a palette flash and explosions - and then
;CheckPasswordEntry resets the game.	;[ok]
EnterPassword:	;$69C9
	call RunPasswordEntry
	call PasswordEndInput
	ld a, [$C600]
	cp $01
	jp z, PasswordRejected
	jp PasswordAccepted

;Input loop: place five balls, then look the 16-bit cell mask up in
;PasswordTable. A match sets wWeaponsUnlocked1 = index * 2 + 1 (Mega Buster plus
;the beaten robot masters' weapons); no match sets $C600 = 1.	;[ok]
RunPasswordEntry:	;$69DA
	ld hl, $C600
	ld b, $20
	xor a
.l69E0
	ld [hl+], a
	dec b
	jr nz, .l69E0
	ld a, $05
	ld [$C60F], a
	ld a, $0C
	ld [$C608], a
	call LoadPasswordScreenGfx
	call PasswordDrawCursor
	call PasswordDrawBallCount
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $90
	ldh [rOBP0], a
	ld a, $84
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call PasswordLCDOn
	ei
.l6A0F
	call PasswordWaitFrame
	ld a, [$C60F]
	or a
	jr z, .l6A23
	call PasswordMoveCursor
	call PasswordPlaceBall
	call PasswordDrawBallCount
	jr .l6A0F
.l6A23
	call PasswordBallsToMask
	ld de, $0000
	ld hl, PasswordTable
.l6A2C
	ld a, [hl+]
	cp b
	jr z, .l6A39
	inc hl
.l6A31
	inc e
	ld a, e
	cp $10
	jr z, .l6A4D
	jr .l6A2C
.l6A39
	ld a, [hl+]
	cp c
	jr nz, .l6A31
	ld a, e
	sla a
	or $01
	ld [wWeaponsUnlocked1], a
	xor a
	ld [$C600], a
	ld [wWeaponsUnlocked2], a
	ret
.l6A4D
	ld a, $01
	ld [wWeaponsUnlocked1], a
	ld [wWeaponsUnlocked2], a
	ld [$C600], a
	ret

;Move the cursor with the d-pad: $C601 = column (1-4), $C602 = row (A-D).	;[ok]
PasswordMoveCursor:	;$6A59
	ld a, [$C600]
	or a
	jr nz, PasswordDrawCursor.l6ABE
	ldh a, [hJoypadPressed]
	and $80
	jr nz, .l6A90
	ldh a, [hJoypadPressed]
	and $40
	jr nz, .l6A9D
	ldh a, [hJoypadPressed]
	and $20
	jr nz, .l6A84
	ldh a, [hJoypadPressed]
	and $10
	jr z, PasswordDrawCursor.l6ABE
	ld a, [$C601]
	cp $03
	jr z, PasswordDrawCursor.l6AB8
	inc a
	ld [$C601], a
	jr PasswordDrawCursor
.l6A84
	ld a, [$C601]
	or a
	jr z, PasswordDrawCursor.l6AB8
	dec a
	ld [$C601], a
	jr PasswordDrawCursor
.l6A90
	ld a, [$C602]
	cp $03
	jr z, PasswordDrawCursor.l6AB8
	inc a
	ld [$C602], a
	jr PasswordDrawCursor
.l6A9D
	ld a, [$C602]
	or a
	jr z, PasswordDrawCursor.l6AB8
	dec a
	ld [$C602], a

;Draw the cursor sprite on its cell.	;[ok]
PasswordDrawCursor:	;$6AA7
	call PasswordCursorCell
	ld a, $41
	ld [$C604], a
	ld de, wShadowOAM
	ld hl, PasswordCellPositions
	call PasswordPutSprite
.l6AB8
	ld a, $01
	ld [$C600], a
	ret
.l6ABE
	ldh a, [hJoypadPressed]
	and $F0
	ret nz
	ld [$C600], a
	ret

;A places a ball on the cursor's cell (unless already taken), B takes the last
;one back. Ball cells+1 are kept at $C611-$C615; $C60F counts balls left.	;[ok]
PasswordPlaceBall:	;$6AC7
	ld a, [$C603]
	or a
	jp nz, .l6B53
	ldh a, [hJoypadPressed]
	and $01
	jr nz, .l6B0C
	ldh a, [hJoypadPressed]
	and $02
	jr z, .l6B53
	ld a, $21
	call JumpQueueSound
	ld a, [$C60F]
	or a
	jp z, .l6B4D
	cp $05
	jp z, .l6B4D
	ld a, [$C60F]
	inc a
	ld [$C60F], a
	ld hl, $C610
	ld e, a
	ld d, $00
	add hl, de
	ld [hl], $00
	ld a, [$C608]
	sub $04
	ld [$C608], a
	ld e, a
	ld d, $C0
	ld a, $C0
	ld [de], a
	jp .l6B4D
.l6B0C
	ld a, $04
	call JumpQueueSound
	call PasswordCursorCell
	ld hl, $C611
	ld b, $05
	inc c
.l6B1A
	ld a, [hl+]
	cp c
	jr z, .l6B4D
	dec b
	jr nz, .l6B1A
	ld a, [$C60F]
	ld e, a
	ld d, $00
	ld hl, $C610
	add hl, de
	ld [hl], c
	dec c
	ld a, $40
	ld [$C604], a
	ld a, [$C608]
	ld e, a
	ld d, $C0
	ld hl, PasswordCellPositions
	call PasswordPutSprite
	ld a, [$C60F]
	dec a
	ld [$C60F], a
	ld a, [$C608]
	add a, $04
	ld [$C608], a
.l6B4D
	ld a, $01
	ld [$C603], a
	ret
.l6B53
	ldh a, [hJoypadPressed]
	and $03
	ret nz
	ld [$C603], a
	ret

;Turn the five placed balls into the cell mask in B (A1-B4) and C (C1-D4).	;[ok]
PasswordBallsToMask:	;$6B5C
	ld bc, $0000
	ld d, $00
	ld a, [$C611]
	call PasswordSetCellBit
	ld a, [$C612]
	call PasswordSetCellBit
	ld a, [$C613]
	call PasswordSetCellBit
	ld a, [$C614]
	call PasswordSetCellBit
	ld a, [$C615]
	call PasswordSetCellBit
	ret

;Set the bit for cell index A (cell + 1) in B or C.	;[ok]
PasswordSetCellBit:	;$6B80
	ld hl, PasswordCellBits
	cp $09
	jr c, .l6B8F
	sub $08
	ld e, a
	add hl, de
	ld a, [hl]
	or c
	ld c, a
	ret
.l6B8F
	ld e, a
	add hl, de
	ld a, [hl]
	or b
	ld b, a
	ret

;Bit for each cell+1: index 0 unused, 1-8 are bits 7-0 of B, 9-16 bits 7-0 of C.	;[ok]
PasswordCellBits:
	db $00, $80, $40, $20, $10, $08, $04, $02
	db $01

;C = the cursor's cell, row * 4 + column.	;[ok]
PasswordCursorCell:	;$6B9E
	ld a, [$C601]
	ld c, a
	ld a, [$C602]
	sla a
	sla a
	or c
	ld c, a
	ret

;Set up the password screen with the LCD off: the stage-select screen's tiles
;and maps (CallBank1Routine 3, LoadStageSelectScreen - which answers how the
;password screen shares the stage select's look), the grid map over BG map 0,
;and the password sprite tiles to $8000.	;[ok]
LoadPasswordScreenGfx:	;$6BAC
	call JumpReadJoypad
	di
	xor a
	ldh [rSTAT], a
	ld a, $03
	ld [wShadowLCDC], a
	call PasswordLCDOff
	call PasswordHideSprites
	ld a, $03
	call JumpCallBank1Routine
	ld de, $9800
	ld hl, PasswordTilemap
	call PasswordCopyTilemap
	ld hl, PasswordSpriteTiles
	ld de, $8000
	ld bc, $0420
	call JumpFill
	ret

;A copy of CopyTilemapRect.	;[ok]
PasswordCopyTilemap:	;$6BD9
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
.l6BDD
	push bc
	ld b, $00
	push de
	call JumpCopyVRAM
	pop de
	push hl
	ld hl, $0020
	add hl, de
	ld e, l
	ld d, h
	pop hl
	pop bc
	dec b
	jr nz, .l6BDD
	ret

;Draw the balls of the password at HL (two mask bytes) as sprites.	;[ok]
PasswordDrawBalls:	;$6BF2
	ld a, $40
	ld [$C604], a
	ld a, [$C608]
	ld e, a
	ld d, $C0
	ld a, [hl+]
	ld bc, $0800
.l6C01
	sla a
	jr nc, .l6C11
	push af
	push bc
	push hl
	ld hl, PasswordCellPositions
	call PasswordPutSprite
	pop hl
	pop bc
	pop af
.l6C11
	inc c
	dec b
	jr nz, .l6C01
	ld a, [hl+]
	ld bc, $0800
.l6C19
	sla a
	jr nc, .l6C29
	push af
	push bc
	push hl
	ld hl, PasswordCellPositions + 16
	call PasswordPutSprite
	pop hl
	pop bc
	pop af
.l6C29
	inc c
	dec b
	jr nz, .l6C19
	ret

;Write one OAM entry at DE: cell C's position from HL, tile [$C604].	;[ok]
PasswordPutSprite:	;$6C2E
	sla c
	ld b, $00
	add hl, bc
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	ld a, [$C604]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	ret

;Draw the balls-left counter beside a ball icon (OAM entries 1-2).	;[ok]
PasswordDrawBallCount:	;$6C42
	ld hl, $C004
	ld a, $6C
	ld [hl+], a
	ld a, $8B
	ld [hl+], a
	ld a, [$C60F]
	ld c, a
	add a, $10
	ld [hl+], a
	xor a
	ld [hl+], a
	ld b, $C0
	ld a, c
	or a
	jr z, .l6C5C
	ld b, $7C
.l6C5C
	ld [hl], b
	inc hl
	ld a, $8B
	ld [hl+], a
	ld a, $40
	ld [hl+], a
	xor a
	ld [hl+], a
	ret

;$6C67: the 16 passwords, one per combination of beaten robot masters, indexed
;by wWeaponsUnlocked1 bits 1-4 (Rolling Cutter, Thunder Beam, Ice Slasher, Fire
;Storm). Each is a 16-bit cell mask, first byte = cells A1-B4, second = C1-D4,
;high bit first; every one has exactly five balls. Decoded:	;[ok]
;   none            A3 B1 B3 C2 C4     Ice             A1 A2 B2 B3 D4
;   Cut             A4 B3 C4 D3 D4     Cut+Ice         A1 A3 A4 B4 D2
;   Elec            A2 A4 B3 D1 D2     Elec+Ice        A1 B4 C1 D2 D4
;   Cut+Elec        A1 A3 B1 B3 D3     Cut+Elec+Ice    A1 A3 C1 C4 D3
;   Fire            A1 B1 B2 C4 D2     Ice+Fire        A2 B3 D2 D3 D4
;   Cut+Fire        A2 B2 C3 D1 D3     Cut+Ice+Fire    A1 A2 B3 C4 D4
;   Elec+Fire       B2 B4 C1 C3 C4     Elec+Ice+Fire   A2 A3 C1 D2 D3
;   Cut+Elec+Fire   A3 B2 B3 B4 C4     all four        A2 A3 B4 C2 C3
PasswordTable:
	db $2A, $50, $12, $13, $52, $0C, $AA, $02
	db $C6, $01, $B1, $04, $81, $85, $A0, $92
	db $8C, $14, $44, $2A, $05, $B0, $27, $10
	db $42, $07, $C2, $11, $60, $86, $61, $60
;$6C87: OAM (Y, X) of each of the 16 grid cells, row by row.	;[ok]
PasswordCellPositions:
	db $3D, $2D, $3D, $3D, $3D, $4D, $3D, $5D
	db $4D, $2D, $4D, $3D, $4D, $4D, $4D, $5D
	db $5D, $2D, $5D, $3D, $5D, $4D, $5D, $5D
	db $6D, $2D, $6D, $3D, $6D, $4D, $6D, $5D

;$6CA7: the password screen's grid (A-D by 1-4), 20x18 with a size header,
;drawn over the stage-select screen's tiles. gfx/tilemaps/password.tilemap.	;[ok]
PasswordTilemap:
INCBIN "gfx/tilemaps/password.tilemap"

;$6E11: 66 sprite tiles loaded to $8000 by the password screen: a full ASCII font
;from "!" to "_" (with a copyright sign at "@" and a yen sign at "\"), then a
;grey and a black password ball. gfx/screens/password_sprites.png.	;[ok]
PasswordSpriteTiles:
	INCBIN "gfx/screens/password_sprites.2bpp"
PasswordSpriteTilesEnd:

;Hide sprite 0 and wait a frame.	;[ok]
PasswordEndInput:	;$7231
	ld hl, wShadowOAM
	ld [hl], $A0
	call PasswordWaitFrame
	ret

;Password accepted: sound $10, SFX_ExtraLife (the extra-life jingle - Will
;confirmed it by ear), and a 180-frame wait.	;[ok]
PasswordAccepted:	;$723A
	ld a, $10
	call JumpQueueSound
	ld bc, $00B4
.l7242
	push bc
	call PasswordWaitFrame
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, .l7242
	ret

;Password rejected: palette flash, the PASS WORD / ERROR !! text (CallBank1Routine
;5, LoadPasswordScreen), 240 frames of explosions (PasswordErrorNoise), then
;sound $0F, SFX_PlayerExplode - Mega Man's death explosion - and 180 frames.
;Will confirmed both sounds by ear.	;[ok]
PasswordRejected:	;$724D
	call PasswordHideSprites
	ld a, $F9
	call PasswordFadeStep
	ld a, $FE
	call PasswordFadeStep
	ld a, $FF
	call PasswordFadeStep
	ld a, $05
	call JumpCallBank1Routine
	ld a, $AB
	call PasswordFadeStep
	ld a, $57
	call PasswordFadeStep
	ld a, $03
	call PasswordFadeStep
	ld bc, $00F0
.l7276
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1
	call PasswordErrorNoise
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, .l7276
	ld a, $0F
	call JumpQueueSound
	ld b, $B4
.l728D
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1
	pop bc
	dec b
	jr nz, .l728D
	ret

;Every 16th frame, or at random otherwise, queue sound $02, SFX_Explode - the
;explosions heard on a wrong password.	;[ok]
PasswordErrorNoise:	;$7299
	ld a, [wFrameCounter]
	and $0F
	jr z, .l72A8
	ld e, $30
	call JumpRNG
	cp e
	jr nc, .l72AD
.l72A8
	ld a, $02
	call JumpQueueSound
.l72AD
	ret

;Set BGP to A and wait 8 frames.	;[ok]
PasswordFadeStep:	;$72AE
	ld [wShadowBGP], a
	ld b, $08
	jp PasswordWaitFrames

;Wait one frame, reading the joypad. Falls into the next with B = 1.	;[ok]
PasswordWaitFrame:	;$72B6
	ld b, $01

;Wait B frames, reading the joypad each one.	;[ok]
PasswordWaitFrames:	;$72B8
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1
	call JumpReadJoypad
	pop bc
	dec b
	jr nz, PasswordWaitFrames
	ret

;$72C7-$7394: an unreferenced copy of a sprite-system kit - a variant of
;InitSpriteSystem that pools all 40 OAM entries, then three metasprite-drawing
;helpers. The same bytes sit at bank $0B $4210 (InitSpriteSystem_0B) and bank
;$0E $4255 (InitSpriteSystem_0E), where they are used; here nothing calls them.
;(Addresses corrected in step 5.4.)	;[ok]
InitSpriteSystem_0C:
	ld hl, $CE28
	ld b, $28
	xor a
.l72CD
	ld [hl+], a
	inc a
	dec b
	jr nz, .l72CD
	ld a, $28
	ld [$CE50], a
	ld hl, $CF00
	ld b, $28
	xor a
.l72DD
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l72DD
	ld hl, $CF28
	ld b, $28
	xor a
.l72E9
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l72E9
	ld hl, $CF50
	ld b, $00
	xor a
.l72F5
	ld [hl+], a
	add a, $04
	dec b
	jr nz, .l72F5
	ld hl, $CF77
	ld b, $28
	ld a, $00
.l7302
	ld [hl-], a
	add a, $04
	dec b
	jr nz, .l7302
	ld a, $FF
	ld [$CE58], a
	ld hl, $D240
	ld b, $40
	xor a
.l7313
	ld [hl+], a
	inc a
	dec b
	jr nz, .l7313
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
.l7331
	ld [hl+], a
	add a, $02
	dec b
	jr nz, .l7331
	ret
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

;$7395-$7FFF: unused, all $FF.	;[ok]
	ds $8000 - $7395, $FF
