#Frame-table parsing for tools/bankgen.py.
#
#A frame table is a list of `dw` pointers to frames; a frame is a 4-byte hitbox
#(when `hitbox`) followed by a DrawMetasprite metasprite: dx, dy, a grid byte
#(cols << 4 | rows), the grid's tiles, then (dx, dy, tile) triples ended by $80
#(a grid byte of 0 ends it at once).
d = b''  # set by the caller (bankgen.py sets it to the bank's CPU view)
def w(a): return d[a]|d[a+1]<<8
def msprite_len(a):
    g=d[a+2]; n=(g>>4)*(g&15); p=a+3+n
    if g==0: return 3
    while d[p]!=0x80: p+=3
    return p+1-a
def frame_len(a, hitbox=True):
    return (4 if hitbox else 0) + msprite_len(a + (4 if hitbox else 0))
def parse(lo,hi,tables,frames,hitbox=True):
    """Items ('table'|'frame'|'gap', start, end) covering lo..hi. Tables run
    until the next known start or a word that does not point into lo..hi;
    frames that nothing points at but that sit between known items are found
    by decoding forward, so a 'gap' means bytes that are neither."""
    tables=set(tables); frames=set(frames)
    tend={}
    changed=True
    while changed:
        changed=False
        starts=sorted(tables|frames)
        for t in sorted(tables):
            nxt=min([s for s in starts if s>t]+[hi])
            p=t
            while p+1<nxt and lo<=w(p)<hi:
                v=w(p)
                if v not in frames and v not in tables:
                    frames.add(v); changed=True
                p+=2
            tend[t]=p
    items=[]; p=lo
    starts=sorted(tables|frames)
    def fill(a,b):
        # orphan frames: decode forward from a; all-or-nothing up to b
        q=a; got=[]
        try:
            while q<b:
                L=frame_len(q,hitbox); got.append((q,q+L)); q+=L
        except IndexError:
            q=-1
        if q==b:
            for s,e in got: items.append(('frame',s,e))
        else:
            items.append(('gap',a,b))
    for i,s in enumerate(starts):
        if s>p: fill(p,s)
        nxt=starts[i+1] if i+1<len(starts) else hi
        e=tend[s] if s in tables else s+frame_len(s,hitbox)
        items.append(('table' if s in tables else 'frame',s,e))
        if e<nxt: fill(e,nxt)
        p=nxt
    return items
