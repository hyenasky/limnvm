#include "devtree/ebus/platformboard/citron/ahdb/AHDB.d"
#include "devtree/ebus/platformboard/citron/clock/Clock.d"
#include "devtree/ebus/platformboard/citron/serial/Serial.d"
#include "devtree/ebus/platformboard/citron/amanatsu/Amanatsu.d"

(* citron bus functions *)
(* disabling and restoring interrupts is up to the user of these functions *)

const DCitronBase 0xF8000000

procedure BuildCitron (* -- *)
	DeviceNew
		"citron" DSetName

		BuildAHDB
		BuildCClock
		BuildCSerial
		BuildAmanatsu
	DeviceExit
end

procedure DCitronInb (* port -- byte *)
	4 * DCitronBase + gb
end

procedure DCitronIni (* port -- int *)
	4 * DCitronBase + gi
end

procedure DCitronInl (* port -- long *)
	4 * DCitronBase + @
end

procedure DCitronOutb (* byte port -- *)
	4 * DCitronBase + sb
end

procedure DCitronOuti (* int port -- *)
	4 * DCitronBase + si
end

procedure DCitronOutl (* long port -- *)
	4 * DCitronBase + !
end

procedure DCitronCommand (* command port -- *)
	auto pbase
	4 * DCitronBase + pbase!

	auto cmd
	cmd!

	cmd@ pbase@ sb

	while (pbase@ gb 0 ~=) end
end

(* doesn't wait for the device to report the operation as completed before returning *)
procedure DCitronCommandASync (* command port -- *)
	auto pbase
	4 * DCitronBase + pbase!

	auto cmd
	cmd!

	cmd@ pbase@ sb
end