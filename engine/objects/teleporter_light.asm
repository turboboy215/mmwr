;Mega Man: Dr. Wily's Revenge disassembly - object type 53, TeleporterLight
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "TeleporterLight (type 53)", ROMX[$61C3], BANK[$D]

;Type 53, placed in Wily 2's two teleporter hubs (lights 0-3 in the four-teleporter
;hub, 0-4 in the five-teleporter one), param = the teleporter:
;its light. Placed by TeleporterLightPositions (X + 5, Y - $15) and drawn,
;blinking every 12 frames, only while that teleporter's bit in wWilyProgress
;(TeleporterLightBits: Quick Man, Bubble Man, Flash Man, Heat Man, Enker) is
;clear - so it marks the teleporters whose boss is still to beat. Never hurts.
;Killed: removed.	;[ok]
TeleporterLightRoutine:	;$61C3
	ld a, b
	or a
	jr z, TeleporterLightUpdate
	dec a
	jr z, TeleporterLightUpdate
	dec a
	jr z, .l61D0
	dec a
	jr z, TeleporterLightUpdate
.l61D0
	ld b, $00
	ret

TeleporterLightPositions:	;$61D3
	db $0F, $23
	db $8F, $23
	db $0F, $53
	db $8F, $53
	db $4F, $63

TeleporterLightSetPosition:	;$61DD
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	add a, a
	add a, LOW(TeleporterLightPositions)
	ld e, a
	ld a, $00
	adc a, HIGH(TeleporterLightPositions)
	ld d, a
	ld a, [de]
	add a, $05
	ld b, a
	inc de
	ld a, [de]
	sub $15
	ld e, a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], b
	inc l
	inc l
	ld [hl], e
	ret

TeleporterLightUpdate:	;$61FF
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $07
	add a, LOW(TeleporterLightBits)
	ld e, a
	ld a, $00
	adc a, HIGH(TeleporterLightBits)
	ld d, a
	ld a, [de]
	ld e, a
	ld a, [wWilyProgress]
	and e
	ld e, $04
	jr z, .l621A
	ld e, $00
.l621A
	ld a, $11
	add a, c
	ld l, a
	ld [hl], e
	call TeleporterLightSetPosition
	ld de, Data_0D_6240
	call AnimateObjectFacing_0D
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

TeleporterLightBits:	;$623B
	db $01, $02, $04, $08, $10

Data_0D_6240:	;$6240
	dw FrameTable_0D_6246
	db 12	;frames per step
	db $00, $01, $FF

FrameTable_0D_6246:	;$6246
	dw Frame_0D_624A, Frame_0D_6253

Frame_0D_624A:	;$624A
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_0D_6253:	;$6253
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $00	;dx, dy, 0x0

;Two stray bytes after the empty frame, which ends at its zero grid byte.	;[ok]
Data_0D_625A:	;$625A
	db $FF, $80
