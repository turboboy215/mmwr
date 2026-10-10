Graphics as PNGs; build.sh and make.bat turn every gfx/*.png and gfx/*/*.png
into a .2bpp next to it with rgbgfx, and the build proves the round trip.

  font.png, health_bar.png, hitbox_viewer.png    bank $00
  sprites/                                       bank $04 (step 3.1)
  screens/                                       bank $06 tiles (step 3.2)
  stages/                                        bank $0C stage tilesets (step 3.3)
  bosses/                                        bank $07 object types 30-56 (step 4.4)
  cutscenes/                                     bank $0B cutscene sprites (step 5.4)
  wily_machine/                                  bank $0D Wily Machine room tiles (step 5.6)
  tilemaps/*.tilemap                             bank $06 maps, raw bytes (step 3.2);
                                                 wily_stage_select is bank $0B's

Sprites are 8x8 in the stages and on the title screen (PlayStage and
TitleScreen clear LCDC bit 2 in wShadowLCDC with `and $7B`), but the stage
select switches to 8x16 (it ORs $64 into wShadowLCDC). The PNGs are all laid
out as plain 8x8 tiles; stage_select.png is four 8x16 sprites side by side as
tile pairs.

PNGs are grayscale, white = colour 0 ... black = colour 3, and laid out in tile
order, left to right. Where a run's tile count does not fill the last row, the
source INCBINs only the real tiles (`INCBIN "x.2bpp", 0, N * 16`). Extract more
with tools/gfx.py.
