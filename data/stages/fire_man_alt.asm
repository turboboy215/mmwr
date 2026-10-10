;The unused alternate Fire Man stage - StageLoadTab index 8, bank $08.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank08.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
FireManAltStageData:	;$6F67
	dw FireManAltRestartPoints
	dw FireManAltCheckpoints

;Restart point 0 is the stage start; n is the room checkpoint n names.	;[ok]
FireManAltRestartPoints:
	dw FireManAltRestart0
	dw FireManAltRestart1
	dw FireManAltRestart2

;Entering one of these rooms makes it the restart point (UpdateRestartPoint).	;[ok]
FireManAltCheckpoints:
	checkpoint $05, $04	;-> restart point 1, FireManAltRoom5
	checkpoint $08, $04	;-> restart point 2, FireManAltRoom8
	end_checkpoints

;restart_point blockset, collision, init, frame hook, x, y, room	;[ok]
FireManAltRestart0:
	restart_point FireManAltBlocks, FireManAltCollision, FireManAltStageInit, FireManAltFrameHook, $0047, $33, FireManAltRoom1
FireManAltRestart1:
	restart_point FireManAltBlocks, FireManAltCollision, FireManAltStageInit, FireManAltFrameHook, $0047, $33, FireManAltRoom5
FireManAltRestart2:
	restart_point FireManAltBlocks, FireManAltCollision, FireManAltStageInit, FireManAltFrameHook, $0040, $33, FireManAltRoom8

FireManAltRoom1:
	room $01, FireManAltRoomRoutine, FireManAltRoom1Layout, $0000
	no_exit
	exit_down 18, 1, FireManAltRoom2
	end_spawns

FireManAltRoom2:
	room $02, FireManAltRoomRoutine, FireManAltRoom2Layout, $00A0
	exit_up 8, 1, FireManAltRoom1
	exit_down 1, 1, FireManAltRoom3
	end_spawns

FireManAltRoom3:
	room $03, FireManAltRoomRoutine, FireManAltRoom3Layout, $00A0
	exit_up 1, 1, FireManAltRoom2
	exit_down 38, 1, FireManAltRoom4
	spawn 8, 4, $31, $00
	end_spawns

FireManAltRoom4:
	room $04, FireManAltRoomRoutine, FireManAltRoom4Layout, $0280
	exit_up 8, 1, FireManAltRoom3
	exit_down 1, 1, FireManAltRoom5
	end_spawns

FireManAltRoom5:
	room $05, FireManAltRoomRoutine, FireManAltRoom5Layout, $0280
	exit_up 1, 1, FireManAltRoom4
	exit_down 78, 1, FireManAltRoom6
	end_spawns

FireManAltRoom6:
	room $06, FireManAltRoomRoutine, FireManAltRoom6Layout, $06E0
	exit_up 8, 1, FireManAltRoom5
	exit_down 1, 1, FireManAltRoom7
	spawn 8, 1, $24, $00
	end_spawns

FireManAltRoom7:
	room $07, FireManAltRoomRoutine, FireManAltRoom7Layout, $06E0
	exit_up 1, 1, FireManAltRoom6
	exit_down 28, 1, FireManAltRoom8
	end_spawns

FireManAltRoom8:
	room $08, FireManAltRoomRoutine, FireManAltRoom8Layout, $0820
	exit_up 8, 1, FireManAltRoom7
	exit_down 1, 1, FireManAltRoom9
	end_spawns

FireManAltRoom9:
	room $09, FireManAltRoomRoutine, FireManAltRoom9Layout, $0820
	exit_up 1, 1, FireManAltRoom8
	no_exit
	spawn 36, 8, $00, $00
	spawn 37, 9, $00, $00	;Fire Storm (Will)
	end_spawns

;$704A: restart-point init and room routine - neither does anything here.	;[ok]
FireManAltStageInit:
	ret
FireManAltRoomRoutine:
	ret

;$704C: frame hook. The same palette cycle as Fire Man's (counter $DCD0, 4-frame
;steps, skipped while $DFB1 is set) but with colour 3 dark grey instead of light
;grey - $8F, $8B, $87, $8B against his $4F, $4B, $47, $4B - and the spike test.
;It has none of the behind-BG zone code that Fire Man's final hook carries (with
;an empty table) - that code matches Elec Man's byte for byte.	;[ok]
FireManAltFrameHook:
	ld a, [wFreezeFlags]
	or a
	ret nz
	ld hl, $DCD0
	inc [hl]
	ld a, [hl]
	and $08
	jr z, .phaseB
	ld a, [hl]
	and $04
	jr z, .phaseA2
	ld a, $8B
	jr .setBGP
