;Mega Man: Dr. Wily's Revenge disassembly - VRAM-safe writes
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "VRAM-Safe Writes", ROM0[$186F]

;$186F-$1961: VRAM-safe versions of memset, single-byte write and copy. Each
;one checks rLCDC bit 7: with the screen off it simply defers to the plain
;routine; with it on, it writes inside HBlank. The HBlank wait spins while STAT
;mode is 0 and then until it is 0 again, so it always waits for the *start* of
;the next HBlank - one write burst per scanline, and nothing at all during
;VBlank, when the mode is 1. Filling a 1 KB tilemap this way takes about
;seven frames. Interrupts are disabled only around each write.	;[ok]

;Memset that is safe with the LCD on: HL = destination, BC = count, A = value.
;Writes one byte per scanline. With the LCD off it tail-jumps to FuncMemset,
;which clobbers DE despite the push here.	;[ok]
MemsetVRAM:	;$186F
	push de
	ld d, a
	ldh a, [rLCDC]
	and LCDC_ON
	jr nz, .loop
	ld a, d
	pop de
	jp FuncMemset

;Second entry that skips the LCD check and always uses the slow path. Nothing
;calls it.
.alwaysSafe	;$187C
	push de
	ld d, a
.loop
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .waitHBlank
	ld [hl], d
	ei
	inc hl
	dec bc
	ld a, c
	or b
	jr nz, .loop
	pop de
	ret

;[HL] = A, waiting for HBlank first if the LCD is on. Used by DrawTextString to
;put one character at a time.	;[ok]
WriteVRAMByte:	;$1895
	push de
	ld d, a
	ldh a, [rLCDC]
	and LCDC_ON
	jr nz, .wait
	ld [hl], d
	pop de
	ret

;As in MemsetVRAM, a second entry that skips the LCD check. Nothing calls it.
.alwaysSafe	;$18A0
	push de
	ld d, a
.wait
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .waitHBlank
	ld [hl], d
	ei
	pop de
	ret

;Copy BC bytes from HL to DE, safe with the LCD on. With it off this is just
;FuncFill. Reachable through the stub at $0165; ten calls and two tail-jumps in
;banks $00 and $01.	;[ok]
CopyVRAM::	;$18B3
	ldh a, [rLCDC]
	and LCDC_ON
	jr nz, CopyVRAMHBlank
	jp FuncFill

;The LCD-on path of CopyVRAM, which bank $01 also calls directly (three sites
;at $1:5E00-$5E51). Copies in 3-byte bursts, one per HBlank, while at least
;three bytes remain, then finishes with one 2-byte or 1-byte burst.	;[ok]
CopyVRAMHBlank::	;$18BC
	ld a, b
	or a
	jr nz, .bursts
	ld a, c
	cp 3
	jr c, .tail
.bursts
	call CopyVRAM3PerHBlank
	jr z, .done
.tail
	ld a, c
	cp 2
	jr nz, .one
	call CopyVRAM2PerHBlank
	jr .done
.one
	call CopyVRAM1PerHBlank
.done
	ret

;Copy while BC >= 3, three bytes per HBlank. Returns Z if BC reached zero.	;[ok]
CopyVRAM3PerHBlank:	;$18D8
	ld a, b
	or a
	jr nz, .burst
	ld a, c
	cp 3
	ret c
.burst
	push bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hl]
	inc hl
	push hl
	ld l, e
	ld h, d
	ld d, a
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .waitHBlank
	ld [hl], c
	inc hl
	ld [hl], b
	inc hl
	ld [hl], d
	ei
	inc hl
	ld e, l
	ld d, h
	pop hl
	pop bc
	dec bc
	dec bc
	dec bc
	ld a, b
	or c
	jr nz, CopyVRAM3PerHBlank
	ret

;Copy while BC >= 2, two bytes per HBlank.	;[ok]
CopyVRAM2PerHBlank:	;$190B
	ld a, b
	or a
	jr nz, .burst
	ld a, c
	cp 2
	ret c
.burst
	push bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	push hl
	ld l, e
	ld h, d
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .waitHBlank
	ld [hl], c
	inc hl
	ld [hl], b
	ei
	inc hl
	ld e, l
	ld d, h
	pop hl
	pop bc
	dec bc
	dec bc
	ld a, b
	or c
	jr nz, CopyVRAM2PerHBlank
	ret

;Copy while BC >= 1, one byte per HBlank.	;[ok]
CopyVRAM1PerHBlank:	;$1938
	ld a, b
	or a
	jr nz, .burst
	ld a, c
	cp 1
	ret c
.burst
	push bc
	ld c, [hl]
	inc hl
	push hl
	ld l, e
	ld h, d
	di
.waitNotHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .waitNotHBlank
.waitHBlank
	ldh a, [rSTAT]
	and STAT_MODE
	jr nz, .waitHBlank
	ld [hl], c
	ei
	inc hl
	ld e, l
	ld d, h
	pop hl
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, CopyVRAM1PerHBlank
	ret
