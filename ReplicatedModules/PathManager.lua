local path = {
	
}

path.getLengthMap = function(map)
	local path = map:WaitForChild("Path")
	local length = 0
	local prevPart
	for i = 0, #path:GetChildren() - 1 do
		local p
		if i == 0 then
			p = path:FindFirstChild("Start")
			if not p then return end
			prevPart = p
		else
			p = path:FindFirstChild(tostring(i))
			if p then
				length += (p.Position - prevPart.Position).Magnitude
				prevPart = p
			else
				p = path:FindFirstChild("Finish")
				if not p then return end
				length += (p.Position - prevPart.Position).Magnitude
				--print(length)
				return length
			end
		end
	end
end

path.getLengthArray = function(path)
	local arrayLength = 0
	for _,_ in pairs(path) do
		arrayLength += 1
	end
	
	local length = 0
	local prevPart	
	for i = 0, arrayLength - 1 do
		local p
		if i == 0 then
			p = path["Start"]
			if not p then return end
			prevPart = p
		else
			p = path[tostring(i)]
			if p then
				length += (p.Position - prevPart.Position).Magnitude
				prevPart = p
			else
				p = path["Finish"]
				if not p then return end
				length += (p.Position - prevPart.Position).Magnitude				
			end
		end
	end
	return length
end

path.getOriginalLength = function()
	return 139
end

return path