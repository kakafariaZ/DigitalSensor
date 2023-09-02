CC = gcc
CFLAGS = -Wall -Werror -Wextra
SRC_DIR = src
SRC_FILES = $(wildcard $(SRC_DIR)/*.c)
OUT = bin/Main

all: build

build: $(OUT)

$(OUT): $(SRC_FILES)
	$(CC) $^ -o $@ $(CFLAGS)

run: build
	./$(OUT)

clean:
	rm -f $(OUT)

.PHONY: all build run clean
