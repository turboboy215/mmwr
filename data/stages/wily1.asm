;Wily stage 1 - StageLoadTab index 5 - bank $08.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank08.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
Wily1StageData:	;$4079
	dw Wily1RestartPoints
	dw Wily1Checkpoints

Wily1RestartPoints:
	dw Wily1Restart0
	dw Wily1Restart1
	dw Wily2Restart0

Wily1Checkpoints:
;Restart point 2 is Wily 2's own start (Wily2Restart0), and its checkpoint names
;room $18, which Wily 1 does not have - so it can never be reached. Wily 1's own
;third record, Wily1UnusedRestart, sits unreferenced after the other two.	;[ok]
	checkpoint $0C, $04
	checkpoint $18, $04
	end_checkpoints

Wily1Restart0:	;$4088
	restart_point Wily1Blocks, Wily1Collision, Wily1StageInit, Wily1FrameHook, $0047, $23, Wily1Room1
Wily1Restart1:	;$4096
	restart_point Wily1Blocks, Wily1Collision, Wily1StageInit, Wily1FrameHook, $0047, $23, Wily1Room12
;Not in the restart table: a restart point in room $15, near the end of the
;stage, that nothing points at. Probably what restart point 2 was meant to be.	;[ok]
Wily1UnusedRestart:	;$40A4
	restart_point Wily1Blocks, Wily1Collision, Wily1StageInit, Wily1FrameHook, $0057, $23, Wily1Room21

Wily1Room1:	;$40B2
	room $01, Wily1RoomRoutine, Wily1Room1Layout, $0000
	no_exit
	exit_down 8, 1, Wily1Room2
	spawn 8, 1, $21, $00
	spawn 21, 1, $10, $00
	spawn 21, 7, $34, $00
	spawn 8, 8, $24, $00
	end_spawns

Wily1Room2:	;$40D0
	room $02, Wily1RoomRoutine, Wily1Room2Layout, $0000
	no_exit
	exit_down 1, 1, Wily1Room3
	spawn 21, 3, $11, $00
	spawn 21, 5, $31, $00
	spawn 21, 6, $30, $00
	spawn 21, 7, $31, $00
	end_spawns

Wily1Room3:	;$40EE
	room $03, Wily1RoomRoutine, Wily1Room3Layout, $0000
	no_exit
	exit_down 8, 1, Wily1Room4
	spawn 4, 4, $60, $00
	spawn 9, 6, $50, $00	;fan
	spawn 9, 6, $60, $00	;fan
	end_spawns

Wily1Room4:	;$4108
	room $04, Wily1RoomRoutine, Wily1Room4Layout, $0000
	no_exit
	exit_down 1, 1, Wily1Room5
	spawn 6, 2, $50, $00
	end_spawns

Wily1Room5:	;$411A
	room $05, Wily1RoomRoutine, Wily1Room5Layout, $0000
	no_exit
	exit_down 18, 1, Wily1Room6
	spawn 18, 5, $40, $0A
	spawn 18, 14, $41, $0A
	end_spawns

Wily1Room6:	;$4130
	room $06, Wily1RoomRoutine, Wily1Room6Layout, $00A0
	no_exit
	exit_down 1, 8, Wily1Room7
	end_spawns

Wily1Room7:	;$413E
	room $07, Wily1RoomRoutine, Wily1Room7Layout, $00A0
	no_exit
	exit_down 1, 8, Wily1Room8
	spawn 8, 2, $34, $00
	spawn 8, 6, $55, $00
	end_spawns

Wily1Room8:	;$4154
	room $08, Wily1RoomRoutine, Wily1Room8Layout, $00A0
	no_exit
	exit_down 1, 8, Wily1Room9
	end_spawns

Wily1Room9:	;$4162
	room $09, Wily1RoomRoutine, Wily1Room9Layout, $00A0
	no_exit
	exit_down 1, 8, Wily1Room10
	spawn 22, 7, $50, $00
	end_spawns

Wily1Room10:	;$4174
	room $0A, Wily1RoomRoutine, Wily1Room10Layout, $00A0
	no_exit
	exit_down 1, 8, Wily1Room11
	spawn 12, 2, $50, $00
	end_spawns

Wily1Room11:	;$4186
	room $0B, Wily1RoomRoutine, Wily1Room11Layout, $00A0
	no_exit
	exit_down 1, 2, Wily1Room12
	end_spawns

Wily1Room12:	;$4194
	room $0C, Wily1RoomRoutine, Wily1Room12Layout, $00A0
	no_exit
	exit_down 48, 1, Wily1Room13
	spawn 4, 11, $61, $00
	spawn 17, 17, $50, $00
	spawn 17, 23, $50, $00
	spawn 7, 30, $00, $00
	spawn 7, 33, $01, $00
	spawn 7, 36, $02, $00
	spawn 7, 39, $00, $00
	spawn 7, 42, $01, $00
	spawn 7, 45, $02, $00
	end_spawns

Wily1Room13:	;$41C6
	room $0D, Wily1RoomRoutine, Wily1Room13Layout, $0320
	no_exit
	exit_down 1, 1, Wily1Room14
	spawn 17, 2, $31, $00
	spawn 17, 5, $51, $00
	end_spawns

Wily1Room14:	;$41DC
	room $0E, Wily1RoomRoutine, Wily1Room14Layout, $0320
	no_exit
	exit_down 18, 1, Wily1Room15
	spawn 8, 5, $62, $00
	spawn 22, 6, $50, $00
	spawn 8, 7, $64, $00
	spawn 24, 13, $60, $00
	end_spawns

Wily1Room15:	;$41FA
	room $0F, Wily1RoomRoutine, Wily1Room15Layout, $03C0
	no_exit
	exit_down 1, 8, Wily1Room16
	spawn 8, 4, $24, $00
	spawn 8, 5, $24, $00
	spawn 8, 6, $24, $00
	end_spawns

Wily1Room16:	;$4214
	room $10, Wily1RoomRoutine, Wily1Room16Layout, $03C0
	no_exit
	exit_down 1, 2, Wily1Room17
	end_spawns

Wily1Room17:	;$4222
	room $11, Wily1RoomRoutine, Wily1Room17Layout, $03C0
	no_exit
	exit_down 18, 1, Wily1Room18
	spawn 22, 4, $60, $00
	spawn 22, 7, $41, $00
	spawn 9, 9, $50, $00	;fan
	spawn 3, 16, $30, $00
	end_spawns

Wily1Room18:	;$4240
	room $12, Wily1RoomRoutine, Wily1Room2Layout, $0460
	no_exit
	exit_down 1, 1, Wily1Room19
	spawn 19, 8, $30, $00
	end_spawns

Wily1Room19:	;$4252
	room $13, Wily1RoomRoutine, Wily1Room19Layout, $0460
	no_exit
	exit_down 38, 1, Wily1Room20
	spawn 18, 5, $40, $1E
	spawn 18, 34, $41, $1E
	end_spawns

Wily1Room20:	;$4268
	room $14, Wily1RoomRoutine, Wily1Room20Layout, $0640
	no_exit
	exit_down 2, 6, Wily1Room21
	spawn 8, 1, $31, $00
	end_spawns

Wily1Room21:	;$427A
	room $15, Wily1RoomRoutine, Wily1Room21Layout, $0640
	no_exit
	exit_down 4, 2, Wily1Room22
	end_spawns

Wily1Room22:	;$4288
	room $16, Wily1RoomRoutine, Wily1Room22Layout, $0640
	no_exit
	exit_down 0, 10, Wily1Room23
	end_spawns

;The last room exits downwards into Wily 2's hub (Wily2Hub): the two stages
;are one continuous level, handed over by Wily1FrameHook and Wily2HubRoutine.	;[ok]
Wily1Room23:	;$4296
	room $17, Wily1RoomRoutine, Wily1Room23Layout, $0640
	no_exit
	exit_down 0, 10, Wily2Hub
	end_spawns

;$42A4: restart-point init and room routine - neither does anything. The third
;`ret` at $42A6 is reached by nothing.	;[ok]
Wily1StageInit:
	ret
Wily1RoomRoutine:
	ret
	ret

