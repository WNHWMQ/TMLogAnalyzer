function getSequenceGroupStr( content, match_str )

	local ret = {}
	local groupStr = ""
	local subStr = ""
	-- local regex = "(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+          running test.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+          running test"
	local regex = match_str
	
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

function getSpecialGroupStr( content, match_str, skipArr, optArr )

	local ret = {}
	local groupStr = ""
	local subStr = ""
	local ignoreStr = ""

	-- print(content)
	-- print(optArr[1],optArr[2])
	
	local length = #content
	local location = 1
	local ignoreFlag = false
	local index = 1

	while(location < length) do

		if string.match(skipArr[index],"test") then

			-- print(tostring(index) .. " :enter test")
			subStr = string.sub(content,location,length)
			groupStr = string.match(subStr,match_str)
			if groupStr ~= "" and groupStr ~= nil then

				for i=1,#optArr do
					if string.match(groupStr,optArr[i]) then
						ignoreFlag = true
					end
				end

				if ignoreFlag then
					ignoreStr = ignoreStr .. groupStr
					location = location + #ignoreStr
				else
					-- print(index,ignoreStr,groupStr)
					table.insert(ret,ignoreStr .. groupStr)
					index = index + 1
					location = location + #groupStr
					ignoreStr = ""
				end

				ignoreFlag = false
			else
				break
			end
		elseif string.match(skipArr[index],"skip") then

			-- print(tostring(index) .. " :enter skip")
			table.insert(ret,"\nSKIP\n")
			index = index + 1
		end

		if index > #skipArr then
			break
		end
	end

	if #ret == #skipArr then
		ret[#ret] = ret[#ret] .. string.sub(content,location,length)
	else
		table.insert(ret,string.sub(content,location,length))
	end

	return ret
end

function getCommonGroupStr( content, time_regex )

	-- "(%d-%/%d-%/%d- %d-%:%d-%:%d-%.%d+.-)%d-%/%d-%/%d- %d-%:%d-%:%d-%.%d+"
	local match_str = string.format("(%s.-)%s",time_regex,time_regex)

	local ret = {}
	local groupStr = ""
	local subStr = ""
	local length = #content
	local location = 1
	local sub_table = {}
	local timeTamp = ""

	while(location < length) do
			subStr = string.sub(content,location,length)
			groupStr = string.match(subStr,match_str)
			if groupStr ~= "" and groupStr ~= nil then

				timeTamp = string.match(groupStr,time_regex)
				if timeTamp ~= "" and timeTamp ~= nil then
					table.insert(sub_table,timeTamp)
					table.insert(sub_table,groupStr)
				end
				table.insert(ret,sub_table)
				location = location + #groupStr
				sub_table = {}
			else
				break
			end
	end

	lastStr = string.sub(content,location,length)
	timeTamp = string.match(lastStr,time_regex)
	if timeTamp ~= "" and timeTamp ~= nil then
		table.insert(sub_table,timeTamp)
		table.insert(sub_table,lastStr)
	else
		sub_table = {}
	end
	table.insert(ret,sub_table)



	-- for k,v in pairs(ret) do
	-- 	print("index:"..tostring(k))
	-- 	print("timeTamp:"..tostring(v[1]))
	-- 	print("value:"..tostring(v[2]))
	-- end

	return ret
end

-- local path = "/Users/henry/Desktop/TM LOG/MAC FCT/C02102200GFPY5L42_01-25-06-32-42_FAIL/C02102200GFPY5L42_J457_FCT_UUT2__01-25_06-21-19_EngineLog.log"

-- local path = "/Users/henry/Desktop/TM LOG/MAC FCT/C02102200GFPY5L42_01-25-06-32-42_FAIL/C02102200GFPY5L42_J457_FCT_UUT2__01-25-06-21-18_flow_plain.log"

-- local path = "/Users/henry/Desktop/TM LOG/MAC FCT/C02102200GFPY5L42_01-25-06-32-42_FAIL/C02102200GFPY5L42_J457_FCT_UUT2__01-25-06-21-18_sequencer.log"

-- local path = "/Users/henry/Desktop/TM LOG/PAD FCT/FCT/DLX0522000YQ4FK1E_12-23-20-30-40_PASS/DLX0522000YQ4FK1E_J517_FCT_UUT2__12-23-20-13-29_sequencer.log"

-- local path = "/Users/henry/Desktop/TM LOG/WATCH FCT/FN605052HF9Q27Q27_12-23-20-34-55_PASS/FN605052HF9Q27Q27_X2010_PREFCT2_UUT1__12-23-20-23-18_sequencer.log"

-- local path = "/Users/henry/Desktop/TM LOG/MAC FCT/C02102200GFPY5L42_01-25-06-32-42_FAIL/C02102200GFPY5L42_J457_FCT_UUT2__01-25-06-21-18_iefi.log"


-- local file = io.open(path,"r")
-- local content = file:read("*a")


-- local match_str = "(.-%d-%-%d-%-%d-%_%d-%-%d-%-%d-%-%d+%s-%< Received %>.-)%d-%-%d-%-%d-%_%d-%-%d-%-%d-%-%d+%s-%< Received %>"

-- local optArr = {"start_test","end_test"}


-- local match_str = "(.-%=%=Test%:.-)%=%=Test%:"

-- local optArr = {}


-- local match_str = "(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-running test.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%s-running test"

-- local optArr = {}

-- 2020-12-23 20:23:27.877594: Sequencer_01: {"data": {"group": "Fixture", "description"


-- local match_str = "(.-%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:.-description.-)%d-%-%d-%-%d- %d-%:%d-%:%d-%.%d+%:[^\n]-description"

-- local optArr = {}



-- local skipArr = {}

-- print(string.match(content,match_str))

-- for i=1,6708 do
-- 	table.insert(skipArr,"test")
-- end

-- getSpecialGroupStr(content,match_str,skipArr,optArr)

-- local time_regex = "%d-%/%d-%/%d- %d-%:%d-%:%d-%.%d+"

-- getCommonGroupStr(content,time_regex)



