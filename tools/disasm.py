#!/usr/bin/env python3
"""Straight-line Game Boy disassembler for one ROM range, in RGBDS syntax.

Emits source you paste into a bank file to replace part of an INCBIN. It does
NOT follow branches or guess where code ends - you give it a range you already
believe is code, read the output, and fix up what is actually data.

  python3 tools/disasm.py baserom.gb 0x4190 0x4200 --bank 1

--bank sets the address the range is mapped at ($4000-$7FFF for banks 1+),
so jump and call targets print with the right addresses.
"""
import sys, argparse

# opcode table: mnemonic template, length. {n8} {n16} {e8} {a8} are operands.
OPS = {}
def _fill():
    r8  = ["b","c","d","e","h","l","[hl]","a"]
    r16 = ["bc","de","hl","sp"]
    cc  = ["nz","z","nc","c"]
    alu = ["add a,","adc a,","sub","sbc a,","and","xor","or","cp"]
    rot = ["rlc","rrc","rl","rr","sla","sra","swap","srl"]
    for o,(m,l) in {
        0x00:("nop",1),0x10:("stop",2),0x76:("halt",1),0xF3:("di",1),0xFB:("ei",1),
        0x07:("rlca",1),0x0F:("rrca",1),0x17:("rla",1),0x1F:("rra",1),
        0x27:("daa",1),0x2F:("cpl",1),0x37:("scf",1),0x3F:("ccf",1),
        0xC9:("ret",1),0xD9:("reti",1),0xE9:("jp hl",1),0xF9:("ld sp, hl",1),
        0xC3:("jp {n16}",3),0xCD:("call {n16}",3),0x18:("jr {e8}",2),
        0xE0:("ldh [{a8}], a",2),0xF0:("ldh a, [{a8}]",2),
        0xE2:("ldh [c], a",1),0xF2:("ldh a, [c]",1),
        0xEA:("ld [{n16}], a",3),0xFA:("ld a, [{n16}]",3),
        0x08:("ld [{n16}], sp",3),0xF8:("ld hl, sp{e8}",2),
        0xE8:("add sp, {e8}",2),0x36:("ld [hl], {n8}",2),
        0x02:("ld [bc], a",1),0x12:("ld [de], a",1),0x22:("ld [hl+], a",1),0x32:("ld [hl-], a",1),
        0x0A:("ld a, [bc]",1),0x1A:("ld a, [de]",1),0x2A:("ld a, [hl+]",1),0x3A:("ld a, [hl-]",1),
    }.items(): OPS[o]=(m,l)
    for i,c in enumerate(cc):
        OPS[0x20+i*8]=("jr %s, {e8}"%c,2); OPS[0xC0+i*8]=("ret %s"%c,1)
        OPS[0xC2+i*8]=("jp %s, {n16}"%c,3); OPS[0xC4+i*8]=("call %s, {n16}"%c,3)
    for i,r in enumerate(r16):
        OPS[0x01+i*16]=("ld %s, {n16}"%r,3); OPS[0x03+i*16]=("inc %s"%r,1)
        OPS[0x0B+i*16]=("dec %s"%r,1); OPS[0x09+i*16]=("add hl, %s"%r,1)
    for i,r in enumerate(["bc","de","hl","af"]):
        OPS[0xC1+i*16]=("pop %s"%r,1); OPS[0xC5+i*16]=("push %s"%r,1)
    for i,r in enumerate(r8):
        OPS[0x04+i*8]=("inc %s"%r,1); OPS[0x05+i*8]=("dec %s"%r,1)
        if 0x06+i*8 != 0x36: OPS[0x06+i*8]=("ld %s, {n8}"%r,2)
    for d,dr in enumerate(r8):
        for s,sr in enumerate(r8):
            o=0x40+d*8+s
            if o!=0x76: OPS[o]=("ld %s, %s"%(dr,sr),1)
    for a,op in enumerate(alu):
        for s,sr in enumerate(r8): OPS[0x80+a*8+s]=("%s %s"%(op,sr),1)
        OPS[0xC6+a*8]=("%s {n8}"%op,2)
    for i in range(8): OPS[0xC7+i*8]=("rst $%02X"%(i*8),1)
_fill()

def cb(b):
    r8=["b","c","d","e","h","l","[hl]","a"]
    rot=["rlc","rrc","rl","rr","sla","sra","swap","srl"]
    if b<0x40: return "%s %s"%(rot[b>>3], r8[b&7])
    return "%s %d, %s"%(["bit","res","set"][(b>>6)-1], (b>>3)&7, r8[b&7])

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("rom"); ap.add_argument("start"); ap.add_argument("end")
    ap.add_argument("--bank", type=lambda s:int(s,0), default=None,
                    help="ROM bank the range lives in (default: inferred from start)")
    a=ap.parse_args()
    d=open(a.rom,'rb').read()
    start=int(a.start,0); end=int(a.end,0)
    bank = a.bank if a.bank is not None else start//0x4000
    base = 0x0000 if bank==0 else 0x4000
    def addr(off): return base + (off - bank*0x4000)

    i=start
    while i<end:
        pc=addr(i); op=d[i]
        if op==0xCB:
            print("\t%-28s ;$%02X:%04X  cb %02X"%(cb(d[i+1]),bank,pc,d[i+1])); i+=2; continue
        if op not in OPS:
            print("\tdb $%02X%s"%(op," "*22)+" ;$%02X:%04X  invalid opcode"%(bank,pc)); i+=1; continue
        m,l=OPS[op]
        raw=d[i:i+l]
        if "{n16}" in m: m=m.replace("{n16}","$%04X"%(raw[1]|raw[2]<<8))
        if "{n8}"  in m: m=m.replace("{n8}","$%02X"%raw[1])
        if "{a8}"  in m: m=m.replace("{a8}","$FF%02X"%raw[1])
        if "{e8}"  in m:
            off=raw[1]-256 if raw[1]>127 else raw[1]
            if m.startswith("jr"):            rep = "$%04X" % (pc + l + off)
            elif m.startswith("add sp"):      rep = "%d" % off
            else:                             rep = "%+d" % off
            m=m.replace("{e8}", rep)
        print("\t%-28s ;$%02X:%04X  %s"%(m,bank,pc,raw.hex(' ')))
        i+=l

if __name__=="__main__": main()
