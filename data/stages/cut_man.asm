;Cut Man - StageLoadTab index 1, bank $05.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank05.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
CutManStageData:	;$4008 [dc]
	dw CutManRestartPoints
	dw CutManCheckpoints

;Restart point 0 is the stage start; n is the room checkpoint n names.	;[ok]
CutManRestartPoints:
	dw CutManRestart0
	dw CutManRestart1
	dw CutManRestart2

;Entering one of these rooms makes it the restart point (UpdateRestartPoint).	;[ok]
CutManCheckpoints:
	checkpoint $05, $04	;-> restart point 1, CutManRoom5
	checkpoint $08, $04	;-> restart point 2, CutManRoom8 / CutManRoom9
	end_checkpoints

;restart_point blockset, collision, init, frame hook, x, y, room	;[ok]
CutManRestart0:
	restart_point CutManBlocks, CutManCollision, CutManStageInit, CutManFrameHook, $0047, $33, CutManRoom1
CutManRestart1:
	restart_point CutManBlocks, CutManCollision, CutManStageInit, CutManFrameHook, $0047, $43, CutManRoom5
CutManRestart2:
	restart_point CutManBlocks, CutManCollision, CutManStageInit, CutManFrameHook, $0087, $43, CutManRoom8

CutManRoom1:
	room $01, CutManRoomRoutine, CutManRoom1Layout, $0000
	no_exit
	exit_down 57, 2, CutManRoom2
	spawn 2, 10, $50, $00
	spawn 1, 13, $31, $00
	spawn 2, 16, $60, $00
	spawn 2, 20, $33, $00
	spawn 2, 24, $60, $00
	spawn 2, 28, $33, $00
	spawn 8, 32, $31, $00
	spawn 2, 36, $41, $00
	spawn 1, 36, $11, $00
	spawn 2, 44, $60, $00
	spawn 3, 54, $50, $00
	spawn 1, 56, $11, $00
	end_spawns

CutManRoom2:
	room $02, CutManRoomRoutine, CutManRoom2Layout, $0320
	exit_up 7, 2, CutManRoom1
	exit_down 1, 1, CutManRoom3
	spawn 1, 2, $13, $00
	spawn 1, 5, $51, $00
	end_spawns

CutManRoom3:
	room $03, CutManRoomRoutine, CutManRoom3Layout, $0320
	exit_up 1, 1, CutManRoom2
	exit_up 28, 1, CutManRoom4
	spawn 1, 5, $11, $00
	spawn 1, 11, $30, $00
	spawn 8, 17, $23, $00
	spawn 8, 17, $54, $00
	spawn 3, 22, $60, $00
	spawn 2, 23, $11, $00
	end_spawns

CutManRoom4:
	room $04, CutManRoomRoutine, CutManRoom4Layout, $0460
	exit_down 8, 1, CutManRoom3
	exit_up 1, 1, CutManRoom5
	spawn 1, 2, $13, $00
	spawn 2, 2, $43, $00
	spawn 2, 5, $13, $00
	end_spawns

CutManRoom5:
	room $05, CutManRoomRoutine, CutManRoom5Layout, $0460
	exit_down 1, 1, CutManRoom4
	exit_down 27, 2, CutManRoom6
	spawn 4, 8, $50, $00
	spawn 5, 13, $50, $00
	spawn 5, 22, $50, $00
	spawn 1, 26, $11, $00
	spawn 1, 26, $50, $00
	end_spawns

CutManRoom6:
	room $06, CutManRoomRoutine, CutManRoom6Layout, $05A0
	exit_up 7, 2, CutManRoom5
	exit_down 1, 1, CutManRoom7
	spawn 6, 3, $60, $00
	end_spawns

CutManRoom7:
	room $07, CutManRoomRoutine, CutManRoom7Layout, $05A0
	exit_up 1, 1, CutManRoom6
	exit_down 38, 1, CutManRoom8
	spawn 1, 7, $11, $00
	spawn 1, 12, $01, $00
	spawn 5, 18, $60, $00
	spawn 4, 27, $50, $00
	spawn 5, 32, $40, $00
	spawn 5, 35, $40, $00
	end_spawns

CutManRoom8:
	room $08, CutManRoomRoutine, CutManRoom8Layout, $0780
	exit_up 8, 1, CutManRoom7
	exit_down 1, 1, CutManRoom9
	spawn 55, 5, $30, $00	;boss door (Will)
	end_spawns

CutManRoom9:
	room $08, CutManRoomRoutine, CutManRoom9Layout, $0780
	no_exit
	no_exit
	spawn 30, 8, $00, $00
	spawn 31, 9, $00, $00	;Rolling Cutter (Will)
	end_spawns

;$416F: restart-point init and room routine - neither does anything here.	;[ok]
CutManStageInit:
	ret
CutManRoomRoutine:
	ret

