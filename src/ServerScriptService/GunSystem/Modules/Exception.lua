--!strict
--  //  FileName: Exception.lua
--  //  Author: cSunix
--  //  Non-yielding exception wrapper with an integrated
--  //  warning resolve.
--  //  @function Exception

local format = "An exception occured '%s'.\n%s"

return function(callback: (any?) -> any?)
	assert(typeof(callback) == "function", "'callback' must be a function")
	
	-- Create a simple protected call on the given callback and
	-- simply apply formats upon an exception. An unexpensive
	-- method in conflict to the likes of promises.
	xpcall(callback, function(...)
		warn(format:format(..., debug.traceback()))
	end)
end