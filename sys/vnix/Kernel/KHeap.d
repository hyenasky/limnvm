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
endstruct

procedure KHeapInit (* -- *)
	"KHeap: init\n" KPrintf

	KHeapSize@ KHeapStart@ KHeapHeader_size + !
	0 KHeapStart@ KHeapHeader_last + !
	0 KHeapStart@ KHeapHeader_allocated + !

	KHeapStart@ KHeapSize@ "KHeap: heap is %d bytes starting at 0x%x\n" KPrintf

	"KHeap: init done\n" KPrintf
end

(* for debugging *)
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
		ept@ KHeapHeader_size + @ size!

		auto alloc
		ept@ KHeapHeader_allocated + gb alloc!

		auto last
		ept@ KHeapHeader_last + @ last!

		i@ "block %d:\n" KPrintf
		ept@ "	ptr: 0x%x\n" KPrintf
		size@ "	size: %d bytes\n" KPrintf
		last@ "	last: 0x%x\n" KPrintf
		alloc@ "	allocated: %d\n" KPrintf

		stotal@ size@ + stotal!
		ept@ size@ + ept!
		i@ 1 + i!
	end

	stotal@ "heap size: 0x%x bytes.\n" KPrintf
end

(* first-fit *)

procedure KMalloc (* sz -- ptr *)
	auto sz
	sz!

	if (sz@ 0 ==)
		0 return
	end

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

				(*
				  we gotta split.
				  is it worth it?
				*)

				auto nsize
				size@ sz@ KHeapHeader_SIZEOF + - nsize!

				if (nsize@ KHeapHeader_SIZEOF >) (* worth *)
					auto nept
					sz@ KHeapHeader_SIZEOF + ept@ + nept!

					nsize@ nept@ KHeapHeader_size + !
					ept@ nept@ KHeapHeader_last + !
					0 nept@ KHeapHeader_allocated + sb

					sz@ KHeapHeader_SIZEOF + ept@ KHeapHeader_size + !
				end

				1 ept@ KHeapHeader_allocated + sb
				ept@ KHeapHeader_SIZEOF + return
			end
		end

		ept@ size@ + ept!
	end

	ERR return (* no space big enough *)
end

procedure KCalloc (* sz -- ptr *)
	auto sz
	sz!

	auto he

	sz@ KMalloc he!

	if (he@ 0 ==)
		0 return
	end

	he@ sz@ 0 memset

	he@
end

procedure KHeapMerge (* ptr msize -- *)
	auto msize
	msize!
	auto ptr
	ptr!

	auto last
	auto next
	auto ns
	auto lsize

	(* check if there are adjacent free blocks to merge into this one *)

	(* check to the left *)

	ptr@ KHeapHeader_last + @ last!

	if (last@ 0 ~=) (* we're not the first block *)
		if (last@ KHeapHeader_allocated + gb 0 ==) (* free, merge the boyo *)
			last@ KHeapHeader_size + @ lsize!

			lsize@ msize@ + ns!

			ns@ last@ KHeapHeader_size + ! (* easy as 1, 2, 3 *)

			last@ ns@ + next!
			if (next@ KHeapStart@ KHeapSize@ + <)
				last@ next@ KHeapHeader_last + ! (* next block points to last *)
			end

			last@ ns@ KHeapMerge (* recursion *)
			return
		end
	end

	(* check to the right *)

	ptr@ msize@ + next!

	if (next@ KHeapStart@ KHeapSize@ + <) (* we aren't the last block *)
		if (next@ KHeapHeader_allocated + gb 0 ==) (* free, merge the boyo *)
			next@ KHeapHeader_size + @ lsize!

			lsize@ msize@ + ns!

			ptr@ ns@ + next!
			if (next@ KHeapStart@ KHeapSize@ + <) (* next next points to us *)
				ptr@ next@ KHeapHeader_last + !
			end

			ns@ ptr@ KHeapHeader_size + ! (* set OUR size to the combined size *)

			ptr@ ns@ KHeapMerge (* recursion *)
		end
	end
end

procedure KFree (* ptr -- *)
	auto ptr
	ptr!

	auto nptr
	ptr@ KHeapHeader_SIZEOF - nptr!

	0 nptr@ KHeapHeader_allocated + sb

	auto msize
	nptr@ KHeapHeader_size + @ msize!

	nptr@ msize@ KHeapMerge
end
























