local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local mods = RS:WaitForChild("Mods")
local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")

local boostStats = require(mods.BoostStats)
local boostsTimer = require(SSS.BoostsTimer)
local monsterStages = require(SSS.MonsterStages)

local function addDebuff(plr, debuffName, customTime)
	local debuffs = plr:FindFirstChild("Debuffs")
	if debuffs then
		local boost = debuffs:FindFirstChild(debuffName)
		if boost then
			local addTime = customTime
			if addTime then
				boost.Value += addTime
				coroutine.wrap(function()
					boostsTimer.AddDebuffTime(plr, debuffName)
				end)()
				return true
			end			
		end
	end
end

local function singleBoost(plr, stat, boostName, customTime)
	if not stat then
		stat = boostStats[boostName]
	end
	
	--Instant boosts
	if boostName == "Skip Stage" then
		local ls = plr:FindFirstChild("leaderstats")
		if ls then
			local stage = ls:FindFirstChild("Stage")
			if stage and monsterStages[stage.Value] then
				bE.CancelStage:Fire(plr)
				stage.Value += 1
				return true
			end
		end
	end
	
	-- Time boosts
	local boosts = plr:FindFirstChild("Boosts")
	if boosts then
		local boost = boosts:FindFirstChild(boostName)
		if boost then
			local addTime = customTime or stat.addTime
			if addTime then
				boost.Value += addTime
				coroutine.wrap(function()
					boostsTimer.AddTime(plr, boostName)
				end)()
				return true
			end			
		end
	end
	
	return false
end

local function serverBoost(stat, boostName)
	for _, plr in pairs(Players:GetPlayers()) do
		singleBoost(plr, stat, boostName)
	end
end

local function buyBoost(plr, boostName, boostType, giftPlrName)
	local giftPlr
	if giftPlrName then
		giftPlr = Players:FindFirstChild(giftPlrName)
		if giftPlr and not giftPlr:GetAttribute("DataLoaded") then
			rE.ClientErrorMessage:FireClient(plr, string.format("Boost gift: %s not ingame or still loading.", giftPlrName))
			return
		end
		
		local ls = plr:FindFirstChild("leaderstats")
		if not ls then return end
		local rebirths = ls:FindFirstChild("Rebirths")
		local robuxSpent = plr:FindFirstChild("RobuxSpent")
		if not rebirths or not robuxSpent then return end
		if not (rebirths.Value > 0 or robuxSpent.Value > 0) then
			rE.ClientErrorMessage:FireClient(plr, "Gifting requirements: 1+ rebirth OR 1+ robux spent")
			return
		end
	end
	
	boostType = string.lower(boostType)
	local gems = plr:FindFirstChild("Gems")
	local stat = boostStats[boostName]
	if gems and stat then
		local price = stat[boostType]
		if price then
			if gems.Value >= price then
				gems.Value -= price	
				if boostType == "solo" or boostType == "gift" then
					local succ = singleBoost(giftPlr or plr, stat, boostName)
					if succ then		
						if giftPlr then
							rE.SM:FireClient(giftPlr,
								string.format("⚡ %s gifted the %s boost to you! ⭐", plr.Name, boostName),
								Enum.Font.SourceSansBold,
								Color3.fromRGB(255, 255, 0)
							)
						end
						rE.PlaySound:FireClient(plr, "PurchaseSuccess")
					else
						gems.Value += price
						rE.ClientErrorMessage:FireClient(plr, "Boost purchase failed.")
					end
				elseif boostType == "server" then
					rE.SM:FireAllClients(
						string.format("⚡ %s bought the %s boost for the whole server! ⭐", plr.Name, boostName),
						Enum.Font.SourceSansBold,
						Color3.fromRGB(255, 255, 0)
					)				
					serverBoost(stat, boostName)
					rE.PlaySound:FireClient(plr, "PurchaseSuccess")
				end
				return
			else
				rE.ClientErrorMessage:FireClient(plr, "Not enough gems")
				return
			end
		end		
	end
	
	rE.ClientErrorMessage:FireClient(plr, "Boost purchase failed. Try again.")
end

rE.BuyBoost.OnServerEvent:Connect(buyBoost)
bE.AddBoost.Event:Connect(singleBoost)
bE.AddDebuff.Event:Connect(addDebuff)