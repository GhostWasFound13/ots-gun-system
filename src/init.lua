--// SERVICES //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

local SHOULDER_DIRECTION = { RIGHT = 1, LEFT = -1 }
local VERTICAL_ANGLE_LIMITS = NumberRange.new(-45, 45)

local IS_ON_DESKTOP = UserInputService.MouseEnabled

--// MODULES //--
local Input = require(script.Input)

--// VARIABLES //--
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG //--
local OTS_Cam = {}

OTS_Cam.CameraSettings = {
    Default = {
        Field_Of_View = 70,
        Offset = Vector3.new(2.5, 2.5, 8),
        Mouse_Sensitivity_X = 3,
        Mouse_Sensitivity_Y = 3,
        Touch_Sensitivity_X = 3,
        Touch_Sensitivity_Y = 3,
        Gamepad_Sensitivity_X = 10,
        Gamepad_Sensitivity_Y = 10,
        Lerp_Speed = 0.1,
        Align_Character = true,
        Lock_Mouse = true,
        Shoulder_Direction = SHOULDER_DIRECTION.RIGHT
    },

    Zoomed = {
        Field_Of_View = 40,
        Offset = Vector3.new(1.5, 1.5, 6),
        Mouse_Sensitivity_X = 1.5,
        Mouse_Sensitivity_Y = 1.5,
        Touch_Sensitivity_X = 1.5,
        Touch_Sensitivity_Y = 1.5,
        Gamepad_Sensitivity_X = 5,
        Gamepad_Sensitivity_Y = 5,
        Lerp_Speed = 0.1,
        Align_Character = true,
        Lock_Mouse = true,
        Shoulder_Direction = SHOULDER_DIRECTION.RIGHT
    }
}

--// PROPERTIES //--
local SavedCameraSettings
local SavedMouseBehavior

local CameraWasEnabled
local CameraMode

OTS_Cam.HorizontalAngle = 0
OTS_Cam.VerticalAngle = 0
OTS_Cam.ShoulderDirection = 1

OTS_Cam.IsCharacterAligned = false
OTS_Cam.IsMouseLocked = false
OTS_Cam.IsEnabled = false

--// FUNCTIONS //--

local function Lerp(x, y, a)
    return x + (y - x) * a
end

local function saveDefaultCamera()
    local currentCamera = workspace.CurrentCamera
    SavedCameraSettings = {
        FieldOfView = currentCamera.FieldOfView,
        CameraSubject = currentCamera.CameraSubject,
        CameraType = currentCamera.CameraType
    }
    SavedMouseBehavior = UserInputService.MouseBehavior
end

local function loadDefaultCamera()
    local currentCamera = workspace.CurrentCamera
    for setting, value in pairs(SavedCameraSettings) do
        currentCamera[setting] = value
    end
end

local function getDelta()
    local delta = Input.GetDelta()

    local xSensitivity, ySensitivity
    if UserInputService.GamepadEnabled then
        xSensitivity = OTS_Cam.CameraSettings[CameraMode].Gamepad_Sensitivity_X
        ySensitivity = OTS_Cam.CameraSettings[CameraMode].Gamepad_Sensitivity_Y
    elseif UserInputService.TouchEnabled then
        xSensitivity = OTS_Cam.CameraSettings[CameraMode].Touch_Sensitivity_X
        ySensitivity = OTS_Cam.CameraSettings[CameraMode].Touch_Sensitivity_Y
    else
        xSensitivity = OTS_Cam.CameraSettings[CameraMode].Mouse_Sensitivity_X
        ySensitivity = OTS_Cam.CameraSettings[CameraMode].Mouse_Sensitivity_Y
    end

    return Vector2.new(delta.X * xSensitivity, delta.Y * ySensitivity)
end

local function configureStateForEnabled()
    saveDefaultCamera()
    CameraMode = "Default"
    OTS_Cam.SetCharacterAlignment(OTS_Cam.CameraSettings[CameraMode].Align_Character)
    OTS_Cam.LockMouse(OTS_Cam.CameraSettings[CameraMode].Lock_Mouse)
    OTS_Cam.ShoulderDirection = OTS_Cam.CameraSettings[CameraMode].Shoulder_Direction

    local cameraCFrame = workspace.CurrentCamera.CFrame
    local x, y, z = cameraCFrame:ToOrientation()
    local horizontalAngle = y
    local verticalAngle = x

    OTS_Cam.HorizontalAngle = horizontalAngle
    OTS_Cam.VerticalAngle = verticalAngle
end

local function configureStateForDisabled()
    OTS_Cam.SetCharacterAlignment(false)
    loadDefaultCamera()
    UserInputService.MouseBehavior = SavedMouseBehavior
    OTS_Cam.HorizontalAngle = 0
    OTS_Cam.VerticalAngle = 0
