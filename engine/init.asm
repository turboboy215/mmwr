;Mega Man: Dr. Wily's Revenge disassembly - power-on initialisation
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Init", ROM0[$05FE]

;$05FE: power-on initialisation, reached from Entry via Start. Silences
;audio, clears VRAM, all of WRAM and the HRAM variables, sets up the stack, the
;resident bank, the RAM-code block and the OAM DMA routine, then starts a new
;game.
;
;The soft reset in ReadJoypad enters at .softReset, which skips only the two
;writes clearing $DFCF/$DFD0 - and both bytes are wiped a few instructions later
;by the WRAM memset anyway, so the second entry point preserves nothing.	;[ok]
Init::	;$05FE
	xor a
	ld [$DFCF],a
	ld [$DFD0],a
.softReset	;$0605
	xor a
	ld [$CCFC],a
	ld [wSelectedStage],a
	xor a
	ldh [rAUDVOL],a
	ldh [rAUDTERM],a
	ldh [rAUDENA],a
	di
	xor a
	ldh [rIF],a
	ldh [rIE],a
	ld hl,STACK_TOP
	ld sp,hl
	call DisableLCD
	ld hl,VRAM_TILES0	;clear all 8 KB of VRAM
	ld bc,$2000
	xor a
	call FuncMemset
	ld hl,wShadowOAM	;= $C000: clear all 8 KB of WRAM
	ld bc,$2000
	xor a
	call FuncMemset
	ld hl,hJoypadHeld	;= $FF8A: clear the 114 HRAM variable bytes,
	ld bc,$0072		;leaving the DMA routine at $FF80 alone
	xor a
	call FuncMemset
	di
	xor a
	ldh [rIF],a
	ldh [rIE],a
	ld hl,STACK_TOP
	ld sp,hl
	ld a,1
	bankswitch
	call ReadJoypad
	call ClearRamCode
	call InstallOAMDMA
	ld a,0
	ldh [rBGP],a
	ldh [rOBP0],a
	ldh [rOBP1],a
	ld [$DF9F],a
	call EnableLCD
	jp NewGame

;$066A: fill the 92-byte RAM code block with `ret`, so every entry point in it
;is harmless until something installs real code.	;[ok]
ClearRamCode::	;$066A
	ld hl,wRamCode
	ld bc,$5C
	ld a,$C9
	jp FuncMemset
