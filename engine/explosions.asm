;Mega Man: Dr. Wily's Revenge disassembly - explosions
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Explosions", ROMX[$5939], BANK[$1]

;CallBank1Routine index 4: one explosion at (E, D).	;[ok]
SpawnExplosion:	;$5939
	ld a, $FF
	ld hl, ExplosionParams
	ld b, $00
	jp SpawnExplosionParticle

;CallBank1Routine index 2, and the collision pass when an enemy dies: an
;explosion at ($D3EB, $D3EC), maybe an item drop (unless $CCF1 is set), and
;sound $02.	;[ok]
SpawnDeathExplosion:	;$5943
	ld a, [$D3EB]
	ld e, a
	ld a, [$D3EC]
	ld d, a
	ld a, $FF
	ld hl, ExplosionParams
	ld b, $00
	call SpawnExplosionParticle
	ld a, [$CCF1]
	or a
	jr nz, .l595E
	call RollItemDrop
.l595E
	ld a, $02
	call QueueSound
	ret

ExplosionParams:	;$5964
	db $00, $00, $02

;Move, animate and expire the explosions ($D300 page: twelve $10-byte records
;from $D31A, free-list pointer $D319, count $D30C).	;[ok]
UpdateExplosions:	;$5967
	ld hl, $D30C
	ld a, [hl]
	or a
	ret z
	ld b, a
	ld l, $00
.l5970
	ld h, $D3
	ld a, [hl+]
	ld c, l
	push bc
	ld c, a
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l598A
	ld a, c
	swap a
	ld e, a
	ld a, [$DF86]
	and e
	xor $01
	jr z, .l598D
.l598A
	call UpdateExplosion
.l598D
	ld h, $D3
	ld a, b
	or a
	jr nz, .l59B2
	pop bc
	dec c
	push bc
	ld l, $0C
	dec [hl]
	ld l, [hl]
	ld a, [hl]
	ld l, c
	ld b, [hl]
	ld [hl], a
	ld a, [$D319]
	dec a
	ld l, a
	ld [hl], b
	ld [$D319], a
	ld l, c
	push hl
	ld a, $00
	add a, b
	ld l, a
	ld a, [hl]
	call FreeSprite
	pop hl
.l59B2
	pop bc
	ld l, c
	dec b
	jr nz, .l5970
	ret

;Explosion C: move it by its velocity (and the scroll), animate it every 3
;frames, draw it; B = 0 once it has finished or left the screen.	;[ok]
UpdateExplosion:	;$59B8
	ld l, c
	inc l
	ld a, [$D850]
	ld b, a
	ld a, [hl+]
	add a, [hl]
	ld [hl+], a
	ld a, [hl+]
	adc a, [hl]
	sub b
	ld [hl+], a
	ld e, a
	ld a, [hl+]
	add a, [hl]
	ld [hl+], a
	ld a, [hl+]
	adc a, [hl]
	ld [hl+], a
	ld d, a
	ld a, e
	cp $E0
	jr nc, .l59D7
	cp $C0
	jp nc, RemoveExplosion
.l59D7
	ld a, d
	cp $F0
	jr nc, .l59E0
	cp $90
	jr nc, RemoveExplosion
.l59E0
	ld h, $D3
	ld a, $00
	add a, c
	ld l, a
	ld l, [hl]
	ld h, $D1
	ld l, [hl]
	dec h
	inc l
	ld a, [hl]
	ldh [$FF99], a
	xor a
	ld [$D3EA], a
	ld a, $6D
	ldh [$FF93], a
	ld h, $D3
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0A
	add a, c
	ld l, a
	ld l, [hl]
	ld a, [$DF94]
	or a
	ld a, l
	jr nz, .l5A17
	ld a, [wFreezeFlags]
	and $01
	ld a, l
	jr nz, .l5A39
.l5A17
	ld a, $09
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l5A22
	xor a
.l5A22
	ld [hl], a
	push af
	ld a, $0A
	add a, c
	ld l, a
	pop af
	ld a, [hl+]
	jr nz, .l5A39
	cp [hl]
	jr nz, .l5A34
	inc l
	dec [hl]
	jr z, RemoveExplosion
	dec l
.l5A34
	dec l
	inc a
	and $03
	ld [hl], a
