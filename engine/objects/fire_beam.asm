;Mega Man: Dr. Wily's Revenge disassembly - object type 10, FireBeam
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "FireBeam (type 10)", ROMX[$474A], BANK[$9]

;Fire beams, which come in several directions (Will). Not in the ending's list.	;[ok]
;Object type 10, placed six times in Fire Man's stage. Spawn: variant = param
;(offset $06) & 3 into $28, moved by FireBeamSpawnOffsets. Variants 0-2 loop a
;34-step animation (6 frames a step) on their own frame table: a strip that grows
;from 2 to 6 tiles (0 upward, 1 leftward, 2 rightward), flickers, shrinks and
;stays empty for 11 steps. Variant 3 steps 8 px right every 6 frames for 7 steps,
;then jumps back 56 px. Flags $85 (immune to shots) unless Ice Slasher is
;equipped ($05). Frozen, or under Time Stopper: no animation, flags $05/$07, so
;it can be hit. Killed or off screen: removed. Will's render: fire pillars and
;horizontal flames.	;[ok]
FireBeamRoutine:	;$474A
	ld a, b
	or a
	jr z, FireBeamInit
	dec a
	jr z, FireBeamUpdate
	dec a
	jr z, .l4757
	dec a
	jr z, FireBeamFrozen
.l4757
	ld b, $00
	ret

FireBeamFrozen:	;$475A
	ld a, $28
	add a, c
	ld l, a
	ld e, $05
	ld a, [hl]
	cp $03
	jr z, .l4767
	ld e, $07
.l4767
	ld a, $11
	add a, c
	ld l, a
	ld [hl], e
	jp ObjSyncAndCheckOnScreen_09

FireBeamInit:	;$476F
	ld a, $06
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	ld b, a
	ld a, $28
	add a, c
	ld l, a
	ld [hl], b
	ld a, $24
	add a, c
	ld l, a
	ld [hl], $00
	ld a, b
	add a, a
	add a, LOW(FireBeamSpawnOffsets)
	ld e, a
	ld a, $00
	adc a, HIGH(FireBeamSpawnOffsets)
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	inc l
	ld a, [de]
	add a, [hl]
	ld [hl+], a
	ld de, Data_09_481C
	call AnimateObjectFacing_09
	jr FireBeamSetImmunity

FireBeamSpawnOffsets:	;$47A0
	db $00, $D0
	db $00, $00
	db $00, $00
	db $00, $F8

FireBeamUpdate:	;$47A8
	ld a, [wFreezeFlags]
	and $FF
	jp nz, FireBeamFrozen
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, FireBeamAnimateUp
	dec a
	jr z, FireBeamAnimateLeft
	dec a
	jr z, FireBeamAnimateRight
	jr FireBeamStepRight

;Flags (offset $11) = $05 if Ice Slasher is the current weapon, else $85
;(immune); then ObjSyncAndCheckOnScreen.	;[ok]
FireBeamSetImmunity:	;$47C0
	ld e, $05
	ld a, [wCurrentWeapon]
	cp $03
	jr z, .l47CB
	ld e, $85
.l47CB
	ld a, $11
	add a, c
	ld l, a
	ld [hl], e
	jp ObjSyncAndCheckOnScreen_09

;Variant 0's frame (offset $28): step the upward beam's animation, then
;FireBeamSetImmunity.	;[ok]
FireBeamAnimateUp:	;$47D3
	ld de, Data_09_481C
	call AnimateObjectFacing_09
	jr FireBeamSetImmunity

;Variant 1: step the leftward beam's animation, then FireBeamSetImmunity.	;[ok]
FireBeamAnimateLeft:	;$47DB
	ld de, Data_09_4842
	call AnimateObjectFacing_09
	jr FireBeamSetImmunity

;Variant 2: step the rightward beam's animation, then FireBeamSetImmunity.	;[ok]
FireBeamAnimateRight:	;$47E3
	ld de, Data_09_4868
	call AnimateObjectFacing_09
	jr FireBeamSetImmunity

;Variant 3: every 6 frames (offset $29) move 8 px right, and on the eighth
;step (offset $2A wraps to 0) jump back 56 px; then animate and
;FireBeamSetImmunity.	;[ok]
FireBeamStepRight:	;$47EB
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	ld [hl], a
	cp $06
	jp c, .l4814
	ld [hl], $00
	inc hl
	inc [hl]
	ld a, [hl]
	and $07
	ld [hl], a
	jr z, .l480C
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, $08
	ld [hl], a
	jp .l4814
.l480C
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	sub $38
	ld [hl], a
.l4814
	ld de, Data_09_488E
	call AnimateObjectFacing_09
	jr FireBeamSetImmunity

