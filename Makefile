ASM=./asm
DRAGONC=./dragonc

# modify this line to whatever love executable you have
EMU=./love.app/Contents/MacOS/love ./vm

ROM=./sys/ROM/Main.s
ROMBIN=./bin/boot.bin
ROMBUILD=./sys/ROM/build

VHD=./bin/hd0.img
DISKTOOLS=./bin/disktools.img

all:
	make rom run

rom:
	printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	$(ASM) $(ROM) $(ROMBIN)

run:
	$(EMU) -rom $(ROMBIN)  -ahd $(DISKTOOLS) -ahd $(VHD)

vboot:
	$(DRAGONC) ./sys/vboot/BootSector.d ./tmp/VBootSector.s
	$(ASM) ./tmp/VBootSector.s ./tmp/VBootSector.o

	$(DRAGONC) ./sys/vboot/Main.d ./tmp/vboot.s
	$(ASM) ./tmp/vboot.s ./tmp/vboot.o

	dd if=./tmp/VBootSector.o of=$(VHD) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VHD) bs=4096 conv=notrunc seek=2

disktools:
	$(DRAGONC) ./sys/disktools/BootSector.d ./tmp/DTBootSector.s
	$(ASM) ./tmp/DTBootSector.s ./tmp/DTBootSector.o

	$(DRAGONC) ./sys/disktools/Main.d ./tmp/disktools.s
	$(ASM) ./tmp/disktools.s ./tmp/disktools.o

	dd if=./tmp/DTBootSector.o of=$(DISKTOOLS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/disktools.o of=$(DISKTOOLS) bs=4096 conv=notrunc seek=2

cleanup:
	rm ./tmp/*