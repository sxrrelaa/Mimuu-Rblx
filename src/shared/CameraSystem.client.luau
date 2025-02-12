-- Camera Config
local playerOffset = Vector3.new(0, 20, -50) -- Adjusted offset for visibility
local playerPosOffset = Vector3.new(0, 0, 0)
local fieldOfView = 10 -- Small but functional for orthographic simulation
local zoom = 4 -- More reasonable zoom value

-- Services and References
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")

-- Initial Camera Setup
camera.FieldOfView = fieldOfView
camera.CameraType = Enum.CameraType.Scriptable

runService:BindToRenderStep("BeforeCamera", Enum.RenderPriority.Camera.Value, function()
	if player.Character and player.Character.PrimaryPart then
		local playerPosition = player.Character.PrimaryPart.Position + playerPosOffset
		local cameraPosition = playerPosition + (playerOffset * zoom)

		camera.CFrame = CFrame.lookAt(cameraPosition, playerPosition) -- Fixes deprecated method
		camera.Focus = CFrame.new(playerPosition) -- Keeps the world loading correctly
	end
end)
