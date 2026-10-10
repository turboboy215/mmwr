;Joypad constants. This copy of hardware.inc does not define them; the names
;follow the gbdev hardware.inc convention, guarded against a future update.

if !def(P1F_GET_DPAD)
;Written to rJOYP to select which half of the pad the low nibble reports.
def P1F_GET_DPAD equ $20
def P1F_GET_BTN  equ $10
def P1F_GET_NONE equ $30
endc

if !def(PADF_A)
;Bit layout of hJoypadHeld and hJoypadPressed, as ReadJoypad assembles it: the
;buttons in the low nibble, the d-pad swapped into the high nibble.
def PADF_A      equ $01
def PADF_B      equ $02
def PADF_SELECT equ $04
def PADF_START  equ $08
def PADF_RIGHT  equ $10
def PADF_LEFT   equ $20
def PADF_UP     equ $40
def PADF_DOWN   equ $80
endc

;The soft-reset combo: A + B + Select + Start held together.
def PAD_SOFT_RESET equ PADF_A | PADF_B | PADF_SELECT | PADF_START
