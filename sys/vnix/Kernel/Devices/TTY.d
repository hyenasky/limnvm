table DTTYDriver
	"tty"
	pointerof DTTYPut
	pointerof DTTYGet
	pointerof DTTYIOCtl
	pointerof DTTYNumMinor
	0
	1
endtable

procedure DTTYInit (* -- *)
	DTTYDriver DevAddDriver
end

procedure DTTYPut (* char loc minor -- status *)
	auto minor
	minor!

	drop

	if (minor@ 0 ==)
		KPutc OK return
	end

	ERR return
end

procedure DTTYGet (* loc minor -- char *)
	auto minor
	minor!

	drop

	if (minor@ 0 ==)
		KGetc return
	end

	ERR return
end

procedure DTTYIOCtl (* -- OK *)
	OK return
end

procedure DTTYNumMinor (* -- num *)
	1 return
end