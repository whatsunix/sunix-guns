--!strict
--  //  FileName: Inventory.lua
--  //  Author: cSunix
--  //  Handles the management and API of the inventory.

--  // Roblox Services
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPack = game:GetService("StarterPack")
local UserInputService = game:GetService("UserInputService")

--  // Dependencies
local InGameInventory = script.Parent.Parent:WaitForChild("InGameInventory")
local InventoryButton = require(InGameInventory:WaitForChild("Components"):WaitForChild("InventoryButton"))

local Maid = require(script:WaitForChild("Maid"))
local Promise = require(script.Parent.Promise)
local Signal = require(script:WaitForChild("Signal"))

--  // Logic & Enums
local GunSystem = ReplicatedStorage:WaitForChild("GunSystem")
local Remotes = GunSystem:WaitForChild("Remotes")

local ReplicateCustomTool = Remotes:WaitForChild("ReplicateCustomTool")

local TOOL_TAG = "Tool"

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local Keycodes = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2
}

-------------------------------------
-- //     PRIVATE FUNCTIONS     // --
-------------------------------------
-- This will be ran on the condition that the Roact
-- inventory already exists.
local function ToolExists(tool)
	local InGameInventory = PlayerGui:FindFirstChild("InGameInventory")
	local Container = InGameInventory:FindFirstChild("Container")
	
	if Container:FindFirstChild(tool) then
		return true
	end
	
	return false
end

-------------------------------------
-- //           CLASS           // --
-------------------------------------
local Inventory = {}
Inventory.__index = Inventory

function Inventory.new()
	local self = setmetatable({}, Inventory)
	self.Event = setmetatable({}, Inventory.Event)
	self.Event.self = self
	
	self.Tools = {} :: {Folder}
	self.Equipped = nil :: Instance?
	self.Connections = Maid.new()
	self.Signals = {}
	
	self.Signals.ToolEquipped = Signal.new()
	self.Signals.ToolUnequipped = Signal.new()
	
	self.Event:InitializeTools()
	self.Event:ConnectUserInput()
	
	self.Character = Player.Character
	
	return self
end

function Inventory:RemovePhysicalTools()
	if self.Character:FindFirstChildOfClass("Folder") then
		local tool = self.Character:FindFirstChildOfClass("Folder")
		if CollectionService:HasTag(tool, TOOL_TAG) then
			ReplicateCustomTool:FireServer(tool, true)
		end
	end
end

function Inventory:WeldTool(tool)
	self:RemovePhysicalTools()
	
	ReplicateCustomTool:FireServer(tool, false)
end

Inventory.Event = {}
Inventory.Event.__index = Inventory.Event

-- Initializes tools into the classes' tool array for client implementation.
-- We can use `self.Tools: {Folder}` to set up the Roact toolbar.
function Inventory.Event:InitializeTools()
	local _self = self.self
	local eventSelf = self -- We create a memory variable to allow access inside private methods.
	
	for _, starterTool in pairs(StarterPack:GetChildren()) do
		if starterTool:IsA("Folder") and CollectionService:HasTag(starterTool, TOOL_TAG) then
			-- Modify the tool if it exists.
			local thread = Promise.new(function(resolve)
				resolve(ToolExists(starterTool.Name))
			end):andThen(function(toolExists)
				if toolExists then
					--TODO: fire the # of tools that exist of this name as a 2nd param
					starterTool.Name = starterTool.Name .. " (1)"
				end
			end):catch(warn)
			
			local toolInsertArray = #_self.Tools+1
			_self.Tools[toolInsertArray] = starterTool
			
			function InventoryButton:didMount()
				print(`Mounted {starterTool.Name}.`)
				PlayerGui:FindFirstChild(starterTool.Name).Parent = PlayerGui.InGameInventory.Container
				
				--TODO: link this with the roact.Events maybe?
				local RoactButtonElement = PlayerGui.InGameInventory.Container:FindFirstChild(starterTool.Name)
				_self.Connections:giveTask(RoactButtonElement.MouseButton1Down:Connect(function()
					eventSelf:ToolChanged(starterTool)
				end))
			end
			
			InventoryButton.mount(starterTool.Name)
		end
	end
end

function Inventory.Event:ToolChanged(toolObject)
	local _self = self.self
	
	if _self.Equipped  then
		_self:RemovePhysicalTools()
		_self.Signals.ToolUnequipped:Fire(toolObject)
		if _self.Equipped ~= toolObject then
			_self.Equipped = nil
			self:ToolChanged(toolObject)
		else
			_self.Equipped = nil
		end
	else
		_self:WeldTool(toolObject)
		_self.Equipped = toolObject
		_self.Signals.ToolEquipped:Fire(toolObject)
	end
end

function Inventory.Event:ConnectUserInput()
	local _self = self.self
	UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean) 
		if not gameProcessedEvent and Keycodes[input.KeyCode] then
			-- From here we can simply use the premade Event API
			-- to apply the tool script the exact same as if the
			-- roact element is clicked.
			local ToolIndex = Keycodes[input.KeyCode]
			if _self.Tools[ToolIndex] then
				self:ToolChanged(_self.Tools[ToolIndex])
			end
		end
	end)
end


return Inventory 
