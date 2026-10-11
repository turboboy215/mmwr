#!/usr/bin/env python3
"""Tally every RAM reference in the source (step 7.5).

Since step 7.2 every byte of the ROM is source, so a RAM map no longer has to
come from a byte scan (tools/ramrefs.py, step 1.2, which could not tell code
from graphics). This reads the source the way rgbasm does - main.asm and its
includes, in order - and for every instruction or `dw` whose operand is a RAM
address ($C000-$DFFF WRAM, $FF80-$FFFE HRAM), by name or by number, records
the address, how it is used and in which ROM bank. Names and the comment above
each declaration come from ram/*.asm and the `def ... equ` constants.

Needs a build first (reads mmwr.sym and mmwr.map).

    python3 tools/rammap.py            summary
    python3 tools/rammap.py --md       the generated table in docs/RAMMAP.md
    python3 tools/rammap.py --unnamed  only addresses with no name
    python3 tools/rammap.py --sites D920   every site that touches an address
"""
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')


def is_ram(a):
    return 0xC000 <= a <= 0xDFFF or 0xFF80 <= a <= 0xFFFE


def load_sym():
    syms = {}
    for line in open(os.path.join(ROOT, 'mmwr.sym')):
        m = re.match(r'([0-9a-fA-F]+):([0-9a-fA-F]{4}) (\S+)', line)
        if m:
            syms[m.group(3)] = int(m.group(2), 16)
    return syms


def load_section_banks():
    banks, cur = {}, None
    for line in open(os.path.join(ROOT, 'mmwr.map')):
        m = re.match(r'(ROM0|ROMX|WRAM0|WRAMX|HRAM|VRAM|SRAM|OAM) bank #(\d+)', line)
        if m:
            cur = (m.group(1), int(m.group(2)))
            continue
        m = re.search(r'SECTION: .*\["(.*)"\]', line)
        if m and cur:
            banks[m.group(1)] = cur
    return banks


def expand(path, out):
    """Yield (file, lineno, text) in assembly order, following includes."""
    full = os.path.join(ROOT, path)
    for n, line in enumerate(open(full, encoding='utf-8', errors='replace'), 1):
        m = re.match(r'\s*include\s+"([^"]+)"', line, re.I)
        if m:
            expand(m.group(1), out)
        else:
            out.append((path, n, line.rstrip('\n')))


def strip_comment(s):
    q, r = False, []
    for ch in s:
        if ch == '"':
            q = not q
        if ch == ';' and not q:
            break
        r.append(ch)
    return ''.join(r)


NUM = re.compile(r'\$[0-9A-Fa-f]+|%[01]+|\b\d+\b')
IDENT = re.compile(r'[A-Za-z_][\w.]*')


def evaluate(expr, names):
    expr = expr.strip()
    if not expr or re.search(r'\b(LOW|HIGH|BANK)\s*\(', expr, re.I):
        return None, None
    used = []

    def ident(m):
        k = m.group(0)
        if k in names:
            used.append(k)
            return str(names[k])
        raise KeyError(k)
    try:
        e = NUM.sub(lambda m: str(int(m.group(0)[1:], 16)) if m.group(0)[0] == '$'
                    else str(int(m.group(0)[1:], 2)) if m.group(0)[0] == '%'
                    else m.group(0), expr)
        e = IDENT.sub(ident, e)
        if not re.fullmatch(r'[\d\s+\-*()]+', e):
            return None, None
        return eval(e), (used[0] if used else None)
    except Exception:
        return None, None


