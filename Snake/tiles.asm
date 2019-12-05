; Memory section for tiles.
; This is formatted to be copied as is
INCLUDE "hardware.inc"

SECTION "Tiles", ROM0
START_TILES:
SNAKE_TILES:
    incbin "SnakeTiles.chr", 0, 23 * 16 ; 22 tiles, each 16 bytes

REPT (528) - (23 * 16)
    db 0
ENDR

TEXT_FONT:
    incbin "AsciiFont.chr", 528, 2048 - 528
END_TILES:

; Copy tile data from RAM to tile data table.
; Assumes that CPU has lock on VRAM
LoadTiles:
    ld de, START_TILES
    ld hl, $9000
    ld bc, END_TILES - START_TILES
    call MemCpy

    ret


EXPORT LoadTiles