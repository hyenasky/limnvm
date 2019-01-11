#include "Devices/Bus/Citron.d"
#include "Devices/MMU.d"
#include "Devices/Blitter.d"
#include "Devices/KConsole.d"
#include "Devices/TTY.d"

#include "Devices/Graphics/Graphics.d"

procedure DriversInit (* -- *)
	DTTYInit
	BlitterInit
end