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

var BootDevice 0
var BootPartition 0
var PartitionTable 0

procedure Main (* ciptr bootdev bootpartition partitiontable -- *)
	PartitionTable!

	BootPartition!

	(* remember the boot device *)
	BootDevice!

	(* initialize the client interface *)
	CIPtr!

	"\nvnix - ball rolling\n" KPrintf

	InterruptsInit
	PMMInit
	KHeapInit
	DevInit
	TaskInit



	ReturnToFirmware
end