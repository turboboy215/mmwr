;Elec Man - StageLoadTab index 3, bank $05.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank05.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
ElecManStageData:	;$5F72 [dc]
	dw ElecManRestartPoints
	dw ElecManCheckpoints

;Restart point 0 is the stage start; n is the room checkpoint n names.	;[ok]
ElecManRestartPoints:
	dw ElecManRestart0
	dw ElecManRestart1
	dw ElecManRestart2

;Entering one of these rooms makes it the restart point (UpdateRestartPoint).	;[ok]
ElecManCheckpoints:
	checkpoint $07, $04	;-> restart point 1, ElecManRoom7
	checkpoint $12, $04	;-> restart point 2, ElecManRoom18
	end_checkpoints

;restart_point blockset, collision, init, frame hook, x, y, room	;[ok]
ElecManRestart0:
	restart_point ElecManBlocks, ElecManCollision, ElecManStageInit, ElecManFrameHook, $0047, $33, ElecManRoom1
ElecManRestart1:
	restart_point ElecManBlocks, ElecManCollision, ElecManStageInit, ElecManFrameHook, $0047, $33, ElecManRoom7
ElecManRestart2:
	restart_point ElecManBlocks, ElecManCollision, ElecManStageInit, ElecManFrameHook, $0087, $33, ElecManRoom18

ElecManRoom1:
	room $01, ElecManRoomRoutine, ElecManRoom1Layout, $0000
	no_exit
	exit_up 18, 1, ElecManRoom2
	spawn 9, 7, $60, $00	;fan
	spawn 20, 14, $61, $00	;appearing block
	end_spawns

ElecManRoom2:
	room $02, ElecManRoomRoutine, ElecManRoom2Layout, $00A0
	exit_down 6, 3, ElecManRoom1
	exit_up 8, 1, ElecManRoom3
	spawn 22, 2, $40, $00
	spawn 22, 5, $51, $00
	end_spawns

ElecManRoom3:
	room $03, ElecManRoomRoutine, ElecManRoom3Layout, $00A0
	exit_down 1, 8, ElecManRoom2
	exit_up 1, 1, ElecManRoom4
	spawn 20, 5, $62, $00	;appearing block
	end_spawns

ElecManRoom4:
	room $04, ElecManRoomRoutine, ElecManRoom4Layout, $00A0
	exit_down 1, 8, ElecManRoom3
	exit_up 8, 1, ElecManRoom5
	spawn 22, 3, $51, $00
	spawn 22, 7, $40, $00
	end_spawns

ElecManRoom5:
	room $05, ElecManRoomRoutine, ElecManRoom5Layout, $00A0
	exit_down 1, 8, ElecManRoom4
	exit_up 1, 1, ElecManRoom6
	spawn 9, 1, $41, $00	;fan
	spawn 20, 1, $65, $00	;appearing block
	end_spawns

ElecManRoom6:
	room $06, ElecManRoomRoutine, ElecManRoom6Layout, $00A0
	exit_down 1, 1, ElecManRoom5
	exit_up 1, 1, ElecManRoom7
	spawn 21, 1, $24, $00
	spawn 21, 4, $30, $00
	spawn 21, 5, $61, $00
	spawn 21, 7, $35, $00
	end_spawns

ElecManRoom7:
	room $07, ElecManRoomRoutine, ElecManRoom7Layout, $00A0
	exit_down 1, 1, ElecManRoom6
	exit_up 28, 1, ElecManRoom8
	spawn 15, 13, $50, $00
	spawn 15, 19, $60, $00
	spawn 15, 25, $40, $00
	end_spawns

ElecManRoom8:
	room $08, ElecManRoomRoutine, ElecManRoom8Layout, $01E0
	exit_down 7, 3, ElecManRoom7
	exit_up 1, 1, ElecManRoom9
	spawn 21, 6, $65, $00
	spawn 21, 8, $41, $00
	spawn 21, 1, $20, $00
	spawn 20, 4, $44, $00	;appearing block
	end_spawns

ElecManRoom9:
	room $09, ElecManRoomRoutine, ElecManRoom9Layout, $01E0
	exit_down 1, 5, ElecManRoom8
	exit_up 8, 1, ElecManRoom10
	spawn 22, 3, $31, $00
	end_spawns

ElecManRoom10:
	room $0A, ElecManRoomRoutine, ElecManRoom10Layout, $01E0
	exit_down 0, 10, ElecManRoom9
	exit_up 1, 1, ElecManRoom11
	spawn 21, 4, $55, $00
	spawn 21, 5, $11, $00
	end_spawns

ElecManRoom11:
	room $0B, ElecManRoomRoutine, ElecManRoom11Layout, $01E0
	exit_down 1, 1, ElecManRoom10
	exit_up 8, 1, ElecManRoom12
	spawn 9, 8, $40, $00	;fan
	spawn 22, 2, $31, $00
	spawn 22, 6, $31, $00
	end_spawns

ElecManRoom12:
	room $0C, ElecManRoomRoutine, ElecManRoom12Layout, $01E0
	exit_down 0, 10, ElecManRoom11
	exit_up 1, 1, ElecManRoom13
	spawn 17, 3, $40, $00
	spawn 17, 5, $40, $00
	end_spawns

ElecManRoom13:
	room $0D, ElecManRoomRoutine, ElecManRoom13Layout, $01E0
	exit_down 1, 1, ElecManRoom12
	exit_up 1, 1, ElecManRoom14
	spawn 20, 4, $43, $00	;appearing block
	spawn 21, 1, $34, $00
	spawn 21, 4, $65, $00
	spawn 21, 7, $11, $00
	end_spawns

ElecManRoom14:
	room $0E, ElecManRoomRoutine, ElecManRoom14Layout, $01E0
	exit_down 1, 1, ElecManRoom13
	exit_up 1, 1, ElecManRoom15
	spawn 22, 2, $20, $00
	spawn 22, 2, $50, $00
	end_spawns

ElecManRoom15:
	room $0F, ElecManRoomRoutine, ElecManRoom14Layout, $01E0
	exit_down 1, 1, ElecManRoom14
	exit_up 1, 1, ElecManRoom16
	spawn 21, 1, $10, $00
	spawn 21, 3, $34, $00
	spawn 21, 1, $54, $00
	end_spawns

ElecManRoom16:
	room $10, ElecManRoomRoutine, ElecManRoom14Layout, $01E0
	exit_down 1, 1, ElecManRoom15
	exit_up 1, 1, ElecManRoom17
	spawn 22, 2, $20, $00
	spawn 22, 2, $50, $00
	end_spawns

ElecManRoom17:
	room $11, ElecManRoomRoutine, ElecManRoom17Layout, $01E0
	exit_down 1, 1, ElecManRoom16
	exit_down 28, 1, ElecManRoom18
	spawn 6, 9, $50, $00
	spawn 17, 14, $60, $00
	spawn 17, 25, $50, $00
	end_spawns

ElecManRoom18:
	room $12, ElecManRoomRoutine, ElecManRoom18Layout, $0320
	exit_up 8, 1, ElecManRoom17
	exit_down 1, 1, ElecManRoom19
	spawn 55, 5, $30, $00	;boss door (Will)
	end_spawns

ElecManRoom19:
	room $13, ElecManRoomRoutine, ElecManRoom19Layout, $0320
	no_exit
	no_exit
	spawn 34, 8, $00, $00
	spawn 37, 9, $00, $00	;Fire Storm (Will)
	end_spawns

;Restart-point init: nothing.	;[ok]
ElecManStageInit:
	ret

;Room routine: set bit 7 of $D3ED if the room has any behind-background zones
;in ElecManBehindBGZones, clear it if not. $D3ED bit 7 goes into every object's
;OAM attributes (BeginSpriteFrame), so in such a room the enemies are drawn behind
;background colours 1-3.	;[ok]
ElecManRoomRoutine:
	ld a, [wRoomID]
	ld e, a
	ld d, $00
	ld hl, ElecManBehindBGZones
	add hl, de
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [hl+]
	and [hl]
	cp $FF
	ld a, $00
	jr z, .store
	ld a, $80
.store
	ld [$D3ED], a
	ret

;Frame hook. Holds the background palette at $C6.
;Block 8 (spikes) sets $D838 to $14, as in Ice Man's hook. Then it sets or
;clears bit 7 of $D80B - the attribute byte bank $01 gives Mega Man's sprites,
;so bit 7 puts him behind the background - by whether his position is inside
;one of the room's zones. It tests twice, the second time with a Y of $F0 or
;more (just above the top of the room) treated as 0; the second answer wins.	;[ok]
ElecManFrameHook:
	ld a, $C6
	ld [wShadowBGP], a
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
.notSpikes
	ld a, [$D80D]
	ldh [$FF92], a
	ld a, [$D80E]
	ldh [$FF93], a
	ld a, [wPlayerY]
	ldh [$FF94], a
	ld a, [$D80B]
	call ElecManZoneTest
	ld [$D80B], a
	ld a, [$D80D]
	ldh [$FF92], a
	ld a, [$D80E]
	ldh [$FF93], a
	ld a, [wPlayerY]
	cp $F0
	jr c, .yOK
	xor a
.yOK
	ldh [$FF94], a
	ld a, [$D80B]
	call ElecManZoneTest
	ld [$D80B], a
	ret

;Return A with bit 7 set if X ($FF92-$FF93) and Y ($FF94) are inside one of
;the current room's zones, clear otherwise. A zone is dw left, dw right,
;db top, db bottom - left and top inclusive, right and bottom exclusive - and
;a list ends with $FFFF.	;[ok]
ElecManZoneTest:
	and $7F
	ldh [hBank1CallIndex], a	;used here as scratch
	ld a, [wRoomID]
	ld e, a
	ld d, $00
	ld hl, ElecManBehindBGZones
	add hl, de
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ldh a, [$FF92]
	ld e, a
	ldh a, [$FF93]
	ld d, a
	ldh a, [$FF94]
	ld b, a
.zone
	ld a, [hl+]
	ld c, a
	and [hl]
	cp $FF
	jr z, .outside
	ld a, e
	sub c
	ld a, d
	sbc a, [hl]
	jr c, .skip5
	inc hl
	ld a, e
	sub [hl]
	inc hl
	ld a, d
	sbc a, [hl]
	jr nc, .skip3
	inc hl
	ld a, b
	cp [hl]
	jr c, .skip2
	inc hl
	cp [hl]
	jr nc, .skip1
	ldh a, [hBank1CallIndex]
	or $80
	jr .done
.skip5
	inc hl
	inc hl
.skip3
	inc hl
.skip2
	inc hl
.skip1
	inc hl
	jr .zone
.outside
	ldh a, [hBank1CallIndex]
.done
	ret

ElecManZonesRoom07:	;$6256
	dw $0000, $0140	;x
	db $00, $50	;y
	dw $00A0, $01D0	;x
	db $4A, $90	;y
	dw $FFFF
ElecManZonesRoom09:	;$6264
	dw $0000, $0078	;x
	db $00, $50	;y
	dw $FFFF
ElecManZonesRoom0A:	;$626C
	dw $0030, $00A0	;x
	db $10, $50	;y
	dw $FFFF
ElecManZonesRoom0B:	;$6274
	dw $0000, $0050	;x
	db $00, $50	;y
	dw $FFFF
ElecManZonesRoom0C:	;$627C
	dw $0070, $00A0	;x
	db $10, $50	;y
	dw $0000, $0050	;x
	db $60, $80	;y
	dw $FFFF
ElecManZonesRoom11:	;$628A
	dw $0000, $00F0	;x
	db $00, $70	;y
	dw $FFFF

;Behind-background zones per room id, for ElecManRoomRoutine and ElecManZoneTest.
;Id 0 is never a room, so its slot holds the $FFFF that ends a list and every
;room without zones points here.	;[ok]
ElecManBehindBGZones:
	dw $FFFF	;id 0, and the empty list
	dw ElecManBehindBGZones	;id $01: none
	dw ElecManBehindBGZones	;id $02: none
	dw ElecManBehindBGZones	;id $03: none
	dw ElecManBehindBGZones	;id $04: none
	dw ElecManBehindBGZones	;id $05: none
	dw ElecManBehindBGZones	;id $06: none
	dw ElecManZonesRoom07	;id $07
	dw ElecManBehindBGZones	;id $08: none
	dw ElecManZonesRoom09	;id $09
	dw ElecManZonesRoom0A	;id $0A
	dw ElecManZonesRoom0B	;id $0B
	dw ElecManZonesRoom0C	;id $0C
	dw ElecManBehindBGZones	;id $0D: none
	dw ElecManBehindBGZones	;id $0E: none
	dw ElecManBehindBGZones	;id $0F: none
	dw ElecManBehindBGZones	;id $10: none
	dw ElecManZonesRoom11	;id $11
	dw ElecManBehindBGZones	;id $12: none
	dw ElecManBehindBGZones	;id $13: none

