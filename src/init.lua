local OTS_Cam = {}

--// SERVICES //--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

local SHOULDER_DIRECTION = {RIGHT = 1, LEFT = -1}
local VERTICAL_ANGLE_LIMITS = NumberRange.new(-45, 45)

local IS_ON_DESKTOP = UserInputService.MouseEnabled

--// MODULES //--
local Input = require(script.Input)

--// VARIABLES //--
local Character = PLAYER.Character or PLAYER.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

--// CONFIG //--
OTS_Cam.CameraSettings = {
    Default = {
        FieldOfView = 70,
        Offset = Vector3.new(2.5, 2.5, 8),
        MouseSensitivity = 3,
        TouchSensitivity = 3,
        GamepadSensitivity = 10,
        LerpSpeed = 0.2, -- Adjust this value to control the smoothness (lower values = smoother)
        AlignCharacter = true,
        LockMouse = true,
        ShoulderDirection = SHOULDER_DIRECTION.RIGHT
    },

    Zoomed = {
        FieldOfView = 40,
        Offset = Vector3.new(1.5, 1.5, 6),
        MouseSensitivity = 1.5,
        TouchSensitivity = 1.5,
        GamepadSensitivity = 5,
        LerpSpeed = 0.2, -- Adjust this value to control the smoothness (lower values = smoother)
        AlignCharacter = true,
        LockMouse = true,
        ShoulderDirection = SHOULDER_DIRECTION.RIGHT
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

    local sensitivity
    if UserInputService.GamepadEnabled then
        sensitivity = OTS_Cam.CameraSettings[CameraMode].GamepadSensitivity
    elseif UserInputService.TouchEnabled then
        sensitivity = OTS_Cam.CameraSettings[CameraMode].TouchSensitivity
    else
        sensitivity = OTS_Cam.CameraSettings[CameraMode].MouseSensitivity
    end

    return Vector2.new(delta.X * sensitivity, delta.Y * sensitivity)
end

local function configureStateForEnabled()
    saveDefaultCamera()
    CameraMode = "Default"
    OTS_Cam.SetCharacterAlignment(OTS_Cam.CameraSettings[CameraMode].AlignCharacter)
    OTS_Cam.LockMouse(OTS_Cam.CameraSettings[CameraMode].LockMouse)
    OTS_Cam.ShoulderDirection = OTS_Cam.CameraSettings[CameraMode].ShoulderDirection

    --// Calculate angles //--
    local cameraCFrame = workspace.CurrentCamera.CFrame
    local x, y, z = cameraCFrame:ToOrientation()
    local horizontalAngle = y
    local verticalAngle = x
    ----

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

local function updateCamera(deltaTime)
    local currentCamera = workspace.CurrentCamera
    local activeCameraSettings = OTS_Cam.CameraSettings[CameraMode]

    currentCamera.CameraType = Enum.CameraType.Scriptable

    --// Moves camera based on Input //--
    local inputDelta = getDelta()
    OTS_Cam.HorizontalAngle -= inputDelta.X / currentCamera.ViewportSize.X
    OTS_Cam.VerticalAngle -= inputDelta.Y / currentCamera.ViewportSize.Y
    OTS_Cam.VerticalAngle = math.rad(
        math.clamp(math.deg(OTS_Cam.VerticalAngle), VERTICAL_ANGLE_LIMITS.Min, VERTICAL_ANGLE_LIMITS.Max)
    )
    ----

    local humanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then -- Disable if Player dies
        -- Interpolate angles smoothly
        OTS_Cam.HorizontalAngle = Lerp(OTS_Cam.HorizontalAngle, OTS_Cam.HorizontalAngle, activeCameraSettings.LerpSpeed * deltaTime)
        OTS_Cam.VerticalAngle = Lerp(OTS_Cam.VerticalAngle, OTS_Cam.VerticalAngle, activeCameraSettings.LerpSpeed * deltaTime)

        currentCamera.FieldOfView = Lerp(currentCamera.FieldOfView, activeCameraSettings.FieldOfView, activeCameraSettings.LerpSpeed)

        --// Address shoulder direction //--
        local offset = activeCameraSettings.Offset
        offset = Vector3.new(offset.X * OTS_Cam.ShoulderDirection, offset.Y, offset.Z)
        ----

        --// Calculate new camera cframe //--
        local newCameraCFrame = CFrame.new(humanoidRootPart.Position) *
            CFrame.Angles(0, OTS_Cam.HorizontalAngle, 0) *
            CFrame.Angles(OTS_Cam.VerticalAngle, 0, 0) *
            CFrame.new(offset)

        newCameraCFrame = currentCamera.CFrame:Lerp(newCameraCFrame, activeCameraSettings.LerpSpeed)
        ----

        --// Raycast for obstructions //--
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local raycastResult = workspace:Raycast(
            humanoidRootPart.Position,
            newCameraCFrame.p - humanoidRootPart.Position,
            raycastParams
        )
        ----

        --// Address obstructions if any //--
        if raycastResult then
            local obstructionDisplacement = (raycastResult.Position - humanoidRootPart.Position)
            local obstructionPosition = humanoidRootPart.Position + (obstructionDisplacement.Unit * (obstructionDisplacement.Magnitude - 0.1))
            local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = newCameraCFrame:GetComponents()
            newCameraCFrame = CFrame.new(obstructionPosition.x, obstructionPosition.y, obstructionPosition.z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
        end
        ----

        --// Address character alignment //--
        if activeCameraSettings.AlignCharacter then
            local newHumanoidRootPartCFrame = CFrame.new(humanoidRootPart.Position) *
                CFrame.Angles(0, OTS_Cam.HorizontalAngle, 0)
            humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(newHumanoidRootPartCFrame, activeCameraSettings.LerpSpeed / 2)
        end
        ----

        currentCamera.CFrame = newCameraCFrame
    else
        OTS_Cam.Disable()
        CameraWasEnabled = true
    end
end

--// METHODS //--

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
        function(deltaTime)
            if OTS_Cam.IsEnabled then
                updateCamera(deltaTime)
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

--// CONTROLS //--

if IS_ON_DESKTOP then
    UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
        if not gameProcessedEvent and OTS_Cam.IsEnabled then
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
        if not gameProcessedEvent and OTS_Cam.IsEnabled then
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
