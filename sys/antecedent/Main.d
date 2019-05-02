procedure Main (* -- *)
	"verbose?" NVRAMGetVar dup if (0 ==)
		drop "false" "verbose?" NVRAMSetVar
		"false"
	end

	if ("true" strcmp)
		ConsoleUserOut
	end

	"auto-boot?" NVRAMGetVar dup if (0 ==)
		drop "false" "auto-boot?" NVRAMSetVar
		"false"
	end

	if ("true" strcmp)
		auto r
		AutoBoot r!
		if (r@ 1 ~=)
			ConsoleUserOut
		end
		[r@]BootErrors@ " boot: %s\n" Printf
	end

	Monitor

	LateReset
end