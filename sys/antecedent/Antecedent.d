#include "llfw/llfw.d" (* this MUST be at the beginning!! *)
#include "Const.d"
#include "Runtime.d"
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

(* asm "

.bc HeapInit ;2ea6
.bc ListLength ;3ecf
.bc TreeNodes ;4ac6
.bc ConsoleSetIn ;5139
.bc InterruptsInit ;5ca9
.bc DevStackPUSH
.bc NVRAMCheck
.bc AutoBoot
.bc Main
.bc MonitorCommandsInit
.bc Monitor
.bc AntecedentEnd

" *)

procedure LateReset (* -- *)
	"\[c" Printf
	Reset
end

procedure AntecedentEntry (* -- *)
	if (NVRAMCheck ~~)
		NVRAMFormat
	end

	HeapInit
	InterruptsInit
	DeviceInit
	ConsoleInit

	FaultsRegister (* let llfw handle faults up until here *)

	Main
end

asm "

AntecedentEnd:

"