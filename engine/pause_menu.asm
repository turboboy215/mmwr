;Mega Man: Dr. Wily's Revenge disassembly - the pause (weapon) menu
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Pause Menu", ROMX[$5C9C], BANK[$1]

;The pause menu, from PlayerControl on Start. Frees the shots, loads the font,
;draws the weapon list and slides the window up over the playfield; the d-pad
;moves the selection (blinking), A, B or Start closes it. Choosing a different
;weapon calls EquipWeapon. Then slides back and restores the object tiles the
;font overwrote.	;[ok]
PauseMenu:	;$5C9C
	ld a, $21
	call QueueSound
	call FreeAllShots
	call DelayFrame
	ld de, $8900
	call LoadFontTiles
	call DrawPauseMenu
	ld b, $7F
.l5CB2
	call DelayFrame
	ld a, b
	ldh [rLYC], a
	cpl
	ld [$DF9E], a
	ld a, b
	cp $1F
	jr c, .l5CC6
	sub $08
	ld b, a
	jr .l5CB2
.l5CC6
	ld a, [wCurrentWeapon]
	ld [$C300], a
	xor a
	ld [$C302], a
.l5CD0
	call DelayFrame
	call ReadJoypad
	ldh a, [hJoypadPressed]
	and $0B
	jr nz, .l5CE1
	call PauseMenuInput
	jr .l5CD0
.l5CE1
	ld a, [$C300]
	ld hl, wCurrentWeapon
	cp [hl]
	jr z, .l5CEE
	ld [hl], a
	call EquipWeapon
.l5CEE
	ld a, $21
	call QueueSound
	ld b, $1F
.l5CF5
	call DelayFrame
	ld a, b
	ldh [rLYC], a
	cpl
	ld [$DF9E], a
	ld a, b
	cp $7F
	jr nc, .l5D09
	add a, $08
	ld b, a
	jr .l5CF5
.l5D09
	call ReloadObjectTilesAfterMenu
	call ReadJoypad
	ret

;One frame of pause-menu input. Up/down walk the unlocked weapons; left/right
;jump between the two columns of six.	;[ok]
PauseMenuInput:	;$5D10
	ld a, [$C300]
	ld [$C301], a
	ld c, a
	ldh a, [hJoypadPressed]
	and $F0
	jr z, .l5D22
	ld a, $0B
	call QueueSound
.l5D22
	ldh a, [hJoypadPressed]
	rlca
	jr c, .l5D57
	rlca
	jr c, .l5D6A
	rlca
	jr c, .l5D31
	rlca
	jp nc, .l5D88
.l5D31
	ld a, c
	cp $06
	jr nc, .l5D44
	call CountRightColumnWeapons
	jr z, .l5D80
	ld a, c
	add a, $06
	cp $0B
	jr nc, .l5D80
	jr .l5D4C
.l5D44
	call CountLeftColumnWeapons
	jr z, .l5D80
	ld a, c
	sub $06
.l5D4C
	ld c, a
	call GetWeaponUnlockBit
	and [hl]
	jr nz, .l5D7C
	ld a, c
	ld [$C300], a
.l5D57
	ld a, [$C300]
.l5D5A
	inc a
	cp $0B
	jr c, .l5D60
	xor a
.l5D60
	ld c, a
	call GetWeaponUnlockBit
	and [hl]
	ld a, c
	jr z, .l5D5A
	jr .l5D7C
.l5D6A
	ld a, [$C300]
.l5D6D
	dec a
	bit 7, a
	jr z, .l5D74
	ld a, $0A
.l5D74
	ld c, a
	call GetWeaponUnlockBit
	and [hl]
	ld a, c
	jr z, .l5D6D
.l5D7C
	ld a, c
	ld [$C300], a
.l5D80
	ld a, [$C301]
	ld b, $01
	call DrawPauseMenuLetters
.l5D88
	ld hl, $C302
	inc [hl]
	ld a, [hl]
	cp $06
	ld b, $00
	jr c, .l5D9B
	cp $11
	ld b, $01
	jr c, .l5D9B
	ld [hl], $00
