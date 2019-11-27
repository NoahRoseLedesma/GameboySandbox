all: print.o

print.o: print.asm
	rgbasm -o print.o print.asm

.PHONY: clean
clean:
	rm print.o
