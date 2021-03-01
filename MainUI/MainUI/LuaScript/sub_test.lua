function getSequenceGroupStr( content )
	local ret = {}
	local groupStr = ""
	local subStr = ""
	local regex = "(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+          running test.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+          running test"
	
	local length = #content
	local location = 1
	while(location < length) do
		subStr = string.sub(content,location,length)
		groupStr = string.match(subStr,regex)
		if groupStr ~= "" and groupStr ~= nil then
			table.insert(ret,groupStr)
			location = #groupStr + location
		else
			break
		end
	end

	local lastGroupStr = string.sub(content,location + 1,length)
	table.insert(ret,lastGroupStr)

	return ret
end

-- getSequenceGroupStr("/Users/henry/Desktop/TM LOG/PAD FCT/FCT/DLX0522000YQ4FK1E_12-23-20-30-40_PASS/DLX0522000YQ4FK1E_J517_FCT_UUT2__12-23-20-13-29_sequencer.log")




















