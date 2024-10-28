

all: main.prg

forth.o: src/forth.s
	ca65 src/forth.s -o forth.o

io.o: src/io.s
	ca65 src/io.s -o io.o

main.o: src/main.s
	ca65 src/main.s -o main.o

main.prg: main.o forth.o io.o
	ld65 main.o io.o forth.o -C config.cfg -o main.prg

.PHONY: all
