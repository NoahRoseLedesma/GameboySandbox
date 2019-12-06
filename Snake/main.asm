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

    ; Load the game border
    call MakeBorder

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

MakeBorder:
    ; Corners
    ld hl, $9800
    ld a, TILE_BORDER_NW_CORNER
    ld [hl], a
    
    ld hl, $9800 + 19
    ld a, TILE_BORDER_NE_CORNER
    ld [hl], a

    ld hl, $9800 + (32 * 14)
    ld a, TILE_BORDER_SW_CORNER
    ld [hl], a

    ld hl, $9800 + (32 * 14) + 19
    ld a, TILE_BORDER_SE_CORNER
    ld [hl], a

    ; Horizontal borders
    ld hl, $9801
    ld bc, 18
    ld d, TILE_BORDER_N
    call Fill

    ld hl, $9801 + (32 * 14)
    ld bc, 18
    ld d, TILE_BORDER_S
    call Fill

    ; Vertical borders
    ld hl, $9800 + 32
    ld bc, 13
.vertialBorderLoop
    ld a, TILE_BORDER_W
    ld [hl], a
    ld a, l
    add 19
    ld l, a
    ld a, h
    adc 0
    ld h, a
    ld a, TILE_BORDER_E
    ld [hl], a
    ld a, l
    add 32 - 19
    ld l, a
    ld a, h
    adc 0
    ld h, a
    dec bc
    ld a, b
    or c
    cp 0
    jr nz, .vertialBorderLoop

    ret