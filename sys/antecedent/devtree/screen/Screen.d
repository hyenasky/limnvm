(* platform independent screen interface, antecedent standard *)

var SScreenNode 0

procedure GScreenDefault (* -- defaultnode *)
	"screen-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/kinnow2" "screen-dev" NVRAMSetVar
		"/ebus/kinnow2"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/kinnow2" "screen-dev" NVRAMSetVar
		"/ebus/kinnow2" DevTreeWalk dn!
	end

	dn@
end

procedure BuildScreen (* -- *)
	GScreenDefault SScreenNode!

	if (SScreenNode@ 0 ~=)
		SScreenNode@ DeviceClone
			"screen" DSetName
		DeviceExit

		if ("screen-bg" NVRAMGetVar 0 ==)
			0x56 "screen-bg" NVRAMSetVarNum
		end
		if ("screen-fg" NVRAMGetVar 0 ==)
			0x00 "screen-fg" NVRAMSetVarNum
		end
	end
end