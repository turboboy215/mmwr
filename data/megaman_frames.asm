;Mega Man: Dr. Wily's Revenge disassembly - Mega Man's frames
;Part of ROM bank $01 (step 5.1). Every section is pinned to its original
;address, so the include order in banks/bank01.asm does not affect the ROM.
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Mega Man Frames", ROMX[$701C], BANK[$1]

;Mega Man's frames: a pointer per (animation, facing) - wPlayerAnim is even, wPlayerFacing
;adds the facing - and the metasprites.	;[ok]
MegaManFrames:	;$701C
	dw MegaManFrame0, MegaManFrame1, MegaManFrame2, MegaManFrame3
	dw MegaManFrame4, MegaManFrame5, MegaManFrame6, MegaManFrame7
	dw MegaManFrame8, MegaManFrame9, MegaManFrame10, MegaManFrame11
	dw MegaManFrame12, MegaManFrame13, MegaManFrame14, MegaManFrame15
	dw MegaManFrame16, MegaManFrame16, MegaManFrame17, MegaManFrame17
	dw MegaManFrame18, MegaManFrame19, MegaManFrame20, MegaManFrame21
	dw MegaManFrame22, MegaManFrame22, MegaManFrame23, MegaManFrame24
	dw MegaManFrame25, MegaManFrame25, MegaManFrame26, MegaManFrame27
	dw MegaManFrame28, MegaManFrame29, MegaManFrame30, MegaManFrame31
	dw MegaManFrame32, MegaManFrame33, MegaManFrame34, MegaManFrame35
	dw MegaManFrame36, MegaManFrame37, MegaManFrame38, MegaManFrame38
	dw MegaManFrame39, MegaManFrame39, MegaManFrame40, MegaManFrame40
	dw MegaManFrame41, MegaManFrame41

MegaManFrame0:	;$7080
	db $F3, $F4, $33	;dx, dy, 3x3
	db $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24
	db $80

MegaManFrame1:	;$708D
	db $F6, $F4, $33	;dx, dy, 3x3
	db $9E, $9D, $9C, $A1, $A0, $9F, $A4, $A3, $A2
	db $80

MegaManFrame2:	;$709A
	db $F3, $F4, $33	;dx, dy, 3x3
	db $1C, $25, $1E, $1F, $26, $21, $22, $23, $24
	db $80

MegaManFrame3:	;$70A7
	db $F6, $F4, $33	;dx, dy, 3x3
	db $9E, $A5, $9C, $A1, $A6, $9F, $A4, $A3, $A2
	db $80

MegaManFrame4:	;$70B4
	db $F3, $F4, $33	;dx, dy, 3x3
	db $1C, $1D, $1E, $1F, $20, $21, $27, $28, $24
	db $80

MegaManFrame5:	;$70C1
	db $F6, $F4, $33	;dx, dy, 3x3
	db $9E, $9D, $9C, $A1, $A0, $9F, $A4, $A8, $A7
	db $80

MegaManFrame6:	;$70CE
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

MegaManFrame7:	;$70DB
	db $F5, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $83, $88, $87, $86
	db $80

MegaManFrame8:	;$70E8
	db $F9, $F4, $23	;dx, dy, 2x3
	db $09, $0A, $0B, $0C, $0D, $0E
	db $80

MegaManFrame9:	;$70F2
	db $F8, $F4, $23	;dx, dy, 2x3
	db $8A, $89, $8C, $8B, $8E, $8D
	db $80

MegaManFrame10:	;$70FC
	db $F7, $F4, $33	;dx, dy, 3x3
	db $0F, $10, $FF, $11, $12, $13, $14, $15, $16
	db $80

MegaManFrame11:	;$7109
	db $F2, $F4, $33	;dx, dy, 3x3
	db $FF, $90, $8F, $93, $92, $91, $96, $95, $94
	db $80

MegaManFrame12:	;$7116
	db $F4, $F4, $33	;dx, dy, 3x3
	db $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F
	db $08, $18, $40
	db $80

MegaManFrame13:	;$7126
	db $F5, $F4, $33	;dx, dy, 3x3
	db $B9, $B8, $B7, $BC, $BB, $BA, $BF, $BE, $BD
	db $08, $18, $C0
	db $80

MegaManFrame14:	;$7136
	db $F4, $F4, $33	;dx, dy, 3x3
	db $41, $38, $39, $42, $3B, $3C, $3D, $3E, $3F
	db $08, $18, $40
	db $FC, $08, $2B
	db $80

MegaManFrame15:	;$7149
	db $F5, $F4, $33	;dx, dy, 3x3
	db $B9, $B8, $C1, $BC, $BB, $C2, $BF, $BE, $BD
	db $08, $18, $C0
	db $14, $08, $AB
	db $80

MegaManFrame16:	;$715C
	db $F9, $F4, $24	;dx, dy, 2x4
	db $C8, $C7, $CA, $C9, $CC, $CB, $FF, $CD
	db $80

MegaManFrame17:	;$7168
	db $F8, $F4, $24	;dx, dy, 2x4
	db $47, $48, $49, $4A, $4B, $4C, $4D, $FF
	db $80

