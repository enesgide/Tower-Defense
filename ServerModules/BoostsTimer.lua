local MPS = game:GetService("MarketplaceService")
local RS = game:GetService("ReplicatedStorage")

local boosts = {
	["x2 Coins"] = {};
	["x2 Damage"] = {};
	["x4 Shiny"] = {};
}

local debuffs = {
	["Half Coins"] = {};
	["Lower Damage"] = {};
	["Half Shiny"] = {};
}

boosts.AddDebuffTime = function(plr, debuffName)
	local plrName = plr.Name
	local plrDebuffs = plr:FindFirstChild("Debuffs")
	local debounce = debuffs[debuffName]
	if plrDebuffs then
		local debuff = plrDebuffs:FindFirstChild(debuffName)			
		if debuff and debounce and not debounce[plrName] then
			debounce[plrName] = true
			repeat
				wait(1)
				debuff.Value -= 1
			until not plr:IsDescendantOf(game) or debuff.Value <= 0
			debounce[plrName]  = nil
		end
	end
end

boosts.AddTime = function(plr, boostName)
	local plrName = plr.Name
	local plrBoosts = plr:FindFirstChild("Boosts")
	local debounce = boosts[boostName]
	if plrBoosts then
		local boost = plrBoosts:FindFirstChild(boostName)			
		if boost and debounce and not debounce[plrName] then
			debounce[plrName] = true
			repeat
				wait(1)
				boost.Value -= 1
			until not plr:IsDescendantOf(game) or boost.Value <= 0
			debounce[plrName]  = nil
		end
	end
end

return boosts