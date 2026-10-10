;Ice Man - StageLoadTab index 2, bank $05.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank05.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
IceManStageData:	;$492F [dc]
	dw IceManRestartPoints
	dw IceManCheckpoints

;Restart point 0 is the stage start; n is the room checkpoint n names.	;[ok]
IceManRestartPoints:
	dw IceManRestart0
	dw IceManRestart1
	dw IceManRestart2

;Entering one of these rooms makes it the restart point (UpdateRestartPoint).	;[ok]
IceManCheckpoints:
	checkpoint $03, $04	;-> restart point 1, IceManRoom3
	checkpoint $08, $04	;-> restart point 2, IceManRoom8 / IceManRoom9
	end_checkpoints

;restart_point blockset, collision, init, frame hook, x, y, room	;[ok]
IceManRestart0:
	restart_point IceManBlocks, IceManCollision, IceManStageInit, IceManFrameHook, $0047, $33, IceManRoom1
IceManRestart1:
	restart_point IceManBlocks, IceManCollision, IceManStageInit, IceManFrameHook, $0047, $33, IceManRoom3
IceManRestart2:
	restart_point IceManBlocks, IceManCollision, IceManStageInit, IceManFrameHook, $0087, $43, IceManRoom8

IceManRoom1:
	room $01, IceManRoomRoutine, IceManRoom1Layout, $0000
	no_exit
	exit_down 48, 1, IceManRoom2
	spawn 7, 10, $01, $00
	spawn 7, 14, $00, $00
	spawn 7, 18, $02, $00
	spawn 7, 22, $00, $00
	spawn 7, 26, $00, $00
	spawn 7, 30, $01, $00
	spawn 7, 34, $00, $00
	spawn 7, 38, $02, $00
	spawn 7, 42, $00, $00
	spawn 7, 46, $00, $00
	end_spawns

IceManRoom2:
	room $02, IceManRoomRoutine, IceManRoom2Layout, $0280
	exit_up 8, 1, IceManRoom1
	exit_down 1, 1, IceManRoom3
	spawn 21, 2, $45, $00
	spawn 21, 7, $40, $00
	spawn 21, 7, $60, $00
	spawn 8, 6, $22, $00
	end_spawns

IceManRoom3:
	room $03, IceManRoomRoutine, IceManRoom3Layout, $0280
	exit_up 1, 1, IceManRoom2
	exit_up 48, 1, IceManRoom4
	spawn 16, 7, $60, $00
	spawn 7, 10, $02, $00
	spawn 16, 13, $40, $00
	spawn 7, 14, $00, $00
	spawn 16, 15, $40, $00
	spawn 7, 18, $00, $00
	spawn 16, 19, $30, $00
	spawn 8, 19, $44, $00
	spawn 16, 19, $50, $00
	spawn 24, 32, $40, $00
	spawn 21, 36, $11, $00
	spawn 21, 40, $11, $00
	spawn 21, 44, $65, $00
	spawn 24, 46, $40, $00
	end_spawns

IceManRoom4:
	room $04, IceManRoomRoutine, IceManRoom4Layout, $0500
	exit_down 8, 1, IceManRoom3
	exit_up 1, 1, IceManRoom5
	spawn 23, 7, $10, $0A	;icicle
	spawn 23, 6, $10, $12	;icicle
	spawn 23, 3, $10, $23	;icicle
	end_spawns

IceManRoom5:
	room $05, IceManRoomRoutine, IceManRoom5Layout, $0500
	exit_down 1, 1, IceManRoom4
	exit_up 8, 1, IceManRoom6
	spawn 23, 4, $10, $1E	;icicle
	spawn 23, 4, $10, $3C	;icicle
	spawn 23, 3, $10, $2D	;icicle
	spawn 23, 1, $10, $37	;icicle
	end_spawns

IceManRoom6:
	room $06, IceManRoomRoutine, IceManRoom6Layout, $0500
	exit_down 8, 1, IceManRoom5
	exit_up 0, 10, IceManRoom7
	spawn 6, 2, $30, $00
	end_spawns

