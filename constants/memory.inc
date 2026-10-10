;Addresses of hardware memory areas that this copy of hardware.inc does not
;define. Names follow the gbdev hardware.inc convention where one exists, and
;each is guarded so that updating hardware.inc later cannot collide with these.

if !def(VRAM_TILES0)
;The three VRAM tile blocks. Which two of them the BG and window read from
;depends on LCDC bit 4; OBJs always use blocks 0 and 1.
def VRAM_TILES0 equ $8000	;$8000-$87FF, tiles 0-127
def VRAM_TILES1 equ $8800	;$8800-$8FFF, tiles 128-255 / -128 to -1
def VRAM_TILES2 equ $9000	;$9000-$97FF, tiles 0-127 in the signed addressing mode
endc

;TILEMAP0 ($9800) and TILEMAP1 ($9C00) come from hardware.inc.

if !def(OAMRAM)
def OAMRAM equ $FE00	;$FE00-$FE9F, 40 OBJs x 4 bytes
endc

if !def(STACK_TOP)
;What the game loads into SP. The stack grows down from here through HRAM.
def STACK_TOP equ $FFFE
endc
