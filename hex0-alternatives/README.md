This directory contains various implementations of the `hex0` utility.

## `hex0.sh`
Implemented as a POSIX shell script, and uses `printf`. Converting hex0
source at the standard input to binary at the standard output.

Usage: `hex0.sh < input.hex0 > output.bin`

## `hex0.c`
Implemented as a C program and uses standard C libraries. Build using any C compiler
you trust.

Usage: `hex0 input.hex0 output.bin
