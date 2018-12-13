(* use ANTECEDENT console for boot messages *)

procedure KPutx (* nx -- *)
	ACIPutInteger
end

procedure KPutn (* n -- *)
	ACIPutIntegerD
end

procedure KPutc (* c -- *)
	ACIStdPutChar
end

procedure KGetc (* -- c *)
	ACIStdGetChar
	dup if (0xFFFF ==) drop ERR return end
end

procedure KPuts (* s -- *)
	ACIPutString
end