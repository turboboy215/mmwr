;Mega Man: Dr. Wily's Revenge disassembly - joypad
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "ReadJoypad", ROM0[$157D]

;$157D: read the joypad into hJoypadHeld, and the newly-pressed edge into
;hJoypadPressed.
;
;The d-pad half is read twice and the button half eight times; on real hardware
;the switch matrix needs a few cycles to settle, and the button reads are OR'd
;together rather than simply discarded, so a bit that bounces high anywhere in
;the sequence reads as not-pressed. `cpl` flips the active-low hardware into
;active-high, and the d-pad nibble is swapped into the high half so one byte
;holds all eight inputs.
;
;Returns the held state in A and C. Also stirs the RNG - see below.	;[ok]
ReadJoypad::	;$157D
	di
	ld a,P1F_GET_DPAD
	ldh [rJOYP],a
	ldh a,[rJOYP]
	ldh a,[rJOYP]		;second read: let the matrix settle
	cpl
	and $0F
	swap a			;d-pad into the high nibble
	ld b,a
	ld a,P1F_GET_BTN
	ldh [rJOYP],a
REPT 6
	ldh a,[rJOYP]
ENDR
	ld c,a
	ldh a,[rJOYP]
	or c
	ld c,a
	ldh a,[rJOYP]
	or c			;OR the button reads together to reject bounce
	cpl
	and $0F
	or b			;B holds the d-pad, A the buttons
	ld c,a
	ldh a,[hJoypadHeld]
	xor c
	and c			;set only where it was 0 and is now 1
	ldh [hJoypadPressed],a
	ld a,c
	ldh [hJoypadHeld],a
	ld a,P1F_GET_NONE
	ldh [rJOYP],a
	ei

;Soft reset: A + B + Select + Start held together jumps to $0605.
	ldh a,[hJoypadHeld]
	and PAD_SOFT_RESET
	cp PAD_SOFT_RESET
	jp z,Init.softReset

;Stir the RNG with whatever is held, folded together with the VBlank counter.
;Player input as an entropy source, which is a reasonable trick on a machine
;with no other one.
	ld a,c
	or a
	ret z
	ld hl,wVBlankCount
	xor [hl]
	swap a
	inc hl
	xor [hl]
	ld hl,wRNGSeed
	add a,[hl]
	ld [hl],a
	ld a,c
	ret
