;Mega Man: Dr. Wily's Revenge disassembly - stage select and boss intro
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Stage Select", ROM0[$1B6B]

;Copy the stage-select sprite tiles (cursor and stars, bank $04) to $8000.
;Called once, by bank $01's stage-select setup at $1:6181.	;[ok]
LoadStageSelectSprites: ; $1B6B
	ld a,4
	bankswitch
	ld de,VRAM_TILES0
	ld hl,GfxRef_StageSelect
	call GetGfxBlock
	call FuncFill
	ld a,1
	bankswitch
	ret

;Put the four robot masters on the stage select (bank $07, step 4.4): copy each
;one's tiles to sprite VRAM from its tile list (CopyListedTiles; Fire Man $8080,
;Cut Man $8360, Ice Man $8580, Elec Man $8820), set the four wStageSelectPos
;pairs, and draw frame 0 of each one not yet beaten (wBossesDefeated bits
;3/0/1/2) into its block of shadow OAM with DrawSpriteGrid. Clears the tiles at
;$8FE0-$8FFF last. Called by StageSelect (bank $01).	;[ok]
LoadStageSelectBosses:	;$1B88
	ld a,$07
	bankswitch
	ld hl,GfxRef_StageSelectFireManTileList
	call TripleDeref
	ld d,h
	ld e,l
	ld hl,GfxRef_FireMan
	call GetGfxBlockShort
	ld bc,$8080
	call CopyListedTiles
	ld hl,GfxRef_StageSelectCutManTileList
	call TripleDeref
	ld d,h
	ld e,l
	ld hl,GfxRef_CutMan
	call GetGfxBlockShort
	ld bc,$8360
	call CopyListedTiles
	ld hl,GfxRef_StageSelectIceManTileList
	call TripleDeref
	ld d,h
	ld e,l
	ld hl,GfxRef_IceMan
	call GetGfxBlockShort
	ld bc,$8580
	call CopyListedTiles
	ld hl,GfxRef_StageSelectElecManTileList
	call TripleDeref
	ld d,h
	ld e,l
	ld hl,GfxRef_ElecMan
	call GetGfxBlockShort
	ld bc,$8820
	call CopyListedTiles
	ld hl,GfxRef_StageSelectFireManFrames
	call TripleDeref
	ld a,$74
	ld [wStageSelectPos4X],a
	ld b,a
	ld a,$78
	ld [wStageSelectPos4Y],a
	ld c,a
	ld a,[wBossesDefeated]
	bit 3,a
	jr nZ,.cutMan
.drawFireMan
	ld de,wShadowOAM + $10
	call DrawSpriteGrid
.cutMan
	ld hl,GfxRef_StageSelectCutManFrames
	call TripleDeref
	ld a,$24
	ld [wStageSelectPos1X],a
	ld b,a
	ld a,$28
	ld [wStageSelectPos1Y],a
	ld c,a
	ld a,[wBossesDefeated]
	bit 0,a
	jr nZ,.iceMan
.drawCutMan
	ld de,wShadowOAM + $34
	call DrawSpriteGrid
.iceMan
	ld hl,GfxRef_StageSelectIceManFrames
	call TripleDeref
	ld a,$74
	ld [wStageSelectPos2X],a
	ld b,a
	ld a,$28
	ld [wStageSelectPos2Y],a
	ld c,a
	ld a,[wBossesDefeated]
	bit 1,a
	jr nZ,.elecMan
.drawIceMan
	ld de,wShadowOAM + $54
	call DrawSpriteGrid
.elecMan
	ld hl,GfxRef_StageSelectElecManFrames
	call TripleDeref
	ld a,$24
	ld [wStageSelectPos3X],a
	ld b,a
	ld a,$78
	ld [wStageSelectPos3Y],a
	ld c,a
	ld a,[wBossesDefeated]
	bit 2,a
	jr nZ,.clearLastTiles
.drawElecMan
	ld de,wShadowOAM + $70
	call DrawSpriteGrid
.clearLastTiles
	ld hl,$8fe0
.loop
	xor a
	ldi [hl],a
	or l
	jr nZ,.loop
.done
	ld a,1
	bankswitch
	ret

;Write a sprite block to shadow OAM at DE, with its origin at (B, C). HL is a
;frame: a size byte (columns in the high nibble, rows in the low), then a
;(tile, attributes) pair per sprite of the grid, 8 pixels apart across and 16
;down; then extra sprites as (dx, dy, tile, attributes) until a $80. Scratch in
;wMetaspriteBaseX ... wMetaspriteRows.	;[ok]
DrawSpriteGrid:	;$1C6D
	ld a,b
	ld [wMetaspriteBaseX],a
	ld [wMetaspriteCurX],a
	ld a,c
	ld [wMetaspriteBaseY],a
	ld [wMetaspriteCurY],a
	ldi a,[hl]
	ld c,a
	and $0f
	ld [wMetaspriteRows],a
	ld a,c
	swap a
	and $0f
	ld [wMetaspriteCols],a
	ld a,[wMetaspriteRows]
	ld c,a
