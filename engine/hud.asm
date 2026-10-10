;Mega Man: Dr. Wily's Revenge disassembly - the HUD
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "HUD", ROMX[$5F68], BANK[$1]

;Build the HUD: install the window split, draw all three parts, copy the
;buffer to the window map and load the weapon letters.	;[ok]
InitHUD:	;$5F68
	call InstallHUDSplit
	call LoadHUDTiles
	call UpdateHUD
	call UpdateHUD
	call UpdateHUD
	ld hl, $C109
	ld de, $9C00
	ld bc, $0014
	push bc
	call FuncFill
	pop bc
	ld de, $9C20
	call FuncFill
	call LoadWeaponLetterTiles
	ret

;Every frame, one of three HUD parts in turn ($C107): weapon bar, health bar,
;lives and boss bar. Each fills its piece of the $C109 buffer and queues a
;copy for VBlank.	;[ok]
UpdateHUD:	;$5F8F
	ld hl, $C107
	ld a, [hl]
	inc a
	cp $03
	jr c, .l5F99
	xor a
.l5F99
	ld [hl], a
	jr z, UpdateHUDWeaponBar
	dec a
	jr z, UpdateHUDHealthBar
	jr UpdateHUDLivesAndBoss

;Queue the 5-byte copy request at HL for VBlank (to $C102, done by
;VBlankCopyHUD).	;[ok]
QueueHUDCopy:	;$5FA1
	ld de, $C102
	ld bc, $0005
	jp FuncFill

HUDCopyWeaponBar:	;$5FAA
	db 7	;tiles per row (non-zero = pending)
	dw $9C00, $C109	;BG map row, buffer row

HUDCopyHealthBar:	;$5FAF
	db 7
	dw $9C07, $C110

HUDCopyLives:	;$5FB4
	db 6
	dw $9C0E, $C117

;HUD part 0: the equipped weapon's bar and the weapon letters' tiles.	;[ok]
UpdateHUDWeaponBar:	;$5FB9
	ld a, [wCurrentWeapon]
	ld b, a
	ld hl, wEnergy
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ld de, $C109
	call DrawHUDBar
	ld hl, $C10E
	ld [hl], $5E
	inc hl
	ld [hl], $5F
	ld hl, $C122
	ld [hl], $60
	inc hl
	ld [hl], $61
	ld hl, HUDCopyWeaponBar
	jr QueueHUDCopy

;HUD part 1: Mega Man's health bar.	;[ok]
UpdateHUDHealthBar:	;$5FE2
	ld de, $C110
	ld b, $01
	ld a, [wEnergy]
	call DrawHUDBar
	ld hl, $C115
	ld [hl], $6D
	inc hl
	ld [hl], $6F
	ld hl, $C129
	ld [hl], $6E
	inc hl
	ld [hl], $50
	ld hl, HUDCopyHealthBar
	jr QueueHUDCopy

;Lives digit (HUDDigitTiles) and, while $C100 is set, the boss's bar from
;$C101.	;[ok]
UpdateHUDLivesAndBoss:	;$6002
	ld a, [wLives]
	ld hl, HUDDigitTiles
	dec a
	call GetTablePointer
	ld a, l
	ld [$C117], a
	ld a, h
	ld [$C12B], a
	ld a, [$C100]
	ld b, a
	ld a, [$C101]
	ld de, $C118
	call DrawHUDBar
	ld hl, HUDCopyLives
	jp QueueHUDCopy

;Draw a two-row energy bar for value A into DE (blank if B = 0).	;[ok]
DrawHUDBar:	;$6027
	add a, $07
	srl a
	srl a
	srl a
	ld c, a
	ld a, b
	or a
	jr nz, .l6047
	ld l, e
	ld h, d
	ld a, $70
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld hl, $0014
	add hl, de
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret
.l6047
	ld b, $05
.l6049
	ld a, c
	cp $04
	ld a, $04
	jr nc, .l6053
	ld a, c
	and $03
.l6053
	add a, a
	add a, LOW(HUDBarTiles)
	ld l, a
	ld a, $00
	adc a, HIGH(HUDBarTiles)
	ld h, a
	ld a, [hl+]
	ld [de], a
	ld a, [hl]
	ld hl, $0014
	add hl, de
	ld [hl], a
	inc de
	ld a, c
	sub $04
	jr nc, .l606B
	xor a
.l606B
	ld c, a
	dec b
	jr nz, .l6049
	ret

;Install the HUD's window split: `jp HUDSplitHandler` into the STAT handler slot
;(wRamCode) and LYC $7F.	;[ok]
InstallHUDSplit:	;$6070
	ld hl, HUDSplitJump
	ld de, wRamCode
	ld bc, $0003
	call FuncFill
	ld a, $89
	ld [$DF9D], a
	ld a, $7F
	ldh [rLYC], a
	cpl
	ld [$DF9E], a
	ld a, $44
	ldh [rSTAT], a
	ret

;Copied to wRamCode by InstallHUDSplit; never run from here.	;[ok]
HUDSplitJump:	;$608E
	jp HUDSplitHandler

HUDBarTiles:	;$6091
	db $73, $73
	db $6B, $6C
	db $69, $6A
	db $67, $68
	db $65, $66

HUDDigitTiles:	;$609B
	db $5A, $5C
	db $51, $52
	db $53, $54
	db $53, $55
	db $56, $57
	db $58, $55
	db $58, $59
	db $5A, $52
	db $5B, $59
	db $5B, $52