.l5A39
	add a, a
	ld l, a
	ld h, $00
	ld c, e
	ld de, ExplosionFrames
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, $FF91
	ld a, [de]
	inc de
	add a, c
	ld [hl+], a
	ld a, [de]
	inc de
	add a, b
	ld [hl+], a
	ld bc, $0202
	call DrawTileGrid
	ld b, $01
	ret

;$5A59: a stray zero byte between two routines.	;[ok]
Unused_01_5A59:	;$5A59
	db $00

;UpdateExplosion's exit for a finished or off-screen explosion: B = 0.	;[ok]
RemoveExplosion:	;$5A5A
	ld h, $D3
	ld b, $00
	ret

;Set up the explosion slots' free list, empty.	;[ok]
InitExplosions:	;$5A5F
	ld hl, $D30D
	ld a, l
	ld [$D319], a
	ld b, $0C
	ld a, $1A
.l5A6A
	ld [hl+], a
	add a, $10
	dec b
	jr nz, .l5A6A
	xor a
	ld [$D30C], a
	ret

;Mega Man died: sound $0F and twelve particles flying out from him - unless
;he fell off the bottom of the screen (Y $80 and up).	;[ok]
SpawnPlayerDeathBurst:	;$5A75
	ld a, $0F
	call QueueSound
	ld a, [wPlayerY]
	cp $80
	ret nc
	ld d, a
	ld a, [wPlayerX]
	ld e, a
	ld b, $0C

;CallBank1Routine index 1: B explosion particles at (E, D), each with its
;direction from BurstParticles.	;[ok]
SpawnExplosionBurst:	;$5A87
	push bc
	push de
	ld a, $0C
	sub b
	add a, a
	add a, a
	add a, LOW(BurstParticles)
	ld l, a
	ld a, HIGH(BurstParticles)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld b, $01
	call SpawnExplosionParticle
	pop de
	pop bc
	dec b
	jr nz, SpawnExplosionBurst
	ret

BurstParticles:	;$5AA2
	db $10, $00, $03, $3C
	db $14, $00, $03, $3C
	db $18, $00, $03, $3C
	db $1C, $00, $03, $3C
	db $12, $01, $00, $3C
	db $16, $01, $00, $3C
	db $1A, $01, $00, $3C
	db $1E, $01, $00, $3C
	db $00, $00, $03, $3C
	db $04, $00, $03, $3C
	db $08, $00, $03, $3C
	db $0C, $00, $03, $3C

;Spawn one explosion: A = direction (index into ParticleVelocities, $FF for
;none), HL = 3 parameter bytes, (E, D) = position. Carry if all twelve are in
;use.	;[ok]
SpawnExplosionParticle:	;$5AD2
	ldh [hBank1CallIndex], a
	ld a, b
	ld [$D3E6], a
	ld a, e
	ld [$D3DE], a
	ld a, d
	ld [$D3E2], a
	ld de, $D3E4
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	ld hl, $D30C
	ld a, [hl]
	cp $0C
	ccf
	ret c
	inc [hl]
	ld c, a
	push bc
	ld a, $04
	call AllocSprite
	ld [$D3DA], a
	ldh a, [hBank1CallIndex]
	call GetParticleVelocity
	ld de, $D3DB
	ld b, $04
.l5B08
	ld a, [hl+]
	ld [de], a
	inc e
	inc e
	dec b
	jr nz, .l5B08
	ld a, $80
	ld [$D3DC], a
	ld [$D3E0], a
	pop bc
	ld h, $D3
	ld a, [$D319]
	ld l, a
	inc a
	ld [$D319], a
	ld b, [hl]
	ld l, c
	ld [hl], b
	ld e, b
	ld d, h
	ld hl, $D3DA
	ld bc, $0010
	call FuncFill
	or a
	ret

;HL = the velocity record for direction A ($FF: none).	;[ok]
GetParticleVelocity:	;$5B32
	cp $FF
	jr nz, .l5B3A
	ld hl, ParticleVelocityNone
	ret
.l5B3A
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld de, ParticleVelocities
	add hl, de
	ret

ParticleVelocityNone:	;$5B44
	dw $0000, $0000

