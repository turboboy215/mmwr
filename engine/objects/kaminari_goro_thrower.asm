;Mega Man: Dr. Wily's Revenge disassembly - object type 14, KaminariGoroThrower
;Part of ROM bank $09 (step 5.2), included from banks/bank09.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "KaminariGoroThrower (type 14)", ROMX[$4ED7], BANK[$9]

;The part of Kaminari Goro that rides type 15 and throws (named from the code).	;[ok]
;Object type 14: never placed; each type 15 spawns one, and stores its own
;record pointer in this object's $2E/$2F. Rides 16 px above the parent. Counts
;$2A from 50 to 100 while facing Mega Man (drawing a type 26 frame beside itself
;from 25 on), then spawns a type 26 (KaminariGoroThrowerSpawnShot) and holds a throw pose for
;20 frames; it throws again only after the type 26 has gone off screen and
;written $A5 to its $28. Frozen: no AI. Returns B = the parent's $09 (its
;on-screen flag), so it goes when the parent does. Killed: frees its extra
;sprite and is removed.	;[ok]
KaminariGoroThrowerRoutine:	;$4ED7
	ld a, b
	or a
	jr z, KaminariGoroThrowerInit
	dec a
	jr z, KaminariGoroThrowerUpdate
	dec a
	jr z, .l4EE4
	dec a
	jr z, .l4EF6
.l4EE4
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	ld l, c
	push hl
	call JumpFreeSprite
	pop hl
	ld c, l
	call KaminariGoroThrowerFollowParent
	ld b, $00
	ret
.l4EF6
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $FF
	jr KaminariGoroThrowerStep

KaminariGoroThrowerInit:	;$4EFE
	ld a, $28
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], $32
	ld l, c
	push hl
	ld a, $02
	call JumpAllocSprite
	pop hl
	ld c, l
	ld e, a
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], e
	ld de, Data_09_5013
	call AnimateObjectFacing_09

;Mode 1 (and the end of KaminariGoroThrowerInit): clear the frozen flag
;(offset $2C) and run KaminariGoroThrowerStep.	;[ok]
KaminariGoroThrowerUpdate:	;$4F1C
	ld a, $2C
	add a, c
	ld l, a
	ld [hl], $00

;Ride the parent (KaminariGoroThrowerFollowParent). Unless wFreezeFlags or
;offset $2C (set to $FF in mode 3) stops it: clear the $A5 the shot leaves in $28
;when it goes off screen; while a shot is out ($28 non-zero),
;KaminariGoroThrowerHoldThrow; else count $2A up to 100 facing Mega Man, then
;KaminariGoroThrowerStartThrow.	;[ok]
KaminariGoroThrowerStep:	;$4F22
	call KaminariGoroThrowerFollowParent
	ld a, [wFreezeFlags]
	or a
	jp nz, KaminariGoroThrowerShowShot
	ld a, $2C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, KaminariGoroThrowerShowShot
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	cp $A5
	jr nz, .l4F3F
	xor a
	ld [hl], a
.l4F3F
	or a
	jp nz, KaminariGoroThrowerHoldThrow
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp $64
	jp nc, KaminariGoroThrowerStartThrow
	inc [hl]
	call ObjFaceMegaMan_09

;Step the thrower's normal two-frame animation.	;[ok]
KaminariGoroThrowerAnimate:	;$4F51
	ld de, Data_09_5013
	call AnimateObjectFacing_09

;While no shot is out ($28 = 0) and $2A >= 25, draw the shot ready beside
;the thrower (KaminariGoroThrowerDrawShotFrame).	;[ok]
KaminariGoroThrowerShowShot:	;$4F57
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, KaminariGoroThrowerCheckParent
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	cp $19
	jr c, KaminariGoroThrowerCheckParent
	call KaminariGoroThrowerDrawShotFrame

;B = the parent platform's offset $09 (its on-screen flag), also into
;$CC44; if the parent is gone, KaminariGoroShotRemove removes this one.	;[ok]
KaminariGoroThrowerCheckParent:	;$4F6B
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	add a, $09
	ld e, a
	inc l
	ld d, [hl]
	ld a, [de]
	ld b, a
	ld [$CC44], a
	or a
	jp z, KaminariGoroShotRemove
	ret

KaminariGoroThrowerShotFrameOffsets:	;$4F7F
	db $F4, $F9, $0C, $F9
	db $F4, $FC, $0C, $FC

