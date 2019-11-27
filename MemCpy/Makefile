all: memcpy.o

memcpy.o: memcpy.asm
	rgbasm -o memcpy.o memcpy.asm

.PHONY: clean
clean:
	rm memcpy.o
