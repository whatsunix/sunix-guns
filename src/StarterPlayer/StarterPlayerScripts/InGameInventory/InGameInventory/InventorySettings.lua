--  // FileName: InventorySettings.lua
--  // Author: cSunix
--  // Handles the inventory customisation.

return {
	InventoryContainer = {
		BackgroundTransparency = 1,
		SizeOffset = UDim2.fromOffset(30, 70)
	},
	InventoryButton = {
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.8,
		SizeOffset = UDim2.fromOffset(50, 50),
		OutlineSizePixel = 0,

		TextColor3 = Color3.new(1, 1, 1),
		TextStrokeTransparency = 1,
		TextStrokeColor3 = Color3.new(1, 1, 1),
		
		TextSize = 7
	}
}