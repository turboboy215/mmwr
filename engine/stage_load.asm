;Mega Man: Dr. Wily's Revenge disassembly - stage and section loading
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Stage Loading", ROM0[$2F93]

;$2F93: one four-byte record per loadable stage:
;
;	dw <pointer slot in ROM0>   ; $0305-$03C1, the far-pointer table
;	db <bank>                   ; stashed in wStageBank and paged in
;	db $00                      ; unused in all eight records
;
;LoadStage indexes this **one-based** - it loads HL with $2F8F, four bytes early,
;so index 1 lands on the first record. HideAllSprites' `dec b / jr nz / ret` tail
;occupies $2F8F-$2F92, so the bias is pointing into code, not into padding.
;wSelectedStage is zero-based on the stage-select screen and incremented by bank
;$01 before the load (at $062BA), which is what reconciles the two.	;[ok]
MACRO stage
	dw \1
	db \2
	db 0
ENDM

StageLoadTab::	;$2F93, indexed from StageLoadTab - 4
	stage $033B, $05	;index 1: Cut Man
	stage $033D, $05	;index 2: Ice Man
	stage $0341, $05	;index 3: Elec Man
	stage $033F, $05	;index 4: Fire Man
	stage $03AB, $08	;index 5: Wily 1
	stage $03AD, $08	;index 6: Wily 2
	stage $03AF, $08	;index 7: Wily 3
	stage $03B1, $08	;index 8: never selected. See below.

;Record 8 is never selected - the Wily branch only sets stages 1-3, and clearing
;the third goes to the ending - but it is not empty. Its data, at bank $08 $6F67
;(ROM $22F67-$23828, 2242 bytes), shares 23.4% of its 8-byte sequences with Fire
;Man's stage against 1-3% for every other stage, including a 76-byte run identical
;to Fire Man's. Will reports an unused alternate Fire Man stage in the ROM; this
;is it, by every measure short of rendering it. Its StageMusicTab entry points at
;an emptied song slot that now falls through into Audio1_EndGameAlt. See
;docs/UNUSED.md.	;[ok]
StageLoadTabEnd::

;$2FB3: called every frame by the stage loop ($0A2F). If the room Mega Man is
;in (wRoomID) is named by a record of the stage's checkpoint list, make that
;record's one-based position the restart point; otherwise leave it alone. The
;list is 2-byte records (room id, a byte nothing reads) ended by $FF - see
;docs/LEVELS.md. B is built from $D80D/$D80E (Mega Man's X / 16, his block
;column) and then never used.	;[ok]
UpdateRestartPoint:	;$2FB3
	ld a, [wStageBank]
	bankswitch
	ld a, [$D80E]
	swap a
	and $F0
	ld b, a
	ld a, [$D80D]
	swap a
	and $0F
	or b
	ld b, a
	ld a, [wRoomID]
	ld c, a
	ld e, $01
	ld a, [wCheckpointsPtr]
	ld l, a
	ld a, [wCheckpointsPtr + 1]
	ld h, a
.l2FDB
	ld a, [hl+]
	cp $FF
	jr z, .l2FED
	cp c
	jr nz, .l2FE5
	jr .l2FE9
.l2FE5
	inc hl
	inc e
	jr .l2FDB
.l2FE9
	ld a, e
	ld [wRestartPoint], a
.l2FED
	ld a, $01
	bankswitch
	ret

;Zero $D800-$D84D and fall straight into LoadStage. PlayStage calls this on
;the way into a stage.	;[ok]
ResetAndLoadStage:	;$2FF6
	ld hl, $D800
	ld bc, $004E
	xor a
	call FuncMemset

