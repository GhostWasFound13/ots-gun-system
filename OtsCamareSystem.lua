local CLASS = {}

--// SERVICES //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// CONSTANTS //--

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local UPDATE_UNIQUE_KEY = "OTS_CAMERA_SYSTEM_UPDATE"

--// VARIABLES //--

local lastUpdateTime = tick()
local currentCameraCFrame = nil
local targetCameraCFrame = nil

--// CONSTRUCTOR //--

function CLASS.new()
    local dataTable = setmetatable(
        {
            --// Properties //--
            ActiveCameraSettings = "DefaultShoulder",
            HorizontalAngle = 0,
            VerticalAngle = 0,
            ShoulderDirection = 1,
            RotationSensitivity = 1,
            ----

            --// Flags //--
            IsCharacterAligned = false,
            IsMouseSteppedIn = false,
            IsEnabled = false,
            ----

            --// Events //--
            ActiveCameraSettingsChangedEvent = Instance.new("BindableEvent"),
            CharacterAlignmentChangedEvent = Instance.new("BindableEvent"),
            MouseStepChangedEvent = Instance.new("BindableEvent"),
            ShoulderDirectionChangedEvent = Instance.new("BindableEvent"),
            EnabledEvent = Instance.new("BindableEvent"),
            DisabledEvent = Instance.new("BindableEvent"),
            ----

            --// Configurations //--
            VerticalAngleLimits = NumberRange.new(-45, 45),
            ----

            --// Camera Settings //--
            CameraSettings = {
                DefaultShoulder = {
                    FieldOfView = 70,
                    Offset = Vector3.new(2.5, 2.5, 8),
                    Sensitivity = 3,
                    LerpSpeed = 0.2, -- Adjust this value to control the smoothness (lower values = smoother)
                },

                ZoomedShoulder = {
                    FieldOfView = 40,
                    Offset = Vector3.new(1.5, 1.5, 6),
                    Sensitivity = 1.5,
                    LerpSpeed = 0.2, -- Adjust this value to control the smoothness (lower values = smoother)
                }
            }
            ----

        },
        CLASS
    )
    local proxyTable = setmetatable(
        {

        },
        {
            __index = function(self, index)
                return dataTable[index]
            end,
            __newindex = function(self, index, newValue)
                dataTable[index] = newValue
            end
        }
    )

    return proxyTable
end

--// FUNCTIONS //--

local function Lerp(x, y, a)
    return x + (y - x) * a
end

--// METHODS //--

function CLASS:SetActiveCameraSettings(cameraSettings)
    assert(cameraSettings ~= nil, "OTS Camera System Argument Error: Argument 1 nil or missing")
    assert(typeof(cameraSettings) == "string", "OTS Camera System Argument Error: string expected, got " .. typeof(cameraSettings))
    assert(self.CameraSettings[cameraSettings] ~= nil, "OTS Camera System Argument Error: Attempt to set unrecognized camera settings " .. cameraSettings)
    if not self.IsEnabled then
        warn("OTS Camera System Logic Warning: Attempt to change active camera settings without enabling OTS camera system")
        return
    end

    self.ActiveCameraSettings = cameraSettings
    self.ActiveCameraSettingsChangedEvent:Fire(cameraSettings)
end

function CLASS:SetCharacterAlignment(aligned)
    assert(aligned ~= nil, "OTS Camera System Argument Error: Argument 1 nil or missing")
    assert(typeof(aligned) == "boolean", "OTS Camera System Argument Error: boolean expected, got " .. typeof(aligned))
    if not self.IsEnabled then
        warn("OTS Camera System Logic Warning: Attempt to change character alignment without enabling OTS camera system")
        return
    end

    local character = LocalPlayer.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoidRootPart and humanoid then
            humanoid.AutoRotate = not aligned
            self.IsCharacterAligned = aligned
            self.CharacterAlignmentChangedEvent:Fire(aligned)
        end
    end
end

function CLASS:SetMouseStep(steppedIn)
    assert(steppedIn ~= nil, "OTS Camera System Argument Error: Argument 1 nil or missing")
    assert(typeof(steppedIn) == "boolean", "OTS Camera System Argument Error: boolean expected, got " .. typeof(steppedIn))
    if not self.IsEnabled then
        warn("OTS Camera System Logic Warning: Attempt to change mouse step without enabling OTS camera system")
        return
    end

    self.IsMouseSteppedIn = steppedIn
    self.MouseStepChangedEvent:Fire(steppedIn)
    UserInputService.MouseBehavior = steppedIn and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
end

function CLASS:SetShoulderDirection(shoulderDirection)
    assert(shoulderDirection ~= nil, "OTS Camera System Argument Error: Argument 1 nil or missing")
    assert(typeof(shoulderDirection) == "number", "OTS Camera System Argument Error: number expected, got " .. typeof(shoulderDirection))
    assert(math.abs(shoulderDirection) == 1, "OTS Camera System Argument Error: Attempt to set unrecognized shoulder direction " .. shoulderDirection)
    if not self.IsEnabled then
        warn("OTS Camera System Logic Warning: Attempt to change shoulder direction without enabling OTS camera system")
        return
    end

    self.ShoulderDirection = shoulderDirection
    self.ShoulderDirectionChangedEvent:Fire(shoulderDirection)
end

function CLASS:SaveCameraSettings()
    local currentCamera = workspace.CurrentCamera
    self.SavedCameraSettings = {
        FieldOfView = currentCamera.FieldOfView,
        CameraSubject = currentCamera.CameraSubject,
        CameraType = currentCamera.CameraType
    }
end

function CLASS:LoadCameraSettings()
    local currentCamera = workspace.CurrentCamera
    for setting, value in pairs(self.SavedCameraSettings) do
        currentCamera[setting] = value
    end
