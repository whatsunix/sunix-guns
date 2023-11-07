--!strict
--  //  FileName: Shotgun.lua
--  //  Author: cSunix
--  //  Derived class of the BaseGun class which handles
--  //  a shotgun mechanism of bullet casting.

--  // Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--  // Dependencies
local Modules = script.Parent.Parent.Parent:WaitForChild("Modules")
local Classes = script.Parent.Parent.Parent:WaitForChild("Classes")

local Exception = require(Modules:WaitForChild("Exception"))
local Maid = require(Modules:WaitForChild("Maid"))
local Utils = require(Modules:WaitForChild("Utils"))
local Verify = require(Modules:WaitForChild("Verify"))

local BaseGun = require(Classes:WaitForChild("BaseGun"))

--  // Logic & Enums
local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")

local Remotes = GunSystem:WaitForChild("Remotes")

-------------------------------------
-- //           CLASS           // --
-------------------------------------
local Shotgun = {}
Shotgun.__index = Shotgun
setmetatable(Shotgun, BaseGun)

function Shotgun:Cast(tool, config, ...)
	-- Shotgun:Cast(...) when a player sends the remote from the gun
	-- at hand, and in turn this fires the shotgun's casting method.
	
	local hitReg = {}
	local damageDealt = false
	
	for index, hit in ipairs(...) do
		if index > config.MaxPellets then
			warn("Impossible pellets!")
			break
		end

		local part, pos, norm, material = unpack(hit)

		if part and part.Parent then
			local humanoid = part.Parent:FindFirstChild("Humanoid")
			if not humanoid then
				humanoid = part.Parent.Parent:FindFirstChild("Humanoid")
			end
			if humanoid and humanoid.Health > 0 then
				local resDamage = self:DealDamage(humanoid, config.PelletDamage)
				damageDealt = true
			end
		end
		table.insert(hitReg, {part, pos, norm, part and (part == workspace.Terrain and material or part.Material) or material})
	end
end

return Shotgun