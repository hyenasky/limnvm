#include "devtree/ebus/platformboard/citron/amanatsu/keyboard/AKeyboard.d"
#include "devtree/ebus/platformboard/citron/amanatsu/mouse/AMouse.d"

procedure BuildAmanatsu (* -- *)
	DeviceNew
		"amanatsu" DSetName

		AKeyboardInit
		AKeyboardPoll
		
		AMouseInit
		AMousePoll
	DeviceExit
end

(* start assigning interrupts at 0x80 *)
var AmaLastInterrupt 0x80

const AmaPortDev 0x30
const AmaPortMID 0x31
const AmaPortCMD 0x32
const AmaPortA 0x33
const AmaPortB 0x34

buffer AmaInterruptMap 256

(* disabling and restoring interrupts is up to the user of these functions *)

procedure AmanatsuPoll (* num -- mid *)
	AmanatsuSelectDev AmanatsuReadMID
end

procedure AmanatsuSelectDev (* num -- *)
	AmaPortDev DCitronOutb
end

procedure AmanatsuReadMID (* -- mid *)
	AmaPortMID DCitronInl
end

procedure AmanatsuCommand (* cmd -- *)
	AmaPortCMD DCitronOutl

	while (AmaPortCMD DCitronInl 0 ~=) end
end

procedure AmanatsuCommandAsync (* cmd -- *)
	AmaPortCMD DCitronOutl
end

procedure AmanatsuWriteA (* long -- *)
	AmaPortA DCitronOutl
end

procedure AmanatsuWriteB (* long -- *)
	AmaPortB DCitronOutl
end

procedure AmanatsuReadA (* -- long *)
	AmaPortA DCitronInl
end

procedure AmanatsuReadB (* -- long *)
	AmaPortB DCitronInl
end

procedure AmanatsuDevFromInt (* int -- dev *)
	AmaInterruptMap + gb
end

procedure AmanatsuSetInterrupt (* handler dev -- *)
	auto dev
	dev!

	auto handler
	handler!

	handler@ AmaLastInterrupt@ PBInterruptRegister
	AmaLastInterrupt@ dev@ 1 AmanatsuSpecialCMD

	dev@ AmaLastInterrupt@ AmaInterruptMap + sb

	AmaLastInterrupt@ 1 + AmaLastInterrupt!
end

procedure AmanatsuSpecialCMD (* a b cmd -- *)
	auto cmd
	cmd!

	auto b
	b!

	auto a
	a!

	0 AmanatsuSelectDev
	a@ AmanatsuWriteA
	b@ AmanatsuWriteB

	cmd@ AmanatsuCommand
end