;$3000: load the selected stage. Pages in bank $05 (to no visible purpose:
;LoadStageTiles switches to $0C at once, and bank $05 holds no shared code),
;loads the stage tiles, looks the stage up in StageLoadTab, pages in that
;stage's own data bank, walks two levels of indirection to the stage header,
;copies it out (wRestartPointsPtr, wCheckpointsPtr) and falls into
;LoadRestartPoint with the record for wRestartPoint.
;
;This and the object handler table are the whole answer to how the banks that no
;literal ever selects get paged in: $05 and $08 arrive here, $03/$09/$0D arrive
;through OBJ_BANK. See docs/BANKS.md.	;[ok]
LoadStage::	;$3000
	ld a,5
	bankswitch
	call LoadStageTiles
	ld hl,StageLoadTab - 4		;one-based index
	ld a,[wSelectedStage]
	ld e,a
	ld a,[wWilyStageSet]
	or a
	jr z,.noOffset
	ld a,4				;records 5-8 are the Wily stages
	add a,e
	ld e,a
.noOffset
	ld a,e
	add a,a
	add a,a				;four bytes per record
	ld e,a
	ld d,$00
	add hl,de
	ld e,[hl]
	inc hl
	ld d,[hl]			;DE = the ROM0 pointer slot
	inc hl
	ld a,[hl]			;A = the stage's data bank
	ld [wStageBank],a
	ld a,[wStageBank]
	bankswitch
	ld a,[de]			;follow the ROM0 slot...
	inc de
	ld l,a
	ld a,[de]
	inc de
	ld h,a
	ld a,[hl+]			;...and the pointer it holds
	ld h,[hl]
	ld l,a
	ld a,[hl+]			;four bytes of stage header
	ld e,a
	ld [wRestartPointsPtr],a
	ld a,[hl+]
	ld d,a
	ld [wRestartPointsPtr + 1],a
	ld a,[hl+]
	ld [wCheckpointsPtr],a
	ld a,[hl+]
	ld [wCheckpointsPtr + 1],a
	ld l,e
	ld h,d
	ld a,[wRestartPoint]
	call GetTablePointer

;$3057: LoadStage falls through to here with HL pointing at one of the stage's
;restart-point records; bank $01 can also enter through the stub at $01AA. With
;the LCD off it reads the 14-byte record (docs/LEVELS.md):
;  db 0			;skipped; 0 in every record of both banks
;  dw blockset		;count byte to wBlockCount, the definitions to wBlocksetPtr
;  dw collision		;64 bytes copied to wBlockCollision
;  dw init		;to wRestartInitPtr: called at the very end through CallHL
;  dw frame hook	;installed as `jp` at wStageHook; StageFrameLoop calls it
;  dw x, db y		;Mega Man's start position: $D80D-$D80E (also $D852/$D853)
;			;and $D824
;  dw room		;to wRoomPtr: the room to start in, for LoadRoom
;then resets the scroll, loads the room, draws it, sets the palettes (BGP $78,
;OBP0 $1C, OBP1 $C4) and calls bank $01 setup at $66DA, $5F68 and $542C.	;[ok]
LoadRestartPoint:	;$3057
	push hl
	di
	call DisableLCD
	ld a, [wShadowLCDC]
	and $7F
	ld [wShadowLCDC], a
	pop hl
	ld a, [hl+]
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [de]
	ld [wBlockCount], a
	inc de
	ld a, e
	ld [wBlocksetPtr], a
	ld a, d
	ld [wBlocksetPtr + 1], a
	ld e, [hl]
	inc hl
	ld a, [hl+]
	push hl
	ld l, e
	ld h, a
	ld de, wBlockCollision
	ld bc, $0040
	call FuncFill
	pop hl
	ld a, [hl+]
	ld [wRestartInitPtr], a
	ld a, [hl+]
	ld [wRestartInitPtr + 1], a
	ld a, [hl+]
	ld [wStageHook + 1], a
	ld a, [hl+]
	ld [wStageHook + 2], a
	ld a, $C3	;jp
	ld [wStageHook], a
	ld a, $01
	ld [wTeleportState], a
	ld a, [hl+]
	ld [$D80D], a
	ld [$D852], a
	ld a, [hl+]
	ld [$D80E], a
	ld [$D853], a
	ld a, [hl+]
	ld [wPlayerY], a
	call StartTeleportIn
	xor a
	ld [$D84E], a
	ld [$D826], a
	ld [$D827], a
	ld [$D828], a
	ld [$D829], a
	ld [wPlayerMotion], a
	xor a
	ld [wShadowSCX], a
	ld [wShadowSCY], a
	ld [$DDFB], a
	ld a, [hl+]
	ld [wRoomPtr], a
	ld a, [hl+]
	ld [wRoomPtr + 1], a
	xor a
	ld [$D891], a
	call LoadRoom
	ld a, [wStageBank]
	bankswitch
	call DrawRoomView
	ld a, $01
	bankswitch
	call HideAllSprites
	call SetPlayerScreenX
	call InitPlayer
	ld a, $78
	ld [wShadowBGP], a
	ld a, $1C
	ldh [rOBP0], a
	ld a, $C4
	ldh [rOBP1], a
	call InitHUD
	call InitPlacedItems
	ld a, [wStageBank]
	bankswitch
	ld a, [wRestartInitPtr]
	ld l, a
	ld a, [wRestartInitPtr + 1]
	ld h, a
	call CallHL
	ld a, $01
	bankswitch
	ret