.loop1
	ld a,[wMetaspriteCols]
	ld b,a
.loop2
	ld a,[wMetaspriteCurY]
	ld [de],a
	inc de
	ld a,[wMetaspriteCurX]
	ld [de],a
	inc de
	add $08
	ld [wMetaspriteCurX],a
	ldi a,[hl]
	ld [de],a
	inc de
	ldi a,[hl]
	ld [de],a
	inc de
	dec b
	ld a,b
	or a
	jr nZ,.loop2
	ld a,[wMetaspriteCurY]
	add $10
	ld [wMetaspriteCurY],a
	ld a,[wMetaspriteBaseX]
	ld [wMetaspriteCurX],a
	dec c
	ld a,c
	or c
	jp nz,.loop1
.loop3
	ld a,[hl]
	cp $80
	ret Z
	ldi a,[hl]
	ld b,a
	ld a,[wMetaspriteBaseX]
	add b
	ld c,a
	ldi a,[hl]
	ld b,a
	ld a,[wMetaspriteBaseY]
	add b
	ld [de],a
	inc de
	ld a,c
	ld [de],a
	inc de
	ldi a,[hl]
	ld [de],a
	inc de
	ldi a,[hl]
	ld [de],a
	inc de
	jr .loop3

;One frame of the chosen robot master posing on the boss intro (bank $01's
;loop at $6268): count wStageSelectTimer, and every 8 frames step its sprite
;through its pose frames (wStageSelectAnimPhase/wStageSelectFrame) and redraw it
;at its position. At $78 frames it sets wScreenCounter to $2C - which ends the
;loop - and draws the standing frame through UpdateBossJump.	;[ok]
AnimateIntroBoss:	;$1CDE
	ld a,[wStageSelectTimer]
	inc a
	ld [wStageSelectTimer],a
	cp $78
	jr c,.animate
	ld a,$2c
	ld [wScreenCounter],a
	jp UpdateBossJump
.animate
	ld a,[wSelectedStage]
	or a
	jr z,.cutMan
	dec a
	jp z,.iceMan
	dec a
	jp z,.elecMan
	ld a,[wStageSelectTimer]
	and $07
	ret nZ
	ld a,$07
	bankswitch
	ld a,[wStageSelectAnimPhase]
	or a
	jr nz,.fireManPhase1
	inc a
	ld [wStageSelectAnimPhase],a
	ld a,$02
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectFireManFrames
	call GetStageSelectFrame
	call GetFireManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.fireManPhase1
	dec a
	jr nz,.fireManPhase2
	ld a,$02
	ld [wStageSelectAnimPhase],a
	ld a,$03
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectFireManFrames
	call GetStageSelectFrame
	call GetFireManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.fireManPhase2
	ld a,$01
	ld [wStageSelectAnimPhase],a
	ld a,$04
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectFireManFrames
	call GetStageSelectFrame
	call GetFireManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.cutMan
	ld a,[wStageSelectTimer]
	and $07
	ret nZ
	ld a,$07
	bankswitch
	ld a,[wStageSelectAnimPhase]
	or a
	jr nz,.cutManPhase1
	inc a
	ld [wStageSelectAnimPhase],a
	ld a,$02
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectCutManFrames
	call GetStageSelectFrame
	call GetCutManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.cutManPhase1
	xor a
	ld [wStageSelectAnimPhase],a
	ld a,$01
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectCutManFrames
	call GetStageSelectFrame
	call GetCutManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.iceMan
	ld a,[wStageSelectTimer]
	and $07
	ret nZ
	ld a,$07
	bankswitch
	ld a,[wStageSelectAnimPhase]
	or a
	jr nz,.iceManPhase1
	inc a
	ld [wStageSelectAnimPhase],a
	ld a,$01
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectIceManFrames
	call GetStageSelectFrame
	call GetIceManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.iceManPhase1
	ld a,$02
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectIceManFrames
	call GetStageSelectFrame
	call GetIceManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.elecMan
	ld a,[wStageSelectTimer]
	and $07
	ret nZ
	ld a,$07
	bankswitch
	ld a,[wStageSelectAnimPhase]
	or a
	jr nz,.elecManPhase1
	inc a
	ld [wStageSelectAnimPhase],a
	ld a,$02
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectElecManFrames
	call GetStageSelectFrame
	call GetElecManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.elecManPhase1
	ld a,$03
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectElecManFrames
	call GetStageSelectFrame
	call GetElecManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret

;Copy B bytes from DE to the start of shadow OAM and zero the rest of it. Bank
;$01 uses it to keep only the chosen robot master's sprites.	;[ok]
CopyToShadowOAM:	;$1E5A
	ld hl,wShadowOAM
.loop1
	ld a,[de]
	ld [hli],a
	inc de
	dec b
	ld a,b
	or a
	jr nz,.loop1
.loop2
	xor a
	ld [hli],a
	ld a,l
	cp $A0
	jr c,.loop2
	ret

;HL = frame wStageSelectFrame of the frame table that the bank $07 reference at
;HL leads to (DoubleDeref, then the table entry).	;[ok]
GetStageSelectFrame:	;$1E6D
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[wStageSelectFrame]
	add a
	add l
	ld l,a
	ld a,0
	adc h
	ld h,a
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ret

;Copy the tiles a tile list names to BC: the list at DE is a count (kept in
;wScreenCounter as the loop counter) and then that many tile numbers into the
;tile data at HL, 16 bytes each; $FF writes a blank tile instead.	;[ok]
CopyListedTiles:	;$1E81
	ld a,[de]
	ld [wScreenCounter],a
	inc de
.tile
	ld a,[de]
	cp $ff
	jr Z,.blankTile
	push hl
	push de
	ld e,a
	swap a
	and $0f
	ld d,a
	ld a,e
	and $0f
	swap a
	ld e,a
	add hl,de
	ld d,$10
.copyByte
	ld a,[hli]
	ld [bc],a
	inc bc
	dec d
	ld a,d
	or a
	jr nZ,.copyByte
	pop de
	pop hl
	inc de
.next
	ld a,[wScreenCounter]
	dec a
	ret Z
	ld [wScreenCounter],a
	jr .tile
.blankTile
	push de
	ld d,$10
.zeroByte
	xor a
	ld [bc],a
	inc bc
	dec d
	or d
	jr nZ,.zeroByte
	pop de
	inc de
	jr .next

;One frame of the chosen robot master's jump to the middle of the screen while
;the stage select slides away (bank $01, $61FA and $622B). Until
;wScreenCounter reaches $2C it moves a pixel across towards the centre, takes
;its Y step from the top or bottom row's jump arc (NextJumpArcStep) and draws the
;jumping frame; at $2C it draws the standing frame; past it, nothing.	;[ok]
UpdateBossJump:	;$1EBF
	ld a,7
	bankswitch
	ld a,[wSelectedStage]
	or a
	jp Z,.cutMan
	dec a
	jp Z,.iceMan
	dec a
	jp Z,.elecMan
	ld a,[wScreenCounter]
	cp $2c
	jr Z,.fireManLanded
	ret nC
	ld hl,GfxRef_StageSelectBottomRowArc
	call TripleDeref
	call NextJumpArcStep
	ld a,[wStageSelectPos4X]
	dec a
	ld [wStageSelectPos4X],a
	ld a,[wStageSelectPos4Y]
	add e
	ld [wStageSelectPos4Y],a
	ld a,$05
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectFireManFrames
	call GetStageSelectFrame
	call GetFireManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.fireManLanded
	ld a,$01
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectFireManFrames
	call GetStageSelectFrame
	call GetFireManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret

.cutMan
	ld a,[wScreenCounter]
	cp $2c
	jr Z,.cutManLanded
	ret nC
	ld hl,GfxRef_StageSelectTopRowArc
	call TripleDeref
	call NextJumpArcStep
	ld a,[wStageSelectPos1X]
	inc a
	ld [wStageSelectPos1X],a
	ld a,[wStageSelectPos1Y]
	add e
	ld [wStageSelectPos1Y],a
	ld a,$03
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectCutManFrames
	call GetStageSelectFrame
	call GetCutManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.cutManLanded
	ld a,$01
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectCutManFrames
	call GetStageSelectFrame
	call GetCutManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret

.iceMan
	ld a,[wScreenCounter]
	cp $2c
	jr Z,.iceManLanded
	ret nC
	ld hl,GfxRef_StageSelectTopRowArc
	call TripleDeref
	call NextJumpArcStep
	ld a,[wStageSelectPos2X]
	dec a
	ld [wStageSelectPos2X],a
	ld a,[wStageSelectPos2Y]
	add e
	ld [wStageSelectPos2Y],a
	ld a,$03
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectIceManFrames
	call GetStageSelectFrame
	call GetIceManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret
.iceManLanded
	ld a,$00
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectIceManFrames
	call GetStageSelectFrame
	call GetIceManSpritePos
	call DrawSpriteGrid
	ld a,$01
	bankswitch
	ret

