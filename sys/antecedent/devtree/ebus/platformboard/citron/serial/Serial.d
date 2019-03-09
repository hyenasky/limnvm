const SerialCmdPort 0x10
const SerialDataPort 0x11

const SerialCmdWrite 1
const SerialCmdRead 2

procedure BuildCSerial (* -- *)
	DeviceNew
		"serial" DSetName

		pointerof SerialWrite "write" DAddMethod
		pointerof SerialRead "read" DAddMethod
	DeviceExit
end

procedure SerialWrite (* c -- *)
	auto rs
	InterruptDisable rs!

	SerialDataPort DCitronOutb
	SerialCmdWrite SerialCmdPort DCitronCommand

	rs@ InterruptRestore
end

procedure SerialRead (* -- c *)
	auto rs
	InterruptDisable rs!

	auto c
	SerialCmdRead SerialCmdPort DCitronCommand
	SerialDataPort DCitronInb c!

	rs@ InterruptRestore

	if (c@ 0xFFFF ==)
		ERR return
	end

	c@
end