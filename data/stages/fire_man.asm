;Fire Man - StageLoadTab index 4, bank $05.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank05.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
FireManStageData:	;$525A [dc]
	dw FireManRestartPoints
	dw FireManCheckpoints

;Restart point 0 is the stage start; n is the room checkpoint n names.	;[ok]
FireManRestartPoints:
	dw FireManRestart0
	dw FireManRestart1
	dw FireManRestart2

;Entering one of these rooms makes it the restart point (UpdateRestartPoint).	;[ok]
FireManCheckpoints:
	checkpoint $05, $04	;-> restart point 1, FireManRoom5
	checkpoint $0C, $04	;-> restart point 2, FireManRoom12
	end_checkpoints

;restart_point blockset, collision, init, frame hook, x, y, room	;[ok]
FireManRestart0:
	restart_point FireManBlocks, FireManCollision, FireManStageInit, FireManFrameHook, $0047, $33, FireManRoom1
FireManRestart1:
	restart_point FireManBlocks, FireManCollision, FireManStageInit, FireManFrameHook, $0047, $33, FireManRoom5
FireManRestart2:
	restart_point FireManBlocks, FireManCollision, FireManStageInit, FireManFrameHook, $0080, $33, FireManRoom12

FireManRoom1:
	room $01, FireManRoomRoutine, FireManRoom1Layout, $0000
	no_exit
	exit_down 18, 1, FireManRoom2
	spawn 21, 10, $21, $00
	spawn 21, 12, $45, $00
	spawn 21, 14, $21, $00
	spawn 21, 16, $45, $00
	end_spawns

FireManRoom2:
	room $02, FireManRoomRoutine, FireManRoom2Layout, $00A0
	exit_up 8, 1, FireManRoom1
	exit_down 1, 1, FireManRoom3
	spawn 21, 1, $44, $00
	spawn 21, 1, $54, $00
	spawn 21, 2, $21, $00
	spawn 21, 5, $25, $00
	end_spawns

FireManRoom3:
	room $03, FireManRoomRoutine, FireManRoom3Layout, $00A0
	exit_up 1, 1, FireManRoom2
	exit_down 38, 1, FireManRoom4
	spawn 11, 5, $00, $00
	spawn 11, 8, $00, $00
	spawn 11, 11, $00, $00
	spawn 7, 14, $00, $00
	spawn 10, 15, $60, $00
	spawn 7, 17, $02, $00
	spawn 7, 21, $01, $00
	spawn 4, 22, $50, $00
	spawn 7, 26, $00, $00
	spawn 10, 28, $50, $00
	spawn 7, 29, $02, $00
	spawn 7, 32, $00, $00
	spawn 7, 36, $02, $00
	spawn 7, 37, $00, $00
	end_spawns

FireManRoom4:
	room $04, FireManRoomRoutine, FireManRoom4Layout, $0280
	exit_up 8, 1, FireManRoom3
	exit_down 1, 1, FireManRoom5
	spawn 11, 5, $00, $00
	end_spawns

FireManRoom5:
	room $05, FireManRoomRoutine, FireManRoom5Layout, $0280
	exit_up 1, 1, FireManRoom4
	exit_up 38, 1, FireManRoom6
	spawn 12, 11, $50, $00
	spawn 12, 20, $40, $00
	spawn 4, 29, $50, $00
	spawn 12, 37, $50, $00
	end_spawns

FireManRoom6:
	room $06, FireManRoomRoutine, FireManRoom6Layout, $0460
	exit_down 8, 1, FireManRoom5
	exit_up 1, 1, FireManRoom7
	spawn 4, 4, $40, $00
	end_spawns

FireManRoom7:
	room $07, FireManRoomRoutine, FireManRoom7Layout, $0460
	exit_down 1, 1, FireManRoom6
	exit_down 78, 1, FireManRoom8
	spawn 2, 6, $60, $00
	spawn 8, 7, $32, $00
	spawn 2, 10, $53, $00
	spawn 2, 12, $60, $00
	spawn 10, 17, $51, $00
	spawn 11, 26, $00, $00
	spawn 21, 29, $21, $00
	spawn 11, 31, $00, $00
	spawn 21, 32, $21, $00
	spawn 11, 34, $00, $00
	spawn 10, 36, $60, $00
	spawn 12, 46, $40, $00
	spawn 2, 55, $40, $00
	spawn 2, 57, $30, $00
	spawn 7, 65, $00, $00
	spawn 7, 69, $01, $00
	spawn 7, 72, $02, $00
	spawn 7, 75, $01, $00
	spawn 7, 78, $00, $00
	end_spawns

FireManRoom8:
	room $08, FireManRoomRoutine, FireManRoom8Layout, $08C0
	exit_up 8, 1, FireManRoom7
	exit_down 1, 1, FireManRoom9
	spawn 10, 3, $53, $00
	end_spawns

FireManRoom9:
	room $09, FireManRoomRoutine, FireManRoom9Layout, $08C0
	exit_up 1, 1, FireManRoom8
	exit_down 8, 1, FireManRoom10
	spawn 10, 3, $53, $00
	end_spawns

FireManRoom10:
	room $0A, FireManRoomRoutine, FireManRoom10Layout, $08C0
	exit_up 8, 1, FireManRoom9
	exit_down 1, 1, FireManRoom11
	spawn 12, 3, $40, $00
	end_spawns

FireManRoom11:
	room $0B, FireManRoomRoutine, FireManRoom11Layout, $08C0
	exit_up 1, 1, FireManRoom10
	exit_down 38, 1, FireManRoom12
	spawn 12, 11, $50, $00
	spawn 12, 19, $40, $00
	spawn 12, 28, $50, $00
	spawn 12, 37, $50, $00
	end_spawns

FireManRoom12:
	room $0C, FireManRoomRoutine, FireManRoom12Layout, $0AA0
	exit_up 8, 1, FireManRoom11
	exit_down 1, 1, FireManRoom13
	spawn 55, 5, $30, $00	;boss door (Will)
	end_spawns

FireManRoom13:
	room $0D, FireManRoomRoutine, FireManRoom13Layout, $0AA0
	no_exit
	no_exit
	spawn 36, 8, $00, $00
	spawn 37, 9, $00, $00	;Fire Storm (Will)
	end_spawns

;Restart-point init: nothing.	;[ok]
FireManStageInit:
	ret

;Room routine: set bit 7 of $D3ED if the room has any behind-background zones
;in FireManBehindBGZones, clear it if not. $D3ED bit 7 goes into every object's
;OAM attributes (BeginSpriteFrame), so in such a room the enemies are drawn behind
;background colours 1-3.	;[ok]
FireManRoomRoutine:
	ld a, [wRoomID]
	ld e, a
	ld d, $00
	ld hl, FireManBehindBGZones
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

;Frame hook. Flickers the background palette $4F, $4B, $47, $4B
;in 4-frame steps (counter $DCD0) unless $DFB1 is set.
;Block 8 (spikes) sets $D838 to $14, as in Ice Man's hook. Then it sets or
;clears bit 7 of $D80B - the attribute byte bank $01 gives Mega Man's sprites,
;so bit 7 puts him behind the background - by whether his position is inside
;one of the room's zones. It tests twice, the second time with a Y of $F0 or
;more (just above the top of the room) treated as 0; the second answer wins.	;[ok]
FireManFrameHook:
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
	ld a, $4B
	jr .setBGP
.phaseA2
	ld a, $47
	jr .setBGP
.phaseB
	ld a, [hl]
	and $04
	jr z, .phaseB2
	ld a, $4B
	jr .setBGP
.phaseB2
	ld a, $4F
.setBGP
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
	call FireManZoneTest
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
	call FireManZoneTest
	ld [$D80B], a
	ret

;Return A with bit 7 set if X ($FF92-$FF93) and Y ($FF94) are inside one of
;the current room's zones, clear otherwise. A zone is dw left, dw right,
;db top, db bottom - left and top inclusive, right and bottom exclusive - and
;a list ends with $FFFF.	;[ok]
FireManZoneTest:
	and $7F
	ldh [hBank1CallIndex], a	;used here as scratch
	ld a, [wRoomID]
	ld e, a
	ld d, $00
	ld hl, FireManBehindBGZones
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

;Behind-background zones per room id, for FireManRoomRoutine and FireManZoneTest.
;Id 0 is never a room, so its slot holds the $FFFF that ends a list and every
;room without zones points here.	;[ok]
FireManBehindBGZones:
	dw $FFFF	;id 0, and the empty list
	dw FireManBehindBGZones	;id $01: none
	dw FireManBehindBGZones	;id $02: none
	dw FireManBehindBGZones	;id $03: none
	dw FireManBehindBGZones	;id $04: none
	dw FireManBehindBGZones	;id $05: none
	dw FireManBehindBGZones	;id $06: none
	dw FireManBehindBGZones	;id $07: none
	dw FireManBehindBGZones	;id $08: none
	dw FireManBehindBGZones	;id $09: none
	dw FireManBehindBGZones	;id $0A: none
	dw FireManBehindBGZones	;id $0B: none
	dw FireManBehindBGZones	;id $0C: none
	dw FireManBehindBGZones	;id $0D: none

;$5542: a stray `ret`, reached by nothing.	;[ok]
	ret

FireManRoom1Layout:	;20 x 8
	layout 20
	lrow "1B 00 00 00 00 00 00 00 1B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B 0B"
	lrow "1B 00 00 00 00 00 00 00 1B 0E 10 11 10 11 10 11 10 11 10 0F"
	lrow "1B 00 00 00 00 00 00 00 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 17 16 17 16 17 16 17 16 17 16 17 16 17 16 17 16 19 02 1B"
	lrow "1B 1B 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 1B 01 1B"
	lrow "1B 1B 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 01 1B"
	end_layout

FireManRoom2Layout:	;10 x 8
	layout 10
	lrow "22 22 22 22 22 22 22 1B 01 1B"
	lrow "10 11 0D 11 0D 10 0F 1B 01 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 15 1B"
	lrow "1B 00 00 00 00 00 00 00 1B 1B"
	lrow "1B 00 18 16 17 16 17 16 17 16"
	lrow "1B 00 1B 08 08 08 08 08 08 08"
	end_layout

FireManRoom3Layout:	;40 x 8
	layout 40
	lrow "1B 00 1B 22 22 22 22 22 22 22 22 22 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 1B 0E 1D 1E 11 1D 1E 10 1D 1E 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 1C 21 21 21 21 21 15 21 21 21 21 1B"
	lrow "16 17 16 19 20 20 15 20 20 15 20 20 15 20 20 1C 20 20 15 20 15 20 15 20 20 15 20 20 1B 20 20 15 20 20 1B 20 20 18 02 1B"
	lrow "08 08 08 08 08 08 1B 08 08 1B 08 08 1B 08 08 1B 08 08 1B 08 1B 08 1B 08 08 1B 08 08 1B 08 08 1B 08 08 1B 08 08 1B 01 1B"
	end_layout

FireManRoom4Layout:	;10 x 8
	layout 10
	lrow "22 22 22 22 22 22 22 1B 01 1B"
	lrow "0D 11 10 0D 1D 1E 0F 1B 01 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 21 21 21 21 21 15 21 21 1B"
	lrow "1B 02 18 19 20 20 18 16 17 1B"
	lrow "1B 01 1B 08 08 08 08 08 08 1B"
	end_layout

FireManRoom5Layout:	;40 x 8
	layout 40
	lrow "1B 00 0E 10 11 0D 10 0D 11 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0E 10 11 10 11 10 11 0F 01 1B"
	lrow "1B 00 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 1F 1F 1F 1F 1F 1F 1F 01 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 1B"
	lrow "1B 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 18 16 16 19 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 1B"
	lrow "1B 20 20 20 20 20 20 20 18 16 16 16 16 19 20 20 20 20 1B 1B 1B 1B 20 20 18 19 20 20 18 19 20 20 18 16 17 16 17 16 17 16"
	lrow "1B 16 17 16 17 16 17 16 1B 08 08 08 08 1B 16 17 16 17 1B 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08 08"
	end_layout

FireManRoom6Layout:	;10 x 8
	layout 10
	lrow "1B 01 0E 10 11 10 11 10 0F 1B"
	lrow "1B 01 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 21 21 21 21 21 21 21 21 1B"
	lrow "1B 15 20 20 15 20 20 15 02 1B"
	lrow "1B 1B 08 08 1B 08 08 1B 01 1B"
	lrow "1B 1B 22 22 1B 22 22 1B 01 1B"
	end_layout

FireManRoom7Layout:	;80 x 8
	layout 80
	lrow "1B 0B 0B 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 22 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 0B 0B 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B 0E 11 1D 1E 10 11 0D 1D 1E 0D 1D 1E 10 11 0D 10 11 0D 11 0F 1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 0E 10 0F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 1A 1A 00 00 1A 00 1A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 15 00 00 15 00 15 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 0A 16 19 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 21 18 16 19 21 21 15 21 15 21 21 15 21 1B 08 08 1B 08 1B 21 21 15 21 15 21 21 21 21 21 21 21 21 18 19 02 1B"
	lrow "1B 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 1B 1B 1B 20 20 15 20 15 20 20 15 20 15 20 20 15 20 20 15 1C 20 20 15 20 20 18 16 19 1B 1B 1B 20 20 1B 08 1B 08 08 1B 08 1B 22 22 1B 22 1B 08 08 1B 08 1B 20 20 15 20 20 15 20 20 1B 1B 01 1B"
	lrow "1B 02 18 16 17 16 17 16 17 16 17 16 17 16 17 16 19 1B 1B 1B 08 08 1B 08 1B 08 08 1B 08 1B 08 08 1B 08 08 1B 1B 08 08 1B 08 08 1B 1B 1B 1B 1B 1B 08 08 1B 22 1B 22 22 1B 22 1B 22 22 1B 22 1B 22 22 1B 22 1B 08 08 1B 08 08 1B 08 08 1B 1B 01 1B"
	end_layout

