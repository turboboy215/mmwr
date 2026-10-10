;Screen-text charmap.
;
;The game has several text encodings, and RGBDS charmaps are global, so each
;non-ASCII one is declared as a separate named charmap and switched to only where
;its text is emitted. The default `main` charmap is left as plain ASCII, which is
;what the bank $00 boss-name table uses. (Step 1.5 believed there were only two
;encodings; step 2.4 found the weapon-get one below, and two more blocks of text
;in banks $01 and $0E are still raw - see docs/ROMMAP.md.)
;
;Rule: tile index = ASCII + $60, with two exceptions - space is $6C, and the
;copyright glyph sits at $A0 where `@` would fall. $00 terminates a string, and
;each string is preceded by its BG tilemap destination; see docs/ROMMAP.md.
;
;A-Z and 0-9 are mapped as whole ranges because the rule is uniform, not because
;every glyph has been seen. The strings actually use A-I, K-P, R-W, Y, 1, 9,
;space, `!`, `,`, `.` and the copyright sign.	;[ok]

NEWCHARMAP screen
	CHARMAP " ", $6C
	CHARMAP "©", $A0
	CHARMAP "!", $81
	CHARMAP ",", $8C
	CHARMAP ".", $8E
	CHARMAP "0", $90
	CHARMAP "1", $91
	CHARMAP "2", $92
	CHARMAP "3", $93
	CHARMAP "4", $94
	CHARMAP "5", $95
	CHARMAP "6", $96
	CHARMAP "7", $97
	CHARMAP "8", $98
	CHARMAP "9", $99
	CHARMAP "A", $A1
	CHARMAP "B", $A2
	CHARMAP "C", $A3
	CHARMAP "D", $A4
	CHARMAP "E", $A5
	CHARMAP "F", $A6
	CHARMAP "G", $A7
	CHARMAP "H", $A8
	CHARMAP "I", $A9
	CHARMAP "J", $AA
	CHARMAP "K", $AB
	CHARMAP "L", $AC
	CHARMAP "M", $AD
	CHARMAP "N", $AE
	CHARMAP "O", $AF
	CHARMAP "P", $B0
	CHARMAP "Q", $B1
	CHARMAP "R", $B2
	CHARMAP "S", $B3
	CHARMAP "T", $B4
	CHARMAP "U", $B5
	CHARMAP "V", $B6
	CHARMAP "W", $B7
	CHARMAP "X", $B8
	CHARMAP "Y", $B9
	CHARMAP "Z", $BA

;Weapon-get charmap ("YOU GOT / ROLLING CUTTER"), bank $00 $21C7. The same
;font as the screen charmap, but the weapon-get screen loads it 32 tiles higher
;(at $8A00 instead of $8800), so every letter is ASCII + $80. Space is $93, a
;blank tile from the weapon-get screen's own tile block; it appears once, in
;"YOU GOT". Only A-Z and space are needed.	;[ok]
NEWCHARMAP getscreen
	CHARMAP " ", $93
	CHARMAP "A", $C1
	CHARMAP "B", $C2
	CHARMAP "C", $C3
	CHARMAP "D", $C4
	CHARMAP "E", $C5
	CHARMAP "F", $C6
	CHARMAP "G", $C7
	CHARMAP "H", $C8
	CHARMAP "I", $C9
	CHARMAP "J", $CA
	CHARMAP "K", $CB
	CHARMAP "L", $CC
	CHARMAP "M", $CD
	CHARMAP "N", $CE
	CHARMAP "O", $CF
	CHARMAP "P", $D0
	CHARMAP "Q", $D1
	CHARMAP "R", $D2
	CHARMAP "S", $D3
	CHARMAP "T", $D4
	CHARMAP "U", $D5
	CHARMAP "V", $D6
	CHARMAP "W", $D7
	CHARMAP "X", $D8
	CHARMAP "Y", $D9
	CHARMAP "Z", $DA

