--  // FileName: Types.lua
--  // Author: cSunix
--  // Handles t strict interface types for the inventory.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local t = require(ReplicatedStorage:WaitForChild("t"))
local Types = {}

Types.ISettings = t.strictInterface({
	BackgroundTransparency = t.optional(t.number),
	SizeOffset = t.optional(t.UDim2)
})

Types.IButtonSettings = t.strictInterface({
	BackgroundColor3 = t.optional(t.Color3),
	BackgroundTransparency = t.optional(t.number),
	SizeOffset = t.optional(t.UDim2),
	ButtonCorner = t.optional(t.boolean),
	CornerRadius = t.optional(t.number),
	ButtonOutline = t.optional(t.boolean),
	OutlineSizePixel = t.optional(t.number),
	
	TextColor3 = t.optional(t.Color3),
	TextStrokeTransparency = t.optional(t.number),
	TextStrokeColor3 = t.optional(t.Color3),
	
	TextScaled = t.optional(t.boolean)
})

-----------------
--  // Layout
-----------------

Types.ILayoutSettings = t.strictInterface({
	FillDirection = t.optional(t.EnumItem),
	HorizontalAlignment = t.optional(t.EnumItem),
	VerticalAlignment = t.optional(t.EnumItem),
	Padding = t.optional(t.UDim)
})

return Types