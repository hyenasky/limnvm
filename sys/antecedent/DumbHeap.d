var KHeapTop 0x500000

procedure Malloc
	auto sz
	sz!

	KHeapTop@ sz@ - KHeapTop!
	KHeapTop@ 
end

procedure Calloc (* sz -- ptr *)
	auto sz
	sz!

	auto he

	sz@ Malloc he!

	if (he@ 0 ==)
		0 return
	end

	he@ sz@ 0 memset

	he@
end

procedure Free (* -- *) end

procedure HeapDump
	KHeapTop@ "%x\n" Printf
end

procedure HeapInit end