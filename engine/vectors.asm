;Mega Man: Dr. Wily's Revenge disassembly - RST and interrupt vectors
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "func0",ROM0[0]
	ld hl,STACK_TOP
	ld sp,hl
	jp Start
	db 1

SECTION "func8",ROM0[8]
	jp FarCallAudio

SECTION "vblank",ROM0[$40]
	jp VBlankHandler

SECTION "lcdc",ROM0[$48]
	jp wRamCode	;memset to `ret`, so a no-op unless a handler is installed

SECTION "timer",ROM0[$50]
	reti

SECTION "serial",ROM0[$58]
	reti

SECTION "joypad",ROM0[$60]
	reti
