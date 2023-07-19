local Input = {}

--// SERVICES //--
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')

--// CONSTANTS //--
local PLAYER = Players.LocalPlayer

local IS_ON_MOBILE = UserInputService.TouchEnabled
local IS_ON_DESKTOP = UserInputService.MouseEnabled
local IS_ON_CONSOLE = UserInputService.GamepadEnabled

--// VARIABLES //--
local touchDelta = Vector2.new()
local selectedTouchInputs = {}

--// CONFIG //--
local GAMEPAD_DEADZONE = 0.15
local GAMEPAD_X_SENSITIVITY, GAMEPAD_Y_SENSITIVITY = 20, 15

local function IsInDynamicThumbstickArea(pos)
    local playerGui = PLAYER:FindFirstChildOfClass("PlayerGui")
    local touchGui = playerGui and playerGui:FindFirstChild("TouchGui")
    local touchFrame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
    local thumbstickFrame = touchFrame and touchFrame:FindFirstChild("DynamicThumbstickFrame")

    if not thumbstickFrame then
        return false
    end

    if not touchGui.Enabled then
        return false
    end

    local posTopLeft = thumbstickFrame.AbsolutePosition
    local posBottomRight = posTopLeft + thumbstickFrame.AbsoluteSize

    return pos.X >= posTopLeft.X and pos.Y >= posTopLeft.Y and pos.X <= posBottomRight.X and pos.Y <= posBottomRight.Y
end

local function SmoothInput(input)
    local x = input.X
    local y = input.Y

    -- Apply smoothing or deadzone if on console
    if IS_ON_CONSOLE then
        local magnitude = input.Magnitude
        if magnitude > GAMEPAD_DEADZONE then
            local normalizedMagnitude = (magnitude - GAMEPAD_DEADZONE) / (1 - GAMEPAD_DEADZONE)
            local scaleFactor = normalizedMagnitude / magnitude
            x *= scaleFactor
            y *= scaleFactor
        else
            x = 0
            y = 0
        end
    end

    return Vector2.new(x, y)
end

local function GetMouseDelta()
    local mousePosition = UserInputService:GetMouseLocation()
    local delta = Vector2.new()

    if IS_ON_DESKTOP and mousePosition then
        delta = Vector2.new(
            mousePosition.X - UserInputService:GetMouseScreenPosition().X,
            mousePosition.Y - UserInputService:GetMouseScreenPosition().Y
        )
    end

    return delta
end

if IS_ON_MOBILE then
    UserInputService.TouchStarted:Connect(function(inputObject, gameProcessedEvent)
        if not gameProcessedEvent then
            local position = inputObject.Position
            position = Vector2.new(position.X, position.Y)
            if not IsInDynamicThumbstickArea(position) then
                selectedTouchInputs[inputObject] = true
            end
        end
    end)

    UserInputService.TouchMoved:Connect(function(inputObject, gameProcessedEvent)
        if selectedTouchInputs[inputObject] then
            local delta = inputObject.Delta
            touchDelta += Vector2.new(delta.X, delta.Y)
        end
    end)

    UserInputService.TouchEnded:Connect(function(inputObject, gameProcessedEvent)
        if selectedTouchInputs[inputObject] then
            selectedTouchInputs[inputObject] = nil
        end
    end)

elseif IS_ON_CONSOLE then
    UserInputService.InputChanged:Connect(function(inputObject, processed)
        if not processed then
            if inputObject.KeyCode == Enum.KeyCode.Thumbstick2 then
                local input = inputObject.Position
                touchDelta += SmoothInput(input) * Vector2.new(GAMEPAD_X_SENSITIVITY, GAMEPAD_Y_SENSITIVITY)
            end
        end
    end)
end

function Input.GetDelta()
    local delta = touchDelta + GetMouseDelta()
    touchDelta = Vector2.new()

    return delta
end

return Input
