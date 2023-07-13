local module = {
	--Tier1
	{rewardType = "Coins", amount = 0.5, timer = 5*60}, --5 min
	{rewardType = "Coins", amount = 0.6, timer = 10*60}, --10 min
	{rewardType = "Coins", amount = 0.7, timer = 15*60}, --15 min
	{rewardType = "Gems", amount = 5, timer = 20*60}, --20 min
	
	--Tier2
	{rewardType = "Coins", amount = 1, timer = 30*60}, --30 min
	{rewardType = "Coins", amount = 1.25, timer = 40*60}, --40 min
	{rewardType = "Coins", amount = 1.5, timer = 50*60}, --50 min
	{rewardType = "Gems", amount = 10, timer = 60*60}, --60 min
	
	--Tier3 / Chests
	{rewardType = "Coins", amount = 3, timer = 80*60}, --80 min / 1 hr, 20 min
	{rewardType = "Gems", amount = 20, timer = 100*60}, --100 min / 1 hr, 40 min
	{rewardType = "Coins", amount = 5, timer = 120*60}, --120 min / 2 hr
	{rewardType = "Gems", amount = 35, timer = 180*60}, --180 min / 3 hr
}



return module