all: hello-world.gb

.PHONY: run
run:
	../SameBoy/sameboy hello-world.gb

hello-world.gb: main.o memcpy.o print.o font.chr
	rgblink -o hello-world.gb memcpy.o print.o main.o 
	rgbfix -v -p 0 hello-world.gb

main.o: main.asm
	rgbasm -o main.o main.asm

memcpy.o: ../MemCpy/memcpy.o
	cp ../MemCpy/memcpy.o .

print.o: ../print/print.o
	cp ../print/print.o .

example: hello-world-example.gb

hello-world-example.gb: main-example.o
	rgblink -o hello-world-example.gb main-example.o
	rgbfix -v -p 0 hello-world-example.gb

main-example.o: main-example.asm
	rgbasm -o main-example.o main-example.asm


.PHONY: run
clean:
	rm *.o
	rm *.gb
