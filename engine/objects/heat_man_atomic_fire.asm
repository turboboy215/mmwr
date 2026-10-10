;Mega Man: Dr. Wily's Revenge disassembly - object type 45, HeatManAtomicFire
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "HeatManAtomicFire (type 45)", ROMX[$793F], BANK[$9]

;Type 45, three placed in Heat Man's room: his fireballs, parked off screen (Y
;$C0). When he writes a count to $CCF6, each takes one (its spread) and jumps
;from him toward Mega Man under gravity, sits on the floor 50 frames, and parks
;again. Once he is beaten the first one sets wStageState 2 and starts the
;victory countdown. Immune to shots (flags $85).	;[ok]
HeatManAtomicFireRoutine:	;$793F
	ld a, b
	or a
	jr z, .l7957
	dec a
	jr z, .l7994
	dec a
	jp z, .l794E
	dec a
	jp z, .l7951
.l794E
	ld b, $00
	ret
.l7951
	call ObjClearFreeze_09
	jp .l7994
.l7957
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
	ld [hl], LOW(FrameTable_7B15)
	inc l
	ld [hl], HIGH(FrameTable_7B15)
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
.l7993
	ret
.l7994
	ld a, [wFreezeFlags]
	or a
	jp nz, .l7993
	call CheckBossDead_09
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l79B1
	dec a
	jp z, .l79D8
	dec a
	jp z, .l7A3D
	jp HeatManAtomicFireStartVictory
.l79B1
	ld a, [$CCF5]
	or a
	jp nz, HeatManAtomicFireBossBeaten
	ld b, $01
	ld a, [wStageSelectAnimPhase]
	ld d, a
	and $03
	ld e, a
	or a
	ret z
	ld a, $2D
	add a, c
	ld l, a
	ld [hl], d
	ld a, e
	dec a
	ld e, a
	ld a, d
	and $80
	or e
	ld [wStageSelectAnimPhase], a
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ret
.l79D8
	xor a
	ld [wStageSelectAnimPhase], a
	call HeatManAtomicFireMoveToBoss
	call ObjFaceMegaMan_09
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $02
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	ld e, $FF
	cp $7F
	jr c, .l79FC
	xor e
.l79FC
	srl a
	srl a
	ld e, a
	call HeatManAtomicFireAddSpread
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	and $80
	jr z, .l7A16
	srl e
	ld a, e
	srl e
	srl e
	add a, e
	ld e, a
.l7A16
	ld a, $31
	add a, c
	ld l, a
	ld [hl], e
	inc hl
	ld [hl], $30
	inc hl
	ld [hl], $02
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $00
	call HeatManAtomicFireAnimate
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
.l7A3D
	xor a
	ld [wStageSelectAnimPhase], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub $6C
	jr c, .l7A56
	ld a, $2B
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $32
	jr nc, .l7A82
	jr .l7A6C
.l7A56
	call ObjArcStep_09
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	cp $A0
	jr nc, .l7A82
	cp $08
	jr c, .l7A82
	call ObjMoveX_09
	call ObjMoveY_09
.l7A6C
	call HeatManAtomicFireAnimate
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
.l7A82
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
	jr .l7A6C

HeatManAtomicFireMoveToBoss:	;$7A96
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
	ret

HeatManAtomicFireBossBeaten:	;$7AA7
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $05
	ld a, [$CCF7]
	or a
	jr nz, .l7ABB
	ld a, $02
	ld [wStageState], a
	ld [$CCF7], a
.l7ABB
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

HeatManAtomicFireStartVictory:	;$7ADA
	ld a, [$CCF8]
	or a
	jr nz, .l7AE8
	ld a, $01
	ld [$CCF8], a
	call StartVictoryCountdown_09
.l7AE8
	ld b, $02
	ret

HeatManAtomicFireAddSpread:	;$7AEB
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	dec a
	swap a
	ld d, a
	ld a, e
	srl d
	add a, d
	ld e, a
	ret

HeatManAtomicFireAnimate:	;$7AFC
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	and $03
	ret nz
	ld [hl+], a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l7B0E
	xor a
	ld [hl], a
.l7B0E
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	ret

FrameTable_7B15:	;$7B15
	dw Frame_7B1B, Frame_7B24, Frame_7B2D

Frame_7B1B:	;$7B1B
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

Frame_7B24:	;$7B24
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $01
	db $80

Frame_7B2D:	;$7B2D
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $02
	db $80
