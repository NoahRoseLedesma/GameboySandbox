INCLUDE "TileGuide.inc"
INCLUDE "hardware.inc"
; Circular array to represent snake cell positions
SECTION "SnakeData", WRAM0
SNAKE_POSITIONS:
DS 17 * 13 * 2
SNAKE_POSITIONS_END:
DS 4 ; Some extra space to account for me being a headass

SNAKE_HEAD:
DS 2

SNAKE_TAIL:
DS 2

SNAKE_DIRECTION:
DS 1


SECTION "SnakeMethods", ROM0

; Sets up the snake array
InitSnakeData:
    ld hl, SNAKE_POSITIONS
    ld bc, SNAKE_POSITIONS_END - SNAKE_POSITIONS
    call ZeroOut

    ld hl, SNAKE_HEAD
    ld bc, SNAKE_POSITIONS
    ld [hl], b
    inc hl
    ld [hl], c

    ; Tail starts past head
    inc bc
    inc bc
    ld hl, SNAKE_TAIL
    ld [hl], b
    inc hl
    ld [hl], c

    ld hl, SNAKE_DIRECTION
    ld a, SNAKE_DIRECTION_EAST
    ld [hl], a

    ; Load the first few cells
    ld b, 4
    ld c, 12
    call PushHead

    ld b, 5
    ld c, 12
    call PushHead

    ld b, 6
    ld c, 12
    call PushHead

    ; Draw the first few cells
    ld b, 4
    ld c, 12
    ld de, .snakeString
    call Print

    ret
.snakeString
    db TILE_SNAKE_E_TAIL, TILE_SNAKE_HORIZONTAL, TILE_SNAKE_W_HEAD, 0

; Push a cell onto the snake array
; @param b Cell X coord
; @param c Cell Y coord
PushHead:
    ld b, b
    ; Get the address of the current head
    ld hl, SNAKE_HEAD
    ld d, [hl]
    inc hl
    ld e, [hl]
    ld h, d
    ld l, e

    ; Go to the space for the next head by adding 2 to the address
    ld a, l
    add 2
    ld l, a
    ld a, h
    adc 0
    ld h, a

    ; Check for address overflow
    ld de, SNAKE_POSITIONS_END
    ld a, e
    sub l
    ld a, d
    sbc h
    jr NZ, .pushDidNotOverflow

    ; If there was an overflow reset address to SNAKE_POSITIONS
    ld hl, SNAKE_POSITIONS
.pushDidNotOverflow
    ; Set new head address
    ld de, SNAKE_HEAD
    ld a, h
    ld [de], a
    ld a, l
    inc de
    ld [de], a

    ; Write x and y values
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a

    ret

; Pop a cell from the tail of the snake array
PopTail:
    ; bc = *SNAKE_TAIL
    ld hl, SNAKE_TAIL
    ld b, [hl]
    inc hl
    ld c, [hl]

    ; bc += 2
    ld a, c
    add 2
    ld c, a
    ld a, b
    adc 0
    ld b, a

    ; SNAKE_POSITIONS_END - SNAKE_POSITIONS > 0
    ld hl, SNAKE_POSITIONS_END
    ld a, l
    sub c
    ld a, h
    sbc b

    jr C, .popDidNotOverflow
    jr NZ, .popDidNotOverflow

    ; If the pop overflowed reset tail address
    ld bc, SNAKE_POSITIONS
.popDidNotOverflow:
    ld hl, SNAKE_TAIL
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a

    ret

; Move the snake one tile
; @param d The new direction of the snake
MoveSnake:
    ; Set new direction
    ld hl, SNAKE_DIRECTION
    ld [hl], d

    ; Get the position of the head
    ld hl, SNAKE_HEAD
    ld b, [hl]
    inc hl
    ld c, [hl]
    ld h, b
    ld l, c
    ; Save this address for later
    push hl
    ld b, [hl] ; X
    inc hl
    ld c, [hl] ; Y

    ; Determine new head position
    ld a, d
    cp SNAKE_DIRECTION_NORTH
    jr NZ, .directionNotNorth
    ; Y -= 1
    dec c
    jr .newPositionDetermined
.directionNotNorth
    cp SNAKE_DIRECTION_EAST
    jr NZ, .directionNotEast
    ; X += 1
    inc b
    jr .newPositionDetermined
.directionNotEast
    cp SNAKE_DIRECTION_SOUTH
    jr NZ, .directionNotSouth
    ; Y += 1
    inc c
    jr .newPositionDetermined
.directionNotSouth
    ; The direction must be west
    ; X -= 1
    dec b
.newPositionDetermined
    call PushHead

; Remove tail sprite
    ld hl, SNAKE_TAIL
    ld b, [hl]
    inc hl
    ld c, [hl]
    ld h, b
    ld l, c
    ld b, [hl] ; X
    inc hl
    ld c, [hl] ; Y
    ld d, 0
    call PutChar
    call PopTail

