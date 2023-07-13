local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerStorage")

local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")
local mods = RS:WaitForChild("Mods")

local coinStats = require(mods.CoinStats)
local rewardStats = require(mods.RewardStats)

local function checkReset(plr)
	local claimedRewards = plr:FindFirstChild("ClaimedRewards")
	local lastRewardReset = plr:FindFirstChild("LastRewardReset")
	local timePlayedSinceReset = plr:FindFirstChild("TimePlayedSinceReset")	
	
	if os.time() - lastRewardReset.Value > 18*3600 then 
		lastRewardReset.Value = os.time()
		timePlayedSinceReset.Value = 0
		claimedRewards:ClearAllChildren()
	end
end

local function claim(plr, giftId)
	if not (plr and giftId) then return end
	
	local passes = plr:FindFirstChild("Passes")
	local plrCoins = plr:FindFirstChild("Coins")
	local plrGems = plr:FindFirstChild("Gems")
	if not (passes and plrCoins and plrGems) then return end
	
	local claimedRewards = plr:FindFirstChild("ClaimedRewards")
	local lastRewardReset = plr:FindFirstChild("LastRewardReset")
	local timePlayedSinceReset = plr:FindFirstChild("TimePlayedSinceReset")	
	if not (claimedRewards and lastRewardReset and timePlayedSinceReset) then return end
	
	local stat = rewardStats[giftId]	
	if not stat then return end	
	
	local prizeType, prizeAmount = stat.rewardType, stat.amount
	if not (prizeType and prizeAmount) then return end
	
	if os.time() - lastRewardReset.Value > 18*3600 then return end
	if (timePlayedSinceReset.Value + os.time() - plr:GetAttribute("LatestTime")) < stat.timer then return end
	if claimedRewards:FindFirstChild("Gift"..giftId) then return end
	
	local gift = Instance.new("BoolValue")
	gift.Name = "Gift"..giftId
	gift.Parent = claimedRewards
	
	if passes:FindFirstChild("x3Rewards") then
		prizeAmount *= 3
	end
	
	if prizeType == "Coins" then
		prizeAmount = math.ceil(prizeAmount * coinStats.getCoinAmount(plr))
		plrCoins.Value += prizeAmount
	elseif prizeType == "Gems" then
		if passes:FindFirstChild("x2Gems") then
			prizeAmount *= 2
		end
		plrGems.Value += prizeAmount
	end
	
	return prizeType, prizeAmount
end

rE.CheckRewardsReset.OnServerEvent:Connect(checkReset)
rE.ClaimReward.OnServerInvoke = claim