const GraphicsScreenWidth 1120
const GraphicsScreenHeight 832
const GraphicsFramebuffer 0xF4000000

procedure GraphicsXYDim (* w h -- dim *)
	16 << |
end

procedure GraphicsFillScreen (* color -- *)
	auto color
	color!

	0 (* modulo *)
	GraphicsScreenWidth GraphicsScreenHeight GraphicsXYDim (* dim *)
	GraphicsFramebuffer (* dest *)
	color@ (* from *)
	2 (* cmd *)
	ACIBlitterOperation
end

procedure GraphicsCopyImage (* image x y w h -- *)
	auto h
	h!
	auto w
	w!
	auto y
	y!
	auto x
	x!
	auto image
	image!

	GraphicsScreenWidth w@ - 16 << (* modulo *)
	w@ h@ GraphicsXYDim (* dim *)
	GraphicsFramebuffer y@ GraphicsScreenWidth * x@ + + (* dest *)
	image@ (* from *)
	1 (* cmd *)
	ACIBlitterOperation
end

procedure GraphicsCopyFromScreen (* buf x y w h -- *)
	auto h
	h!
	auto w
	w!
	auto y
	y!
	auto x
	x!
	auto buf
	buf!

	GraphicsScreenWidth w@ - (* modulo *)
	w@ h@ GraphicsXYDim (* dim *)
	buf@ (* dest *)
	GraphicsFramebuffer y@ GraphicsScreenWidth * x@ + + (* from *)
	1 (* cmd *)
	ACIBlitterOperation
end