var AMouseDev 0
var AMouseCount 0

var AMouseCDev 0

var AMouseCallbacks 0

procedure AMouseInit (* -- *)
	DeviceNew
		"mouse" DSetName
		DevCurrent@ AMouseDev!
	DeviceExit

	ListCreate AMouseCallbacks!
end

const AMouseMID 0x4D4F5553

procedure AMousePoll (* -- *)
	auto i
	1 i!

	while (i@ 256 <)
		auto rs
		InterruptDisable rs!

		if (i@ AmanatsuPoll AMouseMID ==)
			auto hmm
			5 Calloc hmm!

			AMouseDev@ DeviceSelectNode
				DeviceNew
					AMouseCount@ hmm@ itoa

					hmm@ DSetName

					i@ "aID" DAddProperty

					if (AMouseCount@ 0 ==)
						DevCurrent@ AMouseCDev!
						pointerof AMouseInterrupt i@ AmanatsuSetInterrupt

						pointerof AMouseAddCallback "addCallback" DAddMethod
					end

					AMouseCount@ 1 + AMouseCount!
				DeviceExit
			DeviceExit
		end

		rs@ InterruptRestore

		i@ 1 + i!
	end
end

procedure AMouseAddCallback (* handler -- *)
	AMouseCallbacks@ ListInsert
end

procedure AMouseInterrupt (* -- *)
	auto id
	AMouseCDev@ DeviceSelectNode
		"aID" DGetProperty id!
	DeviceExit

	id@ AmanatsuSelectDev
	1 AmanatsuCommand

	auto event
	AmanatsuReadA event!

	auto detail
	AmanatsuReadB detail!

	auto n
	AMouseCallbacks@ ListHead n!

	while (n@ 0 ~=)
		detail@ event@ n@ ListNodeValue Call

		n@ ListNodeNext n!
	end
end