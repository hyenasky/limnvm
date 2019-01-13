var AHDBSpinning 0

const AHDBCmdPort 0x19
const AHDBPortA 0x1A
const AHDBPortB 0x1B

const AHDBCmdSelect 0x1
const AHDBCmdRead 0x2
const AHDBCmdWrite 0x3
const AHDBCmdInfo 0x4
const AHDBCmdPoll 0x5

struct AHDB_VDB
	16 Label
	128 PartitionTable
	4 Magic
endstruct

struct AHDB_PTE
	8 Label
	4 Blocks
	1 Status
	3 Unused
endstruct

procedure AHDBPartitions (* id -- *)
	auto id
	id!

	auto vdbuf
	4096 Malloc vdbuf!

	if (vdbuf@ 0 AHDBRead)
		if (vdbuf@ AHDB_VDB_Magic + @ 0x4E4D494C ==)
			auto i
			0 i!

			auto pc
			0 pc!

			auto offset
			1 offset!

			while (i@ 8 <)
				auto ptr
				AHDB_PTE_SIZEOF i@ * vdbuf@ + ptr!

				if (ptr@ AHDB_PTE_Status + gb 0 ~=)
					auto char
					2 Calloc char!
					'a' pc@ + char@ sb

					DeviceNew
						char@ DSetName

						id@ "id" DAddProperty
						ptr@ AHDB_PTE_Blocks + @ "blocks" DAddProperty
						offset@ "offset" DAddProperty

						pointerof AHDBRead "readBlock" DAddMethod
						pointerof AHDBWrite "writeBlock" DAddMethod
					DeviceExit

					ptr@ AHDB_PTE_Blocks + @ offset@ + offset!

					pc@ 1 + pc!
				end

				i@ 1 + i!
			end
		end
	end

	vdbuf@ Free
end

procedure BuildAHDB (* -- *)
	pointerof AHDBIntASM 0x31 InterruptRegister

	DeviceNew
		"ahdb" DSetName

		auto i
		0 i!
		while (i@ 8 <)
			auto present
			auto blocks

			i@ AHDBPoll blocks! present!

			if (present@ 1 ==)
				DeviceNew
					auto lilbuf
					5 Calloc lilbuf!
					i@ lilbuf@ itoa
					lilbuf@ DSetName

					i@ "id" DAddProperty
					blocks@ "blocks" DAddProperty
					0 "offset" DAddProperty

					pointerof AHDBRead "readBlock" DAddMethod
					pointerof AHDBWrite "writeBlock" DAddMethod

					i@ AHDBPartitions
				DeviceExit
			end

			i@ 1 + i!
		end
	DeviceExit
end

asm "

AHDBIntASM:
	pusha

	call AHDBInt

	popa
	iret

"

procedure AHDBInt (* -- *)
	auto rs
	InterruptDisable rs!

	auto event
	auto details

	AHDBInfo
	details!
	event!

	if (event@ 0 ==)
		0 AHDBSpinning!
		return
	end

	if (event@ 1 == event@ 2 == ||)
		"AHDB: device event. Resetting to avoid big problems.\n" Printf Reset
	end

	rs@ InterruptRestore
end

procedure AHDBRead (* ptr block -- ok? *)
	auto rs
	InterruptDisable rs!

	auto block
	block!

	auto ptr
	ptr!

	auto id
	"id" DGetProperty id!

	if (block@ "blocks" DGetProperty >=) rs@ InterruptRestore ERR return end

	"offset" DGetProperty block@ + block!

	1 AHDBSpinning!

	id@ AHDBSelect

	block@ AHDBPortA DCitronOutl
	ptr@ AHDBPortB DCitronOutl
	AHDBCmdRead AHDBCmdPort DCitronCommandASync

	rs@ InterruptRestore

	while (AHDBSpinning@) end
	1
end

procedure AHDBWrite (* ptr block -- ok? *)
	auto rs
	InterruptDisable rs!

	auto block
	block!

	auto ptr
	ptr!

	auto id
	"id" DGetProperty id!

	if (block@ "blocks" DGetProperty >=) rs@ InterruptRestore ERR return end

	"offset" DGetProperty block@ + block!

	1 AHDBSpinning!

	id@ AHDBSelect

	block@ AHDBPortA DCitronOutl
	ptr@ AHDBPortB DCitronOutl
	AHDBCmdWrite AHDBCmdPort DCitronCommandASync

	rs@ InterruptRestore

	while (AHDBSpinning@) end
	1
end

procedure AHDBPoll (* id -- blocks present? *)
	auto id
	id!

	auto rs
	InterruptDisable rs!

	id@ AHDBPortA DCitronOutl

	AHDBCmdPoll AHDBCmdPort DCitronCommand

	AHDBPortA DCitronInl
	AHDBPortB DCitronInl

	rs@ InterruptRestore
end

procedure AHDBInfo (* -- event details *)
	auto rs
	InterruptDisable rs!

	AHDBCmdInfo AHDBCmdPort DCitronCommand
	AHDBPortA DCitronInb
	AHDBPortB DCitronInb

	rs@ InterruptRestore
end

procedure AHDBSelect (* drive -- *)
	auto drive
	drive!

	auto rs
	InterruptDisable rs!

	drive@ AHDBPortA DCitronOutl
	AHDBCmdSelect AHDBCmdPort DCitronCommand

	rs@ InterruptRestore
end