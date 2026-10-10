;Mega Man: Dr. Wily's Revenge disassembly - object type 48, WilyMachine
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "WilyMachine (type 48)", ROMX[$48D9], BANK[$D]

;Type 48, placed once in Wily 3's last room: the Wily Machine fight, run as a
;chain of states (ObjSetState). It is what makes the room the Wily Machine: its
;spawn streams the room's background tiles, WilyMachineRoomTiles (80 tiles,
;bank $0D's own - not bank $06's cutscene set), to $9000.	;[ok]
;Spawn: wWilyProgress $9F, wBossesDefeated $0F, $CC5B-$CC5D cleared (fight
;flags, damage, flash timer), palettes black, invisible (flags 0), controls
;locked ($D845), wStageState 1. Then:
; 1 stream the 80 tiles in, $40 bytes a frame; spawn type 49; fade in over 128
;   frames (WilyMachineFadeInPalettes) and show the boss bar ($C100).
; 2 type 49 fills the bar and fights (phase 1). When it is killed ($CC5B bit
;   0) and the explosions are over: a burst at (X $7C, Y $2B), and 10 frames
;   later this object appears there - Dr. Wily in the cockpit, a hitbox over
;   the whole machine but hit points $FE - with type 50 and the cannon part
;   (WilyMachineInitCannon); then 16 tiles are streamed over the first ones,
;   which opens the dome in the background (WilyMachineDomeOpenTiles).
; 3 sound $19, 300 frames, then the bar refills (ObjStartBossBarFill) and
;   $CC5B bit 1 starts phase 2: the cannon fires type 51s, type 50 bites, and
;   the only damage is $CC5C, written by a type 51 that Mirror Buster sent back
;   (WilyMachineCheckDamage: 8 bar units per point, 20-frame flash).
; 4 bar empty ($CCF5): a death explosion at the cannon; after the explosions,
;   150 frames of palette flicker and explosion sounds; then a 12-tile sprite:
;   Dr. Wily jumps out and falls to Y $64, wStageState 2 (the victory jingle);
;   360 frames, 180 more, a fade to white (WilyFadePalettes); then
;   wVictoryTimer 0 and wStageState 3, so StageFrameLoop's .stageCleared runs
;   with stage index 6 and jumps to .ending (bank $0E). The victory timer is
;   held at $01E0 every frame until then.	;[ok]
;Frame: runs the state (unless anything is frozen), the cannon and the damage
;check, and keeps its position at $CCF2/$CCF3. Killed: B = 0 (it is never
;shootable with hit points that can run out). Ice Slasher: ObjClearFreeze.	;[ok]
WilyMachineRoutine:	;$48D9
	ld a, b
	or a
	jr z, .l48F4
	dec a
	jr z, .l4948
	dec a
	jr z, .l48E6
	dec a
	jr z, .l48F1
.l48E6
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	dec a
	jr nz, .l48EE
.l48EE
	ld b, $00
	ret
.l48F1
	jp ObjClearFreeze_0D
.l48F4
	ld a, $9F
	ld [wWilyProgress], a
	ld a, $0F
	ld [wBossesDefeated], a
	xor a
	ld [$CC5B], a
	ld [$CC5C], a
	ld [$CC5D], a
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ldh [rOBP1], a
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $64
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $17
	add a, c
	ld l, a
	ld [hl], $00
	ld a, $15
	add a, c
	ld l, a
	ld [hl], LOW(FrameTable_0D_52C4)
	inc l
	ld [hl], HIGH(FrameTable_0D_52C4)
	ld a, $01
	ld [$D845], a
	ld a, $01
	ld [wPlayerFacing], a
	ld [wStageState], a
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $00
	ld de, WilyMachineLoadTiles
	call ObjSetState
	ld b, $01
	ret
.l4948
	ld a, [wFreezeFlags]
	or a
	jp nz, WilyMachineFrame
	ld de, WilyMachineFrame
	push de
	ld a, $3E
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push de
	ret

WilyMachineFrame:	;$495C
	call WilyMachineUpdateCannon
	call WilyMachineCheckDamage
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
	ld a, $0F
	add a, c
	ld l, a
	ld a, e
	ld [$CCF2], a
	ld a, [hl]
	ld [$CCF3], a
	ld b, $01
	ret

;Unused: nothing calls it. Animates through all 22 frames (Data_0D_527A).	;[ok]
WilyMachineAnimateUnused:	;$4981
	ld de, Data_0D_527A
	call AnimateObjectFacing_0D
	ret

WilyMachineLoadTiles:	;$4988
	ld l, c
	push hl
	ld hl, WilyMachineRoomTiles
	ld de, VRAM_TILES2
	ld bc, WilyMachineRoomTilesEnd - WilyMachineRoomTiles
	ld a, $40
	call QueueTileCopy_0D
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rOBP1], a
	pop hl
	ld c, l
	ld de, WilyMachineWaitTiles
	call ObjSetState
	ret

