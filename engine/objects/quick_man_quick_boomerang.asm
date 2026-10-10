;Mega Man: Dr. Wily's Revenge disassembly - object type 47, QuickManQuickBoomerang
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "QuickManQuickBoomerang (type 47)", ROMX[$5EC2], BANK[$D]

;Type 47, three placed beside Quick Man: his Quick Boomerangs, parked off
;screen. Each parked one that sees $CCF6 takes a direction from it and counts
;the high nibble down, so the three fan out 22.5 degrees apart: from the boss
;position it flies 2 px a frame (QuickBoomerangVelocities, 16 directions) for
;32 frames, holds 20, then flies at Mega Man until it leaves the screen, and
;parks. Frames 0-3 every 4 frames. Every frame it runs CheckBossDead; once he is
;beaten it parks, the first one sets wStageState 2 ($CCF7) and the victory
;countdown starts once ($CCF8), B = 2. Time Stopper holds it (still ending the
;fight); other freezes stop it.	;[ok]
QuickManQuickBoomerangRoutine:	;$5EC2
	ld a, b
	or a
	jr z, .l5EDA
	dec a
	jr z, QuickBoomerangFrame
	dec a
	jp z, .l5ED1
	dec a
	jp z, .l5ED4
.l5ED1
	ld b, $00
	ret
.l5ED4
	call ObjClearFreeze_0D
	jp QuickBoomerangFrame
.l5EDA
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
	xor a
	ld [hl], $00
	ld [$CCF7], a
	ld [$CCF8], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_0D_6197)
	inc l
	ld [hl], HIGH(FrameTable_0D_6197)
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

QuickBoomerangHold:	;$5F16
	ld b, $01
	ret

QuickBoomerangTimeStopped:	;$5F19
	call CheckBossDead_0D
	ld a, [$CCF5]
	or a
	jp nz, QuickBoomerangBossBeaten
	jr QuickBoomerangHold

QuickBoomerangFrame:	;$5F25
	ld a, [wFreezeFlags]
	bit 3, a
	jr nz, QuickBoomerangTimeStopped
	or a
	jp nz, QuickBoomerangHold
	call CheckBossDead_0D
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l5F46
	dec a
	jp z, QuickBoomerangFly
	dec a
	jp z, QuickBoomerangTurn
	jp QuickBoomerangVictory
.l5F46
	ld a, [$CCF5]
	or a
	jp nz, QuickBoomerangBossBeaten
	ld b, $01
	ld a, [wStageSelectAnimPhase]
	ld e, a
	or a
	ret z
	ld a, $2D
	add a, c
	ld l, a
	ld a, e
	and $F0
	ld d, a
	ld a, e
	and $0F
	dec a
	and $0F
	ld e, a
	ld [hl], a
	ld a, d
	sub $10
	jr nz, .l5F6C
	xor a
	ld e, a
.l5F6C
	or e
	ld [wStageSelectAnimPhase], a
	call QuickBoomerangSetVelocity
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $2A
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [$CCF2]
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [$CCF3]
	ld [hl], a
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

QuickBoomerangPark:	;$5FA3
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ld a, $27
	add a, c
	ld l, a
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

QuickBoomerangBossBeatenInFlight:	;$5FC8
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	ld a, [$CCF7]
	or a
	jr nz, .l5FDC
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l5FDC
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

QuickBoomerangFly:	;$5FFB
	ld a, [$CCF5]
	or a
	jp nz, QuickBoomerangBossBeatenInFlight
	call QuickBoomerangStep
	ld a, $32
	add a, c
	ld l, a
	ld a, [hl+]
	inc hl
	ld e, [hl]
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jp nc, QuickBoomerangPark
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jp nc, QuickBoomerangPark
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $20
	jr c, QuickBoomerangEndFrame
	ld [hl], $00
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, QuickBoomerangEndFrame
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02

;QuickBoomerangAnimate, update the stage X; B = 1.	;[ok]
QuickBoomerangEndFrame:	;$6049
	call QuickBoomerangAnimate
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

QuickBoomerangTurn:	;$605F
	ld a, $2A
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $14
	jr c, QuickBoomerangEndFrame
	push bc
	ld a, $0F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	ld a, [wPlayerY]
	ld b, a
	ld a, [wPlayerX]
	ld c, a
	call GetDirectionToPoint
	pop bc
	sla a
	ld e, a
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], e
	call QuickBoomerangSetVelocity
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $01
	jr QuickBoomerangEndFrame

QuickBoomerangBossBeaten:	;$6099
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $03
	ld a, [$CCF7]
	or a
	jr nz, .l60AD
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l60AD
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

QuickBoomerangVictory:	;$60CC
	ld a, [$CCF8]
	or a
	jr nz, .l60DA
	ld a, $01
	ld [$CCF8], a
	call StartVictoryCountdown_0D
.l60DA
	ld b, $02
	ret

QuickBoomerangAnimate:	;$60DD
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	ret nz
	ld [hl+], a
	ld a, [hl]
	inc a
	and $03
	ld [hl], a
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

QuickBoomerangStep:	;$60F3
	ld a, $1C
	add a, c
	ld l, a
	ld d, h
	ld e, l
	ld a, $31
	add a, c
	ld l, a
	ld a, [de]
	inc de
	ld b, [hl]
	add a, b
	ld [hl+], a
	jr c, .l6108
	ld a, [de]
	ld [hl+], a
	jr .l6113
.l6108
	ld a, [de]
	cp $80
	jr nc, .l6111
	inc a
	ld [hl+], a
	jr .l6113
.l6111
	dec a
	ld [hl+], a
.l6113
	inc de
	ld a, [de]
	inc de
	ld b, [hl]
	add a, b
	ld [hl+], a
	jr c, .l611F
	ld a, [de]
	ld [hl+], a
	jr .l612A
.l611F
	ld a, [de]
	cp $80
	jr nc, .l6128
	inc a
	ld [hl+], a
	jr .l612A
.l6128
	dec a
	ld [hl+], a
.l612A
	ret

QuickBoomerangSetVelocity:	;$612B
	ld a, $31
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	inc hl
	ld [hl], a
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	push hl
	ld hl, QuickBoomerangVelocities
	sla a
	sla a
	ld d, $00
	ld e, a
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld a, $1C
	add a, c
	ld l, a
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	ret

;X, Y speed (8.8) for 16 directions clockwise from up, 2 px a frame.	;[ok]
QuickBoomerangVelocities:	;$6157
	db $00, $00, $00, $FE
	db $C4, $00, $28, $FE
	db $6C, $01, $98, $FE
	db $D8, $01, $3C, $FF
	db $00, $02, $00, $00
	db $D8, $01, $C4, $00
	db $6C, $01, $68, $01
	db $C4, $00, $D8, $01
	db $00, $00, $00, $02
	db $3C, $FF, $D8, $01
	db $98, $FE, $6C, $01
	db $28, $FE, $C4, $00
	db $00, $FE, $00, $00
	db $28, $FE, $3C, $FF
	db $94, $FE, $98, $FE
	db $3C, $FF, $28, $FE

FrameTable_0D_6197:	;$6197
	dw Frame_0D_619F, Frame_0D_61A8, Frame_0D_61B1, Frame_0D_61BA

Frame_0D_619F:	;$619F
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_0D_61A8:	;$61A8
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $01
	db $80

Frame_0D_61B1:	;$61B1
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $40
	db $80

Frame_0D_61BA:	;$61BA
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $C1
	db $80
