;Mega Man: Dr. Wily's Revenge disassembly - cartridge header
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

;$0100: the cartridge header. Execution starts at $0100 after the boot ROM.
;Every field is in source; rgbfix only fills in the two checksums, so editing
;anything here still produces a ROM the boot ROM will accept.	;[ok]
SECTION "Header", ROM0[$100]
Entry::	;$0100
	nop
	jp Start

;$0104: the Nintendo logo. The boot ROM compares this byte for byte and refuses
;to start the cartridge if it differs.
HeaderLogo:	;$0104
	db $CE, $ED, $66, $66, $CC, $0D, $00, $0B
	db $03, $73, $00, $83, $00, $0C, $00, $0D
	db $00, $08, $11, $1F, $88, $89, $00, $0E
	db $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
	db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC
	db $DD, $DC, $99, $9F, $BB, $B9, $33, $3E

HeaderTitle:	;$0134, 15 bytes, NUL-padded
	db "MEGAMAN"
	ds 15 - STRLEN("MEGAMAN"), 0
HeaderCGBFlag:		db CART_COMPATIBLE_DMG	;$0143
HeaderNewLicensee:	db 0, 0			;$0144, unused: the old code below applies
HeaderSGBFlag:		db CART_INDICATOR_GB	;$0146
HeaderCartType:		db CART_ROM_MBC1	;$0147
HeaderROMSize:		db CART_ROM_256KB	;$0148
HeaderRAMSize:		db CART_SRAM_NONE	;$0149
HeaderDestination:	db CART_DEST_NON_JAPANESE	;$014A
HeaderOldLicensee:	db LICENSEE_CAPCOM	;$014B
HeaderVersion:		db $00			;$014C
HeaderChecksum:		db 0	;$014D, filled in by rgbfix (it is $E4)
HeaderGlobalChecksum:	dw 0	;$014E, big-endian, filled in by rgbfix (it is $C25B)
