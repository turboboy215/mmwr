;Mega Man: Dr. Wily's Revenge disassembly - the stage select and boss intro
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Stage Select Menu", ROMX[$6156], BANK[$1]

;The stage select, called by the game flow. Starts on the first undefeated
;robot master, then: move the cursor, blink it, Start on an undefeated one. The
;screen then zooms (window slides) to the boss intro: starfield, the boss's
;sprite, TypeBossName. Leaves wSelectedStage one-based.	;[ok]
StageSelect:	;$6156
	call DisableLCD
	ld a, [wSelectedStage]
	and $03
	ld c, a
	ld b, $04
.l6161
	ld e, c
	ld d, $00
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	ld a, [wBossesDefeated]
	and [hl]
	jr z, .l6177
	ld a, c
	inc a
	and $03
	ld c, a
	dec b
	jr nz, .l6161
.l6177
	ld a, c
	ld [wSelectedStage], a
	call HideAllSpritesAlt
	call LoadStageSelectScreen
	call LoadStageSelectSprites
	call LoadStageSelectBosses
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $84
	ldh [rOBP1], a
	xor a
	ldh [rIF], a
	ld a, $01
	ldh [rIE], a
	call EnableLCD
	ld a, [wShadowLCDC]
	or $64
	ld [wShadowLCDC], a
	ld a, $48
	ldh [rWY], a
	ld a, $07
	ldh [rWX], a
	xor a
	ld [$CCFC], a
	ld [$CCF7], a
	ld [$CCF8], a
	ld [wScreenCounter], a
	ld a, $0A
	ld [wAudioBank], a
	ld a, $26
	call QueueSound
	ei
.l61C2
	call DelayFrame
	call ReadJoypad
	call PlaceStageSelectCursor
	call BlinkStageSelectCursor
	call StageSelectInput
	ldh a, [hJoypadPressed]
	bit 3, a
	jp z, .l61C2
	ld a, [wSelectedStage]
	ld e, a
	ld d, $00
	ld hl, BitMasks
	add hl, de
	ld a, [hl]
	ld b, a
	ld a, [wBossesDefeated]
	and b
	jr nz, .l61C2
	call KeepChosenBossSprites
	call AudioStopAll
	ld a, $24
	call QueueSound
	ld a, $FF
	ld [wAudioLock], a
.l61FA
	call RunAudioUpdate
	call DelayFrame
	ld a, [$CCFC]
	cp $08
	call nc, FillZoomRowBG
	call UpdateBossJump
	ld a, [$CCFC]
	inc a
	inc a
	ld [$CCFC], a
	cp $48
	jr z, .l6227
	ld a, [wShadowSCY]
	inc a
	inc a
	ld [wShadowSCY], a
	ldh a, [rWY]
	inc a
	inc a
	ldh [rWY], a
	jr .l61FA
.l6227
	xor a
	ld [$CCFC], a
.l622B
	call RunAudioUpdate
	call DelayFrame
	call FillZoomRowWindow
	call UpdateBossJump
	ld a, [$CCFC]
	inc a
	inc a
	ld [$CCFC], a
	cp $2E
	jr z, .l6253
	ld a, [wShadowSCY]
	dec a
	dec a
	ld [wShadowSCY], a
	ldh a, [rWY]
	dec a
	dec a
	ldh [rWY], a
	jr .l622B
.l6253
	call InitStarfield
	xor a
	ld [$CCFC], a
	ld [wStageSelectTimer], a
	ld [wStageSelectFrame], a
	ld [wScreenCounter], a
	ld [wStageSelectAnimPhase], a
	ldh [rOBP0], a
.l6268
	call RunAudioUpdate
	call DelayFrame
	call ReadJoypad
	call AnimateIntroBoss
	call ScrollStarfield
	ld a, [$CCFC]
	xor $01
	ld [$CCFC], a
	ld a, [wScreenCounter]
	or a
	jr z, .l6268
	xor a
	ld [$CCFC], a
	ld [wStageSelectTimer], a
	ld [wStageSelectFrame], a
	ld [wScreenCounter], a
	ldh [rOBP0], a
