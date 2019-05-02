procedure MonitorCommandsInit (* -- *)
	ListCreate MonitorCommandList!

	"Display help."
	pointerof MonitorCommandHelp
	"help"
	MonitorAddCommand

	"Clear console."
	pointerof MonitorCommandClear
	"clear"
	MonitorAddCommand

	"Print banner."
	pointerof MonitorCommandBanner
	"banner"
	MonitorAddCommand

	"Dump firmware heap."
	pointerof MonitorCommandDumpHeap
	"dumpheap"
	MonitorAddCommand

	"[dev] List children of device."
	pointerof MonitorCommandLs
	"ls"
	MonitorAddCommand

	"[dev] List properties of device."
	pointerof MonitorCommandDinfo
	"dinfo"
	MonitorAddCommand

	"[name] Print environment variable."
	pointerof MonitorCommandPrintenv
	"printenv"
	MonitorAddCommand

	"[name] [new] Set environment variable."
	pointerof MonitorCommandSetenv
	"setenv"
	MonitorAddCommand

	"[name] Delete environment variable."
	pointerof MonitorCommandDelenv
	"delenv"
	MonitorAddCommand

	"List environment variables."
	pointerof MonitorCommandListenv
	"listenv"
	MonitorAddCommand

	"Reset system."
	pointerof LateReset
	"reset"
	MonitorAddCommand

	0
	pointerof _DumpStack
	"_ds"
	MonitorAddCommand

	"Write nvram-rc."
	pointerof MonitorCommandNvramrc
	"nvramrc"
	MonitorAddCommand

	"Print nvram-rc."
	pointerof MonitorCommandPrintnvramrc
	"printnvramrc"
	MonitorAddCommand

	"[ptr] Print string."
	pointerof MonitorCommandPuts
	"puts"
	MonitorAddCommand

	"[string] Echo string."
	pointerof MonitorCommandEcho
	"echo"
	MonitorAddCommand

	"Exit monitor."
	pointerof MonitorCommandExit
	"exit"
	MonitorAddCommand

	"Boot with default parameters."
	pointerof MonitorCommandAutoboot
	"autoboot"
	MonitorAddCommand

	"[dev] [args ...] Boot from device."
	pointerof MonitorCommandBoot
	"boot"
	MonitorAddCommand

	"Reset nvram."
	pointerof MonitorCommandNVReset
	"nvreset"
	MonitorAddCommand

	"Uptime in milliseconds."
	pointerof MonitorCommandUptime
	"uptime"
	MonitorAddCommand

	"[time in ms] Wait."
	pointerof MonitorCommandWait
	"wait"
	MonitorAddCommand

	0
	pointerof _SF
	"sf"
	MonitorAddCommand
end

procedure MonitorCommandWait (* -- *)
	auto clock
	"/clock" DevTreeWalk clock!

	if (clock@ 0 ==)
		" no clock!\n" Printf
		return
	end

	clock@ DeviceSelectNode
		auto ms
		MonitorParseWord ms!

		ms@ atoi "wait" DCallMethod drop

		ms@ Free
	DeviceExit
end

procedure MonitorCommandUptime (* -- *)
	auto clock
	"/clock" DevTreeWalk clock!

	if (clock@ 0 ==)
		" no clock!\n" Printf
		return
	end

	clock@ DeviceSelectNode
		"uptime" DCallMethod drop " uptime (ms): %d\n" Printf
	DeviceExit
end

procedure MonitorCommandHinv (* -- *)

end

procedure MonitorCommandNVReset (* -- *)
	NVRAMFormat
end

procedure MonitorCommandClear (* -- *)
	"\[c" Printf
end

procedure MonitorCommandAutoboot (* -- *)
	[AutoBoot]BootErrors@ " boot: %s\n" Printf
end

procedure MonitorCommandBoot (* -- *)
	auto dev
	MonitorParseDevPath dev!
	if (dev@ 0 ==) return end

	[dev@ MonitorLinePoint@ 1 + BootNode]BootErrors@ " boot: %s\n" Printf
end

procedure MonitorCommandExit (* -- *)
	0 MonitorRunning!
end

procedure MonitorCommandEcho (* -- *)
	MonitorLinePoint@ 1 + "%s\n" Printf
end

procedure MonitorCommandPuts (* -- *)
	auto ptr
	MonitorParseWord ptr!

	ptr@ atoi "%s\n" Printf

	ptr@ Free
end

procedure MonitorCommandDinfo (* -- *)
	auto dev
	MonitorParseDevPath dev!
	if (dev@ 0 ==) return end

	dev@ DeviceSelectNode
		DGetName "\n info for %s:\n\n To print property strings, use puts.\n Properties:\n" Printf

		auto plist
		DGetProperties plist!

		auto n
		plist@ ListHead n!

		while (n@ 0 ~=)
			auto pnode
			n@ ListNodeValue pnode!

			pnode@ DeviceProperty_Value + @ pnode@ DeviceProperty_Name + @ pnode@ "\t%x\t%s\t%d\n" Printf

			n@ ListNode_Next + @ n!
		end

		"\n Supported methods:\n" Printf

		auto mlist
		DGetMethods mlist!

		mlist@ ListHead n!

		while (n@ 0 ~=)
			n@ ListNodeValue pnode!

			pnode@ DeviceMethod_Func + @ pnode@ DeviceProperty_Name + @ pnode@ "\t%x\t%s\t%x\n" Printf

			n@ ListNode_Next + @ n!
		end

	DeviceExit

	'\n' Putc
end

procedure _SF (* -- *)
	"c;\n" Printf
end

procedure MonitorCommandPrintnvramrc (* -- *)
	"nvramrc" NVRAMGetVar dup if (0 ==) drop return end
	"%s\n" Printf
end

procedure MonitorCommandNvramrc (* -- *)
	" finish by typing a single ';' on a blank line, restart by typing '#'.\n" Printf

	auto editing
	1 editing!

	auto bigbuf
	240 Calloc bigbuf!

	auto linebuf
	240 Calloc linebuf!

	auto len
	0 len!

	while (editing@)
		len@ " %d/239\t%% " Printf
		linebuf@ 239 Gets

		if (linebuf@ ";" strcmp)
			break
		end else if (linebuf@ "#" strcmp)
			0 len!
			bigbuf@ strzero
		end else
			bigbuf@ len@ + linebuf@ strcpy
			len@ linebuf@ strlen + len!
			'\n' bigbuf@ len@ + sb
			len@ 1 + len!
		end end
	end

	if (len@ 240 >=)
		" script too long!\n"
	end else
		bigbuf@ "nvramrc" NVRAMSetVar

		" enable nvramrc? [true/false] " Printf
		auto lilbuf
		10 Calloc lilbuf!

		lilbuf@ 9 Gets
		lilbuf@ "nvramrc?" NVRAMSetVar
	end

	bigbuf@ Free
	linebuf@ Free
end

procedure MonitorCommandListenv (* -- *)
	auto i
	0 i!

	auto sp
	NVRAMHeader_SIZEOF sp!
	while (i@ NVRAMVarCount <)
		if (sp@ NVRAMOffset gb 0 ~=)
			if (sp@ NVRAMOffset "nvramrc" strcmp)
				" nvramrc\t=\t[type printnvramrc]\n" Printf
			end else
				sp@ NVRAMVariable_Contents + NVRAMOffset sp@ NVRAMOffset " %s\t=\t\"%s\"\n" Printf
			end
		end

		sp@ NVRAMVariable_SIZEOF + sp!
		i@ 1 + i!
	end
end

procedure MonitorCommandDelenv (* -- *)
	auto name
	MonitorParseWord name!

	name@ NVRAMDeleteVar

	name@ Free
end

procedure MonitorCommandSetenv (* -- *)
	auto name
	MonitorParseWord name!

	auto new
	MonitorLinePoint@ 1 + new!

	new@ name@ NVRAMSetVar

	new@ name@ " set %s = \"%s\"\n" Printf

	name@ Free
end

procedure MonitorCommandPrintenv (* -- *)
	auto word
	MonitorParseWord word!

	word@ NVRAMGetVar dup if (0 ~=)
		word@ " %s = \"%s\"\n" Printf
	end else
		drop word@ " %s is not a variable.\n" Printf
	end

	word@ Free
end

procedure MonitorLsH (* tabs dev -- *)
	auto dev
	dev!

	auto tabs
	tabs!

	auto tnc
	dev@ TreeNodeChildren tnc!

	auto n
	tnc@ ListHead n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue pnode!

		n@ "\t%x:" Printf

		auto i
		0 i!
		while (i@ tabs@ <)
			"  " Puts
			i@ 1 + i!
		end

		pnode@ TreeNodeValue DeviceNode_Name + @ "/%s\n" Printf

		tabs@ 1 + pnode@ MonitorLsH

		n@ ListNode_Next + @ n!
	end
end

procedure MonitorCommandLs (* -- *)
	auto dev
	MonitorParseDevPath dev!
	if (dev@ 0 ==) return end

	dev@ DeviceSelectNode
		DGetName " %s:\n" Printf
	DeviceExit

	1 dev@ MonitorLsH
end

procedure MonitorCommandDumpHeap (* -- *)
	HeapDump
end

procedure MonitorCommandHelp (* -- *)
	auto plist
	MonitorCommandList@ plist!

	auto n
	plist@ List_Head + @ n!

	while (n@ 0 ~=)
		auto pnode
		n@ ListNodeValue
		pnode!

		pnode@ MonitorCommand_HelpText + @ dup if (0 ~=)
			pnode@ MonitorCommand_Name + @ " %s\t-\t%s\n" Printf
		end else drop end

		n@ ListNodeNext n!
	end
end

procedure BannerPrint (* ... -- *)
	'\t' dup Putc Putc
	Printf
end

procedure MonitorCommandBanner (* -- *)
	'\n' dup Putc Putc

	"/" DeviceSelect
		"boot firmware up\n" BannerPrint
		"author" DGetProperty "version" DGetProperty DGetName "Implementation details: %s %s written by %s\n" BannerPrint
		"platform" DGetProperty "Platform: %s\n" BannerPrint
		"buildDate" DGetProperty "build" DGetProperty "Build %s, built on %s\n" BannerPrint
	DeviceExit

	"/cpu" DeviceSelect
		"type" DGetProperty "CPU type: %s\n" BannerPrint
	DeviceExit

	"/memory" DeviceSelect
		"totalRAM" DGetProperty 1024 / "RAM: %dkb\n" BannerPrint
	DeviceExit

	'\n' Putc
	" Type 'help' for commands, or 'exit' to return from the monitor.\n" Printf
end