WilyMachineWaitTiles:	;$49A8
	ld l, c
	push hl
	call CopyQueuedTiles_0D
	pop hl
	ld c, l
	ret c
	call WilyMachineLowerCannonSpawn
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $00
	ld de, WilyMachineFadeIn
	jp ObjSetState

WilyMachineLoadDomeOpenTiles:	;$49BF
	ld l, c
	push hl
	ld hl, WilyMachineDomeOpenTiles
	ld de, VRAM_TILES2
	ld bc, WilyMachineDomeOpenTilesEnd - WilyMachineDomeOpenTiles
	ld a, $40
	call QueueTileCopy_0D
	pop hl
	ld c, l
	ld de, WilyMachineWaitDomeOpenTiles
	call ObjSetState
	ret

WilyMachineWaitDomeOpenTiles:	;$49D8
	ld l, c
	push hl
	call CopyQueuedTiles_0D
	pop hl
	ld c, l
	ret c
	ld de, WilyMachineStartPause
	call ObjSetState
	ret

WilyMachineFadeIn:	;$49E7
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $80
	jr nc, .l4A0C
	srl a
	srl a
	srl a
	srl a
	and $06
	add a, LOW(WilyMachineFadeInPalettes)
	ld e, a
	ld a, $00
	adc a, HIGH(WilyMachineFadeInPalettes)
	ld d, a
	ld a, [de]
	inc de
	ld [wShadowBGP], a
	ld a, [de]
	ldh [rOBP1], a
	ret
.l4A0C
	ld a, $01
	ld [$C100], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $0A
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $00
	ld de, WilyMachineWaitPhase1
	jp ObjSetState

;BGP, OBP1 pairs for the fade in, 32 frames each.	;[ok]
WilyMachineFadeInPalettes:	;$4A23
	db $FF, $FF
	db $FE, $EC
	db $F9, $D8
	db $E4, $C4

;State: wait for type 49's death ($CC5B bit 0) and the end of the explosions,
;then the burst and the appearance (10-frame countdown in $27). The `call
;JumpCallBank1Routine` with A = 0 here is never reached ($09 is non-zero there,
;so `inc a / cp 1` never matches).	;[ok]
WilyMachineWaitPhase1:	;$4A2B
	ld a, [$CC5B]
	bit 0, a
	ret z
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4A47
	inc a
	cp $01
	jr nz, .l4A4C
	ld [hl], a
	ld l, c
	push hl
	xor a
	call JumpCallBank1Routine
	pop hl
	ld c, l
.l4A47
	ld a, [$D30C]
	or a
	ret nz
.l4A4C
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4A8D
	dec [hl]
	jr z, .l4A69
	ld a, [hl]
	dec a
	jr z, .l4A5C
	ret
.l4A5C
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld e, $7C
	ld d, $2B
	jp SpawnExplosionBurstAt
.l4A69
	ld a, $02
	call JumpQueueSound
	ld de, WilyMachineCockpitPosition
	call ObjSetPosition
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $65
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld de, Data_0D_529A
	call AnimateObject_0D
	call WilyMachineBitingHeadSpawn
	call WilyMachineInitCannon
	ret
.l4A8D
	ld de, WilyMachineLoadDomeOpenTiles
	jp ObjSetState

WilyMachineCockpitPosition:	;$4A93
	db $7C, $2B

WilyMachineStartPause:	;$4A95
	ld a, $19
	call JumpQueueSound
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $2C
	inc l
	ld [hl], $01
	ld de, WilyMachinePause
	jp ObjSetState

WilyMachinePause:	;$4AA9
	ld a, $27
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	ld a, e
	or d
	jr z, .l4AB9
	dec de
	ld [hl], d
	dec l
	ld [hl], e
	ret
.l4AB9
	ld a, [$CC5B]
	set 1, a
	ld [$CC5B], a
	ld b, $13
	ld de, WilyMachinePhase2
	jp ObjStartBossBarFill

WilyMachinePhase2:	;$4AC9
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $65
	ld a, [$CCF5]
	or a
	jr nz, .l4AE2
	ld de, Data_0D_529A
	call AnimateObject_0D
	ret
.l4AE2
	ld a, [$D30C]
	or a
	ret nz
	ld a, [$CC5B]
	set 3, a
	ld [$CC5B], a
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $96
	ld de, WilyMachineExplode
	jp ObjSetState

WilyMachineExplode:	;$4AFB
	ld a, $E0
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4B21
	dec [hl]
	and $04
	ld a, $E4
	jr z, .l4B16
	ld a, $EB
