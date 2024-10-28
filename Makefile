

all: main.prg

forth.o: src/forth.s
	ca65 src/forth.s -o forth.o

main.o: src/main.asm
	ca65 src/main.asm -o main.o

main.prg: main.o forth.o
	ld65 main.o forth.o -C config.cfg -o main.prg

.PHONY: all
