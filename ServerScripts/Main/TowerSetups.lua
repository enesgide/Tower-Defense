local RS = game:GetService("ReplicatedStorage")

local mods = RS:WaitForChild("Mods")
local blocks = RS:WaitForChild("Blocks")

local rebirthStats = require(mods.RebirthStats).items
local blockStats = require(mods.BlockStats)

local function iterate(def, towerName)
	local defName = def.Name
	
	local stat = blockStats[defName] or rebirthStats[def.Parent.Name]
	if not stat then
		local suffix = string.sub(defName, string.len(defName)-4, string.len(defName))
		if suffix == "Shiny" then
			defName = string.sub(defName, 1, string.len(defName)-5)
			towerName = defName
			stat = blockStats[defName]
		end
	end
	
	def:SetAttribute("TowerName", towerName)
	
	local boundary = def:WaitForChild("Boundary")
	def.PrimaryPart = boundary

	local pathBoundary = boundary:Clone()
	pathBoundary.Name = "PathBoundary"
	pathBoundary.Size = boundary.Size + Vector3.new(0,4,4)
	pathBoundary.Color = Color3.fromRGB(255, 255, 0)
	pathBoundary.Material = Enum.Material.Plastic
	pathBoundary.Transparency = 1
	pathBoundary.CastShadow = true
	pathBoundary.Parent = def

	local model = def:FindFirstChild("Model")
	if model and model:IsA("Model") then
		local body = model:FindFirstChild("Body")
		if body and body:IsA("Model") then
			--[[for i,v in pairs(body:GetChildren()) do
				if v.Position * Vector3.new(1,0,1) - boundary.Position * Vector3.new(1,0,1) then
					v.Name = "BodyPrim"
					body.PrimaryPart = v
					break
				end
			end]]--
			if not body.PrimaryPart then
				local part = Instance.new("Part")
				part.Name = "BodyPrim"
				part.Anchored = true
				part.Transparency = 1
				part.Size = Vector3.new(1,0,1)
				part.CastShadow = false
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Position = boundary.Position + Vector3.new(0,1,0)
				part.Parent = body
			end
			--else
			--warn(defName.." has no body")
		end
		--else
		--warn(defName.." has no model")
	end

	if stat and stat.sound then
		local sound = Instance.new("Sound",def.PrimaryPart)
		sound.SoundId = stat.sound
		sound.Volume = stat.volume
		sound.RollOffMaxDistance = 40
	elseif not stat then
		warn("stat not found for "..defName)
	end

	local head = def:FindFirstChild("Head",true)
	if head and head:IsA("Model") then
		local prim = head.Prim
		head.PrimaryPart = prim
		prim.Anchored = true
		for _,v in pairs(head:GetChildren()) do
			if v:IsA("BasePart") and v ~= prim then
				if not (v:FindFirstChild("WeldConstraint") or v:FindFirstChild("HingeConstraint")) then
					local weld = Instance.new(("WeldConstraint"))
					weld.Part0 = prim
					weld.Part1 = v
					weld.Parent = prim
				end				
				v.Anchored = false
			end
		end
	end
end

for _, item in pairs(blocks:GetChildren()) do
	if item:IsA("Folder") then
		for _, def in pairs(item:GetChildren()) do
			iterate(def, item.Name)
		end
	else
		iterate(item, item.Name)
	end	
end

blocks:SetAttribute("Ready", true)