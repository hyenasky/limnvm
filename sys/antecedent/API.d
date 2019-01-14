table API
	pointerof APIPutc
	pointerof APIGetc
	pointerof APIGets
	pointerof APIPuts
	pointerof APIDevTree
	pointerof APIMalloc
	pointerof APICalloc
	pointerof APIFree
	pointerof _PUSH
	pointerof _POP
endtable

procedure APIMalloc
	asm "

	;r0 - size

	call _PUSH
	call Malloc
	call _POP

	;r0 - ptr

	"
end

procedure APICalloc
	asm "

	;r0 - size

	call _PUSH
	call Calloc
	call _POP

	;r0 - ptr

	"
end

procedure APIFree
	asm "

	;r0 - ptr

	call _PUSH
	call Free

	"
end

procedure APIPutc
	asm "

	;r0 - char

	call _PUSH
	call Putc

	"
end

procedure APIGetc
	asm "

	call Getc
	call _POP

	;r0 - char

	"
end

procedure APIGets
	asm "

	;r0 - s
	;r1 - max

	xch r0, r1

	call _PUSH

	mov r0, r1
	call _PUSH

	call Gets

	"
end

procedure APIPuts
	asm "

	;r0 - string

	call _PUSH

	call Puts

	"
end

procedure APIPutx
	asm "

	;r0 - x

	call _PUSH

	call Putx

	"
end

procedure APIPutn
	asm "

	;r0 - n

	call _PUSH

	call Putn

	"
end

procedure APIDevTree
	DevTree@ asm "

	li r1, DevCurrent

	call _POP

	;r0 - devtree
	;r1 - devcurrent

	"
end