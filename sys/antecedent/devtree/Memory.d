procedure BuildMemory (* -- *)
	DeviceNew
		"memory" DSetName

		0 "totalRAM" DAddProperty
	DeviceExit
end

const MmuAreaBase 0xB8000000