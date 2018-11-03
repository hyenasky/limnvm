# limnvm

Fantasy computer, inspired by late 80s Unix workstations.

Emulates at a low level a CPU, chipset, 8-bit framebuffer, and keyboard.

The long-term goal is to create a really neat (but useless) emulated desktop computer.

The CPU is based around the second iteration of my toy architecture.

Ships with a pre-built boot ROM binary.

![Running the Antecedent boot firmware](https://i.imgur.com/JHrhHT0.png)

## Running

Modify the EMU variable in the makefile to whatever your Love2D 11.0 executable is.

Then, type `make run` in the project directory.

## Using the toolchain

### Assembler

Modify the `./asm` shell script to use your lua5.1 executable.

If it's just `lua5.1` then you're good, that's the default.

Usage is `./asm [source file] [output file]`.

Currently the only thing you'd be able to make is a boot ROM which is a lot of effort, or a (very) simple bootloader, so this isn't much to work with in terms of a toy.

If you want to build the boot ROM yourself, run `make rom`.

Improvements are being made :)

## Things left to do

### Short term

1. FAT32 bootloader
2. Improving the control GUI
3. Beginning a kernel

### Medium term

1. Getting the kernel to a functional, unix-like state
2. Creating a shell and command line utilities

### Long term

1. Build a windowed GUI