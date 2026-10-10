;An unreferenced stage - bank $08. Nothing points at its header: no StageLoadTab
;entry, no pointer anywhere in the ROM. One 40-block room laying out Wily 2's four
;room layouts side by side, no exits, no objects, with Wily 2's blocks - a test or
;viewer stage for Wily 2's rooms, left in. Format: docs/LEVELS.md. Macros:
;macros/stages.inc. Included from banks/bank08.asm.

;Stage header: the restart-point table and the checkpoint list.	;[ok]
Wily2TestStageData:	;$6D05
	dw Wily2TestStageRestartPoints
	dw Wily2TestStageCheckpoints

Wily2TestStageRestartPoints:
	dw Wily2TestStageRestart0
	dw Wily2TestStageRestart1
	dw Wily2TestStageRestart2

Wily2TestStageCheckpoints:
	checkpoint $01, $04
	checkpoint $01, $04
	end_checkpoints

Wily2TestStageRestart0:	;$6D14
	restart_point Wily2TestStageBlocks, Wily2TestStageCollision, Wily2TestStageInit, Wily2TestStageFrameHook, $0047, $33, Wily2TestStageRoom
Wily2TestStageRestart1:	;$6D22
	restart_point Wily2TestStageBlocks, Wily2TestStageCollision, Wily2TestStageInit, Wily2TestStageFrameHook, $0047, $33, Wily2TestStageRoom
Wily2TestStageRestart2:	;$6D30
	restart_point Wily2TestStageBlocks, Wily2TestStageCollision, Wily2TestStageInit, Wily2TestStageFrameHook, $0047, $33, Wily2TestStageRoom

Wily2TestStageRoom:	;$6D3E
	room $01, Wily2TestStageRoomRoutine, Wily2TestStageLayout, $0000
	no_exit
	no_exit
	end_spawns

;$6D48: init and room routine (nothing), and a frame hook with the palette and
;spike test - the same as Wily 1's minus its hand-over code.	;[ok]
Wily2TestStageInit:
	ret
Wily2TestStageRoomRoutine:
	ret
Wily2TestStageFrameHook:
	ld a, $E4
	ld [wShadowBGP], a
	ld a, [$D8C7]		;the block under Mega Man (written by bank $01)
	cp $08
	jr nz, .notSpikes
	ld a, $14
	ld [$D838], a
.notSpikes
	ret

;Four screens side by side: exactly Wily2HubLayout, Wily2HubWithEnkerLayout,
;Wily2BubbleManRoomLayout and Wily2BossRoomLayout.	;[ok]
Wily2TestStageLayout:	;40 x 8
	layout 40
	lrow "09 0A 19 18 19 19 18 19 09 0A 09 0A 19 18 19 19 18 19 09 0A 1B 1C 1D 1E 1B 1C 1D 1E 1B 1C 1B 1C 1D 1E 1B 1C 1D 1E 1B 1C"
	lrow "00 00 19 0F 10 10 11 19 00 00 00 00 19 0F 10 10 11 19 00 00 23 25 25 25 25 25 25 25 25 23 23 27 27 27 27 27 27 27 27 23"
	lrow "00 00 19 12 13 13 14 19 00 00 00 00 19 12 13 13 14 19 00 00 23 24 24 24 24 24 24 24 24 23 23 26 26 26 26 26 26 26 26 23"
	lrow "0D 0E 18 15 16 16 17 18 0D 0E 0D 0E 18 15 16 16 17 18 0D 0E 23 24 24 24 24 24 24 24 24 23 23 26 26 26 26 26 26 26 26 23"
	lrow "00 00 19 18 19 19 18 19 00 00 00 00 19 18 09 0A 18 19 00 00 23 24 24 24 24 24 24 24 24 23 23 26 26 26 26 26 26 26 26 23"
	lrow "00 00 19 1A 1F 20 1A 19 00 00 00 00 19 19 00 00 19 19 00 00 23 24 24 24 24 24 24 24 24 23 23 26 26 26 26 26 26 26 26 23"
	lrow "0B 0C 18 19 21 22 19 18 0B 0C 0B 0C 18 19 00 00 19 18 0B 0C 23 24 24 24 24 24 24 24 24 23 23 26 26 26 26 26 26 26 26 23"
	lrow "1B 1C 1D 1E 1B 1C 1D 1E 1B 1C 1B 1C 1D 1E 0D 0E 1D 1E 1B 1C 1B 0B 0C 1E 1B 1C 1D 1E 1B 1C 1B 0B 0C 1E 1B 1C 1D 1E 1B 1C"
	end_layout

;The same 40 block definitions as Wily2Blocks. The collision table differs in
;one byte: block $23 is passable here, solid in Wily 2.	;[ok]
;40 blocks: block top left, top right, bottom left, bottom right.	;[ok]
Wily2TestStageBlocks:
	blockset Wily2TestStage
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
Wily2TestStageCollision:
	db $00, $00, $02, $00, $03, $03, $03, $03, $01, $03, $03, $03, $03, $03, $03, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $03, $03, $03, $03, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
Wily2TestStageCollisionEnd:
