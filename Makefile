ASM=./asm
DRAGONC=./dragonc

# modify this line to whatever love executable you have
EMU=./love.app/Contents/MacOS/love ./vm

ROM=./sys/antecedent/Antecedent.d
ROMBIN=./bin/boot.bin
LEGACYROMBIN=./bin/legacyrom.bin
ROMBUILD=./sys/antecedent/build

NVRAM=./bin/nvram

VHD=./bin/hd0.img
VNFS=./bin/vnixfs.img
DISKTOOLS=./bin/disktools.img

all:
	make rom run
#	make bkern
#	$(EMU) -outs -rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -nvram,autorun "b0 0 -v"

legacy:
	$(EMU) -rom $(LEGACYROMBIN) -ahd $(DISKTOOLS) -ahd $(VHD) -outs

rom:
	printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	$(DRAGONC) $(ROM) $(ROMBIN) -noprim

run:
	$(EMU) -rom $(ROMBIN) -ahd $(DISKTOOLS) -ahd $(VHD) -ahd ./test.img -outs -nvram $(NVRAM)

bkern:
	make kernel vnfs

kernel:
	$(DRAGONC) ./sys/vnix/Kernel/Kernel.d ./tmp/vnix

	./vfu ./bin/vnixfs.img w /vnix ./tmp/vnix

vnfs:
	dd if=$(VNFS) of=$(VHD) conv=notrunc seek=2 bs=4096 count=512

vboot:
	$(DRAGONC) ./sys/vboot/BootSector.d ./tmp/VBootSector.o

	$(DRAGONC) ./sys/vboot/Main.d ./tmp/vboot.o

	dd if=./tmp/VBootSector.o of=$(VHD) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VNFS) bs=4096 conv=notrunc seek=1

disktools:
	$(DRAGONC) ./sys/disktools/BootSector.d ./tmp/DTBootSector.o

	$(DRAGONC) ./sys/disktools/Main.d ./tmp/disktools.o

	dd if=./tmp/DTBootSector.o of=$(DISKTOOLS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/disktools.o of=$(DISKTOOLS) bs=4096 conv=notrunc seek=2

cleanup:
	rm ./tmp/*