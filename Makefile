ASM=./asm

# modify this line to whatever love executable you have
EMU=./love.app/Contents/MacOS/love ./vm

ROM=./sys/rom/main.s
ROMBIN=./bin/boot.bin
ROMBUILD=./sys/rom/build

CLIENT=./sys/client/test.s
CLIENTBIN=./bin/client.bin

all:
	make rom run

rom:
	printf '%s' `expr \`cat $(ROMBUILD)\` + 1` > $(ROMBUILD)
	$(ASM) $(ROM) $(ROMBIN)

run:
	$(EMU) -rom $(ROMBIN) -sdisk -sdblock 1 $(CLIENTBIN)

client:
	$(ASM) $(CLIENT) $(CLIENTBIN)
