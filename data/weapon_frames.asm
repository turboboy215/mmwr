;Mega Man: Dr. Wily's Revenge disassembly - the weapons' frame tables and frames
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Weapon Frames", ROMX[$5098], BANK[$1]

;Weapon frame tables, one per weapon, and the frames they point at. A frame
;is a 4-byte hitbox (x1, x2, y1, y2 relative to the shot; SetShotFrame copies it
;to the hit list's hitbox) followed by a DrawMetasprite metasprite.	;[ok]
RollingCutterFrames:	;$5098
	dw RollingCutterFrame0, RollingCutterFrame1, RollingCutterFrame2, RollingCutterFrame3

RollingCutterFrame0:	;$50A0
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $80, $01, $81
	db $80

RollingCutterFrame1:	;$50AC
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $02, $03, $42, $43
	db $80

RollingCutterFrame2:	;$50B8
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $41, $C1, $40, $C0
	db $80

RollingCutterFrame3:	;$50C4
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $83, $82, $C3, $C2
	db $80

ThunderBeamFrames:	;$50D0
	dw ThunderBeamFrame0, ThunderBeamFrame1, ThunderBeamFrame2

ThunderBeamFrame0:	;$50D6
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $00, $01, $02, $03, $04, $05
	db $80

ThunderBeamFrame1:	;$50E4
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $04, $05, $00, $01, $02, $03
	db $80

ThunderBeamFrame2:	;$50F2
	db $F8, $07, $F4, $0B	;hitbox
	db $F8, $F4, $23	;dx, dy, 2x3
	db $02, $03, $04, $05, $00, $01
	db $80

IceSlasherFrames:	;$5100
	dw IceSlasherFrame0, IceSlasherFrame1, IceSlasherFrame2, IceSlasherFrame3

IceSlasherFrame0:	;$5108
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

IceSlasherFrame1:	;$5114
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

IceSlasherFrame2:	;$5120
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

IceSlasherFrame3:	;$512C
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80

FireStormFrames:	;$5138
	dw FireStormFrame0, FireStormFrame1, FireStormFrame2, FireStormFrame3
	dw FireStormFrame4, FireStormFrame5, FireStormFrame6, FireStormFrame7
	dw FireStormFrame8

FireStormFrame0:	;$514A
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $00, $01, $40, $41
	db $80

FireStormFrame1:	;$5156
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $02, $03, $42, $43
	db $80

FireStormFrame2:	;$5162
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $04, $05, $44, $45
	db $80

FireStormFrame3:	;$516E
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $81, $80, $C1, $C0
	db $80

FireStormFrame4:	;$517A
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $83, $82, $C3, $C2
	db $80

FireStormFrame5:	;$5186
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $85, $84, $C5, $C4
	db $80

FireStormFrame6:	;$5192
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $06, $86, $46, $C6
	db $80

FireStormFrame7:	;$519E
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $07, $87, $47, $C7
	db $80

FireStormFrame8:	;$51AA
	db $F8, $07, $F8, $07	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $08
	db $80

CarryFrames:	;$51B3
	dw CarryFrame0, CarryFrame1, CarryFrame2

CarryFrame0:	;$51B9
	db $F4, $0B, $FC, $08	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $03, $04, $05
	db $80

CarryFrame1:	;$51C7
	db $F4, $0B, $FC, $08	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $06, $07, $08
	db $80

CarryFrame2:	;$51D5
	db $F4, $0B, $FC, $08	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $00, $01, $02, $09, $0A, $0B
	db $80

AtomicFireFrames:	;$51E3
	dw AtomicFireFrame0, AtomicFireFrame1, AtomicFireFrame2, AtomicFireFrame3
	dw AtomicFireFrame4, AtomicFireFrame5

AtomicFireFrame0:	;$51EF
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $80, $02, $03, $82, $40, $41, $C0
	db $80

AtomicFireFrame1:	;$5200
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F5, $33	;dx, dy, 3x3
	db $04, $05, $84, $06, $07, $86, $44, $45, $C4
	db $80

AtomicFireFrame2:	;$5211
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $08, $88, $48, $C8
	db $80

AtomicFireFrame3:	;$521D
	db $F8, $07, $F8, $07	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $09, $89, $49, $C9
	db $80

AtomicFireFrame4:	;$5229
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $0A
	db $80

AtomicFireFrame5:	;$5232
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $0B
	db $80

TimeStopperFrames:	;$523B
	dw TimeStopperFrame0, TimeStopperFrame1, TimeStopperFrame2, TimeStopperFrame3

TimeStopperFrame0:	;$5243
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $00
	db $80

TimeStopperFrame1:	;$524C
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $01
	db $80

TimeStopperFrame2:	;$5255
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $02
	db $80

TimeStopperFrame3:	;$525E
	db $00, $00, $00, $00	;hitbox
	db $FC, $FD, $11	;dx, dy, 1x1
	db $FF
	db $80

QuickBoomerangFrames:	;$5267
	dw QuickBoomerangFrame0, QuickBoomerangFrame1, QuickBoomerangFrame2, QuickBoomerangFrame3

QuickBoomerangFrame0:	;$526F
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

QuickBoomerangFrame1:	;$5278
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $01
	db $80

QuickBoomerangFrame2:	;$5281
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $40
	db $80

QuickBoomerangFrame3:	;$528A
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $C1
	db $80

BubbleLeadFrames:	;$5293
	dw BubbleLeadFrame0, BubbleLeadFrame1, BubbleLeadFrame2

BubbleLeadFrame0:	;$5299
	db $FA, $05, $F9, $06	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $00, $01, $C1, $41
	db $80

BubbleLeadFrame1:	;$52A5
	db $FA, $05, $F9, $06	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $02, $03, $04, $05
	db $80

BubbleLeadFrame2:	;$52B1
	db $FA, $05, $F9, $06	;hitbox
	db $F8, $F9, $22	;dx, dy, 2x2
	db $06, $07, $08, $09
	db $80

MirrorBusterFrames:	;$52BD
	dw MirrorBusterFrame0, MirrorBusterFrame1, MirrorBusterFrame2, MirrorBusterFrame3
	dw MirrorBusterFrame4, MirrorBusterFrame5, MirrorBusterFrame6, MirrorBusterFrame7
	dw MirrorBusterFrame8, MirrorBusterFrame9, MirrorBusterFrame10, MirrorBusterFrame11
	dw MirrorBusterFrame12, MirrorBusterFrame13, MirrorBusterFrame14

MirrorBusterFrame14:	;$52DB
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $00	;dx, dy, 0x0

MirrorBusterFrame0:	;$52E2
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $00
	db $80

MirrorBusterFrame1:	;$52EB
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $01
	db $80

MirrorBusterFrame2:	;$52F4
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $02
	db $80

MirrorBusterFrame3:	;$52FD
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $41
	db $80

MirrorBusterFrame4:	;$5306
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $40
	db $80

MirrorBusterFrame5:	;$530F
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $C1
	db $80

MirrorBusterFrame6:	;$5318
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $82
	db $80

MirrorBusterFrame7:	;$5321
	db $FC, $03, $FC, $03	;hitbox
	db $FC, $FC, $11	;dx, dy, 1x1
	db $81
	db $80

MirrorBusterFrame8:	;$532A
	db $F4, $05, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $03, $04, $43
	db $80

MirrorBusterFrame9:	;$5335
	db $F4, $05, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $05, $06, $45
	db $80

MirrorBusterFrame10:	;$5340
	db $F4, $05, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $07, $08, $47
	db $80

MirrorBusterFrame11:	;$534B
	db $FA, $0A, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $83, $84, $C3
	db $80

MirrorBusterFrame12:	;$5356
	db $FA, $0A, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $85, $86, $C5
	db $80

MirrorBusterFrame13:	;$5361
	db $FA, $0A, $F4, $0B	;hitbox
	db $FC, $F4, $13	;dx, dy, 1x3
	db $87, $88, $C7
	db $80
