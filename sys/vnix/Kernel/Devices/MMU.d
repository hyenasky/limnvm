const MmuAreaBase 0xFFF20000

procedure MmuReadRegister (* reg -- v *)
	4 * MmuAreaBase + @
end

procedure MmuWriteRegister (* v reg -- *)
	4 * MmuAreaBase + !
end