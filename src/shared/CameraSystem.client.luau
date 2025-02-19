local playerOffset = Vector3.new(0, 20, -50)
-- Camera Config
local playerOffset = Vector3.new(0, 20, -50) -- Adjusted offset for visibility
local playerPosOffset = Vector3.new(0, 0, 0)
local fieldOfView = 10 -- Small but functional for orthographic simulation
local zoom = 4 -- More reasonable zoom value

-- Services and References
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {player.Character}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- Zoom setup
local zoomLevel = 30
local minZoom = 24
local maxZoom = 170
local zoomSpeed = 10

local fieldOfView = 10
-- Initial Camera Setup
camera.FieldOfView = fieldOfView
camera.CameraType = Enum.CameraType.Scriptable

local bobbingAmplitude = 0.5
local bobbingSpeed = 2
local timeElapsed = 0
local rotationAngle = 0
local pitchAngle = math.rad(-30)
local rotationSpeed = math.rad(15)

local mouseSensitivity = 0.0008
local lastMousePosition = nil
local isLeftMouseDown = false
local isMouseDown = false
local smoothRotationAngle = 0
local smoothPitchAngle = 0

local maxRotationAngle = math.rad(20)
local minRotationAngle = math.rad(-20)
local maxPitchAngle = math.rad(20)
local minPitchAngle = math.rad(-34)

local function adjustCameraPosition(root, rotatedOffset)
	local cameraTarget = root.Position + rotatedOffset
	local direction = (cameraTarget - root.Position).unit
	local raycastResult = workspace:Raycast(root.Position, direction * (rotatedOffset.Magnitude - 5), raycastParams)

	if raycastResult then
		local shiftDirection = Vector3.new(-direction.Z, 0, direction.X)
		rotatedOffset = rotatedOffset + shiftDirection * 10
	end

	return rotatedOffset
end


-- Setting Starting Position for Camera
local playerOffset = Vector3.new(0, 30, -40)  -- Change the initial camera position
local player = game.Players.LocalPlayer
local camera = game.Workspace.CurrentCamera
local zoomLevel = 100  -- Set the default zoom level to 30
local pitchAngle = math.rad(-20) -- Default tilt down

-- Set initial camera position
camera.CFrame = CFrame.new(player.Character.PrimaryPart.Position + playerOffset)



-- Mouse input for camera rotation
userInputService.InputChanged:Connect(function(input, gameProcessed)
	if gameProcessed or not isLeftMouseDown then return end
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		local currentMousePosition = input.Position
		if lastMousePosition then
			local delta = currentMousePosition - lastMousePosition
			rotationAngle = rotationAngle - delta.X * mouseSensitivity
			pitchAngle = pitchAngle - delta.Y * mouseSensitivity

			rotationAngle = math.clamp(rotationAngle, minRotationAngle, maxRotationAngle)
			pitchAngle = math.clamp(pitchAngle, minPitchAngle, maxPitchAngle)
		end
		lastMousePosition = currentMousePosition
	end
end)

userInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isLeftMouseDown = true
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isLeftMouseDown = false
	end
end)

userInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Q then
		rotationAngle = rotationAngle - rotationSpeed
	elseif input.KeyCode == Enum.KeyCode.E then
		rotationAngle = rotationAngle + rotationSpeed
	end
	rotationAngle = math.clamp(rotationAngle, minRotationAngle, maxRotationAngle)
end)

-- Scroll Zoom Input
userInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		zoomLevel = math.clamp(zoomLevel - input.Position.Z * zoomSpeed, minZoom, maxZoom)
	end
end)

local function smoothDamp(current, target, smoothTime, deltaTime)
	return current + (target - current) * smoothTime * deltaTime
end

-- Camera update loop
runService:BindToRenderStep("BeforeCamera", Enum.RenderPriority.Camera.Value, function(deltaTime)
	if player.Character and player.Character.PrimaryPart then
		local root = player.Character.PrimaryPart
		local playerPosition = root.Position + playerPosOffset

		smoothRotationAngle = smoothDamp(smoothRotationAngle, rotationAngle, 5, deltaTime)
		smoothPitchAngle = smoothDamp(smoothPitchAngle, pitchAngle, 5, deltaTime)

		local horizontalRotation = CFrame.Angles(0, smoothRotationAngle, 0)
		local verticalRotation = CFrame.Angles(smoothPitchAngle, 0, 0)

		-- Swap out 'zoom' for zoomLevel 👇
		local rotatedOffset = (horizontalRotation * verticalRotation) * playerOffset.Unit * zoomLevel

		local moveDirection = root.Velocity * Vector3.new(1, 0, 1)
		if moveDirection.Magnitude > 0.1 then
			timeElapsed = timeElapsed + deltaTime * bobbingSpeed
			local bobbingOffset = math.sin(timeElapsed) * bobbingAmplitude
			rotatedOffset = rotatedOffset + Vector3.new(0, bobbingOffset, 0)
		end

		rotatedOffset = adjustCameraPosition(root, rotatedOffset)
		local cameraPosition = playerPosition + rotatedOffset
		camera.CFrame = CFrame.lookAt(cameraPosition, playerPosition)
		camera.Focus = CFrame.new(playerPosition)
	end
end)
