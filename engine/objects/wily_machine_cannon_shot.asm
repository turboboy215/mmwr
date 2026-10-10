;Mega Man: Dr. Wily's Revenge disassembly - object type 51, WilyMachineCannonShot
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "WilyMachineCannonShot (type 51)", ROMX[$50AF], BANK[$D]

;Type 51: never placed; the cannon's shot (WilyMachineCannonShotSpawn, from type 48's cannon).
;Flies left 6 px a frame (frames 7-9); hit points $FE. While Mirror Buster is
;the current weapon (wCurrentWeapon $0A), a player shot touching it (frame 7's
;hitbox, JumpCheckShotHit) costs 8 Mirror Buster energy ($DFAD) and sends it back
;($09 = $FF): right at 6 px a frame (frames $0C-$0E); at X $70, unless the
;machine is still flashing ($CC5D), it writes 2 to $CC5C - the only damage the
;Wily Machine takes in phase 2 - and goes off screen. Removed off screen and
;when the boss is beaten.	;[ok]
WilyMachineCannonShotRoutine:	;$50AF
	ld a, b
	or a
	jr z, WilyMachineCannonShotInit
	dec a
	jr z, WilyMachineCannonShotUpdate
	dec a
	jr z, WilyMachineCannonShotRemove
	dec a
	jr z, WilyMachineCannonShotClearFreeze

;Mode 2, and once the boss is beaten: B = 0, removed.	;[ok]
WilyMachineCannonShotRemove:	;$50BC
	ld b, $00
	ret

;Mode 3 (Ice Slasher): end the freeze at once.	;[ok]
WilyMachineCannonShotClearFreeze:	;$50BF
	jp ObjClearFreeze_0D

WilyMachineCannonShotInit:	;$50C2
	ld de, WilyMachineCannonShotSpeed
	call ObjSetVelocity_0D
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld de, Data_0D_52A8
	call AnimateObjectFacing_0D
	ld b, $01
	ret

WilyMachineCannonShotSpeed:	;$50D7
	db $00, $FA, $00, $00
WilyMachineCannonShotReflectedSpeed:	;$50DB
	db $00, $06, $00, $00

;Mode 1: move and animate (frames 7-9, or $0C-$0E once reflected) unless
;frozen, then the stage X and the off-screen check.	;[ok]
WilyMachineCannonShotUpdate:	;$50DF
	ld a, [$CCF5]
	or a
	jr nz, WilyMachineCannonShotRemove
	ld a, [wFreezeFlags]
	or a
	jp nz, .l5100
	call WilyMachineCannonShotMove
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	inc a
	ld de, Data_0D_52A8
	jr nz, .l50FD
	ld de, Data_0D_52B0
.l50FD
	call AnimateObjectFacing_0D
.l5100
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
	jp ObjCheckOnScreen_0D

WilyMachineCannonShotMove:	;$5113
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	inc a
	jr z, WilyMachineCannonShotMoveReflected
	ld de, WilyMachineCannonShotSpeed
	ld a, $0C
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	adc a, [hl]
	ld [hl+], a
	ld e, a
	ld a, [wCurrentWeapon]
	cp $0A
	jr nz, .l5165
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $25
	ld a, $14
	ld [$CC46], a
	ld a, LOW(Frame_0D_5360)
	ld [$CE53], a
	ld a, HIGH(Frame_0D_5360)
	ld [$CE54], a
	ld l, c
	push hl
	call GetObjectHitbox_0D
	call JumpCheckShotHit
	pop hl
	ld c, l
	jr z, .l516B
	ld a, [wEnergy + $0A]
	sub $08
	jr nc, .l515A
	xor a
.l515A
	ld [wEnergy + $0A], a
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $FF
	jr .l516B
.l5165
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $25
.l516B
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ret

WilyMachineCannonShotMoveReflected:	;$5172
	ld de, WilyMachineCannonShotReflectedSpeed
	ld a, $0C
	add a, c
	ld l, a
	ld a, [de]
	inc de
	add a, [hl]
	ld [hl+], a
	ld a, [de]
	adc a, [hl]
	ld [hl+], a
	ld e, a
	ld a, [$CC5D]
	or a
	ret nz
	ld a, e
	cp $70
	ret c
	ld a, $02
	ld [$CC5C], a
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $C0
	ret

;Spawn a type 51 at object C (the cannon), with its tile base, and run
;WilyMachineCannonShotInit on it.	;[ok]
WilyMachineCannonShotSpawn:	;$5196
	ld l, c
	push hl
	ld a, $33
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ld [$CC0D], a
	inc l
	ld a, [hl]
	ld [$CC0F], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_0D
	call WilyMachineCannonShotInit
	pop hl
	ld c, l
	ret