;$312F: the room-exit check, called every frame from the stage loop ($0A46).
;Tests Mega Man's position ($D80D/$D80E X, $D824 Y) against the two exit boxes
;BuildExitBoxes made. Inside one, it clears the objects, runs a row of bank $01
;resets, loads the room the box names (LoadRoom), and starts the transition
;scroll ($D868-$D876) at +2 or -2 per step - downwards if Y is past $70,
;upwards otherwise. The scroll is only ever vertical: nothing here would carry
;Mega Man sideways through the side-wall boxes BuildExitBoxes can also build,
;and no stage asks for one. See docs/LEVELS.md.	;[ok]
CheckRoomExits:	;$312F
	ld hl, wExitBoxes
	ld a, [$D80E]
	ld d, a
	ld a, [$D80D]
	ld e, a
	ld b, $02
.l313C
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l3156
	inc hl
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr nc, .l3156
	inc hl
	ld a, [wPlayerY]
	cp [hl]
	jr c, .l3156
	inc hl
	cp [hl]
	jr c, .l315D
.l3156
	ld hl, wExitBoxes + 8
	dec b
	jr nz, .l313C
	ret
.l315D
	push hl
	ld a, $01
	bankswitch
	xor a
	ld [wFreezeFlags], a
	call ClearAllObjects
	call ClearEnemyShots
	call FreeAllItems
	call FreeAllExplosions
	call FreeAllShots
	call ResetPlacedItems
	call DelayFrame
	ld a, [wStageBank]
	bankswitch
	pop hl
	inc hl
	ld a, [hl+]
	ld [wRoomPtr], a
	ld a, [hl]
	ld [wRoomPtr + 1], a
	call LoadRoom
	ld a, [wStageBank]
	bankswitch
	ld a, [wPlayerY]
	cp $70
	ld a, $02
	jr nc, .l31A9
	ld a, $FE
.l31A9
	ld [$D869], a
	ld a, $80
	ld [$D86A], a
	xor a
	ld [$D868], a
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	call ClampToScrollLimits
	ld a, e
	sub $58
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	xor a
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	rla
	ld [$D870], a
	ld a, e
	ld [$D871], a
	ld a, d
	ld [$D872], a
	ld a, [wShadowSCX]
	sub $08
	ld e, a
	ld a, [$D869]
	bit 7, a
	ld a, [wShadowSCY]
	jr nz, .l31F9
	add a, $80
	jr .l31FB
.l31F9
	sub $08
.l31FB
	ld d, a
	res 3, d
	ld a, [$D869]
	bit 7, a
	jr z, .l3207
	set 3, d
.l3207
	push de
	call PixelToBGMapAddr
	pop de
	res 0, l
	ld a, l
	ld [$D875], a
	ld a, h
	ld [$D876], a
	call PixelToBlockGridAddr
	ld a, l
	ld [$D873], a
	ld a, $01
	bankswitch
	ret

;Clamp DE between the scroll limits: no lower than the word at $D861, no
;higher than the word at $D863.	;[ok]
ClampToScrollLimits:	;$3226
	ld hl, wScrollMinX
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l3238
	inc hl
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l323B
.l3238
	ld d, [hl]
	dec hl
	ld e, [hl]
.l323B
	ret

;HL = the BG map 0 address of pixel (E, D): $9800 + (D / 8) * 32 + E / 8.	;[ok]
PixelToBGMapAddr:	;$323C
	ld a, e
	srl a
	srl a
	srl a
	ld e, a
	ld h, $00
	ld l, d
	add hl, hl
	add hl, hl
	ld a, l
	and $E0
	add a, e
	ld l, a
	ld de, $9800
	add hl, de
	ret

;HL = $DE00 + (D & $F0) + E / 16: the cell for pixel (E, D) in a 16x16 grid of
;16-pixel blocks kept at $DE00-$DEFF.	;[ok]
PixelToBlockGridAddr:	;$3253
	ld a, e
	swap a
	and $0F
	ld e, a
	ld a, d
	and $F0
	or e
	ld l, a
	ld h, $DE
	ret

;$3261: clear two 16-byte rows of the $DE00 block grid with FillGridRow: the
;row above the one at the top of the screen ($DDFB, SCY & $F0) and the row 8
;below that one - the rows just outside the 8 the screen shows. Called when a
;room transition ends and by DrawRoomView.	;[ok]
ClearGridEdgeRows:	;$3261
	ld a, [$DDFB]
	and $F0
	push af
	sub $10
	ld h, $DE
	ld l, a
	ld b, $10
	push hl
	push bc
	xor a
	call FillGridRow
	pop bc
	pop hl
	pop af
	add a, $80
	ld l, a
	xor a
	call FillGridRow
	ret

;$327F: draw the room around the camera for a fresh screen: fill BG map 1 with
;tile $70, clear block-grid rows, clamp the camera and draw 12 columns of the
;room's 8 rows (wRoomRowPtrs) into BG map 0, one DrawBlock call per block.	;[ok]
DrawRoomView:	;$327F
	ld a, $70
	ld hl, $9C00
	ld bc, $0400
	call FuncMemset
	call ClearGridEdgeRows
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	call ClampToScrollLimits
	ld a, e
	sub $60
	ld e, a
	ld a, d
	sbc a, $00
	ld d, a
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	sra d
	rr e
	ld a, e
	ld [$D871], a
	ld a, d
	ld [$D872], a
	ld hl, wRoomRowPtrs
	ld de, $981E
	ld b, $08
.l32C0
	ld a, [hl+]
	push hl
	ld h, [hl]
	ld l, a
	push de
	ld a, [$D871]
	add a, l
	ld l, a
	ld a, [$D872]
	adc a, h
	ld h, a
	ld c, $0C
.l32D1
	push bc
	call DrawBlock
	pop bc
	ld a, e
	push af
	and $E0
	ld e, a
	pop af
	inc a
	and $1F
	or e
	ld e, a
	dec c
	jr nz, .l32D1
	pop de
	ld a, e
	add a, $40
	ld e, a
	jr nc, .l32EC
	inc d
.l32EC
	pop hl
	inc hl
	dec b
	jr nz, .l32C0
	ret

