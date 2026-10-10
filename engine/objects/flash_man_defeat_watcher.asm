;Mega Man: Dr. Wily's Revenge disassembly - object type 43, FlashManDefeatWatcher
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FlashManDefeatWatcher (type 43)", ROMX[$73DD], BANK[$9]

;Type 43, placed beside Flash Man: parked off screen (Y $C0) with no movement
;or attack. Once CheckBossDead reports the boss beaten it sets wStageState 2 and
;calls StartVictoryCountdown every 32 frames - Flash Man's own killed call does
;neither. A reduced copy of type 41's end-of-fight code.	;[ok]
FlashManDefeatWatcherRoutine:	;$73DD
	ld a, b
	or a
	jr z, .l73F0
	dec a
	jp z, .l7422
	dec a
	jp z, BossKilled_09
	dec a
	jp z, .l7422
	jp BossKilled_09
.l73F0
	ld a, $27
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [$CCF7], a
	ld [$CCF8], a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], $C0
	ld de, Data_09_7457
	call AnimateObjectFacing_09
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
	ld b, $01
	ret
.l7422
	call CheckBossDead_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l7430
	jp .l7447
.l7430
	ld a, [$CCF5]
	or a
	jr z, .l7444
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l7444
	ld b, $01
	ret
.l7447
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $1F
	jr nz, .l7444
	call StartVictoryCountdown_09
	ld b, $02
	ret

Data_09_7457:	;$7457
	dw FrameTable_745C
	db 30	;frames per step
	db $00, $FF

FrameTable_745C:	;$745C
	dw Frame_745E

Frame_745E:	;$745E
	db $FA, $06, $FA, $06	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $80, $01, $81
	db $80
