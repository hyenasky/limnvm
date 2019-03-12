ASM=./asm.sh
DRAGONC=./dragonc.sh
VFUTIL=./vfu.sh

EMU=./love.sh ./vm

ROM=./sys/antecedent/Antecedent.d
ROMBIN=./bin/boot.bin
ROMBUILD=./sys/antecedent/build

NVRAM=./bin/nvram

VHD=./bin/hd0.img
VNFS=./bin/kabosufs.img

all:
	# make bkern
	make run

rom:
	printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	$(DRAGONC) $(ROM) $(ROMBIN) -noprim

run:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" \
		-rom $(ROMBIN) -ahd $(VHD) -serial,stdio -nvram $(NVRAM)

bkern:
	make kernel vnfs

kernel:
	$(DRAGONC) ./sys/kabosu/vnix/Kernel.d ./tmp/vnix

	$(VFUTIL) $(VNFS) w /vnix ./tmp/vnix

vnfs:
	dd if=$(VNFS) of=$(VHD) conv=notrunc seek=2 bs=4096 count=512

vboot:
	$(ASM) ./sys/vboot2/BootSector.s ./tmp/VBootSector.o

	$(DRAGONC) ./sys/vboot2/Main.d ./tmp/vboot.o -noprim

	dd if=./tmp/VBootSector.o of=$(VNFS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VNFS) bs=4096 conv=notrunc seek=2

cleanup:
	rm ./tmp/*