var IDiskBD 0

procedure IDiskInit (* bootdev -- *)
	IDiskBD!
end

procedure IReadBlock (* block buffer -- *)
	auto buf
	buf!

	auto block
	block!

	IDiskBD@ DeviceSelectNode
		buf@ ANTEPush block@ ANTEPush "readBlock" DCallMethod drop ANTEPop drop
	DeviceExit
end