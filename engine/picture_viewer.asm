;Mega Man: Dr. Wily's Revenge disassembly - unused cutscene picture viewers
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Picture Viewer", ROMX[$6411], BANK[$1]

;Four routines nothing calls: each shows one cutscene picture (Wily's castle,
;the skull ship, the Wily Machine phase 1 and 2) and waits for Start - a
;picture viewer, perhaps for testing.	;[ok]
ShowWilyCastle:	;$6411
	di
	call DisableLCD
	call HideAllSpritesAlt
	call LoadWilyCastleScreen
	ld a, $E4
	ld [wShadowBGP], a
	xor a
	ld [wScreenCounter], a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
.l642E
	call DelayFrame
	call ReadJoypad
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l642E
	ret

;Show the skull ship and wait for Start.	;[ok]
ShowSkullShip:	;$643B
	call DisableLCD
	call HideAllSpritesAlt
	call LoadSkullShipScreen
	ld a, $E4
	ld [wShadowBGP], a
	xor a
	ld [wScreenCounter], a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
.l6457
	call DelayFrame
	call ReadJoypad
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l6457
	ret

;Show the Wily Machine, phase 1, and wait for Start.	;[ok]
ShowWilyMachinePhase1:	;$6464
	call DisableLCD
	call HideAllSpritesAlt
	call LoadWilyMachinePhase1Screen
	ld a, $E4
	ld [wShadowBGP], a
	xor a
	ld [wScreenCounter], a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
.l6480
	call DelayFrame
	call ReadJoypad
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l6480
	ret

;Show the Wily Machine, phase 2, and wait for Start.	;[ok]
ShowWilyMachinePhase2:	;$648D
	call DisableLCD
	call HideAllSpritesAlt
	call LoadWilyMachinePhase2Screen
	ld a, $E4
	ld [wShadowBGP], a
	xor a
	ld [wScreenCounter], a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ei
.l64A9
	call DelayFrame
	call ReadJoypad
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l64A9
	ret
