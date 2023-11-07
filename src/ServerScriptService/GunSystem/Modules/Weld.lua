return function(p0, p1)
	local weld = Instance.new("Weld")
	weld.Parent = p0
	weld.Name = "RoactToolGripWeld"
	weld.Part0 = p0
	weld.Part1 = p1
	weld.C0 = CFrame.new(0, 0, 0) + Vector3.new(0,p0.Size.Y/2,0)
	
	return weld
end