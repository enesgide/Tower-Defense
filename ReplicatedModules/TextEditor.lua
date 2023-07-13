local editor = {}

editor.Format = function(input,dp,round)
	if dp and type(dp) == "number" then
		local multiplier = 10^dp
		if round == "ceil" then
			input = math.ceil(input*multiplier)/multiplier
		else
			input = math.floor(input*multiplier)/multiplier
		end		
	end
	local str, str2 = tostring(input)
	if input ~= math.floor(input) and string.find(str, ".",1,true) then
		local split = string.split(str,".")
		str = split[1]
		str2 = split[2]
	end
	local len = string.len(str)
	local output = str:reverse():gsub("%d%d%d","%1,",math.ceil(len/3-1)):reverse()
	if str2 then
		output = output.."."..str2
	end
	return(output)
end

--Value manipulator
local assignments = {
	[1] = {symbol = "K", assVal = 10^3};
	[2] = {symbol = "M", assVal = 10^6};
	[3] = {symbol = "B", assVal = 10^9};
	[4] = {symbol = "T", assVal = 10^12};
	[5] = {symbol = "qd", assVal = 10^15};
	[6] = {symbol = "Qn", assVal = 10^18};
	[7] = {symbol = "Sx", assVal = 10^21};
	[8] = {symbol = "Sp", assVal = 10^24};
}

local assignmentsLength = 0
for i,v in pairs(assignments) do assignmentsLength += 1 end

editor.Manipulate = function(val,dp)
	if not dp then
		dp = 0
	end
	if val ~= math.huge then	
		val = tonumber(val)
		for i = assignmentsLength,1,-1 do
			if val >= assignments[i].assVal then
				return((math.floor((val/assignments[i].assVal)*10^dp)/10^dp)..assignments[i].symbol)
			end
		end
		return(editor.Format(val,dp))
	end
	return val
end

editor.TimeFormat = function(val)
	local timer = {}
	local hours = tostring(math.floor(val/3600))
	local minutes = tostring(math.floor((val - (hours*3600))/60))
	local seconds = tostring(math.floor(val - (hours*3600 + minutes*60)))

	for i,v in pairs({hours,minutes,seconds}) do
		if v:len() < 2 then
			v = "0"..v
		end
		table.insert(timer,v)
	end
	
	if val < 3600 then
		return(timer[2]..":"..timer[3])
	end
	
	return(timer[1]..":"..timer[2]..":"..timer[3])
end

return editor