end

function CLASS:Update(deltaTime)
    local currentCamera = workspace.CurrentCamera
    local activeCameraSettings = self.CameraSettings[self.ActiveCameraSettings]

    if self.IsMouseSteppedIn then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    currentCamera.CameraType = Enum.CameraType.Scriptable

    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")

    if humanoidRootPart and humanoid then
        -- Calculate the new camera CFrame using the character's HumanoidRootPart as the center
        local cameraPosition = humanoidRootPart.Position + activeCameraSettings.Offset
        local newCameraCFrame = CFrame.new(cameraPosition)
            * CFrame.Angles(0, self.HorizontalAngle, 0)
            * CFrame.Angles(self.VerticalAngle, 0, 0)
            * CFrame.new(0, 0, -activeCameraSettings.Offset.Z)

        -- Interpolate between the current camera CFrame and the target camera CFrame
        currentCameraCFrame = currentCameraCFrame:Lerp(newCameraCFrame, activeCameraSettings.LerpSpeed * deltaTime)
        currentCamera.CFrame = currentCameraCFrame

        -- Raycast for obstructions
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { character }
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

        local raycastResult = workspace:Raycast(
            humanoidRootPart.Position,
            (currentCamera.CFrame.p - humanoidRootPart.Position).Unit,
            raycastParams
        )

        -- Address obstructions if any
        if raycastResult then
            local hitPosition = raycastResult.Position
            local obstructionDirection = (hitPosition - humanoidRootPart.Position).Unit
            local cameraDistance = (currentCamera.CFrame.p - humanoidRootPart.Position).Magnitude
            currentCamera.CFrame = CFrame.new(humanoidRootPart.Position + obstructionDirection * (cameraDistance - 0.1), currentCamera.CFrame.p)
        end

        -- Address character alignment
        if self.IsCharacterAligned then
            local newHumanoidRootPartCFrame = CFrame.new(humanoidRootPart.Position) * CFrame.Angles(0, self.HorizontalAngle, 0)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(newHumanoidRootPartCFrame, activeCameraSettings.LerpSpeed / 2)
        end
    else
        self:Disable()
    end
end

function CLASS:ConfigureStateForEnabled()
    self:SaveCameraSettings()
    self.SavedMouseBehavior = UserInputService.MouseBehavior
    self:SetCharacterAlignment(false)
    self:SetMouseStep(true)
    self:SetShoulderDirection(1)

    -- Calculate angles
    local cameraCFrame = workspace.CurrentCamera.CFrame
    local x, y, _ = cameraCFrame:ToOrientation()
    self.HorizontalAngle = y
    self.VerticalAngle = math.rad(math.clamp(math.deg(x), self.VerticalAngleLimits.Min, self.VerticalAngleLimits.Max))
end

function CLASS:ConfigureStateForDisabled()
    self:LoadCameraSettings()
    UserInputService.MouseBehavior = self.SavedMouseBehavior
    self:SetCharacterAlignment(false)
    self:SetMouseStep(false)
    self:SetShoulderDirection(1)
    self.HorizontalAngle = 0
    self.VerticalAngle = 0
end

function CLASS:Enable()
    assert(not self.IsEnabled, "OTS Camera System Logic Error: Attempt to enable without disabling")

    self.IsEnabled = true
    self.EnabledEvent:Fire()
    self:ConfigureStateForEnabled()

    RunService:BindToRenderStep(
        UPDATE_UNIQUE_KEY,
        Enum.RenderPriority.Camera.Value - 10,
        function(deltaTime)
            if self.IsEnabled then
                local currentTime = tick()
                deltaTime = currentTime - lastUpdateTime
                lastUpdateTime = currentTime

                self:Update(deltaTime)
            end
        end
    )
end

function CLASS:Disable()
    assert(self.IsEnabled, "OTS Camera System Logic Error: Attempt to disable without enabling")

    self:ConfigureStateForDisabled()
    self.IsEnabled = false
    self.DisabledEvent:Fire()

    RunService:UnbindFromRenderStep(UPDATE_UNIQUE_KEY)
end

--// INSTRUCTIONS //--

CLASS.__index = CLASS

local singleton = CLASS.new()

UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
    if not gameProcessedEvent and singleton.IsEnabled then
        if inputObject.KeyCode == Enum.KeyCode.Q then
            singleton:SetShoulderDirection(-1)
        elseif inputObject.KeyCode == Enum.KeyCode.E then
            singleton:SetShoulderDirection(1)
        end

        if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            singleton:SetActiveCameraSettings("ZoomedShoulder")
        end

        if inputObject.KeyCode == Enum.KeyCode.LeftControl then
            singleton:SetMouseStep(not singleton.IsMouseSteppedIn)
        end

        -- Handle camera rotation input
        if inputObject.KeyCode == Enum.KeyCode.R then
            singleton:SetActiveCameraSettings("DefaultShoulder")
            singleton:SetShoulderDirection(1)
            singleton:SetMouseStep(true)
            singleton.RotationSensitivity = 1  -- Set rotation sensitivity to a suitable value
        elseif inputObject.KeyCode == Enum.KeyCode.F then
            singleton:SetActiveCameraSettings("DefaultShoulder")
            singleton:SetShoulderDirection(1)
            singleton:SetMouseStep(true)
            singleton.RotationSensitivity = -1 -- Set rotation sensitivity to a suitable value
        end
    end
end)

UserInputService.InputEnded:Connect(function(inputObject, gameProcessedEvent)
    if not gameProcessedEvent and singleton.IsEnabled then
        if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            singleton:SetActiveCameraSettings("DefaultShoulder")
        end
    end
end)

return singleton
