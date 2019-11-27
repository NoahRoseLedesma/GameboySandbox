SECTION "MemCpy", ROM0


; Copy memory area
; @param de A pointer to the region of memory to copy from
; @param hl A pointer to the region of memory to copy to
; @param bc Number of bytes to copy
; @return Does not put a return value on the stack
; @return Invalidates a, de, hl, bc

MemCpy:
	ld a, b
	or c
	ret z ; Return if zero
.MemCpyLoop
	ld a, [de]
	inc de
	ldi [hl], a
	dec bc
	ld a, b
	or c
	jr nz, .MemCpyLoop

	ret

; Copy a string upto but including the null character
; @param de A pointer to the string to copy from
; @param hl A pointer to the string to copy to
; @return Does not put a return value on the stack
; @return Invalidates a, de, hl
StrCpy:
.StrCpyLoop
	ld a, [de]
	inc de
	or a
	ret z
	ldi [hl], a
	jr .StrCpyLoop


EXPORT MemCpy
EXPORT StrCpy