;$4171: frame hook. Blocks $10/$11 are the leftward conveyor belts and $12/$13
;the rightward ones (CutManBlocks): standing on one adds -$B0 or +$B0 to the
;16-bit $D830 - Mega Man's X speed, by the look of it. Then, unless $DFB1 is
;set, it steps the counter $DCD0 and flickers the background palette between
;$90 and $92 every 8 frames. The bit-2 tests choose between identical values;
;and the `jr z` at $41AA can never be reached.	;[ok]
CutManFrameHook:
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	ld bc, -$B0
	cp $10
	jr z, .conveyor
	cp $11
	jr z, .conveyor
	ld bc, $B0
	cp $12
	jr z, .conveyor
	cp $13
	jr nz, .palette
.conveyor
	ld hl, $D830
	ld a, c
	add a, [hl]
	ld [hl+], a
	ld a, b
	adc a, [hl]
	ld [hl], a
.palette
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
	ld a, $90
	jr .setBGP
	jr z, .phaseA2		;unreachable
.phaseA2
	ld a, $90
	jr .setBGP
.phaseB
	ld a, [hl]
	and $04
	jr z, .phaseB2
	ld a, $92
	jr .setBGP
.phaseB2
	ld a, $92
.setBGP
	ld [wShadowBGP], a
	ret

CutManRoom1Layout:	;60 x 8
	layout 60
	lrow "0B 0B 0B 0C 15 15 0D 0E 0F 0D 15 15 16 00 00 0D 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0D 21 21 21 22 20 21 21 21 21 21 22 20 21 21 22 00 14 16 00 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B"
	lrow "0E 0F 0D 1D 15 15 0A 0B 0B 0C 15 15 16 00 00 0D 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0D 1A 1A 1A 1B 17 15 15 15 15 15 18 19 1A 1A 1B 00 17 18 00 1F 1C 1D 1D 1D 1D 1E 1F 1F 0D"
	lrow "0E 0F 0D 15 15 15 1E 1F 1F 1C 15 15 16 00 00 20 21 21 21 21 22 20 21 21 21 21 22 20 21 21 21 15 15 15 16 14 15 15 15 15 15 16 14 15 15 16 00 14 16 00 00 19 1A 1A 1A 1A 1B 00 00 0D"
	lrow "0E 0F 0D 15 15 15 16 00 00 14 15 15 16 00 00 17 15 15 15 15 18 19 1A 1A 1A 1A 1B 17 15 15 15 15 15 15 18 12 13 13 13 13 13 13 12 15 15 16 00 17 18 00 00 17 15 15 15 15 18 00 00 0D"
	lrow "0E 0F 0D 15 15 15 18 00 00 17 15 15 0A 0C 00 14 15 15 15 15 16 14 15 15 15 15 16 14 15 15 15 15 21 15 16 1C 1D 1D 1D 1D 1D 1E 1C 15 15 16 00 14 16 00 00 14 15 15 15 15 16 00 00 0D"
	lrow "0E 0F 0D 15 15 15 16 00 00 14 15 15 0D 0D 00 17 15 15 15 15 18 17 15 15 15 15 18 17 15 15 15 15 15 15 18 17 15 15 15 15 15 18 17 15 21 16 00 17 18 00 00 17 15 15 15 15 18 00 00 0D"
	lrow "0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C 0D 0D 00 14 15 15 15 15 16 14 15 15 15 15 16 14 15 15 15 15 15 15 16 14 15 15 15 15 15 16 14 15 15 16 00 09 16 00 0A 0B 0B 0B 0B 0B 0B 0C 00 0D"
	lrow "0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0D 0D 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C 27 24 25 27 24 0D 0F 0E 0F 0E 0F 0E 0D 00 0D"
	end_layout

CutManRoom2Layout:	;10 x 8
	layout 10
	lrow "0D 20 21 21 21 21 21 22 00 0D"
	lrow "0D 17 15 15 15 15 15 18 00 0D"
	lrow "0D 19 1A 1A 1A 1A 1A 1B 00 0D"
	lrow "0D 17 15 15 15 15 15 18 00 0D"
	lrow "0D 14 15 15 15 15 15 16 00 0D"
	lrow "0D 17 09 15 15 15 15 18 00 0D"
	lrow "0D 14 0D 12 13 13 13 13 12 0D"
	lrow "0D 17 0D 0E 0F 0E 0F 0E 0F 0E"
	end_layout

