(* ported from AISIX *)

var KHeapStart 0x100000
var KHeapSize 0x0FFFFF

(* kernel keap starts at 0x100000 and is the second megabyte of physical memory *)
(* we dont touch the first megabyte because antecedent will stop working *)

struct KHeapHeader
	4 size
	4 last
	4 next
	1 allocated
end-struct

procedure KHeapInit (* -- *)
	"KHeapInit\n" ACIPutString

	KHeapSize@ KHeapStart@ KHeapHeader_size + !
	KHeapStart@ KHeapStart@ KHeapHeader_last + !
	0 KHeapStart@ KHeapHeader_allocated + !

	"KHeapInit done\n" ACIPutString

	KHeapDump
end

procedure KHeapDump (* -- *)
	auto ept
	KHeapStart@ ept!

	auto max
	KHeapStart@ KHeapSize@ + max!

	auto i
	0 i!

	auto stotal
	0 stotal!

	while (ept@ max@ <)
		auto size
		ept@ KHeapHeader_size + size!

		auto alloc
		ept@ KHeapHeader_allocated + gb alloc!

		auto last
		ept@ KHeapHeader_last + @ last!

		"block " ACIPutString i@ ACIPutIntegerD ":\n" ACIPutString
		"	ptr: 0x" ACIPutString ept@ ACIPutInteger CR
		"	size: " ACIPutString size@ ACIPutIntegerD " bytes\n" ACIPutString
		"	last: 0x" ACIPutString last@ ACIPutInteger CR
		"	allocated: " ACIPutString alloc@ ACIPutInteger CR

		stotal@ size@ + stotal!
		ept@ size@ + ept!
		i@ 1 + i!
	end

	"heap size: 0x" ACIPutString stotal@ ACIPutInteger " bytes.\n" ACIPutString
end

(* first-fit *)

procedure KMalloc (* sz -- ptr *)
	auto sz
	sz!

	auto big
	sz@ KHeapHeader_size + 1 - big!

	auto ept
	KHeapStart@ ept!

	auto max
	KHeapStart@ KHeapSize@ + max!

	while (ept@ max@ <)
		auto size
		ept@ KHeapHeader_size + @ size!

		if (ept@ KHeapHeader_allocated + gb 0 ==)
			if (size@ big@ >) (* fit *)

				(*
				  do we need to split this block?
				  or is it just the right size?
				  if we need to split, but there's only enough room
				  for the header or less, then
				  don't even bother splitting.
				 *)

				 if (big@ 1 + size@ ==) (* just the right size *)
				 	ept@ KHeapHeader_allocated + 1 sb
				 	ept@ KHeapHeader_SIZEOF + return
				 end

			end
		end

		ept@ size@ + ept!
	end

	0 return (* no space big enough *)
end


























