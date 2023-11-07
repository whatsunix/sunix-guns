--  //  FileName: Verify.lua
--  //  Author: cSunix
--  //  Handles the verification checks of the gun system.

--  // Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--  // Dependencies
local Modules = script.Parent.Parent:WaitForChild("Modules")

local Exception = require(Modules:WaitForChild("Exception"))
local Maid = require(Modules:WaitForChild("Maid"))
local Utils = require(Modules:WaitForChild("Utils"))

--  // Logic & Enums
local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")

--  // Functions
local Verify = {}

function Verify.GunHasAmmo(player, tool): boolean
	if player:GetAttribute(("Ammo"..tool.Name)) then
		return player:GetAttribute(("Ammo"..tool.Name)) > 0
	end
	
	return false
end

return Verify