;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $01
;
;The resident bank: bank $00 pages it back in whenever it is done with another,
;so it holds everything that runs during play and the menus around it. 100%
;source since step 5.1, split by subsystem into the files below (in ROM order);
;every chunk is its own SECTION pinned to its original address, so the include
;order does not matter.
;
;  $4000-$5410  engine/weapons.asm, data/weapon_frames.asm: WeaponTab, firing,
;               the shot engine, the eleven weapons, their animations and frames
;  $5411-$5938  engine/items.asm: item drops and placed items, the refill
;  $5939-$5C9B  engine/explosions.asm: explosions and death bursts
;  $5C9C-$5F67  engine/pause_menu.asm: the weapon menu
;  $5F68-$60AE  engine/hud.asm: the window HUD (energy bars, lives)
;  $60AF-$6155  engine/title_menu.asm: the title screen
;  $6156-$66C4  engine/stage_select_menu.asm, engine/weapon_get_screen.asm,
;               engine/picture_viewer.asm: stage select and boss intro, the
;               weapon-get screen, four unused picture viewers
;  $66C5-$738C  engine/player.asm, data/megaman_frames.asm: Mega Man - life
;               state, controls, physics, drawing, teleport
;  $738D-$7FFF  unused
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

include "engine/weapons.asm"
include "data/weapon_frames.asm"
include "engine/items.asm"
include "engine/explosions.asm"
include "engine/pause_menu.asm"
include "engine/hud.asm"
include "engine/title_menu.asm"
include "engine/stage_select_menu.asm"
include "engine/weapon_get_screen.asm"
include "engine/picture_viewer.asm"
include "engine/player.asm"
include "data/megaman_frames.asm"

;$738D-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 1 Free Space", ROMX[$738D], BANK[$1]
	ds $8000 - $738D, $FF