.l5D9B
	ld a, [$C300]

;Draw weapon A's two letters (B = 1) or blanks (B = 0) at its place in the
;menu - the selection blinks by alternating the two.	;[ok]
DrawPauseMenuLetters:	;$5D9E
	ld de, $DCD0
	push de
	call GetWeaponLetters
	ld hl, PauseMenuLetterPositions
	call GetTablePointer
	ld e, l
	ld d, h
	pop hl
	ld bc, $0002
	call CopyVRAM
	ret

PauseMenuLetterPositions:	;$5DB5
	dw $9C62, $9CA2, $9CE2, $9D22
	dw $9D62, $9DA2, $9C6B, $9CAB
	dw $9CEB, $9D2B, $9D6B

;Count the unlocked weapons in the left column (bits 0-5 of
;wWeaponsUnlocked1).	;[ok]
CountLeftColumnWeapons:	;$5DCB
	ld a, [wWeaponsUnlocked1]
	and $3F

;Count the set bits among the low six of A (Z if none).	;[ok]
CountLowSixBits:	;$5DD0
	ld e, a
	xor a
	ld d, $06
.l5DD4
	rrc e
	adc a, $00
	dec d
	jr nz, .l5DD4
	or a
	ret

;Count the unlocked weapons in the right column (the rest).	;[ok]
CountRightColumnWeapons:	;$5DDD
	ld a, [wWeaponsUnlocked1]
	ld e, a
	ld a, [wWeaponsUnlocked2]
	and $07
	rlc e
	rl a
	rlc e
	rl a
	jr CountLowSixBits

;Draw the pause menu's six rows into the window map ($9C40 on): each row has
;a left and a right weapon with its letters and energy bar.	;[ok]
DrawPauseMenu:	;$5DF0
	ld hl, wWeaponsUnlocked2
	ld a, [hl]
	and $07
	ld [hl], a
	ld hl, BlankMenuRow
	ld de, $9C40
	ld bc, $0014
	call CopyVRAMHBlank
	ld hl, $DCD0
	ld a, $70
	ld bc, $0014
	call FuncMemset
	ld hl, $DCD0
	ld a, $70
	ld [$DCD0], a
	ld [$DCE3], a
	ld c, $00
.l5E1B
	ld de, $DCD2
	ld a, c
	push bc
	call DrawPauseMenuEntry
	pop bc
	ld a, c
	add a, $06
	ld de, $DCDB
	push bc
	call DrawPauseMenuEntry
	pop bc
	push bc
	ld a, c
	add a, a
	add a, $03
	ld d, a
	ld e, $00
	call GetMenuRowAddress
	ld hl, $DCD0
	ld bc, $0014
	push de
	call CopyVRAMHBlank
	pop de
	ld hl, $0020
	add hl, de
	ld e, l
	ld d, h
	ld hl, BlankMenuRow
	ld bc, $0014
	call CopyVRAMHBlank
	pop bc
	inc c
	ld a, c
	cp $06
	jr c, .l5E1B
	ret

BlankMenuRow:	;$5E5C
	db $70, $70, $70, $70, $70, $70, $70, $70, $70, $70
	db $70, $70, $70, $70, $70, $70, $70, $70, $70, $70

;DE = $9C00 + D * 32 + E: the window map at row D, column E.	;[ok]
GetMenuRowAddress:	;$5E70
	push hl
	ld a, d
	swap a
	ld h, a
	and $F0
	ld l, a
	ld a, h
	and $01
	ld h, a
	add hl, hl
	ld d, $9C
	add hl, de
	ld e, l
	ld d, h
	pop hl
	ret

;Weapon A's letters and energy bar into the row buffer at DE (blank if not
;unlocked).	;[ok]
DrawPauseMenuEntry:	;$5E84
	push af
	call GetWeaponUnlockBit
	and [hl]
	ld b, $00
	jr z, .l5E8E
	inc b
