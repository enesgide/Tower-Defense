local RS = game:GetService("ReplicatedStorage")

local block_storage = RS:WaitForChild("Blocks")

repeat 
	task.wait(0.1)
until block_storage:GetAttribute("Ready")

local newFolder = Instance.new("Folder")
newFolder.Name = "SmallMythics"

local function shrinkTower(parent, originalModel, scaleFactor)
	local model = originalModel:Clone()
	local boundary = model:WaitForChild("Boundary")
	boundary.Transparency = 1
	model.PrimaryPart = boundary
	model:WaitForChild("Range"):Destroy()
	local pathBoundary = model:FindFirstChild("PathBoundary")
	if pathBoundary then
		pathBoundary:Destroy()
	end
	
	local orientation = model:GetBoundingBox()
	local dilationCentre = orientation.p

	for i , part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			local partPos = part.Position
			local offset = partPos - dilationCentre
			offset = offset * scaleFactor
			part.Position = dilationCentre + offset
			part.Size = part.Size * scaleFactor
		end
	end
	
	model.Parent = parent
end

for _, towerFolder in pairs(block_storage:GetDescendants()) do
	if towerFolder:IsA("Folder") then
		local folderClone = Instance.new("Folder", newFolder)
		folderClone.Name = towerFolder.Name
		for _, skin in pairs(towerFolder:GetChildren()) do
			shrinkTower(folderClone, skin, 0.3)
		end
	end
end

newFolder.Parent = RS