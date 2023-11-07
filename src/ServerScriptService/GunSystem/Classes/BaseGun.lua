--  //  FileName: BaseGun.lua
--  //  Author: cSunix
--  //  Abstract server-side implementation primarily
--  //  adjusts to allow the customisation of shooting mechanisms
--  //  for different gun types.

type GunTool = Tool & {
	Ammo: IntValue
}

--  // Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

--  // Dependencies
local Modules = script.Parent.Parent:WaitForChild("Modules")

local Exception = require(Modules:WaitForChild("Exception"))
local Maid = require(Modules:WaitForChild("Maid"))
local Utils = require(Modules:WaitForChild("Utils"))
local Verify = require(Modules:WaitForChild("Verify"))

--  // Logic & Enums
local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")

local Remotes = GunSystem:WaitForChild("Remotes")

-------------------------------------
-- //     PRIVATE FUNCTIONS     // --
-------------------------------------
-- // Debug function alternative assert
-- // warns of the error passed and calls the given
-- // function with the parameters given.
local function handleAssertion(_error: string, callback: (any?) -> nil, ...)
	warn(("An exception occured in the BaseGun.\n'%s'\n%s"):format(
		_error,
		debug.traceback()
		))
	
	callback(...)
end

-------------------------------------
-- //           CLASS           // --
-------------------------------------
local BaseGun = {}
BaseGun.__index = BaseGun

function BaseGun:HandleRemote(player: Player, tool: GunTool, remote: string, ...): nil
	local config = Utils.GetGunStats(tool)
	if not config then
		warn(("Tool '%s' has no config file!"):format(tool.Name))
		return nil
	end
	
	if remote == "Fire" then
		if Verify.GunHasAmmo(player, tool) then
			-- Ammo is verified, deduct one.
			player:SetAttribute("Ammo"..tool.Name, player:GetAttribute("Ammo"..tool.Name)-1)
			Remotes:FindFirstChild("GunEvent"):FireClient(player, "UpdateAmmoCounter", player:GetAttribute("Ammo"..tool.Name))
			
			self:Cast(tool, config, ...)
		else	
			local AmmoValue = player:GetAttribute("Ammo"..tool.Name)
			Remotes:FindFirstChild("GunEvent"):FireClient(player, "UpdateAmmoCounter", AmmoValue)
		end
	elseif remote == "Setup" then
		if not player:GetAttribute(("Ammo"..tool.Name)) then
			player:SetAttribute("Ammo"..tool.Name, config.MaxAmmo)
			
			Remotes:FindFirstChild("GunEvent"):FireClient(player, "UpdateAmmoCounter", player:GetAttribute("Ammo"..tool.Name))
		end
	elseif remote == "Reload" then
		task.delay(config.ReloadTime, function()
			local AmmoValue = player:GetAttribute("Ammo"..tool.Name)
			if AmmoValue < config.MaxAmmo then
				player:SetAttribute("Ammo"..tool.Name, config.MaxAmmo)
				Remotes:FindFirstChild("GunEvent"):FireClient(player, "UpdateAmmoCounter", player:GetAttribute("Ammo"..tool.Name))
			end
		end)
	end
	
	return nil
end

function BaseGun:DealDamage(humanoid: Humanoid, caliber: number, limb: string)
	if limb == "Head" then
		caliber*=2
	end
	
	humanoid:TakeDamage(caliber)
end

function BaseGun:Cast(tool, _)
	-- BaseGun:Cast() will be redefined by the derived class
	-- in the main gun class for the tool. This allows the
	-- tool to have more adjustability on its casting mechanism
	-- allowing for the integration of different gun types outside
	-- normal guns.
	warn("BaseGun:Cast(...) is abstract and should be overwritten!")
end

return BaseGun