;Mega Man: Dr. Wily's Revenge (Game Boy) - disassembly
;
;Single translation unit: rgbasm assembles this file only.
;Everything below is included in ROM order.

include "constants/constants.inc"
include "macros/macros.inc"

;RAM layout
include "ram/hram.asm"
include "ram/wram.asm"
include "ram/audio_ram.asm"

;ROM banks
;ROM bank $00 - one file per subsystem; every section is pinned
include "engine/vectors.asm"
include "engine/header.asm"
include "engine/stubs.asm"
include "data/object_tables.asm"
include "engine/screens.asm"
include "engine/banking.asm"
include "engine/audio_interface.asm"
include "data/gfx_pointers.asm"
include "engine/gfx_loaders.asm"
include "data/font.asm"
include "engine/init.asm"
include "engine/vblank.asm"
include "engine/main.asm"
include "engine/stage_engine.asm"
include "engine/joypad.asm"
include "engine/oam.asm"
include "engine/lcd.asm"
include "engine/memory.asm"
include "engine/math.asm"
include "engine/rng.asm"
include "engine/vram.asm"
include "engine/line_step.asm"
include "engine/stage_select.asm"
include "engine/weapon_get.asm"
include "engine/objects.asm"
include "engine/sprites.asm"
include "engine/stage_load.asm"
include "engine/enemy_shots.asm"

;$3979-$3FFF: unused, all $FF.	;[ok]
SECTION "Bank 0 Free Space", ROM0[$3979]
	ds $4000 - $3979, $FF

include "banks/bank01.asm"
include "audio/bank02.asm"
include "banks/bank03.asm"
include "banks/bank04.asm"
include "banks/bank05.asm"
include "banks/bank06.asm"
include "banks/bank07.asm"
include "banks/bank08.asm"
include "banks/bank09.asm"
include "audio/bank0a.asm"
include "banks/bank0b.asm"
include "banks/bank0c.asm"
include "banks/bank0d.asm"
include "banks/bank0e.asm"
include "banks/bank0f.asm"
