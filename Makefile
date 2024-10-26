

all: main.prg

main.o: src/main.asm
	ca65 src/main.asm -o main.o

main.prg: main.o
	ld65 main.o -C config.cfg -o main.prg

.PHONY: all
