SRCS = main.asm tiles.asm util.asm snake.asm
OBJS = $(SRCS:.asm=.o)
LIB_OBJS = libs/MemCpy/memcpy.o libs/print/print.o

ASSETS = AsciiFont.chr SnakeTiles.chr
INCLUDES = TileGuide.inc hardware.inc
TARGET = snake.gb

all: $(TARGET)

.PHONY: run
run:
	../SameBoy/sameboy snake.gb

$(TARGET): $(OBJS) $(INCLUDES)
	rgblink -o $(TARGET) $(OBJS) $(LIB_OBJS)
	rgbfix -v -p 0 $(TARGET)

$(OBJS): %o : %asm
	rgbasm -o $@ $<

.PHONY: clean
clean:
	rm *.o
	rm *.gb
