asm "

BootsplashBMP:
	.static Extra/kabosusplash.bmp

"

const BootsplashW 496
const BootsplashH 107

procedure Bootsplash (* -- *)
	if (BootGraphicsAvailable ~~)
		return
	end

	if ("-dcls" ArgsCheck ~~)
		0x00 0 0 BootGraphicsDimensions BootGraphicsFillRect drop
	end

	auto bx
	auto by

	BootGraphicsDimensions by! bx!
	bx@ 2 / BootsplashW 2 / - bx!
	by@ 2 / BootsplashH 2 / - by!

	pointerof BootsplashBMP bx@ by@ BootsplashW BootsplashH BootGraphicsCopyRect drop
end