#include "Const.d"
#include "Start.d"
#include "Runtime.d"
#include "lib/List.d"
#include "lib/Tree.d"
#include "Antecedent/ACI.d"
#include "Antecedent/DeviceTree.d"
#include "KPrint.d"
#include "PMM.d"
#include "KHeap.d"
#include "Interrupts.d"
#include "Devices.d"
#include "Task.d"
#include "Args.d"

#include "Extra/Bootsplash.d"

var BootDevice 0

procedure Main (* ciptr bootdev args -- *)
	auto args
	args!

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"\nvnix - ball rolling\n" KPrintf

	PMMInit
	KHeapInit
	InterruptsInit
	args@ ArgsInit
	KConsoleInit
	DevInit

	APIDevTree DeviceTreeInit

	GraphicsInit
	Bootsplash

	TaskInit

	ReturnToFirmware
end