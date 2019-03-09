(* platform independent keyboard interface, antecedent standard *)

var SKbdNode 0

procedure GKbdDefault (* -- defaultnode *)
	"kbd-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/amanatsu/kbd/0" "kbd-dev" NVRAMSetVar
		"/ebus/platformboard/citron/amanatsu/kbd/0"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/platformboard/citron/amanatsu/kbd/0" "kbd-dev" NVRAMSetVar
		"/ebus/platformboard/citron/amanatsu/kbd/0" DevTreeWalk dn!
	end

	dn@
end

procedure BuildKeyboard (* -- *)
	GKbdDefault SKbdNode!

	if (SKbdNode@ 0 ~=)
		SKbdNode@ DeviceClone
			"keyboard" DSetName
		DeviceExit
	end
end