CutManRoom3Layout:	;30 x 8
	layout 30
	lrow "0D 14 0A 0B 0B 0B 0B 0C 00 00 00 00 14 15 16 00 14 16 00 00 14 15 0A 0B 0B 0B 0B 0C 01 0D"
	lrow "0D 17 1D 1D 1D 1D 1E 1F 00 00 00 00 19 1A 1B 00 17 18 00 00 17 15 1D 1D 1D 1D 1E 1F 01 0D"
	lrow "0D 14 15 15 15 15 16 00 00 00 00 00 14 15 16 00 14 16 00 00 19 1A 1A 1A 1A 1A 1B 00 01 0D"
	lrow "0D 17 15 15 15 15 18 00 00 00 00 00 17 15 18 00 17 22 00 00 20 15 15 15 15 15 18 00 00 0D"
	lrow "0D 14 15 15 15 15 16 00 00 10 11 11 11 10 16 00 14 16 00 00 14 15 15 21 15 21 16 00 09 0D"
	lrow "0D 17 15 15 15 15 18 00 00 1F 1F 1F 1C 1D 18 00 17 18 00 00 17 21 15 15 15 15 18 00 1F 0D"
	lrow "0D 12 13 13 13 13 13 12 00 00 00 00 14 15 16 00 0A 0C 00 00 14 15 15 15 15 15 09 00 00 0D"
	lrow "0D 0E 0F 0E 0F 0E 0F 0D 24 24 24 24 25 26 27 24 0D 0D 24 24 0A 0B 0B 0B 0B 0B 0C 24 24 0D"
	end_layout

CutManRoom4Layout:	;10 x 8
	layout 10
	lrow "0D 01 21 21 21 21 21 21 22 0D"
	lrow "0D 01 15 15 15 15 15 15 18 0D"
	lrow "0D 01 1A 1A 1A 1A 1A 1A 1B 0D"
	lrow "0D 17 21 15 15 15 21 15 18 0D"
	lrow "0D 14 15 15 15 15 15 15 16 0D"
	lrow "0D 20 15 21 15 21 15 21 18 0D"
	lrow "0D 14 15 15 15 15 15 15 16 0D"
	lrow "0A 0B 0B 0B 0B 0B 0B 0C 02 0D"
	end_layout

CutManRoom5Layout:	;30 x 8
	layout 30
	lrow "0D 20 21 21 21 21 0D 0F 0E 0F 0E 0D 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C"
	lrow "0D 14 15 15 15 15 0A 0B 0B 0B 0B 0C 1F 1F 1F 1C 1D 1E 1F 1F 1C 1E 1F 1F 1F 1F 1C 1E 1F 0D"
	lrow "0D 17 15 15 15 15 1D 1E 1C 1E 1F 1F 00 00 00 14 15 16 00 00 14 16 00 00 00 00 14 16 00 0D"
	lrow "0D 02 0A 0C 15 15 15 16 14 16 00 00 00 00 00 19 1A 1B 00 00 19 1B 00 00 00 00 19 1B 00 0D"
	lrow "0D 01 0D 0D 15 15 15 18 17 18 00 00 00 00 00 14 15 16 00 00 14 16 00 00 00 00 14 16 00 0D"
	lrow "0D 01 0D 0D 15 15 15 16 14 16 00 00 00 00 00 17 15 18 00 00 17 18 00 00 00 00 17 18 00 0D"
	lrow "0D 01 0D 0D 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C 15 16 10 11 11 11 11 11 11 11 11 10 00 0D"
	lrow "0D 01 0D 0D 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0E 0D 26 27 0D 0F 0E 0F 0E 0F 0E 0F 0E 0D 00 0D"
	end_layout

CutManRoom6Layout:	;10 x 8
	layout 10
	lrow "0A 0B 0B 0B 0B 0B 0B 0C 00 0D"
	lrow "0D 1F 1C 1D 1D 1D 1E 1F 00 0D"
	lrow "0D 00 19 1A 1A 1A 1B 00 00 0D"
	lrow "0D 00 14 15 15 15 16 00 00 0D"
	lrow "0D 00 17 15 15 15 18 00 00 0D"
	lrow "0D 00 14 15 15 15 16 00 00 0D"
	lrow "0D 00 17 15 15 15 18 00 00 0D"
	lrow "0D 00 0A 0B 0B 0B 0B 0B 0B 0C"
	end_layout

CutManRoom7Layout:	;40 x 8
	layout 40
	lrow "0D 00 20 21 21 21 21 21 22 14 15 16 14 16 00 00 00 00 14 15 15 16 00 00 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C 0D"
	lrow "0D 00 19 1A 1A 1A 1A 1A 1B 17 15 18 17 18 00 00 00 00 17 15 15 18 00 00 1C 1D 1D 1D 1E 1F 1F 1C 1D 1D 1D 1D 1E 1F 1F 0D"
	lrow "0D 00 14 15 15 15 15 15 16 14 15 16 14 16 00 00 00 00 14 15 15 16 00 00 14 15 15 15 16 00 00 14 15 15 15 15 16 00 00 0D"
	lrow "0D 00 17 15 15 15 15 15 18 12 13 13 12 18 00 00 00 00 19 1A 1A 1B 00 00 17 15 15 15 18 00 00 19 1A 1A 1A 1A 1B 00 00 0D"
	lrow "0D 00 14 15 15 15 15 15 16 1C 1D 1E 1C 16 00 00 00 00 14 15 15 16 00 00 14 15 15 15 16 00 00 14 15 15 15 15 16 00 00 0D"
	lrow "0D 00 17 15 12 13 13 12 18 17 15 18 17 18 00 00 00 00 17 15 15 18 00 00 17 15 15 15 18 00 00 17 15 15 15 15 18 00 00 0D"
	lrow "0D 09 09 15 1D 1D 1D 1D 16 14 15 16 14 16 00 00 00 00 14 15 15 16 00 09 14 15 0A 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0C 00 0D"
	lrow "0D 24 25 26 26 26 26 26 27 25 26 27 25 27 24 12 13 13 13 13 12 27 24 24 25 26 0D 0E 0F 0E 0F 0E 0F 0E 0F 0E 0F 0D 00 0D"
	end_layout

CutManRoom8Layout:	;10 x 8
	layout 10
	lrow "0D 0E 0F 0E 0F 0E 0F 0D 00 0D"
	lrow "0D 0E 0F 0E 0F 04 05 0D 00 0D"
	lrow "0D 0A 0B 0B 0B 06 07 0D 00 0D"
	lrow "0D 1C 1D 1D 1D 1E 1F 1F 00 0D"
	lrow "0D 14 15 15 15 16 00 00 00 0D"
	lrow "0D 19 1A 1A 1A 1B 00 00 00 0D"
	lrow "0D 14 15 15 15 16 00 00 00 0D"
	lrow "0D 17 0A 0B 0B 0B 0B 0B 0B 0C"
	end_layout

CutManRoom9Layout:	;10 x 8
	layout 10
	lrow "0D 14 0A 0B 0B 0B 0B 0B 0C 0D"
	lrow "0D 17 1D 1D 1D 1D 1D 1D 1E 0D"
	lrow "0D 14 15 15 15 15 15 15 16 0D"
	lrow "0D 19 1A 1A 1A 1A 1A 1A 1B 0D"
	lrow "0D 14 15 15 15 15 15 15 16 0D"
	lrow "0D 17 15 15 15 15 15 15 18 0D"
	lrow "0D 14 15 15 15 15 15 15 16 0D"
	lrow "0D 0A 0B 0B 0B 0B 0B 0B 0C 0D"
	end_layout

;41 blocks: block top left, top right, bottom left, bottom right (tile numbers).	;[ok]
CutManBlocks:
	blockset CutMan
	block $2A, $2B, $2C, $2D	;$00
	block $12, $13, $12, $13	;$01
	block $12, $13, $12, $13	;$02
	block $24, $25, $24, $25	;$03
	block $18, $7C, $1C, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $0E, $62, $10, $11	;$06
	block $63, $64, $10, $0D	;$07
	block $26, $27, $28, $29	;$08
	block $0A, $0B, $0C, $0D	;$09
	block $0A, $0F, $0C, $11	;$0A
	block $0E, $0F, $10, $11	;$0B
	block $0E, $0B, $10, $0D	;$0C
	block $14, $15, $16, $17	;$0D
	block $18, $19, $1C, $1D	;$0E
	block $1A, $1B, $1E, $1F	;$0F
	block $02, $03, $06, $07	;$10
	block $20, $21, $22, $23	;$11
	block $04, $05, $08, $09	;$12
	block $20, $21, $22, $23	;$13
	block $38, $39, $38, $39	;$14
	block $3A, $3A, $3A, $3A	;$15
	block $3A, $38, $3A, $38	;$16
	block $38, $39, $3B, $39	;$17
	block $3A, $38, $3A, $3B	;$18
	block $30, $31, $34, $35	;$19
	block $32, $32, $36, $36	;$1A
	block $32, $33, $36, $37	;$1B
	block $3C, $3D, $3B, $39	;$1C
	block $3E, $3E, $3A, $3A	;$1D
	block $3E, $3F, $3A, $3B	;$1E
	block $2E, $2F, $2C, $2D	;$1F
	block $00, $01, $3C, $3D	;$20
	block $00, $01, $3E, $3E	;$21
	block $00, $01, $3E, $3F	;$22
	block $40, $41, $42, $43	;$23
	block $44, $45, $4A, $4B	;$24
	block $46, $47, $4C, $4D	;$25
	block $48, $48, $4E, $4E	;$26
	block $48, $46, $4E, $4F	;$27
	block $24, $25, $24, $25	;$28

;One collision byte per block. LoadRestartPoint copies 64 bytes whatever the
;count, so the copy runs on into whatever follows.	;[ok]
CutManCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $02, $02, $02, $00, $00, $00, $00, $00, $03
CutManCollisionEnd:
