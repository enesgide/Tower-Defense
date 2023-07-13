local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")

local guis = RS:WaitForChild("Guis")
local mods = RS:WaitForChild("Mods")
local misc = RS:WaitForChild("Misc")
local rE = RS:WaitForChild("RE")
local bE = SS:WaitForChild("BE")

local rebirthStats =require(mods.RebirthStats).items
local blockStats = require(mods.BlockStats)
local dmgGui = guis:WaitForChild("DamageGui")

local blocks = workspace.Blocks
local monstersFolder = workspace.Monsters
local debrisHolder = workspace.DebrisHolder

local function getUpdatedAttributes(d)
	return d:GetAttribute("Damage"), d:GetAttribute("Rate"), d:GetAttribute("Range"), d:GetAttribute("Speed"), d:GetAttribute("Cooldown"), d:GetAttribute("Duration")
end

local function getProjectile(defender)
	local foundProjectile = nil

	if defender:GetAttribute("Shiny") then
		foundProjectile = misc:FindFirstChild(defender.Name.."Shiny")
	else
		local skinName = defender:GetAttribute("Skin")
		if skinName then
			foundProjectile = misc:FindFirstChild(defender.Name..skinName)		
		end		
	end

	if not foundProjectile then
		foundProjectile = misc:FindFirstChild(defender.Name)
	end

	return foundProjectile
end

local function effectHudCheck(monster, effect)
	local hud = monster:FindFirstChild("HUD")
	if hud then
		local fx = hud:FindFirstChild(effect, true)
		if fx and fx:IsA("ImageLabel") then
			return fx.Visible
		end				
	end
	return false
end

local function effectHudSwitch(monster, effect, status, text)
	local hud = monster:FindFirstChild("HUD")
	if hud then
		local fx = hud:FindFirstChild(effect, true)
		if fx and fx:IsA("ImageLabel") then
			fx.Visible = status
			local label = fx:FindFirstChild("Label")
			if label then
				label.Text = text
			end
		end				
	end
end

local function checkDamageMultipliers(def)
	local mult = 1
	for i,val in pairs(def:GetChildren()) do
		if val.Name == "Multiplier" and val:IsA("NumberValue") then
			mult += 1			
		end
	end
	return mult
end 

local function checkVulnerabilityMultipliers(monster)	
	local mult = 1
	if not monster then return mult end 
	
	local vuln = monster:FindFirstChild("Vulnerability")
	if vuln then
		return vuln.Value
	end
	return mult
end

local function getNearby(monsterHolder, ogPos, range, exceptions)
	ogPos *= Vector3.new(1,0,1)
	local inRange = {}	
	for i,monster in pairs(monsterHolder:GetChildren()) do
		if not exceptions or not table.find(exceptions, monster) then
			local hum = monster:FindFirstChild("Humanoid")
			local root = monster:FindFirstChild("HumanoidRootPart")
			if hum and hum.Health > 0 and root then
				local monsterPos = root.Position * Vector3.new(1,0,1)
				local distance = (ogPos - monsterPos).Magnitude
				if distance <= range then
					table.insert(inRange, monster)	
				end
			end
		end		
	end
	return inRange
end

local function checkConditions(defId, conditions, monster)
	if not conditions then
		return true
	end
	if conditions.corrupt and monster:FindFirstChild("Vulnerability") then
		return false
	end
	if conditions.charm and (monster:GetAttribute("Charmed") or monster:GetAttribute("CharmId"..defId)) then
		return false
	end
	if conditions.scare and (monster:GetAttribute("Scared") or monster:GetAttribute("ScareId"..defId)) then
		return false
	end
	return true
end

local function targetFirst(monsterHolder, defId, defPos, range, path, conditions)	
	
	local inRange = {}	
	for i,monster in pairs(monsterHolder:GetChildren()) do
		local hum = monster:FindFirstChild("Humanoid")
		local root = monster:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and root then
			if checkConditions(defId, conditions, monster) then
				local monsterPos = root.Position * Vector3.new(1,0,1)
				local distance = (defPos - monsterPos).Magnitude
				if distance <= range then
					table.insert(inRange, monster)	
				end
			end			
		end
	end
	
	if #inRange == 0 then
		return nil
	end
	
	local highestPath = 0
	for i,monster in pairs(inRange) do
		local pathId = monster:GetAttribute("TargetPath")
		if pathId then
			if pathId == "Finish" then				
				highestPath = pathId
				break
			elseif tonumber(pathId) > highestPath then
				highestPath = tonumber(pathId)
			end
		end
	end
	
	local target, closestDistance
	local nextNode = path:FindFirstChild(tostring(highestPath))
	if nextNode then
		local nextNodePos = nextNode.Position
		for i,monster in pairs(inRange) do
			local root = monster:FindFirstChild("HumanoidRootPart")
			if root then
				local monsterPos = root.Position*Vector3.new(1,0,1)
				local distance = (nextNodePos - monsterPos).Magnitude
				if target then						
					if distance <= closestDistance then
						target = root
						closestDistance = distance
					end
				else
					target = root
					closestDistance = distance
				end
			end
		end
	end
	
	return target
end

local function targetClosest(monsterHolder, defId, defPos, range, conditions)	
	local target, closestDistance
	for i,monster in pairs(monsterHolder:GetChildren()) do
		local hum = monster:FindFirstChild("Humanoid")
		local root = monster:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and root then
			local monsterPos = root.Position*Vector3.new(1,0,1)
			local distance = (defPos - monsterPos).Magnitude
			if distance <= range and checkConditions(defId, conditions, monster) then
				if target then						
					if distance <= closestDistance then
						target = root
						closestDistance = distance
					end
				else
					target = root
					closestDistance = distance
				end	
			end
		end
	end
	return target
end

local function targetStrongest(monsterHolder, defId, defPos, range, conditions)
	local target, highestHealth
	for i,monster in pairs(monsterHolder:GetChildren()) do
		local hum = monster:FindFirstChild("Humanoid")
		local root = monster:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and root then
			local monsterHum = monster:FindFirstChild("Humanoid")
			local monsterPos = root.Position*Vector3.new(1,0,1)
			local distance = (defPos - monsterPos).Magnitude
			if monsterHum and monsterHum.Health > 0 and distance <= range and checkConditions(defId, conditions, monster) then
				if target then						
					if monsterHum.Health > highestHealth then
						target = root
						highestHealth = monsterHum.Health
					end
				else
					target = root
					highestHealth = monsterHum.Health
				end	
			end
		end
	end
	return target
end

local function targetWeakest(monsterHolder, defId, defPos, range, conditions)
	local target, lowestHealth
	for i,monster in pairs(monsterHolder:GetChildren()) do
		local hum = monster:FindFirstChild("Humanoid")
		local root = monster:FindFirstChild("HumanoidRootPart")
		if hum and hum.Health > 0 and root then
			local monsterHum = monster:FindFirstChild("Humanoid")
			local monsterPos = root.Position*Vector3.new(1,0,1)
			local distance = (defPos - monsterPos).Magnitude
			if monsterHum and monsterHum.Health > 0 and distance <= range and checkConditions(defId, conditions, monster) then
				if target then						
					if monsterHum.Health < lowestHealth then
						target = root
						lowestHealth = monsterHum.Health
					end
				else
					target = root
					lowestHealth = monsterHum.Health
				end	
			end
		end
	end
	return target
end

local function clientDamage(owner, defender, root, damage, conditions)
	if not (owner and root and damage) then return end
	
	for _, v in pairs(conditions) do
		if v then
			return
		end
	end
	
	rE.DamageMonster:FireClient(owner, defender, root, damage)
end

local function damageMonster(owner, defender, stat, damage, damageDelay, monster, preventAOE, preventSpike, preventBurn)
	local conditions = {preventAOE, preventSpike, preventBurn}
	
	if not owner then return end 
	local monsterHolder = monstersFolder:FindFirstChild(owner.UserId)
	if not monsterHolder then return end
	
	if defender then
		damage = damage * checkDamageMultipliers(defender) * checkVulnerabilityMultipliers(monster)
		local boosts = owner:FindFirstChild("Boosts")
		if boosts then
			local x2Damage = boosts:FindFirstChild("x2 Damage")
			if x2Damage and x2Damage.Value > 0 then
				damage *= 2
			end
		end	
		
		local debuffs = owner:FindFirstChild("Debuffs")
		if debuffs then
			local lowerDamage = debuffs:FindFirstChild("Lower Damage")
			if lowerDamage and lowerDamage.Value > 0 then
				damage = math.ceil(damage * 0.75)
			end
		end	
		
		local passes = owner:FindFirstChild("Passes")
		if passes then
			local proPass = passes:FindFirstChild("PRO")
			if proPass then
				damage = math.ceil(damage * 1.1)
			end
		end	
		
		if monster and monster:IsDescendantOf(monsterHolder) then	
			if defender.Name == "The Eggsecutor" and monster:GetAttribute("Egged") then
				damage *= 2
			end
			
			if defender.Name == "Hell's Vision" and monster:GetAttribute("Frozen") then
				damage *= 2
			end			
			
			local root = monster:FindFirstChild("HumanoidRootPart")			
			local hum = monster:FindFirstChild("Humanoid")
			if root and hum then	
				clientDamage(owner, defender, root, damage, conditions)
				
				local rootPos = root.Position
				if hum.Health > 0 then
					local dmgDealt = 0
					if hum.Health >= damage then
						dmgDealt = damage
						hum.Health -= damage
						if defender.Name == "Eggsploder" and not preventAOE then
							monster:SetAttribute("Egged", true)
							effectHudSwitch(monster, "Egg", true)
						elseif defender.Name == "The Eggsecutor" then
							if hum.Health <= hum.MaxHealth * 0.05 then
								dmgDealt += hum.Health
								hum.Health = 0
								monster:SetAttribute("KilledByTower", defender.Name)
							end
						end
					else
						dmgDealt = hum.Health						
						hum.Health = 0
						monster:SetAttribute("KilledByTower", defender.Name)
						
						if defender.Name == "Mantle Spiker" and not preventSpike then
							coroutine.wrap(function()
								local mult = stat.spikeDamage
								local spike, hitbox = createMantleSpike(owner, defender, rootPos)
								if spike and hitbox then
									local hitMonsters = {}
									local touchCon, ancestryCon
									touchCon = hitbox.Touched:Connect(function(hit)
										local spikedMonster = hit.Parent
										if spikedMonster and not table.find(hitMonsters, spikedMonster) then
											local hum = spikedMonster:FindFirstChild("Humanoid")
											if hum and hum.Health > 0 then
												table.insert(hitMonsters, spike)
												damageMonster(owner, defender, stat, damage * mult, 0, spikedMonster, false, true)
											end
										end										
									end) 
									ancestryCon = spike.AncestryChanged:Connect(function()
										if not spike:IsDescendantOf(workspace) then
											touchCon:Disconnect()
											ancestryCon:Disconnect()
										end
									end)
								end
							end)()
						end
					end		
					
					if owner:GetAttribute("DamageDealt") then
						owner:SetAttribute("DamageDealt", dmgDealt + owner:GetAttribute("DamageDealt"))
					end	
					if not preventAOE and stat.aoeDamage then
						local inRange = getNearby(monsterHolder, rootPos, stat.aoeRange, {defender})
						for i,aoeMonster in pairs(inRange) do
							local mult = stat.aoeDamage
							damageMonster(owner, defender, stat, damage * mult, 0, aoeMonster, true)
						end
					end
					if not preventBurn and stat.burnDamage then
						local intervals = 10
						for i = 1, 10 do
							task.wait(0.2)
							if monster:IsDescendantOf(monsterHolder) then
								local mult = stat.burnDamage / intervals
								damageMonster(owner, defender, stat, damage * mult, 0, monster, false, false, true)
							end
							
						end
					end
					return true
				end							
			end	
		end		
	end
	return false
