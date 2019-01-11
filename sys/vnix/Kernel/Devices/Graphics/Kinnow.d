(* driver for the kinnow framebuffer *)

var KinnowFBStart 0xF4000000
var KinnowWidth 0
var KinnowHeight 0
var KinnowFBSize 0

const KinnowCmdPort 0x12
const KinnowPortA 0x13
const KinnowPortB 0x14
const KinnowPortC 0x15

const KinnowCmdInfo 0x1
const KinnowCmdRect 0x2
const KinnowCmdVSYNC 0x3
const KinnowCmdScroll 0x4

procedure KinnowInit (* -- *)
	auto ic
	InterruptDisable ic!

	KinnowCmdInfo KinnowCmdPort DCitronCommand

	KinnowPortA DCitronInl KinnowWidth!
	KinnowPortB DCitronInl KinnowHeight!

	ic@ InterruptRestore

	KinnowWidth@ KinnowHeight@ * KinnowFBSize!
end

procedure KinnowPopulate (* ctx -- OK? *)
	auto ctx
	ctx!

	if (KinnowFBSize@ 0 ==)
		ERR return
	end

	KinnowFBStart@ ctx@ GraphicsCtx_FBPointer + !
	KinnowFBSize@ ctx@ GraphicsCtx_FBSize + !
	KinnowHeight@ ctx@ GraphicsCtx_Height + !
	KinnowWidth@ ctx@ GraphicsCtx_Width + !
	8 ctx@ GraphicsCtx_BPP + !

	OK
end