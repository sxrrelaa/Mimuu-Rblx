local players = game:GetService("Players")

function playerSpawned(player)
	local leaderstats = Instance.new("Folder", player)
	leaderstats.Name = "leaderstats"
	
	local coins = Instance.new("IntValue", leaderstats)
	coins.Name = "Coins"
	coins.Value = 0 
end

players.PlayerAdded:Connect(playerSpawned)