end

local function getTarget(owner, targeting, defId, defPos, range, path, conditions)
	if not owner then return end 
	local monsterHolder = monstersFolder:FindFirstChild(owner.UserId)
	if not monsterHolder then return end
	
	if targeting == "Strongest" then
		return targetStrongest(monsterHolder, defId, defPos, range, conditions)
	elseif targeting == "Weakest" then
		return targetWeakest(monsterHolder, defId, defPos, range, conditions)
	elseif targeting == "Closest" then
		return targetClosest(monsterHolder, defId, defPos, range, conditions)
	else --first, or targeting not found
		return targetFirst(monsterHolder, defId, defPos, range, path, conditions)
	end
end

local function getInRangeTurrets(defender, range, exceptions)
	local start = defender:FindFirstChild("Boundary")
	if not start then return end
	local turrets = {}
	for i, def in pairs(blocks:GetChildren()) do
		if not table.find(exceptions, def.Name) then
			local dest = def:FindFirstChild("Boundary")
			if dest and misc:FindFirstChild(def.Name) and (start.Position - dest.Position).Magnitude <= range then
				table.insert(turrets, def)
			end
		end
	end
	return turrets
end

local function futuresTurret(defender)
	local particlePart = defender.Model.Head:WaitForChild("Particle"):WaitForChild("Attachment")
	local function particlesOn()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
	end	
	local function particlesOff()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	
	local stat = rebirthStats[defender.Name]
	if stat then
		task.wait(stat.secretCooldown)
		while defender:IsDescendantOf(blocks) do
			local baseRate = stat.rate
			if defender:GetAttribute("Rate") > baseRate then
				defender:SetAttribute("Rate", baseRate)
				particlesOff()
				task.wait(stat.secretCooldown)
			else
				defender:SetAttribute("Rate", baseRate * 2)
				particlesOn()
				task.wait(stat.secretDuration)
			end	
		end
	end
end

local function valentinesTower(defender, monster)
	local duration = 1
	
	local function moveToDefender(humanoid)
		local target = defender:FindFirstChild("Boundary")
		if target then
			humanoid:MoveTo(target.Position)
		end
	end
	
	local charmId = "CharmId"..defender:GetAttribute("Id")
	if not monster:GetAttribute("Charmed") and not monster:GetAttribute(charmId) and not monster:GetAttribute("Scared") then
		local humanoid = monster:FindFirstChild("Humanoid")
		if humanoid then
			monster:SetAttribute("Charmed", true)
			monster:SetAttribute(charmId, true)
			humanoid.WalkSpeed *= 0.5
			effectHudSwitch(monster, "Charm", true)
			moveToDefender(humanoid)
			
			task.delay(duration, function()				
				if not monster:GetAttribute("Frozen") then
					humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed")
				end
				monster:SetAttribute("Charmed", false)
				effectHudSwitch(monster, "Charm", false)
			end)
		end
	end
end

local function jackOLantern(defender, monster)
	local duration = 1

	local function moveAwayFromDefender(monsterPos, humanoid)
		local oppTarget = defender:FindFirstChild("Boundary")
		if oppTarget then
			local oppVec = oppTarget.Position - monsterPos
			local pos = monsterPos - oppVec
			humanoid:MoveTo(pos)
		end
	end

	local scareId = "ScareId"..defender:GetAttribute("Id")
	if not monster:GetAttribute("Scared") and not monster:GetAttribute(scareId) and not monster:GetAttribute("Charmed") then
		local humanoid = monster:FindFirstChild("Humanoid")
		local root = monster:FindFirstChild("HumanoidRootPart")
		if humanoid and root then
			monster:SetAttribute("Scared", true)
			monster:SetAttribute(scareId, true)
			humanoid.WalkSpeed *= 0.5
			effectHudSwitch(monster, "Scare", true)
			moveAwayFromDefender(root.Position, humanoid)

			task.delay(duration, function()				
				if not monster:GetAttribute("Frozen") then
					humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed")
				end
				monster:SetAttribute("Scared", false)
				effectHudSwitch(monster, "Scare", false)
			end)
		end
	end
