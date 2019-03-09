(* platform independent keyboard interface, antecedent standard *)

var SClockNode 0

procedure GClockDefault (* -- defaultnode *)
	"clock-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/clock" "clock-dev" NVRAMSetVar
		"/ebus/platformboard/citron/clock"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/platformboard/citron/clock" "clock-dev" NVRAMSetVar
		"/ebus/platformboard/citron/clock" DevTreeWalk dn!
	end

	dn@
end

procedure BuildClock (* -- *)
	GClockDefault SClockNode!

	if (SClockNode@ 0 ~=)
		SClockNode@ DeviceClone
			"clock" DSetName
		DeviceExit
	end
end