;Mega Man: Dr. Wily's Revenge disassembly - per-type object tables
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Object Table Pointers", ROM0[$01B9]

;$01B9: pointers to the two per-type tables, read by banks $03, $09 and $0D
;(each has `ld hl,$01B9` and `ld a,[$01BB]` patterns at matching offsets).	;[?]
ObjectTablePtrs: ; $1B9
	dw ObjectStatsTab
	dw ObjectTypeTab

SECTION "Object Tables", ROM0[$34D3]

;$34D3: per-type spawn attributes, eight bytes per object type, one-based
;(SpawnObject reads it from $34D3 - 8). What SpawnObject does with each byte:
;  oam	OAM entries for AllocSprite; 0 = no sprite (handle $40)
;  dx, dy	signed offsets added to the spawn position (X 16-bit, Y 8-bit)
;  hp	-> offset $18, the hit points weapon damage is taken from
;		($FE/$FF on many types - presumably ones not meant to die)
;  touch	-> offset $1A, added to $D838 when it touches Mega Man
;  flags	-> offset $11: bit 0 hurts Mega Man, bit 2 visible, bit 6 boss
;		(see UpdateObjects), others as in the collision pass
;  b6	-> offset $03, $07 or $1E/$19 - meaning not traced
;  b7	always 0 and never read
;Types 30-47 alternate a boss (hp $13, flag bit 6) with a companion whose hp
;is $FF; 48 and 49 are both boss records. BossDamageTab ($11B8) covers types
;30-49 in pairs and skips 48.	;[ok]
MACRO objstats
	db \1, \2, \3, \4, \5, \6, \7, \8
ENDM

ObjectStatsTab::	;$34D3
	objstats $04, $08, $08, $08, $02, $05, $07, $00	;type 1
	objstats $03, $08, $08, $03, $03, $05, $07, $00	;type 2
	objstats $02, $08, $08, $01, $03, $05, $07, $00	;type 3
	objstats $0B, $0C, $05, $0A, $03, $05, $07, $00	;type 4
	objstats $04, $08, $F8, $FE, $03, $05, $07, $00	;type 5
	objstats $14, $00, $FC, $08, $05, $05, $07, $00	;type 6
	objstats $06, $00, $00, $01, $03, $05, $07, $00	;type 7
	objstats $01, $08, $07, $00, $00, $04, $07, $00	;type 8
	objstats $04, $00, $00, $FE, $00, $06, $07, $00	;type 9
	objstats $0C, $08, $08, $FE, $04, $85, $07, $00	;type 10
	objstats $04, $00, $00, $FE, $02, $05, $07, $00	;type 11
	objstats $14, $00, $00, $0A, $04, $05, $07, $00	;type 12
	objstats $04, $00, $00, $FE, $08, $05, $07, $00	;type 13
	objstats $08, $00, $00, $03, $05, $05, $07, $00	;type 14
	objstats $06, $00, $00, $64, $00, $06, $07, $00	;type 15
	objstats $04, $08, $08, $FE, $00, $06, $07, $00	;type 16
	objstats $09, $08, $08, $01, $03, $05, $07, $00	;type 17
	objstats $03, $00, $00, $03, $04, $15, $07, $00	;type 18
	objstats $05, $00, $00, $01, $03, $05, $07, $00	;type 19
	objstats $04, $08, $09, $FE, $00, $00, $07, $00	;type 20
	objstats $04, $08, $08, $05, $04, $05, $07, $00	;type 21
	objstats $0C, $00, $00, $FE, $04, $85, $07, $00	;type 22
	objstats $00, $08, $08, $FE, $04, $00, $07, $00	;type 23
	objstats $02, $08, $0C, $06, $04, $05, $07, $00	;type 24
	objstats $04, $08, $00, $02, $02, $05, $07, $00	;type 25
	objstats $02, $00, $00, $FE, $02, $05, $07, $00	;type 26
	objstats $04, $00, $00, $01, $03, $05, $07, $00	;type 27
	objstats $01, $00, $00, $01, $02, $05, $07, $00	;type 28
	objstats $04, $08, $08, $14, $00, $07, $07, $00	;type 29
	objstats $0B, $00, $00, $13, $03, $45, $1E, $00	;type 30
	objstats $04, $00, $00, $FF, $03, $85, $07, $00	;type 31
	objstats $0C, $00, $00, $13, $03, $45, $1E, $00	;type 32
	objstats $04, $00, $00, $FF, $08, $85, $07, $00	;type 33
	objstats $10, $00, $00, $13, $02, $45, $1E, $00	;type 34
	objstats $06, $00, $00, $FF, $03, $85, $07, $00	;type 35
	objstats $0C, $00, $00, $13, $04, $45, $1E, $00	;type 36
	objstats $06, $00, $00, $FE, $04, $85, $07, $00	;type 37
	objstats $10, $00, $00, $13, $04, $45, $19, $00	;type 38
	objstats $03, $00, $00, $FE, $02, $05, $07, $00	;type 39
	objstats $0D, $00, $00, $13, $04, $65, $1E, $00	;type 40
	objstats $04, $00, $00, $FF, $04, $85, $07, $00	;type 41
	objstats $10, $00, $00, $13, $04, $65, $1E, $00	;type 42
	objstats $04, $00, $00, $FF, $00, $05, $07, $00	;type 43
	objstats $10, $00, $00, $13, $04, $65, $1E, $00	;type 44
	objstats $01, $00, $00, $FF, $02, $85, $07, $00	;type 45
	objstats $10, $00, $00, $13, $04, $65, $1E, $00	;type 46
	objstats $01, $00, $00, $FF, $02, $85, $07, $00	;type 47
	objstats $09, $00, $00, $13, $03, $40, $1E, $00	;type 48
	objstats $09, $00, $00, $13, $03, $65, $1E, $00	;type 49
	objstats $09, $00, $00, $FF, $04, $25, $07, $00	;type 50
	objstats $02, $00, $00, $FE, $02, $25, $1E, $00	;type 51
	objstats $04, $08, $08, $08, $04, $05, $1E, $00	;type 52
	objstats $01, $08, $08, $13, $01, $04, $07, $00	;type 53
	objstats $00, $00, $00, $13, $00, $20, $00, $00	;type 54
	objstats $10, $08, $08, $13, $00, $06, $00, $00	;type 55
	objstats $0F, $08, $08, $13, $00, $04, $00, $00	;type 56
