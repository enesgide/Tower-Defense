local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local mods = RS:WaitForChild("Mods")
local other = RS:WaitForChild("Other")
local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")

local pathModule = require(SSS.PathsChecker)
local pathStats = require(mods.PathStats)

--

local originalMap = SS:WaitForChild("Map"):WaitForChild("MapFolder")
local originalPathLength = 0

local originalPathBlock = other:WaitForChild("PathBlock")
local originalPathNode = other:WaitForChild("PathNode")

local exemptBlocks = {"Start", "1", "Last", "Finish"}

--

local function buildPath(plr, pathData)
	local map = workspace:FindFirstChild("Map"..plr.UserId)
	if map then
		local success = false
		local pathTable = {}
		local nodesTable = {}
		local floors = map:FindFirstChild("Floors")
		local path = map:FindFirstChild("PathVisible")
		local nodes = map:FindFirstChild("Path")
		if floors and path and nodes then			
			local mainFloor = floors:FindFirstChild("Prim")
			local pathStart = path:FindFirstChild("Start")
			local pathFinish = path:FindFirstChild("Finish")
			local nodeStart = nodes:FindFirstChild("Start")
			if mainFloor and pathStart and pathFinish and nodeStart then		
				
				for i, data in pairs(pathData) do
					if not table.find(exemptBlocks, data.name) then
						local p = originalPathBlock:Clone()
						p.Name = data.name
						p.Position = (pathStart.Position + data.pos) * Vector3.new(1,0,1) + Vector3.new(0,pathStart.Position.Y,0)
						p.Orientation = data.rot
						p.Size = data.size
						local n = originalPathNode:Clone()
						n.Name = data.name
						n.Position = nodeStart.Position + data.node

						table.insert(pathTable, p)
						table.insert(nodesTable, n)
					end
				end	
				
				if pathModule.checkPath(plr, false, mainFloor, pathStart, pathFinish, pathTable, nodesTable) then
					for i, oldP in pairs(path:GetChildren()) do
						if not table.find(exemptBlocks, oldP.Name) then
							oldP:Destroy()
						end
					end
					for i, oldN in pairs(nodes:GetChildren()) do
						if not table.find(exemptBlocks, oldN.Name) then
							oldN:Destroy()
						end
					end

					for i, p in pairs(pathTable) do
						p.Parent = path
					end
					for i, n in pairs(nodesTable) do
						n.Parent = nodes
					end
					
					local plrPathLength = pathStats.getLengthMap(map)
					--print("Original scale:", plrPathLength / originalPathLength)
					local enemySpeedMulti = 1 + ((plrPathLength / originalPathLength - 1)/2)
					--print("Adjusted scale:", enemySpeedMulti)
					enemySpeedMulti = math.floor(math.clamp(enemySpeedMulti, 1, 2)*100)/100
					--warn("Clamped scale:", enemySpeedMulti)
					
					--warn(enemySpeedMulti)
					plr:SetAttribute("EnemySpeedMultiplier", enemySpeedMulti)
					
					success = true
					rE.RealignPath:FireClient(plr)
				end
			else
				local unfoundParts = {}
				if not mainFloor then table.insert(unfoundParts, "Floor") end
				if not pathStart then table.insert(unfoundParts, "Start") end
				if not pathFinish then table.insert(unfoundParts, "Finish") end
				if not nodeStart then table.insert(unfoundParts, "NodeStart") end
				rE.ClientErrorMessage:FireClient(plr, "Could not find ".. tostring(table.concat(unfoundParts,", ")))
			end	
		end		
		
		if not success then
			rE.ClientErrorMessage:FireClient(plr, "Invalid path build attempt")
			pathTable = nil
			nodesTable = nil
		end
	end
	
	rE.ShowTowersOnPath:FireClient(plr)
end

local function buildPathUnparented(plr, mapName, pathData)
	if not (plr and pathData) then return end
	
	local map = Instance.new("Folder")
	map.Name = mapName
	
	local paths = Instance.new("Folder", map)
	paths.Name = "Paths"
	
	local nodes = Instance.new("Folder", map)
	nodes.Name = "Nodes"
	
	if paths and nodes then			
		local startIndex, finishIndex
		
		for i, data in pairs(pathData) do
			if data.name == "Start" then
				startIndex = i
			elseif data.name == "Finish" then
				finishIndex = i
			end
		end	
		if not (startIndex and finishIndex) then return end
		
		local pathStartPos = pathData[startIndex].pos
		local nodeStartPos = pathData[startIndex].node
		if not (pathStartPos and nodeStartPos) then return end
				
		for i, data in pairs(pathData) do
			local p = originalPathBlock:Clone()
			p.Name = data.name
			p.Position = (pathStartPos + data.pos) * Vector3.new(1,0,1) + Vector3.new(0,pathStartPos.Y,0)
			p.Orientation = data.rot
			p.Size = data.size
			p.Parent = paths
			local n = originalPathNode:Clone()
			n.Name = data.name
			n.Position = nodeStartPos + data.node
			n.Parent = nodes
		end	
	end
	
	return map
end

originalPathLength = pathStats.getOriginalLength()

rE.BuildPath.OnServerEvent:Connect(buildPath)
bE.BuildPath.Event:Connect(buildPath)
bE.BuildPathUnparented.OnInvoke = buildPathUnparented