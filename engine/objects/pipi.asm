;Mega Man: Dr. Wily's Revenge disassembly - object type 19, Pipi
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Pipi (type 19)", ROMX[$53BF], BANK[$9]

;Pipi (Will; the ending lists PIPI, which is the spelling used here).	;[ok]
;Object type 19, placed in Wily 1 and Wily 3. Waits off screen (X $C0, not
;shootable) until no type 27 or 28 exists, 60 frames have passed and Mega Man is
;in its box; then flies in at Y $18 from the side he faces away from, $0133
;px/frame. Within $1C px of him it drops one type 27 (PipiTryDrop). Leaving the
;screen resets it. Frozen: nothing. Killed: removed.	;[ok]
PipiRoutine:	;$53BF
	ld a, b
	or a
	jr z, .l53D0
	dec a
	jr z, PipiUpdate
	dec a
	jr z, .l53CC
	dec a
	jr z, .l53CF
.l53CC
	ld b, $00
	ret
.l53CF
	ret
.l53D0
	call PipiReset
	ld de, Data_09_5693
	call AnimateObjectFacing_09
	ld b, $01
	ret

PipiReset:	;$53DC
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $3C
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ret

PipiUpdate:	;$53EF
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5426
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, .l543D
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $00
	call PipiWaitToEnter
	jr .l5426
.l5409
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l5420
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	add a, $04
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	jr .l5426
.l5420
	ld de, Data_09_5693
	call AnimateObjectFacing_09
.l5426
	ld de, $D811
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	ld e, [hl]
	add a, [hl]
	ld d, a
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], d
	ld a, $01
	ld b, a
	ld [$CC44], a
	ret
.l543D
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $05
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, $FECD
	jr z, .l5451
	ld de, $0133
.l5451
	ld a, $0C
	add a, c
	ld l, a
	ld a, e
	add a, [hl]
	ld [hl+], a
	ld a, d
	adc a, [hl]
	ld [hl], a
	cp $E0
	jr nc, .l5466
	cp $C0
	jr c, .l5466
	call PipiReset
.l5466
	call PipiTryDrop
	jr .l5409

PipiWaitToEnter:	;$546B
	ld a, $1B
	call FindObjectsOfType_09
	ld a, [$CC00]
	cp $FF
	ret nz
	ld a, $1C
	call FindObjectsOfType_09
	ld a, [$CC00]
	cp $FF
	ret nz
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l548B
	dec [hl]
	ret
.l548B
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	add a, a
	add a, a
	ld e, a
	ld d, $00
	ld b, h
	ld hl, Data_09_54CA
	add hl, de
	call CheckPlayerInBox_09
	ld h, b
	ret c
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $01
	ld a, [wPlayerFacing]
	or a
	ld b, $00
	ld de, $18BE
	jr nz, .l54BC
	inc b
	ld de, $18E2
.l54BC
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld [hl], b
	ret

Data_09_54CA:	;$54CA
	db $01, $9F, $00, $90
	db $01, $9F, $00, $90
	db $01, $9F, $00, $90
	db $01, $9F, $00, $90

PipiTryDrop:	;$54DA
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret z
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l54ED
	cpl
	inc a
.l54ED
	cp $1C
	ret nc
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $00
	ld l, c
	push hl
	ld a, $1B
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ld [$CC0D], a
	inc l
	ld a, [hl]
	add a, $08
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_09
	call PipiEggInit
	pop hl
	ld c, l
	ret
