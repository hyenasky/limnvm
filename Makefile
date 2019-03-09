LUA=lua5.1
LOVE=love
ASM=$(LUA) ./sdk/asm/asm.lua
DRAGONC=$(LUA) sdk/dragonfruit/dragonc.lua
VFUTIL=$(LUA) vfutil/vfutil.lua

EMU=$(LOVE) ./vm

ROM=./sys/antecedent/Antecedent.d
ROMBIN=./bin/boot.bin
ROMBUILD=./sys/antecedent/build

NVRAM=./bin/nvram

VHD=./bin/hd0.img
VNFS=./bin/kabosufs.img

KERNEL=./tmp/vnix

.PHONY:all run cleanup

all:run

$(ROMBIN):$(ROM)
	@echo Incrementing build count...
	@printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	@$(DRAGONC) $(ROM) $(ROM).out.s -noprim
	@$(ASM) $(ROM).out.s $(ROMBIN)
	@$(RM) $(ROM).out.s
rom:$(ROMBIN)

run:
	@$(EMU) -verbose \
		-ebus,slot 7 "platformboard" \
		-ebus,board "kinnow2" \
		-rom $(ROMBIN) -ahd $(VHD) -outs -nvram $(NVRAM)

bkern:$(KERNEL) vnfs

$(KERNEL):./sys/kabosu/vnix/kernel.d
	@$(DRAGONC) ./sys/kabosu/vnix/kernel.d ./sys/kabosu/vnix/kernel.d.s
	@mkdir $(dir $@) -p
	@$(ASM) ./sys/kabosu/vnix/kernel.d.s $@
	@$(RM) ./sys/kabosu/vnix/kernel.d.s
	@$(VFUTIL) $(VNFS) w /vnix $@
kernel:$(KERNEL)

$(VHD):vboot
	dd if=$(VNFS) of=$(VHD) conv=notrunc seek=2 bs=4096 count=512
vnfs:$(VHD)

$(VNFS):sys/vboot2/BootSector.s sys/vboot2/Main.d
	@$(ASM) ./sys/vboot2/BootSector.s ./tmp/VBootSector.o
	@$(DRAGONC) ./sys/vboot2/Main.d ./sys/vboot2/Main.d.s -noprim
	@$(ASM) ./sys/vboot2/Main.d.s ./tmp/vboot.o
	@$(RM) ./sys/vboot2/Main.d.s
	dd if=./tmp/VBootSector.o of=$(VNFS) bs=4096 conv=notrunc seek=1
	dd if=./tmp/vboot.o of=$(VNFS) bs=4096 conv=notrunc seek=2
vboot:$(VNFS)

cleanup:
	$(RM) ./tmp/*
