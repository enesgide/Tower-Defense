local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")

local blocks = workspace:WaitForChild("Blocks")
local mods = RS:WaitForChild("Mods")

local Rebirth = require(mods.RebirthStats)

local function checkEligibility(plr)
	local lastRebirthStage = plr:FindFirstChild("LastRebirthStage")
	local ls = plr:FindFirstChild("leaderstats")
	
	if lastRebirthStage and ls then
		local plrStage = ls:FindFirstChild("Stage")
		
		if plrStage then
			local requiredStage = Rebirth.getRebirthStage(plr)
			if plrStage.Value > requiredStage then
				return requiredStage
			end
		end
	end
	
	return false
end

local function clearBase(plr, settingRebirthPlacements)
	-- Cancel stage here & turn off autoplay
	--plr:SetAttribute("AutoPlay", nil)
	bE.CancelStage:Fire(plr, true)
	
	-- Reset base
	for i, block in pairs(blocks:GetChildren()) do
		if block:GetAttribute("Owner") == plr.UserId then
			if settingRebirthPlacements then
				if not Rebirth.items[block:GetAttribute("TowerName")] then
					block:Destroy()
				end
			else
				block:Destroy()
			end			
		end
	end
end

local function addDefaultSkin(plr, mythicName)
	local plrLoot = plr:FindFirstChild("Loot")
	if not plrLoot then return end
	
	local plrSkins = plrLoot:FindFirstChild("Skins")
	if not plrSkins then return end
	
	local towerSkins = plrSkins:FindFirstChild(mythicName)
	if not towerSkins then
		towerSkins = Instance.new("Folder")
		towerSkins.Name = mythicName
		towerSkins.Parent = plrSkins
	end
	
	local skin = towerSkins:FindFirstChild("Default")	
	if skin then return end
	
	skin = Instance.new("IntValue")
	skin.Name = "Default"
	skin.Value = 1
	skin.Parent = towerSkins
end

local function rebirthData(plr, requiredStage)
	local ls = plr:FindFirstChild("leaderstats")	
	
	if not ls then
		return false
	end
	
	local stage = ls:FindFirstChild("Stage")
	local rebirths = ls:FindFirstChild("Rebirths")
	local coins = plr:FindFirstChild("Coins")
	local lastRebirthStage = plr:FindFirstChild("LastRebirthStage")
	local rebirthItems = plr:FindFirstChild("RebirthItems")
	local lastRebirthItem = plr:FindFirstChild("LastRebirthItem")
	local placedBlocks = plr:FindFirstChild("PlacedBlocks")	
	
	if not (stage 
		and rebirths
		and coins
		and lastRebirthStage
		and rebirthItems
		and lastRebirthItem
		and placedBlocks) 
	then
		return false
	end
	
	local itemName = Rebirth.getRandomItem(plr)
	if not itemName then
		return nil
	end
	
	local val = rebirthItems:FindFirstChild(itemName)
	if val then
		val.Value += 1
	else
		val = Instance.new("IntValue")
		val.Name = itemName
		val.Value = 1
	end
	
	addDefaultSkin(plr, itemName)
	
	local settingRebirthPlacements = plr:GetAttribute("SettingRebirthPlacements")
	
	local autoplayOn = plr:GetAttribute("AutoPlay")
	--plr:SetAttribute("AutoPlay", false)	
	
	clearBase(plr, settingRebirthPlacements)
	lastRebirthStage.Value = requiredStage
	lastRebirthItem.Value = itemName
	stage.Value = 1 -- should be after the above line for the sake of updating the title in Rebirth Handler
	coins.Value = 5000
	task.delay(1, function()
		clearBase(plr, settingRebirthPlacements)
		if autoplayOn then
			--plr:SetAttribute("AutoPlay", true)
		end
	end)	
	spawn(function()
		for i = 1,50 do
			if coins.Value > 15000 then
				coins.Value = 5000
			end	
			task.wait(0.1)
		end
	end)
	rebirths.Value += 1
	if val.Parent ~= rebirthItems then
		val.Parent = rebirthItems
	end	
	if settingRebirthPlacements then
		for i,block in pairs(placedBlocks:GetChildren()) do
			if not Rebirth.items[block:GetAttribute("TowerName")] then
				block:Destroy()
			end
		end
	else
		placedBlocks:ClearAllChildren()		
	end
	
	return itemName
end

local function rebirthPlayer(plr)
	local nextStage = checkEligibility(plr)
	if not nextStage then
		rE.ClientErrorMessage:FireClient(plr, "Rebirth requirements not met")
		return nil
	end	
	
	return rebirthData(plr, nextStage)
end

rE.Rebirth.OnServerInvoke = rebirthPlayer