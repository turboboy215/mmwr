#!/bin/sh
# Mega Man: Dr. Wily's Revenge disassembly - build and verify.
#
#   ./build.sh          assemble, link, and compare against baserom.gb
#   ./build.sh clean    remove build products
#
# Needs rgbasm/rgblink/rgbgfx on PATH (see tools/bootstrap-rgbds.sh). With
# baserom.gb in this directory the result is compared byte for byte; without it
# (CI, or anyone who has not dumped the cartridge) it is checked against the
# known SHA-256 of the US ROM instead - no source file reads the base ROM, so
# that is the same test. Windows: use make.bat instead.
set -e
cd "$(dirname "$0")"

if [ "$1" = "clean" ]; then
	rm -f mmwr.gb main.o mmwr.sym mmwr.map gfx/*.2bpp gfx/*/*.2bpp
	echo "cleaned"
	exit 0
fi

SHA256=33d16365318411f063edd9100c79458aabb7ea71bb1873e30f38b93814f0ec6e

# Graphics: every gfx/*.png and gfx/*/*.png becomes a .2bpp next to it.
for png in gfx/*.png gfx/*/*.png; do
	[ -e "$png" ] || continue
	rgbgfx -o "${png%.png}.2bpp" "$png"
done

rgbasm -Weverything -Wno-obsolete -Wno-unmapped-char -o main.o main.asm
rgblink -n mmwr.sym -m mmwr.map -o mmwr.gb main.o

if [ -f baserom.gb ]; then
	if cmp mmwr.gb baserom.gb; then
		echo "OK: mmwr.gb is byte-identical to baserom.gb"
	else
		echo "MISMATCH: the source no longer reproduces the ROM"
		exit 1
	fi
else
	sum=$(sha256sum mmwr.gb 2>/dev/null || shasum -a 256 mmwr.gb)
	if [ "${sum%% *}" = "$SHA256" ]; then
		echo "OK: mmwr.gb matches the SHA-256 of the US ROM (no baserom.gb to compare)"
	else
		echo "MISMATCH: mmwr.gb does not match the SHA-256 of the US ROM"
		exit 1
	fi
fi
