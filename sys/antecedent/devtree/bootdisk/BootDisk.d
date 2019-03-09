(* platform independent keyboard interface, antecedent standard *)

var SBootDiskNode 0

procedure GBootDiskDefault (* -- defaultnode *)
	"boot-dev" NVRAMGetVar dup if (0 ==)
		drop "/ebus/platformboard/citron/ahdb/0/a" "boot-dev" NVRAMSetVar
		"/ebus/platformboard/citron/ahdb/0/a"
	end

	auto dn
	DevTreeWalk dn!

	if (dn@ 0 ==)
		"/ebus/platformboard/citron/ahdb/0/a" "boot-dev" NVRAMSetVar
		"/ebus/platformboard/citron/ahdb/0/a" DevTreeWalk dn!
	end

	dn@
end

procedure BuildBootDisk (* -- *)
	GBootDiskDefault SBootDiskNode!

	if (SBootDiskNode@ 0 ~=)
		SBootDiskNode@ DeviceClone
			"bootdisk" DSetName
		DeviceExit
	end
end