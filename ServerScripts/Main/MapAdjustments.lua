local SS = game:GetService("ServerStorage")
local map = SS:WaitForChild("Map")
local folder = map.MapFolder

if not map.PrimaryPart then
	map.PrimaryPart = folder.Floors:FindFirstChild("Prim")
end

for i,path in pairs(folder.Path:GetChildren()) do
	path.Transparency = 1
end