KaminariGoroThrowerFollowParent:	;$4F87
	ld a, $2E
	add a, c
	ld l, a
	ld a, [hl]
	add a, $0D
	ld e, a
	inc l
	ld a, [hl]
	ld d, a
	ld a, [de]
	ld b, a
	inc e
	inc e
	ld a, [de]
	ld d, a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], b
	inc l
	inc l
	ld a, d
	sub $10
	ld [hl], a
	ret

KaminariGoroThrowerDrawShotFrame:	;$4FA4
	ld l, c
	push hl
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	push af
	ld e, a
	ld d, $00
	ld b, h
	ld hl, KaminariGoroThrowerShotFrameOffsets
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld h, b
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ldh [$FFA2], a
	inc l
	inc l
	ld a, [hl]
	add a, d
	ldh [$FFA3], a
	ld a, $2B
	add a, c
	ld l, a
	ld e, [hl]
	pop af
	and $01
	ld hl, Frame_5085 + 4
	jr z, .l4FE1
	ld hl, Frame_508F + 4
.l4FE1
	ld a, e
	call JumpDrawMetasprite
	pop hl
	ld c, l
	ret

KaminariGoroThrowerStartThrow:	;$4FE8
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $01
	inc l
	xor a
	ld [hl+], a
	ld [hl+], a
	call KaminariGoroThrowerSpawnShot
	jp KaminariGoroThrowerCheckParent

;Throw pose: for 20 frames (offset $29) show frame facing + 4, then go back
;to KaminariGoroThrowerAnimate.	;[ok]
KaminariGoroThrowerHoldThrow:	;$4FF8
	ld a, $29
	add a, c
	ld l, a
	ld a, [hl]
	cp $14
	jp nc, KaminariGoroThrowerAnimate
	inc [hl]
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	add a, $04
	ld e, a
	ld a, $17
	add a, c
	ld l, a
	ld [hl], e
	jp KaminariGoroThrowerCheckParent

Data_09_5013:	;$5013
	dw FrameTable_5019
	db 20	;frames per step
	db $00, $02, $FF

FrameTable_5019:	;$5019
	dw Frame_5025, Frame_5055, Frame_5035, Frame_5065
	dw Frame_5045, Frame_5075

Frame_5025:	;$5025
	db $F0, $0F, $F8, $07	;hitbox
	db $F0, $F8, $42	;dx, dy, 4x2
	db $00, $01, $02, $FF, $03, $04, $05, $06
	db $80

Frame_5035:	;$5035
	db $F0, $0F, $F8, $07	;hitbox
	db $F0, $F8, $42	;dx, dy, 4x2
	db $07, $01, $02, $FF, $08, $04, $09, $0A
	db $80

Frame_5045:	;$5045
	db $F8, $07, $F8, $07	;hitbox
	db $E8, $F8, $42	;dx, dy, 4x2
	db $FF, $FF, $01, $02, $0B, $0C, $0D, $0E
	db $80

Frame_5055:	;$5055
	db $F0, $0F, $F8, $07	;hitbox
	db $F0, $F8, $42	;dx, dy, 4x2
	db $FF, $82, $81, $80, $86, $85, $84, $83
	db $80

Frame_5065:	;$5065
	db $F0, $0F, $F8, $07	;hitbox
	db $F0, $F8, $42	;dx, dy, 4x2
	db $FF, $82, $81, $87, $8A, $89, $84, $88
	db $80

Frame_5075:	;$5075
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $42	;dx, dy, 4x2
	db $82, $81, $FF, $FF, $8E, $8D, $8C, $8B
	db $80

Frame_5085:	;$5085
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FD, $21	;dx, dy, 2x1
	db $0F, $10
	db $80

Frame_508F:	;$508F
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FD, $21	;dx, dy, 2x1
	db $90, $8F
	db $80

KaminariGoroThrowerSpawnShot:	;$5099
	ld l, c
	push hl
	ld a, $1A
	ld [$CC07], a
	ld a, $24
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, $00F0
	jr z, .l50AD
	ld e, $10
.l50AD
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [$CC0D], a
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_09
	pop de
	push de
	ld b, e
	ld a, $28
	add a, b
	ld e, a
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $24
	add a, c
	ld l, a
	ld a, $24
	add a, b
	ld e, a
	ld a, [de]
	ld [hl], a
	call KaminariGoroShotInit
	pop hl
	ld c, l
	ret
