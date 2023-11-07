--  //  FileName: GunSystem.lua
--  //  Author: cSunix
--  //  Handles the networking and execution from the client
--  //  regarding the gun system.

--  // Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local StarterPack = game:GetService("StarterPack")

--  // Dependencies
local Modules = script:WaitForChild("Modules")
local Classes = script:WaitForChild("Classes")

local Exception = require(Modules:WaitForChild("Exception"))
local Maid = require(Modules:WaitForChild("Maid"))
local Utils = require(Modules:WaitForChild("Utils"))
local Weld = require(Modules:WaitForChild("Weld"))

--  // Logic & Enums
local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")
local Remotes = GunSystem:WaitForChild("Remotes")
local GunEvent = Remotes:WaitForChild("GunEvent")
local ReplicateCustomTool = Remotes:WaitForChild("ReplicateCustomTool")

local GunStats = GunSystem:WaitForChild("GunStats")
local GunClasses = Classes:WaitForChild("GunClasses")

-------------------------------------
-- //     PRIVATE FUNCTIONS     // --
-------------------------------------
GunEvent.OnServerEvent:Connect(function(player, tool, event, ...)
	local tool = player.Character:FindFirstChild(tool)
	
	if (not tool)
		or player.Character.Humanoid.Health < 1
		or not Utils.GetGunStats(tool) then
		
		return false
	end
	
	local gunConfig = Utils.GetGunStats(tool)
	
	-- You can hardcode something here
	require(GunClasses[gunConfig.GunType]):HandleRemote(player, tool, event, ...)
	
	return true
end)

ReplicateCustomTool.OnServerEvent:Connect(function(player, tool, unEquipping: boolean)
	if (not tool)
		or (tool.Parent ~= StarterPack and tool.Parent ~= player.Character) then
		return false
	end
	
	
	local character = player.Character
	if not unEquipping then
		local toolWeld = tool:Clone()
		toolWeld.Parent = player.Character

		Weld(toolWeld.Handle, character.RightHand)
	else
		local tool = player.Character:FindFirstChild(tool.Name)
		if tool then
			tool:Destroy()
		end
	end

	return true
end)