.l6294
	call RunAudioUpdate
	call DelayFrame
	call ReadJoypad
	call TypeBossName
	call ScrollStarfield
	ld a, [$CCFC]
	xor $01
	ld [$CCFC], a
	ld a, [wScreenCounter]
	inc a
	ld [wScreenCounter], a
	cp $78
	jr c, .l6294
	ld a, [wSelectedStage]
	inc a
	ld [wSelectedStage], a
	xor a
	ld [wRestartPoint], a
	ld [wScreenCounter], a
	ld [$C100], a
	xor a
	ld [wAudioLock], a
	ld a, $02
	ld [wAudioBank], a
	ret

SECTION "Stage Select Helpers", ROMX[$64B6], BANK[$1]

;Stage-select zoom: fill a row of the BG map (top half) or the window map
;(bottom half) with tile $01, following the slide ($CCFC).	;[ok]
FillZoomRowBG:	;$64B6
	ld a, [$CCFC]
	sub $08
	sla a
	sla a
	ld l, a
	ld a, $00
	adc a, $98
	ld h, a
	ld a, $01
	jr Fill8Bytes

;The window-map half of the same.	;[ok]
FillZoomRowWindow:	;$64C9
	ld a, [$CCFC]
	add a, $08
	sla a
	sla a
	ld l, a
	ld a, $00
	adc a, $9C
	ld h, a
	ld a, $01

;Write A to eight bytes at HL.	;[ok]
Fill8Bytes:	;$64DA
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ret

;Put the stage-select cursor's four corner sprites round portrait
;wSelectedStage.	;[ok]
PlaceStageSelectCursor:	;$64E3
	ld a, [wSelectedStage]
	and $03
	swap a
	srl a
	ld hl, StageSelectCursorCorners
	add a, l
	ld l, a
	ld a, $00
	adc a, h
	ld h, a
	ld de, wShadowOAM
	ld b, $04
.l64FA
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec b
	ld a, b
	or a
	jr nz, .l64FA
	ret

StageSelectCursorCorners:	;$650B
	db $18, $18, $18, $40, $40, $18, $40, $40
	db $18, $68, $18, $90, $40, $68, $40, $90
	db $68, $18, $68, $40, $90, $18, $90, $40
	db $68, $68, $68, $90, $90, $68, $90, $90

;Cycle OBP0 every 8 frames so the cursor blinks.	;[ok]
BlinkStageSelectCursor:	;$652B
	ld a, [wStageSelectTimer]
	inc a
	and $07
	ld [wStageSelectTimer], a
	or a
	ret nz
	ld a, [wStageSelectFrame]
	or a
	jr z, .l6548
	dec a
	jr z, .l6552
	xor a
	ld [wStageSelectFrame], a
	ld a, $9C
	ldh [rOBP0], a
	ret
.l6548
	ld a, $01
	ld [wStageSelectFrame], a
	ld a, $E4
	ldh [rOBP0], a
	ret
.l6552
	ld a, $02
	ld [wStageSelectFrame], a
	ld a, $78
	ldh [rOBP0], a
	ret

;Stage-select input: left/right and up/down flip the column and row bits of
;wSelectedStage, with sound $0B.	;[ok]
StageSelectInput:	;$655C
	ldh a, [hJoypadPressed]
	and $30
	jr z, .l6581
	ld a, [$CCFC]
	or a
	ret nz
	inc a
	ld [$CCFC], a
	ld a, [wSelectedStage]
	ld b, a
	and $02
	ld c, a
	ld a, b
	and $01
	xor $01
	or c
	ld [wSelectedStage], a
	ld a, $0B
	call QueueSound
	ret
.l6581
	ldh a, [hJoypadPressed]
	and $C0
	jr z, .l65A6
	ld a, [$CCFC]
	or a
	ret nz
	inc a
	ld [$CCFC], a
	ld a, [wSelectedStage]
	ld b, a
	and $01
	ld c, a
	ld a, b
	and $02
	xor $02
	or c
	ld [wSelectedStage], a
	ld a, $0B
	call QueueSound
	ret
.l65A6
	xor a
	ld [$CCFC], a
	ret