ElecManRoom1Layout:	;20 x 8
	layout 20
	lrow "09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 09 0A 00 00 01 16"
	lrow "16 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 00 00 01 16"
	lrow "16 0D 00 00 0D 00 00 00 00 00 00 00 00 00 00 00 00 00 01 16"
	lrow "16 0F 00 00 0F 00 00 0E 10 10 0D 0E 10 10 10 10 10 0D 01 16"
	lrow "16 0F 00 00 0E 0D 00 00 00 00 0F 00 00 00 00 00 00 0F 00 16"
	lrow "16 0E 10 10 10 0D 00 00 00 00 0F 00 00 00 00 00 00 0E 10 16"
	lrow "16 00 00 00 00 0E 10 10 11 14 0E 10 10 10 10 10 10 10 15 16"
	lrow "11 12 13 12 13 12 13 14 09 0A 08 08 08 08 08 08 08 08 11 14"
	end_layout

ElecManRoom2Layout:	;10 x 8
	layout 10
	lrow "16 00 00 00 00 00 00 00 01 16"
	lrow "16 0E 0D 00 00 00 00 00 01 16"
	lrow "16 00 0E 10 10 10 0D 00 00 16"
	lrow "16 00 0D 00 00 00 0E 10 10 16"
	lrow "17 00 0F 00 0C 0C 0D 00 0C 16"
	lrow "16 0C 0F 00 00 00 0F 00 00 16"
	lrow "16 00 0E 10 10 0D 0E 10 10 16"
	lrow "11 12 13 12 14 17 00 00 02 16"
	end_layout

ElecManRoom3Layout:	;10 x 8
	layout 10
	lrow "16 01 0C 0C 00 00 00 00 00 16"
	lrow "16 01 0E 10 10 10 0D 00 00 16"
	lrow "16 01 00 00 00 00 0F 00 00 16"
	lrow "16 00 0D 00 00 00 0E 0D 00 16"
	lrow "16 0C 0F 00 00 00 00 0E 0D 16"
	lrow "16 00 0E 0D 00 00 00 00 0E 16"
	lrow "16 00 00 0E 10 10 10 10 10 16"
	lrow "16 00 00 00 00 00 00 00 02 16"
	end_layout

ElecManRoom4Layout:	;10 x 8
	layout 10
	lrow "16 00 0D 00 00 00 00 00 01 16"
	lrow "16 00 0F 00 00 00 00 00 01 16"
	lrow "16 0D 0F 00 00 00 00 00 01 16"
	lrow "16 0E 0D 00 0E 0D 00 00 01 16"
	lrow "16 00 0F 00 00 0E 10 10 00 17"
	lrow "16 00 0E 0D 00 15 00 00 15 16"
	lrow "16 00 00 0F 00 0B 00 00 0B 16"
	lrow "16 02 15 17 00 00 00 00 0E 16"
	end_layout

ElecManRoom5Layout:	;10 x 8
	layout 10
	lrow "16 01 0C 0C 0C 0C 0C 0C 0C 16"
	lrow "16 01 0D 00 00 00 00 0D 00 16"
	lrow "16 01 0E 10 0D 00 00 0E 10 16"
	lrow "16 00 00 00 0E 10 0D 00 00 16"
	lrow "16 00 00 0D 00 00 0E 10 0D 16"
	lrow "16 15 00 0F 00 00 00 00 02 16"
	lrow "16 0B 00 0E 10 10 0D 00 01 16"
	lrow "16 00 00 00 00 00 0E 10 01 16"
	end_layout

ElecManRoom6Layout:	;10 x 8
	layout 10
	lrow "16 01 0C 0C 0C 0C 0C 0C 0C 16"
	lrow "16 01 00 00 00 00 00 00 00 16"
	lrow "16 01 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 0C 0C 0C 0C 0C 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 0C 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "15 02 11 12 13 12 13 12 13 14"
	end_layout

ElecManRoom7Layout:	;30 x 8
	layout 30
	lrow "19 19 19 19 19 19 23 22 19 19 23 25 18 18 24 22 19 19 23 25 18 18 18 18 18 18 18 18 01 18"
	lrow "19 19 19 19 19 2C 2D 2A 2B 2C 2D 18 18 18 18 2A 2B 2C 2D 18 18 18 18 18 18 18 18 18 01 18"
	lrow "22 23 22 23 25 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 01 18"
	lrow "20 21 20 21 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 1A 1B 18 18 18 18 18 18 18 18 18 18 18 18 18 15 18"
	lrow "15 02 11 12 13 12 13 12 13 14 18 18 1E 1C 1D 1F 18 18 18 18 1A 1B 18 18 18 18 1E 1F 18 18"
	lrow "0A 01 0A 09 0A 09 0A 09 0A 09 26 27 19 19 19 19 28 29 18 1E 1C 1D 1F 18 26 27 19 19 28 29"
	end_layout

ElecManRoom8Layout:	;10 x 8
	layout 10
	lrow "16 01 00 00 00 00 0C 0C 0C 16"
	lrow "16 01 00 00 00 0D 00 00 00 16"
	lrow "16 00 00 00 0D 0E 10 10 0D 16"
	lrow "16 0D 00 00 0E 15 0C 0C 0F 16"
	lrow "16 0F 00 00 00 16 00 00 0E 16"
	lrow "16 0E 10 10 10 16 00 0C 0C 16"
	lrow "16 08 08 08 08 16 00 00 00 16"
	lrow "09 0A 09 0A 09 0A 11 14 02 16"
	end_layout

ElecManRoom9Layout:	;10 x 8
	layout 10
	lrow "18 18 18 18 18 18 18 18 01 18"
	lrow "1A 1B 18 18 18 1E 1F 18 01 18"
	lrow "1C 1D 1F 18 18 24 25 18 01 18"
	lrow "22 23 25 18 18 18 18 18 01 18"
	lrow "20 21 18 18 18 18 18 18 01 18"
	lrow "18 18 18 17 18 18 18 18 01 18"
	lrow "18 18 18 18 18 18 18 18 18 18"
	lrow "15 02 18 18 18 18 11 12 13 14"
	end_layout

ElecManRoom10Layout:	;10 x 8
	layout 10
	lrow "09 01 09 0A 09 0A 09 0A 09 0A"
	lrow "18 01 18 18 18 18 1A 1B 18 18"
	lrow "18 01 18 18 18 1E 1C 1D 1F 18"
	lrow "18 01 18 18 18 24 22 23 25 18"
	lrow "18 01 18 18 18 18 20 21 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18"
	lrow "18 15 18 18 11 14 18 18 02 18"
	lrow "18 18 18 18 18 18 18 18 01 18"
	end_layout

ElecManRoom11Layout:	;10 x 8
	layout 10
	lrow "19 19 19 2C 2D 18 18 18 01 18"
	lrow "22 23 25 18 18 18 18 18 01 18"
	lrow "20 21 18 18 18 18 18 18 01 18"
	lrow "18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 15"
	lrow "15 02 17 2E 15 2E 17 2E 15 0A"
	lrow "0A 01 0A 08 0A 08 0A 08 0A 09"
	lrow "09 01 09 0A 09 0A 09 0A 09 0A"
	end_layout

ElecManRoom12Layout:	;10 x 8
	layout 10
	lrow "09 01 09 0A 09 0A 09 0A 09 0A"
	lrow "18 01 18 18 18 18 18 18 1A 1B"
	lrow "18 01 18 18 18 18 18 1E 1C 1D"
	lrow "18 01 18 18 18 18 18 24 22 23"
	lrow "18 18 18 18 18 18 18 18 20 21"
	lrow "18 15 18 15 18 15 18 18 02 18"
	lrow "1F 1E 1F 18 18 18 18 18 01 18"
	lrow "19 19 19 28 29 18 18 18 01 18"
	end_layout

ElecManRoom13Layout:	;10 x 8
	layout 10
	lrow "16 01 0C 0C 0C 0C 0C 0C 0C 16"
	lrow "16 01 00 00 00 00 00 00 00 16"
	lrow "16 01 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 0C 0C 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "15 02 11 12 13 12 13 12 13 14"
	end_layout

ElecManRoom14Layout:	;10 x 8; also ElecManRoom15, ElecManRoom16
	layout 10
	lrow "16 01 0C 0C 16 0A 09 0A 09 0A"
	lrow "16 01 00 00 16 09 0A 09 0A 09"
	lrow "17 01 00 00 17 0A 09 0A 09 0A"
	lrow "16 01 00 00 16 09 0A 09 0A 09"
	lrow "16 01 00 00 16 0A 09 0A 09 0A"
	lrow "17 01 00 00 17 09 0A 09 0A 09"
	lrow "16 01 00 00 16 0A 09 0A 09 0A"
	lrow "16 01 11 12 14 09 0A 09 0A 09"
	end_layout

