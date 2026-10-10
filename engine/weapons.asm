;Mega Man: Dr. Wily's Revenge disassembly - weapons and shots
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Weapons", ROMX[$4000], BANK[$1]

;$4000: the bank's entry point, called at the start of every stage (and on a
;restart) from bank $00: install the two weapon hooks. Bank $01 has no entry
;table; this three-instruction stub is what sits at $4000.	;[ok]
InstallWeaponHooks:	;$4000
	call InstallFireHook
	call InstallShotHook
	ret

;$4007: one 16-byte record per weapon, in wCurrentWeapon order (Mega Buster,
;Rolling Cutter, Thunder Beam, Ice Slasher, Fire Storm, Carry, Atomic Fire, Time
;Stopper, Quick Boomerang, Bubble Lead, Mirror Buster). EquipWeapon copies one out:
;  db tileset	;-> $C22B, LoadObjectTiles type for each shot's sprite
;  db max shots	;-> $C22C, TryFireWeapon refuses to fire past it
;  db state	;-> $C22D, a new shot's offset $00 (non-zero = slot in use)
;  db damage	;-> $C203 (and $C204), copied to each shot's offset $0B
;  db x1, x2, y1, y2	;-> $C205-$C208, the shots' hitbox (often reset per frame)
;  db cost	;-> $C22E, energy SpendWeaponEnergy takes per shot
;  db pierce	;-> $C235, how a hit treats the shot (wWeaponPierce)
;  dw fire, update	;-> `jp` at wWeaponFire and wWeaponUpdate
;  db 0, 0	;unused
;Carry, Atomic Fire and Time Stopper also (Atomic Fire instead) spend energy in
;their own routines: Carry and Time Stopper drain over time, Atomic Fire by
;charge level.	;[ok]
WeaponTab:	;$4007
	db $01, $03, $07, $01, $02, $FD, $02, $FD, $00, $00
	dw FireMegaBuster, UpdateMegaBusterShot
	db $00, $00
	db $04, $01, $03, $02, $00, $00, $00, $00, $08, $00
	dw FireRollingCutter, UpdateRollingCutterShot
	db $00, $00
	db $06, $01, $03, $03, $07, $F8, $07, $F8, $08, $01
	dw FireThunderBeam, UpdateThunderBeamShot
	db $00, $00
	db $04, $01, $03, $01, $00, $00, $00, $00, $08, $03
	dw FireIceSlasher, UpdateIceSlasherShot
	db $00, $00
	db $04, $01, $03, $01, $00, $00, $00, $00, $08, $01
	dw FireFireStorm, UpdateFireStormShot
	db $00, $00
	db $06, $01, $01, $01, $00, $00, $00, $00, $01, $00
	dw FireCarry, UpdateCarryShot
	db $00, $00
	db $01, $01, $03, $01, $00, $00, $00, $00, $00, $04
	dw FireAtomicFire, UpdateAtomicFireShot
	db $00, $00
	db $01, $01, $01, $01, $00, $00, $00, $00, $08, $00
	dw FireTimeStopper, UpdateTimeStopperShot
	db $00, $00
	db $01, $03, $03, $01, $00, $00, $00, $00, $01, $00
	dw FireQuickBoomerang, UpdateQuickBoomerangShot
	db $00, $00
	db $04, $02, $07, $01, $00, $00, $00, $00, $04, $04
	dw FireBubbleLead, UpdateBubbleLeadShot
	db $00, $00
	db $04, $01, $01, $00, $00, $00, $00, $00, $00, $00
	dw FireMirrorBuster, UpdateMirrorBusterShot
	db $00, $00

;$40B7: switch to weapon wCurrentWeapon: reinstall the hooks, zero the shot
;count and shoot timer, copy the weapon's WeaponTab record into wWeaponDamage-wWeaponPierce
;(building the two `jp`s), clear the three shot slots, reset the Mirror Buster
;capture list and load the weapon's HUD letters. Called on stage load and by the
;pause menu when the choice changes.	;[ok]
EquipWeapon:	;$40B7
	call InstallFireHook
	call InstallShotHook
	xor a
	ld [wShootTimer], a
	ld [wShotCount], a
	ld a, [wCurrentWeapon]
	swap a
	and $F0
	ld l, a
	ld h, $00
	ld de, WeaponTab
	add hl, de
	ld a, [hl+]
	ld [wWeaponTileset], a
	ld a, [hl+]
	ld [wWeaponMaxShots], a
	ld a, [hl+]
	ld [wWeaponShotState], a
	ld de, wWeaponDamage
	ld a, [hl+]
	ld [de], a
	ld b, $05
.l40E5
	inc e
	ld [de], a
	ld a, [hl+]
	dec b
	jr nz, .l40E5
	dec hl
	ld a, [hl+]
	ld [wWeaponCost], a
	ld a, [hl+]
	ld [wWeaponPierce], a
	ld de, wWeaponFire
	ld a, $C3
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, $C3
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	ld b, $03
	ld hl, wShotSlots
.l410F
	ld [hl], $00
	ld a, $20
	add a, l
	ld l, a
	dec b
	jr nz, .l410F
	call ClearCapturedShots
	jp LoadWeaponHUD

;Point wHookA at TryFireWeapon. UpdatePlayer calls wHookA when Mega Man is
;able to act ($675D), which answers who calls the $C0AA hook.	;[ok]
InstallFireHook:	;$411E
	ld de, TryFireWeapon
	ld a, e
	ld [wHookA + 1], a
	ld a, d
	ld [wHookA + 2], a
	ld a, $C3
	ld [wHookA], a
	ret

;Point wHookB at UpdateShots. StageFrameLoop calls wHookB every frame.	;[ok]
InstallShotHook:	;$412F
	ld de, UpdateShots
	ld a, e
	ld [wHookB + 1], a
	ld a, d
	ld [wHookB + 2], a
	ld a, $C3
	ld [wHookB], a
	ret

;wHookA: count the shoot timer down, then fire the equipped weapon if B was pressed (held, for Quick Boomerang)
;and nothing forbids it - the game not frozen (wFreezeFlags & $53), fewer than the
;weapon's maximum shots alive, weapon energy left (the buster needs none) and
;the shoot timer below 8. Sets the shoot timer to $10, spends the energy, takes
;a shot slot, places it at the buster and jumps to the weapon's fire routine with
;A = wCurrentWeapon and C = the slot.	;[ok]
TryFireWeapon:	;$4140
	ld hl, wShootTimer
	ld a, [hl]
	or a
	jr z, .l4148
	dec [hl]
.l4148
	ld a, [wFreezeFlags]
	and $53
	ret nz
	ld a, [wCurrentWeapon]
	cp $08
	jr nz, .l415A
	ld a, [wPlayerHeld]
	jr .l415D
.l415A
	ld a, [wPlayerPressed]
.l415D
	bit 1, a
	ret z
	ld a, [wShotCount]
	ld l, LOW(wWeaponMaxShots)
	cp [hl]
	ret nc
	ld a, [wCurrentWeapon]
	or a
	jr z, .l4179
	ld de, wEnergy
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	or a
	ret z
.l4179
	ld l, LOW(wShootTimer)
	ld a, [hl]
	cp $08
	ret nc
	ld [hl], $10
	call SpendWeaponEnergy
	call AllocShot
	call PlaceNewShot
	ld a, [wCurrentWeapon]
	jp wWeaponFire

;Put shot C at the buster: Mega Man's position (wPlayerX, wPlayerY) plus the
;BusterOffsets pair for his state (wPlayerMotion) and facing (wPlayerFacing).	;[ok]
PlaceShotAtBuster:	;$4190
	ld a, [wPlayerMotion]
	add a, a
	ld hl, wPlayerFacing
	add a, [hl]
	add a, a
	ld e, a
	ld d, $00
	ld hl, BusterOffsets
	add hl, de
	ld d, $C2
	ld a, $04
	add a, c
	ld e, a
	ld a, [wPlayerX]
	add a, [hl]
	inc hl
	ld [de], a
	inc e
	inc e
	inc e
	inc e
	ld a, [wPlayerY]
	add a, [hl]
	ld [de], a
	ld h, $C2
	ret

;PlaceShotAtBuster, then fall into InitNewShot.	;[ok]
PlaceNewShot:	;$41B8
	call PlaceShotAtBuster

;Shot C's damage from wWeaponDamage, its facing from wPlayerFacing, and offsets $0F-$15
;zeroed (frame, animation counters, age, weapon scratch).	;[ok]
InitNewShot:	;$41BB
	ld h, $C2
	ld a, $0B
	add a, c
	ld l, a
	ld a, [wWeaponDamage]
	ld [hl], a
	ld a, $0C
	add a, c
	ld l, a
	ld a, [wPlayerFacing]
	ld [hl], a
	ld a, $0F
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret

;$41DA: (dx, dy) from Mega Man to the buster, indexed by (state * 2 + facing):
;standing left/right, airborne left/right, on a ladder left/right.	;[ok]
BusterOffsets:	;$41DA
	db $F9, $03
	db $0A, $03
	db $F2, $01
	db $12, $01
	db $F8, $01
	db $0A, $01

;$41E6: eleven bytes, one per weapon, that nothing reads. For nine weapons the
;byte is the sound its fire routine plays; Atomic Fire and Time Stopper differ.
;Probably a firing-sound table the routines stopped using (UNUSED.md).	;[?]
Unused_01_41E6:	;$41E6
	db $04, $0E, $1D, $1B, $1C, $00, $04, $04, $04, $04, $04

;Subtract the weapon's cost ($C22E) from its meter, stopping at zero. The Mega
;Buster (weapon 0) is free.	;[ok]
SpendWeaponEnergy:	;$41F1
	ld a, [wCurrentWeapon]
	or a
	jr z, .l420A
	ld de, wEnergy
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [wWeaponCost]
	ld b, a
	ld a, [de]
	sub b
	jr nc, .l4209
	xor a
.l4209
	ld [de], a
.l420A
	ret

;Negate DE when Mega Man faces left (wPlayerFacing = 0).	;[ok]
NegateDEIfFacingLeft:	;$420B
	ld a, [wPlayerFacing]
	or a
	ret nz
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
	ret

;Carry if shot C is inside a box around Mega Man (X -6..+6, Y -8..+12). Used
;to catch the Rolling Cutter on its way back.	;[ok]
CheckShotTouchesPlayer:	;$4218
	ld a, $04
	add a, c
	ld l, a
	ld a, [wPlayerX]
	add a, $FA
	cp [hl]
	ret nc
	add a, $0C
	cp [hl]
	jr c, .l4238
	ld a, $08
	add a, c
	ld l, a
	ld a, [wPlayerY]
	add a, $F8
	cp [hl]
	ret nc
	add a, $14
	cp [hl]
	ccf
	ret
.l4238
	or a
	ret

;Set shot C's velocity from HL: dw X speed (mirrored when facing left), dw Y
;speed. Speeds are 8.8 fixed point.	;[ok]
SetShotVelocity:	;$423A
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	call NegateDEIfFacingLeft
	call SetShotVelocityX
	pop hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	call SetShotVelocityY
	ret

;Shot C's X speed = DE (offsets $01 low, $03 high).	;[ok]
SetShotVelocityX:	;$424E
	ld h, $C2
	ld a, $01
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ret

;Shot C's Y speed = DE (offsets $05 low, $07 high).	;[ok]
SetShotVelocityY:	;$4259
	ld h, $C2
	ld a, $05
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ret

;If shot C still does damage (offset $0B, low six bits), append (pointer to
;that byte, X, Y) to the hit list at $C209; $C202 is the list's write pointer.
;The collision pass in bank $00 ($1093) tests enemies against this list with
;the hitbox at $C205-$C208, and on a hit takes the damage from offset $0B and
;weakens or removes the shot there (see wWeaponPierce).	;[ok]
AddShotToHitList:	;$4264
	ld h, $C2
	ld d, h
	ld a, [wShotListEnd]
	ld e, a
	ld a, $0B
	add a, c
	ld l, a
	ld a, [hl]
	and $3F
	ret z
	ld a, l
	ld [de], a
	inc e
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	inc e
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	inc e
	ld a, e
	ld [wShotListEnd], a
	ret

;The same for the second hit list at $C21D (pointer $C216, hitbox
;$C219-$C21C). Thunder Beam's side bolts, the Fire Storm shield and reflected
;Mirror Buster shots use it.	;[ok]
AddShotToHitList2:	;$4289
	ld h, $C2
	ld d, h
	ld a, [wShotList2End]
	ld e, a
	ld a, $0B
	add a, c
	ld l, a
	ld a, [hl]
	and $3F
	ret z
	ld a, l
	ld [de], a
	inc e
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	inc e
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ld [de], a
	inc e
	ld a, e
	ld [wShotList2End], a
	ret

;wHookB, every frame: update and draw the three shot slots ($C239, $C259,
;$C279, $20 bytes each). Sets the sprite tile base ($72) and palette, resets both
;hit lists, and for each live shot - unless the game is frozen (wFreezeFlags bits 0-1)
;- counts its age (offset $12) and calls the weapon's update through wWeaponUpdate: NZ
;keeps the shot and draws it, Z frees it. Then terminates the hit lists and sets
;their non-empty flags ($C204, $C218). With the Mirror Buster equipped it also
;fires back whatever was caught.
;Shot record: $00 power (0 = free), $01/$03 X speed, $02/$04 X (sub, pixel),
;$05/$07 Y speed, $06/$08 Y, $0A sprite handle, $0B damage ($80 once deflected), $0C facing,
;$0D-$0E metasprite, $0F frame, $10-$11 animation counter and step, $12 age,
;$13 onwards per weapon.	;[ok]
UpdateShots:	;$42AE
	ld a, $72
	ld [$CE55], a
	ld a, [$D80B]
	and $80
	or $10
	ld [$D3EA], a
	ld a, $09
	ld [wShotListEnd], a
	ld a, $1D
	ld [wShotList2End], a
	ld c, $39
.l42C9
	ld h, $C2
	ld l, c
	ld a, [hl]
	or a
	jr z, .l42E9
	ld a, [wFreezeFlags]
	and $03
	jr nz, .l42E1
	ld a, $12
	add a, c
	ld l, a
	inc [hl]
	call wWeaponUpdate
	jr z, .l42E6
.l42E1
	call DrawShot
	jr .l42E9
.l42E6
	call FreeShot
.l42E9
	ld a, $20
	add a, c
	ld c, a
	cp $99
	jr c, .l42C9
	ld hl, wShotListEnd
	ld a, [hl+]
	ld e, a
	ld d, $01
	cp $09
	jr nz, .l42FE
	ld d, $00
.l42FE
	inc l
	ld [hl], d
	ld l, e
	ld [hl], $00
	ld hl, wShotList2End
	ld a, [hl+]
	ld e, a
	ld d, $01
	cp $1D
	jr nz, .l4310
	ld d, $00
.l4310
	inc l
	ld [hl], d
	ld l, e
	ld [hl], $00
	ld a, [wCurrentWeapon]
	cp $0A
	call z, ReflectCapturedShots
	ret

;Move shot C by its velocity (X also by the scroll in $D850), then fall into
;the on-screen test: NZ while it is on screen, Z once it has left.	;[ok]
MoveShot:	;$431E
	ld h, $C2
	ld a, $01
	add a, c
	ld l, a
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
	jr CheckPositionOnScreen

;NZ if shot C's position is on screen, Z if not.	;[ok]
CheckShotOnScreen:	;$4339
	ld h, $C2
	ld a, $04
	add a, c
	ld l, a
	ld e, a
	ld a, $08
	add a, c
	ld l, a
	ld d, a

;NZ if (E, D) lies on screen (X below $AC or above $F4, Y below $90).	;[ok]
CheckPositionOnScreen:	;$4345
	ld a, e
	cp $F4
	jr nc, .l434E
	cp $AC
	jr nc, .l4356
.l434E
	ld a, d
	cp $90
	jr nc, .l4356
	xor a
	inc a
	ret
.l4356
	xor a
	ret

;Draw shot C. Offers its box to the hitbox viewer first. The Mega Buster's
;pellet is written straight into its OAM entry (tile $65); Thunder Beam and
;Time Stopper have their own drawing; everything else is a metasprite.	;[ok]
DrawShot:	;$4358
	ld h, $C2
	ld l, c
	push hl
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	ld a, [wShotHitbox]
	add a, e
	ld l, a
	ld a, [wShotHitbox + 2]
	add a, d
	ld h, a
	ld a, [wShotHitbox + 1]
	add a, e
	ld e, a
	ld a, [wShotHitbox + 3]
	add a, d
	ld d, a
	call HitboxViewerCheck
	pop hl
	ld c, l
	ld h, $C2
	ld a, [wCurrentWeapon]
	cp $00
	jr nz, .l43BF
	ld a, $0A
	add a, c
	ld l, a
	ld l, [hl]
	ld h, $D1
	ld l, [hl]
	dec h
	inc l
	ld a, [hl]
	cp $FE
	jr z, .l43BE
	ld l, a
	ld h, $CF
	ld e, [hl]
	ld d, $C0
	ld h, $C2
	ld a, $08
	add a, c
	ld l, a
	ld a, $0C
	add a, [hl]
	ld [de], a
	inc e
	dec l
	dec l
	dec l
	dec l
	ld a, $04
	add a, [hl]
	ld [de], a
	inc e
	ld a, $65
	ld [de], a
	inc e
	ld a, [$D80B]
	and $80
	ld [$D3EA], a
	ld [de], a
