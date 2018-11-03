(* simple interface to make partitioning etc transparent to the rest of the bootloader *)

var IDiskBD 0
var IDiskBase 0

procedure IDiskInit (* bootdev bootpartition partitiontable -- *)
	swap 4 * + @ IDiskBase!
	IDiskBD!
end

procedure IReadBlock (* block buffer -- *)
	swap
	IDiskBase@ + swap IDiskBD@ ReadBlock
end