end

local function attackTower(defender, path, owner, isBeamTower)
	local defId = defender:GetAttribute("Id")
	
	if defender.Name == "Future's Blast" then
		coroutine.wrap(function()
			futuresTurret(defender)	
		end)()
	end
	
	while defender:IsDescendantOf(blocks) do	
		local damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)	
		
		coroutine.wrap(function()
			local defPos = defender.PrimaryPart.Position * Vector3.new(1,0,1)
			local targeting = defender:GetAttribute("Targeting")
			
			local target = nil
			if defender.Name == "Valentine's Tower" then
				target = getTarget(owner, targeting, defId, defPos, range, path, {charm = true})				
			elseif defender.Name == "Jack O'Lantern" then
				target = getTarget(owner, targeting, defId, defPos, range, path, {scare = true})	
			end			
			if not target then
				target = getTarget(owner, targeting, defId, defPos, range, path)
			end

			if target then
				local speed
				local stat = blockStats[defender.Name] or rebirthStats[defender.Name]

				if stat then speed = stat.speed end
				if not speed then speed = 25 end
				
				local targetPos = target.Position * Vector3.new(1,0,1)
				local distance = (targetPos - defPos).Magnitude
				local damageDelay = distance / speed
				
				if not isBeamTower then	
					rE.FireProjectile:FireClient(owner, defender, target, damage, damageDelay)
					task.wait(damageDelay)
				end
				
				local cacheDamage = damage

				local monster, monsterConfirmed = target.Parent, false		
				if monster then
					local snowballValue = monster:GetAttribute("Snowball")
					if snowballValue then
						damage = math.ceil( damage * (1 + snowballValue/100))
					end	
					
					if damageMonster(owner, defender, stat, damage, damageDelay, monster) then
						monsterConfirmed = true
						if defender.Name == "Valentine's Tower" then
							coroutine.wrap(function()
								valentinesTower(defender, monster)
							end)()
						elseif defender.Name == "Jack O'Lantern" then
							coroutine.wrap(function()
								jackOLantern(defender, monster)
							end)()
						elseif stat.snowballTrait then
							coroutine.wrap(function()
								snowballTower(defender, stat.snowballTrait, monster)
							end)() 						
						end	
					end					
				end
				
				if not monsterConfirmed then
					damage = cacheDamage
					
					local target2 = getTarget(owner, targeting, defId, defPos, range, path)
					if target2 then
						local monster2 = target2.Parent	
						
						local snowballValue = monster2:GetAttribute("Snowball")
						if snowballValue then
							damage = math.ceil(damage * (1 + snowballValue/100))
						end						
						
						damageMonster(owner, defender, stat, damage, damageDelay, monster2)
						if defender.Name == "Valentine's Tower" then
							coroutine.wrap(function()
								valentinesTower(defender, monster2)
							end)()
						elseif defender.Name == "Jack O'Lantern" then
							coroutine.wrap(function()
								jackOLantern(defender, monster2)
							end)()
						elseif stat.snowballTrait then
							coroutine.wrap(function()
								snowballTower(defender, stat.snowballTrait, monster2)
							end)() 						
						end	
					end						
				end
			else
				task.wait()
			end
		end)()
		
		task.wait(1/rate)
	end
end

function snowballTower(defender, traitBoost, monster)
	local oldSnowballValue = monster:GetAttribute("Snowball") or 0
	local newSnowballValue = math.clamp(oldSnowballValue + traitBoost, 0, 100)
	monster:SetAttribute("Snowball", newSnowballValue)
	
	effectHudSwitch(monster, "Snowball", true, "+"..newSnowballValue.."%")
end

