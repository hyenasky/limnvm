var AKeyboardDev 0
var AKeyboardCount 0

const AKeyboardMID 0x8FC48FC4

procedure AKeyboardPoll (* -- *)
	auto i
	1 i!

	while (i@ 256 <)
		auto rs
		InterruptDisable rs!

		if (i@ AmanatsuPoll AKeyboardMID ==)
			auto hmm
			5 Calloc hmm!

			AKeyboardDev@ DeviceSelectNode

				DeviceNew
					AKeyboardCount@ hmm@ itoa

					hmm@ DSetName

					i@ "aID" DAddProperty

					pointerof AKeyboardRead "read" DAddMethod

					AKeyboardCount@ 1 + AKeyboardCount!
				DeviceExit
			DeviceExit
		end

		rs@ InterruptRestore

		i@ 1 + i!
	end
end

procedure AKeyboardPopCode (* id -- code *)
	auto id
	id!

	auto rs
	InterruptDisable rs!

	auto code

	id@ AmanatsuSelectDev
	1 AmanatsuCommand
	AmanatsuReadA code!

	rs@ InterruptRestore

	code@
end

procedure AKeyboardSpecial (* code -- *)
	auto code
	code!

	if (code@ 50 ==)
		'\n' return
	end
	if (code@ 51 ==)
		'\b' return
	end

	ERR return
end

procedure AKeyboardRead (* -- c *)
	auto id
	"aID" DGetProperty id!

	auto code

	id@ AKeyboardPopCode code!

	if (code@ 0xFFFF ==)
		ERR return
	end

	auto c

	if (code@ 0xF0 ==) (* shift *)

		id@ AKeyboardPopCode code!

		if (code@ 50 >=) code@ AKeyboardSpecial return end

		pointerof AKeyboardLayoutShift code@ + gb c!

	end else if (code@ 0xF1 ==) (* ctrl *)

		id@ AKeyboardPopCode code!

		if (code@ 50 >=) code@ AKeyboardSpecial return end

		pointerof AKeyboardLayoutCtrl code@ + gb c!

	end else

		if (code@ 50 >=) code@ AKeyboardSpecial return end

		pointerof AKeyboardLayout code@ + gb c!

	end
	end

	c@
end

procedure AKeyboardInit (* -- *)
	DeviceNew
		"kbd" DSetName
		DevCurrent@ AKeyboardDev!
	DeviceExit
end

asm "

AKeyboardLayout:
	.db \"a\"
	.db \"b\", \"c\", \"d\"
	.db \"e\", \"f\", \"g\"
	.db \"h\", \"i\", \"j\"
	.db \"k\", \"l\", \"m\"
	.db \"n\", \"o\", \"p\"
	.db \"q\", \"r\", \"s\"
	.db \"t\", \"u\", \"v\"
	.db \"w\", \"x\", \"y\"
	.db \"z\"
	.db \"0\", \"1\", \"2\"
	.db \"3\", \"4\", \"5\"
	.db \"6\", \"7\", \"8\"
	.db \"9\"
	.db \";\"
	.db 0x20
	.db 0x20
	.db \"-\"
	.db \"=\"
	.db \"[\"
	.db \"]\"
	.db \"\\\"
	.db \";\"
	.db \"/\"
	.db \".\"
	.db \"'\"
	.db \",\"

AKeyboardLayoutCtrl:
	.db \"i\"
	.db \"a\", \"m\", \"s\"
	.db \"u\", \"p\", \"e\"
	.db \"r\", \"g\", \"a\"
	.db \"y\", \"l\", \"m\"
	.db \"n\", \"o\", \"p\"
	.db \"q\", \"r\", \"s\"
	.db \"t\", \"u\", \"v\"
	.db \"w\", \"x\", \"y\"
	.db \"z\"
	.db \"0\", \"1\", \"2\"
	.db \"3\", \"4\", \"5\"
	.db \"6\", \"7\", \"8\"
	.db \"9\"
	.db \";\"
	.db 0x20
	.db 0x20
	.db \"-\"
	.db \"=\"
	.db \"[\"
	.db \"]\"
	.db \"\\\"
	.db \";\"
	.db \"/\"
	.db \".\"
	.db \"'\"
	.db \",\"

AKeyboardLayoutShift:
	.db \"A\"
	.db \"B\", \"C\", \"D\"
	.db \"E\", \"F\", \"G\"
	.db \"H\", \"I\", \"J\"
	.db \"K\", \"L\", \"M\"
	.db \"N\", \"O\", \"P\"
	.db \"Q\", \"R\", \"S\"
	.db \"T\", \"U\", \"V\"
	.db \"W\", \"X\", \"Y\"
	.db \"Z\"
	.db \")\", \"!\", \"@\"
	.db \"#\", \"$\", \"%\"
	.db \"^\", \"&\", \"*\"
	.db \"(\"
	.db \":\"
	.db 0x20
	.db 0x20
	.db \"_\"
	.db \"+\"
	.db \"{\"
	.db \"}\"
	.db \"|\"
	.db \":\"
	.db \"?\"
	.db \">\"
	.db \"\"\"
	.db \"<\"

"