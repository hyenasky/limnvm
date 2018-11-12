local log = {}

log.v = false

function log.init(vm)
	vm.registerOpt("-verbose", function ()
		log.v = true
		return 1
	end)

	return log
end

function log.log(msg)
	if log.v then
		print(string.format("[%d] %s", os.time(), msg))
	end
end

return log