;Wily stage 3 and the Wily Machine - StageLoadTab index 7 - bank $08.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank08.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
Wily3StageData:	;$580A
	dw Wily3RestartPoints
	dw Wily3Checkpoints

Wily3RestartPoints:
	dw Wily3Restart0
	dw Wily3Restart1
	dw Wily3Restart2
	dw Wily3Restart3

Wily3Checkpoints:
	checkpoint $06, $04
	checkpoint $0E, $04
	checkpoint $1A, $01
	end_checkpoints

Wily3Restart0:	;$581D
	restart_point Wily3Blocks, Wily3Collision, Wily3StageInit, Wily3FrameHook, $0047, $33, Wily3Room1
Wily3Restart1:	;$582B
	restart_point Wily3Blocks, Wily3Collision, Wily3StageInit, Wily3FrameHook, $0047, $33, Wily3Room6
Wily3Restart2:	;$5839
	restart_point Wily3Blocks, Wily3Collision, Wily3StageInit, Wily3FrameHook, $0047, $43, Wily3Room14
;The Wily Machine room, with a blockset of its own.	;[ok]
Wily3Restart3:	;$5847
	restart_point Wily3BossRoomBlocks, Wily3BossRoomCollision, Wily3BossRoomInit, Wily3BossRoomHook, $0017, $43, Wily3Room27
;Not in the restart table: a restart point in room $0D that nothing points at.	;[ok]
Wily3UnusedRestart:	;$5855
	restart_point Wily3Blocks, Wily3Collision, Wily3StageInit, Wily3FrameHook, $0067, $33, Wily3Room13

;$5863: init of restart point 3, the Wily Machine room: marks the whole castle
;and all four robot masters done (wWilyProgress $9F, wBossesDefeated $0F) and
;blanks the palettes.	;[ok]
Wily3BossRoomInit:
	ld a, $9F
	ld [wWilyProgress], a
	ld a, $0F
	ld [wBossesDefeated], a
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ldh [rOBP1], a
	ret

;$5877: init of restart points 0-2: the same progress marks, palette $E4.	;[ok]
Wily3StageInit:
	ld a, $9F
	ld [wWilyProgress], a
	ld a, $0F
	ld [wBossesDefeated], a
	ld a, $E4
	ld [wShadowBGP], a
	ldh [rBGP], a
	ret

Wily3Room1:	;$5889
	room $01, Wily3RoomRoutine, Wily3Room1Layout, $0000
	no_exit
	exit_down 97, 2, Wily3Room2
	spawn 4, 10, $61, $00
	spawn 17, 26, $31, $00
	spawn 17, 32, $31, $00
	spawn 17, 37, $31, $00
	spawn 17, 42, $31, $00
	spawn 16, 54, $40, $00
	spawn 16, 54, $50, $00
	spawn 16, 54, $60, $00
	spawn 2, 63, $41, $00
	spawn 3, 67, $60, $00
	spawn 24, 73, $60, $00
	spawn 22, 82, $40, $00
	spawn 22, 84, $51, $00
	spawn 2, 96, $11, $00
	spawn 17, 96, $41, $00
	end_spawns

Wily3Room2:	;$58D3
	room $02, Wily3RoomRoutine, Wily3Room2Layout, $05A0
	no_exit
	exit_down 1, 8, Wily3Room3
	end_spawns

Wily3Room3:	;$58E1
	room $03, Wily3RoomRoutine, Wily3Room3Layout, $05A0
	no_exit
	exit_down 1, 1, Wily3Room4
	spawn 9, 2, $41, $00	;fan
	spawn 22, 4, $31, $00
	end_spawns

Wily3Room4:	;$58F7
	room $04, Wily3RoomRoutine, Wily3Room4Layout, $05A0
	no_exit
	exit_down 38, 1, Wily3Room5
	spawn 20, 5, $56, $00	;appearing block
	end_spawns

Wily3Room5:	;$5909
	room $05, Wily3RoomRoutine, Wily3Room5Layout, $0780
	no_exit
	exit_down 1, 1, Wily3Room6
	spawn 19, 8, $10, $00
	end_spawns

