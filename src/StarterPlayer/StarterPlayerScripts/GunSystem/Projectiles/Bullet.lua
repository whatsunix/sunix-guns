local bullet = {}
bullet.__index = bullet


local utils = require(script.Parent.Parent.Utils)
local gunSystem = game:GetService("ReplicatedStorage").GunSystem

--objects and logic

local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local random = Random.new()


--[[   FUNCTIONS  ]]

function bullet:Cast(caliberStats, x, y, spread)
	local origin = player.Character.Head.Position
	local direction
	local hits = {}

	if typeof(x) == "number" then
		local mouseHit = utils.GetMouseHit(x, y)
		direction = (mouseHit - origin).Unit
	else
		origin = x
		direction = y.Unit
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}

	if caliberStats.MaxPellets > 3 then
		local innerCirclePellets = math.ceil(caliberStats.MaxPellets/3)
		local outerCirclePellets = caliberStats.MaxPellets - innerCirclePellets

		for i = 1, caliberStats.MaxPellets do
			local spreadAngle = math.random(0,360)
			local spreadMagnitude
			if i <= innerCirclePellets then
				spreadMagnitude = random:NextNumber(0, math.rad(spread)*0.4)
			else
				spreadMagnitude = random:NextNumber(math.rad(spread)*0.65, math.rad(spread))
			end

			local spreadDirection = CFrame.new(Vector3.new(), direction) * CFrame.Angles(0,0,math.rad(spreadAngle))
			spreadDirection = spreadDirection * CFrame.Angles(spreadMagnitude,0,0)
			spreadDirection = spreadDirection.LookVector

			local part, pos, norm, material = utils.RecursiveRay(origin, spreadDirection * 500, params)
			table.insert(hits, {part, pos, norm, material})
		end

	else
		for _ = 1, caliberStats.MaxPellets do
			local spreadAngle = math.random(0,360)
			local spreadMagnitude = random:NextNumber(0, math.rad(spread))

			local spreadDirection = CFrame.new(Vector3.new(), direction) * CFrame.Angles(0,0,math.rad(spreadAngle))
			spreadDirection = spreadDirection * CFrame.Angles(spreadMagnitude,0,0)
			spreadDirection = spreadDirection.LookVector

			local part, pos, norm, material = utils.RecursiveRay(origin, spreadDirection * 500, params)
			table.insert(hits, {part, pos, norm, material})
		end
	end

	return hits
end

