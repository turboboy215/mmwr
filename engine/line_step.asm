;Mega Man: Dr. Wily's Revenge disassembly - line stepper
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Line Stepper", ROM0[$1973]

;$1973/$19B5: an integer line-stepper (Bresenham-style) for moving a point
;along a straight line from one position toward another, C pixels per step on
;the major axis. Both are reachable through ROM0 stubs ($0189 and $018C), and
;bank $01 calls them. Banks $03, $09 and $0D each carry their own copy of the
;same code writing the same RAM, so the object banks do not call these. Which
;objects move this way is Phase 5.	;[ok]

;Set up a line from (L, H) toward (E, D) with step size C. Stores both end
;points, |dx| and |dy|, and a signed step for each axis (+C or -C).
;Flaw: the `cpl / inc a / add` absolute-difference trick gets the sign wrong
;when the start coordinate is 0, because the negation of 0 does not carry.	;[ok]
LineStepInit::	;$1973
	ld a, 2
	ld [wLineError], a
	ld a, l
	ld [wLineFromX], a
	ld a, h
	ld [wLineFromY], a
	ld a, e
	ld [wLineToX], a
	ld a, d
	ld [wLineToY], a
	ld b, c
	ld a, l
	cpl
	inc a
	add a, e
	jr c, .xPositive
	cpl
	inc a
	push af
	ld a, c
	cpl
	inc a
	ld b, a
	pop af
.xPositive
	ld [wLineDX], a
	ld a, b
	ld [wLineStepX], a
	ld b, c
	ld a, h
	cpl
	inc a
	add a, d
	jr c, .yPositive
	cpl
	inc a
	ld h, a
	ld a, c
	cpl
	inc a
	ld b, a
	ld a, h
.yPositive
	ld [wLineDY], a
	ld a, b
	ld [wLineStepY], a
	ret

;Advance the point in (E, D) one step along the line set up by LineStepInit.
;The major axis always moves; the minor axis moves when the error accumulator
;overflows past the major-axis distance. Returns NZ (and A non-zero) if either
;coordinate wrapped past 0/255 - presumably "left the screen".	;[ok]
LineStep::	;$19B5
	ld c, $00
	ld a, [wLineDX]
	ld hl, wLineDY
	cp [hl]
	jr nc, .xMajor
	ld a, [wLineError]
	ld hl, wLineDX
	add a, [hl]
	jr c, .stepX
	ld [wLineError], a
	ld hl, wLineDY
	sub [hl]
	jr c, .yOnly
.stepX
	ld [wLineError], a
	ld a, e
	ld hl, wLineStepX
	add a, [hl]
	ld e, a
	jr nc, .yOnly
	inc c
.yOnly
	ld a, d
	ld hl, wLineStepY
	add a, [hl]
	ld d, a
	jr nc, .done
	inc c
	jr .done
.xMajor
	ld a, [wLineError]
	ld hl, wLineDY
	add a, [hl]
	jr c, .stepY
	ld [wLineError], a
	ld hl, wLineDX
	sub [hl]
	jr c, .xOnly
.stepY
	ld [wLineError], a
	ld a, d
	ld hl, wLineStepY
	add a, [hl]
	ld d, a
	jr nc, .xOnly
	inc c
.xOnly
	ld a, e
	ld hl, wLineStepX
	add a, [hl]
	ld e, a
	jr nc, .done
	inc c
.done
	ld a, c
	or a
	ret
