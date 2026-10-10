;Mega Man: Dr. Wily's Revenge disassembly - the Wily Machine types' animations, frames and
;background tiles
;Part of ROM bank $0D (step 5.6), included from banks/bank0d.asm. Every section is
;pinned to its original address. Confidence tags: [ok] verified here, [dc]
;corroborated by Data Crystal, [?] guess.

SECTION "Wily Machine Data", ROMX[$527A], BANK[$D]

;The Wily Machine types' animations, all on FrameTable_0D_52C4: this one runs
;through all 22 frames (only the unused $4981 uses it); then type 49, type 48
;(the cockpit), type 50, type 51, type 51 sent back, Dr. Wily falling, landed.	;[ok]
Data_0D_527A:	;$527A
	dw FrameTable_0D_52C4
	db 1	;frames per step
	db $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $FF
Data_0D_5294:	;$5294
	dw FrameTable_0D_52C4
	db 8	;frames per step
	db $0A, $0B, $FF
Data_0D_529A:	;$529A
	dw FrameTable_0D_52C4
	db 8	;frames per step
	db $0F, $10, $FF
Data_0D_52A0:	;$52A0
	dw FrameTable_0D_52C4
	db 4	;frames per step
	db $00, $01, $02, $01, $FF
Data_0D_52A8:	;$52A8
	dw FrameTable_0D_52C4
	db 4	;frames per step
	db $07, $08, $09, $08, $FF
Data_0D_52B0:	;$52B0
	dw FrameTable_0D_52C4
	db 4	;frames per step
	db $0C, $0D, $0E, $0C, $FF
Data_0D_52B8:	;$52B8
	dw FrameTable_0D_52C4
	db 4	;frames per step
	db $11, $12, $FF
Data_0D_52BE:	;$52BE
	dw FrameTable_0D_52C4
	db 12	;frames per step
	db $13, $14, $FF

FrameTable_0D_52C4:	;$52C4
	dw Frame_0D_52F0, Frame_0D_5301, Frame_0D_5312, Frame_0D_5323
	dw Frame_0D_5334, Frame_0D_5345, Frame_0D_5356, Frame_0D_5360
	dw Frame_0D_536A, Frame_0D_5374, Frame_0D_537E, Frame_0D_538F
	dw Frame_0D_53A0, Frame_0D_53AA, Frame_0D_53B4, Frame_0D_53BE
	dw Frame_0D_53CC, Frame_0D_53DA, Frame_0D_53EE, Frame_0D_5402
	dw Frame_0D_5416, Frame_0D_542A

Frame_0D_52F0:	;$52F0
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0B, $0C, $0D, $0E, $0F, $10, $FF, $11, $12
	db $80

Frame_0D_5301:	;$5301
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0B, $0C, $0D, $13, $14, $15, $16, $17, $18
	db $80

Frame_0D_5312:	;$5312
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $0B, $0C, $0D, $19, $1A, $1B, $FF, $1C, $1D
	db $80

Frame_0D_5323:	;$5323
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8D, $8C, $8B, $90, $8F, $8E, $92, $91, $FF
	db $80

Frame_0D_5334:	;$5334
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8D, $8C, $8B, $95, $94, $93, $98, $97, $96
	db $80

Frame_0D_5345:	;$5345
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $8D, $8C, $8B, $9B, $9A, $99, $9D, $9C, $FF
	db $80

Frame_0D_5356:	;$5356
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $24, $25
	db $80

Frame_0D_5360:	;$5360
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $1E, $1F
	db $80

Frame_0D_536A:	;$536A
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $20, $21
	db $80

Frame_0D_5374:	;$5374
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $22, $23
	db $80

Frame_0D_537E:	;$537E
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $04, $05, $06, $07, $08
	db $80

Frame_0D_538F:	;$538F
	db $F4, $0B, $F4, $0B	;hitbox
	db $F4, $F4, $33	;dx, dy, 3x3
	db $00, $01, $02, $03, $09, $05, $06, $0A, $08
	db $80

Frame_0D_53A0:	;$53A0
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $9F, $9E
	db $80

Frame_0D_53AA:	;$53AA
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $A1, $A0
	db $80

Frame_0D_53B4:	;$53B4
	db $F8, $07, $FC, $03	;hitbox
	db $F8, $FC, $21	;dx, dy, 2x1
	db $A3, $A2
	db $80

Frame_0D_53BE:	;$53BE
	db $F4, $23, $F5, $45	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $26, $27, $28, $31, $32, $33
	db $80

Frame_0D_53CC:	;$53CC
	db $F4, $23, $F5, $45	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $2F, $30, $28, $34, $35, $36
	db $80

Frame_0D_53DA:	;$53DA
	db $F0, $0F, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $42
	db $80

Frame_0D_53EE:	;$53EE
	db $F0, $0F, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $43, $44, $45, $3A, $46, $3C, $47, $48, $49, $4A, $4B, $4C
	db $80

Frame_0D_5402:	;$5402
	db $F0, $0F, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $4D, $4E, $4F, $FF, $50, $51, $52, $53, $54, $55, $56, $57
	db $80

Frame_0D_5416:	;$5416
	db $F0, $0F, $F4, $0B	;hitbox
	db $F0, $F4, $43	;dx, dy, 4x3
	db $58, $FF, $59, $FF, $5A, $5B, $5C, $5D, $5E, $5F, $60, $57
	db $80

Frame_0D_542A:	;$542A
	db $F4, $0B, $F8, $07	;hitbox
	db $F4, $F8, $32	;dx, dy, 3x2
	db $A8, $A7, $A6, $AB, $AA, $A9
	db $80

Data_0D_5438:	;$5438
	dw FrameTable_0D_543E
	db 2	;frames per step
	db $00, $02, $FF

FrameTable_0D_543E:	;$543E
	dw Frame_0D_5446, Frame_0D_5452, Frame_0D_545E, Frame_0D_546A

Frame_0D_5446:	;$5446
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $00, $01, $02, $03
	db $80

Frame_0D_5452:	;$5452
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $81, $80, $83, $82
	db $80

Frame_0D_545E:	;$545E
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $04, $05, $06, $07
	db $80

Frame_0D_546A:	;$546A
	db $FA, $05, $FA, $05	;hitbox
	db $F8, $F8, $22	;dx, dy, 2x2
	db $85, $84, $87, $86
	db $80

;Background tiles $00-$4F of the Wily Machine room, streamed in by type 48: its
;blockset draws the machine with these (gfx/wily_machine/room.png). Not the
;same bytes as bank $06's Wily Machine cutscene tiles, which only look alike.	;[ok]
WilyMachineRoomTiles:	;$5476
	INCBIN "gfx/wily_machine/room.2bpp"
WilyMachineRoomTilesEnd:

;16 tiles streamed over tiles $00-$0F when phase 2 begins: the dome is gone
;(gfx/wily_machine/room_dome_open.png).	;[ok]
WilyMachineDomeOpenTiles:	;$5976
	INCBIN "gfx/wily_machine/room_dome_open.2bpp"
WilyMachineDomeOpenTilesEnd:
