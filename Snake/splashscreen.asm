INCLUDE "hardware.inc"

SECTION "Splash Screen", ROM0

; Displays the splash screen and waits to start the game.
; This routine will also generate a random seed based on how long the user waits.
; This routine assumes LCD is disabled. It will enable it to print, and disable it on return.
; @return bc A randomish seed
DoSplashScreen:
    ld de, SplashScreenString
    ld b, 16 - (SplashScreenStringEnd - SplashScreenString)
    ld c, 8
    call Print

    ; Turn screen on
    ld a, %10000001
    ld [rLCDC], a

    ; Seed
    ld bc, 0

.splashScreenLoop
    call WaitForVBlank
    inc bc
    call WaitForNotVBlank

    ; Check for start button press
    ld hl, rP1 
    ld a, %00010000 ; Enable reading of non-direction buttons by setting this bit
    ld [hl], a
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl]
    ld a, [hl] ; Takes a few cycles to get accurate readings
    and %00001000 ; Mask for start button
    cp 0
    jr NZ, .splashScreenLoop

    call WaitForVBlank
    xor a
    ld [rLCDC], a

    push bc
    ; Clear the background tile map
    call ClearBGTileMap
    pop bc
    
    ret

SECTION "Splash Screen Data", ROM0
SplashScreenString:
DB "Press Start", 0
SplashScreenStringEnd:

EXPORT DoSplashScreen