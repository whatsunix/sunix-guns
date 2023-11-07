--  // FileName: Utils.lua
--  // Author: cSunix
--  // Provides an array of useful gun-class-orientated
--  // functions.

--  // Dependencies
local GunSystem = game:GetService("ReplicatedStorage"):WaitForChild("GunSystem")
local GunStats = GunSystem:WaitForChild("GunStats")

--  // Functions
local Utils = {}

-- Returns the server-sided gun stats module provided in the GunStats
-- folder or false if none is present. (is not void to prevent errors).
function Utils.GetGunStats(tool: Tool): {[string]: number | string} | boolean
	if GunStats[tool.Name] then
		return require(GunStats[tool.Name]) --luacheck: nocheck
	end
	return false
end

return Utils