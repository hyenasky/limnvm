table API
	pointerof APIPutc
	pointerof APIGetc
	pointerof APIGets
	pointerof APIPuts
	pointerof APIDevTree
	pointerof APIMalloc
	pointerof APICalloc
	pointerof APIFree
endtable

procedure APIMalloc
	asm "

	;r0 - size

	pushv r5, r0
	call Malloc
	popv r5, r0

	;r0 - ptr

	"
end

procedure APICalloc
	asm "

	;r0 - size

	pushv r5, r0
	call Calloc
	popv r5, r0

	;r0 - ptr

	"
end

procedure APIFree
	asm "

	;r0 - ptr

	pushv r5, r0
	call Free

	"
end

procedure APIPutc
	asm "

	;r0 - char

	pushv r5, r0
	call Putc

	"
end

procedure APIGetc
	asm "

	call Getc
	popv r5, r0

	;r0 - char

	"
end

procedure APIGets
	asm "

	;r0 - s
	;r1 - max

	xch r0, r1

	pushv r5, r0

	mov r0, r1
	pushv r5, r0

	call Gets

	"
end

procedure APIPuts
	asm "

	;r0 - string

	pushv r5, r0

	call Puts

	"
end

procedure APIPutx
	asm "

	;r0 - x

	pushv r5, r0

	call Putx

	"
end

procedure APIPutn
	asm "

	;r0 - n

	pushv r5, r0

	call Putn

	"
end

procedure APIDevTree
	DevTree@ asm "

	li r1, DevCurrent

	popv r5, r0

	;r0 - devtree
	;r1 - devcurrent

	"
end