ParticleVelocities:	;$5B48
	dw $0000, $FF80
	dw $0031, $FF8A
	dw $005B, $FFA6
	dw $0076, $FFCF
	dw $0080, $0000
	dw $0076, $0031
	dw $005B, $005A
	dw $0031, $0076
	dw $0000, $0080
	dw $FFCF, $0076
	dw $FFA6, $005B
	dw $FF8A, $0031
	dw $FF80, $0000
	dw $FF8A, $FFCF
	dw $FFA5, $FFA6
	dw $FFCF, $FF8A
	dw $0000, $FF00
	dw $0062, $FF14
	dw $00B6, $FF4C
	dw $00EC, $FF9E
	dw $0100, $0000
	dw $00EC, $0062
	dw $00B6, $00B4
	dw $0062, $00EC
	dw $0000, $0100
	dw $FF9E, $00EC
	dw $FF4C, $00B6
	dw $FF14, $0062
	dw $FF00, $0000
	dw $FF14, $FF9E
	dw $FF4A, $FF4C
	dw $FF9E, $FF14
	dw $0000, $FE80
	dw $0093, $FE9E
	dw $0111, $FEF2
	dw $0162, $FF6D
	dw $0180, $0000
	dw $0162, $0093
	dw $0111, $010E
	dw $0093, $0162
	dw $0000, $0180
	dw $FF6D, $0162
	dw $FEF2, $0111
	dw $FE9E, $0093
	dw $FE80, $0000
	dw $FE9E, $FF6D
	dw $FEEF, $FEF2
	dw $FF6D, $FE9E

;Free every explosion and its sprite.	;[ok]
FreeAllExplosions:	;$5C08
	ld hl, $D30C
	ld a, [hl]
	or a
	ret z
	ld [hl], $00
	ld b, a
	ld l, $00
.l5C13
	ld a, [hl+]
	ld c, l
	push bc
	add a, $00
	ld l, a
	ld a, [hl]
	call FreeSprite
	ld h, $D3
	pop bc
	ld l, c
	dec b
	jr nz, .l5C13
	ret

;Write a B-row by C-column grid of tiles from DE into OAM at ($FF92, $FF91)
;with tile base $FF93; the explosions' drawing.	;[ok]
DrawTileGrid:	;$5C25
	push bc
	ldh a, [hBank1CallIndex]
	ldh [$FF98], a
.l5C2A
	push de
	ld a, [de]
	cp $FF
	jr z, .l5C62
	ld d, a
	ldh a, [$FF99]
	cp $FE
	jp z, .l5C79
	ld l, a
	ld h, $CE
	ld a, [hl]
	ldh [$FF99], a
	ld h, $CF
	ld l, [hl]
	ld h, $C0
	ldh a, [$FF92]
	ld [hl+], a
	ldh a, [$FF98]
	ld [hl], a
	inc l
	ld a, d
	and $3F
	ld e, a
	ldh a, [$FF93]
	add a, e
	ld [hl+], a
	ld a, [$D3EA]
	bit 7, d
	jr z, .l5C5B
	set 5, a
.l5C5B
	bit 6, d
	jr z, .l5C61
	set 6, a
.l5C61
	ld [hl+], a
.l5C62
	pop de
	inc de
	ldh a, [$FF98]
	add a, $08
	ldh [$FF98], a
	dec c
	jr nz, .l5C2A
	ldh a, [$FF92]
	add a, $08
	ldh [$FF92], a
	pop bc
	dec b
	jr nz, DrawTileGrid
	jr .l5C7B
.l5C79
	pop de
	pop bc
.l5C7B
	ret

ExplosionFrames:	;$5C7C
	dw ExplosionFrame0, ExplosionFrame1, ExplosionFrame2, ExplosionFrame3

;Explosion frames: (dx, dy) then a 2x2 grid of tiles.	;[ok]
ExplosionFrame0:	;$5C84
	db $04, $0C, $03, $FF, $FF, $FF
ExplosionFrame1:	;$5C8A
	db $00, $08, $00, $80, $40, $C0
ExplosionFrame2:	;$5C90
	db $00, $08, $01, $81, $41, $C1
ExplosionFrame3:	;$5C96
	db $00, $08, $02, $82, $42, $C2
