INCLUDE "hardware.inc"
INCLUDE "TileGuide.inc"

SECTION "Header", ROM0[$100]
    di
    jp Start
REPT $150 - $104
    db 0
ENDR

SECTION "Main", ROM0
Start:
    ; Turn of the LCD display
    call WaitForVBlank
    ld a, LCDCF_OFF
    ld [rLCDC], a

    ; Copy the tiles into VRAM
    call LoadTiles

    ; Clear the background tile map
    call ClearBGTileMap

    ; Print a debug string
    ld de, DEBUG_STRING_0
    ld hl, $9800 + 32 * 0
    call StrCpy
    ld de, DEBUG_STRING_1
    ld hl, $9800 + 32 * 1
    call StrCpy
    ld de, DEBUG_STRING_2
    ld hl, $9800 + 32 * 2
    call StrCpy
    ld de, DEBUG_STRING_3
    ld hl, $9800 + 32 * 3
    call StrCpy
    ld de, DEBUG_STRING_4
    ld hl, $9800 + 32 * 4
    call StrCpy
    ld de, DEBUG_STRING_5
    ld hl, $9800 + 32 * 5
    call StrCpy

    ; Select a palette
    ld a, %11100100
    ld [rBGP], a
    ; Reset scanlines
    xor a
    ld [rSCY], a
    ld [rSCX], a 
    ; Shut sound down
    ld [rNR52], a
    ; Turn screen on, display background
    ld a, %10000001
    ld [rLCDC], a

    halt
    halt

SECTION "Vars", ROM0
DEBUG_STRING_0:
    DB TILE_BORDER_NW_CORNER, TILE_BORDER_N, TILE_BORDER_N, TILE_BORDER_N, TILE_BORDER_NE_CORNER, 0
DEBUG_STRING_1:
    DB TILE_BORDER_W, TILE_SNAKE_SE_CORNER, TILE_SNAKE_HORIZONTAL, TILE_SNAKE_SW_CORNER, TILE_BORDER_E, 0
DEBUG_STRING_2:
    DB TILE_BORDER_W, TILE_SNAKE_VERTICAL, TILE_SNAKE_S_HEAD, TILE_SNAKE_VERTICAL, TILE_BORDER_E, 0
DEBUG_STRING_3:
    DB TILE_BORDER_W, TILE_SNAKE_N_TAIL, TILE_SNAKE_NE_CORNER, TILE_SNAKE_NW_CORNER, TILE_BORDER_E, 0
DEBUG_STRING_4:
    DB TILE_BORDER_SW_CORNER, TILE_BORDER_S, TILE_BORDER_S, TILE_BORDER_S, TILE_BORDER_SE_CORNER, 0
DEBUG_STRING_5:
    DB " Hello World", 0