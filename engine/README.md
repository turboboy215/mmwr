Bank $00, one file per subsystem (step 2.7). Every chunk is its own SECTION
pinned to its original ROM0 address, so the include order in main.asm does not
affect the ROM. Other banks' code moves here as it is understood.

Bank $01 followed in step 5.1, pinned the same way (ROMX, BANK[$1]) and included
from banks/bank01.asm: weapons.asm, items.asm, explosions.asm, pause_menu.asm,
hud.asm, title_menu.asm, stage_select_menu.asm, weapon_get_screen.asm,
picture_viewer.asm and player.asm. (stage_select.asm and weapon_get.asm are the
bank $00 halves of those screens.)
