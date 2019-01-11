const BlitterCmdPort 0x40
const BlitterPortA 0x41
const BlitterPortB 0x42
const BlitterPortC 0x43
const BlitterPortD 0x44

const BlitterIntNum 0x40

var BlitterSpinning 0

asm "

BlitterInterrupt:
	sii.l BlitterSpinning, 0
	iret

"

procedure BlitterInit (* -- *)
	pointerof BlitterInterrupt BlitterIntNum InterruptRegister
end

procedure BlitterOperation (* modulo width height dest from cmd -- OK? *)
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

	if (BlitterSpinning@) ERR return end

	auto ic
	InterruptDisable ic!

	1 BlitterSpinning!

	from@ BlitterPortA DCitronOutl
	dest@ BlitterPortB DCitronOutl
	modulo@ BlitterPortD DCitronOutl
	width@ height@ 16 << | BlitterPortC DCitronOutl

	cmd@ BlitterCmdPort DCitronCommand

	ic@ InterruptRestore

	while (BlitterSpinning@) end

	OK
end