function bullet:Visualize(calledByThisPlayer, tool, hits, config)
	local tool = player.Character:FindFirstChild(tool.Name)
	local firingPoint = tool.Muzzle
	
	local gunMuzzle = firingPoint.CFrame.LookVector
	local cameraVector = workspace.CurrentCamera.CFrame.LookVector
	local angle = math.acos(gunMuzzle:Dot(cameraVector))
	firingPoint.Flash1.Flash:Emit(1)
	firingPoint.Fire:Play()

	for _,hit in ipairs(hits) do
		local part, pos, norm, material = unpack(hit)

		if part then
			material = material.Name

			local hitAttachment = Instance.new("Attachment", workspace.Terrain)
			local humanoid = part.Parent:FindFirstChild("Humanoid")
			if humanoid then
				hitAttachment.CFrame = CFrame.new(pos)

				local blood1 = gunSystem.Particles.Blood1:Clone()
				blood1.Parent = hitAttachment
				blood1:Emit(20)

				local blood2 = gunSystem.Particles.Blood2:Clone()
				blood2.Parent = hitAttachment
				blood2:Emit(12)

				local sound = gunSystem.Sounds.Blood:GetChildren()[math.random(1, #gunSystem.Sounds.Blood:GetChildren())]:Clone()
				sound.Parent = hitAttachment
				sound.Pitch = math.random(100*(sound.Pitch - 0.1), 100*(sound.Pitch + 0.1))/100
				sound:Play()
			else
				hitAttachment.CFrame = CFrame.new(pos, pos + norm)

				if material == "Metal" or material == "DiamondPlate" or material == "CorrodedMetal" then
					local particle1 = gunSystem.Particles.Metal:Clone()
					particle1.Parent = hitAttachment
					particle1:Emit(15)

					local sound = gunSystem.Sounds.Metal:Clone()
					sound.Parent = hitAttachment
					sound.Pitch = math.random(100*(sound.Pitch - 0.1), 100*(sound.Pitch + 0.1))/100
					sound:Play()
				elseif material == "Wood" or material == "WoodPlanks" then
					local particle1 = gunSystem.Particles.Wood:Clone()
					particle1.Parent = hitAttachment
					particle1:Emit(7)

					local sound = gunSystem.Sounds.Wood:Clone()
					sound.Parent = hitAttachment
					sound.Pitch = math.random(100*(sound.Pitch - 0.1), 100*(sound.Pitch + 0.1))/100
					sound:Play()
				elseif material == "Neon" then
					local particle1 = gunSystem.Particles.Neon:Clone()
					particle1.Color = ColorSequence.new(part.Color)
					particle1.Parent = hitAttachment
					particle1:Emit(15)

					local particle2 = gunSystem.Particles.Neon2:Clone()
					particle2.Parent = hitAttachment
					particle2:Emit(1)

					local sound = gunSystem.Sounds.Neon:Clone()
					sound.Parent = hitAttachment
					sound.Pitch = math.random(100*(sound.Pitch - 0.1), 100*(sound.Pitch + 0.1))/100
					sound:Play()
				else
					local particle1 = gunSystem.Particles.Smoke:Clone()
					particle1.Parent = hitAttachment
					particle1:Emit(15)

					local sound = gunSystem.Sounds.BulletHit:GetChildren()[math.random(1, #gunSystem.Sounds.BulletHit:GetChildren())]:Clone()
					sound.Parent = hitAttachment
					sound.Pitch = math.random(100*(sound.Pitch - 0.15), 100*(sound.Pitch + 0.15))/100
					sound:Play()
				end
			end


			game.Debris:AddItem(hitAttachment, 4)
		end

		local velocity = 800
		local distance = (pos - firingPoint.Position).Magnitude

		if distance > 10 then
			local tracer = gunSystem.Objects.Tracer:Clone()
			tracer.Parent = workspace
			tracer.CFrame = CFrame.new(firingPoint.Position, pos)
			tracer.Velocity = tracer.CFrame.LookVector * velocity
			local force = Instance.new("BodyForce", tracer)
			force.Force = Vector3.new(0, tracer.Mass * workspace.Gravity, 0)
			task.spawn(function()
				tracer.Anchored = true
				game:GetService("RunService").RenderStepped:Wait()
				tracer.Anchored = false
				--^ roblox trail oddities /shrug

				task.wait(((pos - firingPoint.Position).Magnitude - 15)/velocity)
				tracer.Anchored = true
				tracer.Trail.Enabled = false
				game.Debris:AddItem(tracer, 1)
			end)
		end

		local shootLine = (pos - firingPoint.Position)
		if shootLine.Magnitude > 10 then
			local originToPlayer = (player.Character.Head.Position - firingPoint.Position)

			local projectionLength = (shootLine:Dot(originToPlayer)/(shootLine.Magnitude^2))

			projectionLength = math.clamp(projectionLength, 10/shootLine.Magnitude, 1)
			local whizzPoint = shootLine*projectionLength + firingPoint.Position
			--^ whizzPoint is a vector projection from the player's head to the vector representing the shooting line (where the tracer went)

			if (whizzPoint - player.Character.Head.Position).Magnitude < 10 then
				local attachment = Instance.new("Attachment", workspace.Terrain)
				attachment.Position = whizzPoint

				local sound = gunSystem.Sounds.BulletCrack:GetChildren()[math.random(1, #gunSystem.Sounds.BulletCrack:GetChildren())]:Clone()
				sound.Parent = attachment
				sound.Pitch = math.random(100*(sound.Pitch - 0.15), 100*(sound.Pitch + 0.15))/100
				sound:Play()

				game.Debris:AddItem(attachment, 2)
			end
		end
	end
end

return bullet