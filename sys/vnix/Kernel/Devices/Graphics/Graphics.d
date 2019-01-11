struct GraphicsCtx
	4 FBPointer
	4 FBSize
	4 Height
	4 Width
	4 BPP
endstruct

#include "Devices/Graphics/Kinnow.d"
#include "Devices/Graphics/Boot.d"

const GraphicsNumContexts 16

var GraphicsCtxList 0
var GraphicsCtxPtr 0

procedure GraphicsInit (* -- *)
	4 GraphicsNumContexts * KCalloc GraphicsCtxList!

	if (GraphicsCtxList@ 0 ==)
		"couldn't allocate graphics contexts: not enough heap\n" KPanic
	end

	KinnowInit
	BootGraphicsInit
end

procedure GraphicsCtxAdd (* ptr -- n *)
	auto ptr
	ptr!

	if (GraphicsCtxPtr@ GraphicsNumContexts ==)
		"couldn't add graphics context: max reached\n" KPanic
	end

	ptr@ GraphicsCtxPtr@ 4 * GraphicsCtxList@ + !

	GraphicsCtxPtr@
	GraphicsCtxPtr@ 1 + GraphicsCtxPtr!
end

procedure GraphicsBPP (* ctx -- bpp *)
	4 * GraphicsCtxList@ + @
	auto pb
	pb!
	if (pb@ 0 ==)
		ERR return
	end

	pb@ GraphicsCtx_BPP + @
end

procedure GraphicsFramebuffer (* ctx -- fbp fbs *)
	4 * GraphicsCtxList@ + @
	auto pb
	pb!
	if (pb@ 0 ==)
		ERR return
	end

	pb@ GraphicsCtx_FBPointer + @
	pb@ GraphicsCtx_FBSize + @
end

procedure GraphicsDimensions (* ctx -- w h *)
	4 * GraphicsCtxList@ + @
	auto pb
	pb!
	if (pb@ 0 ==)
		ERR ERR return
	end

	pb@ GraphicsCtx_Width + @
	pb@ GraphicsCtx_Height + @
end

procedure GraphicsFillRect (* color x y w h ctx -- OK? *)
	2 swap GraphicsBlitRect
end

procedure GraphicsCopyRect (* ptr x y w h ctx -- OK? *)
	1 swap GraphicsBlitRect
end

procedure GraphicsBlitRect (* ptr x y w h mode ctx -- OK? *)
	auto ctx
	ctx!

	ctx@ GraphicsBPP
	if (8 ~=)
		ERR return (* unimplemented *)
	end

	ctx@ GraphicsBlitRect8
end

(* this is a painfully verbose routine *)
procedure GraphicsBlitRect8 (* ptr x y w h mode ctx -- OK? *)
	auto ctx
	ctx!
	auto mode
	mode!
	auto h
	h!
	auto w
	w!
	auto y
	y!
	auto x
	x!
	auto ptr
	ptr!

	auto fbstart
	auto fbsize
	ctx@ GraphicsFramebuffer fbsize! fbstart!

	auto fbw
	auto fbh
	ctx@ GraphicsDimensions fbh! fbw!

	fbstart@ x@ + y@ fbw@ * + fbstart!

	auto modulo
	fbw@ w@ - 16 << modulo!

	modulo@
	w@
	h@
	fbstart@
	ptr@
	mode@
	BlitterOperation
end