ElecManRoom17Layout:	;30 x 8
	layout 30
	lrow "19 19 19 19 19 19 19 19 19 2C 2D 18 24 22 23 25 18 24 22 19 19 23 22 23 25 24 22 23 25 18"
	lrow "25 24 22 19 19 23 22 23 25 18 18 18 18 20 21 18 18 18 2A 2B 2C 2D 20 21 18 18 20 21 18 18"
	lrow "18 18 2A 2B 2C 2D 20 21 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18"
	lrow "18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 18 11 12 13 14 11 12 13 12 13 12 14 16 00 16"
	lrow "15 02 11 12 13 12 13 12 13 12 13 12 13 12 13 14 09 0A 09 0A 0A 09 0A 09 0A 09 0A 16 00 16"
	end_layout

ElecManRoom18Layout:	;10 x 8
	layout 10
	lrow "16 09 0A 09 0A 09 0A 16 00 16"
	lrow "16 09 0A 09 0A 04 05 16 00 16"
	lrow "16 09 0A 09 0A 06 07 16 00 16"
	lrow "16 0B 0B 0B 0B 0B 0B 0B 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 11 12 13 12 13 12 14 16"
	end_layout

ElecManRoom19Layout:	;10 x 8
	layout 10
	lrow "16 00 09 0A 09 0A 09 0A 09 16"
	lrow "16 00 0B 0B 0B 0B 0B 0B 0B 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "16 00 00 00 00 00 00 00 00 16"
	lrow "11 12 13 12 13 12 13 12 13 14"
	end_layout

;48 blocks: block top left, top right, bottom left, bottom right (tile numbers).	;[ok]
ElecManBlocks:
	blockset ElecMan
	block $08, $09, $0A, $0B	;$00
	block $3E, $3F, $3E, $3F	;$01
	block $3E, $3F, $3E, $3F	;$02
	block $78, $79, $78, $79	;$03
	block $18, $7C, $1A, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $18, $62, $1A, $1B	;$06
	block $63, $64, $1E, $1F	;$07
	block $40, $40, $41, $41	;$08
	block $18, $19, $1A, $1B	;$09
	block $1C, $1D, $1E, $1F	;$0A
	block $20, $21, $0A, $0B	;$0B
	block $1C, $1D, $22, $23	;$0C
	block $0C, $0D, $0E, $0F	;$0D
	block $10, $11, $12, $13	;$0E
	block $14, $09, $15, $0B	;$0F
	block $08, $09, $16, $17	;$10
	block $04, $06, $1A, $1B	;$11
	block $07, $06, $1E, $1F	;$12
	block $06, $06, $1A, $1B	;$13
	block $06, $05, $1E, $1F	;$14
	block $04, $05, $1E, $1F	;$15
	block $00, $01, $02, $03	;$16
	block $24, $25, $26, $27	;$17
	block $70, $70, $70, $70	;$18
	block $72, $72, $72, $72	;$19
	block $70, $70, $70, $2A	;$1A
	block $70, $70, $2B, $70	;$1B
	block $2C, $2D, $72, $72	;$1C
	block $2E, $2F, $72, $72	;$1D
	block $70, $70, $30, $31	;$1E
	block $70, $70, $32, $33	;$1F
	block $70, $3C, $70, $70	;$20
	block $3D, $70, $70, $70	;$21
	block $72, $72, $38, $39	;$22
	block $72, $72, $3A, $3B	;$23
	block $34, $35, $70, $70	;$24
	block $36, $37, $70, $70	;$25
	block $70, $70, $70, $30	;$26
	block $70, $2C, $31, $72	;$27
	block $2F, $70, $72, $32	;$28
	block $70, $70, $33, $70	;$29
	block $70, $34, $70, $70	;$2A
	block $35, $72, $70, $38	;$2B
	block $72, $36, $3B, $70	;$2C
	block $37, $70, $70, $70	;$2D
	block $42, $42, $43, $43	;$2E
	block $78, $79, $78, $79	;$2F

;One collision byte per block. LoadRestartPoint copies 64 bytes whatever the
;count, so the copy runs on into whatever follows.	;[ok]
ElecManCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $00, $02, $00, $00, $00
	db $00, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03
ElecManCollisionEnd:
