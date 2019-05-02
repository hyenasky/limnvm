#include "devtree/Memory.d"
#include "devtree/ebus/EBus.d"
#include "devtree/screen/Screen.d"
#include "devtree/serial/Serial.d"
#include "devtree/gconsole/GConsole.d"
#include "devtree/mouse/Mouse.d"
#include "devtree/keyboard/Keyboard.d"
#include "devtree/bootdisk/BootDisk.d"
#include "devtree/clock/Clock.d"
#include "devtree/blitter/Blitter.d"

procedure BuildTree (* -- *)
	DeviceNew
		"cpu" DSetName
		"limn" "type" DAddProperty
	DeviceExit

	BuildEBus

	BuildMemory

	(* platform independent pseudo-devices *)
	BuildSerial
	BuildScreen
	BuildGConsole
	BuildKeyboard
	BuildMouse
	BuildBootDisk
	BuildClock
	BuildGBlitter
end