.phaseA2
	ld a, $87
	jr .setBGP
.phaseB
	ld a, [hl]
	and $04
	jr z, .phaseB2
	ld a, $8B
	jr .setBGP
.phaseB2
	ld a, $8F
.setBGP
	ld [wShadowBGP], a
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
.notSpikes
	ret

FireManAltRoom1Layout:	;20 x 8
	layout 20
	lrow "1B 00 00 00 00 00 00 00 1B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B"
	lrow "1B 00 00 00 00 00 00 00 1B 0E 10 11 0D 11 10 11 10 10 11 1B"
	lrow "1B 00 00 00 00 00 00 00 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 17 16 17 16 17 16 17 16 17 16 17 16 17 16 16 18 1B 02 1B"
	lrow "1B 1B 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 1B 01 1B"
	lrow "1B 1B 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 01 1B"
	end_layout

FireManAltRoom2Layout:	;10 x 8
	layout 10
	lrow "0E 11 10 11 10 11 10 11 01 0F"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 01 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 15 21 21 15 21 21 15 1B"
	lrow "1B 02 1B 08 08 08 08 08 08 1B"
	lrow "16 01 16 17 16 17 16 17 16 17"
	end_layout

FireManAltRoom3Layout:	;40 x 8
	layout 40
	lrow "0E 01 11 11 10 11 10 11 10 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 01 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 21 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 1B"
	lrow "1B 00 00 00 1A 1A 00 1A 00 1A 1A 00 00 21 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 21 20 20 0A 18 16 19 20 20 15 20 20 15 20 1C 20 20 15 20 15 20 1C 20 20 18 19 02 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 21 20 20 20 1B 08 08 08 08 08 08 08 08 08 08 1B 08 08 08 08 08 08 1B 08 08 1B 1B 01 1B"
	lrow "15 16 17 16 17 16 17 16 17 16 17 16 17 16 17 1B 22 22 22 22 22 22 22 22 22 22 1B 22 22 22 22 22 22 1B 22 22 1B 1B 01 1B"
	end_layout

FireManAltRoom4Layout:	;10 x 8
	layout 10
	lrow "1B 0E 10 11 0D 11 10 0F 01 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 01 1B"
	lrow "1B 00 00 00 00 00 00 00 01 1B"
	lrow "1B 21 21 21 21 21 21 21 21 1B"
	lrow "1B 20 20 20 20 20 20 20 20 1B"
	lrow "1B 02 15 15 20 20 15 20 18 1B"
	lrow "1B 01 1B 1B 08 08 08 08 08 1B"
	lrow "1B 01 1B 1B 22 22 22 22 22 1B"
	end_layout

FireManAltRoom5Layout:	;80 x 8
	layout 80
	lrow "1B 01 1B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0E 0F 1B"
	lrow "1B 01 0E 10 11 10 11 0D 10 11 10 11 10 11 0D 0D 10 11 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B 0B 0B 0B 0B 0B 0B 0E 11 10 11 10 11 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 1F 1B"
	lrow "1B 00 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 16 17 16 17 16 19 00 0E 10 11 10 11 0D 0F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0A 0B 0B 0B 0B 0B 1B 00 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0E 10 11 0D 10 11 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 16 17 16 19 21 21 15 21 15 21 21 18 19 09 20 20 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 16 17 16 17 16 17 16 17 16 17 16 19 1B 00 00 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 19 1B 20 20 20 20 20 20 20 20 20 20 20 20 20 1B 20 20 1B"
	lrow "18 16 19 12 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 13 14 1B 08 08 08 08 08 08 08 08 08 08 08 1B 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 16 17 16 19 00 00 00 1B 1B 1B 08 08 08 08 08 08 08 08 08 08 08 08 08 1B 15 02 1B"
	lrow "22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 1B 18 16 17 16 17 16 17 16 17 16 17 16 17 16 17 16 19 1B 08 08 08 1B 18 16 19 1B 1B 1B 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 01 1B"
	end_layout

FireManAltRoom6Layout:	;10 x 8
	layout 10
	lrow "0E 10 11 0F 1D 1E 0E 0F 01 1B"
	lrow "1B 1F 1F 1F 20 20 1F 1F 01 1B"
	lrow "1B 00 00 00 20 20 00 00 01 1B"
	lrow "1B 1A 21 21 20 20 00 00 00 1B"
	lrow "09 20 20 20 20 20 00 00 00 1B"
	lrow "1B 20 20 20 20 20 15 00 00 1B"
	lrow "1B 02 15 15 20 20 1B 18 19 1B"
	lrow "1B 01 1B 1B 08 08 08 08 08 1B"
	end_layout

;Columns 19-20, rows 2-5: a 2x4 door of block 3, the striped shutter block
;(passable), under the 2x2 emblem of blocks 4-7 at columns 18-19. In the final
;stages the shutter blocks are never in a layout; here it is drawn into the map.	;[ok]
FireManAltRoom7Layout:	;30 x 8
	layout 30
	lrow "1B 01 1B 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 04 05 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B"
	lrow "1B 01 0E 10 0F 1D 1E 0E 11 10 11 10 11 10 11 10 0D 0F 06 07 0E 10 11 10 11 10 11 10 11 0F"
	lrow "1B 1F 1F 1F 1F 20 20 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 03 03 1F 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 20 20 00 00 00 00 00 00 00 00 00 00 00 00 03 03 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 20 20 00 00 00 00 00 00 00 00 00 00 00 00 03 03 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 20 20 00 00 00 00 00 00 00 00 00 00 00 00 03 03 00 00 00 00 00 00 00 00 1B"
	lrow "1B 18 16 17 1B 20 20 18 16 17 16 17 16 17 16 17 16 17 16 19 18 16 17 16 17 16 17 19 02 19"
	lrow "1B 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 1B 1B 08 08 08 08 08 08 1B 01 0B"
	end_layout

FireManAltRoom8Layout:	;10 x 8
	layout 10
	lrow "1B 0E 10 11 10 11 11 0F 01 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 01 1B"
	lrow "1B 00 00 00 00 00 00 00 01 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 18 16 17 16 17 16 17 16"
	end_layout

;The boss room. Column 0, rows 2-5: a 1x4 door of block $23 - the same striped
;graphic, solid - in the room's left wall. Nothing in the final game's layouts
;puts a door in a side wall, and no exit record could lead through one (no exit
;anywhere uses BuildExitBox's side-wall form). See docs/UNUSED.md.	;[ok]
FireManAltRoom9Layout:	;10 x 8
	layout 10
	lrow "0E 10 11 10 11 10 11 10 11 0F"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "23 00 00 00 00 00 00 00 00 1B"
	lrow "23 00 00 00 00 00 00 00 00 1B"
	lrow "23 00 00 00 00 00 00 00 00 1B"
	lrow "23 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "16 17 16 17 16 17 16 17 16 17"
	end_layout

;36 blocks: block top left, top right, bottom left, bottom right (tile numbers).	;[ok]
FireManAltBlocks:
	blockset FireManAlt
	block $38, $39, $3A, $3B	;$00
	block $47, $48, $47, $48	;$01
	block $47, $48, $47, $48	;$02
	block $78, $79, $78, $79	;$03
	block $40, $7C, $40, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $40, $62, $41, $42	;$06
	block $63, $64, $42, $42	;$07
	block $4D, $4E, $45, $46	;$08
	block $00, $01, $02, $03	;$09
	block $04, $05, $06, $07	;$0A
	block $08, $09, $0A, $0B	;$0B
	block $0C, $0D, $0E, $0F	;$0C
	block $10, $11, $12, $13	;$0D
	block $0C, $11, $0E, $13	;$0E
	block $10, $0D, $12, $0F	;$0F
	block $10, $11, $14, $15	;$10
	block $10, $11, $16, $17	;$11
	block $18, $19, $1C, $1D	;$12
	block $1A, $19, $1E, $1D	;$13
	block $1A, $1B, $1E, $1F	;$14
	block $20, $21, $24, $25	;$15
	block $22, $23, $26, $27	;$16
	block $28, $29, $24, $25	;$17
	block $20, $29, $24, $25	;$18
	block $28, $21, $24, $25	;$19
	block $2A, $2B, $3E, $3F	;$1A
	block $2C, $2D, $2E, $2F	;$1B
	block $30, $31, $32, $33	;$1C
	block $34, $35, $34, $35	;$1D
	block $36, $37, $36, $37	;$1E
	block $3C, $3D, $3A, $3B	;$1F
	block $70, $70, $70, $70	;$20
	block $49, $4A, $4B, $4C	;$21
	block $43, $44, $45, $46	;$22
	block $78, $79, $78, $79	;$23

;One collision byte per block. LoadRestartPoint copies 64 bytes whatever the
;count, so the copy runs on into whatever follows.	;[ok]
FireManAltCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $03, $03, $03, $03, $00
	db $00, $00, $00, $03
FireManAltCollisionEnd:
