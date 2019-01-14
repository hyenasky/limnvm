var MenuScreenNode 0
var MenuActive 0

var MenuCursorX 20
var MenuCursorY 20

var MenuCursorOldX 20
var MenuCursorOldY 20

var MenuGWidth 0
var MenuGHeight 0
var MenuFramebuffer 0

const MenuCursorWidth 12
const MenuCursorHeight 19

var MenuModified 0
var MenuCurBackBuf 0

var MenuMouseR 0

var MenuButtonList 0

var MenuNeedsInit 1

procedure Menu (* -- *)
	if (MenuNeedsInit@)
		"/screen" DevTreeWalk MenuScreenNode!

		if (MenuScreenNode@ 0 ==)
			return
		end

		auto mousenode

		"menu-mouse" NVRAMGetVar dup if (0 ==)
			drop "/amanatsu/mouse/0" "menu-mouse" NVRAMSetVar
			"/amanatsu/mouse/0"
		end

		DevTreeWalk mousenode!

		if (mousenode@ 0 ==)
			return
		end

		MenuScreenNode@ DeviceSelectNode
			"framebuffer" DGetProperty MenuFramebuffer!
			"width" DGetProperty MenuGWidth!
			"height" DGetProperty MenuGHeight!

			"screen-bg" NVRAMGetVarNum MenuGWidth@ MenuGHeight@ 0 0 "rectangle" DCallMethod drop
			pointerof MenuVsyncCallback "vsyncAdd" DCallMethod drop
		DeviceExit

		ListCreate MenuButtonList!

		MenuCursorWidth MenuCursorHeight * Calloc MenuCurBackBuf!

		mousenode@ DeviceSelectNode
			pointerof MenuMouseCallback "addCallback" DCallMethod drop
		DeviceExit

		MenuGWidth@ 2 / MenuCursorWidth 2 / - dup MenuCursorX! MenuCursorOldX!
		MenuGHeight@ 2 / 2 / dup MenuCursorY! MenuCursorOldY!

		pointerof MenuButtonConsole pointerof MenuButtonConsoleBMP MenuAddButton
		pointerof MenuButtonBoot pointerof MenuButtonBootBMP MenuAddButton
		pointerof MenuButtonReset pointerof MenuButtonResetBMP MenuAddButton

		0 MenuNeedsInit!
	end

	MenuDrawButtons

	MenuCursorX@ MenuCursorY@ MenuDrawCursor

	1 MenuActive!

	while (MenuActive@)
		if (MenuMouseR@)
			0 MenuMouseR!

			MenuDoButtons
		end
	end
end

asm "

MenuCursorBMP:
	.db 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 18, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 18, 18, 15, 0, 0, 0, 0, 0, 0, 0, 0, 15, 18, 18, 18, 15, 0, 0, 0, 0, 0, 0, 0, 15, 18, 18, 18, 18, 15, 0, 0, 0, 0, 0, 0, 15, 18, 18, 18, 18, 18, 15, 0, 0, 0, 0, 0, 15, 18, 18, 18, 18, 18, 18, 15, 0, 0, 0, 0, 15, 18, 18, 18, 18, 18, 18, 18, 15, 0, 0, 0, 15, 18, 18, 18, 18, 18, 18, 18, 18, 15, 0, 0, 15, 18, 18, 18, 18, 18, 18, 18, 18, 18, 15, 0, 15, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 15, 15, 18, 18, 18, 18, 18, 18, 15, 15, 15, 15, 15, 15, 18, 18, 18, 15, 18, 18, 15, 0, 0, 0, 0, 15, 18, 18, 15, 0, 15, 18, 18, 15, 0, 0, 0, 15, 18, 15, 0, 0, 15, 18, 18, 15, 0, 0, 0, 15, 15, 0, 0, 0, 0, 15, 18, 18, 15, 0, 0, 0, 0, 0, 0, 0, 0, 15, 18, 18, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 0, 0, 0, 

MenuButtonBootBMP:
	.static Menu/buttonboot.bmp

MenuButtonConsoleBMP:
	.static Menu/buttonconsole.bmp

MenuButtonResetBMP:
	.static Menu/buttonreset.bmp

"

procedure MenuButtonReset (* -- *)
	0 MenuActive!

	MenuScreenNode@ DeviceSelectNode
		0 MenuGWidth@ MenuGHeight@ 0 0 "rectangle" DCallMethod drop
	DeviceExit

	Reset
end

procedure MenuButtonConsole (* -- *)
	0 MenuActive!

	auto kbdnode

	"menu-kbd" NVRAMGetVar dup if (0 ==)
		drop "/amanatsu/kbd/0" "menu-kbd" NVRAMSetVar
		"/amanatsu/kbd/0"
	end

	DevTreeWalk kbdnode!

	if (kbdnode@ 0 ~=)
		kbdnode@ ConsoleIn!
	end

	"/gconsole" DevTreeWalk ConsoleOut!

	Monitor

	1 MenuActive!
end

procedure MenuButtonBoot (* -- *)
	0 MenuActive!

	MenuScreenNode@ DeviceSelectNode
		"screen-bg" NVRAMGetVarNum MenuGWidth@ MenuGHeight@ 0 0 "rectangle" DCallMethod drop
	DeviceExit

	[AutoBoot]BootErrors@ " boot: %s\n" Printf

	Monitor

	Reset
end

struct MenuButton
	4 icon
	4 callback
	4 x
	4 y
endstruct

procedure MenuDoButtons (* -- *)
	auto cx
	MenuCursorX@ cx!

	auto cy
	MenuCursorY@ cy!

	auto n
	MenuButtonList@ ListHead n!

	while (n@ 0 ~=)
		auto button
		n@ ListNodeValue button!

		auto x
		button@ MenuButton_x + @ x!

		auto y
		button@ MenuButton_y + @ y!

		if (cx@ x@ >= x@ 75 + cx@ >= && cy@ y@ >= && y@ 75 + cy@ >= &&)
			button@ MenuButton_callback + @ Call
			return
		end

		n@ ListNodeNext n!
	end
end

procedure MenuDrawButtons (* -- *)
	auto numbuttons
	MenuButtonList@ ListLength numbuttons!

	auto y
	MenuGHeight@ 2 / 37 - y!

	auto x
	MenuGWidth@ 2 / numbuttons@ 95 * 2 / - x!

	auto n
	MenuButtonList@ ListHead n!

	while (n@ 0 ~=)
		auto button
		n@ ListNodeValue button!

		button@ MenuButton_icon + @ x@ y@ MenuDrawButton 

		x@ button@ MenuButton_x + !
		y@ button@ MenuButton_y + !

		x@ 95 + x!
		n@ ListNodeNext n!
	end
end

procedure MenuAddButton (* callback icon -- *)
	auto icon
	icon!

	auto callback
	callback!

	auto button
	MenuButton_SIZEOF Calloc button!

	icon@ button@ MenuButton_icon + !
	callback@ button@ MenuButton_callback + !

	button@ MenuButtonList@ ListInsert
end

procedure MenuDrawRectangle (* color w h x y -- *)
	MenuScreenNode@ DeviceSelectNode
		"rectangle" DCallMethod drop
	DeviceExit
end

const MenuButtonShade 5

procedure MenuDrawButton (* icon x y -- *)
	auto y
	y!

	auto x
	x!

	auto icon
	icon!

	auto i
	MenuButtonShade i!
	while (i@ 0 >)
		20 70 70 x@ i@ + 1 + y@ i@ + MenuDrawRectangle
		25 70 70 x@ i@ + y@ i@ + MenuDrawRectangle

		i@ 1 - i!
	end

	24 70 70 x@ 1 + y@ 1 + MenuDrawRectangle
	26 71 71 x@ y@ MenuDrawRectangle

	icon@ x@ 1 + y@ 1 + MenuDrawButtonIcon
end

procedure MenuVsyncCallback (* -- *)
	if (MenuActive@ MenuModified@ &&)
		MenuCursorOldX@ MenuCursorOldY@ MenuClearCursor
		MenuCursorX@ MenuCursorY@ MenuDrawCursor

		MenuCursorX@ MenuCursorOldX!
		MenuCursorY@ MenuCursorOldY!

		0 MenuModified!
	end
end

procedure MenuMouseReleased (* detail -- *)
	if (1 ==)
		1 MenuMouseR!
	end
end

procedure MenuMouseMoved (* detail -- *)
	auto detail
	detail!

	auto y
	detail@ 0xFFFF & y!

	auto x
	detail@ 16 >> x!

	auto uv

	if (x@ 0x8000 & 0x8000 ~=)
		MenuCursorX@ x@ + MenuCursorX!
		if (MenuCursorX@ MenuCursorWidth + MenuGWidth@ >=)
			MenuGWidth@ MenuCursorWidth 1 - - MenuCursorX!
		end
	end else
		x@ 0x7FFF & uv!
		if (uv@ MenuCursorX@ >=)
			0 MenuCursorX!
		end else
			MenuCursorX@ uv@ - MenuCursorX!
		end
	end

	if (y@ 0x8000 & 0x8000 ~=)
		MenuCursorY@ y@ + MenuCursorY!

		if (MenuCursorY@ MenuCursorHeight + MenuGHeight@ >=)
			MenuGHeight@ MenuCursorHeight - 1 - MenuCursorY!
		end
	end else
		y@ 0x7FFF & uv!
		if (uv@ MenuCursorY@ >=)
			0 MenuCursorY!
		end else
			MenuCursorY@ uv@ - MenuCursorY!
		end
	end

	1 MenuModified!
end

procedure MenuMouseCallback (* detail event -- *)
	auto event
	event!

	auto detail
	detail!

	if (MenuActive@ ~~) return end

	if (event@ 3 ==) (* moved *)
		detail@ MenuMouseMoved
	end else if (event@ 2 ==) (* released *)
		detail@ MenuMouseReleased
	end end
