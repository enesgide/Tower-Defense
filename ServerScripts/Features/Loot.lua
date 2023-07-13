local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")
local mods = RS:WaitForChild("Mods")

local Loot = require(mods.LootStats)
local Materials = Loot.Materials
local Skins = Loot.Skins

local coinStats = require(mods.CoinStats)

-- General

local function getCrateFromRobuxPrice(price)
	if price == 80 then
		return "Basic Skin Crate"
	elseif price == 200 then
		return "Rare Skin Crate"
	elseif price == 400 then
		return "Phantom Skin Crate"
	end
end

-- Skins

local function addSkin(plr, towerName, skinName)
	local loot = plr:FindFirstChild("Loot")
	if not loot then return end
	
	local skinsFolder = loot:FindFirstChild("Skins")
	if not skinsFolder then return end
	
	local stat = Skins[towerName]
	if not stat then return end
	
	local folder = skinsFolder:FindFirstChild(towerName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = towerName
		folder.Parent = skinsFolder
	end

	local item = folder:FindFirstChild(skinName)	
	if not item then
		item = Instance.new("IntValue")
		item.Name = skinName
		item.Value = 1
		item.Parent = folder
		rE.SkinAdded:FireClient(plr, towerName, skinName)
		return
	end

	item.Value += 1	
	rE.SkinAdded:FireClient(plr, towerName, skinName)
end

local function removeSkin(plr, towerName, skinName)
	local loot = plr:FindFirstChild("Loot")
	if not loot then return end

	local skinsFolder = loot:FindFirstChild("Skins")
	if not skinsFolder then return end

	local folder = skinsFolder:FindFirstChild(towerName)
	if not folder then return end

	local item = folder:FindFirstChild(skinName)	
	if not item then return end
	
	if item.Value > 1 then
		item.Value -= 1
		return true
	else
		return rE.LootErrorMessage:FireClient(plr, "You can't sell the last skin copy")
	end
end

local function sellSkin(plr, currency, towerName, skinName)
	if not (plr and currency and towerName and skinName) then return end
	
	if skinName == "Default" then return rE.LootErrorMessage:FireClient(plr, "Default skins can't be sold") end
	
	local towerStat = Loot.Skins[towerName]
	if not towerStat then return end
	
	local skinStat = towerStat[skinName]
	if not (skinStat) then return end

	local crateName = getCrateFromRobuxPrice(skinStat.price)
	if not crateName then return end

	local crateStat = Loot.Materials[crateName]
	if not (crateStat and crateStat.coinSell and crateStat.gemSell) then return end
	
	local coins = plr:FindFirstChild("Coins")
	local gems = plr:FindFirstChild("Gems")
	if not (coins and gems) then return end
	
	local success = removeSkin(plr, towerName, skinName)
	if not success then return end
	
	if currency == "Coins" then
		coins.Value += (coinStats.getCoinAmount(plr) * crateStat.coinSell)
	elseif currency == "Gems" then
		gems.Value += crateStat.gemSell
	end
	
	rE.PlaySound:FireClient(plr, "Sell")
end

-- Materials

local function addMaterial(plr, name)
	local loot = plr:FindFirstChild("Loot")
	if not loot then return end

	local folder = loot:FindFirstChild("Materials")
	if not folder then return end

	local item = folder:FindFirstChild(name)	
	if not item then
		item = Instance.new("IntValue")
		item.Name = name
		item.Value = 1
		item.Parent = folder
		rE.MaterialAdded:FireClient(plr, name)
		return
	end

	item.Value += 1	
	rE.MaterialAdded:FireClient(plr, name)
end

local function removeMaterial(plr, name)
	local loot = plr:FindFirstChild("Loot")
	if not loot then return end

	local folder = loot:FindFirstChild("Materials")
	if not folder then return end

	local item = folder:FindFirstChild(name)
	if not item or item.Value == 0 then return end

	if item.Value == 1 then
		if Materials[name].alwaysShow then
			item.Value -= 1
		else
			item:Destroy()
		end
	else
		item.Value -= 1
	end
end

local function openMaterial(plr, materialName)	
	if not materialName then return end
	
	local loot = plr:FindFirstChild("Loot")
	if not loot then return end

	local folder = loot:FindFirstChild("Materials")
	if not folder then return end

	local owned = folder:FindFirstChild(materialName)
	if not owned or owned.Value <= 0 then
		rE.LootErrorMessage:FireClient(plr, "You do not own any "..materialName.."s")
		return 
	end

	local stat = Materials[materialName]
	if not stat then return end

	--randomly get reward here
	local rewardTowerName = nil
	local rewardSkinName = nil
	local rewardImage = nil

	if stat.materialType == "Skin Crate" then
		local choices = stat.choices
		local max = #choices
		if max <= 0 then
			rE.LootErrorMessage:FireClient(plr, "Empty crate, try again later")
			return nil
		end

		math.randomseed(tick())
		local choice = choices[math.random(1, max)]
		local towerName, skinName = choice.towerName, choice.skinName		
		local skin = Skins[towerName][skinName]
		rewardTowerName = towerName
		rewardSkinName = skinName
		rewardImage = skin.img
		
		if not rewardTowerName or not rewardSkinName then return end
		removeMaterial(plr, materialName)
		addSkin(plr, rewardTowerName, rewardSkinName)
		
		return rewardTowerName, rewardSkinName, rewardImage
	end
	
	rE.LootErrorMessage:FireClient(plr, "Could not find material type "..materialName)
	return nil
end

local function buyMaterial(plr, materialName)
	if not materialName then return end
	
	local stat = Materials[materialName]
	if not stat then return end
	
	local price = stat.price
	if not price then return end

	local loot = plr:FindFirstChild("Loot")
	if not loot then return end

	local folder = loot:FindFirstChild("Materials")
	if not folder then return end

	local gems = plr:FindFirstChild("Gems")
	if gems and gems.Value >= price then		
		addMaterial(plr, materialName)
		gems.Value -= price
		rE.PlaySound:FireClient(plr, "PurchaseSuccess")
		return
	else
		rE.ClientErrorMessage:FireClient(plr, "Not enough gems")
		rE.PlaySound:FireClient(plr, "PurchaseFailed")
	end
end

local function sellMaterial()

end

-- Events

bE.AddMaterial.Event:Connect(addMaterial)
bE.AddSkin.Event:Connect(addSkin)

rE.BuyMaterial.OnServerEvent:Connect(buyMaterial)

rE.OpenMaterial.OnServerInvoke = openMaterial

rE.SellSkinForCoins.OnServerEvent:Connect(function(plr, towerName, skinName)
	sellSkin(plr, "Coins", towerName, skinName)
end)

rE.SellSkinForGems.OnServerEvent:Connect(function(plr, towerName, skinName)
	sellSkin(plr, "Gems", towerName, skinName)
end)