IceManRoom7:
	room $07, IceManRoomRoutine, IceManRoom7Layout, $0500
	exit_down 0, 10, IceManRoom6
	exit_down 48, 1, IceManRoom8
	spawn 8, 8, $54, $00
	spawn 7, 17, $00, $00
	spawn 4, 18, $50, $00
	spawn 24, 22, $40, $00
	spawn 24, 26, $30, $00
	spawn 24, 30, $50, $00
	spawn 24, 37, $50, $00
	spawn 24, 46, $50, $00
	end_spawns

IceManRoom8:
	room $08, IceManRoomRoutine, IceManRoom8Layout, $0780
	exit_up 8, 1, IceManRoom7
	exit_down 1, 1, IceManRoom9
	spawn 55, 5, $30, $00	;boss door (Will)
	end_spawns

IceManRoom9:
	room $08, IceManRoomRoutine, IceManRoom9Layout, $0780
	no_exit
	no_exit
	spawn 32, 5, $00, $00
	spawn 33, 6, $00, $00	;Ice Slasher (Will)
	spawn 33, 7, $00, $00	;Ice Slasher (Will)
	spawn 33, 8, $00, $00	;Ice Slasher (Will)
	end_spawns

;$4AC2: restart-point init and room routine - neither does anything here.	;[ok]
IceManStageInit:
	ret
IceManRoomRoutine:
	ret

;$4AC4: frame hook. Holds the background palette at $E4. Block 8 - the spikes
;in every stage's blockset - sets $D838 to $14 ($D838 accumulates contact
;damage, see HurtPlayerByObject). Otherwise $D908 becomes 2 on blocks $1D, $22 and
;$23 (the snow-capped blocks, IceManBlocks) and 1 elsewhere; bank $01's
;movement code reads $D908, so these are presumably the slippery ones.	;[?]
IceManFrameHook:
	ld a, $E4
	ld [wShadowBGP], a
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
	ret
.notSpikes
	ld e, $01
	cp $1D
	jr z, .slippery
	cp $22
	jr z, .slippery
	cp $23
	jr nz, .store
.slippery
	inc e
.store
	ld a, e
	ld [wFloorType], a
	ret

IceManRoom1Layout:	;50 x 8
	layout 50
	lrow "0E 0F 11 12 12 13 10 25 25 14 15 15 16 0E 11 12 13 0F 10 25 25 25 0E 11 12 13 10 25 0E 10 14 15 15 15 16 25 0E 11 12 12 13 0F 10 25 14 15 15 16 25 1F"
	lrow "25 25 25 25 25 25 25 0E 10 25 25 25 25 25 25 25 25 25 0E 0F 10 25 25 25 25 0E 0F 0F 10 25 25 25 0E 0F 0F 10 25 25 25 25 25 25 14 15 16 25 0E 0F 0F 1F"
	lrow "17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 1F"
	lrow "26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 22 23 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 22 23 02 1F"
	lrow "26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 22 23 26 26 20 21 26 26 26 26 22 23 26 26 26 26 26 26 26 26 26 26 22 23 20 21 01 1F"
	lrow "26 26 26 26 26 26 26 26 26 26 26 26 22 23 22 23 26 26 26 26 22 23 20 21 26 26 20 21 22 23 22 23 20 21 22 23 26 26 26 26 26 26 22 23 20 21 20 21 01 1F"
	lrow "26 26 26 26 26 26 26 26 22 23 22 23 20 21 20 21 26 26 22 23 20 21 20 21 22 23 20 21 20 21 20 21 20 21 20 21 22 23 26 26 22 23 20 21 20 21 20 21 01 1F"
	lrow "22 23 22 23 22 23 22 23 20 21 20 21 20 21 20 21 22 23 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 22 23 20 21 20 21 20 21 20 21 01 1F"
	end_layout

IceManRoom2Layout:	;10 x 8
	layout 10
	lrow "1F 20 21 20 21 20 21 1F 01 1F"
	lrow "1E 0A 0A 0A 0A 0A 0A 0A 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 0B 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 02 1D 22 23 00 00 00 00 1E"
	lrow "1F 01 1F 20 21 00 00 00 00 1F"
	lrow "1E 01 1E 20 21 22 23 22 23 1E"
	end_layout

IceManRoom3Layout:	;50 x 8
	layout 50
	lrow "1F 01 1F 20 21 20 21 20 21 20 21 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 01 1F"
	lrow "1E 01 0A 0A 0A 0A 0A 0A 0A 0A 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 21 20 21 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 0A 01 1E"
	lrow "1F 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0A 0A 0A 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 1F"
	lrow "1E 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1D 00 1D 00 00 00 24 00 22 23 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1D 22 23 00 00 00 00 00 00 1F 00 1F 00 00 24 0A 00 20 21 00 00 00 00 00 00 00 00 00 00 22 23 22 23 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E 20 21 00 00 00 00 00 00 1E 00 1E 00 00 0A 00 00 20 21 22 23 00 00 22 23 00 00 00 00 20 21 20 21 00 00 00 00 0B 00 00 1E"
	lrow "1F 22 23 22 23 00 00 00 00 1F 20 21 00 00 00 00 00 00 0A 00 0A 00 00 00 00 00 20 21 20 21 00 00 20 21 00 00 22 23 20 21 20 21 00 00 00 00 00 00 00 1F"
	lrow "1E 20 21 20 21 08 08 08 08 1E 20 21 08 08 08 08 08 08 08 08 08 08 08 08 08 08 20 21 20 21 22 23 20 21 08 08 20 21 20 21 20 21 22 23 22 23 22 23 22 1E"
	end_layout

IceManRoom4Layout:	;10 x 8
	layout 10
	lrow "1F 01 20 21 20 21 20 21 20 1F"
	lrow "1E 01 0A 0A 0A 0A 0A 0A 0A 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 0B 0B 00 1E"
	lrow "1F 00 00 1D 00 00 00 00 00 1F"
	lrow "1E 08 08 1E 08 08 22 23 02 1E"
	end_layout

IceManRoom5Layout:	;10 x 8
	layout 10
	lrow "1F 20 21 20 21 20 21 1F 01 1F"
	lrow "1E 0A 0A 0A 0A 0A 0A 0A 01 1E"
	lrow "1F 00 00 00 00 00 00 00 01 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 0B 00 0B 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 0B 1F"
	lrow "1E 02 22 23 1D 08 08 08 08 1E"
	end_layout

IceManRoom6Layout:	;10 x 8
	layout 10
	lrow "26 01 26 26 26 26 26 26 26 1F"
	lrow "26 01 26 26 26 26 26 26 26 1E"
	lrow "26 26 26 26 26 26 26 26 26 1F"
	lrow "26 26 26 26 26 26 26 26 26 1E"
	lrow "22 23 26 26 26 26 26 26 26 1F"
	lrow "20 21 26 26 26 26 26 26 26 1E"
	lrow "20 21 1D 22 23 22 23 1D 02 1F"
	lrow "20 21 1E 20 21 20 21 1E 01 1E"
	end_layout

IceManRoom7Layout:	;50 x 8
	layout 50
	lrow "11 12 13 0F 10 25 0E 11 12 13 10 0E 11 13 0F 10 14 15 15 16 25 25 14 15 15 16 0E 11 12 12 13 0F 0F 10 0E 11 12 13 10 25 25 14 15 15 15 15 15 16 25 0E"
	lrow "25 25 25 0E 0F 0F 10 25 25 25 25 25 25 14 15 16 0E 10 25 0E 0F 0F 0F 10 25 25 25 25 25 25 0E 10 25 0E 0F 10 25 25 0E 0F 11 12 12 13 0F 10 25 25 14 15"
	lrow "25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 1D 22 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 22 23 25 25 25 25 22 23 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25 25"
	lrow "17 18 19 1A 1B 1C 17 18 19 1E 20 21 22 23 1C 17 18 19 1A 1B 1C 17 22 23 1A 1B 20 21 18 19 1A 1B 20 21 18 19 1A 1B 1C 17 18 19 1A 1B 1C 17 18 19 1A 1B"
	lrow "26 02 1D 26 26 22 23 22 23 1F 20 21 20 21 22 23 0C 0C 22 23 0C 0C 20 21 0C 0C 20 21 22 23 22 23 20 21 22 23 22 23 22 23 22 23 22 23 22 23 1D 1D 00 1D"
	lrow "26 01 26 26 26 26 26 26 26 1E 20 21 20 21 20 21 27 27 20 21 27 27 20 21 27 27 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 20 21 1F 1F 00 1F"
	end_layout

IceManRoom8Layout:	;10 x 8
	layout 10
	lrow "1E 21 20 21 20 21 1E 1E 00 1E"
	lrow "1F 21 20 21 20 04 05 1F 00 1F"
	lrow "1E 21 20 21 20 06 07 1E 00 1E"
	lrow "1F 0A 0A 0A 0A 0A 0A 0A 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 1D 22 23 22 23 22 23 1F"
	end_layout

IceManRoom9Layout:	;10 x 8
	layout 10
	lrow "1E 00 1E 20 21 20 21 20 21 1E"
	lrow "1F 00 0A 0A 0A 0A 0A 0A 0A 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "1F 00 00 00 00 00 00 00 00 1F"
	lrow "1E 00 00 00 00 00 00 00 00 1E"
	lrow "22 23 22 23 22 23 22 23 22 23"
	end_layout

;41 blocks: block top left, top right, bottom left, bottom right (tile numbers).	;[ok]
IceManBlocks:
	blockset IceMan
	block $18, $19, $1A, $1B	;$00
	block $20, $21, $20, $21	;$01
	block $20, $21, $20, $21	;$02
	block $78, $79, $78, $79	;$03
	block $00, $7C, $04, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $00, $62, $04, $05	;$06
	block $63, $64, $06, $07	;$07
	block $14, $15, $16, $17	;$08
	block $10, $11, $12, $13	;$09
	block $1C, $1D, $1A, $1B	;$0A
	block $2E, $2F, $1E, $1F	;$0B
	block $22, $22, $23, $23	;$0C
	block $24, $25, $26, $27	;$0D
	block $28, $29, $70, $70	;$0E
	block $2A, $2B, $70, $70	;$0F
	block $2C, $2D, $70, $70	;$10
	block $2A, $2B, $28, $29	;$11
	block $2A, $2B, $2A, $2B	;$12
	block $2A, $2B, $2C, $2D	;$13
	block $70, $70, $28, $29	;$14
	block $70, $70, $2A, $2B	;$15
	block $70, $70, $2C, $2D	;$16
	block $70, $30, $34, $35	;$17
	block $31, $32, $36, $37	;$18
	block $33, $70, $38, $39	;$19
	block $70, $70, $3A, $3B	;$1A
	block $70, $70, $3C, $3D	;$1B
	block $40, $70, $3E, $3F	;$1C
	block $41, $42, $43, $44	;$1D
	block $45, $46, $47, $48	;$1E
	block $49, $4A, $49, $4A	;$1F
	block $00, $01, $04, $05	;$20
	block $02, $03, $06, $07	;$21
	block $08, $09, $0C, $0D	;$22
	block $0A, $0B, $0E, $0F	;$23
	block $2E, $2F, $2E, $2F	;$24
	block $70, $70, $70, $70	;$25
	block $72, $72, $72, $72	;$26
	block $73, $73, $73, $73	;$27
	block $78, $79, $78, $79	;$28

;One collision byte per block. LoadRestartPoint copies 64 bytes whatever the
;count, so the copy runs on into whatever follows.	;[ok]
IceManCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $02, $00, $02, $00, $03, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $03
	db $03, $03, $03, $03, $03, $00, $00, $00, $03
IceManCollisionEnd:
