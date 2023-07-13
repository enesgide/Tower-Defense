local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local chatService = require(SSS:WaitForChild("ChatServiceRunner"):WaitForChild("ChatService"))

local rE = RS:WaitForChild("RE")

local devs = {	
	--36679424,
	2913719210,
}

local mods = {
	776181616,
	1597026393,
	1414066290,
}

local tagColors = {
	["Player"] = Color3.fromRGB(255, 181, 143),
	["Group"] = Color3.fromRGB(255, 193, 49),
	["Tester"] = Color3.fromRGB(0, 217, 0),
	["Verified"] = Color3.fromRGB(56, 239, 255),
	["VIP"] = Color3.fromRGB(255, 238, 0),
	["PRO"] = Color3.fromRGB(255, 134, 35),
	["Moderator"] = Color3.fromRGB(255, 79, 79),
	["Developer"] = Color3.fromRGB(26, 202, 255),
}

local function updateChatTag(speaker, plr)
	local tag = plr:GetAttribute("Tag")
	if not tag then return end

	local tagColor = tagColors[tag]
	if not tagColor then return end

	speaker = chatService:GetSpeaker(tostring(plr.Name))

	speaker:SetExtraData("NameColor", tagColor)
	speaker:SetExtraData("Tags", {{TagText = tag, TagColor = tagColor}})	
end

chatService.SpeakerAdded:Connect(function(plrName)
	local speaker = chatService:GetSpeaker(plrName)	
	local plr = Players:FindFirstChild(plrName)
	if plr then
		updateChatTag(speaker, plr)
		
		plr:GetAttributeChangedSignal("Tag"):Connect(function()
			updateChatTag(speaker, plr)
		end)
	end
end)

rE.EquipTag.OnServerEvent:Connect(function(plr, tagName)
	local plrTags = plr:FindFirstChild("Tags")
	if not plrTags then return end
	
	local foundTag = plrTags:FindFirstChild(tagName)
	if not foundTag then return end
	
	plr:SetAttribute("Tag", tagName)
end)