Wily3Room6:	;$591B
	room $06, Wily3RoomRoutine, Wily3Room6Layout, $0780
	no_exit
	exit_down 38, 1, Wily3Room7
	spawn 6, 10, $60, $00
	spawn 6, 23, $30, $00
	spawn 6, 37, $30, $00
	end_spawns

Wily3Room7:	;$5935
	room $07, Wily3RoomRoutine, Wily3Room7Layout, $0960
	no_exit
	exit_down 1, 1, Wily3Room8
	spawn 1, 2, $12, $00
	spawn 1, 5, $11, $00
	end_spawns

Wily3Room8:	;$594B
	room $08, Wily3RoomRoutine, Wily3Room4Layout, $0960
	no_exit
	exit_down 38, 1, Wily3Room9
	spawn 20, 5, $57, $00	;appearing block
	end_spawns

Wily3Room9:	;$595D
	room $09, Wily3RoomRoutine, Wily3Room5Layout, $0B40
	no_exit
	exit_down 1, 1, Wily3Room10
	spawn 4, 2, $51, $00
	end_spawns

Wily3Room10:	;$596F
	room $0A, Wily3RoomRoutine, Wily3Room10Layout, $0B40
	no_exit
	exit_up 58, 1, Wily3Room11
	spawn 1, 6, $12, $00
	spawn 5, 13, $40, $00
	spawn 1, 17, $40, $00
	spawn 5, 19, $40, $00
	spawn 5, 25, $20, $00
	spawn 1, 26, $03, $00
	spawn 5, 33, $30, $00
	spawn 1, 34, $02, $00
	spawn 5, 43, $40, $00
	spawn 8, 53, $24, $00
	spawn 1, 55, $13, $00
	end_spawns

Wily3Room11:	;$59A9
	room $0B, Wily3RoomRoutine, Wily3Room11Layout, $0E60
	exit_down 8, 1, Wily3Room10
	exit_up 1, 8, Wily3Room12
	spawn 19, 5, $10, $00
	end_spawns

Wily3Room12:	;$59BF
	room $0C, Wily3RoomRoutine, Wily3Room12Layout, $0E60
	exit_down 1, 8, Wily3Room11
	exit_up 1, 8, Wily3Room13
	spawn 22, 4, $20, $00
	spawn 22, 4, $50, $00
	end_spawns

Wily3Room13:	;$59D9
	room $0D, Wily3RoomRoutine, Wily3Room13Layout, $0E60
	exit_down 1, 8, Wily3Room12
	exit_up 1, 1, Wily3Room14
	spawn 19, 5, $10, $00
	end_spawns

Wily3Room14:	;$59EF
	room $0E, Wily3RoomRoutine, Wily3Room14Layout, $0E60
	exit_down 1, 1, Wily3Room13
	exit_down 26, 3, Wily3Room15
	spawn 29, 6, $50, $00	;Atomic Fire block
	spawn 29, 6, $60, $00	;Atomic Fire block
	spawn 8, 7, $61, $00
	spawn 8, 8, $63, $00
	spawn 4, 25, $60, $00
	spawn 29, 27, $10, $00	;Atomic Fire block
	spawn 29, 27, $20, $00	;Atomic Fire block
	end_spawns

Wily3Room15:	;$5A1D
	room $0F, Wily3RoomRoutine, Wily3Room15Layout, $0FA0
	no_exit
	exit_down 1, 3, Wily3Room16
	spawn 12, 3, $30, $00
	spawn 8, 4, $65, $00
	spawn 8, 5, $65, $00
	spawn 8, 6, $65, $00
	spawn 8, 7, $65, $00
	end_spawns

Wily3Room16:	;$5A3F
	room $10, Wily3RoomRoutine, Wily3Room16Layout, $0FA0
	no_exit
	exit_down 1, 8, Wily3Room17
	spawn 8, 3, $35, $00
	spawn 8, 4, $35, $00
	spawn 8, 5, $35, $00
	spawn 22, 7, $60, $00
	end_spawns

Wily3Room17:	;$5A5D
	room $11, Wily3RoomRoutine, Wily3Room17Layout, $0FA0
	no_exit
	exit_down 1, 8, Wily3Room18
	end_spawns

Wily3Room18:	;$5A6B
	room $12, Wily3RoomRoutine, Wily3Room18Layout, $0FA0
	no_exit
	exit_down 1, 8, Wily3Room19
	end_spawns

Wily3Room19:	;$5A79
	room $13, Wily3RoomRoutine, Wily3Room19Layout, $0FA0
	no_exit
	exit_down 1, 6, Wily3Room20
	end_spawns

Wily3Room20:	;$5A87
	room $14, Wily3RoomRoutine, Wily3Room20Layout, $0FA0
	no_exit
	exit_down 8, 1, Wily3Room21
	spawn 12, 4, $60, $00
	end_spawns

Wily3Room21:	;$5A99
	room $15, Wily3RoomRoutine, Wily3Room21Layout, $0FA0
	no_exit
	exit_down 1, 1, Wily3Room22
	spawn 24, 2, $40, $00
	spawn 24, 5, $40, $00
	end_spawns

Wily3Room22:	;$5AAF
	room $16, Wily3RoomRoutine, Wily3Room22Layout, $0FA0
	no_exit
	exit_down 38, 1, Wily3Room23
	spawn 2, 6, $31, $00
	spawn 2, 11, $60, $00
	spawn 2, 16, $31, $00
	spawn 2, 20, $60, $00
	spawn 2, 25, $31, $00
	spawn 9, 31, $51, $00	;fan
	spawn 9, 31, $61, $00	;fan
	spawn 22, 36, $51, $00
	end_spawns

Wily3Room23:	;$5ADD
	room $17, Wily3RoomRoutine, Wily3Room23Layout, $1180
	no_exit
	exit_down 1, 1, Wily3Room24
	spawn 5, 4, $40, $00
	spawn 5, 4, $50, $00
	spawn 5, 4, $60, $00
	end_spawns

Wily3Room24:	;$5AF7
	room $18, Wily3RoomRoutine, Wily3Room24Layout, $1180
	no_exit
	exit_down 1, 1, Wily3Room25
	spawn 8, 3, $41, $00
	end_spawns

Wily3Room25:	;$5B09
	room $19, Wily3RoomRoutine, Wily3Room25Layout, $1180
	no_exit
	exit_down 0, 10, Wily3Room26
	end_spawns

Wily3Room26:	;$5B17
	room $1A, Wily3RoomRoutine, Wily3Room26Layout, $1180
	no_exit
	exit_down 0, 10, Wily3Room27
	end_spawns

;The Wily Machine room (object type 48). Mega Man drops in from room $1A;
;Wily3BossRoomRoutine swaps the blockset.	;[ok]
Wily3Room27:	;$5B25
	room $1B, Wily3BossRoomRoutine, Wily3Room27Layout, $1180
	no_exit
	no_exit
	spawn 48, 5, $50, $00	;Dr. Wily and the Wily Machine's sprite parts (Will)
	end_spawns

;$5B33: room routine of every room but the last - nothing.	;[ok]
Wily3RoomRoutine:
	ret

;$5B34: frame hook: the spike test only.	;[ok]
Wily3FrameHook:
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
.notSpikes
	ret

;$5B41: the Wily Machine room's frame hook - nothing.	;[ok]
Wily3BossRoomHook:
	ret

;$5B42: the Wily Machine room's room routine, run when Mega Man drops in from
;room $1A: makes restart point 3 current, blanks the palette and swaps in that
;restart point's blockset and hooks (SwapRestartData). The final `ret` is
;reached by nothing.	;[ok]
Wily3BossRoomRoutine:
	ld a, $03
	ld [wRestartPoint], a
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ld hl, Wily3Restart3 + 1
	call SwapRestartData
	ret
	ret

Wily3Room1Layout:	;100 x 8
	layout 100
	lrow "33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 30 1D 1D 30 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 30 1D 1D 1D 1D 1D 1D 30 1C 1C 1C 1C 30 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34"
	lrow "30 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 33 34 33 30 1D 1D 1D 1D 1D 1D 1D 1D 1D 1D 1D 30 1C 1C 1C 1C 1C 1C 30 34 33 34 33 34 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 30"
	lrow "30 26 09 0A 13 14 13 0B 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 35 36 35 30 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 30 33 34 33 34 33 34 33 36 35 36 35 36 00 26 00 26 00 26 09 0A 13 14 13 0B 00 26 00 26 00 26 00 30"
	lrow "30 26 0C 2B 29 2B 2B 0F 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 34 33 34 33 34 33 34 33 34 33 34 33 34 35 36 35 36 35 36 35 26 00 26 00 26 00 26 00 26 00 26 0C 2B 28 29 2B 0F 00 26 00 26 00 26 00 30"
	lrow "30 26 0E 2B 2B 29 2C 0D 00 26 00 26 00 26 30 26 00 26 00 26 30 26 00 26 00 26 30 26 00 26 00 26 17 26 00 26 00 18 00 26 00 26 17 26 00 26 00 26 30 26 00 26 00 26 00 36 35 36 35 36 35 36 35 36 35 36 35 36 00 09 0A 13 14 13 0B 26 00 34 33 34 33 26 00 26 00 26 0E 2B 2B 2C 29 0D 00 26 00 26 00 26 00 30"
	lrow "30 26 10 15 15 16 11 12 00 26 00 26 00 30 30 26 00 26 00 30 30 26 00 26 00 30 30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 30 30 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 0C 27 28 29 2C 0D 26 00 30 1D 1D 30 26 00 26 00 26 10 15 15 16 11 12 00 26 00 26 30 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 30 30 30 26 00 26 30 30 30 26 00 26 30 30 30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 30 30 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 10 15 15 16 11 12 34 33 30 1C 1C 30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 30 26 00 30"
	lrow "33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 30 1D 30 1D 1D 30 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 30 26 00 30"
	end_layout

Wily3Room2Layout:	;10 x 8
	layout 10
	lrow "30 1C 1C 1C 1C 1C 34 26 00 30"
	lrow "30 1D 1D 1D 1D 34 35 26 00 30"
	lrow "30 1C 1C 1C 34 36 00 26 00 30"
	lrow "30 1D 1D 34 35 26 00 26 00 30"
	lrow "30 1C 34 36 00 26 00 26 00 30"
	lrow "30 34 35 26 00 26 00 26 00 30"
	lrow "30 36 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	end_layout

Wily3Room3Layout:	;10 x 8
	layout 10
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 09 0A 13 14 13 0B 00 30"
	lrow "30 26 0C 2B 1E 1F 2C 0F 00 30"
	lrow "30 26 0E 28 2B 27 29 0D 00 30"
	lrow "30 26 10 16 15 16 11 12 00 30"
	lrow "30 26 30 26 30 26 30 26 30 30"
	lrow "30 26 30 08 30 08 30 08 30 30"
	lrow "30 26 33 34 33 34 33 34 33 34"
	end_layout

Wily3Room4Layout:	;40 x 8; also Wily3Room8
	layout 40
	lrow "30 00 17 17 17 17 17 17 17 17 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 34 33 30"
	lrow "30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 09 0A 14 13 14 13 13 14 13 14 13 13 14 13 0B 26 26 36 36 30"
	lrow "30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C 2B 2B 2B 28 29 2B 2C 2B 2B 28 2C 2B 2B 0F 00 00 00 00 30"
	lrow "30 26 26 26 09 0A 13 14 13 14 13 0B 26 26 26 26 26 26 26 26 0E 29 28 2B 2B 2B 27 2C 28 2B 2B 1E 1F 28 0F 26 26 26 26 30"
	lrow "30 00 00 00 0C 28 29 2B 2B 2C 2B 0D 00 00 00 00 00 00 00 00 0E 27 2B 29 28 2B 2B 2B 29 2B 2C 2B 2B 27 0D 00 00 00 00 30"
	lrow "30 26 26 26 10 15 16 16 15 16 11 12 26 26 26 26 26 26 26 26 10 15 16 15 16 16 15 16 16 15 16 15 16 11 12 26 33 34 26 30"
	lrow "30 33 34 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 30 00 30"
	lrow "1C 1C 30 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 30 30 26 30"
	end_layout

Wily3Room5Layout:	;10 x 8; also Wily3Room9
	layout 10
	lrow "33 34 33 34 33 34 33 34 00 30"
	lrow "30 36 23 24 24 24 24 25 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 30 21 30 21 30 22 30 30"
	lrow "30 26 33 34 33 34 33 34 33 34"
	end_layout

Wily3Room6Layout:	;40 x 8
	layout 40
	lrow "30 26 33 34 33 34 33 34 33 34 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 35 36 35 36 35 36 35 36 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 34 26 00 26 00 26 00 26 00 26 00 33 34 26 00 26 00 26 00 26 00 26 00 26 33 34 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 33 1C 33 34 26 00 26 00 26 00 33 34 1C 30 26 00 26 00 26 00 26 00 26 33 34 1C 30 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 30 1D 1D 1D 33 34 26 00 33 34 1D 1D 1D 30 26 00 26 00 26 00 26 33 34 1D 1D 1D 30 00 30"
	lrow "33 34 33 34 33 34 33 34 33 34 33 30 1C 1C 1C 30 33 34 33 34 30 1C 1C 1C 30 34 33 34 33 34 33 34 30 1D 1C 1C 1C 30 00 30"
	end_layout

Wily3Room7Layout:	;10 x 8
	layout 10
	lrow "33 34 33 34 33 34 33 34 00 30"
	lrow "30 36 23 24 24 24 24 25 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 20 21 21 21 21 22 00 30"
	lrow "30 26 30 21 21 21 21 22 00 30"
	lrow "30 26 30 33 34 21 21 22 00 30"
	lrow "30 26 30 1C 1C 33 34 22 00 30"
	lrow "30 26 33 1D 1D 34 33 34 33 34"
	end_layout

Wily3Room10Layout:	;60 x 8
	layout 60
	lrow "30 00 17 17 17 17 17 17 17 17 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 33 34 33 34 33 34 33 34 33 34 01 30"
	lrow "30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 36 36 36 36 36 36 36 36 36 36 01 30"
	lrow "30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 30"
	lrow "30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 18 18 26 18 18 18 18 26 26 01 30"
	lrow "30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 30"
	lrow "30 33 34 33 18 18 18 26 26 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 26 26 18 18 18 18 18 18 18 26 26 18 18 18 18 18 18 26 26 26 26 26 18 26 26 26 26 26 26 26 26 30"
	lrow "30 1C 1C 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 17 00 00 00 00 00 00 00 00 00 00 00 00 30"
	lrow "30 1D 1D 30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 18 18 18 18 18 18 18 18 18 18 18 30"
	end_layout

Wily3Room11Layout:	;10 x 8
	layout 10
	lrow "30 01 20 30 21 21 30 01 00 30"
	lrow "30 01 20 30 21 21 30 01 00 30"
	lrow "30 01 20 30 21 21 30 01 00 30"
	lrow "30 01 20 30 21 21 30 01 00 30"
	lrow "30 26 20 24 21 21 30 01 00 30"
	lrow "30 26 20 21 21 21 30 22 00 30"
	lrow "30 26 20 21 21 21 30 22 00 30"
	lrow "33 34 33 34 33 34 33 34 02 30"
	end_layout

Wily3Room12Layout:	;10 x 8
	layout 10
	lrow "30 26 01 30 01 21 30 22 01 30"
	lrow "30 26 01 30 01 21 30 22 01 30"
	lrow "30 26 01 30 01 21 30 22 01 30"
	lrow "30 26 20 30 01 21 30 22 00 30"
	lrow "30 26 20 30 01 21 30 22 00 30"
	lrow "30 26 20 30 01 21 30 22 00 30"
	lrow "30 02 20 30 21 21 30 02 00 30"
	lrow "30 01 20 30 21 21 30 01 00 30"
	end_layout

Wily3Room13Layout:	;10 x 8
	layout 10
	lrow "30 01 33 34 33 34 33 34 33 34"
	lrow "30 01 23 30 24 24 24 25 35 30"
	lrow "30 01 20 30 21 21 21 22 00 30"
	lrow "30 26 20 30 21 21 21 22 00 30"
	lrow "30 26 20 30 02 21 30 22 02 30"
	lrow "30 26 20 30 01 21 30 22 01 30"
	lrow "30 26 02 30 01 21 30 22 01 30"
	lrow "30 26 01 30 01 21 30 22 01 30"
	end_layout

Wily3Room14Layout:	;30 x 8
	layout 30
	lrow "30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 34 33 34 33 34 33 34 33 34 33 34 33 34 33 30"
	lrow "30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 36 36 36 36 36 36 36 36 36 36 36 36 36 36 30"
	lrow "30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30"
	lrow "30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 18 18 18 18 18 18 18 18 18 18 18 18 30 26 30"
	lrow "30 00 00 00 00 00 33 34 33 34 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 00 30"
	lrow "30 26 26 26 26 26 36 36 36 30 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 26 30 26 30"
	lrow "30 00 00 00 00 00 00 00 00 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 00 30"
	lrow "30 02 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 26 30 26 30"
	end_layout

Wily3Room15Layout:	;10 x 8
	layout 10
	lrow "30 34 33 34 33 34 00 30 00 30"
	lrow "30 36 35 36 35 36 00 30 00 30"
	lrow "30 26 00 26 00 26 00 30 00 30"
	lrow "30 26 00 26 00 26 00 30 00 30"
	lrow "30 26 30 18 17 18 17 18 00 30"
	lrow "30 26 30 26 00 26 00 26 00 30"
	lrow "30 26 30 26 00 26 00 26 00 30"
	lrow "30 26 30 26 33 34 33 34 33 34"
	end_layout

Wily3Room16Layout:	;10 x 8
	layout 10
	lrow "30 26 30 26 33 34 33 34 33 30"
	lrow "30 26 30 26 35 36 35 36 35 30"
	lrow "30 26 30 26 00 26 00 26 00 30"
	lrow "30 26 30 26 00 26 00 26 00 30"
	lrow "30 26 17 18 17 30 00 26 00 30"
	lrow "30 26 00 26 00 30 00 26 00 30"
	lrow "30 26 00 26 00 30 00 26 00 30"
	lrow "30 26 00 26 00 30 00 26 00 30"
	end_layout

Wily3Room17Layout:	;10 x 8
	layout 10
	lrow "30 26 00 26 00 30 00 26 00 30"
	lrow "30 26 00 26 00 30 00 26 00 30"
	lrow "30 26 00 26 00 36 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 08 08 26 00 26 00 30"
	lrow "30 26 00 30 30 26 00 26 00 30"
	end_layout

Wily3Room18Layout:	;10 x 8
	layout 10
	lrow "30 26 00 30 30 26 00 26 00 30"
	lrow "30 26 00 30 30 26 00 26 00 30"
	lrow "30 26 00 36 30 26 00 26 00 30"
	lrow "30 26 00 26 30 26 00 26 00 30"
	lrow "30 26 00 26 30 26 00 26 00 30"
	lrow "30 26 00 26 30 08 08 26 00 30"
	lrow "30 26 00 26 17 18 30 26 00 30"
	lrow "30 26 00 26 00 26 30 26 00 30"
	end_layout

Wily3Room19Layout:	;10 x 8
	layout 10
	lrow "30 26 00 26 00 26 30 26 00 30"
	lrow "30 26 00 26 00 26 30 26 00 30"
	lrow "30 26 00 26 00 26 35 26 00 30"
	lrow "30 26 09 0A 13 14 13 0B 00 30"
	lrow "30 26 0C 28 29 2B 2C 0D 00 30"
	lrow "30 26 10 15 15 16 11 12 00 30"
	lrow "30 26 30 08 08 30 00 26 00 30"
	lrow "30 26 30 30 30 30 00 33 34 30"
	end_layout

Wily3Room20Layout:	;10 x 8
	layout 10
	lrow "30 26 30 30 30 30 00 33 34 30"
	lrow "30 26 35 36 35 36 00 36 35 30"
	lrow "30 09 0A 14 13 14 13 14 0B 30"
	lrow "30 0C 2B 2C 28 29 28 29 0F 30"
	lrow "30 0E 2B 2C 2C 2C 27 2B 0F 30"
	lrow "30 0E 27 28 29 2B 1E 1F 0D 30"
	lrow "30 10 15 16 16 16 15 11 12 30"
	lrow "30 33 34 33 34 33 34 33 00 30"
	end_layout

Wily3Room21Layout:	;10 x 8
	layout 10
	lrow "30 33 34 33 34 33 34 33 00 30"
	lrow "30 36 35 36 35 36 35 36 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 30 26 00 30 00 26 00 30"
	lrow "30 26 30 26 00 30 00 26 00 30"
	lrow "30 26 33 34 33 34 33 34 33 34"
	end_layout

Wily3Room22Layout:	;40 x 8
	layout 40
	lrow "30 26 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 31 1C 33 34 33 34 33 34 33 34 33 34 33 30"
	lrow "30 26 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 31 1D 35 36 35 36 35 36 35 36 35 36 35 30"
	lrow "30 26 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 32 33 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 35 36 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 30 26 00 26 00 26 00 26 00 30"
	lrow "30 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 33 34 00 34"
	end_layout

Wily3Room23Layout:	;10 x 8
	layout 10
	lrow "33 34 33 34 33 34 33 34 00 30"
	lrow "30 36 35 36 35 36 35 36 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 00 26 00 26 00 26 00 30"
	lrow "30 26 33 34 33 34 33 34 33 34"
	lrow "30 26 33 34 33 34 33 34 33 34"
	end_layout

Wily3Room24Layout:	;10 x 8
	layout 10
	lrow "30 26 33 34 33 34 33 34 33 34"
	lrow "30 26 04 05 30 1C 1C 1C 1C 1C"
	lrow "30 26 06 07 30 1D 1D 1D 1D 1D"
	lrow "30 26 23 24 30 1C 1C 1C 1C 1C"
	lrow "30 26 20 21 30 1D 1D 1D 1D 1D"
	lrow "30 26 33 34 33 34 33 34 33 34"
	lrow "30 26 30 1C 1C 1C 1C 1C 1C 1C"
	lrow "30 26 30 1D 1D 1D 1D 1D 1D 1D"
	end_layout

Wily3Room25Layout:	;10 x 8
	layout 10
	lrow "30 21 30 1C 1C 1C 1C 1C 1C 1C"
	lrow "30 21 30 1D 1D 1D 1D 1D 1D 1D"
	lrow "30 21 30 1C 1C 1C 1C 1C 1C 1C"
	lrow "30 21 30 1D 1D 1D 1D 1D 1D 1D"
	lrow "30 2A 30 34 33 34 33 34 33 34"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	end_layout

Wily3Room26Layout:	;10 x 8
	layout 10
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	lrow "3A 2A 3A 3A 3A 3A 3A 3A 3A 3A"
	end_layout

Wily3Room27Layout:	;10 x 8
	layout 10
	lrow "00 00 00 00 00 00 23 23 23 23"
	lrow "00 00 00 00 00 00 23 09 0A 0B"
	lrow "00 00 00 00 00 00 0C 0D 0E 0F"
	lrow "00 00 00 00 00 00 10 11 12 13"
	lrow "00 00 00 00 00 14 15 16 17 18"
	lrow "00 00 00 00 00 00 19 1A 1B 1C"
	lrow "00 00 00 00 00 00 1D 1E 1F 20"
	lrow "21 22 21 22 21 22 21 22 21 22"
	end_layout

;The Wily Machine room's blockset (restart point 3).	;[ok]
;36 blocks: block top left, top right, bottom left, bottom right.	;[ok]
Wily3BossRoomBlocks:
	blockset Wily3BossRoom
	block $73, $73, $73, $73	;$00
	block $4E, $4F, $4E, $4F	;$01
	block $4E, $4F, $4E, $4F	;$02
	block $78, $79, $78, $79	;$03
	block $73, $7C, $73, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $73, $62, $73, $73	;$06
	block $63, $64, $73, $73	;$07
	block $73, $73, $73, $73	;$08
	block $73, $73, $73, $10	;$09
	block $73, $73, $11, $73	;$0A
	block $73, $73, $73, $12	;$0B
	block $73, $00, $73, $05	;$0C
	block $01, $02, $06, $07	;$0D
	block $03, $04, $08, $09	;$0E
	block $13, $14, $0A, $15	;$0F
	block $16, $0B, $19, $1A	;$10
	block $0C, $0D, $1B, $1C	;$11
	block $0E, $0F, $1D, $1E	;$12
	block $17, $18, $1F, $20	;$13
	block $73, $73, $73, $29	;$14
	block $21, $22, $2A, $2B	;$15
	block $23, $24, $2C, $2D	;$16
	block $25, $26, $2E, $2F	;$17
	block $27, $28, $30, $31	;$18
	block $32, $33, $73, $73	;$19
	block $34, $35, $3A, $3B	;$1A
	block $36, $37, $3C, $3D	;$1B
	block $38, $39, $3E, $3F	;$1C
	block $73, $40, $73, $47	;$1D
	block $41, $42, $48, $49	;$1E
	block $43, $44, $4A, $4B	;$1F
	block $45, $46, $4C, $4D	;$20
	block $4E, $4F, $4F, $4F	;$21
	block $4F, $4F, $4E, $4F	;$22
	block $73, $73, $73, $73	;$23

;One collision byte per block.	;[ok]
Wily3BossRoomCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $00, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03
Wily3BossRoomCollisionEnd:

;59 blocks: block top left, top right, bottom left, bottom right.	;[ok]
Wily3Blocks:
	blockset Wily3
	block $32, $33, $36, $37	;$00
	block $40, $41, $40, $41	;$01
	block $40, $41, $40, $41	;$02
	block $78, $79, $78, $79	;$03
	block $00, $7C, $02, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $00, $62, $02, $03	;$06
	block $63, $64, $02, $03	;$07
	block $74, $75, $76, $77	;$08
	block $10, $11, $13, $18	;$09
	block $11, $11, $19, $72	;$0A
	block $11, $12, $72, $14	;$0B
	block $13, $19, $13, $72	;$0C
	block $72, $14, $18, $14	;$0D
	block $13, $1F, $13, $72	;$0E
	block $72, $14, $20, $14	;$0F
	block $13, $1F, $15, $16	;$10
	block $72, $18, $16, $16	;$11
	block $19, $14, $16, $17	;$12
	block $11, $11, $1F, $72	;$13
	block $11, $11, $20, $21	;$14
	block $72, $1F, $16, $16	;$15
	block $20, $72, $16, $16	;$16
	block $3A, $3B, $42, $43	;$17
	block $3A, $3B, $44, $45	;$18
	block $3A, $3B, $2E, $2F	;$19
	block $3A, $3B, $30, $30	;$1A
	block $3A, $3B, $30, $2E	;$1B
	block $22, $23, $24, $25	;$1C
	block $26, $27, $28, $29	;$1D
	block $1A, $1B, $1D, $1E	;$1E
	block $1C, $72, $1F, $20	;$1F
	block $2A, $2B, $2A, $2B	;$20
	block $2C, $2C, $2C, $2C	;$21
	block $2D, $2A, $2D, $2A	;$22
	block $2E, $2F, $2A, $2B	;$23
	block $30, $30, $2C, $2C	;$24
	block $31, $2E, $2D, $2A	;$25
	block $34, $35, $38, $39	;$26
	block $21, $72, $72, $1F	;$27
	block $72, $1F, $20, $72	;$28
	block $20, $72, $1F, $20	;$29
	block $73, $73, $73, $73	;$2A
	block $72, $72, $72, $72	;$2B
	block $20, $72, $1F, $20	;$2C
	block $2E, $2F, $2A, $2B	;$2D
	block $30, $30, $2C, $2C	;$2E
	block $31, $2E, $2D, $2A	;$2F
	block $00, $01, $02, $03	;$30
	block $04, $05, $06, $07	;$31
	block $08, $09, $0A, $0B	;$32
	block $0C, $0C, $0E, $0E	;$33
	block $0C, $0D, $0E, $0F	;$34
	block $3C, $3D, $36, $37	;$35
	block $3E, $3F, $38, $39	;$36
	block $46, $47, $48, $49	;$37
	block $4A, $4B, $4C, $4D	;$38
	block $4E, $4E, $4F, $4F	;$39
	block $73, $73, $73, $73	;$3A

;One collision byte per block.	;[ok]
Wily3Collision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $02, $02, $02, $02, $02, $03, $03, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $03, $03, $03, $03, $03, $00, $00, $03, $03, $03, $03
Wily3CollisionEnd:
