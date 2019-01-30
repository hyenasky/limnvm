const ClockPortCmd 0x20
const ClockPortA 0x21

const ClockDefaultInterval 20 (* every 20 ms *)

var ClockUptimeMS 0
var ClockInterval 0

procedure BuildClock (* -- *)
	DeviceNew
		"clock" DSetName

		pointerof ClockSetInterval "setInterval" DAddMethod
		pointerof ClockUptime "uptime" DAddMethod
		pointerof ClockWait "wait" DAddMethod
	DeviceExit

	ClockDefaultInterval ClockSetInterval (* set clock ticking *)

	pointerof ClockIntASM 0x36 InterruptRegister
end

asm "

ClockIntASM:
	pusha

	call ClockInt

	popa
	iret

"

procedure ClockInt (* -- *)
	ClockInterval@ ClockUptimeMS@ + ClockUptimeMS!
end

procedure ClockWait (* ms -- *)
	auto ms
	ms!

	auto wu
	ClockUptimeMS@ ms@ + wu!

	while (ClockUptimeMS@ wu@ <) end
end

procedure ClockUptime (* -- ms *)
	ClockUptimeMS@
end

procedure ClockSetInterval (* ms -- *)
	auto ms
	ms!

	ms@ ClockInterval!

	auto rs
	InterruptDisable rs!

	ms@ ClockPortA DCitronOutl
	1 ClockPortCmd DCitronCommand

	rs@ InterruptRestore
end