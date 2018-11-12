(* barebones runtime lib for vnix *)

procedure _UNDERFLOW (* -- *)
	"Runtime error: Stack underflow.\n" ACIPutString
	while (1) end
end

procedure CR (* -- *)
	'\n' ACIStdPutChar
end