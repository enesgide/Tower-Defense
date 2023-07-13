local collisionParams = RaycastParams.new()
collisionParams.FilterType = Enum.RaycastFilterType.Exclude
collisionParams.FilterDescendantsInstances = {workspace.Placing, workspace.Monsters, workspace.TempBlocksServer, workspace.DebrisHolder, workspace.Spawns, workspace.MapSlots}

--

local shinyChance = 1/50

local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")
local mods = RS:WaitForChild("Mods")
local block_storage = RS:WaitForChild("Blocks")

local rebirthStats = require(mods:WaitForChild("RebirthStats")).items
local blockStats = require(mods:WaitForChild("BlockStats"))
local blocks = workspace.Blocks
local tempBlocks = workspace.TempBlocksServer

repeat 
	task.wait(0.1)
until block_storage:GetAttribute("Ready")

local function block_storage_iterate(block)
	local stat = blockStats[block:GetAttribute("TowerName")] or rebirthStats[block.Parent.Name]
	
	if string.len(block:GetAttribute("TowerName")) >= 5 then
		local suffix = string.sub(block:GetAttribute("TowerName"), string.len(block:GetAttribute("TowerName"))-4, string.len(block:GetAttribute("TowerName")))
		if suffix == "Shiny" then
			stat = blockStats[string.sub(block:GetAttribute("TowerName"), 1, string.len(block:GetAttribute("TowerName"))-5)]
		end
	end
	
	block:SetAttribute("Damage", stat.damage)
	block:SetAttribute("Range", stat.range)
	block:SetAttribute("Rate", stat.rate)
	block:SetAttribute("Speed", stat.speed)
	block:SetAttribute("Cooldown", stat.cooldown)
	block:SetAttribute("Duration", stat.duration)

	local rangePart = block:WaitForChild("Range")
	rangePart.Size = Vector3.new(stat.range*2,stat.range*2,stat.range*2)	
end

for _, item in pairs(block_storage:GetChildren()) do
	if item:IsA("Folder") then
		for _, def in pairs(item:GetChildren()) do
			block_storage_iterate(def)
		end
	else
		block_storage_iterate(item)
	end	
end

local function copyTable(original)
	local copy = {}
	for i,v in pairs(original) do
		table.insert(copy, v)
	end
	return copy
end

local function getBlockHeightPlacement()
	local boundarySizeY = 0.05
	local base = workspace.MapSlots:GetChildren()[1]
	return base.Position.Y + base.Size.Y/2 + boundarySizeY/2
end

local function found_collisions(plr, boundary, exceptions)
	local map = workspace:FindFirstChild("Map"..plr.UserId)
	if not map then
		return true
	end	
	
	local decor = map:FindFirstChild("Decor")
	if not decor then
		return true
	end		
	
	local tempParams = RaycastParams.new()
	tempParams.FilterType = Enum.RaycastFilterType.Exclude
	tempParams.FilterDescendantsInstances = copyTable(collisionParams.FilterDescendantsInstances)
	
	if not exceptions then
		exceptions = {}
	end
	
	for i,dec in pairs(decor:GetChildren()) do
		local boundary = dec:FindFirstChild("Boundary")
		local pathBoundary = dec:FindFirstChild("PathBoundary")
		if boundary then
			table.insert(exceptions, boundary)
		end
		if pathBoundary then
			table.insert(exceptions, pathBoundary)
		end
	end
	
	if exceptions then
		local tempFilter = tempParams.FilterDescendantsInstances
		for i,v in pairs(exceptions) do
			table.insert(tempFilter, v)
		end			
		tempParams.FilterDescendantsInstances = tempFilter
	end
	
	local char = plr.Character
	if char and not table.find(tempParams.FilterDescendantsInstances, char) then
		local newList = tempParams.FilterDescendantsInstances
		table.insert(newList, char)
		tempParams.FilterDescendantsInstances = newList
	end
	
	for i,v in pairs(blocks:GetChildren()) do
		local range = v:FindFirstChild("Range")
		if range and not table.find(tempParams.FilterDescendantsInstances, range) then
			local newList = tempParams.FilterDescendantsInstances
			table.insert(newList, range)
			tempParams.FilterDescendantsInstances = newList
		end
		local pathBoundary = v:FindFirstChild("PathBoundary")
		if pathBoundary and not table.find(tempParams.FilterDescendantsInstances, pathBoundary) then
			local newList = tempParams.FilterDescendantsInstances
			table.insert(newList, pathBoundary)
			tempParams.FilterDescendantsInstances = newList
		end
	end
	
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = collisionParams.FilterType
	overlapParams.FilterDescendantsInstances = collisionParams.FilterDescendantsInstances
	local overlap_results = workspace:GetPartsInPart(boundary, overlapParams)
	if overlap_results and #overlap_results > 0 then
		for i,v in pairs(overlap_results) do
			if v.Parent.Name == "PathVisible" or (v.Name == "Wall" and v.Parent.Name == "Environment") then		
				return true
			end
		end
	end
	
	local sin45 = 1/math.sqrt(2)
	local directionRays = {Vector3.new(0,-1,0), 
		Vector3.new(1,0,0), Vector3.new(-1,0,0), Vector3.new(0,0,1), Vector3.new(0,0,-1), 
		Vector3.new(sin45,0,sin45), Vector3.new(-sin45,0,sin45), Vector3.new(sin45,0,-sin45), Vector3.new(-sin45,0,-sin45)}
	
	for i,unit_ray in pairs(directionRays) do
		local raycast_results = workspace:Raycast(boundary.Position, unit_ray * boundary.Size.Z / 2, tempParams)
		if raycast_results then
			local target = raycast_results.Instance
			if target then
				if i ~= 1 or not target:IsDescendantOf(map) then	
					return true
				end				
			end			
		end
	end
	return false
