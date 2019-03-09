procedure Main (* -- *)
	"menu-skip?" NVRAMGetVar dup if (0 ==)
		drop "false" "menu-skip?" NVRAMSetVar
		"false"
	end

	if ("true" strcmp ~~)
		Menu
	end

	"auto-boot?" NVRAMGetVar dup if (0 ==)
		drop "false" "auto-boot?" NVRAMSetVar
		"false"
	end

	if ("true" strcmp)
		[AutoBoot]BootErrors@ " boot: %s\n" Printf
	end

	Monitor

	Reset
end