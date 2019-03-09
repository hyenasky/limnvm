(* antecedent driver for Kinnow2 framebuffer *)

var KinnowSlotSpace 0
var KinnowSlot 0

var KinnowFBStart 0

const KinnowCmdPorts 0x4000
const KinnowSlotFB 0x100000

const KinnowSlotMID 0x4B494E57

const KinnowGPUCmdPort 0
const KinnowGPUPortA 4
const KinnowGPUPortB 8
const KinnowGPUPortC 12

const KinnowGPUInfo 0x1
const KinnowGPURectangle 0x2
const KinnowGPUVsync 0x3
const KinnowGPUScroll 0x4
const KinnowGPUWindow 0x6

var KinnowWidth 0
var KinnowHeight 0

var KinnowVsyncList 0

var KinnowNeedsInit 1

procedure KinnowCommand (* cmd -- *)
	auto pbase
	KinnowSlotSpace@ KinnowCmdPorts + pbase!

	auto cmd
	cmd!

	cmd@ pbase@ sb

	while (pbase@ gb 0 ~=) end
end

procedure KinnowPortA (* -- v *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortA + @
end

procedure KinnowPortB (* -- v *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortB + @
end

procedure KinnowPortC (* -- v *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortC + @
end

procedure KinnowOutPortA (* v -- *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortA + !
end

procedure KinnowOutPortB (* v -- *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortB + !
end

procedure KinnowOutPortC (* v -- *)
	KinnowSlotSpace@ KinnowCmdPorts + KinnowGPUPortC + !
end

procedure KinnowInfo (* -- w h *)
	auto rs
	InterruptDisable rs!

	KinnowGPUInfo KinnowCommand
	
	KinnowPortB
	KinnowPortA

	rs@ InterruptRestore
end

procedure BuildKinnow (* -- *)
	auto kslot
	KinnowSlotMID EBusFindFirstBoard kslot!

	if (kslot@ ERR ==)
		return
	end

	kslot@ EBusSlotSpace * EBusSlotsStart + KinnowSlotSpace!

	kslot@ KinnowSlot!

	auto w
	auto h
	KinnowInfo w! h!

	if (w@ 0 ==)
		return
	end

	KinnowSlotSpace@ KinnowSlotFB + KinnowFBStart!

	DeviceNew
		"kinnow2" DSetName

		KinnowFBStart@ "framebuffer" DAddProperty
		w@ "width" DAddProperty
		h@ "height" DAddProperty

		pointerof KinnowRectangle "rectangle" DAddMethod
		pointerof KinnowScroll "scroll" DAddMethod
		pointerof KinnowWindow "window" DAddMethod
		pointerof KinnowVsyncAdd "vsyncAdd" DAddMethod
		pointerof KinnowInit "init" DAddMethod
	DeviceExit

	w@ KinnowWidth!
	h@ KinnowHeight!

	ListCreate KinnowVsyncList!

	KinnowVsyncOn
end

procedure KinnowInit (* -- *)
	if (KinnowNeedsInit@)
		"screen-bg" NVRAMGetVarNum KinnowWidth@ KinnowHeight@ 0 0 KinnowRectangle

		0 KinnowNeedsInit!
	end
end

procedure KinnowWindow (* x y w h -- *)
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

	x@ KinnowOutPortA
	y@ KinnowOutPortB
	wh@ KinnowOutPortC

	KinnowGPUWindow KinnowCommand

	rs@ InterruptRestore
end

asm "

KinnowVsyncIntASM:
	pusha

	call KinnowVsyncInt

	popa
	iret

"

procedure KinnowVsyncAdd (* handler -- *)
	KinnowVsyncList@ ListInsert
end

procedure KinnowVsyncInt (* -- *)
	auto n
	KinnowVsyncList@ ListHead n!

	while (n@ 0 ~=)
		n@ ListNodeValue Call

		n@ ListNodeNext n!
	end
end

procedure KinnowVsyncOn (* -- *)
	auto rs
	InterruptDisable rs!

	pointerof KinnowVsyncIntASM KinnowSlot@ EBusSlotInterruptRegister

	KinnowGPUVsync KinnowCommand

	rs@ InterruptRestore
end

procedure KinnowScroll (* color rows -- *)
	auto rs
	InterruptDisable rs!

	auto rows
	rows!

	auto color
	color!

	rows@ KinnowOutPortA
	color@ KinnowOutPortB

	KinnowGPUScroll KinnowCommand

	rs@ InterruptRestore
end

procedure KinnowRectangle (* color w h x y -- *)
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

	cwh@ KinnowOutPortA
	cxy@ KinnowOutPortB
	color@ KinnowOutPortC

	KinnowGPURectangle KinnowCommand

	rs@ InterruptRestore
end