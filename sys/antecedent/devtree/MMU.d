procedure BuildMMU (* -- *)
	DeviceNew
		"mmu" DSetName

		MmuTotalMemory "totalram" DAddProperty
	DeviceExit
end

const MmuAreaBase 0xFFF20000

procedure MmuReadRegister (* reg -- v *)
	4 * MmuAreaBase + @
end

procedure MmuWriteRegister (* v reg -- *)
	4 * MmuAreaBase + !
end

const MmuTMRegister 0

procedure MmuTotalMemory (* -- mem *)
	MmuTMRegister MmuReadRegister
end