procedure KPrintf (* ... fmt -- *)
	auto f
	f!
	auto i
	0 i!
	auto sl
	f@ strlen sl!
	while (i@ sl@ <)
		auto char
		f@ i@ + gb char!
		if (char@ '%' ~=)
			char@ KPutc
		end else
			i@ 1 + i!
			if (i@ sl@ >=)
				return
			end

			f@ i@ + gb char!

			if (char@ 'd' ==)
				KPutn
			end else

			if (char@ 'x' ==)
				KPutx
			end else

			if (char@ 's' ==)
				KPuts
			end else

			if (char@ '%' ==)
				'%' KPutc
			end else

			if (char@ 'l' ==)
				KPutc
			end

			end

			end

			end

			end
		end

		i@ 1 + i!
	end
end

procedure KPanic (* fmt -- *)
	"\nvnix PANIC: " KPrintf

	KPrintf

	"returning to firmware!\n\n" KPrintf

	ReturnToFirmware
end