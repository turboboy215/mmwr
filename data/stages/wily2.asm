;Wily stage 2, the teleporter hub and the five boss rooms - StageLoadTab index 6 - bank $08.
;Format: docs/LEVELS.md. Macros: macros/stages.inc. Included from banks/bank08.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
Wily2StageData:	;$4DD9
	dw Wily2RestartPoints
	dw Wily2Checkpoints

Wily2RestartPoints:
	dw Wily2Restart0
	dw Wily2Restart1
	dw Wily2Restart1

Wily2Checkpoints:
;Both checkpoints name room $16, Enker's room, and both restart entries 1 and 2
;are the five-teleporter hub: dying against Enker returns Mega Man there.	;[ok]
	checkpoint $16, $01
	checkpoint $16, $01
	end_checkpoints

;The hub, reached by dropping in from Wily 1 or by losing a life in it.	;[ok]
Wily2Restart0:	;$4DE8
	restart_point Wily2Blocks, Wily2Collision, Wily2HubRoutine, Wily2HubFrameHook, $0047, $43, Wily2Hub
;The hub once the four bosses are beaten, with the fifth teleporter.	;[ok]
Wily2Restart1:	;$4DF6
	restart_point Wily2Blocks, Wily2Collision, Wily2HubWithEnkerRoutine, Wily2HubFrameHook, $0047, $23, Wily2HubWithEnker

;The five teleporter destinations - not in the restart table, but loaded through
;JumpLoadRestartPoint by Wily2HubTeleportOut, so each boss room starts as a stage
;of its own. Which boss is where follows from the weapon awarded afterwards:
;the weapon-get screen names weapon wHubTeleporter + 4.	;[ok]
Wily2QuickManRestart:	;$4E04
	restart_point Wily2Blocks, Wily2Collision, Wily2BossRoomInit, Wily2BossRoomHook, $0017, $73, Wily2QuickManRoom
Wily2BubbleManRestart:	;$4E12
	restart_point Wily2Blocks, Wily2Collision, Wily2BossRoomInit, Wily2BubbleManRoomHook, $0017, $73, Wily2BubbleManRoom
Wily2FlashManRestart:	;$4E20
	restart_point Wily2Blocks, Wily2Collision, Wily2BossRoomInit, Wily2BossRoomHook, $0017, $73, Wily2FlashManRoom
Wily2HeatManRestart:	;$4E2E
	restart_point Wily2Blocks, Wily2Collision, Wily2BossRoomInit, Wily2BossRoomHook, $0017, $73, Wily2HeatManRoom
Wily2EnkerRestart:	;$4E3C
	restart_point Wily2Blocks, Wily2Collision, Wily2BossRoomInit, Wily2BossRoomHook, $0017, $73, Wily2EnkerRoom

;$4E4A: take the blockset, collision table, init routine and frame hook from a
;restart-point record - HL points at its blockset field, one byte in - without
;loading a room or touching Mega Man. This is how a stage changes graphics in
;the middle: Wily 1 hands over to Wily 2 here, and Wily 3's last room switches
;to the Wily Machine's blockset. A cut-down copy of LoadRestartPoint.	;[ok]
SwapRestartData:
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
	call JumpFill
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
	ret

;First arrival at the hub (from Wily1FrameHook's hand-over): swap in Wily 2's
;stage data and reset the hub state machine.	;[ok]
Wily2HubArrive:
	xor a
	ld [$D845], a
	ld hl, Wily2Restart0 + 1
	call SwapRestartData
	xor a
	ld [wHubState], a
	ld [wHubFadeStep], a
	ret

;$4E93: the four-teleporter hub's room routine, and Wily2Restart0's init. Makes
;restart point 0 current and sets bit 7 of wWilyProgress ("reached the hub").
;The first time, that means Mega Man has just dropped in from Wily 1, so it
;swaps in Wily 2's stage data; afterwards he is coming back from a boss, so it
;falls into Wily2HubPlace.	;[ok]
Wily2HubRoutine:
	xor a
	ld [wRestartPoint], a
	ld a, [wWilyProgress]
	bit 7, a
	set 7, a
	ld [wWilyProgress], a
	jr z, Wily2HubArrive

;Put Mega Man on the teleporter he last used (wHubTeleporter, 0 = none: the
;drop-in spot) and set the hub state to 2, playing.	;[ok]
Wily2HubPlace:
	ld a, $02
	ld [wHubState], a
	ld a, [wHubTeleporter]
	ld hl, Wily2Teleporters - 4
	add a, a
	add a, a
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hl+]
	ld [wPlayerX], a
	ld [$D80D], a
	xor a
	ld [$D80E], a
	ld a, [hl+]
	sub $04
	ld [wPlayerY], a
	ret

;$4EC6: the five-teleporter hub's room routine, and Wily2Restart1's init -
;restart point 1, used once the four bosses are beaten. Like Wily2HubPlace, but
;with no teleporter to return to it starts Mega Man at ($4E, $20).	;[ok]
Wily2HubWithEnkerRoutine:
	ld a, $01
	ld [wRestartPoint], a
	call Wily2HubPlace
	ld a, [wHubTeleporter]
	or a
	ret nz
	ld a, $4E
	ld [wPlayerX], a
	ld [$D80D], a
	xor a
	ld [$D80E], a
	ld a, $20
	ld [wPlayerY], a
	ret

;$4EE5: init and room routine of the five boss rooms: Mega Man starts at
;($1F, $62), on the teleport pad.	;[ok]
Wily2BossRoomInit:
	ld a, $1F
	ld [wPlayerX], a
	ld [$D80D], a
	xor a
	ld [$D80E], a
	ld a, $63
	dec a
	ld [wPlayerY], a
	ret

;$4EF8: the hubs' frame hook, a state machine on wHubState:
;  0  wait until $D846 is set, then start a $78-frame fade-in (-> 1)
;  1  Wily2HubFadeIn: white, then Wily2FadePalettes, then -> 2
;  2  playing: BGP $E4, and Wily2CheckTeleporters
;  3  Wily2HubTeleportOut: fade to white and load the boss room
;It also clears $D909 every frame (see Wily2BubbleManRoomHook).	;[ok]
Wily2HubFrameHook:
	xor a
	ld [wUnderwater], a
	ld a, [wHubState]
	or a
	jr nz, .notWaiting
	ld a, [wPlayerMotion]
	or a
	jp z, .done
	xor a
	ld [$D845], a
	ld a, $78
	ld [wHubFadeTimer], a
	ld a, $01
	ld [wHubState], a
	jp .done
.notWaiting
	dec a
	jp z, Wily2HubFadeIn
	dec a
	dec a
	jp z, Wily2HubTeleportOut
	ld a, $E4
	ld [wShadowBGP], a
	call Wily2CheckTeleporters
.done
	ret

;$4F2C: is Mega Man standing on a teleporter? Checks the first four entries of
;Wily2Teleporters (all five once wWilyProgress's low four bits are set),
;skipping each one whose boss is beaten (wWilyProgress bit n). On an exact
;match of his position it stores the entry's restart record in
;wHubDestination, the teleporter's number (1-5) in wHubTeleporter, and starts
;the teleport-out (state 3). wHubTeleporter is what later picks the weapon:
;the weapon-get screen names weapon wHubTeleporter + 4.	;[ok]
Wily2CheckTeleporters:
	ld a, [wWilyProgress]
	ld c, a
	ld b, $04
	and $0F
	cp $0F
	jr nz, .gotCount
	ld b, $05
.gotCount
	ld a, b
	ldh [hBank1CallIndex], a	;used here as scratch
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	ld d, a
	ld hl, Wily2Teleporters
.loop
	rr c
	jr c, .beaten
	ld a, [hl+]
	cp e
	jr nz, .nextX
	ld a, [hl]
	cp d
	jr nz, .nextX
	inc hl
	ld a, [hl+]
	ld [wHubDestination], a
	ld a, [hl+]
	ld [wHubDestination + 1], a
	ld a, $01
	ld [$D845], a
	ldh a, [hBank1CallIndex]
	sub b
	ld e, a
	ld d, $00
	inc a
	ld [wHubTeleporter], a
	ld a, $03
	ld [wHubState], a
	xor a
	ld [wHubFadeTimer], a
	ld [wHubFadeStep], a
	ld a, $01
	ld [$D845], a
	jr .done
.beaten
	inc hl
.nextX
	inc hl
	inc hl
	inc hl
	dec b
	jr nz, .loop
.done
	ret

;$4F87: the teleporters - Mega Man's X and Y standing on one, and the
;restart-point record it leads to. Wily2HubPlace indexes from Wily2Teleporters
;- 4 with wHubTeleporter, so the entry just before the list is "teleporter 0",
;the drop-in spot. The first entry ($4F87) is read by nothing: its ($4E, $20)
;is the five-teleporter hub's start, which Wily2HubWithEnkerRoutine writes as
;literals instead.	;[ok]
	db $4E, $20
	dw Wily2Restart0	;never read
	db $4E, $50
	dw Wily2Restart0	;teleporter 0: the drop-in spot (position only)
Wily2Teleporters:
	db $0F, $23
	dw Wily2QuickManRestart	;1: top left -> Quick Boomerang
	db $8F, $23
	dw Wily2BubbleManRestart	;2: top right -> Bubble Lead
	db $0F, $53
	dw Wily2FlashManRestart	;3: bottom left -> Time Stopper
	db $8F, $53
	dw Wily2HeatManRestart	;4: bottom right -> Atomic Fire
	db $4E, $63
	dw Wily2EnkerRestart	;5: bottom centre, after the four -> Mirror Buster

;$4FA3: one bit per teleporter. Nothing in this bank reads it (bank $00 uses
;its own table at $1:5EB6 to set wWilyProgress bits).	;[ok]
	db $01, $02, $04, $08, $10, $20, $40, $80

;$4FAB: hub state 1 - hold the palette white for wHubFadeTimer frames, then
;step through Wily2FadePalettes every 4 frames, then state 2.	;[ok]
Wily2HubFadeIn:
	ld hl, wHubFadeTimer
	ld a, [hl]
	or a
	jr z, .fading
	dec [hl]
	ld a, $FF
	ld [wShadowBGP], a
	jp Wily2HubFrameHook.done
.fading
	inc hl
	inc [hl]
	ld a, [hl]
	cp $0C
	jr nc, .finished
	rrc a
	rrc a
	and $03
	ld e, a
	ld d, $00
	ld hl, Wily2FadePalettes
	add hl, de
	ld a, [hl]
	ld [wShadowBGP], a
	jp Wily2HubFrameHook.done
.finished
	ld a, $E4
	ld [wShadowBGP], a
	ld a, $02
	ld [wHubState], a
	jp Wily2HubFrameHook.done

;$4FE3: hub state 3 - fade Wily2FadePalettes backwards to white, then reset the
;stack and load the restart record in wHubDestination through
;JumpLoadRestartPoint, returning into JumpPlayStage: the boss room becomes a
;fresh stage start.	;[ok]
Wily2HubTeleportOut:
	ld hl, wHubFadeTimer
	ld a, [hl]
	or a
	jr z, .fading
	dec [hl]
	jp Wily2HubFrameHook.done
.fading
	inc hl
	inc [hl]
	ld a, [hl]
	cp $0C
	jr nc, .warp
	rrc a
	rrc a
	and $03
	ld e, a
	ld a, $02
	sub e
	ld e, a
	ld d, $00
	ld hl, Wily2FadePalettes
	add hl, de
	ld a, [hl]
	ld [wShadowBGP], a
	jp Wily2HubFrameHook.done
.warp
	ld a, $FF
	ld [wShadowBGP], a
	ld a, $02
	ld [wHubState], a
	ld sp, STACK_TOP
	ld hl, JumpPlayStage
	push hl
	ld a, [wHubDestination]
	ld l, a
	ld a, [wHubDestination + 1]
	ld h, a
	jp JumpLoadRestartPoint

;BGP steps for the hub fades: white to normal. The fourth is never reached.	;[ok]
Wily2FadePalettes:
	db $FE, $F9, $E4, $E4

;$502D: Bubble Man's room's frame hook: sets $D909 to 1 every frame, then
;carries on as the other boss rooms. $D909 is read by bank $01's movement code
;and the hubs clear it; Bubble Man's fight is underwater, so this is presumably
;the water flag.	;[?]
Wily2BubbleManRoomHook:
	ld a, $01
	ld [wUnderwater], a

;$5032: the boss rooms' frame hook. Palette $E4. After the boss is beaten (once
;$CCF5 is set and wVictoryTimer is under $5A), standing on the teleport pad -
;X $1E-$20, Y $63, where Mega Man arrived - plays the teleport sound ($21),
;sets $D845 and $DFCC = 3 and shortens the timer to $23: the warp back out.	;[ok]
Wily2BossRoomHook:
	ld a, $E4
	ld [wShadowBGP], a
	ld a, [wTeleportState]
	or a
	ret nz
	ld a, [$CCF5]
	or a
	ret z
	ld a, [wVictoryTimer]
	ld l, a
	ld a, [wVictoryTimer + 1]
	ld h, a
	ld a, h
	or a
	jr nz, .done
	ld e, $5A
	ld a, l
	cp e
	jr nc, .done
	ld a, [wPlayerX]
	cp $1E
	jr c, .store
	cp $21
	jr nc, .store
	ld a, [wPlayerY]
	cp $63
	jr nz, .store
	ld a, $21	;SFX_Teleport
	call JumpQueueSound
	ld a, $01
	ld [$D845], a
	ld a, $03
	ld [wTeleportState], a
	xor a
	ld [$DFCD], a
	ld e, $23
.store
	ld a, e
	ld [wVictoryTimer], a
	xor a
	ld [wVictoryTimer + 1], a
.done
	ret

;The hub: four teleporters (Wily2Teleporters 1-4). Its id, $11, repeats a
;Wily 1 room id; the two stages never share a checkpoint list, so it is harmless.	;[ok]
Wily2Hub:	;$5083
	room $11, Wily2HubRoutine, Wily2HubLayout, $0640
	no_exit
	no_exit
	spawn 53, 0, $00, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $01, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $02, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $03, $00	;teleporter light (Will) - y is its number
	spawn 56, 4, $40, $00	;the DR.WILY TELEPORT SYSTEM sign (its tiles spell it)
	end_spawns

Wily2QuickManRoom:	;$50A1
	room $12, Wily2BossRoomInit, Wily2BossRoomLayout, $0000
	no_exit
	no_exit
	spawn 46, 6, $00, $00	;Quick Man
	spawn 47, 7, $00, $00	;Quick Boomerang (Will)
	spawn 47, 8, $00, $00	;Quick Boomerang (Will)
	spawn 47, 9, $00, $00	;Quick Boomerang (Will)
	end_spawns

Wily2BubbleManRoom:	;$50BB
	room $13, Wily2BossRoomInit, Wily2BubbleManRoomLayout, $0000
	no_exit
	no_exit
	spawn 40, 3, $00, $00	;Bubble Man
	spawn 41, 5, $00, $00	;Bubble Lead (Will)
	spawn 41, 6, $00, $00	;Bubble Lead (Will)
	spawn 41, 7, $00, $00	;Bubble Lead (Will)
	spawn 41, 8, $00, $00	;Bubble Lead (Will)
	spawn 41, 9, $00, $00	;Bubble Lead (Will)
	end_spawns

Wily2FlashManRoom:	;$50DD
	room $14, Wily2BossRoomInit, Wily2BossRoomLayout, $0000
	no_exit
	no_exit
	spawn 42, 8, $00, $00	;Flash Man
	spawn 43, 9, $00, $00
	end_spawns

Wily2HeatManRoom:	;$50EF
	room $15, Wily2BossRoomInit, Wily2BossRoomLayout, $0000
	no_exit
	no_exit
	spawn 44, 6, $00, $00	;Heat Man
	spawn 45, 7, $00, $00	;Atomic Fire (Will)
	spawn 45, 8, $00, $00	;Atomic Fire (Will)
	spawn 45, 9, $00, $00	;Atomic Fire (Will)
	end_spawns

Wily2EnkerRoom:	;$5109
	room $16, Wily2BossRoomInit, Wily2BossRoomLayout, $0000
	no_exit
	no_exit
	spawn 38, 8, $00, $00	;Enker
	end_spawns

;The same hub with the fifth teleporter, Enker's, once the four are beaten.	;[ok]
Wily2HubWithEnker:	;$5117
	room $17, Wily2HubWithEnkerRoutine, Wily2HubWithEnkerLayout, $0000
	no_exit
	no_exit
	spawn 53, 0, $00, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $01, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $02, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $03, $00	;teleporter light (Will) - y is its number
	spawn 53, 0, $04, $00	;teleporter light (Will) - y is its number
	spawn 56, 4, $40, $00	;the DR.WILY TELEPORT SYSTEM sign (its tiles spell it)
	end_spawns

Wily2HubLayout:	;10 x 8
	layout 10
	lrow "09 0A 19 18 19 19 18 19 09 0A"
	lrow "00 00 19 0F 10 10 11 19 00 00"
	lrow "00 00 19 12 13 13 14 19 00 00"
	lrow "0D 0E 18 15 16 16 17 18 0D 0E"
	lrow "00 00 19 18 19 19 18 19 00 00"
	lrow "00 00 19 1A 1F 20 1A 19 00 00"
	lrow "0B 0C 18 19 21 22 19 18 0B 0C"
	lrow "1B 1C 1D 1E 1B 1C 1D 1E 1B 1C"
	end_layout

Wily2HubWithEnkerLayout:	;10 x 8
	layout 10
	lrow "09 0A 19 18 19 19 18 19 09 0A"
	lrow "00 00 19 0F 10 10 11 19 00 00"
	lrow "00 00 19 12 13 13 14 19 00 00"
	lrow "0D 0E 18 15 16 16 17 18 0D 0E"
	lrow "00 00 19 18 09 0A 18 19 00 00"
	lrow "00 00 19 19 00 00 19 19 00 00"
	lrow "0B 0C 18 19 00 00 19 18 0B 0C"
	lrow "1B 1C 1D 1E 0D 0E 1D 1E 1B 1C"
	end_layout

Wily2BubbleManRoomLayout:	;10 x 8
	layout 10
	lrow "1B 1C 1D 1E 1B 1C 1D 1E 1B 1C"
	lrow "23 25 25 25 25 25 25 25 25 23"
	lrow "23 24 24 24 24 24 24 24 24 23"
	lrow "23 24 24 24 24 24 24 24 24 23"
	lrow "23 24 24 24 24 24 24 24 24 23"
	lrow "23 24 24 24 24 24 24 24 24 23"
	lrow "23 24 24 24 24 24 24 24 24 23"
	lrow "1B 0B 0C 1E 1B 1C 1D 1E 1B 1C"
	end_layout

Wily2BossRoomLayout:	;10 x 8; also Wily2FlashManRoom, Wily2HeatManRoom, Wily2EnkerRoom
	layout 10
	lrow "1B 1C 1D 1E 1B 1C 1D 1E 1B 1C"
	lrow "23 27 27 27 27 27 27 27 27 23"
	lrow "23 26 26 26 26 26 26 26 26 23"
	lrow "23 26 26 26 26 26 26 26 26 23"
	lrow "23 26 26 26 26 26 26 26 26 23"
	lrow "23 26 26 26 26 26 26 26 26 23"
	lrow "23 26 26 26 26 26 26 26 26 23"
	lrow "1B 0B 0C 1E 1B 1C 1D 1E 1B 1C"
	end_layout

;40 blocks: block top left, top right, bottom left, bottom right.	;[ok]
Wily2Blocks:
	blockset Wily2
	block $73, $73, $73, $73	;$00
	block $78, $79, $78, $79	;$01
	block $78, $79, $78, $79	;$02
	block $78, $79, $78, $79	;$03
	block $0A, $7C, $0A, $7F	;$04
	block $7D, $7E, $7A, $7B	;$05
	block $0A, $62, $0A, $0A	;$06
	block $63, $64, $0A, $0A	;$07
	block $74, $75, $76, $77	;$08
	block $00, $01, $04, $05	;$09
	block $02, $03, $06, $07	;$0A
	block $04, $08, $0A, $0B	;$0B
	block $09, $07, $0C, $0A	;$0C
	block $04, $08, $04, $05	;$0D
	block $09, $07, $06, $07	;$0E
	block $0D, $0E, $10, $11	;$0F
	block $0E, $0E, $11, $11	;$10
	block $0E, $0F, $11, $12	;$11
	block $10, $11, $10, $11	;$12
	block $11, $11, $11, $11	;$13
	block $11, $12, $11, $12	;$14
	block $10, $11, $13, $14	;$15
	block $11, $11, $14, $14	;$16
	block $11, $12, $14, $15	;$17
	block $16, $17, $18, $19	;$18
	block $1A, $1B, $1C, $1D	;$19
	block $1E, $1F, $20, $21	;$1A
	block $22, $23, $2A, $2B	;$1B
	block $24, $25, $2C, $2D	;$1C
	block $26, $27, $2E, $2F	;$1D
	block $28, $29, $30, $31	;$1E
	block $32, $33, $36, $37	;$1F
	block $34, $35, $38, $39	;$20
	block $3A, $3B, $3E, $3F	;$21
	block $3C, $3D, $40, $41	;$22
	block $42, $43, $42, $43	;$23
	block $46, $47, $46, $47	;$24
	block $44, $45, $46, $47	;$25
	block $4A, $4B, $4B, $4A	;$26
	block $48, $49, $4B, $4A	;$27

;One collision byte per block.	;[ok]
Wily2Collision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $03, $03, $03, $03, $00
	db $00, $00, $00, $03, $00, $00, $00, $00
Wily2CollisionEnd:

;$534A: a second copy of Wily 2's 76 background tiles - byte for byte the bank $0C
;set, so the same PNG builds both. Wily1FrameHook streams these into VRAM while
;Mega Man drops into the hub, because the bank $0C copy is only loaded at a stage
;start and Wily 1 -> Wily 2 happens without one.	;[ok]
Wily2HubTiles:
	INCBIN "gfx/stages/wily2.2bpp"
Wily2HubTilesEnd:
