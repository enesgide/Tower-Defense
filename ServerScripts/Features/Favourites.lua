local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

local rE = RS:WaitForChild("RE")

rE.ReadjustFavDefenders.OnServerEvent:Connect(function(plr, dict)
	if dict then
		local folder = plr:FindFirstChild("FavouriteDefenders")
		if folder and #folder:GetChildren() <= 9 then --update limit if adding products
			folder:ClearAllChildren()
			for _,tbl in pairs(dict) do
				local name = tbl.name
				if name then
					local val = Instance.new("IntValue")
					val.Name = name
					val.Value = tbl.slot
					val.Parent = folder
				end			
			end
		end
	end
end)