Data_09_481C:	;$481C
	dw FrameTable_48AD
	db 6	;frames per step
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $06, $07, $08, $06, $07, $08, $06, $07, $08, $05, $04, $03, $02, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF
Data_09_4842:	;$4842
	dw FrameTable_48BF
	db 6	;frames per step
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $06, $07, $08, $06, $07, $08, $06, $07, $08, $05, $04, $03, $02, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF
Data_09_4868:	;$4868
	dw FrameTable_48D1
	db 6	;frames per step
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $06, $07, $08, $06, $07, $08, $06, $07, $08, $05, $04, $03, $02, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF
Data_09_488E:	;$488E
	dw FrameTable_4895
	db 8	;frames per step
	db $09, $0A, $0B, $FF

FrameTable_4895:	;$4895
	dw Frame_4932, Frame_4932, Frame_4932, Frame_4932
	dw Frame_4932, Frame_4932, Frame_4932, Frame_4932
	dw Frame_4932, Frame_491F, Frame_4928, Frame_4932

FrameTable_48AD:	;$48AD
	dw Frame_4945, Frame_494E, Frame_4958, Frame_4964
	dw Frame_4972, Frame_4982, Frame_4994, Frame_49A8
	dw Frame_49BC

FrameTable_48BF:	;$48BF
	dw Frame_49D0, Frame_49D9, Frame_49E3, Frame_49EF
	dw Frame_49FD, Frame_4A0D, Frame_4A1F, Frame_4A33
	dw Frame_4A47

FrameTable_48D1:	;$48D1
	dw Frame_4A5B, Frame_4A64, Frame_4A6E, Frame_4A7A
	dw Frame_4A88, Frame_4A98, Frame_4AAA, Frame_4ABE
	dw Frame_4AD2

Frame_48E3:	;$48E3
	db $D8, $07, $F8, $07	;hitbox
	db $D8, $F8, $62	;dx, dy, 6x2
	db $8C, $8E, $8E, $8E, $8E, $8E, $8D, $8F, $8F, $8F, $8F, $8F
	db $80

Frame_48F7:	;$48F7
	db $D8, $07, $F8, $07	;hitbox
	db $D8, $F8, $62	;dx, dy, 6x2
	db $90, $92, $92, $92, $92, $92, $91, $93, $93, $93, $93, $93
	db $80

Frame_490B:	;$490B
	db $D8, $07, $F8, $07	;hitbox
	db $D8, $F8, $62	;dx, dy, 6x2
	db $94, $96, $96, $96, $96, $96, $95, $97, $97, $97, $97, $97
	db $80

Frame_491F:	;$491F
	db $FC, $03, $08, $0F	;hitbox
	db $FC, $08, $11	;dx, dy, 1x1
	db $18
	db $80

Frame_4928:	;$4928
	db $FC, $03, $00, $0F	;hitbox
	db $FC, $00, $12	;dx, dy, 1x2
	db $19, $1A
	db $80

Frame_4932:	;$4932
	db $FC, $03, $00, $0F	;hitbox
	db $FC, $00, $12	;dx, dy, 1x2
	db $1B, $1C
	db $80

Frame_493C:	;$493C
	db $09, $08, $09, $08	;hitbox
	db $00, $FC, $11	;dx, dy, 1x1
	db $FF
	db $80

Frame_4945:	;$4945
	db $F8, $07, $2A, $37	;hitbox
	db $F8, $28, $11	;dx, dy, 1x1
	db $FF
	db $80

Frame_494E:	;$494E
	db $F7, $08, $25, $37	;hitbox
	db $F8, $20, $21	;dx, dy, 2x1
	db $04, $05
	db $80

Frame_4958:	;$4958
	db $F7, $08, $1A, $37	;hitbox
	db $F8, $18, $22	;dx, dy, 2x2
	db $08, $09, $0A, $0B
	db $80

Frame_4964:	;$4964
	db $F7, $08, $12, $37	;hitbox
	db $F8, $10, $23	;dx, dy, 2x3
	db $00, $01, $02, $03, $02, $03
	db $80

Frame_4972:	;$4972
	db $F7, $08, $0D, $37	;hitbox
	db $F8, $08, $24	;dx, dy, 2x4
	db $04, $05, $06, $07, $06, $07, $06, $07
	db $80

Frame_4982:	;$4982
	db $F7, $08, $02, $37	;hitbox
	db $F8, $00, $25	;dx, dy, 2x5
	db $08, $09, $0A, $0B, $0A, $0B, $0A, $0B, $0A, $0B
	db $80

Frame_4994:	;$4994
	db $F7, $08, $FA, $37	;hitbox
	db $F8, $F8, $26	;dx, dy, 2x6
	db $00, $01, $02, $03, $02, $03, $02, $03, $02, $03, $02, $03
	db $80

