local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local mods = RS:WaitForChild("Mods")
local other = RS:WaitForChild("Other")
local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")

local pathStats = require(mods.PathStats)

local exemptBlocks = {"Start", "1", "Last", "Finish"}

--
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {workspace.Blocks}
--

local module = {}

module.checkPath = function(plr, checkForTowers, mainFloor, start, finish, pathTable, nodesTable)
	--print("\n------------------")
	if not nodesTable then
		rE.ClientErrorMessage:FireClient(plr, "No nodes table found")
		return
	end
	if not pathTable then
		rE.ClientErrorMessage:FireClient(plr, "No paths table found")
		return
	end
	if #nodesTable > 40 or #pathTable > 40 then
		rE.ClientErrorMessage:FireClient(plr, string.format("Too many parts in path (%s, %s)", #nodesTable, #pathTable))
		return
	end

	local smallZ, bigZ = mainFloor.Position.Z - mainFloor.Size.Z/2 + 3, mainFloor.Position.Z + mainFloor.Size.Z/2 - 3
	local smallX, bigX = start.Connector.WorldPosition.X, finish.Connector.WorldPosition.X
	if smallX > bigX then
		local temp = bigX
		bigX = smallX
		smallX = temp
	end
	smallX -= 2.5
	bigX += 2.5
	smallZ -= 2.5
	bigZ += 2.5

	for _, p in pairs(pathTable) do
		local cframes = {p.CFrame * CFrame.new(0,0,p.Size.Z/2), p.CFrame * CFrame.new(0,0,-1*p.Size.Z/2)}
		for _, cf in pairs(cframes) do
			local pos = cf.Position

			--[[local abc = Instance.new("Part")
			abc.Material = Enum.Material.Neon
			abc.Size = Vector3.new(1,5,1)
			abc.Position = pos
			abc.Anchored = true
			abc.Parent = workspace]]--

			--warn(p.Name)
			--print(pos.X > bigX , pos.X < smallX , pos.Z > bigZ , pos.Z < smallZ , pos.Y < mainFloor.Position.Y)
			--print(pos.X, bigX)
			--print(pos.Z, bigZ)
			if pos.X > bigX or pos.X < smallX or pos.Z > bigZ or pos.Z < smallZ or pos.Y < mainFloor.Position.Y then
				rE.ClientErrorMessage:FireClient(plr, "Path position out of bounds")
				--abc.BrickColor = BrickColor.new("Bright red")
				return false
			end
			if checkForTowers then
				local overlap_results = workspace:GetPartsInPart(p, overlapParams)
				if overlap_results and #overlap_results > 0 then			
					for i,v in pairs(overlap_results) do
						if v.Name ~= "Range" and v.Name ~= "PathBoundary" then	
							rE.ClientErrorMessage:FireClient(plr, "Move towers that are blocking the path")
							return false
						end						
					end
				end
			end
		end		
	end
	for _, n in pairs(nodesTable) do
		local pos = n.Position
		if pos.X > bigX or pos.X < smallX or pos.Z > bigZ or pos.Z < smallZ or pos.Y < mainFloor.Position.Y then
			--[[warn(n.Name)
			print(pos.X > bigX , pos.X < smallX , pos.Z > bigZ , pos.Z < smallZ , pos.Y < mainFloor.Position.Y)
			print(pos)
			print(smallX, bigX)
			print(mainFloor.Position.Y)
			print(smallZ, bigZ)]]--
			rE.ClientErrorMessage:FireClient(plr, "Path node position out of bounds")
			return false
		end
	end

	local count = #nodesTable
	local nodesCheck = {}
	for i = 1, #nodesTable do
		table.insert(nodesCheck, tostring(i+1))
	end	
	--print("Count", #nodesCheck)
	--print(nodesCheck)
	for _, n in pairs(nodesTable) do
		local i = table.find(nodesCheck, n.Name)
		if i then
			table.remove(nodesCheck, i)
		else
			rE.ClientErrorMessage:FireClient(plr, "Path node count error")
			return false
		end
	end
	
	--print("Remainder", #nodesCheck)
	--print(nodesCheck)

	return true
end

module.checkExistingValid = function(plr, map)
	local pathData = {}
	local mapFloors = map:FindFirstChild("Floors")
	local mapPaths = map:FindFirstChild("PathVisible")
	local mapNodes = map:FindFirstChild("Path")
	if not mapPaths or not mapNodes then 
		return 
	end
	
	local mainFloor = mapFloors:FindFirstChild("Prim")
	local nodeStart = mapNodes:FindFirstChild("Start")
	local pathStart = mapPaths:FindFirstChild("Start")
	local pathFinish = mapPaths:FindFirstChild("Finish")
	if not (nodeStart and pathStart and pathFinish) then return end
	
	local pathsTable = {}
	local nodesTable = {}
	
	for i,p in pairs(mapPaths:GetChildren()) do
		if not table.find(exemptBlocks, p.Name) then
			local n = mapNodes:FindFirstChild(p.Name)
			if n then
				local posVec = p.Position-pathStart.Position
				local nPosVec = n.Position-nodeStart.Position
				local data = {
					name = p.Name,
					pos = {x = posVec.X, y = posVec.Y, z = posVec.Z},
					rot = {x = p.Orientation.X, y = p.Orientation.Y, z = p.Orientation.Z},
					size = {x = p.Size.X, y = p.Size.Y, z = p.Size.Z},
					node = {x = nPosVec.X, y = nPosVec.Y, z = nPosVec.Z},
				}	
				table.insert(pathData, data)
				table.insert(pathsTable, p)
				table.insert(nodesTable, n)
			end
		end
	end
	
	return module.checkPath(plr, true, mainFloor, pathStart, pathFinish, pathsTable, nodesTable)
end

return module