INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
    di
    jp Start
REPT $150 - $104 ; Repeat from memory address 104 to 150
	db 0 ; Fill with zeros
         ; I think this space is needed for header elemnets added by rgbfix
ENDR

SECTION "Vars", WRAM0
SpriteMovementDirection:
    DS 1
SpriteMovementCounter:
    DS 1

SECTION "Program", ROM0
; Zero out the space in HRAM for OAM variables
CLEAR_OAM_VARS:
  ld  hl, OAM_Vars_Start
  ld  bc, $A0
.clear_oam_loop
  ld  a,$0
  ld  [hli],a
  dec bc
  ld  a,b
  or  c
  jr  nz,.clear_oam_loop
  ret

WaitForVBlank:
.waitForVBlankLoop
	ld a, [rLY] ; The memory at address rLY is the y-position of the lcd scan
	cp 144 ; If y >= 144 we are in vblank. If register a is smaller than 144 then C is set.
	jp C, .waitForVBlankLoop
    ret

WaitForNotVBlank:
.waitForNotVBlankLoop
    ld a, [rLY] ; The memory at address rLY is the y-position of the lcd scan
	cp 144 ; If y >= 144 we are in vblank. If register a is smaller than 144 then C is set.
	jp NC, .waitForNotVBlankLoop
    ret

InitSprites:
    ; Y position
    ld e, 80
    ; First character X
    ld d, 44
    ; String char position
    ld hl, HelloWorldString
    ; Sprite address
    ld bc, OAM_Vars_Start

.initSpritesLoop:
    ; Set y position
    ld a, e
    push hl
    ld h, b
    ld l, c
    ld [hli], a

    ; Set x position and update next x
    ld a, d
    ld [hli], a
    add 8
    ld d, a

    ; Set the tilenum and increment string pointer
    ; hl -> bc
    ld b, h
    ld c, l
    ; Get the pointer into the string from the stack
    pop hl
    ; Get the char at the pointer into a
    ld a, [hl]
    ; Increment the pointer
    inc hl
    cp 0 ; Are we looking at the null character?
    ret z ; Return if we reach the end of the string.
    cp " " ; Are we looking at a space?
    jr z, .charWasSpace

    ; Return the pointer to the stack
    push hl
    ; bc -> hl
    ld h, b
    ld l, c
    ld [hli], a
    
    ; Set the sprite flags
    xor a
    ld [hli], a

    ld b, h
    ld c, l
    pop hl

    jr .initSpritesLoop
.charWasSpace:
    ; If we see a space we skip this character.
    ; Which means we need to overwrite the X and Y entries
    dec bc
    dec bc
    ; Then go on to the next character
    jr .initSpritesLoop

UpdateSprites:
    ; Iterate through the string
    ld bc, HelloWorldString
    ld hl, OAM_Vars_Start
    ld a, [SpriteMovementDirection]
    ld e, a
.updateSpritesLoop:
    ; Are we at the end of the string?
    ld a, [bc]
    cp 0
    jr Z, .endUpdateSpritesLoop

    ; Are we on a space?
    cp " "
    jr NZ, .continueUpdateSpritesLoop
    inc bc
    ld a, e
    xor 1
    ld e, a
    jr .updateSpritesLoop
.continueUpdateSpritesLoop
    ld a, [hl]
    ld d, a ; d = y-pos
    ld a, e
    cp 0
    jr z, .moveDown
    ld e, 0
    inc d
    jr .doneMove
.moveDown
    ld e, 1
    dec d
.doneMove
    ld a, d
    ld [hli], a
    inc hl
    inc hl
    inc hl
    
    inc bc
    jr .updateSpritesLoop
.endUpdateSpritesLoop

    ld a, [SpriteMovementCounter]
    inc a
    cp 2
    jr NZ, .dontResetMovementCounter

    ld a, [SpriteMovementDirection]
    xor 1 ; Flip 0->1 1->0
    ld [SpriteMovementDirection], a

    ld a, 0 ; To reset counter
.dontResetMovementCounter
    ld [SpriteMovementCounter], a
    ret
    
Init:
    call WaitForVBlank

	; Disable the LCD
	ld a, LCDCF_OFF
	ld [rLCDC], a

    call CLEAR_OAM_VARS

    ld de, TileMapData ; The address to start copying from
	ld hl, $8000 ; The address to copy to - Sprite pattern table entry 0
	ld bc, TileMapDataEnd - TileMapData ; The number of bytes to copy 
	call MemCpy

    call InitSprites
    ld a, 0
    ld [SpriteMovementDirection], a
    ld a, 1
    ld [SpriteMovementCounter], a

    ; Display registers
	ld a, %11100100
	ld [rBGP], a ; Pick a palette and set the 'register'

    ; Set scroll position to <0,0>
	ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	; Disable sound
	ld [rNR52], a

	; Enable LCD and enable sprite display
	ld a, LCDCF_ON | LCDCF_BG8000 | LCDCF_OBJON
	ld [rLCDC], a

    ; move DMA subroutine to HRAM
    call DMA_COPY

    ret

Start:
    call Init

.programLoop
    call WaitForVBlank
    
    ; Use DMA to copy OAM data to VRAM.
    call UpdateSprites
    call $FF80
    call WaitForNotVBlank
    call WaitForVBlank
    call WaitForNotVBlank
    call WaitForVBlank
    call WaitForNotVBlank
    ld b, b
    jr .programLoop

SECTION "OAM Vars", WRAM0[$C100]
OAM_Vars_Start:
H_Sprite:
    DS 4
E_Sprite:
    DS 4
L1_Sprite:
    DS 4
L2_Sprite:
    DS 4
O1_Sprite:
    DS 4
W_Sprite:
    DS 4
O2_Sprite:
    DS 4
R_Sprite:
    DS 4
L3_Sprite:
    DS 4
D_Sprite:
    DS 4
OAM_Vars_End:

SECTION "Data", ROM0
TileMapData:
    INCBIN "font.chr", 0, 2048
TileMapDataEnd:
HelloWorldString:
    DB "Hello World"
HelloWorldStringEnd:
    DB 0