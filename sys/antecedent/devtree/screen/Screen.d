(* antecedent screen driver for Kinnow framebuffer *)

const ScreenFBStart 0xF4000000

const ScreenGPUCmdPort 0x12
const ScreenGPUPortA 0x13
const ScreenGPUPortB 0x14
const ScreenGPUPortC 0x15

const ScreenGPUInfo 0x1
const ScreenGPURectangle 0x2
const ScreenGPUVsync 0x3
const ScreenGPUScroll 0x4
const ScreenGPUWindow 0x6

var ScreenVsyncList 0

procedure ScreenInfo (* -- w h *)
	ScreenGPUInfo ScreenGPUCmdPort DCitronCommand
	
	ScreenGPUPortB DCitronIni
	ScreenGPUPortA DCitronIni 
end

procedure BuildScreen (* -- *)
	auto w
	auto h
	ScreenInfo w! h!

	if (w@ 0 ==)
		return
	end

	DeviceNew
		"screen" DSetName

		ScreenFBStart "framebuffer" DAddProperty
		w@ "width" DAddProperty
		h@ "height" DAddProperty

		pointerof ScreenRectangle "rectangle" DAddMethod
		pointerof ScreenScroll "scroll" DAddMethod
		pointerof ScreenWindow "window" DAddMethod
		pointerof ScreenVsyncAdd "vsyncAdd" DAddMethod
	DeviceExit

	if ("screen-bg" NVRAMGetVar 0 ==)
		0x56 "screen-bg" NVRAMSetVarNum
	end
	if ("screen-fg" NVRAMGetVar 0 ==)
		0x00 "screen-fg" NVRAMSetVarNum
	end

	ListCreate ScreenVsyncList!

	ScreenVsyncOn
end

procedure ScreenWindow (* x y w h -- *)
	auto h
	h!

	auto w
	w!

	auto y
	y!

	auto x
	x!

	auto wh
	w@ 16 << h@ | wh!

	auto rs
	InterruptDisable rs!

	x@ ScreenGPUPortA DCitronOutl
	y@ ScreenGPUPortB DCitronOutl
	wh@ ScreenGPUPortC DCitronOutl

	ScreenGPUWindow ScreenGPUCmdPort DCitronCommand

	rs@ InterruptRestore
end

asm "

ScreenVsyncIntASM:
	pusha

	call ScreenVsyncInt

	popa
	iret

"

procedure ScreenVsyncAdd (* handler -- *)
	ScreenVsyncList@ ListInsert
end

procedure ScreenVsyncInt (* -- *)
	auto rs
	InterruptDisable rs!

	auto n
	ScreenVsyncList@ ListHead n!

	while (n@ 0 ~=)
		n@ ListNodeValue Call

		n@ ListNodeNext n!
	end

	rs@ InterruptRestore
end

procedure ScreenVsyncOn (* -- *)
	auto rs
	InterruptDisable rs!

	pointerof ScreenVsyncIntASM 0x35 InterruptRegister

	ScreenGPUVsync ScreenGPUCmdPort DCitronCommand

	rs@ InterruptRestore
end

procedure ScreenScroll (* color rows -- *)
	auto rs
	InterruptDisable rs!

	auto rows
	rows!

	auto color
	color!

	rows@ ScreenGPUPortA DCitronOutl
	color@ ScreenGPUPortB DCitronOutl

	ScreenGPUScroll ScreenGPUCmdPort DCitronCommand

	rs@ InterruptRestore
end

procedure ScreenRectangle (* color w h x y -- *)
	auto rs
	InterruptDisable rs!

	auto y
	y!
	auto x
	x!
	auto h
	h!
	auto w
	w!
	auto color
	color!

	auto cxy
	x@ 16 << y@ | cxy!

	auto cwh
	w@ 16 << h@ | cwh!

	cwh@ ScreenGPUPortA DCitronOutl
	cxy@ ScreenGPUPortB DCitronOutl
	color@ ScreenGPUPortC DCitronOutl

	ScreenGPURectangle ScreenGPUCmdPort DCitronCommand

	rs@ InterruptRestore
end