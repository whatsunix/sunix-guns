--  // FileName: GunSystem.lua
--  // Author: cSunix
--  // Handles the general root of the client implementation gun system.

--  // :: NOTICE ::
--  // The GunSystem inherits the creation of the inventory, this can be made
--  // separate by simplying caching the inventory class!
--  // Please review the `Docs` for both systems found in their repository.

--  // Roblox Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

--  // Dependencies
local InGameInventory = script.Parent:WaitForChild("InGameInventory")

local roact = require(game.ReplicatedStorage:WaitForChild("Roact"))
local container = require(InGameInventory.InGameInventory.Components.InventoryContainer)

local promise = require(InGameInventory.NoRoact.Promise)

--  // Logic & Enums
local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")
local Remotes = GunSystem:WaitForChild("Remotes")
local GunStats = GunSystem:WaitForChild("GunStats")

local GunEvent = Remotes:WaitForChild("GunEvent")

-- We're only using a Shotgun so we don't need to localize each local gun state.
local Equipped = false
local GunUI = PlayerGui:WaitForChild("Gun")
local Tool: Folder? = nil
local Ammo = 0
local LastShot = tick()

-------------------------------------
-- //     PRIVATE FUNCTIONS     // --
-------------------------------------
local function IsToolGun(tool: Folder)
	if CollectionService:HasTag(tool, "Gun") then
		return true
	end
	
	return false
end

-------------------------------------
-- //       MAIN FUNCTIONS      // --
-------------------------------------
local function GunEquipped(tool: Folder)
	if IsToolGun(tool) then
		Equipped = true
		GunUI.Enabled = true
		Tool = tool
		
		-- Setup Shotgun if it is the first time.
		if Tool then
			GunEvent:FireServer(Tool.Name, "Setup")
		end
	end
end

local function GunUnequipped(tool: Folder)
	if IsToolGun(tool) then
		GunUI.Enabled = false
		Equipped = false
		Tool = nil
	end
end

local function Fire()
	if Tool then
		local gunConfig = require(GunStats:FindFirstChild(Tool.Name))
		
		if (tick()-LastShot) < gunConfig.Firerate / 60 then
			return false
		end
		
		LastShot = tick()
		
		local mouseLocation = UserInputService:GetMouseLocation()
		local gunBullet = require(script.Projectiles.Bullet)
		
		local bulletCastResult = {gunBullet:Cast(
			gunConfig,
			mouseLocation.X,
			mouseLocation.Y - 36,
			gunConfig.Spread
			)}
		
		gunBullet:Visualize(true, Tool, unpack(bulletCastResult))
		GunEvent:FireServer(Tool.Name, "Fire", unpack(bulletCastResult))
	end
end

local function Reload()
	if Tool then
		GunEvent:FireServer(Tool.Name, "Reload")
	end
end

UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
	if not gameProcessedEvent and Equipped and Tool then
		if input.UserInputType == Enum.UserInputType.MouseButton1 and Ammo > 0 then
			-- Fire the weapon at this point, from here we will calculate
			-- the visualizations on the client to reduce the expensiveness
			-- of the gun system, however the actual infliction will be
			-- server-implemetation.
			Fire()
		elseif input.KeyCode == Enum.KeyCode.R then
			Reload()
		end
	end
end)

-------------------------------------
-- //       INIT FUNCTIONS      // --
-------------------------------------
GunEvent.OnClientEvent:Connect(function(action, ...)
	if action == "UpdateAmmoCounter" then
		GunUI.AmmoCounter.Text = ...
		Ammo = ...
		if (... == 0) then
			GunUI.Reload.Visible = true
		else
			GunUI.Reload.Visible = false
		end
	end
end)

local mustMountInventory = promise.new(function(resolve)
	function container:didMount()
		warn("Inventory container has mounted.")
		
		local inventory = require(InGameInventory.NoRoact.Inventory)
		local inventoryClass = inventory.new()
		
		inventoryClass.Signals.ToolEquipped:Connect(GunEquipped)
		inventoryClass.Signals.ToolUnequipped:Connect(GunUnequipped)
		
		resolve()
	end
	require(InGameInventory.InGameInventory.Components.App)
end)

mustMountInventory:timeout(5):andThen(function()
	print("Client.InGameInventory has successfully started.")
end):catch(warn)