local function magmarsMesa(defender, path, owner)
	local damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)
	
	local particlePart = defender.Model:WaitForChild("Particle")
	local function particlesOn()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
	end	
	local function particlesOff()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	
	local crystal = defender.Model:WaitForChild("Magma Crystal")
	local ogBeam
	local skinName = defender:GetAttribute("Skin")
	if skinName then
		ogBeam = misc:FindFirstChild("Magmar's Mesa"..skinName)
	end
	if not ogBeam then
		ogBeam = misc:FindFirstChild("Magmar's Mesa")
	end
	
	while defender:IsDescendantOf(blocks) do		
		task.wait(cooldown)
		
		if not defender:IsDescendantOf(blocks) then
			break
		end
		
		damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)
		
		local turrets = getInRangeTurrets(defender, range, {"Magmar's Mesa", "Triadic Corruption", "Frozen Pillar"})
		particlesOn()
		
		if turrets then
			for i, def in pairs(turrets) do
				if def:FindFirstChild("Boundary") and def.Boundary:FindFirstChild("Attachment") then
					local numVal = Instance.new("NumberValue")
					numVal.Name = "Multiplier"
					numVal.Value = 2
					
					local beam = ogBeam:Clone()
					beam.Attachment0 = crystal.Attachment
					beam.Attachment1 = def.Boundary.Attachment
					
					game:GetService("Debris"):AddItem(numVal, duration)
					numVal.Parent = def
					game:GetService("Debris"):AddItem(beam, duration)
					beam.Parent = crystal
				end
			end
		end
		task.wait(duration)
		particlesOff()
	end	
end

local function triadicCorruption(defender, path, owner)		
	local defId = defender:GetAttribute("Id")
	
	local crystal = defender.Model.Head:WaitForChild("Crystal")
	
	local ogBeam
	local skinName = defender:GetAttribute("Skin")
	if skinName then
		ogBeam = misc:FindFirstChild("Triadic Corruption"..skinName)
	end
	if not ogBeam then
		ogBeam = misc:FindFirstChild("Triadic Corruption")
	end
	
	local function corruptMonster(monster, root)
		local numVal = Instance.new("NumberValue")
		numVal.Name = "Vulnerability"
		if string.sub(monster.Name, 1, 4) == "Boss" then
			numVal.Value = 3
		else
			numVal.Value = 5
		end		
		numVal.Parent = monster
		
		local att1 = Instance.new("Attachment", root)
		local particles = misc:FindFirstChild("CorruptParticles")
		local head = monster:FindFirstChild("Head")
		if particles then
			if head then
				particles.Arrows:Clone().Parent = head
			end
			particles.Shadow:Clone().Parent = root	
		end

		local beam = ogBeam:Clone()
		beam.Attachment0 = crystal.Spawn		
		beam.Attachment1 = att1
		
		game:GetService("Debris"):AddItem(beam, 0.4)
		beam.Parent = crystal
		
		local humanoid = monster:FindFirstChild("Humanoid")
		if humanoid then
			humanoid:SetAttribute("WalkSpeed", humanoid:GetAttribute("WalkSpeed") * 2)
			if not humanoid:GetAttribute("Frozen") then
				humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed")
			end			
			effectHudSwitch(monster, "Corrupt", true)
		end
	end
	
	while defender:IsDescendantOf(blocks) do		
		local damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)

		local defPos = defender.PrimaryPart.Position * Vector3.new(1,0,1)
		local targeting = defender:GetAttribute("Targeting")
		local target = getTarget(owner, targeting, defId, defPos, range, path, {corrupt = true})

		if target then
			local speed
			local stat = rebirthStats[defender.Name]

			local monster = target.Parent
			if stat and monster and not monster:FindFirstChild("Vulnerability") then	
				local root = monster:FindFirstChild("HumanoidRootPart")
				if root then
					corruptMonster(monster, root)
					task.wait(cooldown)
				end				
			end
		end
		
		task.wait()
	end
end

local function frozenPillar(defender, path, owner)
	local damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)

	local particlePart = defender.Model.Body:WaitForChild("Particle")
	local function particlesOn()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
	end	
	local function particlesOff()
		for i,v in pairs(particlePart:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = false
			end
		end
	end
	
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)
	local exitTweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	
	local boundary = defender:WaitForChild("Boundary")	
	
	local ogOutburst
	local skinName = defender:GetAttribute("Skin")
	if skinName then
		ogOutburst = misc:FindFirstChild("Frozen Pillar"..skinName)
	end
	if not ogOutburst then
		ogOutburst = misc:FindFirstChild("Frozen Pillar")
	end
	
	if not owner then return end 
	local monsterHolder = monstersFolder:FindFirstChild(owner.UserId)
	if not monsterHolder then return end
	
	local sizeScale = (range * 2) / ogOutburst.Size.X

	while defender:IsDescendantOf(blocks) do		
		task.wait(cooldown)
		
		if not defender:IsDescendantOf(blocks) then
			break
		end
		
		damage, rate, range, speed, cooldown, duration = getUpdatedAttributes(defender)
		
		particlesOn()

		local outburst = ogOutburst:Clone()
		outburst.Position = boundary.Position + Vector3.new(0, 0.5, 0)
		local tween = TS:Create(outburst, tweenInfo, {Size = Vector3.new(range * 2, ogOutburst.Size.Y * sizeScale, range * 2)})		
		game:GetService("Debris"):AddItem(outburst, duration + 0.25)
		outburst.Parent = debrisHolder
		tween:Play()
		task.delay(duration, function()
			local exitTween = TS:Create(outburst, exitTweenInfo, {Transparency = 1})	
			exitTween:Play()
		end)
		
		-- Freeze/slow 'zone' mechanic
		local function freeze(monster)
			local freezeId = "FreezeId"..defender:GetAttribute("Id")
			if not monster:GetAttribute("Frozen") and not monster:GetAttribute(freezeId) then
				local humanoid = monster:FindFirstChild("Humanoid")
				if humanoid then
					monster:SetAttribute("Frozen", true)
					monster:SetAttribute(freezeId, true)
					humanoid.WalkSpeed = 0
					local shouldSlow = not effectHudCheck(monster, "Slow")
					effectHudSwitch(monster, "Slow", true)
					task.delay(duration, function()			
						if monster:GetAttribute("Charmed") or monster:GetAttribute("Scared") then
							humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed") / 2
						else 
							humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed")
						end	
						if string.sub(monster.Name, 1, 4) == "Boss" then
							effectHudSwitch(monster, "Slow", false)
						end
						monster:SetAttribute("Frozen", false)						
					end)
				end
			end
		end
		
		local function slow(monster)
			local freezeId = "FreezeId"..defender:GetAttribute("Id")
			if not monster:GetAttribute(freezeId) then
				local humanoid = monster:FindFirstChild("Humanoid")
				if humanoid then
					monster:SetAttribute("FrozenPillar", true)
					monster:SetAttribute(freezeId, true)
					humanoid:SetAttribute("WalkSpeed", humanoid:GetAttribute("WalkSpeed") * 0.7) --30% slow
					if not monster:GetAttribute("Frozen") then
						humanoid.WalkSpeed = humanoid:GetAttribute("WalkSpeed")
					end	
					effectHudSwitch(monster, "Slow", true)
				end
			end
		end
		
		coroutine.wrap(function()
			local intervals = 5
			for i = 1,intervals do
				local inRange = getNearby(monsterHolder, boundary.Position, range, nil)
				for i, monster in pairs(inRange) do
					if string.sub(monster.Name, 1, 4) == "Boss" or monster:GetAttribute("FrozenPillar") then
						freeze(monster)
					else
						slow(monster)
					end
				end
				task.wait(duration/intervals)
			end		
		end)()
		
		task.wait(duration)
		particlesOff()
	end	
end

