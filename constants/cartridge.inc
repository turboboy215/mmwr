;Cartridge header values. This copy of hardware.inc does not define them, so the
;names here are this project's own; each is guarded against a future update.
;Only the values this ROM uses, plus their immediate neighbours for context.

if !def(CART_ROM_MBC1)
;$0147 - cartridge type
def CART_ROM          equ $00
def CART_ROM_MBC1     equ $01	;this game
def CART_ROM_MBC1_RAM equ $02

;$0148 - ROM size: 32 KB << n
def CART_ROM_32KB     equ $00
def CART_ROM_256KB    equ $03	;this game, 16 banks

;$0149 - cartridge RAM size
def CART_SRAM_NONE    equ $00	;this game

;$0143 / $0146 - console support
def CART_COMPATIBLE_DMG equ $00	;$0143: no CGB support
def CART_INDICATOR_GB   equ $00	;$0146: no SGB support

;$014A - destination
def CART_DEST_JAPANESE     equ $00
def CART_DEST_NON_JAPANESE equ $01	;this game (US)

;$014B - old licensee code
def LICENSEE_CAPCOM equ $08	;this game
endc
