#!/bin/sh
# Mega Man: Dr. Wily's Revenge disassembly - build and verify.
#
#   ./build.sh          assemble, link, fix, and compare against baserom.gb
#   ./build.sh clean    remove build products
#
# Needs rgbasm/rgblink/rgbfix on PATH (see tools/bootstrap-rgbds.sh) and
# baserom.gb in this directory. Windows: use make.bat instead.
set -e
cd "$(dirname "$0")"

if [ "$1" = "clean" ]; then
	rm -f mmwr.gb main.o mmwr.sym mmwr.map gfx/*.2bpp gfx/*/*.2bpp
	echo "cleaned"
	exit 0
fi

[ -f baserom.gb ] || { echo "error: baserom.gb is missing (see README.md)"; exit 1; }

# Graphics: every gfx/*.png and gfx/*/*.png becomes a .2bpp next to it.
for png in gfx/*.png gfx/*/*.png; do
	[ -e "$png" ] || continue
	rgbgfx -o "${png%.png}.2bpp" "$png"
done

rgbasm -Weverything -Wno-obsolete -Wno-unmapped-char -o main.o main.asm
rgblink -n mmwr.sym -m mmwr.map -o mmwr.gb main.o
rgbfix -f hg mmwr.gb

if cmp mmwr.gb baserom.gb; then
	echo "OK: mmwr.gb is byte-identical to baserom.gb"
else
	echo "MISMATCH: the source no longer reproduces the ROM"
	exit 1
fi
