include "DI.d"

var BootDevice 0

procedure Main (* bootdev -- *)
	BootDevice!

	"\n\n==== CLIENT ====\n" PutString

	if (BootDevice@ 0 ==)
		"Booted from serial disk\n" PutString
	else
		"Booted from block device " PutString
		BootDevice@ PutInteger
		'\n' StdPutChar
	end

	while (1) end
end