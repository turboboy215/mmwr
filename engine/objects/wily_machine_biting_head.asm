;Mega Man: Dr. Wily's Revenge disassembly - object type 50, WilyMachineBitingHead
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "WilyMachineBitingHead (type 50)", ROMX[$4F06], BANK[$D]

;The biting head (no official name - Will).	;[ok]
;Type 50: never placed; spawned by type 48 (WilyMachineBitingHeadSpawn) when phase 2 begins. A
;biting head (frames 0-5) that waits at (X $94, Y $33) - WilyMachineBitingHeadHome - for 180
;frames, then flies 2 px a frame (LineStep) to where Mega Man was, waits 60
;frames and flies home. Hit points $FE: shots bounce off. Only moves while
;$CC5B bit 1 is set. Once the boss is beaten (and when killed) it zeroes its hit
;points and keeps its position at $CCF2/$CCF3, returning B = 1.	;[ok]
WilyMachineBitingHeadRoutine:	;$4F06
	ld a, b
	or a
	jr z, WilyMachineBitingHeadInit
	dec a
	jr z, WilyMachineBitingHeadUpdate
	dec a
	jr z, WilyMachineBitingHeadBeaten
	dec a
	jr z, WilyMachineBitingHeadClearFreeze

;Mode 2, and every frame once the boss is beaten ($CCF5): hit points 0, its
;position to $CCF2/$CCF3; B = 1.	;[ok]
WilyMachineBitingHeadBeaten:	;$4F13
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	inc l
	ld [$CCF2], a
	ld a, [hl]
	ld [$CCF3], a
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $00
	ld b, $01
	ret

;Mode 3 (Ice Slasher): end the freeze at once.	;[ok]
WilyMachineBitingHeadClearFreeze:	;$4F29
	jp ObjClearFreeze_0D

WilyMachineBitingHeadInit:	;$4F2C
	ld de, WilyMachineBitingHeadHome
	call ObjSetPosition
	ld a, $11
	add a, c
	ld l, a
	ld [hl], $65
	ld a, $18
	add a, c
	ld l, a
	ld [hl], $FE
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $B4
	ld de, WilyMachineBitingHeadWait
	call ObjSetState
	jr WilyMachineBitingHeadAnimate

WilyMachineBitingHeadHome:	;$4F4C
	db $94, $33

;Mode 1: run the state routine at $3E/$3F (returning to
;WilyMachineBitingHeadAnimate) while $CC5B bit 1 is set.	;[ok]
WilyMachineBitingHeadUpdate:	;$4F4E
	ld a, [$CCF5]
	or a
	jr nz, WilyMachineBitingHeadBeaten
	ld a, [wFreezeFlags]
	or a
	jp nz, WilyMachineBitingHeadEndFrame
	ld a, [$CC5B]
	bit 1, a
	jr z, WilyMachineBitingHeadAnimate
	ld de, WilyMachineBitingHeadAnimate
	push de
	ld a, $3E
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	ld d, [hl]
	push de
	ret

;Animate (Data_0D_52A0), then WilyMachineBitingHeadEndFrame.	;[ok]
WilyMachineBitingHeadAnimate:	;$4F6F
	ld de, Data_0D_52A0
	call AnimateObjectFacing_0D

;Update the stage X; B = 1.	;[ok]
WilyMachineBitingHeadEndFrame:	;$4F75
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
	ld b, $01
	ret

WilyMachineBitingHeadWait:	;$4F88
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l4F92
	dec [hl]
	ret
.l4F92
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	ld d, a
	call WilyMachineBitingHeadStartLine
	ld de, WilyMachineBitingHeadFly
	jp ObjSetState

WilyMachineBitingHeadFly:	;$4FA3
	ld a, $2D
	add a, c
	ld l, a
	ld a, [hl+]
	ld b, a
	ld de, wLineToX
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld l, c
	push hl
	call LineStep_0D
	call LineStep_0D
	pop hl
	ld c, l
	ld a, $0D
	add a, c
	ld l, a
	ld [hl], e
	inc l
	inc l
	ld [hl], d
	ld a, $2D
	add a, c
	ld l, a
	ld a, b
	ld [hl+], a
	ld de, wLineToX
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	call WilyMachineBitingHeadCheckAtTarget
	ret nc
	ld a, $0D
	add a, c
	ld l, a
	ld a, [WilyMachineBitingHeadHome]
	sub [hl]
	jr nc, .l5001
	cpl
	inc a
.l5001
	cp $04
	jr nc, .l5017
	ld de, WilyMachineBitingHeadHome
	call ObjSetPosition
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $B4
	ld de, WilyMachineBitingHeadWait
	jp ObjSetState
.l5017
	ld a, $27
	add a, c
	ld l, a
	ld [hl], $3C
	ld de, WilyMachineBitingHeadWaitAtTarget
	jp ObjSetState

WilyMachineBitingHeadWaitAtTarget:	;$5023
	ld a, $27
	add a, c
	ld l, a
	ld a, [hl]
	or a
	jr z, .l502D
	dec [hl]
	ret
.l502D
	ld a, [WilyMachineBitingHeadHome]
	ld e, a
	ld a, [WilyMachineBitingHeadHome + 1]
	ld d, a
	call WilyMachineBitingHeadStartLine
	ld de, WilyMachineBitingHeadFly
	jp ObjSetState

;Carry if the object is within 4 px of the target at $28/$29 on both axes.	;[ok]
WilyMachineBitingHeadCheckAtTarget:	;$503E
	ld a, $0D
	add a, c
	ld l, a
	ld e, [hl]
	inc l
	inc l
	ld d, [hl]
	ld a, $28
	add a, c
	ld l, a
	ld a, e
	sub [hl]
	jr nc, .l5050
	cpl
	inc a
.l5050
	cp $04
	jr nc, .l5061
	inc l
	ld a, d
	sub [hl]
	jr nc, .l505B
	cpl
	inc a
.l505B
	cp $04
	jr nc, .l5061
	scf
	ret
.l5061
	or a
	ret

;Start a line (LineStepInit) from the object to (E, D), keeping the target at
;$28/$29 and LineStep's state at $2D-$33.	;[ok]
WilyMachineBitingHeadStartLine:	;$5063
	ld l, c
	push hl
	ld a, $28
	add a, c
	ld l, a
	ld [hl], e
	inc l
	ld [hl], d
	ld a, $0D
	add a, c
	ld l, a
	ld a, [hl+]
	inc l
	ld h, [hl]
	ld l, a
	ld c, $01
	call LineStepInit_0D
	pop hl
	ld c, l
	ld a, $2D
	add a, c
	ld l, a
	ld a, $02
	ld [hl+], a
	ld de, wLineToX
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ret

WilyMachineBitingHeadSpawn:	;$5097
	ld l, c
	push hl
	ld a, $32
	ld [$CC07], a
	ld a, $05
	add a, c
	ld l, a
	ld a, [hl]
	ld [$CC05], a
	call SpawnChildObject_0D
	call WilyMachineBitingHeadInit
	pop hl
	ld c, l
	ret
