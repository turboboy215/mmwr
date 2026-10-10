@echo off
rem Mega Man: Dr. Wily's Revenge disassembly - Windows build
rem Requires rgbasm/rgblink/rgbfix on PATH (or edit RGBDS below).

set RGBDS=

for %%f in (gfx\*.png gfx\sprites\*.png gfx\screens\*.png gfx\stages\*.png gfx\bosses\*.png gfx\cutscenes\*.png gfx\ending\*.png gfx\wily_machine\*.png) do (
  %RGBDS%rgbgfx -o %%~dpnf.2bpp %%f
  if errorlevel 1 goto fail
)

%RGBDS%rgbasm -Weverything -Wno-obsolete -Wno-unmapped-char -o main.o main.asm
if errorlevel 1 goto fail
%RGBDS%rgblink -n mmwr.sym -m mmwr.map -o mmwr.gb main.o
if errorlevel 1 goto fail
%RGBDS%rgbfix -f hg mmwr.gb
if errorlevel 1 goto fail

fc /b mmwr.gb baserom.gb > nul
if errorlevel 1 (
  echo MISMATCH: mmwr.gb differs from baserom.gb
  fc /b mmwr.gb baserom.gb
  exit /b 1
)
echo OK: mmwr.gb is byte-identical to baserom.gb
exit /b 0

:fail
echo Build failed.
exit /b 1
