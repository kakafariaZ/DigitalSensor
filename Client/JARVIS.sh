#!/usr/bin/env bash

# Uncomment this line for verbose output.
# set -x

CC=gcc                         # Change this to the available compiler.
CFLAGS="-Wall -Werror -Wextra" # Change this to the desired/needed compilation flags.
SOURCE=Main.c                  # Change this to the proper source file.
OUTPUT=Main                    # Change this to the desired output file.

function help_message() {
  echo "Usage.: $0 <ACTION>"
  echo ""
  echo "  Avaliable actions:"
  echo "    -b, --build:     Compiles the code."
  echo "    -r, --run:       Runs the code."
  echo "    -c, --clean:     Removes the compilation resuls."
  exit 1
}

if [ ! $# -eq 1 ]; then
  help_message
fi

OPTION=$1

case $OPTION in
  -b | --build)
    $CC $CFLAGS $SOURCE -o $OUTPUT
    ;;
  -r | --run)
    ./$OUTPUT
    ;;
  -c | --clean)
    rm -f $OUTPUT
    ;;
  *)
    help_message
    ;;
esac
