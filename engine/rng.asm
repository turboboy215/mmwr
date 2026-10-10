;Mega Man: Dr. Wily's Revenge disassembly - random numbers
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "RNG", ROM0[$1758]

;$1758: pseudo-random number generator.
;Increments a counter at $DFAF, indexes RNGTable with it, and XORs the result
;into the running seed at $DFAE. Reached from ROM0 via JumpRNG ($0159).
FuncRNG::
	push hl
	ld hl, wRNGIndex
	inc [hl]
	ld a, [hl]
	add a, LOW(RNGTable)
	ld l, a
	ld a, HIGH(RNGTable)
	adc 0
	ld h, a
	ld a, [wRNGSeed]
	xor [hl]
	ld [wRNGSeed], a
	pop hl
	ret

;$176F: 256 bytes of random values indexed by FuncRNG. Nearly a permutation of
;0-255: $09 and $BA each appear twice, and $00 and $DA not at all.	;[ok]
RNGTable::
	db $4B, $92, $31, $19, $4A, $0D, $A9, $74, $D0, $43, $0F, $8D, $99, $82, $04, $3B
	db $96, $95, $79, $2A, $CB, $13, $32, $DD, $C5, $73, $9B, $B4, $1B, $8F, $CC, $F4
	db $2D, $47, $69, $F7, $34, $7F, $6E, $8C, $67, $87, $1D, $09, $A5, $9A, $80, $08
	db $BB, $6D, $CF, $D9, $CD, $9D, $BD, $2C, $7B, $E6, $D6, $C2, $E4, $F9, $E5, $3C
	db $27, $55, $0B, $45, $81, $B5, $6C, $E9, $28, $5E, $F2, $94, $4E, $3F, $39, $76
	db $41, $7A, $71, $C7, $CE, $20, $D4, $46, $02, $C6, $7D, $F1, $21, $E3, $A8, $3E
	db $98, $54, $D3, $7E, $B6, $52, $6B, $72, $EE, $30, $BC, $26, $C8, $D8, $10, $C3
	db $8E, $DE, $B9, $48, $50, $5A, $6A, $ED, $0E, $51, $53, $49, $36, $57, $B2, $01
	db $97, $63, $C0, $2F, $33, $FB, $AB, $B0, $8B, $38, $14, $3D, $61, $35, $4F, $23
	db $3A, $5C, $6F, $84, $9C, $06, $BA, $90, $85, $F8, $A7, $E0, $42, $4C, $78, $F5
	db $07, $C9, $88, $E1, $E8, $FE, $93, $60, $62, $CA, $24, $A4, $12, $2B, $BA, $C1
	db $B3, $B7, $AE, $37, $77, $FC, $AD, $1A, $4D, $EB, $64, $5F, $D5, $5B, $FA, $17
	db $A0, $0A, $9E, $B8, $18, $AA, $A2, $9F, $05, $86, $22, $F3, $40, $EC, $70, $E2
	db $EA, $DC, $09, $7C, $D7, $E7, $B1, $68, $D2, $03, $56, $89, $A6, $AF, $D1, $C4
	db $58, $15, $F0, $F6, $44, $A1, $25, $BF, $2E, $AC, $8A, $BE, $75, $0C, $65, $66
	db $1F, $DF, $1E, $FD, $29, $FF, $DB, $83, $16, $EF, $A3, $5D, $59, $91, $11, $1C
RNGTableEnd::