MegaManFrame18:	;$7174
	db $F8, $F4, $24	;dx, dy, 2x4
	db $4E, $4F, $50, $51, $52, $4C, $4D, $FF
	db $F8, $08, $2B
	db $80

MegaManFrame19:	;$7183
	db $F9, $F4, $24	;dx, dy, 2x4
	db $CF, $CE, $D1, $D0, $CC, $D2, $FF, $CD
	db $10, $08, $AB
	db $80

MegaManFrame20:	;$7192
	db $F8, $F4, $24	;dx, dy, 2x4
	db $4E, $4F, $50, $51, $52, $4C, $4D, $FF
	db $F8, $08, $32
	db $80

MegaManFrame21:	;$71A1
	db $F9, $F4, $24	;dx, dy, 2x4
	db $CF, $CE, $D1, $D0, $CC, $D2, $FF, $CD
	db $10, $08, $B2
	db $80

MegaManFrame22:	;$71B0
	db $F8, $FC, $23	;dx, dy, 2x3
	db $43, $C3, $44, $45, $46, $FF
	db $80

MegaManFrame23:	;$71BA
	db $F5, $F1, $33	;dx, dy, 3x3
	db $53, $54, $55, $56, $57, $58, $3D, $59, $5A
	db $08, $18, $5B
	db $80

MegaManFrame24:	;$71CA
	db $F3, $F1, $33	;dx, dy, 3x3
	db $D5, $D4, $D3, $D8, $D7, $D6, $DA, $D9, $BD
	db $08, $18, $DB
	db $80

MegaManFrame25:	;$71DA
	db $F5, $F4, $33	;dx, dy, 3x3
	db $5C, $5D, $5E, $5F, $64, $DF, $DE, $DD, $DC
	db $80

MegaManFrame26:	;$71E7
	db $F4, $F4, $33	;dx, dy, 3x3
	db $29, $2A, $FF, $2C, $2D, $2E, $2F, $30, $31
	db $F8, $08, $2B
	db $80

MegaManFrame27:	;$71F7
	db $F5, $F4, $33	;dx, dy, 3x3
	db $FF, $AA, $A9, $AE, $AD, $AC, $B1, $B0, $AF
	db $18, $08, $AB
	db $80

MegaManFrame28:	;$7207
	db $F4, $F4, $33	;dx, dy, 3x3
	db $29, $2A, $FF, $2C, $2D, $2E, $2F, $30, $31
	db $F8, $08, $32
	db $80

MegaManFrame29:	;$7217
	db $F5, $F4, $33	;dx, dy, 3x3
	db $FF, $AA, $A9, $AE, $AD, $AC, $B1, $B0, $AF
	db $18, $08, $B2
	db $80

MegaManFrame30:	;$7227
	db $F4, $F4, $33	;dx, dy, 3x3
	db $29, $2A, $FF, $34, $2D, $2E, $36, $30, $31
	db $F8, $08, $33
	db $F8, $10, $35
	db $80

MegaManFrame31:	;$723A
	db $F5, $F4, $33	;dx, dy, 3x3
	db $FF, $AA, $A9, $AE, $AD, $B4, $B1, $B0, $B6
	db $18, $08, $B3
	db $18, $10, $B5
	db $80

MegaManFrame32:	;$724D
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $17, $04, $05, $18, $07, $08
	db $FB, $09, $2B
	db $80

MegaManFrame33:	;$725D
	db $F5, $F4, $33	;dx, dy, 3x3
	db $82, $81, $80, $85, $84, $97, $88, $87, $98
	db $15, $09, $AB
	db $80

MegaManFrame34:	;$726D
	db $F1, $F4, $33	;dx, dy, 3x3
	db $FF, $09, $0A, $63, $19, $0C, $FF, $0D, $0E
	db $FE, $07, $2B
	db $80

MegaManFrame35:	;$727D
	db $F8, $F4, $33	;dx, dy, 3x3
	db $8A, $89, $FF, $8C, $99, $E3, $8E, $8D, $FF
	db $12, $07, $AB
	db $80

MegaManFrame36:	;$728D
	db $F7, $F4, $33	;dx, dy, 3x3
	db $0F, $10, $FF, $1A, $1B, $FF, $14, $15, $16
	db $F8, $09, $2B
	db $80

MegaManFrame37:	;$729D
	db $F2, $F3, $33	;dx, dy, 3x3
	db $FF, $90, $8F, $FF, $9B, $9A, $96, $95, $94
	db $18, $09, $AB
	db $80

MegaManFrame38:	;$72AD
	db $00, $00, $11	;dx, dy, 1x1
	db $FF
	db $80

MegaManFrame39:	;$72B2
	db $FC, $EC, $14	;dx, dy, 1x4
	db $67, $67, $67, $67
	db $80

MegaManFrame40:	;$72BA
	db $F4, $E7, $34	;dx, dy, 3x4
	db $FF, $6A, $FF, $69, $6A, $E9, $69, $6A, $E9, $68, $6B, $E8
	db $80

MegaManFrame41:	;$72CA
	db $F4, $EC, $32	;dx, dy, 3x2
	db $69, $6A, $E9, $68, $6B, $E8
	db $80