.l5E8E
	pop af
	call GetWeaponLetters
	ld hl, wEnergy
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	call DrawMenuEnergyBar
	ret

;HL = the unlock byte for weapon A, A = its bit.	;[ok]
GetWeaponUnlockBit:	;$5EA0
	ld hl, wWeaponsUnlocked1
	cp $08
	jr c, .l5EAA
	sub $08
	inc hl
.l5EAA
	push hl
	ld hl, BitMasks
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	pop hl
	ret

;$5EB7: single-bit masks. Bank $00 also indexes this from $5EB6.	;[ok]
BitMasks:	;$5EB7
	db $01, $02, $04, $08, $10, $20, $40, $80

;Five bar tiles for an energy value A (a tile per 8 points, $98 = full).	;[ok]
DrawMenuEnergyBar:	;$5EBF
	add a, $07
	srl a
	srl a
	srl a
	ld c, a
	ld a, b
	or a
	jr nz, .l5ED6
	ld l, e
	ld h, d
	ld a, $70
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret
.l5ED6
	ld b, $05
.l5ED8
	ld a, c
	cp $04
	ld a, $04
	jr nc, .l5EE2
	ld a, c
	and $03
.l5EE2
	add a, LOW(MenuBarTiles)
	ld l, a
	ld a, $00
	adc a, HIGH(MenuBarTiles)
	ld h, a
	ld a, [hl]
	ld [de], a
	inc de
	ld a, c
	sub $04
	jr nc, .l5EF3
	xor a
.l5EF3
	ld c, a
	dec b
	jr nz, .l5ED8
	ret

MenuBarTiles:	;$5EF8
	db $73, $AD, $AC, $AB, $AA

;Write weapon A's two letters to DE (blanks if B = 0).	;[ok]
GetWeaponLetters:	;$5EFD
	push af
	ld l, a
	ld a, b
	or a
	jr nz, .l5F0A
	ld a, $70
	ld [de], a
	inc de
	ld [de], a
	jr .l5F18
.l5F0A
	ld h, $00
	add hl, hl
	push de
	ld de, WeaponLetters
	add hl, de
	pop de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
.l5F18
	inc de
	pop af
	ret

;Two letters per weapon for the pause menu and the HUD, in the `menu` charmap
;(the font loaded at $8900): the first letters of the robot master each weapon
;comes from - P for the Mega Buster, CA for Carry, HE (Heat Man), FL (Flash Man)
;and EN (Enker) for the three Wily weapons.	;[ok]
WeaponLetters:	;$5F1B
	SETCHARMAP menu
	db "P "	;Mega Buster
	db "CU"	;Rolling Cutter
	db "EL"	;Thunder Beam
	db "IC"	;Ice Slasher
	db "FI"	;Fire Storm
	db "CA"	;Carry
	db "HE"	;Atomic Fire
	db "FL"	;Time Stopper
	db "QU"	;Quick Boomerang
	db "BU"	;Bubble Lead
	db "EN"	;Mirror Buster
	SETCHARMAP main

;After the pause menu: the font was loaded over sprite tiles $90 and up, so
;rewind the object-tile cache ($C3C4) to the first tileset that reached them and
;reload it and everything after.	;[ok]
ReloadObjectTilesAfterMenu:	;$5F31
	ld c, $0C
	ld hl, $C3C4
.l5F36
	ld a, [hl+]
	or a
	jr z, .l5F43
	ld a, [hl+]
	cp $90
	jr nc, .l5F50
	dec c
	jr nz, .l5F36
	ret
.l5F43
	ld a, [$C3B3]
	cp $90
	ret z
	ret c
	dec hl
	dec hl
	ld a, [hl]
	dec hl
	jr .l5F57
.l5F50
	dec hl
	dec hl
	jr z, .l5F57
	dec hl
	ld a, [hl]
	dec hl
.l5F57
	ld [$C3B3], a
.l5F5A
	ld a, [hl]
	or a
	ret z
	ld [hl], $00
	push hl
	call LoadObjectTiles
	pop hl
	inc hl
	inc hl
	jr .l5F5A