.l43BE
	ret
.l43BF
	cp $02
	jp z, DrawThunderBeam
	cp $07
	jp z, DrawTimeStopper

;Draw shot C's current metasprite (offsets $0D-$0E) at its position.	;[ok]
DrawShotFrame:	;$43C9
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA2], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $0A
	add a, c
	ld l, a
	ld a, [hl]
	ld l, e
	ld h, d
	jp DrawMetasprite

;Claim a free shot slot (the first wins if all are taken), give it the weapon's
;power and a sprite handle for its tileset, and count it. Returns C = slot.	;[ok]
AllocShot:	;$43E8
	ld b, $03
	ld hl, wShotSlots
.l43ED
	ld a, [hl]
	or a
	jr z, .l43FA
	ld a, $20
	add a, l
	ld l, a
	dec b
	jr nz, .l43ED
	ld l, $39
.l43FA
	ld a, [wWeaponShotState]
	ld [hl], a
	ld c, l
	ld a, $0A
	add a, c
	ld l, a
	ld a, [wWeaponTileset]
	push hl
	push bc
	call AllocSprite
	pop bc
	pop hl
	ld [hl], a
	ld l, $00
	inc [hl]
	ret

;Free shot C, if live: clear it, release its sprite handle, uncount it.	;[ok]
FreeShot:	;$4412
	ld h, $C2
	ld l, c
	ld a, [hl]
	or a
	ret z
	ld [hl], $00
	push hl
	ld a, $0A
	add a, c
	ld l, a
	ld a, [hl]
	call FreeSprite
	pop hl
	ld c, l
	ld l, $00
	dec [hl]
	ret

;Free the shots and zero the count. The loop stops at $60, so only the first
;two slots are freed - the third ($C279) is skipped, though the count is still
;zeroed. Called on pause and stage load.	;[ok]
FreeAllShots:	;$4429
	ld c, $39
.l442B
	call FreeShot
	ld a, $20
	add a, c
	ld c, a
	cp $60
	jr c, .l442B
	ld l, $00
	ld [hl], $00
	ld a, $1C
	ldh [rOBP0], a
	ret

;Mega Buster: sound $04 and a pellet forward at 2 pixels a frame.	;[ok]
FireMegaBuster:	;$443F
	ld a, $04
	call QueueSound
	ld hl, MegaBusterVelocity
	call SetShotVelocity
	ret

MegaBusterVelocity:	;$444B
	dw $0200, $0000

;A pellet an enemy deflected (offset $0B bit 7) turns round and flies back up
;and away in state 1, which keeps it off the hit list; otherwise it just
;moves.	;[ok]
UpdateMegaBusterShot:	;$444F
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	cp $01
	jr z, .l4483
	ld a, $0B
	add a, c
	ld l, a
	ld a, [hl]
	bit 7, a
	jr z, .l4481
	ld a, $00
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $03
	add a, c
	ld l, a
	bit 7, [hl]
	ld de, $0400
	jr nz, .l4475
	ld de, $FC00
.l4475
	ld [hl], d
	dec l
	dec l
	ld [hl], e
	ld a, $07
	add a, c
	ld l, a
	ld [hl], $FD
	jr .l4483
.l4481
	or a
	ret z
.l4483
	call MoveShot
	ret z
	ld a, $00
	add a, c
	ld l, a
	ld a, [hl]
	and $02
	call nz, AddShotToHitList
	xor a
	inc a
	ret

;$4494: `xor a / ret` that nothing reaches - it follows FireMegaBuster's
;update routine's `ret`.	;[ok]
Unused_01_4494:	;$4494
	xor a
	ret

;Rolling Cutter: sound $0E, start the spin animation.	;[ok]
FireRollingCutter:	;$4496
	ld a, $0E
	call QueueSound
	ld de, RollingCutterAnim
	call AnimateShot
	ret

;Rolling Cutter's outward arc: nine (dw X speed, dw Y speed) steps, five frames
;each, before it turns for home.	;[ok]
RollingCutterArc:	;$44A2
	dw $00FA, $FEE0
	dw $0142, $FF34
	dw $0178, $FFAF
	dw $0178, $0051
	dw $0142, $00CC
	dw $00FA, $0120
	dw $FF06, $0120
	dw $FEBE, $00CC
	dw $FE88, $0051

;The cutter flies RollingCutterArc, then homes in on Mega Man with a line step
;and disappears (sound $14) when it reaches him or leaves the screen.	;[ok]
UpdateRollingCutterShot:	;$44C6
	ld a, $15
	add a, c
	ld l, a
	ld d, h
	ld e, l
	ld a, [hl]
	cp $09
	jr nc, .l4513
	inc l
	inc [hl]
	ld a, [hl]
	cp $05
	jr c, .l44E1
	ld [hl], $00
	ld a, [de]
	inc a
	ld [de], a
	cp $09
	jr nc, .l451C
.l44E1
	ld a, [de]
	add a, a
	add a, a
	ld e, a
	ld d, $00
	push hl
	ld hl, RollingCutterArc
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	pop hl
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	call z, NegateDE
	call SetShotVelocityX
	ldh a, [hBank1CallIndex]
	ld e, a
	ldh a, [$FF92]
	ld d, a
	call SetShotVelocityY
	call MoveShot
	jr z, .l4563
	jr .l4544
.l4513
	ld a, $12
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	jr nz, .l451F
.l451C
	call AimShotAtPlayer
.l451F
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	ld l, c
	push hl
	call LineStep
	pop hl
	ld c, l
	ld a, $04
	add a, c
	ld l, a
	ld [hl], e
	ld a, $08
	add a, c
	ld l, a
	ld [hl], d
	call CheckShotOnScreen
	jr z, .l4563
	call CheckShotTouchesPlayer
	jr c, .l4563
.l4544
	ld a, $0B
	add a, c
	ld l, a
	ld a, [wWeaponDamage]
	ld [hl], a
	ld a, $13
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4557
	dec [hl]
	jr .l455A
.l4557
	call AddShotToHitList
.l455A
	ld de, RollingCutterAnim
	call AnimateShot
	xor a
	inc a
	ret
.l4563
	ld a, $14
	call QueueSound
	xor a
	ret

;Start a line step from shot C to Mega Man (LineStepInit), for the Rolling
;Cutter's return.	;[ok]
AimShotAtPlayer:	;$456A
	ld l, c
	push hl
	ld a, $04
	add a, c
	ld l, a
	ld e, [hl]
	ld a, $08
	add a, c
	ld l, a
	ld d, [hl]
	push de
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	ld d, a
	pop hl
	ld c, $02
	call LineStepInit
	pop hl
	ld c, l
	ret

RollingCutterAnim:	;$4588
	dw RollingCutterFrames
	db 6	;frames per step
	db $00, $01, $02, $03, $FF

ThunderBeamVelocity:	;$4590
	dw $00C0, $0000

;Thunder Beam fires three bolts: this one forward, then FireThunderBeamSides
;adds one going up and one going down.	;[ok]
FireThunderBeam:	;$4594
	ld a, $1D
	call QueueSound
	ld hl, ThunderBeamVelocity
	call SetShotVelocity
	ld a, $0A
	add a, c
	ld l, a
	ld a, [hl]
	push bc
	call FreeSprite
	ld a, $08
	call AllocSprite
	ld e, a
	pop bc
	ld h, $C2
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], e
	ld a, $16
	add a, c
	ld l, a
	ld [hl], $FF
	ld l, c
	push hl
	ld hl, ThunderBeamList2Setup
	ld de, $C217
	ld bc, $0006
	call FuncFill
	pop hl
	ld c, l
	ld de, ThunderBeamBoltRight
	ld b, $D8
	ld a, [wPlayerFacing]
	or a
	jr z, .l45DC
	ld de, ThunderBeamBoltLeft
	ld b, $28
.l45DC
	ld a, $17
	add a, c
	ld l, a
	ld [hl], b
	ld a, $19
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	jr FireThunderBeamSides

