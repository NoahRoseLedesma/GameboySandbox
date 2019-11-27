SECTION "Print", ROM0

; Write a string to the background tile map
; Assumes that the CPU has lock on VRAM
; To display the contents of the tile map, display must be called
; @param de A pointer to the string to display
; @param b The X position to write the string
; @param c The Y position to write the string
Print:
	ld hl, 0

	; hl = y * 32
.multiplicationLoop:
	ld a, c
	or a
	jr z, .endMultiplicationLoop

	; Add 32 to the lower byte
	ld a, l
	add 32
	ld l, a

	; Add the carry bit to the high byte
	ld a, h
	adc 0
	ld h, a

	dec c
	jr nz, .multiplicationLoop
.endMultiplicationLoop:

	; hl += x + background tile map start address
	ld a, l
	add b
	ld l, a
	ld a, h
	adc $98
	ld h, a

	; de = char* str
	; hl = void* dest
	call StrCpy
	
	ret

; Display the contents of the background tile map
; Display:


EXPORT Print