Frame_49A8:	;$49A8
	db $F7, $08, $FD, $37	;hitbox
	db $F8, $F8, $26	;dx, dy, 2x6
	db $04, $05, $06, $07, $06, $07, $06, $07, $06, $07, $06, $07
	db $80

Frame_49BC:	;$49BC
	db $F7, $08, $FA, $37	;hitbox
	db $F8, $F8, $26	;dx, dy, 2x6
	db $08, $09, $0A, $0B, $0A, $0B, $0A, $0B, $0A, $0B, $0A, $0B
	db $80

Frame_49D0:	;$49D0
	db $FA, $07, $F8, $07	;hitbox
	db $F8, $F8, $11	;dx, dy, 1x1
	db $FF
	db $80

Frame_49D9:	;$49D9
	db $F5, $07, $F8, $07	;hitbox
	db $F0, $F8, $12	;dx, dy, 1x2
	db $90, $91
	db $80

Frame_49E3:	;$49E3
	db $EA, $07, $F8, $07	;hitbox
	db $E8, $F8, $22	;dx, dy, 2x2
	db $94, $96, $95, $97
	db $80

Frame_49EF:	;$49EF
	db $E2, $07, $F8, $07	;hitbox
	db $E0, $F8, $32	;dx, dy, 3x2
	db $8C, $8E, $8E, $8D, $8F, $8F
	db $80

Frame_49FD:	;$49FD
	db $DD, $07, $F8, $07	;hitbox
	db $D8, $F8, $42	;dx, dy, 4x2
	db $90, $92, $92, $92, $91, $93, $93, $93
	db $80

Frame_4A0D:	;$4A0D
	db $D2, $07, $F8, $07	;hitbox
	db $D0, $F8, $52	;dx, dy, 5x2
	db $94, $96, $96, $96, $96, $95, $97, $97, $97, $97
	db $80

Frame_4A1F:	;$4A1F
	db $CA, $07, $F8, $07	;hitbox
	db $C8, $F8, $62	;dx, dy, 6x2
	db $8C, $8E, $8E, $8E, $8E, $8E, $8D, $8F, $8F, $8F, $8F, $8F
	db $80

Frame_4A33:	;$4A33
	db $CD, $07, $F8, $07	;hitbox
	db $C8, $F8, $62	;dx, dy, 6x2
	db $90, $92, $92, $92, $92, $92, $91, $93, $93, $93, $93, $93
	db $80

Frame_4A47:	;$4A47
	db $CA, $07, $F8, $07	;hitbox
	db $C8, $F8, $62	;dx, dy, 6x2
	db $94, $96, $96, $96, $96, $96, $95, $97, $97, $97, $97, $97
	db $80

Frame_4A5B:	;$4A5B
	db $F8, $05, $F8, $07	;hitbox
	db $08, $F8, $11	;dx, dy, 1x1
	db $FF
	db $80

Frame_4A64:	;$4A64
	db $F8, $0D, $F8, $07	;hitbox
	db $08, $F8, $12	;dx, dy, 1x2
	db $10, $11
	db $80

Frame_4A6E:	;$4A6E
	db $F8, $15, $F8, $07	;hitbox
	db $08, $F8, $22	;dx, dy, 2x2
	db $16, $14, $17, $15
	db $80

Frame_4A7A:	;$4A7A
	db $F8, $1D, $F8, $07	;hitbox
	db $08, $F8, $32	;dx, dy, 3x2
	db $0E, $0E, $0C, $0F, $0F, $0D
	db $80

Frame_4A88:	;$4A88
	db $F8, $25, $F8, $07	;hitbox
	db $08, $F8, $42	;dx, dy, 4x2
	db $12, $12, $12, $10, $13, $13, $13, $11
	db $80

Frame_4A98:	;$4A98
	db $F8, $2D, $F8, $07	;hitbox
	db $08, $F8, $52	;dx, dy, 5x2
	db $16, $16, $16, $16, $14, $17, $17, $17, $17, $15
	db $80

Frame_4AAA:	;$4AAA
	db $F8, $35, $F8, $07	;hitbox
	db $08, $F8, $62	;dx, dy, 6x2
	db $0E, $0E, $0E, $0E, $0E, $0C, $0F, $0F, $0F, $0F, $0F, $0D
	db $80

Frame_4ABE:	;$4ABE
	db $F8, $35, $F8, $07	;hitbox
	db $08, $F8, $62	;dx, dy, 6x2
	db $12, $12, $12, $12, $12, $10, $13, $13, $13, $13, $13, $11
	db $80

Frame_4AD2:	;$4AD2
	db $F8, $35, $F8, $07	;hitbox
	db $08, $F8, $62	;dx, dy, 6x2
	db $16, $16, $16, $16, $16, $14, $17, $17, $17, $17, $17, $15
	db $80
