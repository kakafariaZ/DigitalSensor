CC=gcc
CFLAGS=-Wall -Werror -Wextra
SOURCE=Main.c
OUT=Main

all: build

build: ${SOURCE}
	${CC} ${SOURCE} -o ${OUT} ${CFLAGS}

run:
	./${OUT}

clean:
	rm -f ${OUT}

.PHONY: all build run clean
