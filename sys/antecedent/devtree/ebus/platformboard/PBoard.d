#include "devtree/ebus/platformboard/citron/Citron.d"

var PBInterruptsVT 0

const PBBase 0xF8000000
const PBInfo 0xF8000800
const PBInfoIRQ 0xF8000FFC

procedure BuildPBoard (* -- *)
	1024 Calloc PBInterruptsVT!

	pointerof PBInterruptASM 0x7 EBusSlotInterruptRegister

	DeviceNew
		"platformboard" DSetName

		PBInfo@ "version" DAddProperty

		BuildCitron
	DeviceExit
end

procedure PBInterrupt (* -- *)
	auto handler
	PBInfoIRQ@ 4 * PBInterruptsVT@ + @ handler!

	if (handler@ 0 ~=)
		handler@ Call
	end
end

asm "

PBInterruptASM:
	pusha

	call PBInterrupt

	popa
	iret

"

procedure PBInterruptRegister (* handler num -- *)
	4 * PBInterruptsVT@ + !
end