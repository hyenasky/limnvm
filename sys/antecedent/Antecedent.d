#include "llfw/llfw.d" (* this MUST be at the beginning!! *)
#include "Const.d"
#include "Runtime.d"
#include "prim.s"
#include "Heap.d"
#include "lib/List.d"
#include "lib/Tree.d"
#include "Console.d"
#include "Interrupts.d"
#include "DeviceTree.d"
#include "NVRAM.d"
#include "Boot.d"
#include "Main.d"
#include "Monitor/Monitor.d"
#include "Menu/Menu.d"

procedure AntecedentEntry (* -- *)
	if (NVRAMCheck ~~)
		NVRAMFormat
	end

	HeapInit
	InterruptsInit
	DeviceInit
	ConsoleInit

	Main
end

asm "

AntecedentEnd:

"