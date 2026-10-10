;Mega Man: Dr. Wily's Revenge disassembly - enemy shots
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Enemy Shots", ROM0[$3773]

;$3773-$3978: enemy shots - small projectiles kept apart from the 24-slot
;object system. Up to 12, each a 16-byte record at $CD1B + 16n:
;  +$01/+$02 X velocity / fraction, +$03/+$04 X velocity high / X
;  +$05/+$06, +$07/+$08 the same for Y
;  +$09 tile, +$0A damage on touching Mega Man, +$0B sprite handle (1 OAM entry)
;Active list $CD00-$CD0B with count $CD0D; free stack $CD0E-$CD19, pointer $CD1A.
;
;Move and draw every shot, retiring those that report B = 0: the last entry
;fills the gap, the record goes back on the free stack and its sprite is freed.
;Called from the stage loop at $0A23.	;[ok]
UpdateEnemyShots:	;$3773
	ld hl, $CD0D
	ld a, [hl]
	or a
	ret z
	ld b, a
	ld l, $00
.l377C
	ld h, $CD
	ld a, [hl+]
	ld c, l
	push bc
	ld l, a
	call UpdateEnemyShot
	ld a, b
	or a
	jr nz, .l37A8
	pop bc
	dec c
	push bc
	ld l, $0D
	dec [hl]
	ld l, [hl]
	ld a, [hl]
	ld l, c
	ld b, [hl]
	ld [hl], a
	ld a, [$CD1A]
	dec a
	ld l, a
	ld [hl], b
	ld [$CD1A], a
	ld l, c
	push hl
	ld a, $0B
	add a, b
	ld l, a
	ld a, [hl]
	call FreeSprite
	pop hl
.l37A8
	pop bc
	ld l, c
	dec b
	jr nz, .l377C
	ret

;Update one shot (record C in page $CD). Adds the scroll delta $D851 to X, and
;moves it unless $DFB1 & $0F is set. Returns B = 0 when it should go: off
;screen (X $C0-$DF or Y $90-$EF), after it touches Mega Man (HurtPlayerByShot,
;damage from +$0A, skipped while $D838 is non-zero), or when Mirror Buster
;(weapon 10) is equipped and one of its shots hits it - bank $01 $4FD0 then
;handles the reflection. Otherwise it writes the shot's OAM entry (OBP1) and
;returns B = 1.	;[ok]
UpdateEnemyShot:	;$37AE
	ld c, l
	ld a, $04
	add a, c
	ld l, a
	ld a, [$D851]
	add a, [hl]
	ld [hl], a
	ld a, [wFreezeFlags]
	and $0F
	jr z, .l37CB
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	jr .l37DD
.l37CB
	ld a, $01
	add a, c
	ld l, a
	ld a, [hl+]
	add a, [hl]
	ld [hl+], a
	ld a, [hl+]
	adc a, [hl]
	ld [hl+], a
	ld e, a
	ld a, [hl+]
	add a, [hl]
	ld [hl+], a
	ld a, [hl+]
	adc a, [hl]
	ld [hl+], a
	ld d, a
.l37DD
	ld a, e
	cp $E0
	jr nc, .l37E7
	cp $C0
	jp nc, .l3881
.l37E7
	ld a, d
	cp $F0
	jr nc, .l37F1
	cp $90
	jp nc, .l3881
.l37F1
	ld hl, $D838
	ld a, [hl]
	inc hl
	or [hl]
	jr nz, .l3815
	ld hl, $D841
	ld a, e
	cp [hl]
	jr c, .l3815
	inc hl
	cp [hl]
	jr nc, .l3815
	inc hl
	ld a, d
	cp [hl]
	jr c, .l3815
	inc hl
	cp [hl]
	jr nc, .l3815
	ld h, $CD
	call HurtPlayerByShot
	jp .l3881
.l3815
	ld h, $CD
	ld a, [wCurrentWeapon]
	cp $0A
	jr nz, .l3835
	push de
	ld l, c
	push hl
	ld a, $01
	ld [$CC46], a
	ld c, e
	ld b, d
	call CheckShotHit
	pop hl
	ld c, l
	pop de
	jr z, .l3835
	call CaptureEnemyShot
	jr .l3881
.l3835
	ld h, $CD
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	ld l, e
	ld h, d
	call HitboxViewerCheck
	ld h, $CD
	ld a, $0B
	add a, c
	ld l, a
	ld l, [hl]
	ld h, $D1
	ld l, [hl]
	dec h
	inc l
	ld a, [hl]
	ld h, $CF
	cp $FE
	jr z, .l387B
	ld l, a
	ld e, [hl]
	ld d, $C0
	ld h, $CD
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	add a, $0C
	ld [de], a
	inc e
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	add a, $05
	ld [de], a
	inc e
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	ld a, $10
	inc e
	ld [de], a
