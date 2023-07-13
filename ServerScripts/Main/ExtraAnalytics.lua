local config = {
	DoNotReportScriptErrors = false,
	DoNotTrackServerStart = true,
	DoNotTrackVisits = true,
}

local GA = require(153590792)
GA.Init("XXX", config)

--
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")

bE.SendAnalytic.Event:Connect(function(category, action, label, value)
	--warn(action, label)
	GA.ReportEvent(category, action, label, value)
end)

rE.SER.OnServerEvent:Connect(function(plr, category, action, label, value)		
	--warn(label)
	GA.ReportEvent(category, action, label, value)	
end)

-- Testing placement progress error

rE.SetDevice.OnServerEvent:Connect(function(plr, device)
	plr:SetAttribute("Device", device)
end)

rE.SetButtonVisible.OnServerEvent:Connect(function(plr, status, size, pos, max)
	plr:SetAttribute("ButtonVisible", status)
	plr:SetAttribute("ButtonSize", size)
	plr:SetAttribute("ButtonPos", pos)
	plr:SetAttribute("ButtonMax", max)
end)


rE.SetPlacementProgress.OnServerEvent:Connect(function(plr, num)
	local oldNum = plr:GetAttribute("PlacementProgress")
	if not oldNum or num > oldNum then
		plr:SetAttribute("PlacementProgress", num)
	end
end)
