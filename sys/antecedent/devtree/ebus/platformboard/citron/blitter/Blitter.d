procedure BuildBlitter (* -- *)
	DeviceNew
		"blitter" DSetName

		pointerof BlitterOperation "blit" DAddMethod 
	DeviceExit
end

const BlitterCmdPort 0x40
const BlitterPortA 0x41
const BlitterPortB 0x42
const BlitterPortC 0x43
const BlitterPortD 0x44

procedure BlitterOperation (* modulo width height dest from cmd -- *)
	auto cmd
	cmd!
	auto from
	from!
	auto dest
	dest!
	auto height
	height!
	auto width
	width!
	auto modulo
	modulo!

	auto ic
	InterruptDisable ic!

	from@ BlitterPortA DCitronOutl
	dest@ BlitterPortB DCitronOutl
	modulo@ BlitterPortD DCitronOutl
	width@ height@ 16 << | BlitterPortC DCitronOutl

	cmd@ BlitterCmdPort DCitronCommand

	ic@ InterruptRestore
end