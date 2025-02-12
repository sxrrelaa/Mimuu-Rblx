
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local coin = script.Parent
local sound = coin:FindFirstChild("CoinPickUpEffect")  -- Ensure sound exists
local used = false

-- Spin Animation
local goal = {Orientation = Vector3.new(0, 360, 0)}
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
local tween = TweenService:Create(coin, tweenInfo, goal)
tween:Play() -- Start spinning the coin

-- Coin Pickup Function
local function giveCoin(part)
	if used then return end  -- Prevent multiple pickups
	local character = part.Parent
	local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
	local player = Players:GetPlayerFromCharacter(character)

	if humanoid and player then
		used = true

		-- Clone sound, play it, then destroy the coin instantly
		if sound then
			local soundClone = sound:Clone()
			soundClone.Parent = workspace  -- Put it in workspace so it can be heard
			soundClone:Play()
			game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength) -- Remove sound after it finishes
		end

		-- Increase coin count
		player.leaderstats.Coins.Value = player.leaderstats.Coins.Value + 1

		-- Destroy the coin instantly
		coin:Destroy()
	end
end

coin.Touched:Connect(giveCoin)