end

local function updateCamera()
    local currentCamera = workspace.CurrentCamera
    local activeCameraSettings = OTS_Cam.CameraSettings[CameraMode]

    currentCamera.CameraType = Enum.CameraType.Scriptable

    local inputDelta = getDelta()
    OTS_Cam.HorizontalAngle -= inputDelta.X / currentCamera.ViewportSize.X
    OTS_Cam.VerticalAngle -= inputDelta.Y / currentCamera.ViewportSize.Y
    OTS_Cam.VerticalAngle = math.rad(math.clamp(math.deg(OTS_Cam.VerticalAngle), VERTICAL_ANGLE_LIMITS.Min, VERTICAL_ANGLE_LIMITS.Max))

    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        currentCamera.FieldOfView = Lerp(
            currentCamera.FieldOfView,
            activeCameraSettings.Field_Of_View,
            activeCameraSettings.Lerp_Speed
        )

        local offset = activeCameraSettings.Offset
        offset = Vector3.new(offset.X * OTS_Cam.ShoulderDirection, offset.Y, offset.Z)

        local newCameraCFrame = CFrame.new(humanoidRootPart.Position) *
            CFrame.Angles(0, OTS_Cam.HorizontalAngle, 0) *
            CFrame.Angles(OTS_Cam.VerticalAngle, 0, 0) *
            CFrame.new(offset)

        local alpha = 1 - math.exp(-activeCameraSettings.Lerp_Speed * RunService.RenderStepped:Wait())
        local currentCameraCFrame = currentCamera.CFrame
        local newCFrame = currentCameraCFrame:Lerp(newCameraCFrame, alpha)
        currentCamera.CFrame = newCFrame

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = { Character }
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = workspace:Raycast(
            humanoidRootPart.Position,
            newCameraCFrame.Position - humanoidRootPart.Position,
            raycastParams
        )

        if raycastResult then
            local obstructionDisplacement = raycastResult.Position - humanoidRootPart.Position
            local obstructionPosition = humanoidRootPart.Position + obstructionDisplacement.Unit * (obstructionDisplacement.Magnitude - 0.1)
            local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = newCameraCFrame:GetComponents()
            newCameraCFrame = CFrame.new(obstructionPosition.X, obstructionPosition.Y, obstructionPosition.Z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
        end

        if activeCameraSettings.Align_Character then
            local newHumanoidRootPartCFrame = CFrame.new(humanoidRootPart.Position) *
                CFrame.Angles(0, OTS_Cam.HorizontalAngle, 0)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(newHumanoidRootPartCFrame, activeCameraSettings.Lerp_Speed / 2)
        end
    else
        OTS_Cam.Disable()
        CameraWasEnabled = true
    end
end

function OTS_Cam.SetCharacterAlignment(aligned)
    Humanoid.AutoRotate = not aligned
    OTS_Cam.IsCharacterAligned = aligned
end

function OTS_Cam.LockMouse(lock)
    OTS_Cam.IsMouseLocked = lock
    if lock then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end

function OTS_Cam.Enable()
    OTS_Cam.IsEnabled = true
    CameraWasEnabled = true
    configureStateForEnabled()

    RunService:BindToRenderStep(
        "OTS_CAMERA",
        Enum.RenderPriority.Camera.Value - 10,
        function()
            if OTS_Cam.IsEnabled then
                updateCamera()
            end
        end
    )
end

function OTS_Cam.Disable()
    configureStateForDisabled()
    OTS_Cam.IsEnabled = false
    CameraWasEnabled = false
    RunService:UnbindFromRenderStep("OTS_CAMERA")
end

if IS_ON_DESKTOP then
    UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
        if gameProcessedEvent == false and OTS_Cam.IsEnabled then
            if inputObject.KeyCode == Enum.KeyCode.Q then
                OTS_Cam.ShoulderDirection = SHOULDER_DIRECTION.LEFT
            elseif inputObject.KeyCode == Enum.KeyCode.E then
                OTS_Cam.ShoulderDirection = SHOULDER_DIRECTION.RIGHT
            end
            if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
                CameraMode = "Zoomed"
            end

            if inputObject.KeyCode == Enum.KeyCode.LeftControl then
                if OTS_Cam.IsEnabled then
                    OTS_Cam.LockMouse(not OTS_Cam.IsMouseLocked)
                end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inputObject, gameProcessedEvent)
        if gameProcessedEvent == false and OTS_Cam.IsEnabled then
            if inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
                CameraMode = "Default"
            end
        end
    end)
end

PLAYER.CharacterAdded:Connect(function(character)
    Character = character
    Humanoid = character:WaitForChild("Humanoid")

    if CameraWasEnabled then
        OTS_Cam.Enable()
    end
end)

return OTS_Cam