.l4B16
	ld [wShadowBGP], a
	ld l, c
	push hl
	call WilyMachineExplosionSound
	pop hl
	ld c, l
	ret
.l4B21
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $01
	ld de, WilyJumpOut
	jp ObjSetState

WilyJumpOut:	;$4B2D
	ld a, $27
	add a, c
	ld l, a
	dec [hl]
	jr z, .l4B3A
	ld a, $EB
	ld [wShadowBGP], a
	ret
.l4B3A
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FF
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	ld l, c
	push hl
	call JumpFreeSprite
	ld a, $0C
	call JumpAllocSprite
	ld b, a
	pop hl
	ld c, l
	ld [hl], b
	ld a, $EB
	ld [wShadowBGP], a
	ld de, WilyJumpVelocity
	call ObjSetVelocity_0D
	ld de, WilyFall
	jp ObjSetState

WilyJumpVelocity:	;$4B64
	db $E0, $FF, $00, $FD

WilyFall:	;$4B68
	ld a, $E0
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	call ObjFallAndMove_0D
	ld de, Data_0D_52B8
	call AnimateObject_0D
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $64
	ret c
	ld [hl], $64
	ld a, $28
	add a, c
	ld l, a
	ld [hl], $68
	inc l
	ld [hl], $01
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $3C
	ld a, $02
	ld [wStageState], a
	ld de, WilyLanded
	jp ObjSetState

;Dr. Wily has landed: he bows (frames $13/$14 - Will) until the victory
;jingle's timer runs out, then the fade-out.	;[ok]
WilyLanded:	;$4B9F
	ld a, $E0
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	ld de, Data_0D_52BE
	call AnimateObject_0D
	ld a, $28
	add a, c
	ld l, a
	ld a, [hl+]
	ld e, a
	ld d, [hl]
	or d
	jr z, .l4BBE
	dec de
	ld [hl], d
	dec l
	ld [hl], e
	ret
.l4BBE
	ld a, $17
	add a, c
	ld l, a
	ld a, [hl]
	cp $14
	ret nz
	ld a, $27
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl], a
	ld a, $2B
	add a, c
	ld l, a
	ld [hl], $B4
	ld de, WilyFadeOut
	jp ObjSetState

WilyFadeOut:	;$4BD9
	ld a, $E0
	ld [wVictoryTimer], a
	ld a, $01
	ld [wVictoryTimer + 1], a
	ld a, $2B
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4BED
	dec [hl]
	ret
.l4BED
	ld a, $2A
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $27
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	cp $04
	jr c, .l4C02
	ld [hl], $00
	inc l
	inc [hl]
	dec l
.l4C02
	inc l
	ld a, [hl]
	cp $04
	jr nc, .l4C24
	ld e, a
	add a, a
	add a, e
	ld e, a
	ld d, $00
	ld l, c
	push hl
	ld hl, WilyFadePalettes
	add hl, de
	ld a, [hl+]
	ld [wShadowBGP], a
	ld [$DF9F], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	pop hl
	ld c, l
	ret
.l4C24
	ld a, $00
	ld [wVictoryTimer], a
	ld a, $00
	ld [wVictoryTimer + 1], a
	ld a, $03
	ld [wStageState], a
	ret

;Four 3-byte entries, of which only the first byte is read: BGP (also OBP0,
;OBP1) for the fade to white, 4 frames each.	;[ok]
WilyFadePalettes:	;$4C34
	db $EB, $1C, $C4
	db $96, $08, $80
	db $41, $00, $40
	db $00, $00, $00

;Phase 2's damage, once $CC5B bit 1 is set (and not bit 3, the death
;sequence; not after the fade starts, $2A). While $CC5D runs the palette
;flashes; else $CC5C points come off the bar (x 8) and start a 20-frame flash.
;At 0: if Mega Man is dying ($DF94) the bar stays at 1; otherwise $CCF5 (boss
;beaten), controls locked, pause disabled ($DF41), $CC5B bit 2, a death
;explosion at the cannon and AudioStopAll.	;[ok]
WilyMachineCheckDamage:	;$4C40
	ld a, $2A
	add a, c
	ld l, a
	ld a, [hl]
	or a
	ret nz
	ld a, [$CC5B]
	bit 1, a
	ret z
	ld a, [$CC5B]
	bit 3, a
	ret nz
	ld a, [$CC5D]
	or a
	jr z, .l4C6E
	dec a
	ld [$CC5D], a
	ld a, $29
	add a, c
	ld l, a
	inc [hl]
	bit 2, [hl]
	ld a, $E4
	jr z, .l4C6A
	ld a, $18
.l4C6A
	ld [wShadowBGP], a
	ret
.l4C6E
	ld a, $E4
	ld [wShadowBGP], a
	ld a, [$CC5C]
	or a
	ret z
	ld b, a
	xor a
	ld [$CC5C], a
	ld a, b
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, [$C101]
	sub b
	jr nc, .l4C89
	xor a
.l4C89
	ld [$C101], a
	ld a, $14
	ld [$CC5D], a
	ret nz
	ld a, [$DF94]
	or a
	jr z, .l4C9E
	ld a, $01
	ld [$C101], a
	ret
.l4C9E
	ld a, $01
	ld [$CCF5], a
	ld [$D845], a
	ld [wPlayerFacing], a
	ld a, $01
	ld [$DF41], a
	ld a, [$CC5B]
	set 2, a
	ld [$CC5B], a
	ld l, c
	push hl
	ld a, $2E
	add a, c
	ld l, a
	ld c, [hl]
	inc l
	ld h, [hl]
	call WilyMachineCannonExplosion
	xor a
	call JumpCallBank1Routine
	pop hl
	ld c, l
	ret

;Set up the cannon: a slot record that is never run (AllocPartRecord), kept at
;$2E/$2F, with a 2-entry sprite, at (X $78, Y $4B), $09 = 1, this object's tile
;base.	;[ok]
WilyMachineInitCannon:	;$4CC9
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call AllocPartRecord
	ld a, $2E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld l, c
	push hl
	push de
	ld a, $02
	call JumpAllocSprite
	ld b, a
	pop hl
	ld c, l
	ld a, $10
	add a, c
	ld l, a
	ld [hl], b
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], $78
	inc l
	inc l
	ld [hl], $4B
	ld a, $09
	add a, c
	ld l, a
	ld [hl], $01
	ld a, $05
	add a, c
	ld l, a
	ld a, [$CC05]
	ld [hl], a
	pop hl
	ld c, l
	ret

WilyMachineCannonExplosion:	;$4D06
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ld [$D3EB], a
	inc l
	ld a, [hl+]
	ld [$D3EC], a
	ld l, c
	push hl
	ld a, $02
	call JumpCallBank1Routine
	pop hl
	ld c, l
	ret

;The cannon, in phase 2 until the boss is beaten: it moves 4 px a frame
;between Y $4B and $6B ($09: 0 up, 1 down; bit 1 waiting), waits 120 frames at
;each end and fires a type 51 (WilyMachineCannonShotSpawn); drawn with frame 6 every frame.	;[ok]
WilyMachineUpdateCannon:	;$4D1D
	ld a, [$CC5B]
	bit 1, a
	ret z
	ld l, c
	push hl
	ld a, $2E
	add a, c
	ld l, a
	ld c, [hl]
	inc l
	ld h, [hl]
	ld a, [$CCF5]
	or a
	jr nz, .l4D3F
	ld a, [wFreezeFlags]
	or a
	jp nz, .l4D3C
	call WilyMachineMoveCannon
.l4D3C
	call WilyMachineDrawCannon
.l4D3F
	pop hl
	ld c, l
	ret

WilyMachineMoveCannon:	;$4D42
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	ld e, a
	and $02
	jr nz, .l4D76
	ld d, l
	ld a, $0F
	add a, c
	ld l, a
	ld a, e
	or a
	jr nz, .l4D63
	dec [hl]
	dec [hl]
	dec [hl]
	dec [hl]
	ld a, [hl]
	cp $4B
	jr nz, .l4D75
	ld l, d
	ld [hl], $03
	jr .l4D6F
.l4D63
	inc [hl]
	inc [hl]
	inc [hl]
	inc [hl]
	ld a, [hl]
	cp $6B
	jr nz, .l4D75
	ld l, d
	ld [hl], $02
.l4D6F
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $78
.l4D75
	ret
.l4D76
	ld a, $27
	add a, c
	ld l, a
	dec [hl]
	ret nz
	ld a, $09
	add a, c
	ld l, a
	ld a, [hl]
	and $01
	ld [hl], a
	jp WilyMachineCannonShotSpawn

WilyMachineDrawCannon:	;$4D87
	ld l, c
	push hl
	ld a, $01
	ld [$CE57], a
	ld a, $10
	ld [$D3EA], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CE55], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	inc l
	ldh [$FFA2], a
	ld a, [hl]
	ldh [$FFA3], a
	ld a, $10
	add a, c
	ld l, a
	ld a, [hl]
	ld hl, Frame_0D_5356 + 4
	call JumpDrawMetasprite
	pop hl
	ld c, l
	ret

;Sound 2 every 128 frames and at random about 1 frame in 5.	;[ok]
WilyMachineExplosionSound:	;$4DB4
	ld a, [wFrameCounter]
	and $7F
	jr z, .l4DC3
	ld e, $30
	call JumpRNG
	cp e
	jr nc, .l4DC8
.l4DC3
	ld a, $02
	call JumpQueueSound
.l4DC8
	ret