FireManRoom8Layout:	;10 x 8
	layout 10
	lrow "22 22 22 22 22 22 22 1B 01 1B"
	lrow "1B 0E 0D 10 0D 11 0F 1B 01 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 12 13 13 13 13 14 15 1B"
	lrow "1B 00 1B 08 08 08 08 08 08 1B"
	end_layout

FireManRoom9Layout:	;10 x 8
	layout 10
	lrow "1B 00 18 16 17 16 17 16 17 16"
	lrow "1B 00 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 15 12 13 13 13 13 14 00 1B"
	lrow "08 08 08 08 08 08 08 1B 00 1B"
	end_layout

FireManRoom10Layout:	;10 x 8
	layout 10
	lrow "0D 11 10 0D 10 11 0D 0F 00 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 18 19 00 00 00 00 00 1B"
	lrow "1B 00 1B 1B 00 00 00 00 00 1B"
	lrow "1B 00 1B 1B 18 16 17 16 17 16"
	end_layout

FireManRoom11Layout:	;40 x 8
	layout 40
	lrow "1B 00 1B 0B 0B 0B 1B 0B 0B 0B 0B 0B 0B 0B 1B 0E 10 11 10 11 10 0D 0D 11 0D 10 0D 10 11 0D 0D 10 11 11 0D 10 0D 10 0F 1B"
	lrow "1B 00 1B 0B 0B 0B 1B 0E 10 11 10 11 10 11 1B 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 1B 0E 11 0F 1B 1F 1F 1F 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 1F 1F 1F 1F 1F 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 18 16 17 16 16 17 16 19 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 18 16 17 16 17 16 17 19 1B 08 08 08 08 08 08 1B 18 16 17 16 17 16 17 16 17 16 17 16 19 00 1B"
	lrow "16 17 16 17 16 17 16 17 16 19 1B 08 08 08 08 08 08 1B 22 22 22 22 22 22 1B 08 08 08 08 08 08 08 08 08 08 08 08 1B 00 1B"
	end_layout

FireManRoom12Layout:	;10 x 8
	layout 10
	lrow "1B 18 16 17 17 16 19 1B 00 1B"
	lrow "1B 0B 0B 0B 0B 04 05 1B 00 1B"
	lrow "1B 0E 10 11 10 06 07 1B 00 1B"
	lrow "1B 1F 1F 1F 1F 1F 1F 1F 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 18 16 17 16 17 16 19 1B"
	end_layout

FireManRoom13Layout:	;10 x 8
	layout 10
	lrow "1B 00 0E 10 11 10 11 10 0F 1B"
	lrow "1B 00 1F 1F 1F 1F 1F 1F 1F 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 00 00 00 00 00 00 00 00 1B"
	lrow "1B 18 16 17 16 16 17 16 19 1B"
	end_layout

;36 blocks: block top left, top right, bottom left, bottom right (tile numbers).	;[ok]
FireManBlocks:
	blockset FireMan
	block $38, $39, $3A, $3B	;$00
	block $47, $48, $47, $48	;$01
	block $47, $48, $47, $48	;$02
	block $78, $79, $78, $79	;$03
	block $08, $7C, $0A, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $10, $62, $16, $17	;$06
	block $63, $64, $12, $0F	;$07
	block $4D, $4E, $45, $46	;$08
	block $00, $01, $02, $03	;$09
	block $04, $05, $06, $07	;$0A
	block $08, $09, $0A, $0B	;$0B
	block $10, $11, $0E, $0F	;$0C
	block $10, $11, $12, $13	;$0D
	block $10, $11, $0E, $13	;$0E
	block $10, $11, $12, $0F	;$0F
	block $10, $11, $14, $15	;$10
	block $10, $11, $16, $17	;$11
	block $18, $19, $1C, $1D	;$12
	block $1A, $19, $1E, $1D	;$13
	block $1A, $1B, $1E, $1F	;$14
	block $20, $21, $0C, $0D	;$15
	block $22, $23, $26, $27	;$16
	block $28, $29, $24, $25	;$17
	block $20, $29, $0C, $25	;$18
	block $28, $21, $24, $0D	;$19
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
FireManCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $03, $03, $03, $03, $00
	db $00, $00, $00, $03
FireManCollisionEnd:
