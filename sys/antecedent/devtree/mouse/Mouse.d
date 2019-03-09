(* platform independent keyboard interface, antecedent standard *)

var SMouseNode 0

procedure GMouseDefault (* -- defaultnode *)
	"mouse-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/amanatsu/mouse/0" "mouse-dev" NVRAMSetVar
		"/ebus/platformboard/citron/amanatsu/mouse/0"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/platformboard/citron/amanatsu/mouse/0" "mouse-dev" NVRAMSetVar
		"/ebus/platformboard/citron/amanatsu/mouse/0" DevTreeWalk dn!
	end

	dn@
end

procedure BuildMouse (* -- *)
	GMouseDefault SMouseNode!

	if (SMouseNode@ 0 ~=)
		SMouseNode@ DeviceClone
			"mouse" DSetName
		DeviceExit
	end
end