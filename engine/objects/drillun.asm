;Mega Man: Dr. Wily's Revenge disassembly - object type 13, Drillun
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Drillun (type 13)", ROMX[$4DDD], BANK[$9]

;Drillun (type 13; Will, from its official artwork - a drill with a green cap
;and eyes - and the ending's DRILLUN entry). Unused: no stage places it, no
;SpawnChildObject call spawns it, and the ending's script skips its entry.	;[ok]
;The code: a solid object (AddSolidBox, X-8..X+7, Y-8..Y) that falls under
;gravity until the point below it is solid, then rises 1.5 px a frame to Y $20
;and falls again, moving Mega Man by its Y change when he stands on it.
;CheckPlayerOnObject is called with no box set up (compare type 15), so that
;part cannot work as written. Modes 1 and 3 are the same. Killed: removed.	;[ok]
DrillunRoutine:	;$4DDD
	ld a, b
	or a
	jr z, DrillunInit
	dec a
	jr z, DrillunUpdate
	dec a
	jr z, .l4DEA
	dec a
	jr z, DrillunUpdate
.l4DEA
	ld b, $00
	ret

;Unused: a lone ret nothing reaches (between the mode dispatch and
;DrillunInit; compare Unused_09_58EA).	;[ok]
Unused_09_4DED:	;$4DED
	ret

DrillunInit:	;$4DEE
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld de, Data_09_4EA6
	call AnimateObjectFacing_09
	ld b, $01
	ret

DrillunUpdate:	;$4E06
	ld a, [wFreezeFlags]
	or a
	jp nz, .l4E16
	call DrillunMove
	ld de, Data_09_4EA6
	call AnimateObjectFacing_09
.l4E16
	call DrillunAddSolidBox
	ret

DrillunMove:	;$4E1A
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr z, DrillunFall
	dec a
	jr z, DrillunRise
	inc [hl]
	ld a, $1C
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a

DrillunCarryPlayer:	;$4E2F
	call CheckPlayerOnObject_09
	jr nc, .l4E47
	ld a, $2F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	sub d
	ld d, a
	ld e, $00
	ld b, h
	call PushPlayer_09
	ld h, b
.l4E47
	ld a, $0F
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $2F
	add a, c
	ld l, a
	ld [hl], d
	ret

DrillunFall:	;$4E52
	call ObjFallAndMove_09
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld a, [hl]
	add a, $08
	ld d, a
	ld l, c
	push hl
	call JumpCheckSolidPoint
	pop hl
	ld c, l
	jr nc, DrillunCarryPlayer
	ld de, DrillunRiseVelocity
	call ObjSetVelocity_09
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $02
	jr DrillunCarryPlayer

DrillunRiseVelocity:	;$4E77
	dw $0000, $FE80

DrillunRise:	;$4E7B
	call ObjMoveByVelocity_09
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $20
	jr nc, DrillunCarryPlayer
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	jr DrillunCarryPlayer

DrillunAddSolidBox:	;$4E8F
	ld l, c
	push hl
	ld a, $0D
	add a, c
	ld l, a
	ld c, [hl]
	inc l
	inc l
	ld b, [hl]
	ld hl, DrillunSolidBox
	call JumpAddSolidBox
	pop hl
	ld c, l
	ret

DrillunSolidBox:	;$4EA2
	db $F8, $07, $F8, $00

Data_09_4EA6:	;$4EA6
	dw FrameTable_4EAD
	db 5	;frames per step
	db $00, $01, $02, $FF

FrameTable_4EAD:	;$4EAD
	dw Frame_4EB3, Frame_4EBF, Frame_4ECB

Frame_4EB3:	;$4EB3
	db $F8, $07, $00, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_4EBF:	;$4EBF
	db $F8, $07, $00, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $04, $05
	db $80

Frame_4ECB:	;$4ECB
	db $F8, $07, $00, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $06, $07
	db $80
