;Mega Man: Dr. Wily's Revenge disassembly - ROM bank $09
;
;One of the three object banks ($03, $09, $0D): code for 24 object types,
;reached only through ObjectTypeTab (every object's OBJ_BANK). 100% source since
;step 5.2. The bank is three parts:
;
;  $4000-$4047  the entry table: one `jp` per object type, in ObjectTypeTab
;               order (slot n is the type listed against it there)
;  $4048-$4749  the object library, engine/object_library.asm - the same 1794
;               bytes of helpers are in banks $03 ($4042) and $0D ($401B), so the
;               file is shared: its labels end in {OBJBANK} (_09 here)
;  $474A-$7D31  the 24 objects' routines and their animation data, one file per
;               object type in engine/objects/, in ROM order
;  $7D32-$7FFF  unused, all $FF
;
;An object routine is called with B = 0 when the object is spawned, 1 every
;frame, 2 when its hit points reach zero, and 3 instead of 1 while it is frozen
;by Ice Slasher; it returns B = 0 to be removed. See CallObjectRoutine.
;
;Confidence tags: [ok] verified here, [dc] corroborated by Data Crystal, [?]
;unverified guess. See docs/CONVENTIONS.md.

DEF OBJBANK EQUS "_09"

include "engine/objects/entry_table_09.asm"
SECTION "Object Library 09", ROMX[$4048], BANK[$9]
include "engine/object_library.asm"
include "engine/objects/fire_beam.asm"
include "engine/objects/changkey.asm"
include "engine/objects/changkey_maker.asm"
include "engine/objects/drillun.asm"
include "engine/objects/kaminari_goro_thrower.asm"
include "engine/objects/kaminari_goro_shot.asm"
include "engine/objects/kaminari_goro.asm"
include "engine/objects/pipi.asm"
include "engine/objects/pipi_egg.asm"
include "engine/objects/copipi.asm"
include "engine/objects/scworm.asm"
include "engine/objects/scworm_spawn.asm"
include "engine/objects/enker_shot.asm"
include "engine/objects/enker.asm"
include "engine/objects/sniper_joe.asm"
include "engine/objects/atomic_fire_block.asm"
include "engine/objects/bubble_man.asm"
include "engine/objects/bubble_man_bubble_lead.asm"
include "engine/objects/flash_man.asm"
include "engine/objects/flash_man_freeze.asm"
include "engine/objects/flash_man_defeat_watcher.asm"
include "engine/objects/heat_man.asm"
include "engine/objects/heat_man_atomic_fire.asm"
include "engine/objects/boss_door.asm"

;$7D32-$7FFF: unused, all $FF.	;[ok]
SECTION "Bank 9 Free Space", ROMX[$7D32], BANK[$9]
	ds $8000 - $7D32, $FF

PURGE OBJBANK
