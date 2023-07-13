local module = {}

local dataStore = game:GetService("DataStoreService"):GetDataStore("UserData-1") 
local MPS = game:GetService("MarketplaceService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local mods = RS:WaitForChild("Mods")
local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")
local blockStorage = RS:WaitForChild("Blocks")

local boostsTimer = require(SSS.BoostsTimer)
local gpStats = require(mods.GamepassStats)
local rebirthStats = require(mods:WaitForChild("RebirthStats")).items
local blockStats = require(mods:WaitForChild("BlockStats"))
local blocks = workspace.Blocks

local exemptPathBlocks = {"Start", "1", "Last", "Finish"}

local function shortenVectorToString(vector, dp)
	local div = 10^dp
	local x = math.floor(vector.X*div)/div
	local y = math.floor(vector.Y*div)/div
	local z = math.floor(vector.Z*div)/div
	return string.format("(%s, %s, %s)",x,y,z)
end

module.LoadData = function(plr)	
	--Make sure all old blocks are removed
	local oldBlockFound
	repeat
		task.wait(0.1)
		oldBlockFound = false
		for i, oldBlock in pairs(blocks:GetChildren()) do
			if oldBlock:GetAttribute("Owner") == plr.UserId then
				oldBlockFound = true
				break
			end
		end
	until not oldBlockFound
	
	--Player's map
	local map = workspace["Map"..plr.UserId]
	local floors = map:WaitForChild("Floors")
	local mainFloor = floors:WaitForChild("Prim")
	
	--Create objects
	plr:SetAttribute("SaveData", false)
	plr:SetAttribute("JoinTime", os.time())
	plr:SetAttribute("LatestTime", os.time())
	plr:SetAttribute("CompletedRounds", 0)
	plr:SetAttribute("FailedRounds", 0)
	plr:SetAttribute("NoShinyCount", 0)
	plr:SetAttribute("Tag", "Player")
	
	--Event	
	local quests = Instance.new("Folder")
	quests.Name = "Quests"

	for i = 1,3 do
		local questVal = Instance.new("IntValue", quests)
		questVal.Name = "Q"..i
	end
	
	--	
	local debuffs = Instance.new("Folder", plr)
	debuffs.Name = "Debuffs"

	local halfCoins = Instance.new("IntValue")
	halfCoins.Name = "Half Coins"

	local lowerDamage = Instance.new("IntValue")
	lowerDamage.Name = "Lower Damage"

	local halfShiny = Instance.new("IntValue")
	halfShiny.Name = "Half Shiny"
	--
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	
	local codes = Instance.new("Folder")
	codes.Name = "Codes"
	
	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	
	local lastRebirthStage = Instance.new("IntValue")
	lastRebirthStage.Name = "LastRebirthStage"
	
	local lastRebirthItem = Instance.new("StringValue")
	lastRebirthItem.Name = "LastRebirthItem"
	
	local stage = Instance.new("IntValue")
	stage.Name = "Stage" 
	
	local totalStages = Instance.new("IntValue")
	totalStages.Name = "TotalStages"

	local coins = Instance.new("NumberValue")
	coins.Name = "Coins"
	
	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	
	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	
	local tags = Instance.new("Folder")
	tags.Name = "Tags"
	
	local rebirthItems = Instance.new("Folder")
	rebirthItems.Name = "RebirthItems"
	
	local placedBlocks = Instance.new("Folder")
	placedBlocks.Name = "PlacedBlocks"
	
	local pathSlots = Instance.new("Folder")
	pathSlots.Name = "PathSlots"
	
	local blocksBought = Instance.new("IntValue")
	blocksBought.Name = "BlocksBought"
	
	local timePlayed = Instance.new("IntValue")
	timePlayed.Name = "TimePlayed"
	
	local robuxSpent = Instance.new("IntValue")
	robuxSpent.Name = "RobuxSpent"
	
	local claimedRewards = Instance.new("Folder", plr)
	claimedRewards.Name = "ClaimedRewards"
	
	local lastRewardReset = Instance.new("IntValue")
	lastRewardReset.Name = "LastRewardReset"
	
	local timePlayedSinceReset = Instance.new("IntValue")
	timePlayedSinceReset.Name = "TimePlayedSinceReset"
	
	local lastDailyNormal = Instance.new("IntValue")
	lastDailyNormal.Name = "LastDailyNormal"
	
	local lastDailyVIP = Instance.new("IntValue")
	lastDailyVIP.Name = "LastDailyVIP"

	local lastDailyPRO = Instance.new("IntValue")
	lastDailyPRO.Name = "LastDailyPRO"
	
	local lastFeedback = Instance.new("IntValue", plr)
	lastFeedback.Name = "LastFeedback"
	
	local passes = Instance.new("Folder")
	passes.Name = "Passes"
	
	local favDefenders = Instance.new("Folder", plr)
	favDefenders.Name = "FavouriteDefenders"
	
	local boosts = Instance.new("Folder", plr)
	boosts.Name = "Boosts"
	
	local x2Coins = Instance.new("IntValue")
	x2Coins.Name = "x2 Coins"
	
	local x2Damage = Instance.new("IntValue")
	x2Damage.Name = "x2 Damage"
	
	local x4Shiny = Instance.new("IntValue")
	x4Shiny.Name = "x4 Shiny"
	
	--Verification
	local twitterVerified = Instance.new("BoolValue")
	twitterVerified.Name = "TwitterVerified"
	
	--Loot
	local loot = Instance.new("Folder")
	loot.Name = "Loot"
	
	local materials = Instance.new("Folder", loot)
	materials.Name = "Materials"
	
	local skins = Instance.new("Folder", loot)
	skins.Name = "Skins"
	
	--Load data
	local key = plr.UserId.."'s Data - "
	local data
	local succ, err = pcall(function()
		data = dataStore:GetAsync(key)
	end)
	
	if succ then		
		task.delay(5, function()
			if plr and plr:IsDescendantOf(Players) then
				plr:SetAttribute("SaveData", true)
			end
		end)		
	end					
	if err then
		warn(err)
	end
	
	local function createTag(name)
		if tags:FindFirstChild(name) then return end
		local t = Instance.new("BoolValue")
		t.Name = name				
		t.Parent = tags
	end
	createTag("Player")
	
	if data and data ~= "erased" then -- REMOVE ~= MUPOWER
		plr:SetAttribute("AutoPlayV3", data["AutoPlayV3"] or false)
		
		--Stats		
		coins.Value = data["Coins"] or 150
		gems.Value = data["Gems"] or 0
		rebirths.Value = data["Rebirths"] or 0 
		lastRebirthStage.Value = data["LastRebirthStage"] or 0
		lastRebirthItem.Value = data["LastRebirthItem"] or ""
		stage.Value = data["Stage"] or 1
		totalStages.Value = data["TotalStages"] or 0
		kills.Value = data["Kills"] or 0
		
		if totalStages.Value - 1 < stage.Value then
			totalStages.Value = stage.Value - 1
		end
		
		blocksBought.Value = data["BlocksBought"] or os.time()
		timePlayed.Value = data["TimePlayed"] or 0
		
		--Gems adjust
		if data["GemsAdjusted"] then
			plr:SetAttribute("GemsAdjusted", true)
		else			
			gems.Value *= 10
			plr:SetAttribute("GemsAdjusted", true)
		end
		
		--Robux
		robuxSpent.Value = data["RobuxSpent"] or 0
		
		for name,id in pairs(gpStats) do
			local s, e = pcall(function()
				if MPS:UserOwnsGamePassAsync(plr.UserId, id) then
					local bool = Instance.new("BoolValue")
					bool.Name = name
					bool.Parent = passes
					if not data["RobuxSpentPasses"] or not table.find(data["RobuxSpentPasses"], name) then
						local price = MPS:GetProductInfo(id, Enum.InfoType.GamePass).PriceInRobux
						if price then
							robuxSpent.Value += price
						end
					end
					bool.Value = true
				end
			end)
			if e then
				warn(e)
			end
		end
		
		if data["robuxSpentPasses"] then
			for _,passName in pairs(data["robuxSpentPasses"]) do
				local pass = passes:FindFirstChild(passName)
				if pass then
					pass.Value = true
				end
			end
		end		
		
		--Event

		--Quests
		local questData = data["QuestsChristmas2022"]
		if questData then
			for i, q in pairs(quests:GetChildren()) do
				q.Value = questData[q.Name][1] or 0
				q:SetAttribute("Completed", questData[q.Name][2] or false)
				q:SetAttribute("Claimed", questData[q.Name][3] or false)
				if q.Name == "Q1" then
					local collectedCanes = questData[q.Name][4]
					if collectedCanes and #collectedCanes > 0 then
						for _, caneName in pairs(collectedCanes) do
							local caneVal = Instance.new("BoolValue")
							caneVal.Name = caneName
							caneVal.Parent = q
						end
					end
				end
			end
		end		
		
		--Debuffs
		halfCoins.Value = data["Half Coins"] or 0
		lowerDamage.Value = data["Lower Damage"] or 0
		halfShiny.Value = data["Half Shiny"] or 0
		--
		
		--Daily Rewards
		lastDailyNormal.Value = data["LastDailyNormal"] or 0	
		lastDailyVIP.Value = data["LastDailyVIP"] or 0		
		lastDailyPRO.Value = data["LastDailyPRO"] or 0
		
		--Rewards
		if data["LastRewardReset"] then
			if (os.time() - data["LastRewardReset"]) >= (18*3600) then
				lastRewardReset.Value = os.time()
				timePlayedSinceReset.Value = 0
			else
				lastRewardReset.Value = data["LastRewardReset"]
				timePlayedSinceReset.Value = data["TimePlayedSinceReset"] or 0
				local claimedRewardsData = data["ClaimedRewards"]
				if claimedRewardsData then
					for _, giftName in pairs(claimedRewardsData) do
						local gift = Instance.new("BoolValue")
						gift.Name = giftName
						gift.Parent = claimedRewards
					end
				end
			end
		else
			lastRewardReset.Value = os.time()
			timePlayedSinceReset.Value = 0
		end
		
		--Verification
		twitterVerified.Value = data["TwitterVerified"] or false
		
		--Boosts
		x2Coins.Value = data["x2Coins"] or 0
		x2Damage.Value = data["x2Damage"] or 0
		x4Shiny.Value = data["x4Shiny"] or 0
		
		--Feedback
		lastFeedback.Value = data["LastFeedback"] or 0	
		
		--Misc
		plr:SetAttribute("NoShinyCount", data["NoShinyCount"] or 0)
		
		--Tags
		local tagsData = data["Tags"]
		if tagsData then
			for _, data in pairs(tagsData) do
				local name, equipped = data[1], data[2]
				local t = createTag(name)
				if equipped then
					plr:SetAttribute("Tag", name)
				end				
			end
		end
		
		local devs = {	
			36679424, --MuPower
			2913719210, --UfoHunter10
		}

		local mods = {
			776181616, --FGG_Pro
			1597026393, --Luca
			1414066290, --Chooki
		}
		
		if passes:FindFirstChild("PRO") then
			createTag("PRO")
		end
		if passes:FindFirstChild("VIP") then
			createTag("VIP")
		end
		if table.find(devs, plr.UserId) then
			createTag("Developer")
			createTag("Moderator")
			createTag("Tester")
		end
		if table.find(mods, plr.UserId) then
			createTag("Moderator")
			createTag("Tester")
		end
		if twitterVerified.Value then
			createTag("Verified")
		end
		pcall(function()
			if plr:IsInGroup(13119970) then
				createTag("Group")
			end
			if plr:GetRoleInGroup(13119970) == "Tester" then
				createTag("Tester")
			end
		end)	
		
		--Codes
		local usedCodes = data["Codes"]
		if usedCodes then
			for i,code in pairs(usedCodes) do
				local c = Instance.new("BoolValue")
				c.Name = code
				c.Parent = codes
			end
		end
		
		--Favourites
		if data["Favourites"] then
			for i,favDef in pairs(data["Favourites"]) do
				if blockStats[favDef.name] then
					local def = Instance.new("IntValue")
					def.Name = favDef.name
					def.Value = favDef.slot
					def.Parent = favDefenders
				--else
					--warn(favDef.name, "not a block item")
				end				
			end
		end	
		
		--Skins
		if data["Materials"] then
			for name, data in pairs(data["Materials"]) do
				local mat = Instance.new("IntValue", materials)
				mat.Name = data.name
				mat.Value = data.quantity
			end
		end
		
		--Rebirth items
		if data["RebirthItems"] then
			for i,reb in pairs(data["RebirthItems"]) do
				local val = Instance.new("IntValue")
				val.Name = reb.name
				val.Value = reb.quantity
				val.Parent = rebirthItems			
			end
		end	
		
		--Skins
		if data["Skins"] then
			for mythicName, mythicData in pairs(data["Skins"]) do
				local towerSkins = Instance.new("Folder", skins)
				towerSkins.Name = mythicName
				for _, skinData in pairs(mythicData) do
					local skin = Instance.new("IntValue", towerSkins)
					skin.Name = skinData.name
					skin.Value = skinData.quantity
				end
			end
		end
		
		for mythic, stat in pairs(rebirthStats) do		
			if rebirthItems:FindFirstChild(mythic) then
				local towerSkins = skins:FindFirstChild(mythic)
				if not towerSkins then
					towerSkins = Instance.new("Folder", skins)
					towerSkins.Name = mythic
				end		
				if not towerSkins:FindFirstChild("Default") then
					local skin = Instance.new("IntValue", towerSkins)
					skin.Name = "Default"
					skin.Value = 1
				end
			end
		end
		
		--Path
		local pathData = data["Path"]
		if pathData and #pathData > 0 then
			local fixedData = {}
			for _, data in pairs(pathData) do
				table.insert(fixedData,
					{						
						name = data.name,
						pos = Vector3.new(data.pos.x, data.pos.y, data.pos.z),
						rot = Vector3.new(data.rot.x, data.rot.y, data.rot.z),
						size = Vector3.new(data.size.x, data.size.y, data.size.z),
						node = Vector3.new(data.node.x, data.node.y, data.node.z),
					}
				)				
			end			
			bE.BuildPath:Fire(plr, fixedData)
		end
		
		--Path Slots
		local savedPathSlots = data["PathSlots"]
		if savedPathSlots and #savedPathSlots > 0 then
			for _, slot in pairs(savedPathSlots) do
				local pathData = slot.data
				local fixedData = {}
				
				for _, data in pairs(pathData) do
					table.insert(fixedData,
						{						
							name = data.name,
							pos = Vector3.new(data.pos.x, data.pos.y, data.pos.z),
							rot = Vector3.new(data.rot.x, data.rot.y, data.rot.z),
							size = Vector3.new(data.size.x, data.size.y, data.size.z),
							node = Vector3.new(data.node.x, data.node.y, data.node.z),
						}
					)				
				end	
				
				local slotFolder = bE.BuildPathUnparented:Invoke(plr, slot.name, fixedData)
				if slotFolder then
					slotFolder.Parent = pathSlots
				end
			end
		end
		
		--Defenders
		if data["Defenders"] then
			for i,def in pairs(data["Defenders"]) do
				local block
				if def.shiny then
					block = blockStorage:FindFirstChild(def.name.."Shiny")				
				end
				if not block then
					block = blockStorage:FindFirstChild(def.name)
				end
				if block then	
					if block:IsA("Folder") then
						block = block:FindFirstChild(tostring(def.skin)) or block:FindFirstChild("Default")
					end
					
					if block then
						block = block:Clone()	
						block.Name = def.name
						
						block:SetAttribute("Owner", plr.UserId)
						block:SetAttribute("Id", def.id)
						block:SetAttribute("Skin", def.skin or "Default")
						block:SetAttribute("Level", def.level or 0)
						block:SetAttribute("Targeting", def.targeting or "First")	
						block:SetAttribute("Shiny", def.shiny or false)
						
						local stat = blockStats[block:GetAttribute("TowerName")] or rebirthStats[block:GetAttribute("TowerName")]
						if stat then
							local damage, range, rate, speed, cooldown, duration = stat.damage, stat.range, stat.rate, stat.speed, stat.cooldown, stat.duration
							
							local level = block:GetAttribute("Level")
							if not level then level = 0 end
							if level > 0 then
								damage =  math.ceil(damage *  1.2^level)
							end
							
							if def.shiny then
								block:SetAttribute("Damage", damage * 3)
							else
								block:SetAttribute("Damage", damage)
							end
							
							block:SetAttribute("Range", range)
							block:SetAttribute("Rate", rate)
							block:SetAttribute("Speed", speed)
							block:SetAttribute("Cooldown", cooldown)
							block:SetAttribute("Duration", duration)
						else
							block:SetAttribute("Damage", def.damage)
							block:SetAttribute("Range", def.range)
							block:SetAttribute("Rate", def.rate)
							block:SetAttribute("Speed", def.speed)
							block:SetAttribute("Cooldown", def.cooldown)
							block:SetAttribute("Duration", def.duration)
						end
						
						local newStart = map.Path:WaitForChild("Start").Position	
						local oldStart = Vector3.new(-14, 1.05, -45)
						local adjustmentVector = newStart - oldStart
						local pos = Vector3.new(def.x, def.y, def.z) + adjustmentVector				
						
						if not block.PrimaryPart then
							block.PrimaryPart = block.Boundary
						end
						
						pos = Vector3.new(pos.X, mainFloor.Position.Y + mainFloor.Size.Y/2 + block.Boundary.Size.X/2, pos.Z)
						block:SetPrimaryPartCFrame(CFrame.new(pos) * CFrame.Angles(0,0,math.pi/2))
						block.Boundary.Transparency = 1
						block.Range.Transparency = 1
						
						local valSaver = block:Clone()
						valSaver:ClearAllChildren()
						valSaver:SetAttribute("X", block.Boundary.Position.X)
						valSaver:SetAttribute("Y", block.Boundary.Position.Y)
						valSaver:SetAttribute("Z", block.Boundary.Position.Z)
						valSaver.Parent = placedBlocks
						
						local attributes = {"Level", "Owner", "Id", "Shiny", "Targeting", "Range", "Rate", "Speed", "Damage", "Cooldown", "Duration"}
						for i, att in pairs(attributes) do
							block:GetAttributeChangedSignal(att):Connect(function()
								valSaver:SetAttribute(att, block:GetAttribute(att))
							end)
						end
						
						block.Parent = blocks	
						bE.ScalingTowers:Fire(plr, block)
						
						if block:FindFirstChild("SpinBarrel", true) then
							for i,v in pairs(block:GetDescendants()) do
								if v.Name == "SpinBarrel" and v:IsA("BasePart") and not v.Anchored then
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
				end
			end
		end
		
		-- Settings
		local settings = {"SettingMusic", "SettingSounds", "SettingProjectiles", "SettingResults", "SettingHotkeys", 
			"SettingFavorites", "SettingAFKMode", "SettingRebirthPlacements", "SettingCoinsAdded", "SettingCoinsParticles"}
		local falseSettings = {"SettingAFKMode", "SettingCoinsAdded"}
		for i, s in pairs(settings) do
			if data[s] ~= nil then
				plr:SetAttribute(s, data[s])
			else
				if table.find(falseSettings, s) then
					plr:SetAttribute(s, false)
				else
					plr:SetAttribute(s, true)
				end				
			end
		end
		rE.LoadSettings:FireClient(plr)
		--warn("Loading projectiles:",data["SettingProjectiles"], plr:GetAttribute("SettingProjectiles"))
	else
		plr:SetAttribute("AutoPlayV3", true)
		plr:SetAttribute("Tutorial", 1)
		
		plr:SetAttribute("FirstSession", true)
		coins.Value = 175
		stage.Value = 1
		
		lastRewardReset.Value = os.time()
		
		local def = Instance.new("IntValue")
		def.Name = "Turret"
		def.Value = 1
		def.Parent = favDefenders
		
		local def = Instance.new("IntValue")
		def.Name = "Charger"
		def.Value = 2
		def.Parent = favDefenders
		
		plr:SetAttribute("SettingMusic", true)
		plr:SetAttribute("SettingSounds", true)
		plr:SetAttribute("SettingProjectiles", true)
		plr:SetAttribute("SettingResults", true)
		plr:SetAttribute("SettingHotkeys", true)
		plr:SetAttribute("SettingFavorites", true)
		plr:SetAttribute("SettingRebirthPlacements", true)
		rE.LoadSettings:FireClient(plr)
	end
	
	--Parents	
	rebirths.Parent = leaderstats
	stage.Parent = leaderstats
	loot.Parent = plr
	totalStages.Parent = plr
	leaderstats.Parent = plr
	codes.Parent = plr
	lastRebirthStage.Parent = plr
	lastRebirthItem.Parent = plr
	coins.Parent = plr	
	gems.Parent = plr
	kills.Parent = plr
	tags.Parent = plr
	rebirthItems.Parent = plr
	placedBlocks.Parent = plr
	pathSlots.Parent = plr
	blocksBought.Parent = plr
	timePlayed.Parent = plr
	robuxSpent.Parent = plr
	passes.Parent = plr
	lastDailyNormal.Parent = plr
	lastDailyVIP.Parent = plr
	lastDailyPRO.Parent = plr
	lastRewardReset.Parent = plr
	timePlayedSinceReset.Parent = plr
	
	twitterVerified.Parent = plr
	
	x2Coins.Parent = boosts
	x2Damage.Parent = boosts
	x4Shiny.Parent = boosts
	
	halfCoins.Parent = debuffs
	lowerDamage.Parent = debuffs
	halfShiny.Parent = debuffs
	
	--Events
	quests.Parent = plr
	--
	
	if data and data ~= "erased" and data["Defenders"] and #data["Defenders"] < #placedBlocks:GetChildren() then
		return
	end
	
	for i,boost in pairs(boosts:GetChildren()) do
		if boost.Value > 0 then
			coroutine.wrap(function()
				boostsTimer.AddTime(plr, boost.Name)
			end)()
		end
	end
	
	for i,debuff in pairs(debuffs:GetChildren()) do
		if debuff.Value > 0 then
			coroutine.wrap(function()
				boostsTimer.AddDebuffTime(plr, debuff.Name)
			end)()
		end
	end
	
	task.wait(1)
	
	plr:SetAttribute("DataLoaded",true)
end

local function getPathData(map, length, slotPath)	
	local pathData = {}
	
	local mapPaths = map:FindFirstChild("PathVisible") or map:FindFirstChild("Paths")
	local mapNodes = map:FindFirstChild("Path") or map:FindFirstChild("Nodes")
	if not mapPaths or not mapNodes then 
		return 
	end
	
	local pathStart = mapPaths:FindFirstChild("Start")
	local nodeStart = mapNodes:FindFirstChild("Start")
	if not (pathStart and nodeStart) then return end

	for i,p in pairs(mapPaths:GetChildren()) do
		if not table.find(exemptPathBlocks, p.Name) or slotPath then
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
				local mag = math.floor((n.Position - nodeStart.Position).Magnitude*100)/100
				if mag > length then
					return
				end
				table.insert(pathData, data)
			end
		end
	end
	
	return pathData
end

module.SaveData = function(plr)
	if plr:GetAttribute("DataLoaded") then
		local randomMapSlot = workspace.MapSlots:GetChildren()[1]
		local length = math.floor(math.sqrt(randomMapSlot.Size.X^2 + randomMapSlot.Size.Z^2)*100)/100
		
		local map = workspace["Map"..plr.UserId]
		local newStart = map.Path.Start.Position	
		local oldStart = Vector3.new(-14, 1.05, -45)
		local adjustmentVector = newStart - oldStart
		
		--Rebirth items
		local rebirthItems = {}
		for i,reb in pairs(plr.RebirthItems:GetChildren()) do
			local tempData = {
				name = reb.Name,
				quantity = reb.Value,
			}
			table.insert(rebirthItems, tempData)
		end
		
		local pathData = getPathData(map, length)
		--[[if #pathData == 0 then --Loading checks that it's > 0, this is fine to ignore here
			print("Path is not custom / too short")
			--return
		end]]--
		
		local pathSlots = {}
		for _, slot in pairs(plr.PathSlots:GetChildren()) do
			local slotData = getPathData(slot, length, true)
			if slotData then
				table.insert(pathSlots, {name = slot.Name, data = slotData})
			end
		end		
		
		--Defenders
		local defenders = {}
		for i,def in pairs(plr.PlacedBlocks:GetChildren()) do
			local defPos = Vector3.new(def:GetAttribute("X"), def:GetAttribute("Y"), def:GetAttribute("Z"))
			local mag = math.floor((defPos - newStart).Magnitude*100)/100
			if mag > length then
				--rE.ClientErrorMessage:FireClient(plr, "Problem saving data. Please rejoin the game.")
				--bE.SendAnalytic:Fire("Custom Error", "DataStore: Cannot save towers due to distance exceeding the maximum set by variable 'length'", string.format("Player: %s | Defender: %s | newStart: %s | defPos: %s | Max Length: %s vs Magnitude: %s", plr.Name, def.Name, shortenVectorToString(newStart,2), shortenVectorToString(defPos,2), length, mag), 0)
				return
			end
			local tempData = {
				--Stats
				name = def.Name,
				owner = plr.Name,
				id = def:GetAttribute("Id"),
				skin = def:GetAttribute("Skin") or "Default",
				shiny = def:GetAttribute("Shiny"),
				level = def:GetAttribute("Level"),
				targeting = def:GetAttribute("Targeting"),
				--Position
				x = def:GetAttribute("X") - adjustmentVector.X,
				y = def:GetAttribute("Y") - adjustmentVector.Y,
				z = def:GetAttribute("Z") - adjustmentVector.Z,
			}
			table.insert(defenders, tempData)
		end
		
		if #defenders < #plr.PlacedBlocks:GetChildren() then
			return
		end
		
		--Mythic Skins
		local loot = plr:FindFirstChild("Loot")
		if not loot then return end
		
		local skins = loot:FindFirstChild("Skins")
		if not skins then return end
				
		local skinsList = {}
		for _, towerFolder in pairs(skins:GetChildren()) do
			local data = {}
			for _, skin in pairs(towerFolder:GetChildren()) do
				table.insert(data, {name = skin.Name, quantity = skin.Value})
			end
			skinsList[towerFolder.Name] = data
		end
		
		--Materials
		local materials = loot:FindFirstChild("Materials")
		if not materials then return end

		local materialsList = {}
		for _, material in pairs(materials:GetChildren()) do
			table.insert(materialsList, {name = material.Name, quantity = material.Value})
		end
		
		--Favourites
		local favourites = {}
		for i,favDef in pairs(plr.FavouriteDefenders:GetChildren()) do
			table.insert(favourites, {name = favDef.Name, slot = favDef.Value})
		end	
		
		--Events
		local questData = {}
		for i, q in pairs(plr.Quests:GetChildren()) do			
			if q.Name == "Q1" then
				local collectedCanes = {}
				for _, cane in pairs(q:GetChildren()) do
					table.insert(collectedCanes, cane.Name)
				end
				questData[q.Name] = {q.Value, q:GetAttribute("Completed") or false, q:GetAttribute("Claimed") or false, collectedCanes}
			else
				questData[q.Name] = {q.Value, q:GetAttribute("Completed") or false, q:GetAttribute("Claimed") or false}
			end			
		end
		
		--Tags
		local tags = {}
		for i,tag in pairs(plr.Tags:GetChildren()) do
			local equipped = false
			if plr:GetAttribute("Tag") == tag.Name then
				equipped = true
			end
			table.insert(tags, {tag.Name, equipped})
		end
		
		--Codes
		local codes = {}
		for i,code in pairs(plr.Codes:GetChildren()) do
			table.insert(codes, code.Name)
		end
		
		--Rewards
		local claimedRewards = plr:FindFirstChild("ClaimedRewards")
		if not claimedRewards then return end
		
		local claimedRewardsList = {}
		for _, gift in pairs(claimedRewards:GetChildren()) do
			table.insert(claimedRewardsList, gift.Name)
		end
		
		--Passes
		local robuxSpentPasses = {}
		for i,pass in pairs(plr.Passes:GetChildren()) do
			if pass.Value then
				table.insert(robuxSpentPasses, pass.Name)
			end
		end
		
		local data = {
			["AutoPlayV3"] = plr:GetAttribute("AutoPlayV3");
			
			--Player data
			["Rebirths"] = plr.leaderstats.Rebirths.Value;
			["Stage"] = plr.leaderstats.Stage.Value;
			["TotalStages"] = plr.TotalStages.Value;
			["LastRebirthStage"] = plr.LastRebirthStage.Value;
			["LastRebirthItem"] = plr.LastRebirthItem.Value;
			["Kills"] = plr.Kills.Value;
			["BlocksBought"] = plr.BlocksBought.Value;
			
			--Currency
			["Coins"] = plr.Coins.Value;
			["Gems"] = plr.Gems.Value;
			["GemsAdjusted"] = plr:GetAttribute("GemsAdjusted");	
			
			--Defenders
			["RebirthItems"] = rebirthItems;
			["Defenders"] = defenders;
			["Favourites"] = favourites;
			
			--Loot
			["Skins"] = skinsList;
			["Materials"] = materialsList;
			
			--Path
			["Path"] = pathData;
			
			--PathSlots
			["PathSlots"] = pathSlots;
			
			--Daily Rewards
			["LastDailyNormal"] = plr.LastDailyNormal.Value;
			["LastDailyVIP"] = plr.LastDailyVIP.Value;
			["LastDailyPRO"] = plr.LastDailyPRO.Value;
			
			--Rewards
			["LastRewardReset"] = plr.LastRewardReset.Value;
			["ClaimedRewards"] = claimedRewardsList;
			["TimePlayedSinceReset"] = plr.TimePlayedSinceReset.Value;
			
			--Verification
			["TwitterVerified"] = plr.TwitterVerified.Value;
			
			--Boosts
			["x2Coins"] = plr.Boosts["x2 Coins"].Value;
			["x2Damage"] = plr.Boosts["x2 Damage"].Value;
			["x4Shiny"] = plr.Boosts["x4 Shiny"].Value;
			
			--Debuffs			
			["Half Coins"] = plr.Debuffs["Half Coins"].Value;
			["Lower Damage"] = plr.Debuffs["Lower Damage"].Value;
			["Half Shiny"] = plr.Debuffs["Half Shiny"].Value;
			
			--Miscellanous
			["Codes"] = codes;
			["Tags"] = tags;
			["TimePlayed"] = plr.TimePlayed.Value;
			["RobuxSpent"] = plr.RobuxSpent.Value;
			["RobuxSpentPasses"] = robuxSpentPasses;
			["LastFeedback"] = plr.LastFeedback.Value;
			["NoShinyCount"] = plr:GetAttribute("NoShinyCount") or 0;
			
			--Settings
			["SettingMusic"] = plr:GetAttribute("SettingMusic") or false;
			["SettingSounds"] = plr:GetAttribute("SettingSounds") or false;
			["SettingProjectiles"] = plr:GetAttribute("SettingProjectiles") or false;
			["SettingResults"] = plr:GetAttribute("SettingResults") or false;
			["SettingHotkeys"] = plr:GetAttribute("SettingHotkeys") or false;
			["SettingFavorites"] = plr:GetAttribute("SettingFavorites") or false;
			["SettingAFKMode"] = plr:GetAttribute("SettingAFKMode") or false;
			["SettingRebirthPlacements"] = plr:GetAttribute("SettingRebirthPlacements") or false; 
			["SettingCoinsAdded"] = plr:GetAttribute("SettingCoinsAdded") or false;
			["SettingCoinsParticles"] = plr:GetAttribute("SettingCoinsParticles") or false;	
			
			--Events
			["QuestsChristmas2022"] = questData;
		}		
		
		local key = plr.UserId.."'s Data - "	
		
		for i = 1,3 do
			local success,err = pcall(function()
				dataStore:SetAsync(key,data)
			end)
			if success then break end
			if err then warn("Error for "..plr.Name..": "..err) end
		end	
	end
end

return module