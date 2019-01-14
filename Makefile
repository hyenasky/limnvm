ASM=./asm
DRAGONC=./dragonc

EMU=./love ./vm

ROM=./sys/antecedent/Antecedent.d
ROMBIN=./bin/boot.bin
ROMBUILD=./sys/antecedent/build

NVRAM=./bin/nvram

VHD=./bin/hd0.img
VNFS=./bin/vnixfs.img

all:
	make rom run
#	make bkern
#	$(EMU) -outs -rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -nvram,autorun "b0 0 -v"

rom:
	printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	$(DRAGONC) $(ROM) $(ROMBIN) -noprim

run:
	$(EMU) -rom $(ROMBIN) -ahd $(VHD) -outs -nvram $(NVRAM)

bkern:
	make kernel vnfs

kernel:
	$(DRAGONC) ./sys/vnix/Kernel/Kernel.d ./tmp/vnix

	./vfu ./bin/vnixfs.img w /vnix ./tmp/vnix

vnfs:
	dd if=$(VNFS) of=$(VHD) conv=notrunc seek=2 bs=4096 count=512

vboot:
	$(ASM) ./sys/vboot2/BootSector.s ./tmp/VBootSector.o

	$(DRAGONC) ./sys/vboot2/Main.d ./tmp/vboot.o -noprim

	dd if=./tmp/VBootSector.o of=$(VNFS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VNFS) bs=4096 conv=notrunc seek=2

cleanup:
	rm ./tmp/*