function createMantleSpike(plr, defender, rootPos)
	if not plr or not rootPos then return end
	
	local map = workspace:FindFirstChild("Map"..plr.UserId)
	if not map then return end
	
	local floors = map:FindFirstChild("Floors")
	if not floors then return end
	
	local floor = floors:FindFirstChild("Prim")
	if not floor then return end	
	
	local ogSpike
	local skinName = defender:GetAttribute("Skin")
	if skinName then
		ogSpike = misc:FindFirstChild("Mantle Spiker Spikes"..skinName)
	end
	if not ogSpike then
		ogSpike = misc:FindFirstChild("Mantle Spiker Spikes")
	end
	
	local spike = ogSpike:Clone()
	if not spike.PrimaryPart then
		spike.PrimaryPart = spike.Hitbox
	end
	
	local y = (floor.Position.Y + floor.Size.Y/2) + (spike.PrimaryPart.Size.Y/2)
	
	spike:SetPrimaryPartCFrame(CFrame.new(rootPos.X, y, rootPos.Z))
	
	game:GetService("Debris"):AddItem(spike, 4)
	spike.Parent = debrisHolder
	
	return spike, spike.PrimaryPart
end

local function connect(defender)
	repeat task.wait() until defender.PrimaryPart 	
	
	local ownerAtt = defender:GetAttribute("Owner")
	local owner = Players:FindFirstChild(tostring(ownerAtt)) or Players:GetPlayerByUserId(tonumber(ownerAtt))
	
	if owner then
		local path = workspace:WaitForChild("Map"..owner.UserId).Path	
		
		--Rebirth items first
		if defender.Name == "Magmar's Mesa" then
			magmarsMesa(defender, path, owner)	
		elseif defender.Name == "Triadic Corruption" then
			triadicCorruption(defender, path, owner)
		elseif defender.Name == "Frozen Pillar" then
			frozenPillar(defender, path, owner)
		elseif misc:FindFirstChild(defender.Name) then --determine if ranged defender
			local foundProjectile = getProjectile(defender)
			if foundProjectile and foundProjectile:IsA("Beam") then
				attackTower(defender, path, owner, true)		
			else
				attackTower(defender, path, owner, false)		
			end				
		end
	end
end

for i,defender in pairs(blocks:GetChildren()) do
	coroutine.wrap(function()
		connect(defender)
	end)()
end

blocks.ChildAdded:Connect(function(defender)	
	connect(defender)
end)

-- 

rE.ScalingTowers.OnServerEvent:Connect(function(plr, defender)
	-- blacklist --
	local scalingTowers = {"Festive Turret", "Heaven's Vision", "Holiday Turret", "Solar Scorch", "Future's Blast", "Valentine's Tower", "Armored Cannon", "Eggsploder", "The Eggsecutor", "Mantle Spiker", "Firework Launcher", "Acidic Powerplant", "Hell's Vision", "Jack O'Lantern", "Gingerbread Blaster", "Candy Cane Cannon", "Festive Minigun", "Ice Dragon"}
	
	if not defender then return end
	
	local stat = rebirthStats[defender.Name]
	if not stat then return end
	
	local dmg = stat.damage
	local rate = stat.rate
	local scaleDamage = stat.scaleDamage	
	if not (dmg and rate and scaleDamage) then return end
	
	local setDPS = dmg * rate
	
	-- Find the highest dps non-mythic 
	for i, block in pairs(blocks:GetChildren()) do
		-- Make sure you're only checking the player's tower
		if not table.find(scalingTowers, block:GetAttribute("TowerName")) and block:GetAttribute("Owner") == plr.UserId then
			local checkDmg, checkRate = block:GetAttribute("Damage"), block:GetAttribute("Rate")						
			if checkDmg and checkRate then
				local checkDPS = checkDmg * checkRate * scaleDamage
				if checkDPS > setDPS then
					setDPS = checkDPS
				end
			end						
		end
	end
	
	if setDPS > 0 then
		defender:SetAttribute("Damage", math.ceil(setDPS / rate))
	end		
end)