end

procedure MenuDrawButtonIcon (* icon x y -- *)
	auto y
	y!

	auto x
	x!

	auto ptr
	ptr!

	auto fbp
	MenuFramebuffer@ y@ MenuGWidth@ * + x@ + fbp!

	fbp@ ptr@ MenuGWidth@ asm "

	push r5
	push r6

	;scratch: r2, r5

	;menugwidth - r6
	;ptr - r4
	;fbp - r3

	;row - r0
	;col - r1

	call _POP
	mov r6, r0

	call _POP
	mov r4, r0

	call _POP
	mov r3, r0

	li r0, 0

	.rowloop:
		cmpi r0, 68
		bge .rlo

		li r1, 0

		.colloop:
			cmpi r1, 68
			bge .clo

			add r5, r3, r1
			lrr.b r2, r4
			srr.b r5, r2

			addi r4, r4, 1
			addi r1, r1, 1
			b .colloop

		.clo:

		add r3, r3, r6
		addi r0, r0, 1
		b .rowloop

	.rlo:

	pop r6
	pop r5

	"
end

(* these loops have to be in asm cuz the dragonfruit compiler sucks
and it cant run at 60fps otherwise *)

procedure MenuClearCursor (* x y -- *)
	auto y
	y!

	auto x
	x!

	auto ptr
	MenuCurBackBuf@ ptr!

	auto fbp
	MenuFramebuffer@ y@ MenuGWidth@ * + x@ + fbp!

	fbp@ ptr@ MenuGWidth@ asm "

	push r5
	push r6

	;scratch: r2, r5

	;menugwidth - r6
	;ptr - r4
	;fbp - r3

	;row - r0
	;col - r1

	call _POP
	mov r6, r0

	call _POP
	mov r4, r0

	call _POP
	mov r3, r0

	li r0, 0

	.rowloop:
		cmpi r0, MenuCursorHeight
		bge .rlo

		li r1, 0

		.colloop:
			cmpi r1, MenuCursorWidth
			bge .clo

			lrr.b r2, r4
			add r5, r3, r1
			srr.b r5, r2

			addi r4, r4, 1
			addi r1, r1, 1
			b .colloop

		.clo:

		add r3, r3, r6
		addi r0, r0, 1
		b .rowloop

	.rlo:

	pop r6
	pop r5

	"
end

procedure MenuFillBackBuf (* -- *)
	auto ptr
	MenuCurBackBuf@ ptr!

	auto x
	MenuCursorX@ x!

	auto y
	MenuCursorY@ y!

	auto row
	0 row!

	auto fbp
	MenuFramebuffer@ y@ MenuGWidth@ * + x@ + fbp!

	fbp@ ptr@ MenuGWidth@ asm "

	push r5
	push r6

	;scratch: r2, r5

	;menugwidth - r6
	;ptr - r4
	;fbp - r3

	;row - r0
	;col - r1

	call _POP
	mov r6, r0

	call _POP
	mov r4, r0

	call _POP
	mov r3, r0

	li r0, 0

	.rowloop:
		cmpi r0, MenuCursorHeight
		bge .rlo

		li r1, 0

		.colloop:
			cmpi r1, MenuCursorWidth
			bge .clo

			add r2, r3, r1
			lrr.b r5, r2
			srr.b r4, r5

			addi r4, r4, 1
			addi r1, r1, 1
			b .colloop

		.clo:

		add r3, r3, r6
		addi r0, r0, 1
		b .rowloop

	.rlo:

	pop r6
	pop r5

	"
end

procedure MenuDrawCursor (* x y -- *)
	auto y
	y!

	auto x
	x!

	MenuFillBackBuf

	auto ptr
	pointerof MenuCursorBMP ptr!

	auto row
	0 row!

	auto fbp
	MenuFramebuffer@ y@ MenuGWidth@ * + x@ + fbp!

	fbp@ ptr@ MenuGWidth@ asm "

	push r5
	push r6
	push r7

	;scratch: r2, r5

	;menugwidth - r6
	;ptr - r4
	;fbp - r3

	;row - r0
	;col - r1

	call _POP
	mov r6, r0

	call _POP
	mov r4, r0

	call _POP
	mov r3, r0

	li r0, 0

	.rowloop:
		cmpi r0, MenuCursorHeight
		bge .rlo

		li r1, 0

		.colloop:
			cmpi r1, MenuCursorWidth
			bge .clo

			lrr.b r7, r4
			cmpi r7, 0
			be .colcont

			add r2, r3, r1
			srr.b r2, r7

			.colcont:

			addi r4, r4, 1
			addi r1, r1, 1
			b .colloop

		.clo:

		add r3, r3, r6
		addi r0, r0, 1
		b .rowloop

	.rlo:

	pop r7
	pop r6
	pop r5

	"
end





