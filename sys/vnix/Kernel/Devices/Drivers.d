#include "Devices/Bus/Citron.d"
#include "Devices/MMU.d"
#include "Devices/Blitter.d"

#include "Devices/Graphics/Graphics.d"

procedure DriversInit (* -- *)
	GraphicsInit
	BlitterInit
end