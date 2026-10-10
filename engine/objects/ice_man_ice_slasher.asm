;Mega Man: Dr. Wily's Revenge disassembly - object type 33, IceManIceSlasher
;Part of ROM bank $03 (step 5.3), included from banks/bank03.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "IceManIceSlasher (type 33)", ROMX[$512C], BANK[$3]

;Type 33, three placed beside Ice Man: his Ice Slashers, parked below the
;screen (Y $C0). The first parked one to see $CCF6 clears it, moves to him
;(Y-2), faces Mega Man and flies straight 1 px a frame until it leaves the
;screen, then parks again. Every frame it runs CheckBossDead; once he is beaten
;the first one sets wStageState 2 ($CCF7) and starts the victory countdown once
;($CCF8), returning B = 2. Stops while anything is frozen.	;[ok]
IceManIceSlasherRoutine:	;$512C
	ld a, b
	or a
	jr z, .l5141
	dec a
	jr z, .l5179
	dec a
	jp z, .l513B
	dec a
	jp z, .l513E
.l513B
	ld b, $00
	ret
.l513E
	jp ObjClearFreeze_03
.l5141
	xor a
	ld [wStageSelectAnimPhase], a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], $C0
	ld [hl], $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	xor a
	ld [$CCF7], a
	ld [$CCF8], a
	ld de, IceManIceSlasherAnim
	call AnimateObjectFacing_03
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
.l5179
	ld a, [wFreezeFlags]
	or a
	jp nz, .l513E
	call CheckBossDead_03
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5194
	dec a
	jp z, .l51E9
	dec a
	jp z, IceManIceSlasherVictory
	ret
.l5194
	ld a, [$CCF5]
	or a
	jp nz, IceManIceSlasherBossBeaten
	ld b, $01
	ld a, [wStageSelectAnimPhase]
	or a
	ret z
	xor a
	ld [wStageSelectAnimPhase], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$CCF2]
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [$CCF3]
	sub $02
	ld [hl], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld b, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	cp [hl]
	jr c, .l51CC
	ld b, $01
.l51CC
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], b
	ld a, $24
	add a, c
	ld l, a
	ld [hl], b
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
.l51E9
	ld a, [$CCF5]
	or a
	jp nz, IceManIceSlasherBossBeaten
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l51FF
	ld a, $0D
	add a, c
	ld l, a
	inc [hl]
	jr .l5204
.l51FF
	ld a, $0D
	add a, c
	ld l, a
	dec [hl]
.l5204
	call IceManIceSlasherCheckOffScreen
	ld a, e
	or a
	jr z, .l5225
	ld e, $00
	ld a, $27
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], e
	inc l
	ld [hl], e
	inc l
	ld [hl], e
	inc l
	ld [hl], e
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
.l5225
	ld de, IceManIceSlasherAnim
	call AnimateObjectFacing_03
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

IceManIceSlasherCheckOffScreen:	;$523E
	ld e, $00
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub $A0
	ret c
	ld e, $01
	ret

IceManIceSlasherBossBeaten:	;$524B
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, [$CCF7]
	or a
	jr nz, .l525F
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l525F
	ld e, $C0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], e
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

IceManIceSlasherVictory:	;$527E
	ld a, [$CCF8]
	or a
	jr nz, .l528C
	ld a, $01
	ld [$CCF8], a
	call StartVictoryCountdown_03
.l528C
	ld b, $02
	ret

IceManIceSlasherAnim:	;$528F
	dw FrameTable_03_5295
	db 10	;frames per step
	db $00, $02, $FF

FrameTable_03_5295:	;$5295
	dw Frame_03_529D, Frame_03_52B5, Frame_03_52A9, Frame_03_52C1

Frame_03_529D:	;$529D
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_03_52A9:	;$52A9
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_03_52B5:	;$52B5
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_03_52C1:	;$52C1
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80
