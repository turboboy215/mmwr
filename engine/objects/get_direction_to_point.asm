;Mega Man: Dr. Wily's Revenge disassembly - GetDirectionToPoint, used by Quick Man and type 47
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Direction Helper 0D", ROMX[$62D2], BANK[$D]

;A = the direction of point (C, B) from (E, D), 0-7 clockwise from up (0 up,
;2 right, 4 down, 6 left); within $18 px counts as level on that axis. The
;same code as bank $09's unused GetDirectionToPoint_09
;($7CF3).	;[ok]
GetDirectionToPoint:	;$62D2
	ld a, e
	add a, $18
	sub c
	jr c, .l62E7
	ld a, e
	sub $18
	sub c
	jr nc, .l62FC
	ld a, d
	sub b
	jr c, .l62E4
	xor a
	ret
.l62E4
	ld a, $04
	ret
.l62E7
	ld a, d
	add a, $18
	sub b
	jr c, .l62F6
	ld a, d
	sub $18
	sub b
	jr nc, .l62F9
	ld a, $02
	ret
.l62F6
	ld a, $03
	ret
.l62F9
	ld a, $01
	ret
.l62FC
	ld a, d
	add a, $18
	sub b
	jr c, .l630B
	ld a, d
	sub $18
	sub b
	jr nc, .l630E
	ld a, $06
	ret
.l630B
	ld a, $05
	ret
.l630E
	ld a, $07
	ret
