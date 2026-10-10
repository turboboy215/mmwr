;Mega Man: Dr. Wily's Revenge disassembly - copy, fill and table lookups
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Copy and Fill", ROM0[$167E]

FuncFill:: ; $167E - byte-fill: copy BC bytes from HL to DE
	push af
.loop
	ld a,[hli]
	ld [de],a
	inc de
	dec bc
	ld a,b
	or c
	jr nz,.loop
	pop af
	ret

;Copy BC bytes from HL to DE walking downwards (HL and DE are the last bytes),
;like FuncFill in reverse. Nothing calls it. Unused.	;[ok]
CopyBytesBackward:	;$1689
	push af
.loop
	ld a,[hld]
	ld [de],a
	dec de
	dec bc
	ld a,b
	or c
	jr nz,.loop
	pop af
	ret

;$1694: memset. HL = destination, BC = count, A = value. Writes the first byte
;itself, then points DE one past HL and falls into FuncFill, so the copy loop
;drags the value along the whole run. Reachable from ROM0 via the stub at $016B.
;19 call sites across banks $00 and $01.	;[ok]
FuncMemset::	;$1694
	ld [hl],a
	ld e,l
	ld d,h
	inc de
	dec bc
	ld a,b
	or c
	ret z
	jp FuncFill

SECTION "Table Lookups", ROM0[$1960]

;A = [HL + A]. Nothing calls it; GetTablePointer below is the word-sized
;version that the game does use.	;[ok]
GetTableByte:	;$1962
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hl]
	ret

;HL = the word at HL + 2*A: look up entry A of a pointer table. Reachable
;through the stub at $015F; nine call sites in banks $00 and $01.	;[ok]
GetTablePointer::	;$1968
	add a, a
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret
