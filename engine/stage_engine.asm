;Mega Man: Dr. Wily's Revenge disassembly - stage engine routines, $0CDC-$157C
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Stage Engine", ROM0[$0CDC]

;$0CDC: zero the play-state RAM, $C200-$D4C1 (shots, objects, sprites, Mega Man,
;the stage and room) and $D4F3-$DF42, between stages and after a lost life.
;$D4C2-$D4F2 and the progress/settings block from $DF43 survive.	;[ok]
ClearStageRAM:	;$0CDC
	ld hl, wShotCount
	ld bc, $12C2
	xor a
	call FuncMemset
	ld hl, $D4F3
	ld bc, $0A50
	xor a
	call FuncMemset
	ret

;$0CF1-$0F03: a hitbox viewer - a developer's tool, switched off in the
;shipped game. When running it freezes play ($DFB1 bit 0), shows a blinking ring
;cursor that the d-pad moves a pixel at a time (every frame while A is held),
;and while B is held it puts four blinking corner brackets round the hitbox of
;whatever lies under the cursor: Mega Man, an object or an enemy shot. Select
;turns it off, Start leaves through bank $01 $67EA.
;
;Why it is dead: the viewer's own loop at $0D76 has no caller, no pointer to it
;exists anywhere in the ROM, and nothing ever gives $DFC0-$DFC4 sprite handles -
;InitHitboxViewer sets $DFC0 to $FE, which makes DrawHitboxCorners return at
;once. The collision code still calls HitboxViewerCheck for every hitbox, so
;holding B in a stage quietly runs the overlap test and discards the result.
;Found while chasing the five "background" tiles Will could not place in any
;stage.	;[ok]

;Copy the viewer's five tiles to sprite tiles $FB-$FF, centre the cursor at
;($50, $40), and mark the corner sprites absent. PlayStage calls it on every
;stage start.	;[ok]
InitHitboxViewer:	;$0CF1
	ld hl, HitboxViewerTiles
	ld de, VRAM_TILES0 + $FB * 16
	ld bc, HitboxViewerTilesEnd - HitboxViewerTiles
	call FuncFill
	ld a, $50
	ld [$DFB2], a
	ld a, $40
	ld [$DFB3], a
	ld a, $FE
	ld [$DFC0], a
	ret
;$0D0D: the viewer's tiles, at sprite tiles $FB-$FF: a hitbox corner in black
;and in grey ($FB/$FC, alternated every 8 frames to blink), the cursor ring in
;black and grey ($FD/$FE, likewise), and a solid grey block ($FF) that nothing
;draws. gfx/hitbox_viewer.png.	;[ok]
HitboxViewerTiles::	;$0D0D
	INCBIN "gfx/hitbox_viewer.2bpp"
HitboxViewerTilesEnd::

;$0D5D: five one-tile metasprites for DrawMetasprite - offset (dx, dy), a 1x1
;grid, the tile byte, then $80 to end the (empty) free list. The four corners
;are one tile flipped four ways; the fifth is the cursor. (Read before step 3.3
;as "tile numbers and a VRAM address".)	;[ok]
HitboxCornerMetasprites::
	db -2, -2, $11, $00, $80	;top left
	db -2, -5, $11, $40, $80	;bottom left: Y flip
	db -5, -2, $11, $80, $80	;top right: X flip
	db -5, -5, $11, $C0, $80	;bottom right: both
HitboxCursorMetasprite:
	db -3, -3, $11, $00, $80

;$0D76: one frame of the viewer. No caller.	;[ok]
HitboxViewer:
	ld hl, wFreezeFlags
	set 0, [hl]
	ldh a, [hJoypadPressed]
	bit 3, a
	jr z, .l0D8C
	ld hl, wFreezeFlags
	res 0, [hl]
	xor a
	ldh [hJoypadPressed], a
	jp PlayerControl	;bank $01
.l0D8C
	bit 2, a
	jr z, .l0DBD
	xor a
	ld [$DFB0], a
	ld hl, wFreezeFlags
	res 0, [hl]
	ld a, [$DFC0]
	call FreeSprite
	ld a, [$DFC1]
	call FreeSprite
	ld a, [$DFC2]
	call FreeSprite
	ld a, [$DFC3]
	call FreeSprite
	ld a, [$DFC4]
	call FreeSprite
	ld a, $FE
	ld [$DFC0], a
	ret
.l0DBD
	call HitboxViewerCheckPlayer
	ldh a, [hJoypadHeld]
	bit 1, a
	ret nz
	ld a, [wVBlankCount]
	and $08
	ld a, $FD
	jr nz, .l0DCF
	inc a
.l0DCF
	ld [$CE55], a
	ldh a, [hJoypadHeld]
	bit 0, a
	jr z, .l0DDA
	ldh a, [hJoypadPressed]
.l0DDA
	ld de, Entry
	rlca
	jr c, .l0DF5
	ld de, $FF00
	rlca
	jr c, .l0DF5
	ld de, $00FF
	rlca
	jr c, .l0DF5
	ld de, $0001
	rlca
	jr c, .l0DF5
	ld de, $0000
.l0DF5
	ldh a, [$FFA2]
	ld l, a
	ldh a, [$FFA3]
	ld h, a
	push hl
	ld hl, $DFB2
	ld a, e
	add a, [hl]
	ld [hl+], a
	ldh [$FFA2], a
	ld a, d
	add a, [hl]
	ld [hl+], a
	ldh [$FFA3], a
	xor a
	ld [$D3EA], a
	ld hl, HitboxCursorMetasprite
	ld a, [$DFC4]
	call DrawMetasprite
	pop hl
	ld a, l
	ldh [$FFA2], a
	ld a, h
	ldh [$FFA3], a
	ret

;Test Mega Man's own box (centred on $D821, $D824) against the cursor.	;[ok]
HitboxViewerCheckPlayer:	;$0E1E
	ld a, [wPlayerX]
	ld h, a
	add a, $FA
	ld e, a
	ld a, h
	add a, $06
	ld l, a
	ld a, [wPlayerY]
	ld h, a
	add a, $F8
	ld d, a
	ld a, h
	add a, $0C
	ld h, a
	jp HitboxViewerCheck

;Called with a hitbox in E-L (X) and D-H (Y) by the collision pass, by
;UpdateEnemyShot and twice from bank $01. Only while B is held: if the cursor
;point lies inside the box, store its corners at $DFB8-$DFBF and draw the
;brackets. Preserves everything it touches.	;[ok]
HitboxViewerCheck:	;$0E37
	ldh a, [hJoypadHeld]
	bit 1, a
	ret z
	push hl
	push de
	push bc
	ldh a, [$FFA2]
	ld c, a
	ldh a, [$FFA3]
	ld b, a
	push bc
	ld a, [$DFB2]
	add a, $03
	ld b, a
	sub $06
	cp l
	jr nc, .l0E83
	ld a, b
	cp e
	jr c, .l0E83
	ld a, [$DFB3]
	add a, $03
	ld b, a
	sub $06
	cp h
	jr nc, .l0E83
	ld a, b
	cp d
	jr c, .l0E83
	ld a, l
	ld [$DFBD], a
	ld [$DFBF], a
	ld a, e
	ld [$DFB9], a
	ld [$DFBB], a
	ld a, h
	ld [$DFBA], a
	ld [$DFBE], a
	ld a, d
	ld [$DFB8], a
	ld [$DFBC], a
	call DrawHitboxCorners
.l0E83
	pop bc
	ld a, c
	ldh [$FFA2], a
	ld a, b
	ldh [$FFA3], a
	pop bc
	pop de
	pop hl
	ret

;Draw the four corner brackets from $DFB8-$DFBF, blinking. Returns at once
;while $DFC0 is $FE, which in the shipped game is always.	;[ok]
DrawHitboxCorners:	;$0E8E
	ld a, [$DFC0]
	cp $FE
	ret z
	ld a, [$CE55]
	ld e, a
	ld a, [$D3EA]
	ld d, a
	push de
	ld a, [wVBlankCount]
	and $08
	ld a, $FB
	jr nz, .l0EA7
	inc a
.l0EA7
	ld [$CE55], a
	xor a
	ld [$D3EA], a
	ld a, [$DFB9]
	ldh [$FFA2], a
	ld a, [$DFB8]
	ldh [$FFA3], a
	ld hl, HitboxCornerMetasprites
	ld a, [$DFC0]
	call DrawMetasprite
	ld a, [$DFBB]
	ldh [$FFA2], a
	ld a, [$DFBA]
	ldh [$FFA3], a
	ld hl, HitboxCornerMetasprites + 5
	ld a, [$DFC1]
	call DrawMetasprite
	ld a, [$DFBD]
	ldh [$FFA2], a
	ld a, [$DFBC]
	ldh [$FFA3], a
	ld hl, HitboxCornerMetasprites + 10
	ld a, [$DFC2]
	call DrawMetasprite
	ld a, [$DFBF]
	ldh [$FFA2], a
	ld a, [$DFBE]
	ldh [$FFA3], a
	ld hl, HitboxCornerMetasprites + 15
	ld a, [$DFC3]
	call DrawMetasprite
	pop de
	ld a, e
	ld [$CE55], a
	ld a, d
	ld [$D3EA], a
	ret

;Start Mega Man's beam-in at a stage start or restart: Y = $F8 (above the
;screen), wTeleportState 1, beam animation counter $DFCD cleared. Called by
;LoadRestartPoint.	;[ok]
StartTeleportIn:	;$0F04
	ld a, $F8
	ld [wPlayerY], a
	ld a, $01
	ld [wTeleportState], a
	xor a
	ld [$DFCD], a
	ret

;Called every frame by UpdatePlayerState once the victory timer is under $68
;(robot master stages only - not once all four are beaten): lock the controls
;($D845 = 1) and, once Mega Man is not in the air, drop the rest of the caller
;(`pop hl`), play the teleport sound ($21) and start the beam-out
;(wTeleportState 2).	;[ok]
TeleportOutWhenGrounded:	;$0F13
	ld a, $01
	ld [$D845], a
	ld a, [wPlayerMotion]
	or a
	ret z
	pop hl
	ld a, $21
	call QueueSound
	ld a, $02
	ld [wTeleportState], a
	xor a
	ld [$DFCD], a
	ret

;The game-over screen: black palettes, LoadGameOverScreen, scroll reset, then
;wait for A, B or Start and leave 0, 1 or 2 in $DFD3, which LoseLife acts on
;(2 resets the game through Init). Stops the audio and selects audio bank $02
;on the way out.	;[ok]
GameOverMenu:	;$0F2D
	ld a, $FF
	ld [wShadowBGP], a
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call HideAllSpritesAlt
	call LoadGameOverScreen
	xor a
	ld [wShadowSCX], a
	ldh [rSCX], a
	ld [wShadowSCY], a
	ldh [rSCY], a
	ei
	call ReadJoypad
.l0F4D
	call DelayFrame
	ld a, $E4
	ld [wShadowBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	call ReadJoypad
	ldh a, [hJoypadPressed]
	bit 0, a
	jr nz, .l0F6C
	bit 1, a
	jr nz, .l0F70
	bit 3, a
	jr nz, .l0F74
	jr .l0F4D
.l0F6C
	ld a, $00
	jr .l0F76
.l0F70
	ld a, $01
	jr .l0F76
.l0F74
	ld a, $02
.l0F76
	ld [$DFD3], a
	call AudioStopAll
	ld a, $02
	ld [wAudioBank], a
	ret

;Collision at Mega Man's own position; see CheckSolidAt.	;[ok]
CheckSolidAtPlayer:	;$0F82
	ld a, [wPlayerX]
	ld e, a
	ld a, [wPlayerY]
	jr CheckSolidAt

;Collision at Mega Man's position plus the (dx, dy) at HL; see CheckSolidAt.	;[ok]
CheckSolidNearPlayer:	;$0F8B
	ld a, [wPlayerX]
	add a, [hl]
	inc hl
	ld e, a
	ld a, [wPlayerY]
	add a, [hl]

;Collision test for the screen point (E, A). Returns B = the block there
;(GetBlockAt) and carry if the point is solid, by the block's collision byte
;(wBlockCollision): 0 never, 3 always, 1 only in the block's lower half (Y bit 3
;set - block 8, the spikes) and 2 only in its upper half (block 2, the top of a
;ladder, which can be stood on and climbed through). A passable point is still
;solid if it lies in one of the boxes on the $DF00 list (AddSolidBox: the Carry
;platform) or, while $FFB1 is set (UpdatePlayer sets it around Mega Man's
;own movement), off the right or bottom edge of the screen. The bank $01
;player code also tests B itself: block 1 is a ladder, block 2 its top.	;[ok]
CheckSolidAt:	;$0F95
	ld d, a

;CheckSolidPoint: the same test entered past the `ld d, a` (D is not set from
;A). The object banks call it through JumpCheckSolidPoint.	;[ok]
CheckSolidPoint::	;$0F96
	ld [$D849], a
	ld a, e
	ld [$D848], a
	call GetBlockAt
	ld b, a
	ld [$D847], a
	ld a, $C8
	add a, b
	ld l, a
	ld a, $D8
	adc a, $00
	ld h, a
	ld a, [hl]
	and $03
	jr z, .l0FC5
	cp $03
	jr z, .l0FC3
	cp $02
	ld a, [$D849]
	jr nz, .l0FBF
	xor $08
.l0FBF
	and $08
	jr z, .l0FC5
.l0FC3
	scf
	ret
.l0FC5
	ld a, [$D848]
	ld e, a
	ldh a, [$FFB1]
	or a
	jr z, .l0FE2
	ld a, e
	cp $A0
	jr c, .l0FD5
	scf
	ret
.l0FD5
	ld a, [$D849]
	cp $F0
	jr nc, .l0FE2
	cp $90
	jr c, .l0FE2
	scf
	ret
.l0FE2
	ld hl, $DF00
	ld a, [hl+]
	ld d, a
.l0FE7
	ld a, l
	cp d
	ret nc
	ld a, e
	cp [hl]
	inc l
	jr c, .l0FFF
	cp [hl]
	inc l
	jr nc, .l1000
	ld a, [$D849]
	cp [hl]
	inc l
	jr c, .l1001
	cp [hl]
	inc l
	jr nc, .l0FE7
	ret
.l0FFF
	inc l
.l1000
	inc l
.l1001
	inc l
	jr .l0FE7

;Add the box at HL (x1, x2, y1, y2), offset by (C, B), to the solid-box list at
;$DF00 (first byte: the list's end). CheckSolidAt treats the boxes as solid; the
;Carry platform registers itself here every frame.	;[ok]
AddSolidBox:	;$1004
	ld de, $DF00
	ld a, [de]
	ld e, a
	ld a, [hl+]
	add a, c
	ld [de], a
	inc e
	ld a, [hl+]
	add a, c
	ld [de], a
	inc e
	ld a, [hl+]
	add a, b
	ld [de], a
	inc e
	ld a, [hl+]
	add a, b
	ld [de], a
	inc e
	ld a, e
	cp $41
	jr nc, .l1022
	ld [$DF00], a
	ret
.l1022
	jr .l1022

;Empty the solid-box list; UpdatePlayer does it every frame after moving.	;[ok]
ClearSolidBoxes:	;$1024
	ld a, $01
	ld [$DF00], a
	ret

;The block under screen point (E, D): scroll-adjusted, looked up in the $DE00
;block grid that DrawBlock fills.	;[ok]
GetBlockAt:	;$102A
	ld a, [wShadowSCX]
	add a, e
	ld e, a
	ld a, [wShadowSCY]
	add a, d
	ld d, a
	ld a, e
	swap a
	and $0F
	ld e, a
	ld a, d
	and $F0
	or e
	ld l, a
	ld h, $DE
	ld a, [hl]
	ret

;wPlayerX = Mega Man's on-screen X, from GetPlayerScreenX.	;[ok]
SetPlayerScreenX:	;$1043
	call GetPlayerScreenX
	ld a, e
	ld [wPlayerX], a
	ret

;From Mega Man's 16-bit stage X ($D80D/$D80E), E = his X on screen and C (also
;$D85D) = the scroll state: 1 at the left limit (below $50, E = the stage X),
;2 at the right limit (past wScrollMaxX, E = $50 + the excess), 0 in between,
;where the camera follows him and E = $50. Banks $0B and $0E carry copies.	;[ok]
GetPlayerScreenX:	;$104B
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	or a
	ld a, e
	jr nz, .l105D
	cp $50
	ld c, $01
	jr c, .l1073
.l105D
	ld hl, wScrollMaxX
	sub [hl]
	ld e, a
	inc hl
	ld a, d
	sbc a, [hl]
	jr c, .l106F
	ld a, $50
	add a, e
	ld e, a
	ld c, $02
	jr .l1073
.l106F
	ld c, $00
	ld e, $50
.l1073
	ld a, c
	ld [$D85D], a
	or a
	ret

;Mega Man's hitbox for this frame at $D841-$D844: X - 6, X + 6, Y - 8, Y + 12.
;Called by the stage loop; the collision pass tests objects against it.	;[ok]
SetPlayerHitbox:	;$1079
	ld a, [wPlayerX]
	ld e, a
	ld hl, $D841
	add a, $FA
	ld [hl+], a
	ld a, e
	add a, $06
	ld [hl+], a
	ld a, [wPlayerY]
	ld e, a
	add a, $F8
	ld [hl+], a
	ld a, e
	add a, $0C
	ld [hl+], a
	ret

;Does the box C-E (X), B-D (Y) touch one of Mega Man's shots? Tests the two hit
;lists UpdateShots builds (wShotList, then wShotList2, each only if active; the
;box is saved at $FF95-$FF98 for the second). On a hit returns NZ with A = the
;damage to deal, having applied $CC46 - the target's hit points, or $FF destroy
;the shot / $FE deflect it - to the shot (see wWeaponPierce); Z for no hit. The
;collision pass and UpdateEnemyShot call it, bank $0D through JumpCheckShotHit.	;[ok]
CheckShotHit:	;$1093
	ld hl, wShotListActive
	ld a, [hl]
	or a
	jp z, CheckShotListHit.checkList2
	ld a, c
	ldh [$FF95], a
	ld a, b
	ldh [$FF96], a
	ld a, e
	ldh [$FF97], a
	ld a, d
	ldh [$FF98], a
	call CheckShotListHit
	ret nz
	jp CheckShotListHit.restoreBoxCheckList2

;One hit list, HL at its Active byte: shrink the box by the list's shot hitbox
;(wShotHitbox), then test each (slot, X, Y) entry's point against it. The hit
;slot goes to $C22A, and $C236 says whether the hit counts.	;[ok]
CheckShotListHit:	;$10AE
	inc l
	ld a, c
	sub [hl]
	cp $E0
	jr c, .l10B6
	xor a
.l10B6
	ld c, a
	inc l
	ld a, e
	sub [hl]
	cp $E0
	jr c, .l10BF
	xor a
.l10BF
	ld e, a
	inc l
	ld a, b
	sub [hl]
	ld b, a
	inc l
	ld a, d
	sub [hl]	;$10C6 (a label once; nothing jumps here)
	ld d, a
	inc l
.l10C9
	ld a, [hl+]
	or a
	jr z, .noHit
	ld [$C22A], a
	ld a, [hl+]
	cp c
	jr c, .l10E0
	cp e
	jr nc, .l10E0
	ld a, [hl+]
	cp b
	jr c, .l10C9
	cp d
	jr c, .hit
	jr .l10C9
.l10E0
	inc l
	jr .l10C9

.noHit	;$10E3
	xor a
	ret
.hit
	ld a, $01
	ld [$C236], a
	ld a, [$C22A]
	ld l, a
	ld h, $C2
	ld d, [hl]
	ld a, [$CC46]
	ld e, a
	cp $FF
	jr nz, .l10FD
	ld [hl], $00
	jr .l1108
.l10FD
	cp $FE
	jr nz, .l110F
	ld a, $0A
	call QueueSound
	ld [hl], $80
.l1108
	xor a
	ld d, a
	ld [$C236], a
	jr .l112A
.l110F
	ld a, [wWeaponPierce]
	ld b, a
	bit 0, b
	jr nz, .l1124
	ld a, d
	bit 2, b
	jr z, .l111F
	cp e
	jr nc, .l112A
.l111F
	sub e
	jr nc, .l1123
	xor a
.l1123
	ld [hl], a
.l1124
	bit 1, b
	jr z, .l112A
	ld d, $00
.l112A
	xor a
	inc a
	ld a, d
	ret
.restoreBoxCheckList2
	ldh a, [$FF95]
	ld c, a
	ldh a, [$FF96]
	ld b, a
	ldh a, [$FF97]
	ld e, a
	ldh a, [$FF98]
	ld d, a
.checkList2
	ld hl, wShotList2Active
	ld a, [hl]
	or a
	jp nz, CheckShotListHit
	ret

;ApplyWeaponToObject for an object with flag bit 6 (a boss): clear its freeze
;timer (offset $22), and for types 30-49 except 48 replace the damage in D from
;BossDamageTab (below), scaling Atomic Fire's charge levels. Anything else goes
;on to ApplyWeaponSideEffects. A result of 0 clears $C236.	;[ok]
ApplyBossDamageTab:	;$1143
	ld a, $22
	add a, c
	ld l, a
	xor a
	ld [hl+], a
	ld [hl+], a
	ld a, $07
	add a, c
	ld l, a
	ld a, [hl]

.byType	;$114F
	cp $30
	jr z, .l115B
	sub $1E
	jr c, .l115B
	cp $14
	jr c, .l115E
.l115B
	jp ApplyWeaponSideEffects
.l115E
	srl a
	ld b, h
	ld e, a
	ld d, $00
	ld hl, BossDamageTab
	add hl, de
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [wCurrentWeapon]
	ld e, a
	add hl, de
	ld a, [hl]
	cp $FF
	jr z, .l1177
	ld d, a
.l1177
	ld a, [wCurrentWeapon]
	cp $06
	jr nz, .l11AF
	ld a, d
	or a
	jr z, .l11AF
	add a, a
	add a, a
	add a, d
	ld e, a
	ld a, [wCurrentBank]
	push af
	ld a, $01
	bankswitch
	ld hl, AtomicFireDamage	;bank $01
	ld a, [wWeaponDamage]
	cp [hl]
	jr z, .l11A8
	inc hl
	sla d
	cp [hl]
	jr z, .l11A8
	inc hl
	ld d, e
	cp [hl]
	jr z, .l11A8
	ld d, $00
.l11A8
	pop af
	bankswitch
.l11AF
	ld a, d
	or a
	jr nz, .l11B6
	ld [$C236], a
.l11B6
	ld h, b
	ret
;$11B8: weapon damage against the bosses. The routine above takes the struck
;object's type (offset $07); types 30-49 except 48 pick row (type - 30) / 2,
;anything else keeps the normal damage. Each row has one byte per weapon,
;indexed by wCurrentWeapon (0 = Mega Buster ... 10 = Mirror Buster, plus one
;spare); $FF keeps the normal damage in D. The result is subtracted from the
;object's hit points in the collision pass (step 2.4), and types 30-49 are the
;boss records in ObjectStatsTab (step 2.6). The last row is pointed at twice.	;[ok]
BossDamageTab:
	dw Data_00_11CE, Data_00_11DA, Data_00_11E6, Data_00_11F2, Data_00_11FE, Data_00_120A
	dw Data_00_1216, Data_00_1222, Data_00_122E, Data_00_123A, Data_00_123A
Data_00_11CE:
	db $01, $FF, $01, $FF, $02, $00, $FF, $00, $FF, $FF, $00, $00
Data_00_11DA:
	db $01, $02, $08, $FF, $01, $00, $FF, $00, $FF, $FF, $00, $00
Data_00_11E6:
	db $01, $08, $FF, $FF, $01, $00, $FF, $00, $FF, $FF, $00, $00
Data_00_11F2:
	db $01, $02, $01, $04, $FF, $00, $FF, $00, $FF, $FF, $00, $00
Data_00_11FE:
	db $01, $FF, $FF, $FF, $FF, $00, $FF, $00, $FF, $FF, $00, $00
Data_00_120A:
	db $01, $01, $FF, $01, $FF, $00, $FF, $00, $02, $FF, $00, $00
Data_00_1216:
	db $01, $01, $FF, $02, $01, $00, $01, $00, $FF, $01, $00, $00
Data_00_1222:
	db $01, $FF, $FF, $FF, $FF, $00, $FF, $00, $02, $04, $00, $00
Data_00_122E:
	db $01, $FF, $FF, $01, $01, $00, $02, $00, $FF, $FF, $00, $00
Data_00_123A:
	db $01, $01, $FF, $FF, $01, $00, $02, $00, $01, $01, $00, $00

;$1246: page in the stage's bank, run UpdateRoomTransition and
;QueueScrollColumn, and return to bank $01. Called once a frame from
;UpdatePlayer (bank $01), which is its only caller.	;[ok]
UpdateScrolling:	;$1246
	ld a, [wStageBank]
	bankswitch
	call UpdateRoomTransition
	call QueueScrollColumn
	ld a, $01
	bankswitch
	ret

;If the camera moved this frame ($D84F, from UpdateCamera) and SCX crossed an
;8-pixel boundary since $D854, queue the BG tile column coming into view for
;VBlankDrawColumn: 8 pixels past the right edge when scrolling right, 16 left of
;the screen when scrolling left. On the first of a block's two tile columns to
;come into view, the room layout's column is copied into the $DE00 block grid
;first; then the 8 blocks'
;tile pairs (bytes 0-1 or 2-3 of each blockset entry) go to $DDD0, the map
;address to $D866/$D867 and $10 to $D865. Banks $0B and $0E carry left-edge
;copies.	;[ok]
QueueScrollColumn:	;$125E
	ld a, [$D84F]
	or a
	ret z
	ld a, [$D854]
	ld c, a
	ld a, [wShadowSCX]
	ld b, a
	xor c
	and $08
	ret z
	ld a, [$D84F]
	bit 7, a
	ld a, b
	jp nz, .leftEdge
	add a, $A8
	srl a
	srl a
	srl a

.column	;$1280: A = the BG map column
	ld c, a
	ld a, [wShadowSCY]
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld b, $98
	add hl, bc
	ld a, l
	ld [$D866], a
	ld a, h
	ld [$D867], a
	ld a, [wShadowSCX]
	add a, $A8
	ld e, a
	ld a, [wShadowSCY]
	ld d, a
	ld a, e
	swap a
	and $0F
	ld e, a
	ld a, d
	and $F0
	or e
	bit 0, c
	ld c, a
	ld e, $02
	ld b, $DE
	jr nz, .l12F4
	ld a, [$D80D]
	ld e, a
	ld a, [$D80E]
	ld d, a
	ld hl, $0058
	add hl, de
	ld e, $00
.l12C1
	push de
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	rr h
	rr l
	ld h, $00
	ld a, [wRoomRowPtrs]
	ld e, a
	ld a, [$D878]
	ld d, a
	add hl, de
	ld a, [wRoomWidth]
	ld e, a
	ld d, $00
	ld a, $08
	push bc
.l12E6
	push af
	ld a, [hl]
	ld [bc], a
	add hl, de
	ld a, c
	add a, $10
	ld c, a
	pop af
	dec a
	jr nz, .l12E6
	pop bc
	pop de
.l12F4
	ld a, [wBlocksetPtr]
	add a, e
	ld e, a
	ld a, [wBlocksetPtr + 1]
	adc a, $00
	ld d, a
	ld hl, $DDD0
	ld a, $08
.l1304
	push af
	push hl
	ld b, $DE
	ld a, [bc]
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	add hl, de
	ld a, [hl+]
	ld b, [hl]
	pop hl

	ld [hl+], a
	ld [hl], b
	inc l
	ld a, c
	add a, $10
	ld c, a
	pop af
	dec a
	jr nz, .l1304
	ld a, $10
	ld [$D865], a
	ret
.leftEdge
	add a, $F0
	srl a
	srl a
	srl a
	ld c, a
	ld a, [wShadowSCY]
	and $F8
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld b, $98
	add hl, bc
	ld a, l
	ld [$D866], a
	ld a, h
	ld [$D867], a
	ld a, [wShadowSCX]
	add a, $F0
	ld e, a
	ld a, [wShadowSCY]
	ld d, a
	ld a, e
	swap a
	and $0F
	ld e, a
	ld a, d
	and $F0
	or e
	bit 0, c
	ld c, a
	ld e, $00
	ld b, $DE
	jr z, .l12F4
	ld a, [$D80D]
	ld l, a
	ld a, [$D80E]
	ld h, a
	ld de, $FFA0
	add hl, de
	ld e, $02
	jp .l12C1

;Move the camera with Mega Man. Its X is his stage X ($D80D) while
;GetPlayerScreenX's state ($D85D) is 0, otherwise the scroll limit he is at
;(wScrollMinX if this or last frame's state, $D85E, was 1, else wScrollMaxX);
;last frame's is $D852 (his old X) or the limit the same way. From those it
;sets the camera X ($D80F/$D810), the movement ($D84F, also $D850 and negated
;in $D851), the screen's left edge in stage X ($D811/$D812, camera - $50), adds
;the movement to SCX (old SCX to $D854), and puts the camera's block column in
;$D855 with the spawn window $D856-$D857 six blocks either side.	;[ok]
UpdateCamera:	;$136F
	ld hl, $D85E
	ld c, [hl]
	ld a, [$D85D]
	ld b, a
	ld [hl], a
	ld a, [wScrollMinX]
	ldh [hBank1CallIndex], a
	ld a, [wScrollMinX + 1]
	ldh [$FF92], a
	ld a, b
	or c
	and $01
	jr nz, .l1392
	ld a, [wScrollMaxX]
	ldh [hBank1CallIndex], a
	ld a, [wScrollMaxX + 1]
	ldh [$FF92], a
.l1392
	ld de, $D80D
	ld a, b
	or a
	jr z, .l139C
	ld de, hBank1CallIndex
.l139C
	ld hl, $D852
	ld a, c
	or a
	jr z, .l13A6
	ld hl, hBank1CallIndex
.l13A6
	inc de
	ld a, [de]
	ld [$D810], a
	ld b, a
	dec de
	ld a, [de]
	ld [$D80F], a
	ld c, a
	sub [hl]
	ld [$D84F], a
	ld e, a
	ld a, c
	sub $50
	ld [$D811], a
	ld a, b
	sbc a, $00
	ld [$D812], a
	ld hl, wShadowSCX
	ld a, [hl]
	ld [$D854], a
	add a, e
	ld [hl], a
	ld a, [$D80F]
	ld l, a
	ld a, [$D810]
	srl a
	rr l
	srl a
	rr l
	srl a
	rr l
	srl a
	rr l
	ld a, l
	ld [$D855], a
	sub $06
	jr nc, .l13EC
	xor a
.l13EC
	ld [$D856], a
	ld a, l
	add a, $06
	ld [$D857], a
	ld a, [$D84F]
	ld [$D850], a
	cpl
	inc a
	ld [$D851], a
	ret

;One frame of the vertical scroll between rooms that CheckRoomExits starts
;($D869 = +2 down or -2 up, $D86A = $80 pixels to go). Every 8 pixels it
;queues the next tile row (QueueTransitionRowDown/Up); each frame SCY moves by
;$D869, Mega Man's Y by -/+ $01D0 (1 13/16 px against the scroll, fraction in
;$D868), and $D86A counts down. At 0 it clears $D869 and ClearGridEdgeRows.
;Every call also sets $DDFA = (SCY * 4) & $E0 and $DDFB = SCY & $F0.	;[ok]
UpdateRoomTransition:	;$1401
	ld a, [$D869]
	or a
	jr z, .l1455
	ld a, [$D86A]
	or a
	jr z, .l1467
	ld b, a
	ld a, $80
	sub b
	ld b, a
	ldh [hBank1CallIndex], a
	and $07
	jr nz, .l1427
	ld a, [$D869]
	bit 7, a
	jr nz, .l1424
	call QueueTransitionRowDown
	jr .l1427
.l1424
	call QueueTransitionRowUp
.l1427
	ld de, $01D0
	ld a, [$D869]
	bit 7, a
	jr nz, .l1434
	ld de, $FE30
.l1434
	ld hl, $D868
	ld a, [hl]
	add a, e
	ld [hl], a
	ld hl, wPlayerY
	ld a, d
	adc a, [hl]
	ld [hl], a
	ld hl, wShadowSCY
	ld a, [$D869]
	ld b, a
	add a, [hl]
	ld [hl], a
	ld a, b
	bit 7, a
	jr nz, .l1450
	cpl
	inc a
.l1450
	ld hl, $D86A
	add a, [hl]
	ld [hl], a
.l1455
	ld a, [wShadowSCY]
	ld b, a
	add a, a
	add a, a
	and $E0
	ld [$DDFA], a
	ld a, b
	and $F0
	ld [$DDFB], a
	ret
.l1467
	xor a
	ld [$D869], a
	call ClearGridEdgeRows
	ret

;From the pixels scrolled so far (B), queue the tile row of a downward
;transition: block row B / 16, its top tile row first (E = 0, C = 0) then its
;bottom (E = 1, C = 8).	;[ok]
QueueTransitionRowDown:	;$146F
	ld a, b
	and $08
	ld e, $01
	jr nz, .l1477
	dec e
.l1477
	ld a, b
	and $08
	ld c, a
	ld a, b
	swap a
	and $07
	ld b, a
	call QueueTransitionRow
	ret

;The same for an upward transition: block rows from 7 back to 0, bottom tile
;row first.	;[ok]
QueueTransitionRowUp:	;$1485
	ld a, b
	and $08
	ld e, $01
	jr nz, .l148D
	dec e
.l148D
	ld a, b
	and $08
	xor $08
	ld c, a
	ld a, b
	swap a
	and $07
	ld b, a
	ld a, $07
	sub b
	ld b, a
	call QueueTransitionRow
	ret

;Queue one tile row for VBlankDrawRow: block row B of the new room, tile row C
;(0 top, 8 bottom). When E = 0 (the row's first half to arrive) the room's 12
;blocks from column $D871/$D872 are copied into the $DE00 grid row at $D873
;(CopyToGridRow) and the grid row 7 rows further in the scroll direction is
;cleared (FillGridRow); when
;E = 1, $D873 moves on a row afterwards. The 24 tiles go to $DDE0 from the
;blockset, the map address $D875/$D876 to $D86C/$D86D (then one map row on,
;wrapping inside $9800-$9BFF), and $18 to $D86B.	;[ok]
QueueTransitionRow:	;$14A1
	ld a, c
	ldh [$FF93], a
	ld a, e
	ldh [$FF92], a
	or a
	jr nz, .l14E1
	ld l, b
	ld h, $00
	add hl, hl
	ld de, wRoomRowPtrs
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [$D871]
	ld e, a
	ld a, [$D872]
	ld d, a
	add hl, de
	ld a, [$D873]
	ld e, a
	ld d, $DE
	ld b, $0C
	call CopyToGridRow
	ld a, [$D869]
	bit 7, a
	ld b, $90
	jr nz, .l14D4
	ld b, $70
.l14D4
	ld a, [$D873]
	add a, b
	ld l, a
	ld h, $DE
	ld b, $10
	xor a
	call FillGridRow
.l14E1
	ld a, [$D873]
	ld l, a
	and $F0
	ld c, a
	ld h, $DE
	ld de, $DDE0
	ld b, $0C
.l14EF
	ld a, [hl]
	push bc
	push hl
	ld l, a
	ld h, $00
	add hl, hl
	add hl, hl
	ld a, [wBlocksetPtr]
	ld c, a
	ld a, [wBlocksetPtr + 1]
	ld b, a
	add hl, bc
	ldh a, [$FF93]
	or a
	jr z, .l1506
	inc hl
.l1506
	ld a, [hl+]
	ld [de], a
	inc de
	inc hl
	ld a, [hl]
	ld [de], a
	inc de
	pop hl
	pop bc
	ld a, l
	inc a
	and $0F
	or c
	ld l, a
	dec b
	jr nz, .l14EF
	ldh a, [$FF92]
	or a
	jr z, .l152F
	ld a, [$D869]
	bit 7, a
	ld b, $10
	jr z, .l1528
	ld b, $F0
.l1528
	ld a, [$D873]
	add a, b
	ld [$D873], a
.l152F
	ld a, [$D875]
	ld e, a
	ld [$D86C], a
	ld a, [$D876]
	ld d, a
	ld [$D86D], a
	ld hl, $0020
	ld a, [$D869]
	bit 7, a
	jr z, .l154A
	ld hl, $FFE0
.l154A
	add hl, de
	ld a, h
	and $03
	or $98
	ld [$D876], a
	ld a, l
	ld [$D875], a
	ld a, $18
	ld [$D86B], a
	ret

;Copy B bytes from HL to the block grid at DE, wrapping round inside DE's
;16-byte grid row.	;[ok]
CopyToGridRow:	;$155D
	ld a, e
	and $F0
	ld c, a
.l1561
	ld a, [hl+]
	ld [de], a
	ld a, e
	inc a
	and $0F
	or c
	ld e, a
	dec b
	jr nz, .l1561
	ret

;Fill B bytes of the block grid from HL with A, wrapping round inside HL's
;16-byte grid row.	;[ok]
FillGridRow:	;$156D
	ld d, a
	ld a, l
	and $F0
	ld c, a
.l1572
	ld [hl], d
	ld a, l
	inc a
	and $0F
	or c
	ld l, a
	dec b
	jr nz, .l1572
	ret
