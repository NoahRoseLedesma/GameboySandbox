; Misc methods
include "hardware.inc"

SECTION "Util", ROM0

; Busy-wait until VBlank
WaitForVBlank:
    ; Check that the scanline is out of the screen
    ld a, [rLY]
    cp 144
    jr C, WaitForVBlank
    ret

; Busy-wait until not VBlank
WaitForNotVBlank:
    ; Check that the scanline is out of the screen
    ld a, [rLY]
    cp 144
    jr NC, WaitForNotVBlank
    ret

; Zero out a memory region
; @param hl A pointer to the memory region to zero
; @param bc The number of bytes to zero out
ZeroOut:
    ld a, 0
    ld [hli], a
    dec bc
    ld a, b
    or c
    cp 0
    jr nz, ZeroOut
    ret

; Fill a memory region with the specified byte
; @param hl A pointer to the memory region
; @param bc The number of bytes to write over
; @param d  The byte to write
Fill:
    ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or c
    cp 0
    jr NZ, Fill
    ret

; Clears the backgound tile map
ClearBGTileMap:
    ld hl, $9800
    ld bc, $9BFF - $9800
    call ZeroOut
    ret

EXPORT WaitForVBlank
EXPORT WaitForNotVBlank
EXPORT Fill
EXPORT ClearBGTileMap
EXPORT ZeroOut