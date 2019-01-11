#include "devtree/Citron.d"
#include "devtree/MMU.d"
#include "devtree/screen/Screen.d"
#include "devtree/serial/Serial.d"
#include "devtree/amanatsu/Amanatsu.d"
#include "devtree/ahdb/AHDB.d"
#include "devtree/gconsole/GConsole.d"

procedure BuildTree (* -- *)
	BuildMMU
	BuildScreen
	BuildSerial
	BuildAmanatsu
	BuildAHDB
	BuildGConsole

	DeviceNew
		"cpu" DSetName
		"limn" "type" DAddProperty
	DeviceExit
end