--  // FileName: App.lua
--  // Author: cSunix
--  // Inventory entry point.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local Helpers = script.Parent.Parent.Helpers
local Types = require(script.Parent.Parent.Types)

local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local t = require(ReplicatedStorage:WaitForChild("t"))
local inventoryContainer = require(script.Parent.InventoryContainer)

local mapSettingsToProps = require(Helpers.mapSettingsToProps)
local inventorySettings = require(script.Parent.Parent.InventorySettings).InventoryContainer
local layoutSettings = require(script.Parent.layout.Settings)

local app = Roact.Component:extend("app")
app.validateProps = Types.ISettings

function app:render()
	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false
	}, {
		Layout = Roact.createElement("UIListLayout", layoutSettings)
	})
end

function app:didMount()
	local InGameInventory = PlayerGui["InGameInventory"]
	Roact.mount(Roact.createElement(inventoryContainer, inventorySettings), InGameInventory, "Container")
end

Roact.mount(Roact.createElement(app), PlayerGui, "InGameInventory")

return app
