;Mega Man: Dr. Wily's Revenge disassembly - arithmetic
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Math", ROM0[$169F]

;$169F: 8x8 -> 16-bit multiply, A * DE -> HL, fully unrolled. No direct call
;site found; like FuncMemset it is presumably reached through one of the ROM0
;stubs.	;[ok]
Mul8x8::	;$169F
	ld hl,$0000
	ld d,h
REPT 7
	rla
	jr nc,.skip\@
	add hl,de
.skip\@
	add hl,hl
ENDR
	rla
	jr nc,.last
	add hl,de
.last
	ret

;$16CB-$1757: a small arithmetic library. None of these four routines has a
;caller anywhere in the ROM - no call or jump to their addresses, and no pointer
;to them in any table - so they appear to be unused. The game does its
;multiplying with Mul8x8 above and its random rolls with FuncRNG directly.
;Behaviour below was checked by simulating each routine's exact instruction
;semantics against Python arithmetic on 20,000 random inputs.	;[ok]

;BC:HL = HL * DE, a full 32-bit product (BC high word). Shift-and-add, 16
;rounds. Preserves A.	;[ok]
Mul16x16:	;$16CB
	push af
	ld c, e
	ld b, d
	ld e, l
	ld d, h
	ld hl, $0000
	ld a, 16
.loop
	add hl, hl
	rl c
	rl b
	jr nc, .next
	add hl, de
	jr nc, .next
	inc bc
.next
	dec a
	jr nz, .loop
	pop af
	ret

;HL = HL / DE, DE = HL % DE. Restoring division, one quotient bit per round.
;Correct for every 16-bit input pair tested (divisor non-zero).	;[ok]
Div16:	;$16E5
	ld c, e
	ld b, d
	ld e, l
	ld d, h
	ld hl, $0000
	ld a, 16
.loop
	push af
	sla e
	rl d
	ld a, l
	adc a, a
	ld l, a
	ld a, h
	adc a, a
	ld h, a
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc a, b
	ld h, a
	jr nc, .fits
	add hl, bc
	jr .next
.fits
	inc de
.next
	pop af
	dec a
	jr nz, .loop
	ld a, e
	ld e, l
	ld l, a
	ld a, d
	ld d, h
	ld h, a
	ret

;DE = BC:DE / [HL], BC = BC:DE % [HL], where HL points at a 16-bit divisor and
;BC must already be smaller than it. Quotient bits are collected inverted in the
;carry flag and fixed up by the `ccf`.
;Flaw: the bit shifted out of B each round is dropped before the compare, so
;the result is only right while the divisor is at most $8000 - in simulation,
;about 89% of results are wrong for divisors above that.	;[ok]
Div32By16:	;$1711
	ld a, 16
	ld [wDivLoopCount], a
.loop
	rl e
	rl d
	rl c
	rl b
	ld a, c
	sub [hl]
	ld c, a
	inc hl
	ld a, b
	sbc a, [hl]
	ld b, a
	dec hl
	jr nc, .fits
	ld a, c
	add a, [hl]
	ld c, a
	inc hl
	ld a, b
	adc a, [hl]
	ld b, a
	dec hl
	scf
.fits
	ccf
	ld a, [wDivLoopCount]
	dec a
	ld [wDivLoopCount], a
	jr nz, .loop
	rl e
	rl d
	ret

;A = a random number from 0 to A-1. Builds the smallest all-ones mask that
;covers A-1, then rerolls FuncRNG until the masked value is below A. With A = 0
;it never returns. Preserves BC.	;[ok]
RandomBelow:	;$173E
	push bc
	ld b, a
	dec a
	ld c, $FF
	or a
.mask
	rr c
	jr nc, .gotMask
	rlca
	jr nc, .mask
.gotMask
	scf
	rl c
.roll
	call FuncRNG
	and c
	cp b
	jr nc, .roll
	pop bc
	ret
