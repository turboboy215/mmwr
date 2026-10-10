;Mega Man: Dr. Wily's Revenge disassembly - the first cutscene's stage select
;Part of ROM bank $0B (step 5.4), included from banks/bank0b.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Wily Stage Select", ROMX[$4CA6], BANK[$B]

;Cycle OBP0 every 8 frames so the cursor blinks. Byte-identical to bank $01's
;BlinkStageSelectCursor.	;[ok]
BlinkStageSelectCursor_0B:	;$4CA6
	ld a, [wStageSelectTimer]
	inc a
	and $07
	ld [wStageSelectTimer], a
	or a
	ret nz
	ld a, [wStageSelectFrame]
	or a
	jr z, .l4CC3
	dec a
	jr z, .l4CCD
	xor a
	ld [wStageSelectFrame], a
	ld a, $9C
	ldh [rOBP0], a
	ret
.l4CC3
	ld a, $01
	ld [wStageSelectFrame], a
	ld a, $E4
	ldh [rOBP0], a
	ret
.l4CCD
	ld a, $02
	ld [wStageSelectFrame], a
	ld a, $78
	ldh [rOBP0], a
	ret

;Draw the stage-select cursor round the middle slot: four one-tile sprites at
;its corners, palette OBP0. Falls into DrawWilyCursorCorner for the last.	;[ok]
DrawWilyStageCursor:	;$4CD7
	ld hl, WilyCursorTopLeft
	call DrawWilyCursorCorner
	ld hl, WilyCursorTopRight
	call DrawWilyCursorCorner
	ld hl, WilyCursorBottomLeft
	call DrawWilyCursorCorner
	ld hl, WilyCursorBottomRight

;Allocate a one-entry sprite handle into $CC00 and draw the corner record at
;HL with it.	;[ok]
DrawWilyCursorCorner:	;$4CEC
	ld a, $01
	push hl
	call JumpAllocSprite
	pop hl
	ld [$CC00], a
	jp DrawSpriteRecordIndirectHandle_0B

;The cursor's corners, 8-byte records (DrawSpriteRecordIndirectHandle_0B).	;[ok]
WilyCursorTopLeft:	;$4CF9
	db $00, $00, $40, $40	;attributes, tile base, X, Y
	dw $CC00, WilyCursorMetasprite	;sprite handle pointer, metasprite
WilyCursorTopRight:	;$4D01
	db $00, $00, $68, $40	;attributes, tile base, X, Y
	dw $CC00, WilyCursorMetasprite	;sprite handle pointer, metasprite
WilyCursorBottomLeft:	;$4D09
	db $00, $00, $40, $68	;attributes, tile base, X, Y
	dw $CC00, WilyCursorMetasprite	;sprite handle pointer, metasprite
WilyCursorBottomRight:	;$4D11
	db $00, $00, $68, $68	;attributes, tile base, X, Y
	dw $CC00, WilyCursorMetasprite	;sprite handle pointer, metasprite

;One tile, the cursor's corner.	;[ok]
WilyCursorMetasprite:	;$4D19
	db $F8, $F0, $11	;dx, dy, 1x1
	db $00
	db $80

;Allocate a 9-entry sprite handle into $CC10 and draw Dr. Wily in the middle
;slot.	;[ok]
DrawWilyPortrait:	;$4D1E
	ld a, $09
	call JumpAllocSprite
	ld [$CC10], a
	ld hl, WilyPortraitRecord
	jp DrawSpriteRecordIndirectHandle_0B

;Dr. Wily in the middle slot, tile base 8, palette OBP1.	;[ok]
WilyPortraitRecord:	;$4D2C
	db $10, $08, $4E, $48	;attributes, tile base, X, Y
	dw $CC10, WilyPortraitMetasprite	;sprite handle pointer, metasprite

;Wily's frames, tile base 8, hitbox first as in the saucer's. The middle
;slot's portrait, 3x3.	;[ok]
WilyPortraitFrame:	;$4D34
	db $F4, $0B, $F4, $0B	;hitbox (unused)
WilyPortraitMetasprite:	;$4D38
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

;Wily's face in the saucer, 3x2: two frames that differ in the top-left two
;tiles.	;[ok]
SaucerWilyFrame1:	;$4D45
	db $F4, $0B, $F8, $07	;hitbox (unused)
SaucerWilyMetasprite1:	;$4D49
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $03, $04, $05
	db $80

SaucerWilyFrame2:	;$4D53
	db $F4, $0B, $F8, $07	;hitbox (unused)
SaucerWilyMetasprite2:	;$4D57
	db $F4, $F8, $32	;dx, dy, 3x2
	db $09, $0A, $02, $03, $04, $05
	db $80

;The stage select with all four portraits empty, 20x18, copied to $9800 over
;the normal stage-select map; drawn with the stage select's BG tiles.	;[ok]
WilyStageSelectTilemap:	;$4D61
INCBIN "gfx/tilemaps/wily_stage_select.tilemap"

;67 sprite tiles, to $8000: the stage-select cursor and 59 tiles of Dr. Wily,
;both copies of tiles stored elsewhere, so the source INCBINs those PNGs.	;[ok]
WilyStageSelectTiles:	;$4EC9
	INCBIN "gfx/sprites/stage_select.2bpp"	;8 tiles, the cursor (bank $04's copy)
	INCBIN "gfx/bosses/obj_type48.2bpp", 38 * 16, 59 * 16	;Dr. Wily (bank $07's tiles 38-96)
WilyStageSelectTilesEnd:
