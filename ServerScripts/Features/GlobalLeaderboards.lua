local RebirthsODS = game:GetService("DataStoreService"):GetOrderedDataStore("RebirthsODS1")
local KillsODS = game:GetService("DataStoreService"):GetOrderedDataStore("KillsODS1")
local PlaytimeODS = game:GetService("DataStoreService"):GetOrderedDataStore("PlaytimeODS1")
local RobuxODS = game:GetService("DataStoreService"):GetOrderedDataStore("RobuxODS1")

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local textEditor = require(RS:WaitForChild("Mods"):WaitForChild("TextEditor"))
local globalFrame = RS:WaitForChild("Guis"):WaitForChild("GlobalFrame")

local folder = workspace:WaitForChild("Global Leaderboards")

local rebirthsLB = folder:WaitForChild("Rebirths")
local rebirthsHolder = rebirthsLB:WaitForChild("Display"):WaitForChild("Gui"):WaitForChild("Holder")
local killsLB = folder:WaitForChild("Kills")
local killsHolder = killsLB:WaitForChild("Display"):WaitForChild("Gui"):WaitForChild("Holder")
local playtimeLB = folder:WaitForChild("Playtime")
local playtimeHolder = playtimeLB:WaitForChild("Display"):WaitForChild("Gui"):WaitForChild("Holder")
local robuxLB = folder:WaitForChild("Robux")
local robuxHolder = robuxLB:WaitForChild("Display"):WaitForChild("Gui"):WaitForChild("Holder")

--Rank images
rankImages = {
	[1] = {img = "rbxassetid://6769640204", colour = Color3.fromRGB(255, 255, 0)};
	[2] = {img = "rbxassetid://6769683391", colour = Color3.fromRGB(255, 255, 255)};
	[3] = {img = "rbxassetid://6769683391", colour = Color3.fromRGB(255, 112, 16)};
}
--

local resetTime = 120

local function handler(data, holder, isPlaytime)
	local Page = data:GetCurrentPage()
	for rank, data in ipairs(Page) do
		local userId = 	tonumber(data.key)
		local name
		pcall(function()
			name = Players:GetNameFromUserIdAsync(userId)
		end)
		if not name then
			name = "Loading..."
		end
		local stat = data.value
		local clonedFrame = globalFrame:Clone()
		local background = clonedFrame.Background
		if rankImages[rank] then
			--clonedFrame.Background.Image = rankImages[rank].img
			if rankImages[rank].colour then
				clonedFrame.Background.ImageColor3 = rankImages[rank].colour
			end
		end
		local plrImage, ready = Players:GetUserThumbnailAsync(userId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
		clonedFrame.Icon.Image = plrImage
		clonedFrame.Player.Text = name
		if isPlaytime then
			clonedFrame.Amount.Text = tostring(math.floor(stat/3600*10)/10).."h"
		else
			clonedFrame.Amount.Text = textEditor.Manipulate(stat, 2)
		end		
		clonedFrame.Rank.Text = rank
		clonedFrame.Parent = holder
	end	
end

local function removeFrame(holder)
	for _,v in pairs(holder:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end
end

local function pre_handler()
	local succ, err = pcall(function()
		removeFrame(rebirthsHolder)
		handler(RebirthsODS:GetSortedAsync(false, 50, 1), rebirthsHolder) --ascending order, page size, min value, max value
		removeFrame(killsHolder)
		handler(KillsODS:GetSortedAsync(false, 50, 1), killsHolder)
		removeFrame(playtimeHolder)
		handler(PlaytimeODS:GetSortedAsync(false, 50, 1), playtimeHolder, true)
		removeFrame(robuxHolder)
		handler(RobuxODS:GetSortedAsync(false, 50, 1), robuxHolder)
	end)
	if err then
		warn(err)
	end
end


 
while true do
	for i,plr in pairs(Players:GetPlayers()) do
		if plr.Name ~= "MuPower" or game.PlaceId == 7424138523 or game.PlaceId == 9391432644 then
			local userId = plr.UserId
			if userId >= 1 then
				local succ, err = pcall(function()
					RebirthsODS:SetAsync(tostring(userId), plr.leaderstats.Rebirths.Value)
					KillsODS:SetAsync(tostring(userId), plr.Kills.Value)
					PlaytimeODS:SetAsync(tostring(userId), plr.TimePlayed.Value)
					RobuxODS:SetAsync(tostring(userId), plr.RobuxSpent.Value)
				end)
				if err then
					warn(err)
				end
			end
		end
    end
    pre_handler()
	
    task.wait(resetTime)
end

--[[
local LevelsODS = game:GetService("DataStoreService"):GetOrderedDataStore("LevelsODS1")
LevelsODS:SetAsync(tostring(36679424), 1)
]]--