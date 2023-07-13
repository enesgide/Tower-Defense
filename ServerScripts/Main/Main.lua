local MPS = game:GetService("MarketplaceService")
local SSS = game:GetService("ServerScriptService")
local SS = game:GetService("ServerStorage")
local RS = game:GetService("ReplicatedStorage")
local PS = game:GetService("PhysicsService")
local TS = game:GetService("TweenService")

local pathModule = require(SSS.PathsChecker)
local monsterStats = require(SSS.MonsterStats)
local monsterStages = require(SSS.MonsterStages)
local monsterStorage = SS.Monsters
local monstersFolder = workspace.Monsters

local bE = SS:WaitForChild("BE")
local rE = RS:WaitForChild("RE")

local pathIds = {}

local hud = script:WaitForChild("HUD")

local function checkPasses(passes)
	if passes then
		if passes:FindFirstChild("x2Coins") then
			return true
		end
	end
	return false
end

local function checkBoosts(boosts)
	if boosts then
		local x2Coins = boosts:FindFirstChild("x2 Coins")
		if x2Coins and x2Coins.Value > 0 then
			return true
		end
	end
	return false
end

local function getTargetPath(monster, path)
	local targetPath = path:FindFirstChild(tostring(pathIds[monster]))
	if not targetPath then
		targetPath = path:FindFirstChild("Finish")
	end
	if not targetPath then
		return nil
	end
	monster:SetAttribute("TargetPath", targetPath.Name)
	return targetPath
end

local function prepareMonster(plr, monster)
	local hud = hud:Clone()
	local hudEffects = hud:FindFirstChild("Effects")
	if hudEffects then
		local hudEffectsHolder = hudEffects:FindFirstChild("Holder")
		if hudEffectsHolder then
			for i,v in pairs(hudEffectsHolder:GetChildren()) do
				if v:IsA("ImageLabel") then
					v.Visible = false
				end
			end
		end
	end
	
	local hum = monster.Humanoid
	local maxHp
	local diedCon
	diedCon = hum.Died:Connect(function()
		--Coins earned animation
		--if this players enemy is killed
		if plr:GetAttribute("SettingCoinsParticles") and monster:GetAttribute("Owner") == plr.UserId then
			local head = monster:FindFirstChild("Head")
			if head then
				rE.EnemyKilled:FireClient(plr, head.Position, string.sub(monster.Name, 1, 4) == "Boss")
			end		
		end
		
		local killedByTower = monster:GetAttribute("KilledByTower")
		diedCon:Disconnect()
		task.delay(0.2, function() monster:Destroy() end)
		--monster:Destroy()
		plr:SetAttribute("EnemiesKilled", 1 + plr:GetAttribute("EnemiesKilled"))
		if maxHp and maxHp > 0 then
			local coins = plr:FindFirstChild("Coins")
			if coins then
				local amount = math.ceil(maxHp * 1.2)
				
				local stat = monsterStats[monster.Name]
				if stat and stat.reward and stat.reward > 0 then
					amount += stat.reward
				end
				local boosts = plr:FindFirstChild("Boosts")
				local debuffs = plr:FindFirstChild("Debuffs")
				local passes = plr:FindFirstChild("Passes")
				if checkPasses(passes) then
					if checkBoosts(boosts) then
						amount *= 3
					else
						amount *= 2
					end
				elseif checkBoosts(boosts) then
					amount *= 2
				end
				
				if debuffs then
					local halfCoins = debuffs:FindFirstChild("Half Coins")
					if halfCoins and halfCoins.Value > 0 then
						print("debuff coins active")
						amount = math.ceil(amount * 0.5)
					end
				end	
				
				if passes:FindFirstChild("AutoPlay") then
					amount = math.ceil(amount * 1.1)
				end
				
				if killedByTower then
					if killedByTower == "Heaven's Vision" then
						amount *= 3
					end
				end
				
				local twitterVerified = plr:FindFirstChild("TwitterVerified")
				if twitterVerified and twitterVerified.Value then
					amount = math.ceil(amount * 1.3)
				end
				
				coins.Value += amount
				plr:SetAttribute("CoinsEarned", amount + plr:GetAttribute("CoinsEarned"))
			end
		end
	end)
	
	local walkSpeed = monsterStats[monster.Name].speed * (plr:GetAttribute("EnemySpeedMultiplier") or 1)
	maxHp = monsterStats[monster.Name].maxhealth
	monster:SetAttribute("MaxHealth", maxHp)
	monster:SetAttribute("Speed", walkSpeed)
	monster:SetAttribute("Reward", monsterStats[monster.Name].reward)
	hum:SetAttribute("WalkSpeed", walkSpeed)
	hum.WalkSpeed = walkSpeed		
	hum.HipHeight = monsterStats[monster.Name].hipheight
	hum.MaxHealth = maxHp
	hum.Health = maxHp

	local health_Frame = hud:FindFirstChild("HealthBar",true)	
	health_Frame.TopText.Text = hum.MaxHealth
	health_Frame.BottomText.Text = hum.MaxHealth

	local head = monster.Head
	if monsterStats[monster.Name].face then
		head.face.Texture = monsterStats[monster.Name].face
	end
	hud.WeldConstraint.Part1 = head		
	hud.Position = head.Position + (Vector3.new(0,head.Size.Y/2 + hud.Size.Y/2 + monsterStats[monster.Name].hud,0))
	hud:FindFirstChild("HPTween",true).Disabled = false			
	hud.Parent = monster

	for i,body_part in pairs(monster:GetDescendants()) do
		if body_part:IsA("BasePart") then
			body_part.CollisionGroup = "NPC"
			body_part.CastShadow = false
		end
	end
	
	local animate
	if monster.Humanoid.RigType == Enum.HumanoidRigType.R15 then
		animate = script.R15Animate:Clone()
	else
		animate = script.R6Animate:Clone()
	end
	animate.Disabled = false
	animate.Parent = monster
end

local function spawnMonster(plr, monsterName, path, start, finish)
	if not plr then return end 
	local monsterHolder = monstersFolder:FindFirstChild(plr.UserId)
	if not monsterHolder then return end
	
	local monster = monsterStorage:FindFirstChild(monsterName):Clone()
	monster:SetAttribute("Owner", plr.UserId)
	
	if monster then
		local humanoid = monster:WaitForChild("Humanoid")
		
		local root = monster:WaitForChild("HumanoidRootPart")
		if not monster.PrimaryPart then
			monster.PrimaryPart = root
		end
		prepareMonster(plr, monster)
			
		pathIds[monster] = 1		
		monster:SetPrimaryPartCFrame(CFrame.new(start.Position + Vector3.new(0, 0.2 + humanoid.HipHeight, 0)))
		monster:SetAttribute("TargetPath", 1)
		monster.Parent = monsterHolder
		root:SetNetworkOwner(nil)
		while monster:IsDescendantOf(monsterHolder) and humanoid.Health > 0 do
			local targetPath = getTargetPath(monster, path)
			if targetPath then
				local targetPathP = targetPath.Position
				pathIds[monster] += 1
				repeat
					if humanoid:GetAttribute("Charmed") or humanoid:GetAttribute("Scared") then
						task.wait()
					else
						humanoid:MoveTo(targetPathP)
						
						local yield, con, con2, con3 = Instance.new("BindableEvent")	
						con = humanoid.MoveToFinished:Connect(function()
							yield:Fire()
						end)
						con2 = monster:GetAttributeChangedSignal("Charmed"):Connect(function()
							yield:Fire()
						end)
						con3 = monster:GetAttributeChangedSignal("Scared"):Connect(function()
							yield:Fire()
						end)
						yield.Event:Wait()
						con:Disconnect()
						con2:Disconnect()
						con3:Disconnect()
					end					
				until (root.Position*Vector3.new(1,0,1) - targetPathP*Vector3.new(1,0,1)).Magnitude < 1
			else
				task.wait()
			end
		end
	end
end

rE.StartStage.OnServerEvent:Connect(function(plr)
	rE.PlayResponseReached:FireClient(plr)
	
	if not plr then return end 
	local monsterHolder = monstersFolder:FindFirstChild(plr.UserId)
	if not monsterHolder then return end
	
	local ls = plr:FindFirstChild("leaderstats")
	local map = workspace:FindFirstChild("Map"..plr.UserId)
	if not (ls and map) then return end	
	
	local rebirths = ls:FindFirstChild("Rebirths")
	local path = map:WaitForChild("Path", 2)
	if not (rebirths and path) then return end
	
	if not pathModule.checkExistingValid(plr, map) then
		rE.CancelStage:FireClient(plr)
		return 
	end
	
	local start = path:WaitForChild("Start")
	local finish = path:WaitForChild("Finish")

	if not plr:GetAttribute("InStage") and plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Stage") then
		plr:SetAttribute("InStage",true)
		plr:SetAttribute("EnemiesKilled",0)
		plr:SetAttribute("DamageDealt",0)
		plr:SetAttribute("CoinsEarned",0)

		local stageFailed = false
		local stageCancelled = false
		local ghostCancelled = false
		local stageNum = plr.leaderstats.Stage.Value

		local con, con2, con3
		con = rE.CancelStage.OnServerEvent:Connect(function(eventPlr)
			if eventPlr == plr then
				stageFailed = true
				stageCancelled = true
			end			
		end)
		con2 = bE.CancelStage.Event:Connect(function(eventPlr, ghostCancel)			
			if eventPlr == plr then
				ghostCancelled = true
				stageFailed = true
				stageCancelled = true				
			end			
		end)
		con3 = finish.Touched:Connect(function(hit)
			if hit:IsDescendantOf(monsterHolder) and hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent:Destroy()		
				stageFailed = true
			end
		end)	

		if stageNum then
			local stage = monsterStages[stageNum]
			if not stage then
				stageNum -= 1
				stage = monsterStages[stageNum]
			end
			if stage then		
				local startTime = os.time()
				for _,wave in pairs(stage) do
					local count = 1
					if wave.count then count = wave.count end
					if stageFailed then break end
					for _ = 1, count do
						if stageFailed then break end
						if wave.name then
							if plr:IsDescendantOf(game) then
								if not wave.uptoRebirth or rebirths.Value <= wave.uptoRebirth then
									coroutine.wrap(function() spawnMonster(plr, wave.name, path, start, finish) end)()
								end
							else
								return
							end
						end	
						
						local completedRounds = plr:GetAttribute("CompletedRounds") or 0
						if rebirths.Value >= 1 and completedRounds >= 3 then
							if completedRounds >= 15 then
								task.wait(wave.delay * 0.3)
							elseif completedRounds >= 10 then
								task.wait(wave.delay * 0.5)
							elseif completedRounds >= 6 then
								task.wait(wave.delay * 0.7)
							else -- >= 3
								task.wait(wave.delay * 0.8)
							end
						else
							task.wait(wave.delay)
						end
					end					
				end	

				local waveFinished
				repeat 
					waveFinished = true
					for i,v in pairs(monsterHolder:GetChildren()) do
						if v:GetAttribute("Owner") == plr.UserId then
							waveFinished = false
							break
						end
					end
					task.wait(.1)
				until stageFailed or waveFinished

				local roundDuration = os.time() - startTime
				if stageFailed then
					for i,v in pairs(monsterHolder:GetChildren()) do
						if v:GetAttribute("Owner") == plr.UserId then
							v:Destroy()
						end	
					end
					
					if not stageCancelled then						
						local completedRounds = plr:GetAttribute("CompletedRounds")
						if completedRounds > 16 then 
							completedRounds = 16 							
						end						
						local newCompletedRounds = completedRounds - 2
						if newCompletedRounds < 0 then 
							newCompletedRounds = 0 
						end
						plr:SetAttribute("CompletedRounds", newCompletedRounds)
						
						plr:SetAttribute("FailedRounds", plr:GetAttribute("FailedRounds") + 1)						
					end
					
					if not ghostCancelled then
						rE.ShowResults:FireClient(plr, false, roundDuration, plr:GetAttribute("EnemiesKilled"), plr:GetAttribute("DamageDealt"), plr:GetAttribute("CoinsEarned"))
					end
				else
					plr:SetAttribute("FailedRounds", 0)
					plr:SetAttribute("CompletedRounds", plr:GetAttribute("CompletedRounds") + 1)
					rE.ShowResults:FireClient(plr, true, roundDuration, plr:GetAttribute("EnemiesKilled"), plr:GetAttribute("DamageDealt"), plr:GetAttribute("CoinsEarned"))
					plr.leaderstats.Stage.Value = stageNum+1
					coroutine.wrap(function()
						local plrBase = workspace:FindFirstChild("Map"..plr.UserId)
						if plrBase then
							local baseModel = plrBase:FindFirstChild("Base", true)
							if baseModel then
								local gate = baseModel:FindFirstChild("Gate")
								if gate then
									for i,v in pairs(gate:GetChildren()) do
										if v:IsA("ParticleEmitter") then
											v.Enabled = true
										end
									end
									task.delay(2, function()
										for i,v in pairs(gate:GetChildren()) do
											if v:IsA("ParticleEmitter") then
												v.Enabled = false
											end
										end
									end)
								end
							end
						end
					end)()
				end	

				local plrKills = plr:FindFirstChild("Kills")
				if plrKills then
					plrKills.Value += plr:GetAttribute("EnemiesKilled") or 0
				end
				task.wait(1)			
			end
		end	
		if con then con:Disconnect() end
		if con2 then con2:Disconnect() end
		if con3 then con3:Disconnect() end
		plr:SetAttribute("InStage",nil)	
	end
end)

for i, monster in pairs(monsterStorage:GetChildren()) do
	for i,part in pairs(monster:GetChildren()) do
		if part:IsA("BasePart") then
			local properties = PhysicalProperties.new(10, 0.3, 1, 0.5, 1)
			part.CustomPhysicalProperties = properties
		end
	end
end