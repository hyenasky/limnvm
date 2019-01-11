#include "Const.d"
#include "Start.d"
#include "Runtime.d"
#include "ACI.d"
#include "KPrint.d"
#include "PMM.d"
#include "KHeap.d"
#include "Interrupts.d"
#include "Devices.d"
#include "Task.d"
#include "Args.d"

#include "Extra/Bootsplash.d"

var BootDevice 0
var BootPartition 0
var PartitionTable 0

procedure Main (* ciptr bootdev bootpartition partitiontable args -- *)
	auto args
	args!

	PartitionTable!

	BootPartition!

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

	GraphicsInit
	Bootsplash

	TaskInit

	ReturnToFirmware
end