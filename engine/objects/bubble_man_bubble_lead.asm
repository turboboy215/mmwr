;Mega Man: Dr. Wily's Revenge disassembly - object type 41, BubbleManBubbleLead
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "BubbleManBubbleLead (type 41)", ROMX[$6A79], BANK[$9]

;Type 41, five placed in Bubble Man's room: his shots, parked off screen (Y
;$C0) until he asks. The first idle one to see $CCF6 = 1 fires a bouncing shot
;from him toward Mega Man; $CCF6 = 2 gives a straight shot, 2 px a frame. Once
;CheckBossDead reports him beaten, the first one sets wStageState 2 and starts the
;victory countdown - his own killed call does neither. Ice Slasher does nothing
;to them.	;[ok]
BubbleManBubbleLeadRoutine:	;$6A79
	ld a, b
	or a
	jr z, .l6A91
	dec a
	jr z, .l6ACE
	dec a
	jp z, .l6A88
	dec a
	jp z, .l6A8B
.l6A88
	ld b, $00
	ret
.l6A8B
	call ObjClearFreeze_09
	jp .l6ACE
.l6A91
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
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	xor a
	ld [$CCF7], a
	ld [$CCF8], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_6C9A)
	inc l
	ld [hl], HIGH(FrameTable_6C9A)
	inc l
	ld [hl], $00
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
.l6ACD
	ret
.l6ACE
	ld a, [wFreezeFlags]
	or a
	jp nz, .l6ACD
	call CheckBossDead_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6AF3
	dec a
	jp z, .l6B14
	dec a
	jp z, .l6B4B
	dec a
	jp z, .l6BA0
	dec a
	jp z, .l6BCC
	jp BubbleManBubbleLeadStartVictory
.l6AF3
	ld a, [$CCF5]
	or a
	jp nz, BubbleManBubbleLeadOnBossDead
	ld b, $01
	ld a, [wStageSelectAnimPhase]
	ld e, a
	or a
	ret z
	xor a
	ld [wStageSelectAnimPhase], a
	ld a, $27
	add a, c
	ld l, a
	ld a, e
	dec a
	jr z, .l6B11
	ld [hl], $03
	ret
.l6B11
	ld [hl], $01
	ret
.l6B14
	ld d, $FC
	ld e, $00
	call BubbleManBubbleLeadPlaceAtBoss
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $31
	add a, c
	ld l, a
	ld [hl], $0A
	inc hl
	ld [hl], $3C
	inc hl
	ld [hl], $02
	call BubbleManBubbleLeadAnimateBounce
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
.l6B4B
	call ObjArcStep_09
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jr nc, .l6B8C
	cp $08
	jr c, .l6B8C
	call ObjMoveX_09
	call ObjMoveY_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $68
	jr c, .l6B76
	ld a, $31
	add a, c
	ld l, a
	ld [hl], $0A
	inc hl
	ld [hl], $3C
	inc hl
	ld [hl], $02
.l6B76
	call BubbleManBubbleLeadAnimateBounce
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
.l6B8C
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	jr .l6B76
.l6BA0
	ld d, $FC
	ld e, $00
	call BubbleManBubbleLeadPlaceAtBoss
	call ObjFaceMegaMan_09
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $02
	call BubbleManBubbleLeadAnimateStraight
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
.l6BCC
	ld e, $FE
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6BD8
	ld e, $02
.l6BD8
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl], a
	cp $C0
	jr c, .l6BE9
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
.l6BE9
	call BubbleManBubbleLeadAnimateStraight
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

BubbleManBubbleLeadPlaceAtBoss:	;$6BFF
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$CCF2]
	add a, d
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [$CCF3]
	sub e
	ld [hl], a
	ret

BubbleManBubbleLeadOnBossDead:	;$6C12
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	ld a, [$CCF7]
	or a
	jr nz, .l6C26
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l6C26
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

BubbleManBubbleLeadStartVictory:	;$6C45
	ld a, [$CCF8]
	or a
	jr nz, .l6C53
	ld a, $01
	ld [$CCF8], a
	call StartVictoryCountdown_09
.l6C53
	ld b, $02
	ret

BubbleManBubbleLeadAnimateStraight:	;$6C56
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	ret c
	ld [hl], $00
	inc hl
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l6C6A
	xor a
	ld [hl], a
.l6C6A
	ld e, a
	ld d, $00
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l6C77
	ld d, $03
.l6C77
	ld a, $17
	add a, c
	ld l, a
	ld a, e
	add a, d
	ld [hl], a
	ret

BubbleManBubbleLeadAnimateBounce:	;$6C7F
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $06
	ret c
	ld [hl], $00
	inc hl
	ld a, [hl]
	and $01
	xor $01
	ld [hl], a
	add a, $06
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

FrameTable_6C9A:	;$6C9A
	dw Frame_6CAA, Frame_6CB4, Frame_6CBE, Frame_6CC8
	dw Frame_6CD2, Frame_6CDC, Frame_6CE6, Frame_6CF2

Frame_6CAA:	;$6CAA
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $00, $01
	db $80

Frame_6CB4:	;$6CB4
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $02, $03
	db $80

Frame_6CBE:	;$6CBE
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $04, $05
	db $80

Frame_6CC8:	;$6CC8
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $81, $80
	db $80

Frame_6CD2:	;$6CD2
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $83, $82
	db $80

Frame_6CDC:	;$6CDC
	db $FC, $03, $FE, $01	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $85, $84
	db $80

Frame_6CE6:	;$6CE6
	db $FC, $03, $FC, $03	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $06, $07, $C7, $47
	db $80

Frame_6CF2:	;$6CF2
	db $FC, $03, $FC, $03	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $08, $09, $C9, $49
	db $80
