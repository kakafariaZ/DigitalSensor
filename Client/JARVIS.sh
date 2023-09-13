#!/usr/bin/env bash

# Uncomment this line for verbose output.
# set -x

CC=gcc                                         # Change this to the available compiler.
# CFLAGS="-Wall -Werror -Wextra"                 # Change this to the desired/needed compilation flags.
LIBS="-lpthread"                               # Change this to the desired/needed libraries.
SRC_DIR=src                                    # Change this to proper source directory.
SRC_FILES=$(find $SRC_DIR -type f -name '*.c') # Modify as needed to catch source files.
OUTPUT=bin/Main                                # Change this to the desired output file.

function help_message() {
	echo "Usage.: $0 <ACTION>"
	echo ""
	echo "  Avaliable actions:"
	echo "    -h, --help:      Displays this message."
	echo "    -b, --build:     Compiles the code."
	echo "    -r, --run:       Runs the code."
	echo "    -c, --clean:     Removes the compilation results."

	exit "$1"
}

if [ ! $# -eq 1 ]; then
	help_message 1
fi

OPTION=$1

case $OPTION in
-b | --build)
	$CC $LIBS $CFLAGS $SRC_FILES -o $OUTPUT
	;;
-r | --run)
	./$OUTPUT
	;;
-c | --clean)
	rm -f $OUTPUT
	;;
-h | --help)
	help_message 0
	;;
*)
	help_message 1
	;;
esac
