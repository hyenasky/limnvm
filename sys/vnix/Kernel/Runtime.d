(* barebones runtime lib for vnix *)

procedure _UNDERFLOW (* -- *)
	"Runtime error: Stack underflow.\n" KPanic
end

procedure CR (* -- *)
	'\n' KPutc
end

procedure Call (* fptr -- *)
	asm "
		call _POP
		call .e
		ret

		.e:
			br r0
	"
end

procedure _DumpStack (* -- *)
	asm "

	li r0, 0
	lri.l r1, _STACK_PTR
	li r2, _STACK

.loop:
	cmp r0, r1
	be .out

	lrr.l r3, r2
	push r0
	mov r0, r3
	call _PUSH
	call KPutx

	li r0, 0xA
	call _PUSH
	call KPutc
	pop r0

	addi r0, r0, 4
	addi r2, r2, 4
	b .loop

.out:

	"
end

procedure memset (* ptr size wot -- *)
	auto wot
	wot!

	auto size
	size!

	auto ptr
	ptr!

	auto max
	ptr@ size@ + max!
	while (ptr@ max@ <)
		wot@ ptr@ sb
		ptr@ 1 + ptr!
	end
end

procedure strcmp (* str1 str2 -- equal? *)
	auto str1
	str1!

	auto str2
	str2!

	auto i
	0 i!

	while (str1@ i@ + gb str2@ i@ + gb ==)
		if (str1@ i@ + gb 0 ==)
			1 return
		end

		i@ 1 + i!
	end

	0 return
end

procedure strlen (* str -- size *)
	auto str
	str!

	auto size
	0 size!

	while (str@ gb 0 ~=)
		size@ 1 + size!
		str@ 1 + str!
	end

	size@ return
end

procedure strtok (* str buf del -- next *)
	auto del
	del!

	auto buf
	buf!

	auto str
	str!

	auto i
	0 i!

	if (str@ gb 0 ==)
		0 return
	end

	while (str@ gb del@ ==)
		str@ 1 + str!
	end

	while (str@ i@ + gb del@ ~=)
		auto char
		str@ i@ + gb char!

		if (char@ 0 ==)
			0 return
		end

		char@ buf@ i@ + sb

		i@ 1 + i!
	end

	str@ i@ +
end

procedure strzero (* str -- *)
	auto str
	str!

	auto i
	0 i!
	while (str@ i@ + gb 0 ~=)
		0 str@ i@ + sb
		i@ 1 + i!
	end
end

procedure strntok (* str buf del n -- next *)
	auto n
	n!

	auto del
	del!

	auto buf
	buf!

	auto str
	str!

	auto i
	0 i!

	if (str@ gb 0 ==)
		0 return
	end

	while (str@ gb del@ ==)
		str@ 1 + str!
	end

	while (str@ i@ + gb del@ ~=)
		if (i@ n@ >)
			break
		end

		auto char
		str@ i@ + gb char!

		if (char@ 0 ==)
			0 return
		end

		char@ buf@ i@ + sb

		i@ 1 + i!
	end

	str@ i@ +
end

procedure atoi (* str -- n *)
	auto str
	str!

	auto i
	auto res
	0 i!
	0 res!
	while (str@ i@ + gb 0 ~=)
		res@ 10 *
		str@ i@ + gb '0' -
		+
		res!

		i@ 1 + i!
	end
	res@ return
end


























