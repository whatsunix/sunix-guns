--  // FileName: InventoryContainer.lua
--  // Author: cSunix
--  // Inventory container component.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Helpers = script.Parent.Parent.Helpers
local Types = require(script.Parent.Parent.Types)

local Roact = require(ReplicatedStorage:WaitForChild("Roact"))
local t = require(ReplicatedStorage:WaitForChild("t"))

local mapSettingsToProps = require(Helpers.mapSettingsToProps)
local inventorySettings = require(script.Parent.Parent.InventorySettings)
local layoutSettings = require(script.Parent.layout.Settings)

local app = Roact.Component:extend("container")
app.validateProps = Types.ISettings

function app:render()
	-- This will be the frame that is used to
	-- hold the inventory buttons.
	local map = mapSettingsToProps(self.props)
	return Roact.createElement("Frame", map, {
		Layout = Roact.createElement("UIListLayout", layoutSettings)
	})
end

function app:didMount()
	-- We keep this method abstract to allow the container to properly load
	-- before initializing our inventory tools.
	warn("app:didMount() is abstract and needs to be overwritten!")
end

return app
