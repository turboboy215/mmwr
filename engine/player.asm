;Mega Man: Dr. Wily's Revenge disassembly - Mega Man
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Player", ROMX[$66C5], BANK[$1]

;Clear $DF93. While it is set, PlayerControl throws away the damage waiting in
;$D838, so Mega Man takes no damage or knockback at all. This is the only write
;to $DF93 by address in the ROM (no other `ld [$DF93],a`, no `ld hl,$DF93`), so
;the flag looks like a leftover. Called by the game flow after the title.	;[ok]
ClearNoDamageFlag:	;$66C5
	xor a
	ld [$DF93], a
	ret

;$66CA: unreachable. Returns if bit 7 of $D80E is clear, and otherwise hangs -
;the same kind of trap as the sprite system's.	;[ok]
Unused_01_66CA:	;$66CA
	push bc
	ld b, a
	ld a, [$D80E]
	bit 7, a
	ld a, b
	pop bc
	ret z
.l66D4
	jr .l66D4

;Stage load: just FreeHurtSpark.	;[ok]
RoomFreeHurtSpark:	;$66D6
	call FreeHurtSpark
	ret

;Mega Man at the start of a stage: state 1 (alive), facing right, the buster
;unlocked.	;[ok]
InitPlayer:	;$66DA
	ld hl, wPlayerState
	ld [hl], $01
	ld a, $00
	ld [wPlayerAnim], a
	ld a, $01
	ld [wPlayerFacing], a
	xor a
	ld [$D80B], a
	call LoadPlayerTiles
	ld hl, wWeaponsUnlocked1
	set 0, [hl]
	call ClearSolidBoxes
	ret

;With Carry out, stop Mega Man walking into the side of the platform.	;[ok]
CheckCarrySideCollision:	;$66F9
	ld a, [wCurrentWeapon]
	cp $05
	ret nz
	ld a, [wShotSlots]
	or a
	ret z
	ld a, [wPlayerX]
	ld e, a
	ld hl, wShotSlots + 4
	ld a, [hl]
	add a, $ED
	cp e
	ret nc
	ld a, [hl]
	add a, $11
	cp e
	ret c
	ld a, [wPlayerY]
	ld e, a
	ld hl, wShotSlots + 8
	ld a, [hl]
	add a, $F0
	cp e
	ret nc
	ld a, [hl]
	add a, $10
	cp e
	ret c
	ld a, [$D81C]
	ld [wPlayerX], a
	ret

;Mega Man's frame, from the stage loop: state and controls, Carry, scroll
;tracking, then draw him, his hurt spark, and fire the weapon (wHookA) if he can.	;[ok]
UpdatePlayer:	;$672D
	ld a, $FF
	ldh [$FFB1], a
	call UpdatePlayerState
	call CheckCarrySideCollision
	call AccumulatePlayerDX
	call SetPlayerScreenX
	call UpdateCamera
	xor a
	ldh [$FFB1], a
	call ClearSolidBoxes
	ld a, [wPlayerState]
	cp $01
	ret nz
	call DrawPlayer
	call UpdateHurtSpark
	ld a, [$D869]
	or a
	jr nz, .l6760
	ld a, [wHurtTimer]
	cp $5A
	call c, wHookA
.l6760
	call UpdateScrolling
	ret

;Mega Man's life state (wPlayerState): 1 alive, 2 just died (start the death burst,
;take OAM entries for it, $F0-frame timer), 3 dying (on to LoseLife when the
;timer runs out). While alive, also run the teleport and the stage-clear exit.	;[ok]
UpdatePlayerState:	;$6764
	xor a
	ld [wPlayerHeld], a
	ld [wPlayerPressed], a
	ld [$D8C7], a
	ld a, [wPlayerY]
	ld [$D81E], a
	ld a, [wPlayerX]
	ld [$D81C], a
	ld a, [$D820]
	ld [$D81B], a
	ld a, [$D869]
	or a
	jp nz, PlayerControlEnd
	ld hl, wPlayerState
	ld a, [hl]
	cp $01
	jr z, .l67C9
	cp $02
	jr nz, .l67C0
	inc [hl]
	ld a, [$CE50]
	ld l, a
	ld h, $CE
	ld a, $0E
.l679C
	dec l
	dec a
	ld [hl], a
	jr nz, .l679C
	ld a, l
	ld [$CE50], a
	ld a, $FF
	ld [$CE58], a
	ld a, [wMusicSlot]
	ld [wAudioStopSlot], a
	call AudioStopSlot
	call SpawnPlayerDeathBurst
	ld a, $F0
	ld [$DF87], a
	xor a
	ld [$D850], a
	ret
.l67C0
	ld a, [$DF87]
	or a
	ret nz
	pop hl
	jp LoseLife
.l67C9
	ld a, [wTeleportState]
	or a
	jp nz, UpdateTeleport
	ld a, [wVictoryTimer + 1]
	or a
	jr nz, .l67E7
	ld a, [wVictoryTimer]
	cp $68
	jr nc, .l67E7
	ld a, [wBossesDefeated]
	and $0F
	cp $0F
	call nz, TeleportOutWhenGrounded
.l67E7
	call ReadPlayerJoypad

;Controls: Start opens the pause menu (not while shots are out, except with
;the Mirror Buster); otherwise walk, jump, climb, take damage.	;[ok]
PlayerControl:	;$67EA
	ld a, [wCurrentWeapon]
	cp $0A
	jr z, .l67F7
	ld a, [wShotCount]
	or a
	jr nz, .l6804
.l67F7
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l6804
	ld a, [$DF41]
	or a
	jp z, PauseMenu
.l6804
	ld a, [wFreezeFlags]
	and $F6
	jr z, .l6817
	call StopPlayer
	ld a, [wPlayerAnim]
	cp $2A
	call z, ChooseMotionAnim
	ret
.l6817
	ld a, [$DF93]
	or a
	jr z, .l6823
	xor a
	ld [$D838], a
	jr PlayerControlMove
.l6823
	ld a, [wPlayerY]
	cp $E0
	jr nc, .l6839
	cp $80
	jr c, .l6839
	ld hl, $D838
	ld [hl], $1F
	inc hl
	ld [hl], $00
	ld [$D838], a
.l6839
	ld hl, $D838
	ld a, [hl+]
	or [hl]
	jp nz, HandlePlayerDamage

;PlayerControl once Mega Man may move: by wPlayerMotion - in the air, on a
;ladder, or on the ground (walk, jump on A, climb down on Down at a ladder
;top).	;[ok]
PlayerControlMove:	;$6841
	call SetWalkVelocity
	ld a, [wPlayerMotion]
	or a
	jp z, UpdatePlayerAir
	cp $02
	jp z, UpdatePlayerLadder
	ld a, [wPlayerPressed]
	bit 0, a
	jp nz, StartJump
	ld a, [wPlayerHeld]
	bit 7, a
	jr z, .l6868
	call CheckTileBelowPlayer
	ld a, b
	cp $02
	jp z, ClimbDownLadderTop
.l6868
	xor a
	ld [$D805], a
	ld hl, $D826
	ld a, [hl+]
	or [hl]
	ld hl, $D817
	or [hl]
	inc hl
	or [hl]
	ld hl, $D809
	jr nz, .l6880
	xor a
	ld [hl], a
	jr .l689F
.l6880
	ld e, $02
	ld a, [hl]
	cp $06
	jr nc, .l689B
	inc [hl]
	ld a, $01
	ld [$D808], a
	ld a, [hl]
	cp $01
	ld e, $01
	jr z, .l689B
	ld a, $01
	ld [$D805], a
	jr .l689F
.l689B
	ld a, e
	ld [$D805], a
.l689F
	call MovePlayerX
	call CheckPlayerWalls
	call CheckPlayerLanding

;Common exit: choose the animation.	;[ok]
PlayerControlEnd:	;$68A8
	jp ChoosePlayerAnim

;Copy the joypad to wPlayerPressed and wPlayerHeld, unless $D845 says
;controls are locked.	;[ok]
ReadPlayerJoypad:	;$68AB
	call ReadJoypad
	ld a, [$D845]
	or a
	ret nz
	ldh a, [hJoypadPressed]
	ld [wPlayerPressed], a
	ldh a, [hJoypadHeld]
	ld [wPlayerHeld], a
	ret

;Damage and knockback. $D838 is the damage waiting to be taken (spikes and
;the collision pass add to it): 8 health per unit, death when health reaches 0
;(wPlayerState 2). A hit plays sound $06, starts the hit spark and sets
;wHurtTimer to $88; Mega Man is then pushed back (velocity from $D834) while it
;is $59 or more. With $CCF5 set (not traced) the hurt state is cancelled, and a
;hit that would take health below zero leaves 1.	;[ok]
HandlePlayerDamage:	;$68BE
	ld a, [$CCF5]
	or a
	jr z, .l68CC
	ld [hl], $00
	inc l
	ld [hl], $00
	jp PlayerControlMove
.l68CC
	ld a, [hl]
	or a
	jr z, .l68FA
	dec [hl]
	ld a, [hl]
	cp $59
	jr c, .l68F3
.l68D6
	ld a, [$D834]
	ld [$D82A], a
	ld a, [$D835]
	ld [$D82B], a
	bit 7, a
	ld a, $01
	jr nz, .l68E9
	dec a
.l68E9
	ld [wPlayerFacing], a
	xor a
	ld [wPlayerPressed], a
	ld [wPlayerHeld], a
.l68F3
	xor a
	ld [$D838], a
	jp PlayerControlMove
.l68FA
	dec hl
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld b, a
	ld hl, wEnergy
	ld a, [hl]
	sub b
	jr z, .l6913
	jr nc, .l691E
	ld a, [$CCF5]
	or a
	jr z, .l6913
	ld [hl], $01
	jr .l68F3
.l6913
	ld a, $01
	ld [$DF94], a
	ld a, $02
	ld [wPlayerState], a
	xor a
.l691E
	ld [hl], a
	call SpawnHurtSpark
	ld a, $06
	call QueueSound
	ld a, $88
	ld [wHurtTimer], a
	ld hl, wPlayerMotion
	ld a, [hl]
	cp $02
	jr nz, .l693B
	ld [hl], $00
	ld hl, $D806
	ld [hl], $00
.l693B
	xor a
	ld [wShootTimer], a
	jr .l68D6

;Mega Man was hit: start the three-frame hit spark at his position.	;[ok]
SpawnHurtSpark:	;$6941
	ld hl, $D83A
	xor a
	ld [hl+], a
	inc a
	ld [hl+], a
	ld a, $03
	push hl
	call AllocSprite
	pop hl
	ld [hl+], a
	ld a, [wPlayerX]
	ld [hl+], a
	ld a, [wPlayerY]
	ld [hl+], a
	ret

;Advance the hit spark (a frame every $14 frames, three frames) and draw it;
;frozen while the game is.	;[ok]
UpdateHurtSpark:	;$6959
	ld hl, $D83B
	ld a, [hl]
	or a
	ret z
	ld a, [wFreezeFlags]
	and $01
	jr nz, DrawHurtSpark
	dec hl
	inc [hl]
	ld a, [hl]
	cp $14
	jr c, DrawHurtSpark
	ld [hl], $00
	inc hl
	inc [hl]
	ld a, [hl]
	cp $04
	jr c, DrawHurtSpark

;Hit spark finished: release its sprite.	;[ok]
EndHurtSpark:	;$6976
	ld [hl], $00
	ld a, [$D83C]
	jp FreeSprite

;Release the hit spark's sprite.	;[ok]
FreeHurtSpark:	;$697E
	ld hl, $D83B
	ld a, [hl]
	or a
	ret z
	jr EndHurtSpark

;Draw the hit spark's current frame at Mega Man.	;[ok]
DrawHurtSpark:	;$6986
	ld a, [wPlayerX]
	ldh [$FFA2], a
	ld a, [wPlayerY]
	ldh [$FFA3], a
	ld a, [$D83B]
	ld hl, HurtSparkFrame1
	dec a
	jr z, .l69A2
	ld hl, HurtSparkFrame2
	dec a
	jr z, .l69A2
	ld hl, HurtSparkFrame3
.l69A2
	ld a, [$D80B]
	and $80
	ld [$D3EA], a
	ld a, $60
	ld [$CE55], a
	ld a, [$D83C]
	jp DrawMetasprite

;The hit spark's three metasprites.	;[ok]
HurtSparkFrame1:	;$69B5
	db $F2, $F1, $11, $00, $0A, $FE, $00, $14, $00, $00, $80
HurtSparkFrame2:	;$69C0
	db $F2, $F1, $11, $01, $0A, $FE, $01, $14, $00, $01, $80
HurtSparkFrame3:	;$69CB
	db $F2, $F1, $11, $02, $0A, $FE, $02, $14, $00, $02, $80

;Climb down from the top of a ladder: Y + 6, then GrabLadder.	;[ok]
ClimbDownLadderTop:	;$69D6
	ld hl, wPlayerY
	ld a, [hl]
	add a, $06
	ld [hl], a
	ld a, $08
	ld [$D806], a
	xor a
	ld [$D807], a
	call GrabLadder
	jp PlayerControlEnd

;Hurt animations: while wHurtTimer is $5A or more he is knocked back,
;alternating $1A and $1C every 4 frames; after that he blinks, animation $2A
;(a frame with no tiles) every other 4 frames.	;[ok]
ChooseHurtAnim:	;$69EC
	ld c, a
	ld a, [$D869]
	or a
	jr z, .l69F5
	set 2, c
.l69F5
	ld a, c
	cp $5A
	jr nc, .l6A05
	ld a, [$DF86]
	ld b, $2A
	bit 2, a
	jr z, .l6A0D
	jr ChooseMotionAnim
.l6A05
	ld b, $1A
	bit 2, c
	jr nz, .l6A0D
	ld b, $1C
.l6A0D
	jp SetPlayerAnim

;Animation: the hurt animations first while wHurtTimer runs.	;[ok]
ChoosePlayerAnim:	;$6A10
	ld a, [wHurtTimer]
	or a
	jr nz, ChooseHurtAnim

;Choose wPlayerAnim from what Mega Man is doing: jumping, climbing, walking
;(a four-step cycle from $6AE6) or standing (with an occasional blink), and the
;shooting versions of each while wShootTimer runs.	;[ok]
ChooseMotionAnim:	;$6A16
	ld a, [wPlayerMotion]
	or a
	jp z, ChooseAirAnim
	cp $02
	jp z, ChooseLadderAnim
	ld hl, $D817
	ld a, [hl+]
	or [hl]
	jr z, .l6A59
	xor a
	ld [$D804], a
	ld a, [$D805]
	or a
	ld b, $00
	jr z, SetPlayerAnim
	ld b, $04
	dec a
	jr z, SetPlayerAnim
	ld hl, $D808
	inc [hl]
	ld a, [hl]
	srl a
	srl a
	srl a
	and $03
	ld l, a
	ld a, [wShootTimer]
	or a
	jr z, .l6A50
	set 2, l
.l6A50
	ld h, $00
	ld de, WalkCycle
	add hl, de
	ld b, [hl]
	jr SetPlayerAnim
.l6A59
	ld hl, $D826
	ld a, [hl+]
	or [hl]
	ld b, $00
	jr nz, SetPlayerAnim
	ld hl, $D804
	inc [hl]
	ld a, [hl]
	cp $D7
	jr nc, .l6A79
	cp $C8
	jr c, SetPlayerAnim
	ld a, [wShootTimer]
	or a
	jr nz, .l6A79
	ld b, $02
	jr SetPlayerAnim
