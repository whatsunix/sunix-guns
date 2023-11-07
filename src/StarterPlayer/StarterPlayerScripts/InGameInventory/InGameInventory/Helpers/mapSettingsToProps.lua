local Maps = {
	["BackgroundColor3"] = "BackgroundColor3",
	["BackgroundTransparency"] = "BackgroundTransparency",
	["SizeOffset"] = "Size",
	["OutlineSizePixel"] = "BorderSizePixel",
	["TextColor3"] = "TextColor3",
	["TextStrokeTransparency"] = "TextStrokeTransparency",
	["TextStrokeColor3"] = "TextStrokeColor3",
	["Text"] = "Text",
	["TextSize"] = "TextSize"
}

return function(settings)
	local newMap = {}
	for setting, value in next, settings do
		if Maps[setting] then
			newMap[Maps[setting]] = value
		end
	end
	
	return newMap
end