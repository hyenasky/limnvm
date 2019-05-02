(* platform independent blitter interface, antecedent standard *)

var SBlitterNode 0

procedure GBlitterDefault (* -- defaultnode *)
	"blitter-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/blitter" "blitter-dev" NVRAMSetVar
		"/ebus/platformboard/citron/blitter"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/platformboard/citron/blitter" "blitter-dev" NVRAMSetVar
		"/ebus/platformboard/citron/blitter" DevTreeWalk dn!
	end

	dn@
end

procedure BuildGBlitter (* -- *)
	GBlitterDefault SBlitterNode!

	if (SBlitterNode@ 0 ~=)
		SBlitterNode@ DeviceClone
			"blitter" DSetName
		DeviceExit
	end
end