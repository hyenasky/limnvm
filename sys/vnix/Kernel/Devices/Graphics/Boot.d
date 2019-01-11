table BootGraphicsCtx
	0
	0
	0
	0
	0
endtable

var GraphicsBootCtx 0

procedure BootGraphicsInit (* -- bootctx *)
	if ("-nographics" ArgsCheck)
		"no boot graphics\n" KPrintf
		ERR GraphicsBootCtx!
		return
	end

	BootGraphicsCtx KinnowPopulate
	if (ERR ==)
		"no boot graphics\n" KPrintf
		ERR GraphicsBootCtx!
		return
	end

	BootGraphicsCtx GraphicsCtxAdd GraphicsBootCtx!

	GraphicsBootCtx@ GraphicsBPP GraphicsBootCtx@ GraphicsDimensions swap GraphicsBootCtx@
	"boot graphics on context %d: %dx%dx%d\n" KPrintf
end

procedure BootGraphicsBPP (* -- bpp *)
	GraphicsBootCtx@ GraphicsBPP
end

procedure BootGraphicsFramebuffer (* -- fbp fbs *)
	GraphicsBootCtx@ GraphicsFramebuffer
end

procedure BootGraphicsDimensions (* -- w h *)
	GraphicsBootCtx@ GraphicsDimensions
end

procedure BootGraphicsAvailable (* -- available? *)
	GraphicsBootCtx@ ERR ~=
end

procedure BootGraphicsFillRect (* color x y w h -- OK? *)
	if (BootGraphicsAvailable ~~)
		ERR return
	end

	GraphicsBootCtx@ GraphicsFillRect
end

procedure BootGraphicsCopyRect (* ptr x y w h -- OK? *)
	if (BootGraphicsAvailable ~~)
		ERR return
	end

	GraphicsBootCtx@ GraphicsCopyRect
end

procedure BootGraphicsBlitRect (* ptr x y w h mode -- OK? *)
	if (BootGraphicsAvailable ~~)
		ERR return
	end

	GraphicsBootCtx@ GraphicsBlitRect
end