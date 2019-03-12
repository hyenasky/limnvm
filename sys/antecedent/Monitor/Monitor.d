var MonitorRunning 0

var MonitorCommandList 0

var MonitorLine 0
var MonitorLinePoint 0

var MonitorNvramrc 0
var MonitorOldCI 0
var MonitorOldCIM 0
var MonitorNvramrcBuf 0
var MonitorNvramrcLen 0
var MonitorNvramrcPtr 0
var MonitorPastNvramrc 0

struct MonitorCommand
	4 Name
	4 Callback
	4 HelpText
endstruct

#include "Monitor/Commands.d"

procedure Monitor (* -- *)
	if (MonitorCommandList@ 0 ==)
		MonitorCommandsInit
	end

	1 MonitorRunning!

	if (MonitorLine@) MonitorLine@ Free end

	256 Calloc MonitorLine!

	MonitorCommandBanner

	MonitorDoNvramrc

	while (MonitorRunning@)
		MonitorPrompt
		MonitorDoLine
	end

	MonitorExit
end

procedure SafeMonitor (* -- *)
	if (MonitorCommandList@ 0 ==)
		MonitorCommandsInit
	end

	1 MonitorRunning!

	if (MonitorLine@) MonitorLine@ Free end

	256 Calloc MonitorLine!

	while (MonitorRunning@)
		MonitorPrompt
		MonitorDoLine
	end

	MonitorExit
end

procedure MonitorDoNvramrc (* -- *)
	0 MonitorNvramrc!

	"nvramrc?" NVRAMGetVar dup if (0 ==)
		drop "false" "nvramrc?" NVRAMSetVar
		"false"
	end

	if ("true" strcmp)
		1 MonitorNvramrc!

		0 MonitorNvramrcPtr!

		240 Calloc MonitorNvramrcBuf!

		"nvramrc" NVRAMGetVar dup if (0 ==)
			drop
			""
		end

		MonitorNvramrcBuf@ swap strcpy

		MonitorNvramrcBuf@ strlen MonitorNvramrcLen!

		ConsoleInMethod@ MonitorOldCIM!
		ConsoleIn@ MonitorOldCI!

		if (MonitorPastNvramrc@ 0 ==)
			DeviceNew
				"nvramrc" DSetName

				pointerof MonitorNvramrcRead "read" DAddMethod

				DevCurrent@ dup ConsoleSetIn MonitorPastNvramrc!
			DeviceExit
		end else
			MonitorPastNvramrc@ ConsoleSetIn
		end
	end
end

procedure MonitorNvramrcRead (* -- c *)
	if (MonitorNvramrcPtr@ MonitorNvramrcLen@ >=) MonitorNvramrcExit ERR return end

	MonitorNvramrcBuf@ MonitorNvramrcPtr@ + gb

	MonitorNvramrcPtr@ 1 + MonitorNvramrcPtr!
end

procedure MonitorNvramrcExit (* -- *)
	if (MonitorNvramrc@)
		MonitorOldCIM@ ConsoleInMethod!
		MonitorOldCI@ ConsoleIn!

		0 MonitorNvramrc!

		MonitorNvramrcBuf@ Free
	end
end

(* should be called before any command leaves the monitor, for instance 'boot' *)
procedure MonitorExit (* -- *)
	MonitorNvramrcExit

	if (MonitorLine@) MonitorLine@ Free end
end

procedure MonitorParseDevPath (* -- dev or 0 *)
	auto word
	MonitorParseWord word!

	auto dev
	word@ DevTreeWalk dev!

	if (dev@ 0 ==)
		word@ " bad device path %s.\n" Printf
	end

	word@ Free

	dev@
end

procedure MonitorPrompt (* -- *)
	MonitorLine@ MonitorLinePoint!
	"  > " Printf
	MonitorLine@ 255 Gets
end

procedure MonitorDoLine (* -- *)
	auto word
	MonitorParseWord word!

	if (word@ strlen 0 ~=)
		if (word@ MonitorDoCommand ~~)
			word@ " %s is not a recognized command.\n" Printf
		end else return end
	end

	word@ Free
end

procedure MonitorParseWord (* -- word *)
	auto word
	256 Calloc word!

	MonitorLinePoint@ word@ ' ' 255 strntok MonitorLinePoint!

	word@
end

procedure MonitorDoCommand (* command -- ok? *)
	auto name
	name!

	auto plist
	MonitorCommandList@ plist!

	auto n
	plist@ List_Head + @ n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		if (pnode@ MonitorCommand_Name + @ name@ strcmp)
			name@ Free

			pnode@ MonitorCommand_Callback + @ Call 1 return
		end

		n@ ListNodeNext n!
	end

	0
end

procedure MonitorAddCommand (* helptext callback name -- *)
	auto name
	name!

	auto callback
	callback!

	auto helptext
	helptext!

	auto command
	MonitorCommand_SIZEOF Calloc command!

	name@ command@ MonitorCommand_Name + !
	callback@ command@ MonitorCommand_Callback + !
	helptext@ command@ MonitorCommand_HelpText + !

	command@ MonitorCommandList@ ListInsert
end




