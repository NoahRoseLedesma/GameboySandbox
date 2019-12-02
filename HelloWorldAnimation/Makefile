all: hello-world.gb

.PHONY: run
run:
	../SameBoy/sameboy hello-world.gb

hello-world.gb: main.o DMA.o memcpy.o font.chr
	rgblink -o hello-world.gb DMA.o memcpy.o main.o 
	rgbfix -v -p 0 hello-world.gb

main.o: main.asm
	rgbasm -o main.o main.asm

DMA.o: DMA.asm
	rgbasm -o DMA.o DMA.asm

memcpy.o: ../MemCpy/
	make -C ../MemCpy/
	cp ../MemCpy/memcpy.o .

.PHONY: run
clean:
	rm *.o
	rm *.gb
