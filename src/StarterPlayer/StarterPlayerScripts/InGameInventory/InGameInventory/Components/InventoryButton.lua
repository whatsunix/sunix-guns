--  // FileName: InventoryButton.lua
--  // Author: cSunix
--  // Inventory button component.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = game.Players.LocalPlayer.PlayerGui

local Helpers = script.Parent.Parent.Helpers
local Types = require(script.Parent.Parent.Types)

local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local t = require(ReplicatedStorage:WaitForChild("t"))
local inventoryContainer = require(script.Parent.InventoryContainer)

local mapSettingsToProps = require(Helpers.mapSettingsToProps)
local inventorySettings = require(script.Parent.Parent.InventorySettings)
local layoutSettings = require(script.Parent.layout.Settings)

local app = Roact.Component:extend("button")
app.validateProps = Types.IButtonSettings

function app:render()
	return Roact.createElement("TextButton", mapSettingsToProps(self.props))
end

function app:didMount()
	-- app:didMount() should be ran in a toolChanged module to allow
	-- for a direct reference to prevent a race condition on the
	-- roact element component.
	warn("app:didMount() is abstract is needs to be overwritten!")
end

function app.mount(name)
	local nProps = inventorySettings.InventoryButton
	nProps["Text"] = name
	
	return Roact.mount(Roact.createElement(app, nProps), PlayerGui, name)
end

return app