.elecMan
	ld a,[wScreenCounter]
	cp $2c
	jr Z,.elecManLanded
	ret nC
	ld hl,GfxRef_StageSelectBottomRowArc
	call TripleDeref
	call NextJumpArcStep
	ld a,[wStageSelectPos3X]
	inc a
	ld [wStageSelectPos3X],a
	ld a,[wStageSelectPos3Y]
	add e
	ld [wStageSelectPos3Y],a
	ld a,$04
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectElecManFrames
	call GetStageSelectFrame
	call GetElecManSpritePos
	call DrawSpriteGrid
	ld a,$01
	ld [wCurrentBank],a
	ld [$2100],a
	ret
.elecManLanded
	ld a,$01
	ld [wStageSelectFrame],a
	ld hl,GfxRef_StageSelectElecManFrames
	call GetStageSelectFrame
	call GetElecManSpritePos
	call DrawSpriteGrid
	ld a,$01
	ld [wCurrentBank],a
	ld [$2100],a
	ret

;B, C = a robot master's stage-select position, DE = shadow OAM: Fire Man,
;Cut Man, Ice Man and Elec Man, ready for DrawSpriteGrid.	;[ok]
GetFireManSpritePos:	;$2022
	ld a,[wStageSelectPos4X]
	ld b,a
	ld a,[wStageSelectPos4Y]
	ld c,a
	ld de,wShadowOAM
	ret

GetCutManSpritePos:	;$202E
	ld a,[wStageSelectPos1X]
	ld b,a
	ld a,[wStageSelectPos1Y]
	ld c,a
	ld de,wShadowOAM
	ret

GetIceManSpritePos:	;$203A
	ld a,[wStageSelectPos2X]
	ld b,a
	ld a,[wStageSelectPos2Y]
	ld c,a
	ld de,wShadowOAM
	ret

GetElecManSpritePos:	;$2046
	ld a,[wStageSelectPos3X]
	ld b,a
	ld a,[wStageSelectPos3Y]
	ld c,a
	ld de,wShadowOAM
	ret

;E = this frame's Y step from the jump arc at HL, entry wScreenCounter: a
;signed 4.4 step accumulated with the fraction in $CCF8 (AddFixedPoint44). A 0
;entry leaves E alone. Counts wScreenCounter on.	;[ok]
NextJumpArcStep:	;$2052
	ld a,[wScreenCounter]
	add l
	ld l,a
	ld a,0
	adc h
	ld h,a
	ld a,[hl]
	or a
	jr z,.next
	ld e,a
	ld a,[$CCF8]
	ld h,a
	ld l,e
	call AddFixedPoint44
	ld a,h
	ld [$CCF8],a
	ld e,l
.next
	ld a,[wScreenCounter]
	inc a
	ld [wScreenCounter],a
	ret

;Add the 4.4 fixed-point step L (bit 7 = negative) to the fraction H: returns L =
;the whole pixels, signed, and H = the new fraction. The fraction is kept as a
;magnitude, so it carries into whichever direction the next step goes.	;[ok]
AddFixedPoint44:	;$2075
	ld a,l
	and $80
	jr Z,.next
	xor a
	sub l
	add h
	ld l,a
	and $0f
	ld h,a
	ld a,l
	swap a
	and $0f
	cpl
	inc a
	ld l,a
	ret
.next
	ld a,l
	add h
	ld l,a
	and $0f
	ld h,a
	ld a,l
	swap a
	and $0f
	ld l,a
	ret

;$2097: draw one more letter of the selected robot master's name on the boss
;intro screen. Called once per frame by bank $01's intro loop at $6294, which
;counts frames in wScreenCounter; the counter doubles as the index of the letter
;to draw, so the name types itself out one letter per frame. Stops at index 9 or
;at the first NUL, whichever comes first. Writes straight into the BG tilemap.
;The names are plain ASCII in the default charmap, unlike the screen text in
;bank $06.	;[ok]
TypeBossName::	;$2097
	ld a,[wScreenCounter]
	cp $09
	ret nC
	ld de,TILEMAP0 + $1C7
	ld b,$00
	ld c,a
	ld a,[wSelectedStage]
	or a
	jr Z,.next1
	dec a
	jr Z,.next2
	dec a
	jr Z,.next3
	ld hl,.fireman
	jr .next4
.next1
	ld hl,.cutman
	jr .next4
.next2
	ld hl,.iceman
	jr .next4
.next3
	ld hl,.elecman
.next4
	ld a,c
	add hl,bc
	add e
	ld e,a
	ld a,[hl]
	or a
	ret Z
	ld [de],a
	ret

.cutman
	db "CUTMAN",0,0,0,0
.iceman
	db "ICEMAN",0,0,0,0
.elecman
	db "ELECMAN",0,0,0
.fireman
	db "FIREMAN",0,0,0