;$32F2: set up the room at wRoomPtr. Runs the bank $01 resets (ClearObjectRAM
;and InitSpriteSystem among them) and reads the room record (docs/LEVELS.md):
;  db id			;to wRoomID
;  dw routine		;to wRoomRoutinePtr, called at the very end
;  dw layout		;to wRoomLayoutPtr
;  dw x offset		;to wRoomXOffset; after the first room, Mega Man's X
;			;moves by old offset - new offset, so X is room-relative
;  exit, exit		;two exit records, for BuildExitBoxes
;  spawn list		;for InitStageObjects
;then sets the scroll limits from the layout's width, starts the object system
;on the spawn list, points wRoomRowPtrs at the layout's rows and calls the
;room routine through CallHL.	;[ok]
LoadRoom:	;$32F2
	ld a, $01
	bankswitch
	call RoomFreeHurtSpark
	call ClearObjectRAM
	call InitSpriteSystem
	call InitItems
	call EquipWeapon
	call $0D07
	call InitEnemyShots
	call InitExplosions
	ld a, [wStageBank]
	bankswitch
	ld a, [wRoomPtr]
	ld l, a
	ld a, [wRoomPtr + 1]
	ld h, a
	ld a, [hl+]
	ld [wRoomID], a
	ld a, [hl+]
	ld [wRoomRoutinePtr], a
	ld a, [hl+]
	ld [wRoomRoutinePtr + 1], a
	ld a, [hl+]
	ld [wRoomLayoutPtr], a
	ld a, [hl+]
	ld [wRoomLayoutPtr + 1], a
	ld a, [wRoomXOffset]
	ld e, a
	ld a, [wRoomXOffset + 1]
	ld d, a
	ld a, [hl+]
	ld c, a
	ld [wRoomXOffset], a
	ld a, [hl+]
	ld b, a
	ld [wRoomXOffset + 1], a
	push hl
	ld a, [$D891]
	or a
	jr z, .l3365
	ld hl, $D80D
	ld a, e
	add a, [hl]
	ld [hl+], a
	ld a, d
	adc a, [hl]
	ld [hl-], a
	ld a, [hl]
	sub c
	ld [hl+], a
	ld [$D852], a
	ld a, [hl]
	sbc a, b
	ld [hl], a
	ld [$D853], a
.l3365
	ld a, $01
	ld [$D891], a
	pop hl
	call BuildExitBoxes
	push hl
	ld a, [wRoomLayoutPtr]
	ld l, a
	ld a, [wRoomLayoutPtr + 1]
	ld h, a
	ld a, [hl+]
	ld [wRoomWidth], a
	ld a, [hl+]
	ld [wRoomHeight], a
	ld a, $50
	ld [wScrollMinX], a
	ld a, $00
	ld [wScrollMinX + 1], a
	ld a, [wRoomWidth]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld a, l
	sub $50
	ld [wScrollMaxX], a
	ld a, h
	sbc a, $00
	ld [wScrollMaxX + 1], a
	call GetPlayerScreenX
	ld a, c
	ld [$D85D], a
	ld [$D85E], a
	pop hl
	call InitStageObjects
	ld a, [wRoomLayoutPtr]
	ld l, a
	ld a, [wRoomLayoutPtr + 1]
	ld h, a
	ld e, [hl]
	inc hl
	inc hl
	ld d, $00
	ld bc, wRoomRowPtrs
	ld a, [wRoomHeight]
.l33C0
	push af
	ld a, l
	ld [bc], a
	inc bc
	ld a, h
	ld [bc], a
	inc bc
	add hl, de
	pop af
	dec a
	jr nz, .l33C0
	xor a
	ld [$D3ED], a
	ld a, $01
	ld [wFloorType], a
	ld hl, $CC59
	ld [hl], $00
	ld de, $CC5A
	ld bc, $0004
	call FuncFill
	ld a, [wRoomRoutinePtr]
	ld l, a
	ld a, [wRoomRoutinePtr + 1]
	ld h, a
	call CallHL
	ld a, $01
	bankswitch
	ret

;Jump to HL - with `call CallHL` this calls a routine whose address is in HL.	;[ok]
CallHL:	;$33F7
	jp hl

