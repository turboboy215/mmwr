#!/bin/sh
# Build RGBDS from source into ~/bin. For fresh Linux/cloud sessions that have
# no rgbds package (it is not in Ubuntu's repos). Takes about a minute.
#
#   sh tools/bootstrap-rgbds.sh && export PATH="$HOME/bin:$PATH"
set -e
VER=${RGBDS_VERSION:-v0.9.4}
WORK=$(mktemp -d)
git clone --depth 1 --branch "$VER" https://github.com/gbdev/rgbds.git "$WORK/rgbds"
cmake -S "$WORK/rgbds" -B "$WORK/rgbds/build" -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF
cmake --build "$WORK/rgbds/build" -j "$(nproc 2>/dev/null || echo 4)"
mkdir -p "$HOME/bin"
cp "$WORK/rgbds"/rgbasm "$WORK/rgbds"/rgblink "$WORK/rgbds"/rgbfix "$WORK/rgbds"/rgbgfx "$HOME/bin/"
rm -rf "$WORK"
echo "Installed to $HOME/bin:"
"$HOME/bin/rgbasm" --version
