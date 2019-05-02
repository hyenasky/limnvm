(* ported from AISIX *)

var KHeapStart 0x22000
var KHeapSize 0xDDFFF

struct KHeapHeader
	4 size
	4 last
	4 next
	4 allocby
	1 allocated
endstruct

procedure HeapInit (* -- *)
	KHeapSize@ KHeapStart@ KHeapHeader_size + !
	0 KHeapStart@ KHeapHeader_last + !
	0 KHeapStart@ KHeapHeader_allocated + !
end

procedure HeapDump (* -- *)
	auto ept
	KHeapStart@ ept!

	auto max
	KHeapStart@ KHeapSize@ + max!

	auto tfree
	0 tfree!

	auto talloc
	0 talloc!

	auto i
	0 i!

	auto stotal
	0 stotal!

	while (ept@ max@ <)
		auto size
		ept@ KHeapHeader_size + @ size!

		auto asz
		size@ KHeapHeader_SIZEOF - asz!

		auto alloc
		ept@ KHeapHeader_allocated + gb alloc!

		auto last
		ept@ KHeapHeader_last + @ last!

		auto allocby
		ept@ KHeapHeader_allocby + @ allocby!

		i@ "block %d:\n" Printf
		ept@ "	ptr: 0x%x\n" Printf
		size@ "	size: %d bytes\n" Printf
		asz@ "	real size: %d bytes\n" Printf
		last@ "	last: 0x%x\n" Printf
		alloc@ "	allocated: %d\n" Printf
		allocby@ "	allocated by: 0x%x\n" Printf

		if (alloc@ 1 ==)
			talloc@ size@ + talloc!
		end else
			tfree@ size@ + tfree!
		end

		if (size@ 0 ==)
			"size 0, very weird, breaking\n" Printf
			break
		end

		stotal@ size@ + stotal!
		ept@ size@ + ept!
		i@ 1 + i!
	end

	tfree@ talloc@ stotal@ "heap size: 0x%x bytes.\n%d bytes taken, %d bytes free.\n" Printf
end

(* first-fit *)

procedure DMalloc (* cp sz -- ptr *)
	auto rs
	InterruptDisable rs!

	auto sz
	sz!

	auto cp
	cp!

	if (sz@ 0 ==)
		ERR rs@ InterruptRestore return
	end

	auto big
	sz@ KHeapHeader_SIZEOF + 1 - big!

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
					cp@ ept@ KHeapHeader_allocby + !
					ept@ KHeapHeader_SIZEOF +

					rs@ InterruptRestore

					return
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
				cp@ ept@ KHeapHeader_allocby + !
				ept@ KHeapHeader_SIZEOF +

				rs@ InterruptRestore

				return
			end
		end

		ept@ size@ + ept!
	end

	rs@ InterruptRestore

	HeapDump
	asm "

	.db 0xF2

	"
	"wow it happened\n" Printf
	asm "hlt"

	ERR return (* no space big enough *)
end

procedure Malloc (* sz -- ptr *)
	auto sz
	sz!

	asm "

	pop r0
	pushv r5, r0

	"

	auto cp
	cp!

	auto ptr

	cp@ sz@ DMalloc ptr!

	cp@ asm "

	popv r5, r0
	push r0

	"

	ptr@
end

procedure Calloc (* sz -- ptr *)
	auto sz
	sz!

	asm "

	pop r0
	pushv r5, r0

	"

	auto cp
	cp!

	auto he

	cp@ sz@ DMalloc he!

	if (he@ ERR ==)
		ERR return
	end

	he@ sz@ 0 memset

	cp@ asm "

	popv r5, r0
	push r0

	"

	he@
end

procedure HeapMerge (* ptr msize -- *)
	auto rs
	InterruptDisable rs!

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

			last@ ptr!
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
		end
	end

	rs@ InterruptRestore
end

procedure Free (* ptr -- *)
	auto rs
	InterruptDisable rs!

	auto ptr
	ptr!

	if (ptr@ 0 == ptr@ ERR == ||)
		ptr@ "tried to free 0x%x!\n" Printf
	end

	auto nptr
	ptr@ KHeapHeader_SIZEOF - nptr!

	0 nptr@ KHeapHeader_allocated + sb

	auto msize
	nptr@ KHeapHeader_size + @ msize!

	nptr@ msize@ HeapMerge

	rs@ InterruptRestore
end