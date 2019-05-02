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
	$(DRAGONC) $(ROM) $(ROMBIN)

run:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" \
		-rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -ahd hdd.img -mouse -keyboard

headless:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -serial,wopen -ahd hdd.img

bigfb:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" -kinnow,display 1920 1080 \
		-rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -mouse -keyboard

smallfb:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" -kinnow,display 640 480 \
		-rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -mouse -keyboard

hpfb:
	$(EMU) \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" -kinnow,display 1280 1024 \
		-rom $(ROMBIN) -ahd $(VHD) -nvram $(NVRAM) -mouse -keyboard

bkern:
	make kernel vnfs

kernel:
	$(DRAGONC) ./sys/kabosu/vnix/Kernel.d ./tmp/vnix

	$(VFUTIL) $(VNFS) w /vnix ./tmp/vnix

vnfs:
	dd if=$(VNFS) of=$(VHD) conv=notrunc seek=2 bs=4096 count=512

vboot:
	$(ASM) ./sys/vboot2/BootSector.s ./tmp/VBootSector.o

	$(DRAGONC) ./sys/vboot2/Main.d ./tmp/vboot.o

	dd if=./tmp/VBootSector.o of=$(VNFS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VNFS) bs=4096 conv=notrunc seek=2

cleanup:
	rm ./tmp/*