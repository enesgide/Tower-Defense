local httpService = game:GetService("HttpService")
local rE = game:GetService("ReplicatedStorage"):WaitForChild("RE")

local webhook = "XXX"

rE.Feedback.OnServerEvent:Connect(function(plr,msg)
	local lastFeedback = plr:FindFirstChild("LastFeedback")
	if lastFeedback and (os.time() - lastFeedback.Value) > 120 then
		if 0 < string.len(msg) and string.len(msg) <= 300 then
			lastFeedback.Value = os.time()
			local data = {
				content = msg;
				username = string.format("%s (Stage %s, Playtime: %s mins)", plr.Name, plr.leaderstats.Stage.Value, math.floor(plr.TimePlayed.Value/60*100)/100);
				avatar_url = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=420&height=420&format=png";
			}
			pcall(function()
				data = httpService:JSONEncode(data)
				httpService:PostAsync(webhook, data)
			end)
		end
	end
end)
