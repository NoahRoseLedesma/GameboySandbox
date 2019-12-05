; Facilitate DMA copy

; Copy Data subroutine
; Used to copy the DMA subroutine to HRAM.

; Placing this subroutine in address $28 lets us use the reset instruction for calling.
; I think the purpose of doing this as opposed to a standard call is performance.
; Note: that doesnt seem to make sense. rst opcode takes 32 cycles, call takes 12
SECTION "Copy Data", ROM0
COPY_DATA:
  ; pop return address off stack into hl
  pop hl
  push bc

  ; here we get the number of bytes to copy
  ; hl contains the address of the bytes following the "rst $28" call

  ; put first byte into b ($00 in this context)
  ld  a,[hli]
  ld  b,a

  ; put second byte into c ($0D in this context)
  ld  a,[hli]
  ld  c,a

  ; bc now contains $000D
  ; hl now points to the first byte of our assembled subroutine (which is $F5)
  ; begin copying data
.copy_data_loop
  
  ; load a byte of data into a
  ld  a,[hli]

  ; store the byte in de, our destination ($FF80 in this context)
  ld  [de],a
  
  ; go to the next destination byte, decrease counter
  inc de
  dec bc

  ; check if counter is zero, if not repeat loop
  ld  a,b
  or  c
  jr  nz,.copy_data_loop
  
  ; all done, return home
  pop bc
  jp  hl
  ret

SECTION "DMA Subroutine", ROM0
DMA_COPY:
  ; load de with the HRAM destination address
  ld  de,$FF80

  call COPY_DATA

  ; the amount of data we want to copy into HRAM, $000D which is 13 bytes
  DB  $00,$0D

  ; this is the above DMA subroutine hand assembled, which is 13 bytes long
  DB  $F5, $3E, $C1, $EA, $46, $FF, $3E, $28, $3D, $20, $FD, $F1, $D9
  ret

EXPORT DMA_COPY