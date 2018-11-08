# limnvm

Fantasy computer, inspired by late 80s Unix workstations.

Emulates at a low level a CPU, chipset, 8-bit framebuffer, a virtual disk bus, and a keyboard.

The long-term goal is to create a really neat (but useless) emulated desktop computer.

The CPU is based around the second iteration of my toy architecture.

Ships with a pre-built boot ROM binary, a disktools image (see *Using the toolchain*), and a vnix image.

![Running the Antecedent boot firmware](https://i.imgur.com/LmF2ZaE.png)

## Running

Modify the EMU variable in the makefile to whatever your Love2D 11.0 executable is.

Then, type `make run` in the project directory.

## Using the toolchain

Modify the `./lua` shell script to point to your lua5.1 executable.

If it's just `lua5.1` then you're good, that's the default.

Check the wiki (WIP) for more information on the tools below.

### Assembler

Usage is `./asm [source file] [output file]`.

Currently the only thing you'd be able to make is a boot ROM which is a lot of effort, or a bootloader, so this isn't much to work with in terms of a toy.

If you want to build the boot ROM yourself, run `make rom`.

Improvements are being made :)

### Dragonfruit Compiler

Usage is `./dragonc [source file] [output file]`.

If you came here expecting a language that will let you debug it without ripping your hair and entrails out, you'll be very, very sad.

### VnixFAT Utility

Usage is `./vfu [disk image] [command] ...`.

Lets you format disk images as VnixFAT, and manipulate existing VnixFAT images.

### Disktools

Lets you partition disks under the Vnix scheme. Vnix won't boot off a disk whose block zero doesn't conform to this.

This tool is unique in that it's bootable and runs in the vm itself as an Antecedent client program.

Under the default configuration, it exists on block device 0,0. Type `b0 0` or just `b` at the Antecedent prompt to boot it.

## Things left to do

### Short term

1. Improving the control GUI

### Medium term

1. Getting the kernel to a functional, unix-like state
2. Creating a shell and command line utilities

### Long term

1. Build a windowed GUI