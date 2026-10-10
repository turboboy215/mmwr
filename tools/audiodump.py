#!/usr/bin/env python3
"""Walk every sound in the two audio banks and report what the data uses.

    python3 tools/audiodump.py baserom.gb               summary of both banks
    python3 tools/audiodump.py baserom.gb --headers     one line per SoundTab entry
    python3 tools/audiodump.py baserom.gb --uses CMD    where a command byte is used
                                                        (e.g. --uses F7, --uses EC)

Reads the ROM, not the source, so it also works on an edited mmwr.gb. Names come
from mmwr.sym when it exists (run ./build.sh first). The command language is
described in docs/AUDIO.md; this tool interprets it the way the driver in
audio/bank02.asm does:

  * every command is two bytes (command, parameter), except
  * while automatic length is on (EC ... EB) every command is ONE byte and the
    parameter is the last note length;
  * E9 lo hi is three bytes (call); EA and EC re-read their parameter byte as the
    next command, so they are one byte;
  * jumps (9x/Ax/Bx yy) go to the command's own address + 2*signed(yy); x=0 is
    unconditional, so a track ends at FF or at an x=0 jump.
"""
import sys, os
from collections import Counter, defaultdict

BANKS = {0x02: 'Audio1_', 0x0A: 'Audio2_'}
SOUNDTAB = 0x4015
SOUNDTAB_LEN = 49
TRACKS = ['SFX1', 'SFX2', 'SFX3', 'SFX4', 'Mus1', 'Mus2', 'Mus3', 'Mus4']

# Which VCMDs each hardware channel's table implements (from Audio1_VCMDCh*Tab).
ALL = set(range(0xE6, 0x100))
VCMD_OK = {
    1: ALL - {0xF3, 0xF2},
    2: ALL - {0xF5, 0xF3, 0xF2},
    3: ALL - {0xFB, 0xF5, 0xF4, 0xF3},
    4: ALL - {0xF7, 0xF6, 0xF5, 0xF4, 0xF3, 0xF2, 0xEF, 0xED, 0xE7},
}


def load_syms(path):
    syms = {}
    if not os.path.exists(path):
        return syms
    for line in open(path):
        line = line.split(';')[0].strip()
        if not line:
            continue
        loc, name = line.split()
        bank, addr = loc.split(':')
        if '.' in name:
            continue
        key = (int(bank, 16), int(addr, 16))
        # several labels can share an address (Will's DoNotUseNN entries fall
        # through into the next song); prefer the real name
        if key not in syms or 'DoNotUse' in syms[key]:
            syms[key] = name
    return syms


class Bank:
    def __init__(self, rom, bank):
        self.rom, self.bank = rom, bank

    def b(self, addr):
        return self.rom[self.bank * 0x4000 + addr - 0x4000]

    def w(self, addr):
        return self.b(addr) | self.b(addr + 1) << 8


def walk_track(bk, start, chan, stats, notes):
    """Scan one track from `start`, following every jump and call target."""
    todo = [(start, False)]
    seen = set()
    while todo:
        pc, auto = todo.pop()
        while True:
            if (pc, auto) in seen or not 0x4000 <= pc < 0x8000:
                break
            seen.add((pc, auto))
            cmd = bk.b(pc)
            if auto:
                param, size = None, 1
            else:
                param, size = bk.b(pc + 1), 2
            stats['cmd'][cmd if cmd >= 0xC0 else (cmd & 0xF0)] += 1
            if auto:
                stats['auto_cmds'][cmd] += 1
            if cmd >= 0xC0:
                if cmd < 0xE6:
                    stats['invalid'].append((pc, cmd))
                elif cmd not in VCMD_OK[chan]:
                    stats['ignored'].append((pc, cmd, chan))
                if cmd == 0xFF:
                    break
                if cmd == 0xE9:          # call: lo, hi
                    tgt = bk.w(pc + 1)
                    todo.append((tgt, auto))
                    stats['calls'].append((pc, tgt))
                    pc += 3 if not auto else 2
                    continue
                if cmd == 0xE8:          # return
                    break
                if cmd == 0xEC:          # auto length on: 1-byte commands follow
                    pc += 1
                    auto = True
                    continue
                if cmd == 0xEB:
                    auto = False
                if cmd == 0xEA:
                    pc += 1
                    continue
                if cmd == 0xE6:
                    stats['cues'].append((pc, param))
                stats['params'][cmd].add(param)
                pc += size
                continue
            if cmd >= 0x90:              # 9x / Ax / Bx
                if auto:
                    stats['auto_jumps'].append(pc)
                    off = param if param is not None else 0
                else:
                    off = param
                off = off - 0x100 if off >= 0x80 else off
                tgt = pc + 2 * off
                stats['jumps'][cmd & 0xF0].append((pc, cmd & 0x0F, tgt))
                if cmd & 0x0F == 0:
                    pc = tgt
                    continue
                todo.append((tgt, auto))
                pc += size
                continue
            # note or rest
            if chan == 4:
                notes['noise'][cmd] += 1
            elif cmd & 0xF0:
                notes['tone'][cmd] += 1
                if cmd >= 0x80 or (cmd & 0x0F) >= 12:
                    stats['odd_notes'].append((pc, cmd))
            else:
                notes['rest'] += 1
            pc += size
    return seen