.l6A79
	ld [hl], $00

;Store animation B. Standing still while shooting becomes $1E (Mega Buster
;and Quick Boomerang) or $22 (the other weapons).	;[ok]
SetPlayerAnim:	;$6A7B
	ld a, b
	ld [wPlayerAnim], a
	cp $00
	ret nz
	ld a, [wShootTimer]
	ld c, a
	or a
	ret z
	ld b, $1E
	ld a, [wCurrentWeapon]
	or a
	jr z, .l6A96
	cp $08
	jr z, .l6A96
	ld b, $22
.l6A96
	ld a, b
	ld [wPlayerAnim], a
	ret

;On a ladder: getting on or off ($18), shooting ($14 or $16), else climbing
;($10/$12, alternating with his Y).	;[ok]
ChooseLadderAnim:	;$6A9B
	xor a
	ld [$D804], a
	ld a, [$D806]
	or a
	jr z, .l6AA9
	ld b, $18
	jr SetPlayerAnim
.l6AA9
	ld a, [wShootTimer]
	or a
	jr z, .l6ABB
	ld b, $14
	ld a, [wCurrentWeapon]
	or a
	jr z, SetPlayerAnim
	ld b, $16
	jr SetPlayerAnim
.l6ABB
	ld a, [$D869]
	or a
	jr nz, .l6ACF
	ld a, [wPlayerY]
.l6AC4
	srl a
	srl a
	and $02
	add a, $10
	ld b, a
	jr SetPlayerAnim
.l6ACF
	ld a, [$DF86]
	srl a
	jr .l6AC4

;In the air: $0C, or $0E shooting.	;[ok]
ChooseAirAnim:	;$6AD6
	xor a
	ld [$D804], a
	ld b, $0C
	ld a, [wShootTimer]
	or a
	jr z, SetPlayerAnim
	ld b, $0E
	jr SetPlayerAnim

;Walking animation cycle, plain and shooting.	;[ok]
WalkCycle:	;$6AE6
	db $06, $08, $0A, $08, $24, $26, $28, $26

;$D84E = how far Mega Man moved in X this frame; add it to the 16-bit
;$D80D.	;[ok]
AccumulatePlayerDX:	;$6AEE
	ld a, [$D81C]
	ld e, a
	ld a, [wPlayerX]
	sub e
	ld e, a
	ld d, $00
	jr nc, .l6AFC
	dec d
.l6AFC
	ld bc, $D852
	ld hl, $D80D
	ld a, [hl]
	ld [bc], a
	inc bc
	add a, e
	ld [hl+], a
	ld a, [hl]
	ld [bc], a
	adc a, d
	ld [hl], a
	ld a, e
	ld [$D84E], a
	ret

;A pressed: leave the ground with a 10-frame rise ($D84A).	;[ok]
StartJump:	;$6B10
	nop
	xor a
	ld [wPlayerMotion], a
	ld a, $0A
	ld [$D84A], a
	ld a, $00
	ld [$D84B], a
	ld a, $00
	ld [$D84C], a

;In the air. During the 10-frame rise ($D84A), holding A keeps the full jump
;speed (-$2E0, -$2B0 under water); letting go early cuts it to $D84B, a speed
;that has been growing by $49 a frame since take-off - so a short press gives
;a short jump. Then gravity, movement, walls and ceiling, landing; Up over a
;ladder (block 1) grabs it.	;[ok]
UpdatePlayerAir:	;$6B24
	ld hl, $D84A
	ld a, [hl]
	or a
	jr z, .l6B78
	dec [hl]
	jr z, .l6B4A
	ld de, $FFB7
	ld a, [wUnderwater]
	or a
	jr z, .l6B3A
	ld de, $FFBC
.l6B3A
	ld hl, $D84B
	ld a, [hl]
	add a, e
	ld [hl+], a
	ld a, [hl]
	adc a, d
	ld [hl], a
	ld a, [wPlayerHeld]
	bit 0, a
	jr nz, .l6B5C
.l6B4A
	xor a
	ld [$D84A], a
	ld a, [$D84B]
	ld [$D828], a
	ld a, [$D84C]
	ld [$D829], a
	jr .l6B78
.l6B5C
	ld a, [wUnderwater]
	or a
	jr nz, .l6B6E
	ld a, $20
	ld [$D828], a
	ld a, $FD
	ld [$D829], a
	jr .l6B78
.l6B6E
	ld a, $50
	ld [$D828], a
	ld a, $FD
	ld [$D829], a
.l6B78
	call ApplyPlayerGravity
	call MovePlayerY
	call CheckPlayerFloorCeiling
	ld hl, $D817
	ld a, [hl+]
	or [hl]
	jr z, .l6B8D
	ld a, $06
	ld [$D809], a
.l6B8D
	call MovePlayerX
	call CheckPlayerWalls
	call CheckPlayerWallsMid
	ld a, [wPlayerHeld]
	bit 6, a
	jr z, .l6BB0
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	call CheckSolidAt
	dec b
	jr nz, .l6BB0
	call GrabLadder
	jp PlayerControlEnd
.l6BB0
	call CheckPlayerLanding
	jp z, PlayerControlEnd
	xor a
	ld [$D828], a
	ld [$D829], a
	jp PlayerControlEnd

;Zero Mega Man's velocities.	;[ok]
StopPlayer:	;$6BC0
	xor a
	ld [$D828], a
	ld [$D829], a
	ld [$D826], a
	ld [$D827], a
	ret

;Grab a ladder: state 2, X snapped to the ladder's column.	;[ok]
GrabLadder:	;$6BCE
	ld a, $02
	ld [wPlayerMotion], a
	ld hl, wPlayerX
	ld a, [wShadowSCX]
	ld d, a
	add a, [hl]
	and $F0
	sub d
	add a, $08
	ld [hl], a
	xor a
	ld hl, $D826
	ld [hl+], a
	ld [hl], a
	ret

;On a ladder: climb with Up and Down (SetClimbVelocity), get off at the top or
;bottom; A lets go.	;[ok]
UpdatePlayerLadder:	;$6BE8
	ld hl, $D806
	ld a, [hl]
	or a
	jr z, .l6C16
	dec [hl]
	jp nz, .l6CB4
	xor a
	ld hl, $D828
	ld [hl+], a
	ld [hl+], a
	ld a, [$D807]
	or a
	jr nz, .l6C09
	ld a, [wPlayerY]
	add a, $0E
	ld [wPlayerY], a
	jr .l6C16
.l6C09
	ld a, [wPlayerY]
	sub $07
	ld [wPlayerY], a
	ld e, $01
	jp .l6C99
.l6C16
	ld a, [wShootTimer]
	or a
	jp z, .l6C25
	ld a, [wPlayerHeld]
	and $0F
	ld [wPlayerHeld], a
.l6C25
	ld a, [wPlayerPressed]
	bit 0, a
	jr nz, .l6C97
	call SetClimbVelocity
	call MovePlayerY
	ld hl, $D828
	ld a, [hl+]
	or [hl]
	jr z, .l6CB4
	ld a, [hl]
	and $80
	jr nz, .l6C5A
	call CheckTileBelowPlayer
	jr nc, .l6C4C
	ld a, b
	cp $02
	jr z, .l6C4C
	ld a, $01
	jr .l6CAD
.l6C4C
	call CheckSolidAtPlayer
	ld a, b
	cp $01
	jr z, .l6CB4
	cp $02
	jr z, .l6CB4
	jr .l6C97
.l6C5A
	call CheckSolidAtPlayer
	ld a, b
	cp $01
	jr z, .l6C7E
	cp $02
	jr nz, .l6C97
	ld a, [wPlayerY]
	bit 3, a
	jr nz, .l6CB4
	sub $0D
	ld [wPlayerY], a
	ld a, $08
	ld [$D806], a
	ld a, $01
	ld [$D807], a
	jr .l6CB4
.l6C7E
	call CheckTileAbovePlayer
	jr nc, .l6CB4
	ld a, b
	cp $02
	jr z, .l6CB4
	ld a, [$D81E]
	ld [wPlayerY], a
	xor a
	ld [$D828], a
	ld [$D829], a
	jr .l6CB4
.l6C97
	ld e, $00
.l6C99
	xor a
	ld hl, $D817
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld hl, $D826
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, e
.l6CAD
	ld [wPlayerMotion], a
	xor a
	ld [$D84A], a
.l6CB4
	jp PlayerControlEnd

;Add the Y speed ($D828-$D829) to Mega Man's Y ($D823-$D825).	;[ok]
MovePlayerY:	;$6CB7
	ld hl, $D823
	ld a, [$D828]
	add a, [hl]
	ld [hl+], a
	ld a, [$D829]
	adc a, [hl]
	ld [hl+], a
	ld a, $00
	adc a, [hl]
	ld [hl], a
	ret

;Gravity: Y speed += $34, or $12 under water (wUnderwater), capped at +$0340 and
;-$0341.	;[ok]
ApplyPlayerGravity:	;$6CC9
	ld a, [wUnderwater]
	or a
	ld e, $34
	jr z, .l6CD3
	ld e, $12
.l6CD3
	ld hl, $D828
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, [hl]
	adc a, $00
	ld d, a
	ld hl, $D832
	ld a, [hl]
	ld [hl], $00
	inc hl
	add a, e
	ld e, a
	ld a, [hl]
	ld [hl], $00
	adc a, d
	ld d, a
	bit 7, d
	jr nz, .l6CFC
	ld a, $40
	sub e
	ld a, $03
	sbc a, d
	jr nc, .l6D07
	ld de, $0340
	jr .l6D07
.l6CFC
	ld a, $BF
	sub e
	ld a, $FC
	sbc a, d
	jr c, .l6D07
	ld de, $FCBF
.l6D07
	ld a, e
	ld [$D828], a
	ld a, d
	ld [$D829], a
	ret

;Collision probes, (dx, dy) from Mega Man's centre: head, feet, and two
;points either side of his middle.	;[ok]
ProbeHeadLeft:	;$6D10
	db $FA, $F8
ProbeHeadRight:	;$6D12
	db $06, $F8
ProbeFeetLeft:	;$6D14
	db $FA, $0C
ProbeFeetRight:	;$6D16
	db $06, $0C
ProbeUpperLeft:	;$6D18
	db $FA, $FD
ProbeUpperRight:	;$6D1A
	db $06, $FD
ProbeLowerLeft:	;$6D1C
	db $FA, $05
ProbeLowerRight:	;$6D1E
	db $06, $05

;Vertical collision: while rising, stop at a ceiling (head probes); while
;falling, at a floor (feet probes) - moving Mega Man a pixel at a time out of
;the block.	;[ok]
CheckPlayerFloorCeiling:	;$6D20
	xor a
	ld [$D84D], a
.l6D24
	ld a, [$D829]
	bit 7, a
	jr z, .l6D5E
	ld a, [wPlayerY]
	cp $F8
	jr nc, .l6D36
	cp $C0
	jr nc, .l6D46
.l6D36
	ld hl, ProbeHeadLeft
	call CheckSolidNearPlayer
	jr c, .l6D46
	ld hl, ProbeHeadRight
	call CheckSolidNearPlayer
	jr nc, .l6D6E
.l6D46
	xor a
	ld [$D84A], a
	inc a
	ld [$D84D], a
	ld hl, wPlayerY
	ld a, [$D829]
	bit 7, a
	jr z, .l6D5B
	inc [hl]
	jr .l6D5C
.l6D5B
	dec [hl]
.l6D5C
	jr .l6D24
.l6D5E
	ld hl, ProbeFeetLeft
	call CheckSolidNearPlayer
	jr c, .l6D46
	ld hl, ProbeFeetRight
	call CheckSolidNearPlayer
	jr c, .l6D46
.l6D6E
	ld a, [$D84D]
	or a
	ret z
	xor a
	ld [$D828], a
	ld [$D829], a
	ret

;Horizontal collision: walking into a wall puts Mega Man back where he was
;this frame and zeroes his X speed. Carry if he was stopped. The `cp $9C` here
;and `cp $04` in CheckPlayerWallsLeft test $D827, this frame's whole-pixel X
;movement, which never reaches those values in its direction, so both tests are
;dead; they look like screen-edge checks meant for wPlayerX.	;[ok]
CheckPlayerWalls:	;$6D7B
	ld a, [$D827]
	bit 7, a
	jr nz, CheckPlayerWallsLeft
	cp $9C
	jr nc, BlockPlayerX
	ld hl, ProbeHeadRight
	call CheckSolidNearPlayer
	jr c, BlockPlayerX
	ld hl, ProbeFeetRight
	call CheckSolidNearPlayer
	ret nc

;Blocked: back to last frame's X, X speed zero, carry.	;[ok]
BlockPlayerX:	;$6D95
	ld a, [$D81C]
	ld [wPlayerX], a
	ld a, [$D81B]
	ld [$D820], a
	xor a
	ld [$D826], a
	ld [$D827], a
	scf
	ret

;Moving left: the left probes (and a dead `cp $04`, see CheckPlayerWalls).	;[ok]
CheckPlayerWallsLeft:	;$6DAA
	cp $04
	jr c, BlockPlayerX
	ld hl, ProbeHeadLeft
	call CheckSolidNearPlayer
	jr c, BlockPlayerX
	ld hl, ProbeFeetLeft
	call CheckSolidNearPlayer
	jr c, BlockPlayerX
	ret

;Horizontal collision with the probes nearer his middle, used in the air.	;[ok]
CheckPlayerWallsMid:	;$6DBF
	ld a, [$D827]
	bit 7, a
	jr nz, .l6DD7
	ld hl, ProbeUpperRight
	call CheckSolidNearPlayer
	jr c, .l6DD5
	ld hl, ProbeLowerRight
	call CheckSolidNearPlayer
	ret nc
.l6DD5
	jr BlockPlayerX
.l6DD7
	ld hl, ProbeUpperLeft
	call CheckSolidNearPlayer
	jr c, .l6DD5
	ld hl, ProbeLowerLeft
	call CheckSolidNearPlayer
	jr c, .l6DD5
	ret

;CheckSolidAt 8 pixels above Mega Man.	;[ok]
CheckTileAbovePlayer:	;$6DE8
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	add a, $F8
	jp CheckSolidAt

;CheckSolidAt $0D pixels below Mega Man (just under his feet).	;[ok]
CheckTileBelowPlayer:	;$6DF4
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	add a, $0D
	jp CheckSolidAt

;If his feet are on something and he is not rising, land (sound $08 the
;first frame): state 1 on the ground, 0 in the air.	;[ok]
CheckPlayerLanding:	;$6E00
	call CheckPlayerFeet
	jr c, .l6E08
.l6E05
	xor a
	jr .l6E27
.l6E08
	ld a, [$D829]
	and $80
	jr nz, .l6E05
	ld [$D828], a
	ld [$D829], a
	ld a, b
	ld [$D8C7], a
	ld a, [wPlayerMotion]
	cp $01
	jr z, .l6E25
	ld a, $08
	call QueueSound
.l6E25
	ld a, $01
.l6E27
	ld [wPlayerMotion], a
	or a
	ret

;CheckSolidAt Mega Man plus the (dx, dy + 1) at HL.	;[ok]
CheckPlayerProbe:	;$6E2C
	ld a, [wPlayerX]
	add a, [hl]
	inc hl
	ld e, a
	ld a, [wPlayerY]
	inc a
	add a, [hl]
	jp CheckSolidAt

;Carry if either foot probe is solid.	;[ok]
CheckPlayerFeet:	;$6E3A
	ld hl, ProbeFeetLeft
	call CheckPlayerProbe
	ret c
	ld hl, ProbeFeetRight
	jp CheckPlayerProbe

;Add the X speed to Mega Man's X, with the slide/ice adjustment from
;$6E92.	;[ok]
MovePlayerX:	;$6E47
	ld hl, $D82A
	ld a, [$D817]
	add a, [hl]
	ld e, a
	ld a, [$D818]
	inc hl
	adc a, [hl]
	ld d, a
	call ClampPlayerSpeedX
	ld hl, $D820
	ld a, e
	add a, [hl]
	ld [hl+], a
	ld a, d
	adc a, [hl]
	ld [hl+], a
	ld hl, $D82B
	ld a, [hl-]
	ld b, a
	ld c, [hl]
	or c
	jr z, .l6E91
	ld a, [wPlayerMotion]
	or a
	jr z, .l6E73
	ld a, [wFloorType]
.l6E73
	add a, a
	bit 7, b
	jr nz, .l6E79
	inc a
.l6E79
	add a, a
	add a, LOW(FloorFriction)
	ld e, a
	ld a, HIGH(FloorFriction)
	adc a, $00
	ld d, a
	ld a, [de]
	add a, [hl]
	ld [hl+], a
	inc de
	ld a, [de]
	adc a, [hl]
	ld [hl], a
	xor b
	and $80
	jr z, .l6E91
	xor a
	ld [hl-], a
	ld [hl], a
.l6E91
	ret

;Friction per floor type (wFloorType), one step toward zero speed: (moving
;left, moving right). Ice is 1.	;[ok]
FloorFriction:	;$6E92
	dw $0006, $FFFA
	dw $0028, $FFD8
	dw $0001, $FFFF

;Clamp the X speed to $F0 ($C0 under water).	;[ok]
ClampPlayerSpeedX:	;$6E9E
	ld bc, $00F0
	ld a, [wUnderwater]
	or a
	jr z, .l6EAA
	ld bc, $00C0
.l6EAA
	bit 7, d
	jr nz, .l6EBA
	ld a, e
	or d
	ld a, c
	sub e
	ld a, b
	sbc a, d
	jr nc, .l6EC8
	ld e, c
	ld d, b
	jr .l6EC8
.l6EBA
	ld a, c
	cpl
	ld c, a
	ld a, b
	cpl
	ld b, a
	ld a, c
	sub e
	ld a, b
	sbc a, d
	jr c, .l6EC8
	ld e, c
	ld d, b
.l6EC8
	ld a, e
	ld [$D82A], a
	ld a, d
	ld [$D82B], a
	ld hl, $D830
	ld a, [hl]
	ld [hl], $00
	inc hl
	add a, e
	ld e, a
	ld [$D826], a
	ld a, [hl]
	ld [hl], $00
	adc a, d
	ld d, a
	ld [$D827], a
	ret

;Facing and walking speed from left/right.	;[ok]
SetWalkVelocity:	;$6EE5
	ld a, [wPlayerHeld]
	ld c, a
	ld b, $00
	and $20
	jr nz, .l6EFF
	inc b
	bit 4, c
	jr nz, .l6EFF
	ld a, $00
	ld [$D817], a
	ld a, $00
	ld [$D818], a
	ret
.l6EFF
	ld a, b
	ld [wPlayerFacing], a
	ld a, [wPlayerMotion]
	or a
	jr z, .l6F0C
	ld a, [wFloorType]
.l6F0C
	add a, a
	add a, b
	add a, a
	add a, LOW(FloorWalkAccel)
	ld l, a
	ld a, HIGH(FloorWalkAccel)
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld [$D817], a
	ld a, [hl+]
	ld [$D818], a
	ret

;Walking acceleration per floor type: (left, right). Ice is 4.	;[ok]
FloorWalkAccel:	;$6F20
	dw $FFC0, $0040
	dw $FFC0, $0040
	dw $FFFC, $0004

;Ladder: up -$A0, down +$A0, else 0.	;[ok]
SetClimbVelocity:	;$6F2C
	ld a, [wPlayerHeld]
	ld c, a
	ld de, $FF60
	and $40
	jr nz, .l6F42
	ld de, $00A0
	ld a, c
	and $80
	jr nz, .l6F42
	ld de, $0000
.l6F42
	ld a, e
	ld [$D828], a
	ld a, d
	ld [$D829], a
	ret

;Draw Mega Man into shadow OAM from $C000: frame (wPlayerAnim + facing) from
;MegaManFrames, at his position, flipped by $D80B; unused entries hidden.	;[ok]
DrawPlayer:	;$6F4B
	ld a, [wPlayerAnim]
	ld hl, wPlayerFacing
	add a, [hl]
	ld l, a
	ld h, $00
	add hl, hl
	ld de, MegaManFrames
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [wPlayerX]
	add a, $08
	add a, [hl]
	ldh [$FF92], a
	inc hl
	ld a, [wPlayerY]
	add a, $12
	add a, [hl]
	ldh [hBank1CallIndex], a
	ldh [$FF94], a
	inc hl
	ld a, [hl+]
	ld b, a
	swap a
	and $0F
	ld c, a
	ld a, b
	and $0F
	ld b, a
	ld de, wShadowOAM
	xor a
	ldh [$FF93], a
.l6F82
	push bc
	ldh a, [$FF92]
	ld b, a
.l6F86
	ld a, [hl+]
	cp $FF
	jr z, .l6FAD
	dec hl
	ldh a, [hBank1CallIndex]
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	ld a, [hl]
	and $7F
	ld [de], a
	inc de
	ld a, [hl+]
	and $80
	ld a, [$D80B]
	jr z, .l6FA2
	or $20
.l6FA2
	ld [de], a
	inc de
	ldh a, [$FF93]
	inc a
	ldh [$FF93], a
	cp $0B
	jr nc, .l701A
.l6FAD
	ld a, b
	add a, $08
	ld b, a
	dec c
	jr nz, .l6F86
	pop bc
	ldh a, [hBank1CallIndex]
	add a, $08
	ldh [hBank1CallIndex], a
	dec b
	jr nz, .l6F82
.l6FBE
	ld a, [hl+]
	cp $80
	jr z, .l6FE8
	ld c, a
	ld a, [hl+]
	ld b, a
	ldh a, [$FF94]
	add a, b
	ld [de], a
	inc de
	ldh a, [$FF92]
	add a, c
	ld [de], a
	inc de
	ld a, [hl]
	and $7F
	ld [de], a
	inc de
	ld a, [hl+]
	and $80
	ld a, [$D80B]
	jr z, .l6FDF
	or $20
.l6FDF
	ld [de], a
	inc de
	ldh a, [$FF93]
	inc a
	ldh [$FF93], a
	jr .l6FBE
.l6FE8
	ldh a, [$FF93]
	ld b, a
	ld a, $0B
	sub b
	and $0F
	jr z, .l6FFF
	ld b, a
	ld l, e
	ld h, d
	ld de, $0004
	ld a, $A0
.l6FFA
	ld [hl], a
	add hl, de
	dec b
	jr nz, .l6FFA
.l6FFF
	ld a, [wPlayerAnim]
	cp $1C
	ret nz
	ld de, $0004
	ld hl, wShadowOAM + $1B
	ld a, [hl]
	or $40
	ld [hl], a
	add hl, de
	ld a, [hl]
	or $40
	ld [hl], a
	add hl, de
	ld a, [hl]
	or $40
	ld [hl], a
	ret
.l701A
	pop bc
	ret

SECTION "Teleport", ROMX[$72D4], BANK[$1]

;Teleport (wTeleportState): 1 the beam drops in from the top until it lands and turns
;into Mega Man, 2 and 3 the beam leaves.	;[ok]
UpdateTeleport:	;$72D4
	ld a, [wTeleportState]
	cp $01
	jr nz, .l7328
	ld a, [$DFCD]
	or a
	jr nz, .l7301
	ld hl, wPlayerY
	ld a, [hl]
	cp $1E
	jr c, .l7321
	cp $F0
	jr nc, .l7321
	ld b, $06
.l72EF
	ld hl, wPlayerY
	inc [hl]
	push bc
	call CheckTileBelowPlayer
	pop bc
	ld e, $2C
	jr c, .l7301
	dec b
	jr nz, .l72EF
	jr .l731C
.l7301
	call StepTeleportBeam
	jr nc, .l731C
	ld a, $01
	ld [wPlayerMotion], a
	xor a
	ld [wTeleportState], a
	ld a, [wPlayerX]
	cp $50
	ld a, $00
	jr nc, .l7319
	inc a
.l7319
	ld [wPlayerFacing], a
.l731C
	ld a, e
	ld [wPlayerAnim], a
	ret
.l7321
	add a, $06
	ld [hl], a
	ld e, $2C
	jr .l731C
.l7328
	cp $02
	jr z, .l7334
	cp $03
	jr z, .l7352
	ld e, $2A
	jr .l734D
.l7334
	call StepTeleportBeam
	jr nc, .l734D
	ld hl, wPlayerY
	ld a, [hl]
	sub $08
	ld [hl], a
	cp $90
	jr c, .l734D
	cp $F0
	jr nc, .l734D
.l7348
	ld a, $FF
	ld [wTeleportState], a
.l734D
	ld a, e
	ld [wPlayerAnim], a
	ret
.l7352
	call StepTeleportBeamFast
	jr c, .l7348
	jr .l734D

;Teleport beam animation steps: E = the frame, carry once it is done.	;[ok]
StepTeleportBeam:	;$7359
	ld hl, $DFCD
	inc [hl]
	ld a, [hl]
	ld e, $2E
	cp $04
	jr c, TeleportBeamNotDone
	ld e, $30
	cp $08
	jr c, TeleportBeamNotDone
	ld e, $2C
	cp $0C
	jr c, TeleportBeamNotDone
	scf
	ret

;Not done yet: no carry.	;[ok]
TeleportBeamNotDone:	;$7372
	or a
	ret

;A faster version of the beam animation, for teleport state 3.	;[ok]
StepTeleportBeamFast:	;$7374
	ld hl, $DFCD
	inc [hl]
	ld a, [hl]
	ld e, $2E
	cp $03
	jr c, TeleportBeamNotDone
	ld e, $30
	cp $06
	jr c, TeleportBeamNotDone
	ld e, $2C
	cp $07
	jr c, TeleportBeamNotDone
	scf
	ret