; Add a sprite for the new head
    ld hl, SNAKE_DIRECTION
    ld d, [hl]

    ld hl, SNAKE_HEAD
    ld b, [hl]
    inc hl
    ld c, [hl]
    ld h, b
    ld l, c
    ld b, [hl] ; X
    inc hl
    ld c, [hl] ; Y
    call PutChar

; Change the sprite of the old head
    pop hl ; hl = Old Head Address
    push hl
    ld b, [hl] ; X
    inc hl
    ld c, [hl] ; Y
    call GetChar ; d = GetChar
    ; Determine which tile to use for the next head from the current head and direction.
    ld hl, SNAKE_DIRECTION
    ld e, [hl]
    call GetReplacementHeadTile ; d = GetReplacementHeadTile(d, e)
    ld a, d
    pop hl
    ld b, [hl] ; X
    inc hl
    ld c, [hl] ; Y
    call PutChar

    ret

; Determine which of the tiles to use as the replacement for the old head when the snake moves
; @param e The direction of the movement
; @param d The old head tile ID
; @return d The tile id which should replace the old head
GetReplacementHeadTile:
    ld a, d
    cp TILE_SNAKE_W_HEAD
    jr NZ, .OldHeadWasNotWest

        ld a, e
        cp SNAKE_DIRECTION_NORTH
        jr NZ, .WestHeadNotNorth

        ld d, TILE_SNAKE_NW_CORNER
        ret
.WestHeadNotNorth
        cp SNAKE_DIRECTION_EAST
        jr NZ, .WestHeadNotEast

        ld d, TILE_SNAKE_HORIZONTAL
        ret
.WestHeadNotEast
        ; Else, we are pointed south
        ld d, TILE_SNAKE_SW_CORNER
        ret
    
.OldHeadWasNotWest
    ld a, d
    cp TILE_SNAKE_N_HEAD
    jr NZ, .OldHeadWasNotNorth

        ld a, e
        cp SNAKE_DIRECTION_EAST
        jr NZ, .NorthHeadNotEast

        ld d, TILE_SNAKE_NE_CORNER
        ret
.NorthHeadNotEast
        cp SNAKE_DIRECTION_SOUTH
        jr NZ, .NorthHeadNotSouth

        ld d, TILE_SNAKE_VERTICAL
        ret
.NorthHeadNotSouth
        ; Else, we are pointed west
        ld d, TILE_SNAKE_NW_CORNER
        ret

.OldHeadWasNotNorth
    ld a, d
    cp TILE_SNAKE_E_HEAD
    jr NZ, .OldHeadWasNotEast

        ld a, e
        cp SNAKE_DIRECTION_NORTH
        jr NZ, .EastHeadNotNorth

        ld d, TILE_SNAKE_NE_CORNER
        ret
.EastHeadNotNorth
        cp SNAKE_DIRECTION_SOUTH
        jr NZ, .EastHeadNotSouth

        ld d, TILE_SNAKE_SE_CORNER
        ret
.EastHeadNotSouth
        ; Else, we are poitned west
        ld d, TILE_SNAKE_HORIZONTAL
        ret

.OldHeadWasNotEast
    ; Else, the snake head is south
        ld a, e
        cp SNAKE_DIRECTION_NORTH
        jr NZ, .SouthHeadNotNorth

        ld d, TILE_SNAKE_VERTICAL
        ret
.SouthHeadNotNorth
        cp SNAKE_DIRECTION_WEST
        jr NZ, .SouthHeadNotWest

        ld d, TILE_SNAKE_SW_CORNER
        ret
.SouthHeadNotWest
        ; Else, we are pointed east
        ld d, TILE_SNAKE_SE_CORNER
        ret

; Gets the movement direction from the joypad.
; If there is no input, the direction will not change.
; @return d The direction of the snake
GetInputDirection:
    ld hl, rP1 
    ld a, %00100000 ; Enable reading of direction buttons by setting this bit
    ld [hl], a
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl]
    ld b, [hl] ; Takes a few cycles to get accurate readings
    
    ld a, b
    and P1F_0 ; Input right
    cp 0
    jr NZ, .NotInputRight
    ld d, SNAKE_DIRECTION_EAST
    ret
.NotInputRight
    ld a, b
    and P1F_1
    cp 0
    jr NZ, .NotInputLeft
    ld d, SNAKE_DIRECTION_WEST
    ret
.NotInputLeft
    ld a, b
    and P1F_2
    cp 0
    jr NZ, .NotInputUp
    ld d, SNAKE_DIRECTION_NORTH
    ret
.NotInputUp
    ld a, b
    and P1F_3
    cp 0
    jr NZ, .NoInput
    ld d, SNAKE_DIRECTION_SOUTH
    ret
.NoInput
    ld hl, SNAKE_DIRECTION
    ld d, [hl]
    ret

EXPORT SNAKE_DIRECTION_NORTH
EXPORT SNAKE_DIRECTION_EAST
EXPORT SNAKE_DIRECTION_SOUTH
EXPORT SNAKE_DIRECTION_WEST

EXPORT InitSnakeData
EXPORT PushHead
EXPORT PopTail
EXPORT MoveSnake
EXPORT GetInputDirection