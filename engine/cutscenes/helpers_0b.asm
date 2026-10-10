;Mega Man: Dr. Wily's Revenge disassembly - the first cutscene's helpers
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Bank 0B Scene Helpers", ROMX[$4C61], BANK[$B]

;Copy a 20x18 tilemap from HL to the BG map at DE. Byte-identical to bank
;$00's CopyTilemap20x18.	;[ok]
CopyTilemap20x18_0B:	;$4C61
	ld c, $12
.row
	ld b, $14
.col
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	ld a, b
	or a
	jr nz, .col
	ld a, $0C
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	dec c
	ld a, c
	or a
	jr nz, .row
	ret

;Wait one frame (DelayFrame through FarCallBank1_0B, then ReadJoypad). Falls
;into the next with B = 1.	;[ok]
CastleCutsceneWaitFrame:	;$4C7B
	ld b, $01

;Wait B frames. If A or B is pressed and the first cutscene has been seen
;($DFCF set), skip it: wAudioBank = 2, SP back to what PlayWilyCutscene saved,
;and `ret` - out of PlayWilyCutscene altogether.	;[ok]
CastleCutsceneWaitFrames:	;$4C7D
	push bc
	ld hl, JumpDelayFrame
	call FarCallBank1_0B
	call JumpReadJoypad
	pop bc
	ldh a, [hJoypadPressed]
	and $03
	jr nz, .pressed
	dec b
	jr nz, CastleCutsceneWaitFrames
	ret
.pressed
	ld a, [$DFCF]
	or a
	ret z
	ld a, $02
	ld [wAudioBank], a
	ld a, [wShotSlots]
	ld l, a
	ld a, [wShotSlots + 1]
	ld h, a
	ld sp, hl
	ret
