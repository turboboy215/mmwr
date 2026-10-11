;Mega Man: Dr. Wily's Revenge disassembly - cartridge header
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

;$0100: the cartridge header. Execution starts at $0100 after the boot ROM.
;Every byte is in source, the two checksums included, so the build needs no
;rgbfix (step 7.4). The header checksum is computed here from the fields below,
;so editing any of them still gives a ROM the boot ROM accepts; the global
;checksum is a fixed value (see HeaderGlobalChecksum).	;[ok]
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

def HEADER_TITLE equs "MEGAMAN"	;at most 15 characters
def HEADER_CGB_FLAG      equ CART_COMPATIBLE_DMG
def HEADER_NEW_LICENSEE  equ $0000	;two bytes, unused: the old code applies
def HEADER_SGB_FLAG      equ CART_INDICATOR_GB
def HEADER_CART_TYPE     equ CART_ROM_MBC1
def HEADER_ROM_SIZE      equ CART_ROM_256KB
def HEADER_RAM_SIZE      equ CART_SRAM_NONE
def HEADER_DESTINATION   equ CART_DEST_NON_JAPANESE
def HEADER_OLD_LICENSEE  equ LICENSEE_CAPCOM
def HEADER_VERSION       equ $00

HeaderTitle:	;$0134, 15 bytes, NUL-padded
	db "{HEADER_TITLE}"
	ds 15 - STRLEN("{HEADER_TITLE}"), 0
HeaderCGBFlag:		db HEADER_CGB_FLAG	;$0143
HeaderNewLicensee:	db HIGH(HEADER_NEW_LICENSEE), LOW(HEADER_NEW_LICENSEE)	;$0144
HeaderSGBFlag:		db HEADER_SGB_FLAG	;$0146
HeaderCartType:		db HEADER_CART_TYPE	;$0147
HeaderROMSize:		db HEADER_ROM_SIZE	;$0148
HeaderRAMSize:		db HEADER_RAM_SIZE	;$0149
HeaderDestination:	db HEADER_DESTINATION	;$014A
HeaderOldLicensee:	db HEADER_OLD_LICENSEE	;$014B
HeaderVersion:		db HEADER_VERSION	;$014C

;$014D: the header checksum, which the boot ROM checks: starting from 0, subtract
;each byte of $0134-$014C plus one. Computed from the values above (the title's
;NUL padding adds nothing but its "plus one"s); for this ROM it is $E4.	;[ok]
def HEADER_SUM = HIGH(HEADER_NEW_LICENSEE) + LOW(HEADER_NEW_LICENSEE)
def HEADER_SUM += HEADER_CGB_FLAG + HEADER_SGB_FLAG + HEADER_CART_TYPE
def HEADER_SUM += HEADER_ROM_SIZE + HEADER_RAM_SIZE + HEADER_DESTINATION
def HEADER_SUM += HEADER_OLD_LICENSEE + HEADER_VERSION
for I, STRLEN("{HEADER_TITLE}")
	def HEADER_SUM += STRSLICE("{HEADER_TITLE}", I, I + 1)
endr
HeaderChecksum:		db LOW(-HEADER_SUM - ($014D - $0134))	;$014D

;$014E: the global checksum, big-endian: the 16-bit sum of every byte in the ROM
;except these two. No Game Boy checks it (some emulators and flash carts warn),
;and the assembler cannot see the whole linked ROM, so it is the original value,
;written out. A modified ROM keeps this value unless it is fixed afterwards, e.g.
;with `rgbfix -f g mmwr.gb`.	;[ok]
HeaderGlobalChecksum:	db $C2, $5B	;$014E
