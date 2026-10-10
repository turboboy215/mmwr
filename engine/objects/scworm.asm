;Mega Man: Dr. Wily's Revenge disassembly - object type 24, Scworm
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Scworm (type 24)", ROMX[$58D4], BANK[$9]

;Scworm (Will; the ending lists SCWORM).	;[ok]
;Object type 24, placed seven times in Ice Man's stage and in Wily 1/3. Never
;moves. Every 128 frames, while Mega Man is within about $8C px and nothing is
;frozen, it spawns a type 25 above itself, skipping 1 time in 4 (JumpRNG). Its
;$09 is 1 while alive; children still waiting to jump explode when it reads 0.
;Ice Slasher does not stop it. Killed: removed.	;[ok]
ScwormRoutine:	;$58D4
	ld a, b
	or a
	jr z, ScwormInit
	dec a
	jr z, ScwormUpdate
	dec a
	jr z, .l58E1
	dec a
	jr z, ScwormUpdate
.l58E1
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $00
	ret

;Unused: a lone ret nothing reaches (compare Unused_09_4DED).	;[ok]
Unused_09_58EA:	;$58EA
	ret

ScwormInit:	;$58EB
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_5B2A)
	inc l
	ld [hl], HIGH(FrameTable_5B2A)
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret

ScwormUpdate:	;$58FD
	ld a, [wFreezeFlags]
	and $FF
	jp nz, .l595D
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $7F
	jr nz, .l595D
	ld a, [wPlayerX]
	ld e, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub e
	jr nc, .l591C
	cpl
.l591C
	cp $8C
	jr nc, .l595D
	call JumpRNG
	and $03
	cp $02
	ret z
	ld l, c
	push hl
	ld a, $09
	add a, c
	ld l, a
	push hl
	ld a, $19
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0D], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $0B
	ld [$CC0F], a
	xor a
	ld [$CC08], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $01
	ld [$CC05], a
	call SpawnChildObject_09
	pop de
	call ScwormSpawnInit
	pop hl
	ld c, l
.l595D
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld b, $01
	ret
