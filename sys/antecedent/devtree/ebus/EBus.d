const EBusSlotsStart 0xC0000000
const EBusSlots 7
const EBusSlotSpace 0x8000000
const EBusBoardMagic 0x0C007CA1

#include "devtree/ebus/platformboard/PBoard.d"
#include "devtree/ebus/kinnow2/Kinnow2.d"

procedure BuildEBus (* -- *)
	DeviceNew
		"ebus" DSetName

		BuildPBoard
		BuildKinnow
	DeviceExit
end

(* find first board of id *)
procedure EBusFindFirstBoard (* id -- slot *)
	auto id
	id!

	auto i
	0 i!

	while (i@ EBusSlots <)
		auto bp
		i@ EBusSlotSpace * EBusSlotsStart + bp!

		if (bp@@ EBusBoardMagic ==)
			if (bp@ 4 + @ id@ ==)
				i@ return
			end
		end

		1 i@ + i!
	end

	ERR return
end

procedure EBusSlotInterruptRegister (* handler slot -- *)
	0x98 + InterruptRegister
end