;Copied to $C217-$C21C for the side bolts: $C217, wShotList2Active and
;wShotHitbox2.	;[ok]
ThunderBeamList2Setup:	;$45EA
	db $03, $03, $03, $FC, $03, $FC

;The up and down bolts (offset $15 = 1 and 2), on the second hit list.	;[ok]
FireThunderBeamSides:	;$45F0
	call AllocShot
	call PlaceNewShot
	ld hl, ThunderBeamUpVelocity
	call SetShotVelocity
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $01
	call AllocShot
	call PlaceNewShot
	ld hl, ThunderBeamDownVelocity
	call SetShotVelocity
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $02
	ret

ThunderBeamUpVelocity:	;$4615
	dw $0000, $FFE0
ThunderBeamDownVelocity:	;$4619
	dw $0000, $0020

;The forward bolt (offset $15 = 0) grows every 3 frames, moving out by
;offset $17's step; the side bolts go to UpdateThunderBeamSide.	;[ok]
UpdateThunderBeamShot:	;$461D
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, UpdateThunderBeamSide
	ld a, $16
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l464A
	ld [hl], $00
	ld a, $10
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $0E
	jr c, .l464A
	ld [hl], $00
	ld a, $17
	add a, c
	ld l, a
	ld d, [hl]
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld [hl], a
.l464A
	call MoveShot
	ret z
	ld a, $19
	add a, c
	ld l, a
	ld a, [hl+]
	ldh [$FF95], a
	ld a, [hl]
	ldh [$FF96], a
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA2], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $16
	add a, c
	ld l, a
	ld a, [hl]
	and $03
	add a, a
	ld e, a
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld de, wShotList2
	ld b, $02
.l467A
	ldh [hBank1CallIndex], a
	ld l, a
	add a, a
	add a, l
	ld l, a
	ldh a, [$FF95]
	add a, l
	ld l, a
	ldh a, [$FF96]
	adc a, $00
	ld h, a
	ld a, c
	add a, $0B
	ld [de], a
	inc e
	ldh a, [$FFA2]
	add a, [hl]
	ld [de], a
	inc hl
	inc e
	ldh a, [$FFA3]
	add a, [hl]
	ld [de], a
	inc hl
	inc hl
	inc e
	ldh a, [hBank1CallIndex]
	inc a
	dec b
	jr nz, .l467A
	ld a, e
	ld [wShotList2End], a
	ld h, $C2
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $02
	xor a
	inc a
	ret

;Draw a Thunder Beam bolt: the forward one is a (dx, dy, tile) list walked by
;frame; the side ones use ThunderBeamFrames.	;[ok]
DrawThunderBeam:	;$46B0
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, .l46E6
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	add a, $04
	ldh [$FFA4], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	add a, $0C
	ldh [$FFA5], a
	ld a, $0A
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	add a, [hl]
	ld d, $00
	ld e, a
	ld a, $19
	add a, c
	ld l, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	add hl, de
	ld a, b
	call DrawMetaspriteList
	ret
.l46E6
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld de, ThunderBeamFrames
	call SetShotFrame
	jp DrawShotFrame

;The forward bolt as (dx, dy, tile) triples, one table per facing.	;[ok]
ThunderBeamBoltRight:	;$46F4
	db $00, $00, $08
	db $00, $08, $09
	db $F8, $08, $0A
	db $F8, $00, $0B
	db $F8, $F8, $4B
	db $F0, $F0, $0C
	db $F0, $E8, $49
	db $E8, $E8, $4A
	db $E8, $F0, $08
	db $E8, $F8, $09
	db $E0, $F8, $0A
	db $E0, $F0, $0D
	db $D8, $F0, $06
	db $D8, $F8, $07
	db $D8, $00, $08
	db $D8, $08, $09
	db $D0, $08, $0A
	db $D0, $00, $0B
	db $D0, $F8, $4B
	db $C8, $F0, $0C
	db $C8, $E8, $49
	db $C0, $E8, $4A

ThunderBeamBoltLeft:	;$4736
	db $00, $00, $88
	db $00, $08, $89
	db $08, $08, $8A
	db $08, $00, $8B
	db $08, $F8, $CB
	db $10, $F0, $8C
	db $10, $E8, $C9
	db $18, $E8, $CA
	db $18, $F0, $88
	db $18, $F8, $89
	db $20, $F8, $8A
	db $20, $F0, $8D
	db $28, $F0, $86
	db $28, $F8, $87
	db $28, $00, $88
	db $28, $08, $89
	db $30, $08, $8A
	db $30, $00, $8B
	db $30, $F8, $CB
	db $38, $F0, $8C
	db $38, $E8, $C9
	db $40, $E8, $CA

;A side bolt: every 3 frames it moves 8 pixels up or down (by its Y speed's
;sign) and steps its frame; on the second hit list.	;[ok]
UpdateThunderBeamSide:	;$4778
	ld a, $16
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l47B6
	ld [hl], $00
	ld a, $07
	add a, c
	ld l, a
	bit 7, [hl]
	ld e, $08
	jr z, .l4790
	ld e, $F8
.l4790
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld [hl], a
	ld a, $10
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l47A3
	ld [hl], $00
.l47A3
	ld e, [hl]
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	cp $01
	jr z, .l47B1
	ld a, $02
	sub e
	ld e, a
.l47B1
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], e
.l47B6
	call MoveShot
	ret z
	call AddShotToHitList
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $02
	xor a
	inc a
	ret

;Ice Slasher: sound $1B, a blade forward at 2 pixels a frame.	;[ok]
FireIceSlasher:	;$47C6
	ld a, $1B
	call QueueSound
	ld hl, IceSlasherVelocity
	call SetShotVelocity
	call AnimateIceSlasher
	ret

IceSlasherVelocity:	;$47D5
	dw $0200, $0000

;Animate the Ice Slasher for its facing.	;[ok]
AnimateIceSlasher:	;$47D9
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, IceSlasherAnimRight
	jr z, .l47E7
	ld de, IceSlasherAnimLeft
.l47E7
	jp AnimateShot

;Move and animate the blade.	;[ok]
UpdateIceSlasherShot:	;$47EA
	call MoveShot
	ret z
	call AnimateIceSlasher
	call AddShotToHitList
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $01
	or a
	ret

IceSlasherAnimRight:	;$47FC
	dw IceSlasherFrames
	db 10	;frames per step
	db $00, $01, $FF
IceSlasherAnimLeft:	;$4802
	dw IceSlasherFrames
	db 10	;frames per step
	db $02, $03, $FF

;Fire Storm: a fireball forward plus a shield of flame that circles Mega Man
;($3C frames).	;[ok]
FireFireStorm:	;$4808
	ld a, $1C
	call QueueSound
	ld hl, FireStormVelocity
	call SetShotVelocity
	ld de, FireStormAnimRight
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4821
	ld de, FireStormAnimLeft
.l4821
	call AllocShot
	call InitNewShot
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $01
	inc l
	inc l
	ld [hl], $3C
	ld a, $05
	ld [$C217], a
	ld de, FireStormShieldAnim
	call AnimateShot2
	ret

FireStormVelocity:	;$483D
	dw $0200, $0000

;The fireball (offset $15 = 0) moves and animates; the shield part goes to
;UpdateFireStormShield.	;[ok]
UpdateFireStormShot:	;$4841
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr nz, UpdateFireStormShield
	call MoveShot
	ret z
	ld de, FireStormAnimRight
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l485B
	ld de, FireStormAnimLeft
.l485B
	call AnimateShot
	call AddShotToHitList
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $01
	or a
	ret

FireStormAnimRight:	;$4869
	dw FireStormFrames
	db 6	;frames per step
	db $00, $01, $02, $FF
FireStormAnimLeft:	;$4870
	dw FireStormFrames
	db 6	;frames per step
	db $03, $04, $05, $FF

;The circling shield: eight positions around Mega Man (FireStormOrbit), on the
;second hit list.	;[ok]
UpdateFireStormShield:	;$4877
	ld a, $17
	add a, c
	ld l, a
	dec [hl]
	ret z
	ld a, $12
	add a, c
	ld l, a
	ld a, [hl]
	cp $02
	jr c, .l4894
	ld [hl], $00
	ld a, $18
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $08
	jr c, .l4894
	ld [hl], $00
.l4894
	ld a, $18
	add a, c
	ld l, a
	ld a, [hl]
	add a, a
	add a, LOW(FireStormOrbit)
	ld l, a
	ld a, HIGH(FireStormOrbit)
	adc a, $00
	ld h, a
	ld a, [wPlayerX]
	add a, [hl]
	ld e, a
	inc hl
	ld a, [wPlayerY]
	add a, [hl]
	ld d, a
	inc hl
	ld b, [hl]
	ld h, $C2
	ld a, $04
	add a, c
	ld l, a
	ld [hl], e
	ld a, $08
	add a, c
	ld l, a
	ld [hl], d
	ld de, FireStormShieldAnim
	call AnimateShot2
	call AddShotToHitList2
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $01
	or a
	ret

;(dx, dy) around Mega Man for the Fire Storm shield.	;[ok]
FireStormOrbit:	;$48CC
	db $00, $EC
	db $0E, $F2
	db $14, $00
	db $0E, $0E
	db $00, $14
	db $F2, $0E
	db $EC, $00
	db $F2, $F2

FireStormShieldAnim:	;$48DC
	dw FireStormFrames
	db 4	;frames per step
	db $07, $08, $07, $06, $07, $08, $07, $06, $FF

;Carry: a platform placed in front of Mega Man (closer when he is
;airborne).	;[ok]
FireCarry:	;$48E8
	ld a, $00
	call QueueSound
	ld a, [wPlayerMotion]
	or a
	jr z, .l48F9
	ld d, $04
	ld e, $FC
	jr .l48FD
.l48F9
	ld d, $16
	ld e, $00
.l48FD
	ld l, $41
	ld a, [hl]
	add a, d
	ld [hl], a
	ld a, [wPlayerFacing]
	or a
	jr z, .l490C
	ld a, e
	cpl
	inc a
	ld e, a
.l490C
	ld l, $3D
	ld a, [hl]
	add a, e
	ld [hl], a
	xor a
	ld l, $3A
	ld [hl+], a
	inc l
	ld [hl+], a
	inc l
	ld [hl+], a
	inc l
	ld [hl+], a
	ld a, [wPlayerY]
	ld [wShotSlots + $18], a
	ld de, CarryAnim
	call AnimateShot
	ret

;Register the Carry platform as a solid box (AddSolidBox) at its position.	;[ok]
AddCarrySolidBox:	;$4928
	push hl
	push bc
	ld a, [wShotSlots + 4]
	ld c, a
	ld a, [wShotSlots + 8]
	ld b, a
	ld hl, CarryFrame0
	call AddSolidBox
	pop bc
	pop hl
	ret

;The platform is gone: an explosion where it was, Z to free the shot.	;[ok]
DestroyCarryShot:	;$493B
	ld l, $3D
	ld e, [hl]
	ld l, $41
	ld d, [hl]
	ld a, $FF
	ld hl, ExplosionParams
	push bc
	call SpawnExplosionParticle
	pop bc
	ld h, $C2
	xor a
	ret

;The Carry platform: 8 energy every $3C frames, gone (with an explosion) at 0
;or when a wall probe hits.	;[ok]
UpdateCarryShot:	;$494F
	ld l, $4F
	inc [hl]
	ld a, [hl]
	cp $3C
	jr c, .l4967
	ld [hl], $00
	ld a, [wEnergy + 5]
	or a
	jr z, DestroyCarryShot
	sub $08
	jr nc, .l4964
	xor a
.l4964
	ld [wEnergy + 5], a
.l4967
	xor a
	ld l, $50
	ld [hl+], a
	call CheckCarryInWall
	jr c, DestroyCarryShot
	ld l, $4B
	ld a, [hl]
	cp $B4
	jr nc, DestroyCarryShot
	call CheckPlayerOnCarry
	jr nc, .l498B
	ld a, [wShotSlots + $15]
	or a
	jr nz, .l498B
	ld a, $01
	ld [wShotSlots + $15], a
	xor a
	ld [wShotSlots + $12], a
.l498B
	ld hl, wShotSlots + $12
	ld a, [hl]
	cp $9C
	jr nc, .l499B
	ld de, CarryAnim
	call AnimateShot
	jr .l499B
.l499B
	call AddCarrySolidBox
	xor a
	inc a
	ld a, [$D851]
	ld l, $3D
	add a, [hl]
	ld [hl], a
	ret

CarryAnim:	;$49A8
	dw CarryFrames
	db 6	;frames per step
	db $00, $01, $02, $FF

;Carry if Mega Man is on the platform (and sets shot offset $17). Standing still
;at its top (Y = platform Y - 8) counts; so does falling through the top this
;frame, which also adds the overshoot (top - Y, negative) to $D833, the high byte
;of the one-frame Y push that ApplyPlayerGravity adds to his Y speed - pulling
;him back up onto it. Rising never counts. Y $F0 and up reads as 0.	;[ok]
CheckPlayerOnCarry:	;$49AF
	ld a, [wShotSlots + 8]
	add a, $F8
	ld d, a
	ld hl, wShotSlots + $18
	ld a, [wPlayerY]
	cp $F0
	jr c, .l49C0
	xor a
.l49C0
	ld e, [hl]
	cp [hl]
	ld [hl], a
	jr c, .l49E8
	jr z, .l49DE
	ld a, e
	cp d
	jr nc, .l49E8
	ld a, [wPlayerY]
	cp d
	jr c, .l49E8
	cpl
	inc a
	add a, d
	ld d, a
	ld a, [$D833]
	add a, d
	ld [$D833], a
	jr .l49E1
.l49DE
	cp d
	jr nz, .l49E8
.l49E1
	ld a, $01
	ld [wShotSlots + $17], a
	scf
	ret
.l49E8
	or a
	ret

;Carry if any of the platform's four corners is in a solid block.	;[ok]
CheckCarryInWall:	;$49EA
	ld d, $F8
	ld e, $F4
	call CheckCarryCorner
	ld d, $F8
	ld e, $0B
	call nc, CheckCarryCorner
	ld d, $05
	ld e, $F4
	call nc, CheckCarryCorner
	ld d, $05
	ld e, $0B
	call nc, CheckCarryCorner
	ret

;One of the Carry corner probes: CheckSolidAt the platform's position plus
;(E, D).	;[ok]
CheckCarryCorner:	;$4A07
	ld l, $3D
	ld a, e
	add a, [hl]
	ld e, a
	ld l, $41
	ld a, d
	add a, [hl]
	ld d, a
	ld l, c
	push hl
	call CheckSolidAt
	pop hl
	ld c, l
	ret

;Atomic Fire: holding B charges (offset $12), releasing fires. The charge
;level picks tileset, damage, cost and palette cycle from the tables below.	;[ok]
FireAtomicFire:	;$4A19
	xor a
	ld [wShootTimer], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $16
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $08
	add a, c
	ld l, a
	ld [hl], $A0
	ld a, $1A
	add a, c
	ld l, a
	ld [hl], $00
	jp AnimateAtomicFire

;Atomic Fire, per charge level (0-2): tileset, damage (1, 2, 5), cost; then
;three palette cycles and the shot's speed. Bank $00's boss-damage code
;(ApplyBossDamageTab) finds the charge level by matching wWeaponDamage against the
;damage row, and scales the boss damage by 1, 2 or 5 to match.	;[ok]
AtomicFireTilesets:	;$4A38
	db $01, $04, $09
AtomicFireDamage:	;$4A3B
	db $01, $02, $05
AtomicFireCosts:	;$4A3E
	db $08, $10, $20
AtomicFirePalettes1:	;$4A41
	db $10, $14, $18, $1C
AtomicFirePalettes2:	;$4A45
	db $10, $24, $38, $0C
AtomicFirePalettes3:	;$4A49
	db $90, $E4, $38, $4C

AtomicFireVelocity:	;$4A4D
	dw $0200, $0000

;Not enough energy for the charge level: cancel (cost 0, palette back).	;[ok]
AtomicFireNoEnergy:	;$4A51
	xor a
	ld [wWeaponCost], a

;Restore OBP0 to $1C after Atomic Fire's palette cycling.	;[ok]
ResetShotPalette:	;$4A55
	ld a, $1C
	ldh [rOBP0], a
	ret

;While B is held, charge (sounds $2F-$31 by level, levels at $78 and $B4
;frames) with the shot parked off the bottom of the screen; on release, fire
;at the charge level if there is energy for it.	;[ok]
UpdateAtomicFireShot:	;$4A5A
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, UpdateAtomicFireFlight
	ld a, $12
	add a, c
	ld l, a
	ld a, [hl]
	cp $78
	ld e, $2F
	ld b, $00
	jr c, .l4A7C
	ld e, $30
	inc b
	cp $B4
	jr c, .l4A7C
	ld e, $31
	inc b
	ld [hl], $B5
