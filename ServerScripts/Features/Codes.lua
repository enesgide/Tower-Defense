local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")
local mods = RS:WaitForChild("Mods")

local coinStats = require(mods.CoinStats)
local codeStats = require(mods.CodeStats)

local newCodesArray = codeStats.current
local codes = {}
for _,c in pairs(newCodesArray) do
	table.insert(codes, c)
end

--

local function checkPasses(passes, passName)
	if passes then
		if passes:FindFirstChild(passName) then
			return true
		end
	end
	return false
end

local function addCoins(plr, amount, mult)
	local coins = plr:FindFirstChild("Coins")
	if coins then
		if amount == "T1" then
			amount = coinStats.getCoinAmount(plr)
			if mult then
				amount *= mult
			end
		end		
		if checkPasses(plr:FindFirstChild("Passes"), "x2Coins") then
			amount *= 2
		end	
		coins.Value += amount
		rE.CodeReward:FireClient(plr, {isBoost = false, name = "Coins", amount = amount})
	end
end

local function addGems(plr, amount)
	local gems = plr:FindFirstChild("Gems")
	if gems then
		if checkPasses(plr:FindFirstChild("Passes"), "x2Gems") then
			amount *= 2
		end		
		gems.Value += amount
		rE.CodeReward:FireClient(plr, {isBoost = false, name = "Gems", amount = amount})
	end
end

local function addBoost(plr, boost_type, tier)
	local length = 15*60 --sample
	bE.BoostPurchase:Fire(plr, boost_type, tier, true)
	rE.CodeReward:FireClient(plr, {isBoost = true, name = boost_type, amount = length})
end

local function addMaterial(plr, materialName)
	bE.AddMaterial:Fire(plr, materialName)
end
--

rE.Codes.OnServerEvent:Connect(function(plr, code)
	local plrCodes = plr:FindFirstChild("Codes")
	if plrCodes and not plrCodes:FindFirstChild(code) and table.find(codes, code) then
		local codeVal = Instance.new("BoolValue", plrCodes)
		codeVal.Name = code
		--Coins
		if code == "FIRSTCODE" or code == "DISC1K" or code == "COINZ" then
			addCoins(plr, "T1")
		elseif code == "10KLIKES" then
			addCoins(plr, "T1", 2)
		--Gems
		elseif code == "PATHBUILDER" or code == "VERIFY" or code == "9FAVS" or code == "WINTER22" then
			addGems(plr, 10)
		--Materials
		elseif code == "SKINS" or code == "ACID" then
			addMaterial(plr, "Basic Skin Crate")
		elseif code == "10MPLAYS" then
			addMaterial(plr, "Rare Skin Crate")
		elseif code == "PHANTOM" then
			addMaterial(plr, "Phantom Skin Crate")
		elseif code == "SNOW" then
			addMaterial(plr, "Winter Skin Crate")
		end
	end
end)