end

local function isRebirth(name)
	if rebirthStats[name] then
		return true
	end
	return false
end

local function rebirthItemQuantityCheck(plr, block_name, rebirthItems)
	local val = rebirthItems:FindFirstChild(block_name)
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")
	if not val then return false end
	
	local placedCount = 0
	for i, block in pairs(placedBlocks:GetChildren()) do
		if block.Name == block_name then
			placedCount += 1
		end
	end
	
	--[[Count using Blocks / old version
	for i, block in pairs(blocks:GetChildren()) do
		if block.Name == block_name and block:GetAttribute("Owner") == plr.UserId then
			placedCount += 1
		end
	end]]--
	
	--warn(val.Value.." owned vs "..placedCount.." placed")
	
	if val.Value > placedCount then
		return true
	end
	
	return false
end

local function buyBlock(plr, block_name, pos, skinName)
	if not skinName then skinName = "Default" end
	
	if not pos then
		rE.ClientErrorMessage:FireClient(plr, "Block place failed: no pos found")		
		return false
	end
	pos = Vector3.new(pos.X, getBlockHeightPlacement(), pos.Z)
	
	local map = workspace:FindFirstChild("Map"..plr.UserId)
	if not map then
		rE.ClientErrorMessage:FireClient(plr, "Block place failed: no map found")	
		return false
	end	
	
	local decor = map:FindFirstChild("Decor")
	if not decor then
		rE.ClientErrorMessage:FireClient(plr, "Block place failed: no decor found")	
		return false
	end	
	
	local rebirthItems = plr:FindFirstChild("RebirthItems")
	local isRebirth = isRebirth(block_name)
	
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")
	local coins = plr:FindFirstChild("Coins")
	local stat = blockStats[block_name] or rebirthStats[block_name]
	
	if placedBlocks and coins and stat then
		if isRebirth then
			if not (rebirthItems and rebirthItemQuantityCheck(plr, block_name, rebirthItems)) then
				rE.ClientErrorMessage:FireClient(plr, "Too many copies of this item are placed")
				return false
			end
		elseif stat.price then
			if coins.Value < stat.price then
				rE.ClientErrorMessage:FireClient(plr, "Not enough coins")
				return false
			end
		else
			rE.ClientErrorMessage:FireClient(plr, "Error occurred while placing")
			return false
		end
		
		local block
		if isRebirth then
			local blockFolder = block_storage:FindFirstChild(block_name)
			if blockFolder then
				block = blockFolder:FindFirstChild(skinName)
			end
		else
			block = block_storage:FindFirstChild(block_name)
		end
		
		if block then
			local bound = block.Boundary:Clone()
			bound.CFrame = CFrame.new(pos) * CFrame.Angles(0,0,math.pi/2)
			bound.Parent = tempBlocks
			
			if found_collisions(plr, bound) then
				bound:Destroy()
				rE.ClientErrorMessage:FireClient(plr, "Too close to other parts v1")
				return false

			else		
				bound:Destroy()
				if not isRebirth then
					coins.Value -= stat.price
				end					
				
				local plrShinyChance = shinyChance
				local boosts = plr:FindFirstChild("Boosts")
				if boosts then
					local x4Shiny = boosts:FindFirstChild("x4 Shiny")
					if x4Shiny and x4Shiny.Value > 0 then
						plrShinyChance *= 4
					end
				end		
				
				local debuffs = plr:FindFirstChild("Boosts")
				if debuffs then
					local halfShiny = debuffs:FindFirstChild("Half Shiny")
					if halfShiny and halfShiny.Value > 0 then
						plrShinyChance *= 0.5
					end
				end	
				
				local shiny = (1 == math.random(1, 1/plrShinyChance))	
				
				if isRebirth then 
					shiny = false 
				else
					local noShinyCount = plr:GetAttribute("NoShinyCount")
					if not shiny and noShinyCount >= math.ceil(1/plrShinyChance) then
						shiny = true
					end

					if shiny then
						plr:SetAttribute("NoShinyCount", 0)
					else
						plr:SetAttribute("NoShinyCount", 1 + plr:GetAttribute("NoShinyCount"))
					end
				end
				
				if shiny then
					block = block_storage:FindFirstChild(block_name.."Shiny"):Clone()
					block.Name = block_name
					block:SetAttribute("Shiny", true)
					block:SetAttribute("Damage", stat.damage * 3)
					--play sparkly sfx to local player
				else
					block = block:Clone()
					block:SetAttribute("Shiny", false)
				end
				
				block.Name = block_name
				
				block:SetAttribute("Owner", plr.UserId)
				block:SetAttribute("Skin", skinName)
				block:SetAttribute("Level", 0)
				block:SetAttribute("Targeting", "First")
				block:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0,0,math.pi/2))
				block.Boundary.Transparency = 1
				block.Range.Transparency = 1

				-- PlacedBlocks vals
				local valSaver = block:Clone()
				valSaver:ClearAllChildren()
				valSaver:SetAttribute("X", block.Boundary.Position.X)
				valSaver:SetAttribute("Y", block.Boundary.Position.Y)
				valSaver:SetAttribute("Z", block.Boundary.Position.Z)
				valSaver.Parent = placedBlocks

				local attributes = {"Level", "Owner", "Id", "Shiny", "Targeting", "Range", "Rate", "Speed", "Damage"}
				for i, att in pairs(attributes) do
					valSaver:SetAttribute(att, block:GetAttribute(att))
					block:GetAttributeChangedSignal(att):Connect(function()
						valSaver:SetAttribute(att, block:GetAttribute(att))
					end)
				end
				--

				local blocksBought = plr:FindFirstChild("BlocksBought")
				if blocksBought then
					local id = blocksBought.Value
					if isRebirth then
						local takenIds = {}
						for i,v in pairs(placedBlocks:GetChildren()) do
							if v.Name == block.Name then
								local currId = v:GetAttribute("Id")
								table.insert(takenIds, currId)
							end
						end
						
						local filteredName
						local count = 1
						while true do
							filteredName = block.Name:gsub('%p+',''):gsub('%s+','')
							id = filteredName..count
							if not table.find(takenIds, id) then
								break
							end
							if count % 10 == 0 then
								task.wait()
							end
							count += 1
						end	
					end
					blocksBought.Value += 1
					plr:SetAttribute("BlocksBought",id)
					block:SetAttribute("Id",id)											
					block.Parent = blocks
					
					if block:FindFirstChild("SpinBarrel", true) then
						for i,v in pairs(block:GetDescendants()) do
							if v:IsA("BasePart") and v.Name == "SpinBarrel" and not v.Anchored then
								v:SetNetworkOwner(plr)
							end
						end
					end	
					if block:FindFirstChild("HingeConstraint", true) then
						for i,v in pairs(block:GetDescendants()) do
							if v:IsA("BasePart") and v.Name ~= "SpinBarrel" and v:FindFirstChild("HingeConstraint") and not v.Anchored then
								v:SetNetworkOwner(plr)
							end
						end
					end
				end		
				
				if not plr:GetAttribute("BlocksPlacedThisSession") or plr:GetAttribute("BlocksPlacedThisSession") == 0 then
					plr:SetAttribute("BlocksPlacedThisSession", 1)
				end
				
				return block
			end
		end
		
	end
	return false