.l4A7C
	ld a, [wFrameCounter]
	and $01
	jr z, .l4A87
	ld a, e
	call QueueSound
.l4A87
	ld a, b
	ld [$C237], a
	add a, LOW(AtomicFireCosts)
	ld e, a
	ld a, HIGH(AtomicFireCosts)
	adc a, $00
	ld d, a
	ld a, [de]
	ld b, a
	ld [wWeaponCost], a
	ld a, [wEnergy + 6]
	cp b
	jr c, AtomicFireNoEnergy
	ld a, [wPlayerHeld]
	bit 1, a
	jr z, .l4AAD
	ld a, $08
	add a, c
	ld l, a
	ld [hl], $A0
	jr .l4B0C
.l4AAD
	ld a, $1C
	call QueueSound
	call ResetShotPalette
	ld a, $0A
	add a, c
	ld l, a
	ld a, [hl]
	push bc
	call FreeSprite
	ld a, [$C237]
	add a, LOW(AtomicFireTilesets)
	ld e, a
	ld a, HIGH(AtomicFireTilesets)
	adc a, $00
	ld d, a
	ld a, [de]
	call AllocSprite
	ld e, a
	pop bc
	ld h, $C2
	ld a, $0A
	add a, c
	ld l, a
	ld [hl], e
	call PlaceNewShot
	ld a, [$C237]
	add a, LOW(AtomicFireDamage)
	ld e, a
	ld a, HIGH(AtomicFireDamage)
	adc a, $00
	ld d, a
	ld a, [de]
	ld [wWeaponDamage], a
	ld a, $10
	ld [wShootTimer], a
	ld a, $1A
	add a, c
	ld l, a
	ld a, [$C237]
	ld [hl], a
	ld hl, AtomicFireVelocity
	call SetShotVelocity
	ld h, $C2
	call SpendWeaponEnergy
	xor a
	ld [wWeaponCost], a
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $01
	jr .l4B45
.l4B0C
	ld a, $17
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l4B24
	ld [hl], $00
	ld a, $18
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $04
	jr c, .l4B24
	ld [hl], $00
.l4B24
	ld a, $18
	add a, c
	ld l, a
	ld b, [hl]
	ld a, [$C237]
	or a
	ld de, AtomicFirePalettes1
	jr z, .l4B3B
	dec a
	ld de, AtomicFirePalettes2
	jr z, .l4B3B
	ld de, AtomicFirePalettes3
.l4B3B
	ld a, e
	add a, b
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	ldh [rOBP0], a
.l4B45
	xor a
	inc a
	ret

;Animate the Atomic Fire shot for its charge level (offset $1A).	;[ok]
AnimateAtomicFire:	;$4B48
	ld a, $1A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, AtomicFireAnim1
	jr z, .l4B5C
	dec a
	ld de, AtomicFireAnim2
	jr z, .l4B5C
	ld de, AtomicFireAnim3
.l4B5C
	jp AnimateShot

;Atomic Fire in flight.	;[ok]
UpdateAtomicFireFlight:	;$4B5F
	ld a, $0B
	add a, c
	ld l, a
	ld a, [hl]
	and $1F
	ret z
	ld a, [wWeaponDamage]
	ld [hl], a
	call MoveShot
	ret z
	call AnimateAtomicFire
	call AddShotToHitList
	xor a
	inc a
	ret

AtomicFireAnim1:	;$4B78
	dw AtomicFireFrames
	db 6	;frames per step
	db $04, $05, $FF
AtomicFireAnim2:	;$4B7E
	dw AtomicFireFrames
	db 6	;frames per step
	db $02, $03, $FF
AtomicFireAnim3:	;$4B84
	dw AtomicFireFrames
	db 6	;frames per step
	db $00, $01, $FF

TimeStopperLayout1:	;$4B8A
	db $97, $10
	db $80, $40
	db $78, $50
	db $70, $18
	db $58, $70
	db $30, $68
	db $28, $5A
	db $10, $60
TimeStopperLayout2:	;$4B9A
	db $90, $30
	db $88, $50
	db $60, $28
	db $50, $52
	db $38, $38
	db $38, $62
	db $20, $30
	db $10, $52
TimeStopperLayout3:	;$4BAA
	db $80, $28
	db $78, $70
	db $68, $58
	db $50, $38
	db $40, $20
	db $40, $50
	db $28, $08
	db $10, $18

;Time Stopper: sets wFreezeFlags bit 3 (time stopped) and puts up eight sprites;
;drains 8 energy every $19 frames until empty.	;[ok]
FireTimeStopper:	;$4BBA
	ld a, $2B
	call QueueSound
	ld hl, wShotSlots + $18
	ld b, $08
.l4BC4
	push hl
	push bc
	ld a, $01
	call AllocSprite
	pop bc
	pop hl
	ld [hl+], a
	dec b
	jr nz, .l4BC4
	ld de, TimeStopperAnim
	call AnimateShot
	ld a, [wFreezeFlags]
	set 3, a
	ld [wFreezeFlags], a
	ret

;Time runs again: free the eight sprites and clear wFreezeFlags bit 3.	;[ok]
EndTimeStopper:	;$4BE0
	ld hl, wShotSlots + $18
	ld b, $08
.l4BE5
	ld a, [hl+]
	push hl
	push bc
	call FreeSprite
	pop bc
	pop hl
	dec b
	jr nz, .l4BE5
	ld a, [wFreezeFlags]
	res 3, a
	ld [wFreezeFlags], a
	ld c, $39
	xor a
	ret

;Every $19 frames take 8 energy; at 0 time runs again. Cycles the sprites
;through their three layouts.	;[ok]
UpdateTimeStopperShot:	;$4BFC
	ld hl, wShotSlots + $12
	ld a, [hl]
	cp $19
	jr c, .l4C14
	ld [hl], $00
	ld a, [wEnergy + 7]
	or a
	jr z, EndTimeStopper
	sub $08
	jr nc, .l4C11
	xor a
.l4C11
	ld [wEnergy + 7], a
.l4C14
	ld l, $4E
	inc [hl]
	cp $12
	jr c, .l4C26
	ld [hl], $00
	inc l
	inc [hl]
	ld a, [hl]
	cp $03
	jr c, .l4C26
	ld [hl], $00
.l4C26
	xor a
	inc a
	ld c, $39
	ret

TimeStopperLayouts:	;$4C2B
	dw TimeStopperLayout1, TimeStopperLayout2, TimeStopperLayout3

;Draw the Time Stopper's eight sprites at one of three layouts.	;[ok]
DrawTimeStopper:	;$4C31
	ld de, TimeStopperAnim
	call AnimateShot
	ld a, [wShotSlots + $16]
	ld hl, TimeStopperLayouts
	call GetTablePointer
	ld b, $08
	ld de, wShotSlots + $18
.l4C45
	ld a, [hl+]
	ldh [$FFA2], a
	ld a, [hl+]
	ldh [$FFA3], a
	push bc
	push hl
	ld a, [wShotSlots + $0D]
	ld l, a
	ld a, [wShotSlots + $0E]
	ld h, a
	ld a, [de]
	inc de
	push de
	call DrawMetasprite
	pop de
	pop hl
	pop bc
	dec b
	jr nz, .l4C45
	ret

TimeStopperAnim:	;$4C62
	dw TimeStopperFrames
	db 6	;frames per step
	db $00, $01, $02, $03, $FF

;Quick Boomerang: fired while B is held; it flies a twelve-step curve.	;[ok]
FireQuickBoomerang:	;$4C6A
	ld a, $04
	call QueueSound
	ld de, QuickBoomerangAnim
	call AnimateShot
	ret

;Quick Boomerang's curve: twelve (dw X speed, dw Y speed) steps.	;[ok]
QuickBoomerangPath:	;$4C76
	dw $0145, $FE89
	dw $01A4, $FEF7
	dw $01EA, $FF97
	dw $01EA, $0069
	dw $01A4, $0109
	dw $0145, $0177
	dw $FEBB, $0177
	dw $FE5C, $0109
	dw $FE16, $0069
	dw $FE16, $FF97
	dw $FE5C, $FEF7
	dw $FEBB, $FE89

;Fly the twelve-step curve, then the shot is gone.	;[ok]
UpdateQuickBoomerangShot:	;$4CA6
	ld a, $0B
	add a, c
	ld l, a
	ld a, [wWeaponDamage]
	cp [hl]
	jr z, .l4CB6
	ld a, $13
	add a, c
	ld l, a
	ld [hl], $04
.l4CB6
	ld a, $15
	add a, c
	ld l, a
	ld d, h
	ld e, l
	inc l
	inc [hl]
	ld a, [hl]
	cp $04
	jr c, .l4CCE
	ld [hl], $00
	ld a, [de]
	inc a
	ld [de], a
	cp $0C
	jr c, .l4CCE
	xor a
	ret
.l4CCE
	ld a, [de]
	add a, a
	add a, a
	ld e, a
	ld d, $00
	push hl
	ld hl, QuickBoomerangPath
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	pop hl
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	call z, NegateDE
	call SetShotVelocityX
	ldh a, [hBank1CallIndex]
	ld e, a
	ldh a, [$FF92]
	ld d, a
	call SetShotVelocityY
	call MoveShot
	ret z
	jr .l4CFF
.l4CFF
	ld a, $0B
	add a, c
	ld l, a
	ld a, [wWeaponDamage]
	ld [hl], a
	ld a, $13
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4D12
	dec [hl]
	jr .l4D15
.l4D12
	call AddShotToHitList
.l4D15
	ld de, QuickBoomerangAnim
	call AnimateShot
	xor a
	inc a
	ret

QuickBoomerangAnim:	;$4D1E
	dw QuickBoomerangFrames
	db 6	;frames per step
	db $00, $01, $02, $03, $FF

;Bubble Lead: a bubble that falls under gravity (ApplyShotGravity) and is
;stopped and turned by walls and floors.	;[ok]
FireBubbleLead:	;$4D26
	ld a, $04
	call QueueSound
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $04
	ld hl, BubbleLeadVelocity
	call SetShotVelocity
	ld de, BubbleLeadAnim
	call AnimateShot
	ret

BubbleLeadVelocity:	;$4D44
	dw $014C, $FE80

;Fall (ApplyShotGravity) until a floor stops it, then travel along it; turned
;or stopped by walls.	;[ok]
UpdateBubbleLeadShot:	;$4D48
	ld a, $0B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret z
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	ld [$C237], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	ld [$C238], a
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, .l4DB6
	call ApplyShotGravity
	call MoveShot
	ret z
	call CheckBubbleLeadFront
	jr nc, .l4D8E
	ld a, $04
	add a, c
	ld l, a
	ld a, [$C237]
	ld [hl], a
	ld de, $0805
	call CheckShotTile
	jr c, .l4D8C
	ld de, $07FA
	call CheckShotTile
	jr nc, .l4D9E
.l4D8C
	xor a
	ret
.l4D8E
	ld de, $0805
	call CheckShotTile
	jr c, .l4D9E
	ld de, $07FA
	call CheckShotTile
	jr nc, .l4DAA
.l4D9E
	ld a, $04
	add a, c
	ld l, a
	res 0, [hl]
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $01
.l4DAA
	ld de, BubbleLeadAnim
	call AnimateShot
	call AddShotToHitList
	xor a
	inc a
	ret
.l4DB6
	ld de, $0805
	call CheckShotTile
	jr c, .l4DDC
	ld de, $07FA
	call CheckShotTile
	jr c, .l4DDC
	ld a, $01
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	inc l
	ld [hl], $00
	ld a, $05
	add a, c
	ld l, a
	ld [hl], $4C
	inc l
	inc l
	ld [hl], $01
	jr .l4E03
.l4DDC
	call CheckBubbleLeadFront
	jr nc, .l4DE3
	xor a
	ret
.l4DE3
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ld de, $0180
	jr nz, .l4DF1
	ld de, $FE80
.l4DF1
	ld a, $05
	add a, c
	ld l, a
	ld [hl], $00
	inc l
	inc l
	ld [hl], $00
	ld a, $01
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
.l4E03
	call MoveShot
	ret z
	jp .l4DAA

BubbleLeadAnim:	;$4E0A
	dw BubbleLeadFrames
	db 6	;frames per step
	db $00, $01, $02, $FF

;Carry if the Bubble Lead's probes on its front side hit a solid block.	;[ok]
CheckBubbleLeadFront:	;$4E11
	ld a, $0C
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4E2C
	ld de, $F905
	call CheckShotTile
	ret c
	ld de, $FF05
	call CheckShotTile
	ret c
	ld de, $0705
	jr CheckShotTile
.l4E2C
	ld de, $F8FA
	call CheckShotTile
	ret c
	ld de, $FFFA
	call CheckShotTile
	ret c
	ld de, $06FA

;Collision tile at shot C's position plus (E, D).	;[ok]
CheckShotTile:	;$4E3D
	ld a, $04
	add a, c
	ld l, a
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $08
	add a, c
	ld l, a
	ld a, [hl]
	add a, d
	ld d, a
	ld l, c
	push hl
	call CheckSolidAt
	pop hl
	ld c, l
	ret

;Mirror Buster has no shot of its own. While B is held, its update puts a
;shield in front of Mega Man; enemy shots that hit it are caught
;(CaptureEnemyShot) and sent back.	;[ok]
FireMirrorBuster:	;$4E53
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $00
	ret

;With B held (and $DF94 clear) show the shield in front of Mega Man;
;otherwise an empty frame. Reflected shots (offset $15 set) are in flight.	;[ok]
UpdateMirrorBusterShot:	;$4E5A
	ld a, $15
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jp nz, UpdateReflectedShot
	ld a, [wPlayerHeld]
	bit 1, a
	jr z, .l4E92
	ld a, [$DF94]
	or a
	jr nz, .l4E92
	ld a, $12
	add a, c
	ld l, a
	ld a, [hl]
	cp $03
	jr c, .l4E83
	ld e, l
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $01
	ld l, e
	xor a
	ld [hl], a
.l4E83
	ld b, a
	ld a, [wPlayerFacing]
	or a
	ld de, $0112
	jr nz, .l4E90
	ld de, $01F2
.l4E90
	jr .l4E9D
.l4E92
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], LOW(MirrorBusterFrame14 + 4)
	inc l
	ld [hl], HIGH(MirrorBusterFrame14 + 4)
	jr .l4EC1
.l4E9D
	ld a, $04
	add a, c
	ld l, a
	ld a, [wPlayerX]
	add a, e
	ld [hl], a
	ld a, $08
	add a, c
	ld l, a
	ld a, [wPlayerY]
	add a, d
	ld [hl], a
	ld de, MirrorBusterAnimLeft
	ld a, [wPlayerFacing]
	or a
	jr z, .l4EBB
	ld de, MirrorBusterAnimRight
.l4EBB
	call AnimateShot
	call AddShotToHitList
.l4EC1
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $00
	ld a, [wEnergy + $0A]
	or a
	ret

MirrorBusterAnimLeft:	;$4ECC
	dw MirrorBusterFrames
	db 4	;frames per step
	db $0B, $0C, $0D, $FF
MirrorBusterAnimRight:	;$4ED3
	dw MirrorBusterFrames
	db 4	;frames per step
	db $08, $09, $0A, $FF
MirrorBusterAnimUnused:	;$4EDA
	dw MirrorBusterFrames
	db 100	;frames per step
	db $0E, $FF

;A reflected shot in flight (Mirror Buster), on the second hit list.	;[ok]
UpdateReflectedShot:	;$4EDF
	call MoveShot
	ret z
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	ld de, MirrorBusterFrames
	call SetShotFrame2
	ld a, $04
	ld [$C217], a
	call AddShotToHitList2
	ld a, $0B
	add a, c
	ld l, a
	ld [hl], $04
	xor a
	inc a
	ret

;Pick shot C's frame from the signs of its velocity, through the three
;DirectionFrames tables.	;[ok]
SetShotFrameFromVelocity:	;$4EFF
	ld a, $03
	add a, c
	ld l, a
	ld a, [hl-]
	ld e, $00
	bit 7, a
	jr nz, .l4F0F
	inc e
	or a
	jr z, .l4F0F
	inc e
.l4F0F
	ld a, $07
	add a, c
	ld l, a
	ld a, [hl-]
	ld b, $00
	bit 7, a
	jr nz, .l4F1F
	inc b
	or a
	jr z, .l4F1F
	inc b
.l4F1F
	ld a, e
	or a
	ld de, DirectionFramesUp
	jr z, .l4F2F
	dec a
	ld de, DirectionFramesLevel
	jr z, .l4F2F
	ld de, DirectionFramesDown
.l4F2F
	ld a, b
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], b
	ret

DirectionFramesUp:	;$4F3E
	db $07, $06, $05
DirectionFramesLevel:	;$4F41
	db $00, $00, $04
DirectionFramesDown:	;$4F44
	db $01, $02, $03

;Claim a free shot slot like AllocShot, but return carry if there is none.	;[ok]
AllocShotSlot:	;$4F47
	ld b, $03
	ld hl, wShotSlots
.l4F4C
	ld a, [hl]
	or a
	jr z, .l4F59
	ld a, $20
	add a, l
	ld l, a
	dec b
	jr nz, .l4F4C
	scf
	ret
.l4F59
	ld c, l
	ld a, $0A
	add a, c
	ld l, a
	ld a, [wWeaponTileset]
	push hl
	push bc
	call AllocSprite
	pop bc
	pop hl
	ld [hl], a
	ld l, $00
	inc [hl]
	or a
	ret

;Mirror Buster: launch every caught enemy shot back as a shot of our own,
;velocity reversed, 4 energy each, while energy lasts.	;[ok]
ReflectCapturedShots:	;$4F6E
	ld a, [wEnergy + $0A]
	or a
	jr z, ClearCapturedShots
	ld de, wCapturedShots
.l4F77
	ld a, [wCapturedShotsEnd]
	cp e
	jr z, ClearCapturedShots
	push de
	call AllocShotSlot
	pop de
	jr c, ClearCapturedShots
	ld a, $00
	add a, c
	ld l, a
	ld [hl], $03
	push bc
	ld h, $C2
	ld a, $01
	add a, c
	ld l, a
	ld a, [de]
	inc e
	cpl
	ld c, a
	ld a, [de]
	inc e
	cpl
	ld b, a
	inc bc
	ld [hl], c
	inc l
	inc l
	ld [hl], b
	inc l
	ld a, [de]
	inc e
	ld [hl+], a
	ld a, [de]
	inc e
	cpl
	ld c, a
	ld a, [de]
	inc e
	cpl
	ld b, a
	inc bc
	ld [hl], c
	inc l
	inc l
	ld [hl], b
	inc l
	ld a, [de]
	inc e
	ld [hl+], a
	pop bc
	ld a, $15
	add a, c
	ld l, a
	ld [hl], $01
	call SetShotFrameFromVelocity
	ld a, [wEnergy + $0A]
	sub $04
	jr nc, .l4FC5
	xor a
.l4FC5
	ld [wEnergy + $0A], a
	jr .l4F77

;Empty the capture list ($C299 is its write pointer, records from $C29A).	;[ok]
ClearCapturedShots:	;$4FCA
	ld a, $9A
	ld [wCapturedShotsEnd], a
	ret

;Called by the enemy-shot code (bank $00 $3830) when the Mirror Buster
;blocked enemy shot C: record its velocity and position for
;ReflectCapturedShots.	;[ok]
CaptureEnemyShot:	;$4FD0
	ld a, [wCurrentWeapon]
	cp $0A
	ret nz
	ld de, wCapturedShotsEnd
	ld a, [de]
	ld e, a
	ld a, $01
	add a, c
	ld l, a
	ld a, [hl+]
	ld [de], a
	inc e
	inc l
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	inc l
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, e
	ld [wCapturedShotsEnd], a
	ret

;Add $17 to shot C's Y speed, capped at $0120, and bleed off 1/64 of its X
;speed.	;[ok]
ApplyShotGravity:	;$4FF8
	ld h, $C2
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $17
	ld e, a
	inc l
	inc l
	ld a, [hl]
	adc a, $00
	ld d, a
	bit 7, a
	jr nz, .l5017
	ld a, $20
	sub e
	ld a, $01
	sbc a, d
	jr nc, .l5017
	ld de, $0120
.l5017
	ld [hl], d
	dec l
	dec l
	ld [hl], e
	ld a, $01
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, e
	ld b, d
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sub e
	ld e, a
	ld a, b
	sbc a, d
	ld [hl-], a
	dec l
	ld [hl], e
	ret

;Advance shot C's animation. DE = an animation record:
;  dw frame table, db frames per step, db frame, frame, ..., $FF (loop)
;and set its frame (SetShotFrameAndStore). AnimateShot2 does the same for a
;shot on the second hit list.	;[ok]
AnimateShot:	;$5045
	xor a
	ldh [$FF95], a

;AnimateShot's body, with $FF95 choosing the hit list.	;[ok]
AnimateShotOnList:	;$5048
	ld h, $C2
	ld a, [de]
	inc de
	ldh [hBank1CallIndex], a
	ld a, [de]
	inc de
	ldh [$FF92], a
	ld a, $10
	add a, c
	ld l, a
	inc [hl]
	ld a, [de]
	inc de
	dec a
	cp [hl]
	jr nc, .l5061
	ld [hl], $00
	inc l
	inc [hl]
.l5061
	ld a, e
	ldh [$FF93], a
	ld a, d
	ldh [$FF94], a
	ld a, $11
	add a, c
	ld l, a
.l506B
	ld a, [hl]
	add a, e
	ld e, a
	ld a, $00
	adc a, d
	ld d, a
	ld a, [de]
	cp $FF
	jr nz, .l5081
	ld [hl], $00
	ldh a, [$FF93]
	ld e, a
	ldh a, [$FF94]
	ld d, a
	jr .l506B
.l5081
	ld b, a
	ldh a, [hBank1CallIndex]
	ld e, a
	ldh a, [$FF92]
	ld d, a
	ldh a, [$FF95]
	or a
	ld a, b
	jp z, SetShotFrameAndStore
	jp SetShotFrame2AndStore

;AnimateShot for a shot on the second hit list.	;[ok]
AnimateShot2:	;$5092
	ld a, $01
	ldh [$FF95], a
	jr AnimateShotOnList

SECTION "Weapon Letters and Frames", ROMX[$536C], BANK[$1]

;Load the equipped weapon's two HUD letters, then redraw the HUD.	;[ok]
LoadWeaponHUD:	;$536C
	call LoadWeaponLetterTiles
	jp LoadWeaponShotTiles

;Copy the font tiles for the equipped weapon's two letters to $9600 and
;$9610.	;[ok]
LoadWeaponLetterTiles:	;$5372
	ld de, $DCD0
	push de
	ld a, [wCurrentWeapon]
	ld b, $01
	call GetWeaponLetters
	pop hl
	ld a, [hl+]
	push hl
	ld de, $9600
	call CopyLetterTile
	pop hl
	ld a, [hl+]
	ld de, $9610

;Copy the tile for character A (a screen-charmap code; $70 is the blank) to
;DE.	;[ok]
CopyLetterTile:	;$538C
	cp $70
	ld hl, BlankTile
	jr z, .l53A5
	sub $90
	swap a
	ld l, a
	and $0F
	ld h, a
	ld a, l
	and $F0
	add a, $1E
	ld l, a
	ld a, h
	adc a, $04
	ld h, a
.l53A5
	ld bc, $0010
	jp CopyVRAM

BlankTile:	;$53AB
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

;Store frame A at offset $0F, then set it: look the frame up in table DE,
;copy its hitbox to $C205-$C208 and point offset $0D at its metasprite.	;[ok]
SetShotFrameAndStore:	;$53BB
	ld b, a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], b
	ld a, b

;SetShotFrameAndStore without the store: frame A of table DE.	;[ok]
SetShotFrame:	;$53C2
	ld b, a
	ld a, $0D
	add a, c
	ld l, a
	push hl
	ld a, b
	ld l, e
	ld h, d
	call GetTablePointer
	ld a, [hl+]
	ld [wShotHitbox + 1], a
	ld a, [hl+]
	ld [wShotHitbox], a
	ld a, [hl+]
	ld [wShotHitbox + 3], a
	ld a, [hl+]
	ld [wShotHitbox + 2], a
	pop de
	ld a, l
	ld [de], a
	inc e
	ld a, h
	ld [de], a
	ld h, d
	ret

;The same, but the hitbox goes to $C219-$C21C (second hit list).	;[ok]
SetShotFrame2AndStore:	;$53E6
	ld b, a
	ld a, $0F
	add a, c
	ld l, a
	ld [hl], b
	ld a, b

;The same for the second hit list.	;[ok]
SetShotFrame2:	;$53ED
	ld b, a
	ld a, $0D
	add a, c
	ld l, a
	push hl
	ld a, b
	ld l, e
	ld h, d
	call GetTablePointer
	ld a, [hl+]
	ld [wShotHitbox2 + 1], a
	ld a, [hl+]
	ld [wShotHitbox2], a
	ld a, [hl+]
	ld [wShotHitbox2 + 3], a
	ld a, [hl+]
	ld [wShotHitbox2 + 2], a
	pop de
	ld a, l
	ld [de], a
	inc e
	ld a, h
	ld [de], a
	ld h, d
	ret
