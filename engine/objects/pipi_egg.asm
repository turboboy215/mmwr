;Mega Man: Dr. Wily's Revenge disassembly - object type 27, PipiEgg
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "PipiEgg (type 27)", ROMX[$551D], BANK[$9]

;Pipi's egg (Will: Pipi drops eggs with Copipi inside).	;[ok]
;Object type 27: never placed; dropped by type 19 (PipiEggInit). Falls under
;gravity through walls until it is next to Mega Man or a point beside its base is
;solid; then it bursts: it splits into two halves that fly apart in mirrored
;arcs and spawns six type 28s (PipiEggSpawnCopipis). Off screen or killed: frees its
;second sprite and is removed. Frozen: nothing.	;[ok]
PipiEggRoutine:	;$551D
	ld a, b
	or a
	jr z, PipiEggInit
	dec a
	jr z, PipiEggUpdate
	dec a
	jr z, PipiEggRemove
	dec a
	jr z, PipiEggFrozen

PipiEggRemove:	;$552A
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	push hl
	push bc
	call JumpFreeSprite
	pop bc
	pop hl
	ld [hl], $40
	ld b, $00
	ret

;Mode 3 (Ice Slasher): return with B unchanged - nothing happens.	;[ok]
PipiEggFrozen:	;$553B
	ret

PipiEggInit:	;$553C
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_56A5)
	inc l
	ld [hl], HIGH(FrameTable_56A5)
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], $40
	ld de, Data_09_5618
	call ObjSetVelocity_09
	ld b, $01
	ret

;Mode 1: PipiEggUpdateHalves once it has burst (offset $09 = 1), else
;PipiEggFall.	;[ok]
PipiEggUpdate:	;$555A
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jp z, PipiEggUpdateHalves
	jr PipiEggFall

;ObjSyncAndCheckOnScreen; off screen, PipiEggRemove.	;[ok]
PipiEggCheckOnScreen:	;$5565
	call ObjSyncAndCheckOnScreen_09
	ld a, b
	or a
	jr z, PipiEggRemove
	ret

PipiEggFall:	;$556D
	ld a, [wFreezeFlags]
	or a
	jp nz, .l55CA
	call ObjApplyGravity_09
	call ObjMoveByVelocity_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [wPlayerY]
	sub [hl]
	jr nc, .l5586
	cpl
	inc a
.l5586
	cp $04
	jr nc, .l559A
	ld a, $0D
	add a, c
	ld l, a
	ld a, [wPlayerX]
	sub [hl]
	jr nc, .l5596
	cpl
	inc a
.l5596
	cp $0C
	jr c, .l55CC
.l559A
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC0D], a
	add a, $FA
	ld e, a
	inc l
	inc l
	ld a, [hl]
	add a, $03
	ld [$CC0F], a
	ld d, a
	ld l, c
	push hl
	call JumpCheckSolidPoint
	pop hl
	ld c, l
	jr c, .l55CC
	ld a, [$CC0D]
	add a, $05
	ld e, a
	ld a, [$CC0F]
	ld d, a
	ld l, c
	push hl
	call JumpCheckSolidPoint
	pop hl
	ld c, l
	jr c, .l55CC
.l55CA
	jr PipiEggCheckOnScreen
.l55CC
	ld l, c
	push hl
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	call JumpFreeSprite
	ld a, $02
	call JumpAllocSprite
	ld [$CC2E], a
	ld a, $02
	call JumpAllocSprite
	ld e, a
	pop hl
	ld c, l
	ld a, $10
	add a, c
	ld l, a
	ld [hl], e
	ld a, $2E
	add a, c
	ld l, a
	ld a, [$CC2E]
	ld [hl], a
	ld de, Data_09_5614
	call ObjSetVelocity_09
	ld a, $2F
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	call PipiEggMoveHalves
	call PipiEggSpawnCopipis
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	jr .l55CA

Data_09_5614:	;$5614
	dw $0120, $FDA0
Data_09_5618:	;$5618
	dw $0000, $FF00

PipiEggUpdateHalves:	;$561C
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $04
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, [wFreezeFlags]
	or a
	jp nz, .l563F
	ld a, [$DF86]
	and $01
	call z, PipiEggMoveHalves
.l563F
	ld l, c
	push hl
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl+]
	cpl
	ld e, a
	ld a, [hl]
	cpl
	ld d, a
	inc de
	sla e
	rl d
	sla e
	rl d
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl+]
	add a, e
	ld a, [hl]
	adc a, d
	ldh [$FFA2], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	ld hl, Frame_56D1 + 4
	call JumpDrawMetasprite
	pop hl
	ld c, l
	jp PipiEggCheckOnScreen

;Move the burst egg two steps (gravity and velocity twice) and add its X speed
;($1C/$1D) to $2F/$30, which PipiEggUpdateHalves mirrors to place the second
;half.	;[ok]
PipiEggMoveHalves:	;$5675
	call ObjApplyGravity_09
	call ObjMoveByVelocity_09
	call ObjApplyGravity_09
	call ObjMoveByVelocity_09
	ld a, $1C
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, $2F
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	ret

Data_09_5693:	;$5693
	dw FrameTable_5699
	db 20	;frames per step
	db $00, $02, $FF

FrameTable_5699:	;$5699
	dw Frame_56A9, Frame_56F3, Frame_56B7, Frame_5701
	dw Frame_56E5, Frame_570F

FrameTable_56A5:	;$56A5
	dw Frame_56C5, Frame_56DB

Frame_56A9:	;$56A9
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $FF, $00, $03, $01, $02, $04
	db $80

Frame_56B7:	;$56B7
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $FF, $00, $05, $01, $02, $06
	db $80

Frame_56C5:	;$56C5
	db $FC, $07, $FC, $04	;hitbox
	db $FC, $FC, $22	;dx, dy, 2x2
	db $07, $08, $09, $0A
	db $80

Frame_56D1:	;$56D1
	db $00, $00, $00, $00	;hitbox
	db $00, $00, $12	;dx, dy, 1x2
	db $0D, $4D
	db $80

Frame_56DB:	;$56DB
	db $00, $00, $00, $00	;hitbox
	db $00, $00, $12	;dx, dy, 1x2
	db $8D, $CD
	db $80

Frame_56E5:	;$56E5
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $FF, $00, $03, $01, $0E, $0F
	db $80

Frame_56F3:	;$56F3
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $83, $80, $FF, $84, $82, $81
	db $80

Frame_5701:	;$5701
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $85, $80, $FF, $84, $82, $81
	db $80

Frame_570F:	;$570F
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $83, $80, $FF, $8F, $8E, $81
	db $80

PipiEggSpawnCopipis:	;$571D
	ld l, c
	push hl
	ld a, $1C
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
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	xor a
.l573D
	push af
	call PipiEggSpawnCopipi
	pop af
	inc a
	cp $06
	jr c, .l573D
	pop hl
	ld c, l
	ret

PipiEggSpawnCopipi:	;$574A
	ld [$CC08], a
	call SpawnChildObject_09
	jp CopipiInit
