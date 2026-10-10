;Macros inherited from the iimarckus/megaman disassembly, modernized for RGBDS 0.9+.
;
;(The skeleton's `freespace` macro, which re-emitted bank tails from the base ROM,
;was removed in step 7.2: every tail is now an explicit `ds` fill.)

;bankswitch: MBC1 ROM bank select. A is written to the shadow in WRAM first and
;then to the cartridge register, because $2100 is write-only and code elsewhere
;reads the shadow to find out which bank is paged in. All 117 bank switches in
;the ROM use this pair.
MACRO bankswitch
	ld [wCurrentBank], a
	ld [$2100], a
ENDM