;$42A7: frame hook. Holds the background palette at $E4 and has the spike test.
;From room $16 on - the two shafts Mega Man drops down at the end of the stage -
;it sets $D845 to $FF and prepares the hand-over to Wily 2's teleporter hub:
;in room $16 it queues a copy of Wily 2's 76 tiles (Wily2HubTiles, kept in this
;bank) to VRAM $9000 in $40-byte chunks and clears wWilyProgress; in room $17 it
;copies the next chunk each frame with the palette blanked to $FF. The hub's
;room routine then swaps in Wily 2's blockset (Wily2HubRoutine).	;[ok]
Wily1FrameHook:
	ld a, $E4
	ld [wShadowBGP], a
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
.notSpikes
	ld a, [wRoomID]
	ld b, a
	cp $16
	jr c, .done
	ld a, $FF
	ld [$D845], a
	ld a, b
	cp $17
	jr nc, .copying
	ld hl, Wily2HubTiles
	ld de, $9000
	ld bc, Wily2HubTilesEnd - Wily2HubTiles
	ld a, $40
	call QueueTileCopy
	xor a
	ld [wWilyProgress], a
	jr .done
.copying
	call CopyQueuedTiles
	ld a, $FF
	ld [wShadowBGP], a
	jr .done
.done
	ret

Wily1Room1Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 1C 0F"
	lrow "0F 00 1E 1F 00 00 00 00 1A 0F"
	lrow "0F 09 0A 00 00 00 00 00 26 0F"
	lrow "0F 10 0F 00 1C 1C 00 00 14 0F"
	lrow "0F 12 0F 1E 24 24 1F 1E 1F 0F"
	lrow "0F 10 0F 00 1A 1A 00 00 00 0F"
	lrow "0F 09 0A 09 0A 09 0A 09 00 0F"
	end_layout

Wily1Room2Layout:	;10 x 8; also Wily1Room18
	layout 10
	lrow "0F 17 18 18 19 0F 13 0F 00 0F"
	lrow "0F 14 14 14 14 0F 12 0F 00 0F"
	lrow "0F 00 00 00 00 17 18 19 00 0F"
	lrow "0F 00 00 00 00 14 14 14 00 0F"
	lrow "0F 00 26 00 00 00 00 00 00 0F"
	lrow "0F 00 0F 00 00 00 00 00 00 0F"
	lrow "0F 00 0F 00 26 00 26 20 26 0F"
	lrow "0F 00 09 0A 09 0A 09 0A 09 0A"
	end_layout

Wily1Room3Layout:	;10 x 8
	layout 10
	lrow "0F 00 17 19 18 19 18 17 19 0F"
	lrow "0F 00 14 14 14 14 14 14 14 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 26 00 0F"
	lrow "0F 00 00 00 00 00 1C 0F 00 0F"
	lrow "0F 00 00 00 00 1E 24 0F 00 0F"
	lrow "0F 00 00 00 00 1E 24 0F 00 0F"
	lrow "0F 09 0A 09 0A 09 0A 09 00 0F"
	end_layout

Wily1Room4Layout:	;10 x 8
	layout 10
	lrow "0F 17 17 19 18 17 19 19 00 0F"
	lrow "0F 14 14 14 14 14 14 14 00 0F"
	lrow "0F 22 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 22 00 00 1C 1C 0F"
	lrow "0F 00 00 00 00 00 1E 24 24 0F"
	lrow "0F 00 00 00 1C 00 00 1A 1A 0F"
	lrow "0F 00 00 00 17 18 19 00 00 0F"
	lrow "0F 00 09 0A 09 0A 09 0A 09 0F"
	end_layout

Wily1Room5Layout:	;20 x 8
	layout 20
	lrow "0F 00 10 11 10 11 10 11 10 11 10 11 10 11 10 11 10 11 0F 0F"
	lrow "0F 00 12 13 12 13 12 13 12 13 12 13 12 13 12 13 12 13 0F 0F"
	lrow "0F 00 0D 0E 0D 0E 0D 0E 0D 0E 0D 0E 0D 0E 0D 0E 0D 0E 26 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 1F 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 1F 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 1F 0F"
	lrow "0F 26 0B 0C 0B 0C 0B 0C 0B 0C 0B 0C 0B 0C 0B 0C 0B 0C 00 0F"
	lrow "0F 0F 10 11 10 11 10 11 10 11 10 11 10 11 10 11 10 11 00 0F"
	end_layout

Wily1Room6Layout:	;10 x 8
	layout 10
	lrow "0F 17 18 17 18 17 17 19 00 0F"
	lrow "0F 17 19 17 19 19 14 14 00 0F"
	lrow "0F 17 17 19 14 14 00 1E 1F 0F"
	lrow "0F 26 14 14 00 00 00 00 00 0F"
	lrow "0F 14 00 00 00 00 00 00 00 0F"
	lrow "0F 1C 1C 1E 1D 1F 00 1C 1C 0F"
	lrow "0F 1A 1A 1E 1B 1F 00 1A 1A 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	end_layout

