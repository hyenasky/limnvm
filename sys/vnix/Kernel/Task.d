const TASKNUM 128
var TaskList 0

var TaskCurrent 0

struct Task
	144 THTTA
	4 PName
	4 PStart
	4 NSize
endstruct

procedure TaskInit (* -- *)
	"Task: init\n" KPrintf

	TASKNUM 4 * KCalloc dup TaskList!
	if (ERR ==)
		"couldn't allocate task list: not enough heap\n" KPanic
	end

	"Task: init done\n" KPrintf
end

procedure TaskName (* pid -- name *)
	4 * TaskList@ + @ Task_PName + @
end

procedure TaskHTTA (* pid -- htta *)
	4 * TaskList@ + @ Task_THTTA +
end

procedure TaskPStart (* pid -- pstart *)
	4 * TaskList@ + @ Task_PStart + @
end

procedure TaskPSize (* pid -- psize *)
	4 * TaskList@ + @ Task_NSize + @
end

procedure TaskSCreate (* memsize name -- ptr *)
	auto name
	name!

	auto memsize
	memsize!

	auto taskS
	Task_SIZEOF KCalloc taskS!

	if (taskS@ 0 ==)
		ERR return
	end

	name@ taskS@ Task_PName + !

	auto psize
	auto pstart

	memsize@ 4096 / 2 + psize!

	psize@ PMMAllocate pstart!

	if (pstart@ ERR ==)
		taskS@ KFree
		ERR return
	end

	pstart@ taskS@ Task_PStart + !
	psize@ taskS@ Task_NSize + !

	taskS@
end

procedure TaskDestroy (* pid -- *)
	auto pid
	pid!

	auto taskS
	pid@ 4 * TaskList@ + @ taskS!

	auto pstart
	auto psize

	taskS@ Task_PStart + @ pstart!
	taskS@ Task_NSize + @ psize!

	pstart@ psize@ PMMFree

	taskS@ KFree

	0 pid@ 4 * TaskList@ + !
end

procedure TaskNewPID (* task -- pid *)
	auto task
	task!

	auto i
	0 i!

	while (i@ TASKNUM <)
		auto tlb
		i@ 4 * TaskList@ + tlb!

		if (tlb@ @ 0 ==)
			task@ tlb@ !

			i@ return
		end
		i@ 1 + i!
	end

	ERR
end

procedure TaskCreate (* memsize name -- pid *)
	TaskSCreate
	dup
	if (ERR ==)
		ERR return
	end
	TaskNewPID
end