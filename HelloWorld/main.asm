INCLUDE "hardware.inc"

SECTION "Header", ROM0[$100]
	di ; Disable interrupts
	jp Start ;

REPT $150 - $104 ; Repeat from memory address 104 to 150
	db 0 ; Fill with zeros
ENDR

SECTION "Main", ROM0
	; We need to wait for VBlank to load font data into VRAM 
	; I believe that VRAM is locked by the PPU until VBlank.

Start:	
.waitForVBlank
	ld a, [rLY] ; The memory at address rLY is the y-position of the lcd scan
	cp 144 ; If y >= 144 we are in vblank. If register a is smaller than 144 then C is set.
	jp C, .waitForVBlank

	; Disable the LCD
	ld a, LCDCF_OFF
	ld [rLCDC], a
	
	; With LCD disabled we can access VRAM
	; Copy the font from static memory to VRAM
	ld de, FontTiles ; The address to start copying from
	ld hl, $9000 ; The address to copy to (VRAM)
	ld bc, FontTilesEnd - FontTiles ; The number of bytes to copy 
	call MemCpy
	
 	; Copy the string to print
 	ld de, HelloWorldString ; de points to the string
	ld b, 4
	ld c, 16
	call Print

	ld de, HelloWorldSubtitle
	ld b, 2
	ld c, 8
	call Print

.init
	; Display registers
	ld a, %11100100
	ld [rBGP], a ; Pick a palette and set the 'register'

	; Set scroll position to <0,0>
	ld a, 0
	ld [rSCY], a
	ld [rSCX], a

	; Disable sound
	ld [rNR52], a

	; Enable LCD and enable BG display
	ld a, LCDCF_ON | LCDCF_BGON
	ld [rLCDC], a

	; Use double halt trick to disable CPU
	halt
	halt

SECTION "Data", ROM0

FontTiles:
	INCBIN "font.chr", 0, 2048
FontTilesEnd:

HelloWorldString:
	db "Hello World.", 0 ; Note that the 0 is being appended here to null-terminate the string.
			     ; Null-termination is required when using db to write strings. 
EndHelloWorldString:
HelloWorldSubtitle:
	db "Tezuni "
	db 1 
	db " Gameboy!", 0

