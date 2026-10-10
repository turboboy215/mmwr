;Mega Man: Dr. Wily's Revenge disassembly - font tiles
;Part of ROM bank $00. Every section is pinned to its original address, so the
;files can be read by subsystem while the ROM layout stays exact. Confidence
;tags: [ok] verified here, [dc] corroborated by Data Crystal, [?] guess.

SECTION "Font Tiles", ROM0[$041E]

;$041E: A-Z in a bold 7-pixel face, 26 tiles, drawn in colour 2 only. Loaded
;together with the four tiles after it by LoadFontTiles. Source: gfx/font.png.
FontTiles::	;$041E
	INCBIN "gfx/font.2bpp"

;$05BE: four tiles of a health bar at four fill levels, loaded along with the
;font. Identified by Will; what draws them is not yet traced. Bank $04 has a
;separate set labelled HealthBar, so these may be a second, HUD-side copy.
;Source: gfx/health_bar.png.	;[ok]
FontHealthBarTiles::	;$05BE
	INCBIN "gfx/health_bar.2bpp"
FontTilesEnd::