;Pause-menu charmap: the two-letter weapon names in bank $01 (WeaponLetters).
;The pause menu loads FontTiles (A-Z) to $8900, so A is tile $90 and Z $A9; $70
;is the blank. CopyLetterTile turns a code back into a FontTiles address the
;same way.	;[ok]
NEWCHARMAP menu
	CHARMAP " ", $70
	CHARMAP "A", $90
	CHARMAP "B", $91
	CHARMAP "C", $92
	CHARMAP "D", $93
	CHARMAP "E", $94
	CHARMAP "F", $95
	CHARMAP "G", $96
	CHARMAP "H", $97
	CHARMAP "I", $98
	CHARMAP "J", $99
	CHARMAP "K", $9A
	CHARMAP "L", $9B
	CHARMAP "M", $9C
	CHARMAP "N", $9D
	CHARMAP "O", $9E
	CHARMAP "P", $9F
	CHARMAP "Q", $A0
	CHARMAP "R", $A1
	CHARMAP "S", $A2
	CHARMAP "T", $A3
	CHARMAP "U", $A4
	CHARMAP "V", $A5
	CHARMAP "W", $A6
	CHARMAP "X", $A7
	CHARMAP "Y", $A8
	CHARMAP "Z", $A9

;Ending roll-call charmap: the enemy names in bank $0E (RollCallTextPtrs). The
;ending loads its own font (EndingFontTiles) to $9000 as tiles $00-$3F in ASCII
;order from the space, so a tile is ASCII - $20, with the copyright glyph where
;`@` would be. Tile $00, the space, is also each string's terminator, so a
;two-word name is two strings: the first ends in $FF, which moves to a new BG
;address, and the font itself is otherwise unused.	;[ok]
NEWCHARMAP rollcall
	CHARMAP "!", $01
	CHARMAP "\"", $02
	CHARMAP "#", $03
	CHARMAP "$", $04
	CHARMAP "%", $05
	CHARMAP "&", $06
	CHARMAP "'", $07
	CHARMAP "(", $08
	CHARMAP ")", $09
	CHARMAP "*", $0A
	CHARMAP "+", $0B
	CHARMAP ",", $0C
	CHARMAP "-", $0D
	CHARMAP ".", $0E
	CHARMAP "/", $0F
	CHARMAP "0", $10
	CHARMAP "1", $11
	CHARMAP "2", $12
	CHARMAP "3", $13
	CHARMAP "4", $14
	CHARMAP "5", $15
	CHARMAP "6", $16
	CHARMAP "7", $17
	CHARMAP "8", $18
	CHARMAP "9", $19
	CHARMAP ":", $1A
	CHARMAP ";", $1B
	CHARMAP "<", $1C
	CHARMAP "=", $1D
	CHARMAP ">", $1E
	CHARMAP "?", $1F
	CHARMAP "A", $21
	CHARMAP "B", $22
	CHARMAP "C", $23
	CHARMAP "D", $24
	CHARMAP "E", $25
	CHARMAP "F", $26
	CHARMAP "G", $27
	CHARMAP "H", $28
	CHARMAP "I", $29
	CHARMAP "J", $2A
	CHARMAP "K", $2B
	CHARMAP "L", $2C
	CHARMAP "M", $2D
	CHARMAP "N", $2E
	CHARMAP "O", $2F
	CHARMAP "P", $30
	CHARMAP "Q", $31
	CHARMAP "R", $32
	CHARMAP "S", $33
	CHARMAP "T", $34
	CHARMAP "U", $35
	CHARMAP "V", $36
	CHARMAP "W", $37
	CHARMAP "X", $38
	CHARMAP "Y", $39
	CHARMAP "Z", $3A
	CHARMAP "[", $3B
	CHARMAP "\\", $3C
	CHARMAP "]", $3D
	CHARMAP "^", $3E
	CHARMAP "_", $3F
	CHARMAP "©", $20

;Back to plain ASCII for everything that follows.
SETCHARMAP main
