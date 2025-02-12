local coin = game.ServerStorage.Coin

while true do
	local clone = coin:Clone()
	clone.Parent = game.Workspace
	clone.Position = Vector3.new(math.random(-226, 234), 2.834, math.random(-230, 231))
	wait(math.random(1, 5))
end
testing 1