;After a stage is chosen: keep only the chosen robot master's sprites. Each
;stage's block of shadow OAM is the one LoadStageSelectBosses drew that boss
;into (Cut Man $34, Ice Man $54, Elec Man $70, Fire Man $10); CopyToShadowOAM
;moves it to the start and clears the rest. Also zeroes wScreenCounter.	;[ok]
KeepChosenBossSprites:	;$65AB
	xor a
	ld [wScreenCounter], a
	ld a, [wSelectedStage]
	or a
	jr z, .l65C3
	dec a
	jr z, .l65CB
	dec a
	jr z, .l65D3
	ld b, $24
	ld de, wShadowOAM + $10
	jp CopyToShadowOAM
.l65C3
	ld b, $20
	ld de, wShadowOAM + $34
	jp CopyToShadowOAM
.l65CB
	ld b, $1C
	ld de, wShadowOAM + $54
	jp CopyToShadowOAM
.l65D3
	ld b, $1C
	ld de, wShadowOAM + $70
	jp CopyToShadowOAM

;Boss intro: copy the three starfield layers into shadow OAM ($C030).	;[ok]
InitStarfield:	;$65DB
	ld hl, wShadowOAM + $30
	ld de, StarfieldFar
	ld b, $20
	call CopyBytesB
	ld de, StarfieldMid
	ld b, $20
	call CopyBytesB
	ld de, StarfieldNear
	ld b, $30
	call CopyBytesB
	ret

;Copy B bytes from DE to HL.	;[ok]
CopyBytesB:	;$65F7
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	ld a, b
	or a
	jr nz, CopyBytesB
	ret

;Starfield sprites, three layers (OAM entries); ScrollStarfield moves them at
;different speeds.	;[ok]
StarfieldFar:	;$6600
	db $20, $40, $06, $00
	db $80, $48, $06, $00
	db $28, $88, $06, $00
	db $88, $80, $06, $00
	db $30, $24, $06, $00
	db $84, $62, $06, $00
	db $26, $C0, $06, $00
	db $78, $10, $06, $00
StarfieldMid:	;$6620
	db $18, $40, $04, $00
	db $82, $48, $04, $00
	db $24, $88, $04, $00
	db $8A, $82, $04, $00
	db $2E, $24, $04, $00
	db $86, $62, $04, $00
	db $1C, $C0, $04, $00
	db $7E, $10, $04, $00
StarfieldNear:	;$6640
	db $16, $40, $02, $00
	db $83, $48, $02, $00
	db $23, $88, $02, $00
	db $8B, $82, $02, $00
	db $25, $24, $02, $00
	db $87, $62, $02, $00
	db $1F, $C0, $02, $00
	db $7D, $10, $02, $00
	db $15, $14, $02, $00
	db $97, $52, $02, $00
	db $2F, $20, $02, $00
	db $8D, $D0, $02, $00

;Move the starfield layers diagonally.	;[ok]
ScrollStarfield:	;$6670
	ld hl, wShadowOAM + $30
	ld b, $08
	ld d, $02
	ld e, $FE
	ld a, $06
	ld [$CCF7], a
	call ScrollStarLayer
	ld b, $08
	ld d, $01
	ld e, $FF
	ld a, $04
	ld [$CCF7], a
	call ScrollStarLayer
	ld a, [$CCFC]
	or a
	ret z
	ld b, $0C
	ld d, $01
	ld e, $FF
	ld a, $02
	ld [$CCF7], a
	call ScrollStarLayer
	ret

;Move B starfield sprites at HL by D down and E across; Y wraps at $A2, and
;stars inside the portrait band (Y $38-$71) get tile $FE instead of $CCF7, which
;hides them.	;[ok]
ScrollStarLayer:	;$66A3
	ld a, [$CCF7]
	ld c, a
	ld a, d
	add a, [hl]
	cp $38
	jr c, .l66B3
	cp $72
	jr nc, .l66B3
	ld c, $FE
.l66B3
	cp $A2
	jr c, .l66B8
	xor a
.l66B8
	ld [hl+], a
	ld a, e
	add a, [hl]
	ld [hl+], a
	ld [hl], c
	inc hl
	inc hl
	dec b
	ld a, b
	or a
	jr nz, ScrollStarLayer
	ret
