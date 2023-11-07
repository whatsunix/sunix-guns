local utils = {}

utils.RecursiveRay = function(origin, direction, params, ignoreHumanoid)
	local result = workspace:Raycast(origin, direction, params)

	if result and result.Instance then
		if ignoreHumanoid and result.Instance.Parent:FindFirstChild("Humanoid") then
			params.FilterDescendantsInstances = {result.Instance.Parent,unpack(params.FilterDescendantsInstances)}
			return utils.RecursiveRay(origin, direction, params, ignoreHumanoid)
		else
			if result.Instance.CanCollide and result.Instance.Name ~= "HumanoidRootPart" then
				return result.Instance, result.Position, result.Normal, result.Material
			else
				if result.Instance.Parent:FindFirstChild("Humanoid") and result.Instance.Name ~= "HumanoidRootPart" then
					return result.Instance, result.Position, result.Normal, result.Material
				end
				params.FilterDescendantsInstances = {result.Instance,unpack(params.FilterDescendantsInstances)}
				return utils.RecursiveRay(origin, direction, params, ignoreHumanoid)
			end
		end
	end
	return nil, origin + direction, Vector3.new(0,1,0), nil
end

utils.GetMouseHit = function(x, y, filter)
	local camera = workspace.CurrentCamera
	local player = game.Players.LocalPlayer
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = filter or {player.Character}
	params.IgnoreWater = true

	local ray = camera:ScreenPointToRay(
		x,
		y,
		(player.Character.Head.Position - camera.CFrame.Position).magnitude
	)
	local _,mouseHitPoint = utils.RecursiveRay(ray.Origin, ray.Direction * 300, params)
	return mouseHitPoint
end

function utils.Lerp(a,b,t)
	return a + (b-a)*t
end

return utils