Wily1Room7Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 22 00 00 20 21 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 1C 1C 00 00 22 0F"
	lrow "0F 00 15 1E 24 24 1F 00 00 0F"
	lrow "0F 20 21 00 1A 1A 00 20 21 0F"
	lrow "0F 22 00 00 00 00 15 20 21 0F"
	lrow "0F 20 21 00 00 00 00 00 00 0F"
	end_layout

Wily1Room8Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 1C 1C 00 00 00 0F"
	lrow "0F 00 00 1E 08 08 1F 00 00 0F"
	lrow "0F 1C 1C 1C 0A 0A 1C 1C 1C 0F"
	lrow "0F 24 24 24 0F 0F 24 24 24 0F"
	lrow "0F 1A 1A 1A 0F 0F 1A 1A 1A 0F"
	end_layout

Wily1Room9Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 0F 0F 00 00 00 0F"
	lrow "0F 1C 1C 1C 0F 0F 00 00 00 0F"
	lrow "0F 24 24 24 0F 0F 00 00 00 0F"
	lrow "0F 1A 1A 1A 0F 0F 1E 1D 1F 0F"
	lrow "0F 00 00 00 0F 0F 1E 24 1F 0F"
	lrow "0F 00 1E 1F 0F 16 1E 1B 1F 0F"
	lrow "0F 00 1E 1F 0F 0F 00 00 00 0F"
	lrow "0F 00 00 00 0F 0F 00 00 00 0F"
	end_layout

Wily1Room10Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 0F 0F 00 00 00 0F"
	lrow "0F 00 00 00 17 19 00 00 00 0F"
	lrow "0F 00 00 00 14 14 00 00 00 0F"
	lrow "0F 00 1C 1C 1C 1C 1C 1C 00 0F"
	lrow "0F 1E 24 24 24 24 24 24 1F 0F"
	lrow "0F 00 1A 1A 1A 1A 1A 1A 00 0F"
	lrow "0F 15 15 00 00 00 00 15 15 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	end_layout

Wily1Room11Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 1C 1C 1C 00 0F"
	lrow "0F 1C 00 00 1E 24 24 24 1F 0F"
	lrow "0F 24 1F 00 1E 24 24 24 1F 0F"
	lrow "0F 24 1F 00 00 1A 1A 1A 00 0F"
	lrow "0F 24 1F 1C 1C 1C 1C 1C 1C 0F"
	lrow "0F 1A 1E 08 08 08 08 08 08 0F"
	lrow "0F 00 00 0A 0A 0A 0A 0A 0A 0F"
	end_layout

Wily1Room12Layout:	;50 x 8
	layout 50
	lrow "0F 00 00 17 19 18 19 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 0F"
	lrow "0F 00 00 14 14 14 14 17 18 19 18 19 18 17 19 18 18 17 17 18 18 19 19 18 18 17 18 18 17 18 19 18 19 18 17 18 19 19 18 17 18 19 18 17 18 18 17 17 19 0F"
	lrow "0F 00 00 00 22 22 00 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 0F"
	lrow "0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1C 1C 1C 1C 00 00 00 00 00 1C 1C 1C 1C 00 00 00 1C 1C 00 00 00 1C 1C 00 00 1C 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 1C 1C 1C 1C 00 1E 24 24 24 24 1F 00 00 00 1E 24 24 24 24 1F 00 1E 24 24 1F 00 1E 24 24 1F 1E 24 1F 00 00 09 09 1C 1C 1C 0F"
	lrow "0F 22 00 00 00 00 00 00 1E 24 24 24 24 1F 00 1A 1A 1A 1A 00 00 00 00 00 1A 1A 1A 1A 00 00 00 1A 1A 00 00 00 1A 1A 00 00 1A 00 00 00 0F 0F 24 24 24 0F"
	lrow "0F 00 00 00 00 22 00 00 00 1A 1A 1A 1A 26 00 26 00 26 00 26 00 26 00 26 00 26 00 26 00 09 0A 09 1C 1C 26 1C 1C 26 1C 1C 26 1C 09 0A 09 0A 09 1A 1A 0F"
	lrow "0F 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 08 08 26 08 08 26 08 08 26 08 0F 09 0A 09 0F 0A 00 0F"
	end_layout

Wily1Room13Layout:	;10 x 8
	layout 10
	lrow "0F 17 17 18 19 18 17 19 00 0F"
	lrow "0F 14 14 14 14 14 14 14 00 0F"
	lrow "0F 00 1C 1C 00 00 00 00 00 0F"
	lrow "0F 1E 24 24 1F 00 1C 1C 00 0F"
	lrow "0F 00 26 1A 00 1E 24 24 1F 0F"
	lrow "0F 00 0F 17 19 1E 24 24 1F 0F"
	lrow "0F 00 0F 17 17 19 19 1A 00 0F"
	lrow "0F 00 0F 09 0A 09 0A 09 0A 0F"
	end_layout

Wily1Room14Layout:	;20 x 8
	layout 20
	lrow "0F 00 17 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 19 0F"
	lrow "0F 00 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 0F"
	lrow "0F 1C 1C 1C 1C 1C 1C 1C 00 22 00 1C 1C 1C 1C 00 00 00 22 0F"
	lrow "0F 24 24 24 24 24 24 24 1F 00 00 1A 1A 1A 1A 09 0A 09 1F 0F"
	lrow "0F 24 24 24 24 24 24 24 09 0A 00 1C 1C 1C 1C 0F 0F 0F 1F 0F"
	lrow "0F 24 1B 09 0A 1B 24 24 0F 12 09 24 24 24 24 0F 0F 0F 1F 0F"
	lrow "0F 24 1F 0F 0F 1E 26 24 0F 13 0F 24 24 24 24 0F 0F 0F 1F 0F"
	lrow "0F 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 00 0F"
	end_layout

Wily1Room15Layout:	;10 x 8
	layout 10
	lrow "0F 17 18 18 19 18 18 19 1C 0F"
	lrow "0F 14 14 14 14 14 14 0F 24 0F"
	lrow "0F 1D 1D 1F 00 1E 1F 0F 24 0F"
	lrow "0F 24 24 1F 15 15 15 15 1A 0F"
	lrow "0F 1B 1B 1F 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 1C 00 00 00 00 0F"
	lrow "0F 15 1F 00 1A 00 00 15 1F 0F"
	end_layout

Wily1Room16Layout:	;10 x 8
	layout 10
	lrow "0F 00 00 00 00 00 1C 1C 00 0F"
	lrow "0F 00 00 00 00 1E 24 24 1D 0F"
	lrow "0F 00 1C 1C 00 00 1A 1A 1A 0F"
	lrow "0F 1E 24 24 1D 1F 00 00 00 0F"
	lrow "0F 00 1A 1A 1A 00 00 00 00 0F"
	lrow "0F 00 1E 1D 1D 1D 1D 26 1D 0F"
	lrow "0F 00 1E 08 08 08 08 0F 08 0F"
	lrow "0F 00 00 09 0A 09 0A 09 0A 0F"
	end_layout

Wily1Room17Layout:	;20 x 8
	layout 20
	lrow "0F 00 00 17 18 19 18 19 18 17 18 19 18 17 19 18 19 18 19 0F"
	lrow "0F 00 00 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 14 0F"
	lrow "0F 00 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 1C 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 24 24 24 24 09 0A 09 0A 24 0F"
	lrow "0F 1E 24 24 24 24 24 24 24 24 09 0A 09 0A 13 10 11 0F 1A 0F"
	lrow "0F 1E 24 24 24 24 16 16 09 0A 10 11 12 13 11 12 13 0F 00 0F"
	lrow "0F 09 0A 09 0A 09 0A 13 10 11 12 13 10 11 13 10 11 0F 00 0F"
	end_layout

Wily1Room19Layout:	;40 x 8
	layout 40
	lrow "0F 00 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 0F"
	lrow "0F 00 0D 0E 0D 0E 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 0D 0E 0D 0E 0D 0E 0D 0E 12 13 10 11 12 13 10 11 12 0F"
	lrow "0F 1E 24 24 24 24 10 11 12 13 10 11 12 0D 0E 0D 0E 0D 0E 0D 0E 0D 24 24 24 24 24 24 24 24 10 11 12 13 0D 0E 0D 0E 0D 0F"
	lrow "0F 1E 24 24 24 24 12 13 10 11 12 13 10 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 24 0D 0E 0D 0E 24 24 24 24 24 0F"
	lrow "0F 1D 24 24 24 24 0D 0E 0D 0E 0D 0E 0D 24 24 24 24 24 24 24 24 24 24 24 0B 0C 0B 0C 24 24 24 24 24 24 24 24 24 24 1B 0F"
	lrow "0F 09 0B 0C 24 24 24 24 24 24 24 24 24 24 24 0B 0C 0B 0C 0B 0C 0B 0C 0B 10 11 12 13 24 24 24 24 24 24 24 24 0B 0C 00 0F"
	lrow "0F 0F 10 11 24 24 24 24 24 24 24 24 24 24 24 11 12 13 10 11 12 13 10 11 12 13 10 11 0B 0C 0B 0C 0B 0C 0B 0C 12 13 00 0F"
	lrow "0F 0F 12 13 0B 0C 0B 0C 0B 0C 0B 0C 0B 0C 0B 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 12 13 10 11 00 0F"
	end_layout

Wily1Room20Layout:	;10 x 8
	layout 10
	lrow "0F 17 17 19 18 17 19 19 00 0F"
	lrow "0F 14 14 14 14 14 14 14 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 00 00 00 00 00 00 00 00 0F"
	lrow "0F 26 00 00 00 00 00 00 26 0F"
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	end_layout

Wily1Room21Layout:	;10 x 8
	layout 10
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	lrow "0F 0F 00 00 00 00 00 00 0F 0F"
	lrow "0F 0F 1C 1C 00 00 1C 1C 0F 0F"
	lrow "0F 0F 08 08 1F 1E 08 08 0F 0F"
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	end_layout

Wily1Room22Layout:	;10 x 8
	layout 10
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	lrow "0F 0F 0F 0F 00 00 0F 0F 0F 0F"
	lrow "14 14 14 14 00 00 14 14 14 14"
	lrow "00 00 00 00 00 00 00 00 00 00"
	lrow "23 23 23 23 23 23 23 23 23 23"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	end_layout

Wily1Room23Layout:	;10 x 8
	layout 10
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	lrow "25 25 25 25 25 25 25 25 25 25"
	end_layout

;39 blocks: block top left, top right, bottom left, bottom right.	;[ok]
Wily1Blocks:
	blockset Wily1
	block $2D, $2D, $2D, $2D	;$00
	block $2E, $2F, $2E, $2F	;$01
	block $2E, $2F, $2E, $2F	;$02
	block $78, $79, $78, $79	;$03
	block $18, $7C, $1A, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $18, $62, $1A, $1B	;$06
	block $63, $64, $1A, $1B	;$07
	block $74, $75, $76, $77	;$08
	block $00, $01, $04, $05	;$09
	block $02, $03, $06, $07	;$0A
	block $08, $09, $0C, $0D	;$0B
	block $0A, $0B, $0E, $0F	;$0C
	block $10, $11, $14, $15	;$0D
	block $12, $13, $16, $17	;$0E
	block $18, $19, $1A, $1B	;$0F
	block $1C, $1D, $20, $21	;$10
	block $1E, $1F, $22, $23	;$11
	block $24, $25, $28, $29	;$12
	block $26, $27, $2A, $2B	;$13
	block $2C, $2C, $2D, $2D	;$14
	block $02, $03, $2C, $2C	;$15
	block $30, $31, $32, $33	;$16
	block $34, $35, $36, $37	;$17
	block $35, $35, $37, $37	;$18
	block $35, $38, $37, $39	;$19
	block $3C, $3D, $3A, $3B	;$1A
	block $70, $70, $3D, $3C	;$1B
	block $3A, $3B, $3E, $3F	;$1C
	block $3F, $3E, $70, $70	;$1D
	block $2D, $3E, $2D, $3C	;$1E
	block $3F, $2D, $3D, $2D	;$1F
	block $2D, $3A, $2D, $3A	;$20
	block $3B, $2D, $3B, $2D	;$21
	block $40, $41, $42, $43	;$22
	block $44, $45, $46, $47	;$23
	block $70, $70, $70, $70	;$24
	block $73, $73, $73, $73	;$25
	block $34, $38, $36, $39	;$26

;One collision byte per block.	;[ok]
Wily1Collision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $00, $02, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $03
Wily1CollisionEnd:
