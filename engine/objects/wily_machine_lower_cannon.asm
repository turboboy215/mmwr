;Mega Man: Dr. Wily's Revenge disassembly - object type 49, WilyMachineLowerCannon
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "WilyMachineLowerCannon (type 49)", ROMX[$4DC9], BANK[$D]

;The lower cannon (no official name - Will).	;[ok]
;Type 49: never placed; spawned by type 48 (WilyMachineLowerCannonSpawn) once the room's tiles
;are in. The Wily Machine's lower cannon (3x3 frames $0A/$0B), phase 1 of the
;fight. At (X $6B, Y $5C), shots destroyed (hit points $FF) until the bar shows;
;then it fills the bar (ObjStartBossBarFill: 19 hit points), unlocks Mega Man
;and after 60 frames bobs between Y $5C and $64 at 0.8 px a frame, pausing 20
;frames at each end; each time it reaches the bottom it fires a type 52
;(WilyMachineCuttingWheelSpawn), alternately one of the four lobs and one of the four low
;throws. The bar shows its hit points. Killed: $CC5B bit 0 (type 48 goes on),
;sound 2, removed. Ice Slasher: ObjClearFreeze.	;[ok]
WilyMachineLowerCannonRoutine:	;$4DC9
	ld a, b
	or a
	jr z, WilyMachineLowerCannonInit
	dec a
	jr z, WilyMachineLowerCannonFrame
	dec a
	jr z, .l4DD6
	dec a
	jr z, .l4DE9
.l4DD6
	ld a, [$CC5B]
	set 0, a
	ld [$CC5B], a
	call UpdateBossEnergy_0D
	ld a, $02
	call JumpQueueSound
	ld b, $00
	ret
.l4DE9
	jp ObjClearFreeze_0D

WilyMachineLowerCannonInit:	;$4DEC
	ld de, WilyMachineLowerCannonStartPosition
	call ObjSetPosition
	ld de, Data_0D_5294
	call AnimateObjectFacing_0D
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FF
	ld de, WilyMachineLowerCannonWaitForBar
	call ObjSetState
	jr WilyMachineLowerCannonSyncPosition

WilyMachineLowerCannonStartPosition:	;$4E06
	db $6B, $5C

WilyMachineLowerCannonVelocity:	;$4E08
	db $00, $00, $CC, $00

WilyMachineLowerCannonFrame:	;$4E0C
	ld a, [wFreezeFlags]
	or a
	jp nz, WilyMachineLowerCannonSyncPosition
	ld de, WilyMachineLowerCannonSyncPosition
	push de
	ld a, $3E
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push de
	ret

WilyMachineLowerCannonSyncPosition:	;$4E20
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $65
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

WilyMachineLowerCannonWaitForBar:	;$4E45
	ld de, Data_0D_5294
	call AnimateObjectFacing_0D
	ld a, [$C100]
	or a
	ret z
	ld de, WilyMachineLowerCannonVelocity
	call ObjSetVelocity_0D
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $3C
	ld b, $13
	ld de, WilyMachineLowerCannonFight
	jp ObjStartBossBarFill

WilyMachineLowerCannonFight:	;$4E64
	xor a
	ld [$D845], a
	ld de, Data_0D_5294
	call AnimateObjectFacing_0D
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4E79
	dec [hl]
	jr .l4EB9
.l4E79
	call ObjMoveByVelocity_0D
	ld a, $1F
	add a, c
	ld l, a
	ld b, [hl]
	ld a, $0F
	add a, c
	ld l, a
	ld a, [hl]
	cp $5C
	jr z, .l4EA5
	cp $64
	jr nz, .l4EB9
	bit 7, b
	jr nz, .l4EB9
	ld a, $28
	add a, c
	ld l, a
	inc [hl]
	ld a, [hl]
	add a, a
	add a, a
	and $04
	ld b, a
	call WilyMachineCuttingWheelSpawn
	ld de, $FF34
	jr .l4EAC
.l4EA5
	bit 7, b
	jr z, .l4EB9
	ld de, $00CC
.l4EAC
	ld a, $1E
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $14
.l4EB9
	jp UpdateBossEnergy_0D

;Spawn a type 49 with this object's tile base and run WilyMachineLowerCannonInit on it.	;[ok]
WilyMachineLowerCannonSpawn:	;$4EBC
	ld l, c
	push hl
	ld a, $31
	ld [$CC07], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_0D
	call WilyMachineLowerCannonInit
	pop hl
	ld c, l
	ret

;Spawn a type 52 at this object, tile base + $61, $CC08 = B | random 0-3 (B =
;0 or 4), and run WilyMachineCuttingWheelInit on it.	;[ok]
WilyMachineCuttingWheelSpawn:	;$4ED4
	ld l, c
	push hl
	call JumpRNG
	and $03
	or b
	ld b, a
	ld a, $34
	ld [$CC07], a
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	ld [$CC0D], a
	inc l
	ld a, [hl]
	ld [$CC0F], a
	ld a, b
	ld [$CC08], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	add a, $61
	ld [$CC05], a
	call SpawnChildObject_0D
	call WilyMachineCuttingWheelInit
	pop hl
	ld c, l
	ret