def main():
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return
    rom = open(args[0], 'rb').read()
    syms = load_syms(os.path.join(os.path.dirname(os.path.abspath(args[0])), 'mmwr.sym'))
    show_headers = '--headers' in args
    uses = None
    if '--uses' in args:
        uses = int(args[args.index('--uses') + 1], 16)

    for bank, prefix in BANKS.items():
        bk = Bank(rom, bank)
        stats = defaultdict(list)
        stats['cmd'] = Counter()
        stats['auto_cmds'] = Counter()
        stats['params'] = defaultdict(set)
        stats['jumps'] = defaultdict(list)
        notes = {'tone': Counter(), 'noise': Counter(), 'rest': 0}
        tempo_by_prio = []
        heads = {}
        print(f'== bank ${bank:02X}')
        for i in range(SOUNDTAB_LEN):
            p = bk.w(SOUNDTAB + 2 * i)
            name = syms.get((bank, p), f'${p:04X}')
            tempo, prio = bk.b(p), bk.b(p + 1)
            chans = []
            for c in range(4):
                tp = bk.w(p + 2 + 3 * c)
                tr = bk.b(p + 4 + 3 * c)
                chans.append((tp, tr))
                if tp and tp not in heads:
                    heads[tp] = (name, c + 1)
                    walk_track(bk, tp, c + 1, stats, notes)
            if show_headers:
                cs = ' '.join(f'{TRACKS[tr] if tp else "-":>4}' for tp, tr in chans)
                print(f'  {i:2d} id ${i+1:02X} {name.replace(prefix, ""):<20} tempo {tempo:3d} prio {prio:3d}  ch1-4: {cs}')
            tempo_by_prio.append((name, tempo, prio, chans))
        if uses is not None:
            # rescan, reporting where `uses` occurs
            for tp, (name, chan) in sorted(heads.items()):
                st = defaultdict(list); st['cmd'] = Counter(); st['auto_cmds'] = Counter(); st['params'] = defaultdict(set); st['jumps'] = defaultdict(list)
                seen = walk_track(bk, tp, chan, st, {'tone': Counter(), 'noise': Counter(), 'rest': 0})
                hits = sorted(pc for pc, a in seen if bk.b(pc) == uses or (uses in (0x90, 0xA0, 0xB0) and bk.b(pc) & 0xF0 == uses and bk.b(pc) >= 0x90))
                if hits:
                    sys.stdout.flush()
                    print(f'  {name} ch{chan}: ' + ' '.join(f'${h:04X}' for h in hits[:12]) + (' ...' if len(hits) > 12 else ''))
            continue
        c = stats['cmd']
        print('  command use (notes/rests and jumps grouped by high nibble):')
        print('   ' + '  '.join(f'{k:02X}:{v}' for k, v in sorted(c.items())))
        print(f"  calls (E9): {len(stats['calls'])}   cues (E6): {sorted(set(p for _, p in stats['cues']))}")
        print(f"  jumps: " + ', '.join(f"{k:02X}:{len(v)} (x=0: {sum(1 for j in v if j[1]==0)})" for k, v in sorted(stats['jumps'].items())))
        print(f"  auto-length commands: {dict(stats['auto_cmds'])}  jumps inside auto mode: {len(stats['auto_jumps'])}")
        print(f"  commands $C0-$E5 (no-ops): {stats['invalid']}")
        print(f"  VCMDs missing from their channel's table: {stats['ignored']}")
        print(f"  notes outside 7 octaves x 12: {stats['odd_notes']}")
        print(f"  parameters seen: " + '; '.join(f'{k:02X}=' + ','.join(f'{x:02X}' for x in sorted(v) if x is not None) for k, v in sorted(stats['params'].items())))
        print(f"  noise indices used: {sorted(notes['noise'])}")
        tn = notes['tone']
        if tn:
            print(f"  tone range: ${min(tn):02X}-${max(tn):02X}, {sum(tn.values())} notes, {notes['rest']} rests")


if __name__ == '__main__':
    main()