end

local function upgradeBlock(plr, id)
	for i,block in pairs(blocks:GetChildren()) do
		if block:GetAttribute("Id") == id and block:GetAttribute("Owner") == plr.UserId then
			local coins = plr:FindFirstChild("Coins")
			local stat = blockStats[block.Name]
			local level = block:GetAttribute("Level")
			if coins and stat and level < 3 then
				local price = math.ceil(stat.price / 4 * (level + 1))
				if coins.Value >= price then
					local newLevel = level + 1
					block:SetAttribute("Level", newLevel)
					if block:GetAttribute("Shiny") then
						block:SetAttribute("Damage", math.ceil(stat.damage *  1.2^newLevel) * 3)
					else
						block:SetAttribute("Damage", math.ceil(stat.damage *  1.2^newLevel))
					end
					
					coins.Value -= price
					
					rE.ScalingTowers:FireClient(plr)
					
					return true
				else
					return false, true
				end				
			end				
		end
	end
	return false
end

local function findPlacedBlockVal(placedBlocks, id)
	for i, v in pairs(placedBlocks:GetChildren()) do
		if v:GetAttribute("Id") == id then
			return v
		end
	end
	return nil
end

local function sellBlock(plr, id)
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")
	if not placedBlocks then
		return false
	end
	
	for i,block in pairs(blocks:GetChildren()) do
		if block:GetAttribute("Id") == id and block:GetAttribute("Owner") == plr.UserId then
			if isRebirth(block.Name) then				
				local placedVal = findPlacedBlockVal(placedBlocks, id)
				if placedVal then
					block:Destroy()
					placedVal:Destroy()
				end		
				return true
			end
			
			local level = block:GetAttribute("Level")
			if not level then level = 0 end
			local coins = plr:FindFirstChild("Coins")
			local stat = blockStats[block.Name]
			if coins and stat then
				local amount = math.ceil(stat.price / 2  * 1.2^level)
				if block:GetAttribute("Shiny") then
					amount *= 5
				end
				
				local blockCount = 0
				for i,defender in pairs(blocks:GetChildren()) do
					if defender:GetAttribute("Owner") == plr.Name or defender:GetAttribute("Owner") == plr.UserId then
						blockCount += 1
					end
					if blockCount == 2 then
						break
					end
				end
				
				local placedVal = findPlacedBlockVal(placedBlocks, id)
				if placedVal then
					if blockCount >= 2 or (coins.Value + amount) >= 100 then
						block:Destroy()
						placedVal:Destroy()
						coins.Value += amount
						return true
					else
						block:Destroy()
						placedVal:Destroy()
						coins.Value += stat.price
						return true
					end	
				end							
			end				
		end
	end
	
	return false
end

local function moveBlock(plr, block, newPos)
	if not block or not block:FindFirstChild("Boundary") then
		return
	end
	
	if block:GetAttribute("Owner") ~= plr.UserId then
		return
	end
	
	if not newPos then		
		return false
	end
	newPos = Vector3.new(newPos.X, getBlockHeightPlacement(), newPos.Z)
	
	local originalPos = block.Boundary.Position
	local id = block:GetAttribute("Id")
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")
	
	if not (id and placedBlocks) then
		return false, originalPos
	end

	local placedVal
	for i,v in pairs(placedBlocks:GetChildren()) do
		if id == v:GetAttribute("Id") then
			placedVal = v
			break
		end
	end

	if not placedVal then
		return false, originalPos
	end

	local bound = block.Boundary:Clone()
	bound.CFrame = CFrame.new(newPos) * CFrame.Angles(0,0,math.pi/2)
	bound.Parent = tempBlocks
	local collided = found_collisions(plr, bound, {block})
	bound:Destroy()
	if collided then
		bound:Destroy()
		rE.ClientErrorMessage:FireClient(plr, "Too close to other parts")
		return false, originalPos
	end
	
	block:SetPrimaryPartCFrame(CFrame.new(newPos) * CFrame.Angles(0,0,math.pi/2))
	
	placedVal:SetAttribute("X", block.Boundary.Position.X)
	placedVal:SetAttribute("Y", block.Boundary.Position.Y)
	placedVal:SetAttribute("Z", block.Boundary.Position.Z)
	
	return true, block.Boundary.Position
end

local function getBlockPosition(plr, block)
	if not block or not block:FindFirstChild("Boundary") or block:GetAttribute("Owner") ~= plr.UserId then
		return nil
	end
	
	return block.Boundary.Position
end

local function changeBlockTarget(plr, id, newTarget)
	local possibleTargets = {"First", "Closest", "Strongest", "Weakest"}
	if table.find(possibleTargets, newTarget) then
		for i,block in pairs(blocks:GetChildren()) do
			if block:GetAttribute("Id") == id and block:GetAttribute("Owner") == plr.UserId then
				block:SetAttribute("Targeting",newTarget)	
				break
			end			
		end
	end
end

rE.SellAll.OnServerEvent:Connect(function(plr)
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")
	if placedBlocks then
		for i,block in pairs(blocks:GetChildren()) do
			if block:GetAttribute("Owner") == plr.UserId then
				sellBlock(plr, block:GetAttribute("Id"))
			end
		end
		
		placedBlocks:ClearAllChildren()
	end
end)

rE.ChangeSkin.OnServerInvoke = function(plr, tower, skinName)
	if not tower then return end
	
	local name = tower.Name
	local id = tower:GetAttribute("Id")
	local boundary = tower:FindFirstChild("Boundary")
	
	if not (name and id and boundary) then return end
	
	local pos = boundary.Position
	
	sellBlock(plr, id)
	
	local skinTower = buyBlock(plr, name, pos, skinName)
	
	return skinTower
end

rE.BuyBlock.OnServerInvoke = buyBlock
rE.UpgradeBlock.OnServerInvoke = upgradeBlock
rE.SellBlock.OnServerInvoke = sellBlock
rE.MoveBlock.OnServerInvoke = moveBlock
rE.GetBlockPosition.OnServerInvoke = getBlockPosition
rE.ChangeBlockTarget.OnServerEvent:Connect(changeBlockTarget)