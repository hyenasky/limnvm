#include "Devices/Drivers.d"

struct DevDriver
	4 PName
	4 FPut
	4 FGet
	4 FIOCtl
	4 FNumMinor
	4 IsBlock
endstruct

(*
for block devices:

buffer block minor FPut -- fail?
buffer block minor FGet -- fail?

for char devices:
char minor FPut -- fail?
minor FGet -- char

*)

const DEVDRIVERNUM 128
var DevDriverList 0
var DevDriverPtr 0

procedure DevInit (* -- *)
	"Dev: init\n" KPrintf

	DEVDRIVERNUM DevDriver_SIZEOF * KCalloc dup DevDriverList!
	if (ERR ==)
		"couldn't allocate driver list: not enough heap\n" KPanic
	end

	DriversInit

	"Dev: init done\n" KPrintf
end

procedure DevIsBlock (* devnum -- block? *)
	auto driver
	auto minor

	DevSplitNum driver! minor!

	if (driver@ ERR ==)
		ERR return
	end

	driver@ DevDriver_IsBlock + @
end

procedure DevNumMinors (* devnum -- minors *)
	auto driver
	auto minor

	DevSplitNum driver! minor!

	if (driver@ ERR ==)
		ERR return
	end

	auto fnum
	minor@ driver@ DevDriver_FNumMinor + @ fnum!

	if (fnum@ 0 ==)
		ERR return
	end
	
	fnum@ Call
end

procedure DevIOCtl (* ... devnum -- ? *)
	auto driver
	auto minor

	DevSplitNum driver! minor!

	if (driver@ ERR ==)
		ERR return
	end

	auto fioctl
	minor@ driver@ DevDriver_FIOCtl + @ fioctl!

	if (fioctl@ 0 ==)
		ERR return
	end
	
	fioctl@ Call
end

procedure DevPut (* ... devnum -- fail? *)
	auto driver
	auto minor

	DevSplitNum driver! minor!

	if (driver@ ERR ==)
		ERR return
	end

	auto fput
	minor@ driver@ DevDriver_FPut + @ fput!

	if (fput@ 0 ==)
		ERR return
	end

	fput@ Call
end

procedure DevGet (* ... devnum --  *)
	auto driver
	auto minor

	DevSplitNum driver! minor!

	if (driver@ ERR ==)
		ERR return
	end

	auto fget
	minor@ driver@ DevDriver_FGet + @ fget!

	if (fget@ 0 ==)
		ERR return
	end

	fget@ Call
end

(* dev paths look like /[driver]/[minor number] *)

procedure DevResolvePath (* path -- dev *)
	auto path
	path!

	auto buf
	32 KCalloc buf! (* for re-entrance *)

	auto major
	auto minor

	path@ buf@ '/' 31 strntok path!

	buf@ DevDriverByName major!

	if (major@ ERR ==) (* no such driver *)
		buf@ KFree ERR return
	end

	buf@ strzero

	path@ buf@ '/' 31 strntok path!

	buf@ atoi minor!

	if (minor@ 65535 >)
		buf@ KFree ERR return
	end

	buf@ KFree major@ 16 << minor@ |
end

procedure DevSplitNum (* devnum -- minor drivertab *)
	auto devnum
	devnum!

	auto driver
	devnum@ 16 >> DevDriverByMajor driver!

	auto minor
	devnum@ 0xFFFF & minor!

	minor@ driver@
end

procedure DevDriverByMajor (* maj -- tabptr *)
	auto maj
	maj!

	if (maj@ DevDriverPtr@ >=)
		ERR return
	end

	maj@ 4 * DevDriverList@ + @
end

procedure DevDriverByName (* name -- driver *)
	auto name
	name!

	auto i
	0 i!

	auto max
	DevDriverPtr@ max!
	while (i@ max@ <)
		auto base
		i@ 4 * DevDriverList@ + @ base!

		if (base@ 0 ~=)
			if (base@ DevDriver_PName + @ name@ strcmp)
				i@ return
			end
		end

		i@ 1 + i!
	end

	ERR return
end

procedure DevAddDriver (* tab -- *)
	auto tab
	tab!

	DevDriverPtr@ tab@ tab@ DevDriver_PName + @ "Dev: adding driver %s@0x%x@%d\n" KPrintf

	if (DevDriverPtr@ DEVDRIVERNUM ==)
		"can't add driver: max reached\n" KPanic
	end

	tab@ DevDriverPtr@ 4 * DevDriverList@ + !

	DevDriverPtr@ 1 + DevDriverPtr!
end