;$33F8: fill wExitBoxes with $80 and build up to two exit boxes from the room's
;exit records at HL. An exit is a single $00 byte when absent, else 5 bytes
;for BuildExitBox. Returns HL past both, at the spawn list.	;[ok]
BuildExitBoxes:	;$33F8
	push hl
	ld hl, wExitBoxes
	ld bc, $0010
	ld a, $80
	push hl
	call FuncMemset
	pop de
	pop hl
	ld a, [hl+]
	or a
	call nz, BuildExitBox
	ld a, [hl+]
	or a
	call nz, BuildExitBox
	ret

;$3412: build one 8-byte exit box at DE from the exit record at HL - 1:
;  db length << 4 | row	;row of the room, in blocks; A on entry
;  db column		;in blocks
;  db flags		;bit 0: box runs down a side wall (length in rows)
;			;  instead of along a floor or ceiling (length in columns)
;			;bit 1: the far edge - bottom (or right) instead of top (or
;			;  left); the box is pulled 12 pixels in from that edge
;  dw room		;copied to the box's last two bytes
;The box is dw left, dw right, db top, db bottom, dw room, in pixels. Every
;exit in the game is a floor or ceiling exit (bit 0 clear) with bit 1 set
;exactly when the row is 7 - the side-wall form is never used.	;[ok]
BuildExitBox:	;$3412
	ldh [hBank1CallIndex], a
	ld a, [hl+]
	ldh [$FF92], a
	ld a, [hl+]
	ldh [$FF93], a
	push hl
	ldh a, [$FF92]
	swap a
	ld l, a
	and $0F
	ld h, a
	ld a, l
	and $F0
	ld l, a
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ld bc, $0010
	ldh a, [$FF93]
	bit 0, a
	jr nz, .l343A
	ldh a, [hBank1CallIndex]
	and $F0
	ld c, a
.l343A
	add hl, bc
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ldh a, [hBank1CallIndex]
	swap a
	and $F0
	ld [de], a
	inc de
	ld l, a
	ld c, $10
	ldh a, [$FF93]
	bit 0, a
	jr z, .l3457
	ldh a, [hBank1CallIndex]
	and $F0
	ld c, a
.l3457
	ld a, l
	add a, c
	ld [de], a
	ld l, e
	ld h, d
	inc de
	ldh a, [$FF93]
	bit 0, a
	jr nz, .l3474
	bit 1, a
	jr z, .l346E
	dec hl
	ld a, [hl]
	add a, $0C
	ld [hl], a
	jr .l348E
.l346E
	ld a, [hl]
	sub $0C
	ld [hl], a
	jr .l348E
.l3474
	dec hl
	dec hl
	dec hl
	ld bc, $000C
	bit 1, a
	jr nz, .l3488
	dec hl
	dec hl
	ld a, c
	add a, [hl]
	ld [hl+], a
	ld a, b
	adc a, [hl]
	ld [hl], a
	jr .l348E
.l3488
	ld a, [hl]
	sub c
	ld [hl+], a
	ld a, [hl]
	sbc a, b
	ld [hl], a
.l348E
	pop hl
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ret

;$3496: draw the block at HL (a layout byte) to the BG map address in DE, and
;record its number in the block grid at $DE00 for the cell DE covers. A block
;is 4 tile numbers - top left, bottom left, top right, bottom right - found at
;wBlocksetPtr + 4 * block. Returns HL + 1.	;[ok]
DrawBlock:	;$3496
	push de
	rr d
	rr e
	ld a,e
	rr d
	rr e
	and $F
	ld d,a
	ld a,e
	and $F0
	or d
	ld e,a
	ld d,$DE
	ld a,[hli]
	ld [de],a
	pop de
	push hl
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	ld a,[wBlocksetPtr]
	ld c,a
	ld a,[wBlocksetPtr + 1]
	ld b,a
	add hl,bc
	ld a,[hli]
	ld [de],a
	push de
	ld a,e
	add $20
	ld e,a
	jr nc,.next
	inc d
.next
	ld c,e
	ld b,d
	ld a,[hli]
	ld [de],a
	pop de
	inc e
	ld a,[hli]
	ld [de],a
	inc c
	ld a,[hli]
	ld [bc],a
	pop hl
	ret