.l387B
	ld b, $01
	ret
	jr .l387B	;unreachable, and the $00 after it too
	nop
.l3881
	ld h, $CD
	ld b, $00
	ret

;Empty the shot system: the free stack gets the twelve slots, the count 0.
;Called while setting up a sub-section ($330C).	;[ok]
InitEnemyShots:	;$3886
	ld hl, EnemyShotSlots
	ld de, $CD0E
	ld a, e
	ld [$CD1A], a
	ld b, $0C
.l3892
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, .l3892
	xor a
	ld [$CD0D], a
	ret

;Low bytes of the twelve 16-byte shot records, $CD1B-$CDCB.	;[ok]
EnemyShotSlots:	;$389D
	db $1B, $2B, $3B, $4B, $5B, $6B, $7B, $8B
	db $9B, $AB, $BB, $CB

;Fire a shot from (E, D) in direction hBank1CallIndex (0-15, see
;EnemyShotVelocities), with tile B and touch damage L. Takes a sprite handle
;with one OAM entry and queues sound $05. Returns carry, firing nothing, if 12
;shots are already out. Reachable through the stub at $0153, which banks $03
;and $09 appear to call (four `call $0153` patterns, not yet confirmed as code).	;[ok]
FireEnemyShot:	;$38A9
	ldh [hBank1CallIndex], a
	ld a, l
	ldh [$FF95], a
	ld a, h
	ldh [$FF96], a
	ld hl, $CD0D
	ld a, [hl]
	cp $0C
	ccf
	ret c
	inc [hl]
	ld c, a
	ld a, b
	ldh [$FF92], a
	push de
	push bc
	ld a, $01
	call AllocSprite
	ldh [$FF93], a
	ld a, b
	ldh [$FF94], a
	pop bc
	pop de
	ld h, $CD
	ld a, [$CD1A]
	ld l, a
	inc a
	ld [$CD1A], a
	ld b, [hl]
	ld l, c
	ld [hl], b
	ld l, b
	ld c, b
	ld [hl], $00
	inc l
	inc l
	ld [hl], $00
	inc l
	inc l
	ld [hl], e
	inc l
	inc l
	ld [hl], $00
	inc l
	inc l
	ld [hl], d
	ldh a, [hBank1CallIndex]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld de, EnemyShotVelocities
	add hl, de
	ld e, l
	ld d, h
	ld h, $CD
	ld l, c
	inc l
	ld a, [de]
	inc de
	ld [hl+], a
	inc l
	ld a, [de]
	inc de
	ld [hl+], a
	inc l
	ld a, [de]
	inc de
	ld [hl+], a
	inc l
	ld a, [de]
	inc de
	ld [hl+], a
	inc l
	ldh a, [$FF92]
	ld [hl+], a
	ldh a, [$FF95]
	ld [hl+], a
	ldh a, [$FF93]
	ld [hl+], a
	ld a, $05
	call QueueSound
	or a
	ret

;Shot velocities for the 16 directions, clockwise from straight up: X then Y,
;each a signed 8.8 word, 3 pixels per frame. The diagonals are not quite
;symmetrical - $0222 in some places, $021C in others, where 3/sqrt(2) would be
;$021F.	;[ok]
EnemyShotVelocities:	;$391C
	dw $0000, $FD00	;0
	dw $0126, $FD3C	;1
	dw $0222, $FDE4	;2
	dw $02C4, $FEDA	;3
	dw $0300, $0000	;4
	dw $02C4, $0126	;5
	dw $0222, $021C	;6
	dw $0126, $02C4	;7
	dw $0000, $0300	;8
	dw $FEDA, $02C4	;9
	dw $FDE4, $0222	;10
	dw $FD3C, $0126	;11
	dw $FD00, $0000	;12
	dw $FD3C, $FEDA	;13
	dw $FDDE, $FDE4	;14
	dw $FEDA, $FD3C	;15

;Remove every shot and free its sprite; the free stack is left as it is.
;Called by the transition at $316D.	;[ok]
ClearEnemyShots:	;$395C
	ld hl, $CD0D
	ld a, [hl]
	or a
	ret z
	ld [hl], $00
	ld b, a
	ld l, $00
.l3967
	ld a, [hl+]
	ld c, l
	push bc
	add a, $0B
	ld l, a
	ld a, [hl]
	call FreeSprite
	ld h, $CD
	pop bc
	ld l, c
	dec b
	jr nz, .l3967
	ret
