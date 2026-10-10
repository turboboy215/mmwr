;Audio RAM addresses and slot indices
;From Will Trowbridge's Mega Man: Dr. Wily's Revenge audio disassembly

def AudioROM equ $4000
def AudioRAM equ $D935
def WaveRAM equ $FF30
def MasterSlotSpeedRAM equ AudioRAM+$44
def Slot1SpeedRAM equ MasterSlotSpeedRAM+$03
def Slot2SpeedRAM equ Slot1SpeedRAM+$03
def Slot3SpeedRAM equ Slot2SpeedRAM+$03
def Slot4SpeedRAM equ Slot3SpeedRAM+$03
def Slot5SpeedRAM equ Slot4SpeedRAM+$03
def Slot6SpeedRAM equ Slot5SpeedRAM+$03
def Slot7SpeedRAM equ Slot6SpeedRAM+$03
def Slot8SpeedRAM equ Slot7SpeedRAM+$03
def SFX1RAM equ AudioRAM+$AC
def SFX2RAM equ SFX1RAM+$59
def SFX3RAM equ SFX2RAM+$59
def SFX4RAM equ SFX3RAM+$59
def Mus1RAM equ SFX4RAM+$59
def Mus2RAM equ Mus1RAM+$59
def Mus3RAM equ Mus2RAM+$59
def Mus4RAM equ Mus3RAM+$59

;Audio update lock (step 6.4). Non-zero: the per-frame update must not run. The
;VBlank handler takes it around its own call to PlayAudio; every driver entry
;point that changes driver state saves it in wAudioLockSave, takes it, and
;restores it; bank $01 holds it through the stage-intro and weapon-get sequences
;and runs the update itself (RunAudioUpdate). Will's name was wAudioLock/2.	;[ok]
def wAudioLock equ $C131
def wAudioLockSave equ wAudioLock+$01

def wAudioStopSlot equ $CC4A
def wQueuedSoundPtr equ AudioRAM+$01	;$D936: header of the best sound queued this frame (bank $00)
def wMusicSlot equ $DCBC		;slot of the current music, from LoadSong/LoadSound (bank $00)

def SFX1	equ 0
def SFX2	equ 1
def SFX3	equ 2
def SFX4	equ 3
def Mus1	equ 4
def Mus2	equ 5
def Mus3	equ 6
def Mus4	equ 7