ObjectStatsTabEnd::


;$3693: object handler table. One four-byte record per object type:
;
;	dw <entry point>   ; always a slot in the target bank's jp table at $4000
;	db <bank>          ; paged in before the handler is called
;	db $00             ; unused in every one of the 56 records
;
;This is how banks $03, $09 and $0D are reached - nothing switches to them with a
;literal. The object's record carries its bank at offset OBJ_BANK, and the far-call
;sites at $28A3 and $2A5B read it back and page it in before jumping to the handler.
;
;Every `jp` slot in each of those three banks is referenced exactly once and in
;order - 22 in $03, 24 in $09, 9 in $0D - so the three banks exist to hold object
;behaviour code and this table is their complete index. The 56th target is a lone
;bank $01 address.
;
;Types are one-based: SpawnObject indexes `ObjectTypeTab - 4` and LoadObjectTiles
;`ObjectTilesetPtrs - 2`, so the first record is type 1. (Before step 2.4 these
;comments counted from 0.) The type names are not known yet; the slot number in
;each comment is the index into the target bank's jp table.	;[ok]
MACRO objtype
	dw \1
	db \2
	db 0
ENDM

ObjectTypeTab::	;$3693
	objtype $4000, $03	;type  1: bank $03 slot  0 - Cutting Wheel (Will)	;[ok]
	objtype $4006, $03	;type  2: bank $03 slot  2 - Screw Driver (Will)	;[ok]
	objtype $4009, $03	;type  3: bank $03 slot  3 - Gabyoall (Will)	;[ok]
	objtype $402A, $09	;type  4: bank $09 slot 14
	objtype $4003, $03	;type  5: bank $03 slot  1 - Super Cutter (Will)	;[ok]
	objtype $400C, $03	;type  6: bank $03 slot  4 - Bigeye (Will)	;[ok]
	objtype $400F, $03	;type  7: bank $03 slot  5 - Bunby Heli (Will)	;[ok]
	objtype $5450, $01	;type  8: bank $01, not an entry slot
	objtype $4012, $03	;type  9: bank $03 slot  6 - fan (Will)	;[ok]
	objtype $4000, $09	;type 10: bank $09 slot  0
	objtype $4003, $09	;type 11: bank $09 slot  1
	objtype $4006, $09	;type 12: bank $09 slot  2
	objtype $4009, $09	;type 13: bank $09 slot  3
	objtype $400C, $09	;type 14: bank $09 slot  4
	objtype $400F, $09	;type 15: bank $09 slot  5
	objtype $4015, $03	;type 16: bank $03 slot  7 - ice platform that melts (Will)	;[ok]
	objtype $403C, $03	;type 17: bank $03 slot 20 - Metall (Will)	;[ok]
	objtype $403F, $03	;type 18: bank $03 slot 21 - Mole (Will)	;[ok]
	objtype $4012, $09	;type 19: bank $09 slot  6
	objtype $4018, $03	;type 20: bank $03 slot  8 - appearing blocks (Will)	;[ok]
	objtype $401B, $03	;type 21: bank $03 slot  9 - Suzy (Will)	;[ok]
	objtype $401E, $03	;type 22: bank $03 slot 10 - electric beam (Will)	;[ok]
	objtype $4021, $03	;type 23: bank $03 slot 11 - icicle (Will)	;[ok]
	objtype $4015, $09	;type 24: bank $09 slot  7
	objtype $4018, $09	;type 25: bank $09 slot  8
	objtype $401B, $09	;type 26: bank $09 slot  9
	objtype $401E, $09	;type 27: bank $09 slot 10
	objtype $4021, $09	;type 28: bank $09 slot 11
	objtype $402D, $09	;type 29: bank $09 slot 15 - Atomic Fire block (Will)	;[ok]
	objtype $4024, $03	;type 30: bank $03 slot 12
	objtype $4027, $03	;type 31: bank $03 slot 13 - Cut Man's Rolling Cutter (Will)	;[ok]
	objtype $402A, $03	;type 32: bank $03 slot 14
	objtype $402D, $03	;type 33: bank $03 slot 15 - Ice Man's Ice Slasher (Will)	;[ok]
	objtype $4030, $03	;type 34: bank $03 slot 16
	objtype $4033, $03	;type 35: bank $03 slot 17
	objtype $4036, $03	;type 36: bank $03 slot 18
	objtype $4039, $03	;type 37: bank $03 slot 19 - Fire Storm (Will)	;[ok]
	objtype $4027, $09	;type 38: bank $09 slot 13 - Enker (step 4.3)	;[ok]
	objtype $4024, $09	;type 39: bank $09 slot 12 - Mirror Buster? (Will)	;[?]
	objtype $4030, $09	;type 40: bank $09 slot 16 - Bubble Man (step 4.3)	;[ok]
	objtype $4033, $09	;type 41: bank $09 slot 17 - Bubble Man's Bubble Lead (Will)	;[ok]
	objtype $4036, $09	;type 42: bank $09 slot 18 - Flash Man (step 4.3)	;[ok]
	objtype $4039, $09	;type 43: bank $09 slot 19
	objtype $403C, $09	;type 44: bank $09 slot 20 - Heat Man (step 4.3)	;[ok]
	objtype $403F, $09	;type 45: bank $09 slot 21 - Heat Man's Atomic Fire (Will)	;[ok]
	objtype $400F, $0D	;type 46: bank $0D slot  5 - Quick Man (step 4.3)	;[ok]
	objtype $4012, $0D	;type 47: bank $0D slot  6 - Quick Man's Quick Boomerang (Will)	;[ok]
	objtype $4000, $0D	;type 48: bank $0D slot  0 - Dr. Wily and the Wily Machine's sprite parts, including the wheel enemy (Will)	;[ok]
	objtype $4003, $0D	;type 49: bank $0D slot  1 - Wily Machine phase 1: the lower cannon (no official name - Will), throws type 52	;[ok]
	objtype $4006, $0D	;type 50: bank $0D slot  2 - Wily Machine phase 2: the biting head (no official name - Will)	;[ok]
	objtype $4009, $0D	;type 51: bank $0D slot  3 - Wily Machine phase 2: the cannon's shot, which Mirror Buster sends back (step 5.6)	;[ok]
	objtype $400C, $0D	;type 52: bank $0D slot  4 - the Wily fight's Cutting Wheel, thrown by the lower cannon (Will)	;[ok]
	objtype $4015, $0D	;type 53: bank $0D slot  7 - light on an active teleporter (Will; spawned with its number 0-4 as Y)	;[ok]
	objtype $4042, $09	;type 54: bank $09 slot 22
	objtype $4045, $09	;type 55: bank $09 slot 23 - boss door (Will)	;[ok]
	objtype $4018, $0D	;type 56: bank $0D slot  8 - the "DR.WILY TELEPORT SYSTEM" sign: its tiles spell it (bank $07)	;[ok]
ObjectTypeTabEnd::
