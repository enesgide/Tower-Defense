local RS = game:GetService("ReplicatedStorage")

local mods = RS:WaitForChild("Mods")
local rE = RS:WaitForChild("RE")

local coinStats = require(mods.CoinStats)

local maxTime = 18 * 3600

rE.DailyRewards.OnServerEvent:Connect(function(plr, rewardType)
	local passes = plr:FindFirstChild("Passes")	
	local coins = plr:FindFirstChild("Coins")
	local gems = plr:FindFirstChild("Gems")
	if not (passes and coins and gems) then return end
	
	if rewardType == "Normal" then
		local lastDailyNormal = plr:FindFirstChild("LastDailyNormal")
		if not lastDailyNormal then return end

		if (os.time() - lastDailyNormal.Value < maxTime) then return end

		lastDailyNormal.Value = os.time()

		local amount = coinStats.getCoinAmount(plr)
		if passes:FindFirstChild("x2Coins") then
			amount *= 2
		end
		coins.Value += amount
		
		rE.DisplayReward:FireClient(plr, "Coins", {Amount = amount})
		
	elseif rewardType == "VIP" then
		local lastDailyVIP = plr:FindFirstChild("LastDailyVIP")
		local ownsPass = passes:FindFirstChild("VIP")
		if not (lastDailyVIP and ownsPass) then return end
		
		if (os.time() - lastDailyVIP.Value < maxTime) then return end
		
		lastDailyVIP.Value = os.time()
		
		local amount = math.random(12,15)
		if passes:FindFirstChild("x2Gems") then
			amount *= 2
		end
		gems.Value += amount
		
		rE.DisplayReward:FireClient(plr, "Gems", {Amount = amount})
		
	elseif rewardType == "PRO" then
		local lastDailyPRO = plr:FindFirstChild("LastDailyPRO")
		local ownsPass = passes:FindFirstChild("PRO")
		if not (lastDailyPRO and ownsPass) then return end
		
		if (os.time() - lastDailyPRO.Value < maxTime) then return end
		
		lastDailyPRO.Value = os.time()
		
		local amount = math.random(18,22)
		if passes:FindFirstChild("x2Gems") then
			amount *= 2
		end
		gems.Value += amount
		
		rE.DisplayReward:FireClient(plr, "Gems", {Amount = amount})
	end
	
	--rE.PlaySound:FireClient(plr, "RewardCollect") Client does it (in the playtime rewards script)
end)