# Curated regions (step 7.5), from docs/RAMMAP.md's region table. An unnamed
# address with no source comment gets its region's description in the table.
REGIONS = [
    (0xC000, 0xC09F, 'shadow OAM'),
    (0xC0A4, 0xC0FF, 'RAM code block (memset to `ret`, then hooks and trampolines)'),
    (0xC100, 0xC132, 'per-game state wiped by ResetGameState: boss bar, HUD copy queue and buffers ($C102-$C12B), lives, audio lock'),
    (0xC200, 0xC29A, "weapon and shot state (bank $01); banks $0B's cutscenes reuse $C20A-$C21F as scratch"),
    (0xC300, 0xC302, 'pause menu selection, previous selection, blink timer'),
    (0xC380, 0xC3E2, 'object system bookkeeping: active list, slot free list, spawn-record count, tile allocator, type->tile cache'),
    (0xC400, 0xC5FF, 'stage spawn records, 8 bytes each'),
    (0xC600, 0xCBFF, '24 object slots of $40 bytes; reused by the password screen (bank $0C) and the ending (bank $0E)'),
    (0xCC00, 0xCC1B, "SpawnObject's header buffer / spawn parameters ($CC07 type, $CC0D/$CC0F position); the ending reuses it"),
    (0xCC2C, 0xCC2E, 'object scratch'),
    (0xCC40, 0xCC47, 'current object pointer and per-object scratch'),
    (0xCC4B, 0xCC5D, 'metasprite drawing scratch, stage-select sprite positions, Wily Machine fight state'),
    (0xCCF1, 0xCCFC, 'stage-select animation state, and boss-fight state'),
    (0xCD00, 0xCDDA, 'enemy shots: active list, count, free stack, twelve 16-byte records'),
    (0xCE28, 0xCF77, 'OAM entry pool, links and offsets; drawing scratch $CE53-$CE58'),
    (0xD000, 0xD28B, 'sprite handle system: records, handle pool, holder/waiting lists, link table'),
    (0xD300, 0xD3ED, 'explosions: live list, free list, twelve $10-byte records, a record being built ($D3DA-$D3E9), death position'),
    (0xD400, 0xD4F3, 'items: live list, free list, ten records, spawn parameters, meter refill, placed-item list'),
    (0xD800, 0xD85E, "Mega Man: state, animation, position, speeds, pushes, damage, hit spark, joypad copy, box; camera and scroll"),
    (0xD85F, 0xD8C8, 'scroll shadows, BG column/row copy queues, room transition, stage and room state, block collision'),
    (0xD8C9, 0xD916, 'block under feet, floor type, underwater flag, Wily 2 hub, chunked tile copy, sound queue'),
    (0xD935, 0xDCBD, 'audio driver (ram/audio_ram.asm)'),
    (0xDCBE, 0xDDFF, 'game flags after the audio block; BG copy buffers $DDD0/$DDE0; transition scroll bytes $DDFA/$DDFB'),
    (0xDE00, 0xDEFF, '16x16 grid of the visible blocks (PixelToBlockGridAddr)'),
    (0xDF00, 0xDF41, 'extra solid boxes (AddSolidBox), count byte first; $DF41 pause disabled'),
    (0xDF80, 0xDFAF, 'stage hook, VBlank bookkeeping, banking, LCD shadows, progress, weapons, energy, RNG'),
    (0xDFB0, 0xDFC4, 'disabled hitbox viewer: freeze flags, cursor, box corners, sprite handles'),
    (0xDFC5, 0xDFD4, 'misc flags: Gabyoall state, teleport beam, cutscene waits, title buttons, game-over choice, once-per-game flag'),
    (0xFF80, 0xFF91, 'OAM DMA routine, joypad, far-call scratch, bank-1 call index'),
    (0xFF92, 0xFFB1, 'HRAM scratch shared by many routines (screen positions, hitboxes, movement)'),
]


def region_of(a):
    for lo, hi, text in REGIONS:
        if lo <= a <= hi:
            return text
    return None


def main():
    syms = load_sym()
    secbank = load_section_banks()
    lines = []
    expand('main.asm', lines)

    names = dict(syms)
    decl = {}          # address -> (name, size, comment, file)
    comment = []
    for f, n, text in lines:
        m = re.match(r'\s*def\s+(\w+)\s+equ\s+(.+)', strip_comment(text), re.I)
        if m:
            v, _ = evaluate(m.group(2), names)
            if v is not None:
                names[m.group(1)] = v
                if f.startswith(('ram/', 'constants/')) and is_ram(v) and v not in decl:
                    decl[v] = (m.group(1), None, ' '.join(comment), f)
        if f.startswith('ram/'):
            s = text.strip()
            if s.startswith(';'):
                comment.append(s.lstrip(';').strip())
                continue
            if not s:
                comment = []
                continue
            m = re.match(r'(\w+)::?\s*ds\s+([^;]+)', s)
            if m and m.group(1) in syms:
                size, _ = evaluate(m.group(2), names)
                a = syms[m.group(1)]
                note = ' '.join(comment)
                tail = text.split(';', 1)[1].strip() if ';' in text else ''
                decl.setdefault(a, (m.group(1), size, note or tail, f))
                for i in range(1, size or 1):
                    decl.setdefault(a + i, (None, None, None, f))
                comment = []
        elif not text.strip().startswith(';'):
            comment = []

    refs = defaultdict(list)      # address -> [(kind, bank, file, line, name)]
    bank = None
    routine = None
    nextcode = {}
    prev = None
    for i in range(len(lines) - 1, -1, -1):
        c = strip_comment(lines[i][2]).strip()
        nextcode[i] = prev
        if c:
            prev = c
    for i, (f, n, text) in enumerate(lines):
        code = strip_comment(text)
        g = re.match(r'([A-Za-z_]\w*)(?:\{\w+\})?::?', code)
        if g and not code.startswith(('def ', 'DEF ', 'MACRO', 'SECTION')):
            routine = g.group(1)
        m = re.match(r'\s*SECTION\s+"([^"]+)"', code, re.I)
        if m:
            kind_bank = secbank.get(m.group(1))
            bank = kind_bank[1] if kind_bank and kind_bank[0] in ('ROM0', 'ROMX') else None
            continue
        if bank is None:
            continue
        m = re.match(r'\s+(\w+)\s*(.*)', code)
        if not m:
            continue
        op, args = m.group(1).lower(), m.group(2).strip()
        cands = []
        if op in ('ld', 'ldh'):
            parts = [p.strip() for p in args.split(',', 1)]
            if len(parts) == 2:
                dst, src = parts
                if dst.startswith('['):
                    cands.append(('write', dst.strip('[]')))
                elif src.startswith('['):
                    cands.append(('read', src.strip('[]')))
                elif dst.lower() in ('hl', 'de', 'bc', 'sp'):
                    nxt = (nextcode.get(i) or '').lower()
                    deref = dst.lower() == 'sp' or f'[{dst.lower()}' in nxt.replace(' ', '')
                    cands.append(('addr' if deref else 'addr?', src))
        elif op in ('call', 'jp'):
            cands.append(('call', args.split(',')[-1]))
        elif op == 'dw':
            for p in args.split(','):
                cands.append(('dw', p))
        for kind, expr in cands:
            expr = expr.strip()
            if expr.lower() in ('hl', 'hl+', 'hl-', 'hli', 'hld', 'de', 'bc', 'c', 'a'):
                continue
            v, nm = evaluate(expr, names)
            if op == 'ldh' and v is not None and v < 0x100:
                v += 0xFF00
            if v is None or not is_ram(v):
                continue
            refs[v].append((kind, bank, f, n, nm, routine))

    # A 16-bit constant $FF80-$FFFF in `dw` or `ld rr,nn` is far more often a
    # small negative number (a speed, an offset) than an HRAM pointer: keep such
    # hits only where the same address is also read or written, or is named.
    negatives = {}
    for a in list(refs):
        if a < 0xFF80:
            continue
        rw = any(k in ('read', 'write', 'call', 'addr') for k, *_ in refs[a])
        if not rw and not any(x[4] for x in refs[a]):
            negatives[a] = len(refs.pop(a))
        else:
            keep = [x for x in refs[a] if x[0] != 'dw' or x[4]]
            if keep:
                refs[a] = keep
            else:
                negatives[a] = len(refs.pop(a))

    # What the source's own comments say about an address nobody has named:
    # comment paragraphs (runs of comment lines) and trailing comments.
    paras, cur = [], []
    for f, n, text in lines:
        if f.startswith('ram/'):
            continue
        st = text.strip()
        if st.startswith(';'):
            cur.append(st.lstrip(';').strip())
            continue
        if cur:
            paras.append(' '.join(cur))
            cur = []
        if ';' in strip_comment(text) + ';' and ';' in text and not st.startswith(';'):
            paras.append(text.split(';', 1)[1].strip())
    said = {}
    for c in paras:
        c = re.sub(r'\s*;?\[(ok|dc|\?)\]', '', c).replace('|', '/').replace('`', '')
        for m in re.finditer(r'\$([C-Fc-f][0-9A-Fa-f]{3})\b', c):
            ad = int(m.group(1), 16)
            if ad in refs and ad not in said:
                lo = max(0, m.start() - 60)
                hi = m.end() + 80
                said[ad] = ('…' if lo else '') + c[lo:hi].strip() + ('…' if hi < len(c) else '')

    args = sys.argv[1:]
    if '--sites' in args:
        a = int(args[args.index('--sites') + 1], 16)
        for kind, b, f, n, nm, rt in refs.get(a, []):
            print(f'{f}:{n}  bank ${b:02X}  {kind:5} {rt}  {nm or ""}')
        return

    def name_of(a):
        d = decl.get(a)
        if d and d[0]:
            return d[0]
        for kind, b, f, n, nm, rt in refs.get(a, []):
            if nm and names.get(nm) == a:
                return nm
        return None

    def owner(a):
        """Nearest declared label at or below a, for addresses inside a block."""
        for b in range(a, max(a - 0x200, 0xC000) - 1, -1):
            d = decl.get(b)
            if d and d[0]:
                size = d[1]
                if b == a or (size and a < b + size):
                    return d[0], a - b
                return None
        return None

    rows = []
    for a in sorted(refs):
        r = refs[a]
        kinds = defaultdict(int)
        for k, *_ in r:
            kinds[k.rstrip('?')] += 1
        bks = sorted({b for _, b, *_ in r})
        nm = name_of(a)
        own = None if nm else owner(a)
        users = []
        for x in r:
            if x[5] and x[5] not in users:
                users.append(x[5])
        rows.append((a, nm, own, len(r), kinds, bks, users))

    named = sum(1 for x in rows if x[1] or x[2])
    unnamed = [x for x in rows if not x[1] and not x[2]]
    never = sorted(a for a, d in decl.items() if d[0] and d[3] != 'ram/audio_ram.asm'
                   and not d[3].startswith('constants/audio') and not any(
        o in refs for o in range(a, a + (d[1] or 1))))

    if '--md' in args or '--unnamed' in args:
        print('| Address | Name | Refs | Use | Banks | Used by | Source comment (unnamed only) |')
        print('|---|---|---:|---|---|---|---|')
        for a, nm, own, cnt, kinds, bks, users in rows:
            if '--unnamed' in args and (nm or own):
                continue
            label = f'`{nm}`' if nm else (f'`{own[0]}+{own[1]}`' if own else '—')
            use = ', '.join(f'{k} {v}' for k, v in sorted(kinds.items()))
            who = ', '.join(f'`{u}`' for u in users[:3]) + (f' +{len(users) - 3}' if len(users) > 3 else '')
            print(f'| `${a:04X}` | {label} | {cnt} | {use} | '
                  + ' '.join(f'${b:02X}' for b in bks) + f' | {who} | '
                  + ('' if (nm or own) else said.get(a) or f'(region: {region_of(a) or "?"})') + ' |')
        if '--md' in args and negatives:
            print()
            print('Left out as 16-bit constants rather than HRAM addresses (only ever in '
                  '`dw` or `ld rr,nn`, never read or written): '
                  + ', '.join(f'`${a:04X}`' for a in sorted(negatives)) + '.')
        if '--md' in args and never:
            print()
            print('Declared but never referenced from code: '
                  + ', '.join(f'`{decl[a][0]}` (`${a:04X}`)' for a in never) + '.')
        return

    print(f'{len(rows)} RAM addresses referenced from code '
          f'({sum(x[3] for x in rows)} references)')
    print(f'  {named} named (directly or as part of a named block), '
          f'{len(unnamed)} without a name')
    print(f'  {len(never)} declared labels never referenced')


if __name__ == '__main__':
    main()
