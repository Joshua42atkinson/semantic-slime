--!strict
-- Mobile Adaptation System for Semantic Slime
-- Automatically adjusts UI for mobile devices

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local MobileAdaptation = {}

local addMobileControls


-- Configuration
local MOBILE_SCALE_FACTOR = 0.8
local TABLET_SCALE_FACTOR = 0.9
local DESKTOP_SCALE_FACTOR = 1.0

local MOBILE_BUTTON_SIZE = 60
local TABLET_BUTTON_SIZE = 80
local DESKTOP_BUTTON_SIZE = 100

local MOBILE_FONT_SIZE = 14
local TABLET_FONT_SIZE = 16
local DESKTOP_FONT_SIZE = 18

-- Device detection
local function getDeviceType(): string
    local isMobile = (UserInputService.TouchEnabled and 
                     not UserInputService.MouseEnabled and 
                     not UserInputService.KeyboardEnabled)
    
    local isTablet = (UserInputService.TouchEnabled and 
                      UserInputService.MouseEnabled)
    
    if isMobile then
        return "Mobile"
    elseif isTablet then
        return "Tablet"
    else
        return "Desktop"
    end
end

local function getScreenSize(): Vector2
    local camera = workspace.CurrentCamera
    if camera then
        return camera.ViewportSize
    end
    return Vector2.new(1920, 1080) -- Fallback
end

-- UI adaptation functions
local function adaptFrame(frame: Frame, deviceType: string)
    local scaleFactor = deviceType == "Mobile" and MOBILE_SCALE_FACTOR or
                       deviceType == "Tablet" and TABLET_SCALE_FACTOR or
                       DESKTOP_SCALE_FACTOR
    
    -- Scale the frame
    local currentSize = frame.Size
    local currentPosition = frame.Position
    
    if currentSize.X.Scale > 0 then
        frame.Size = UDim2.new(currentSize.X.Scale * scaleFactor, currentSize.X.Offset,
                              currentSize.Y.Scale * scaleFactor, currentSize.Y.Offset)
    end
    
    -- Adjust position for mobile (center more elements)
    if deviceType == "Mobile" then
        if currentPosition.X.Scale > 0.5 then
            frame.Position = UDim2.new(0.5, currentPosition.X.Offset,
                                       currentPosition.Y.Scale, currentPosition.Y.Offset)
        end
    end
end

local function adaptButton(button: TextButton, deviceType: string)
    local buttonSize = deviceType == "Mobile" and MOBILE_BUTTON_SIZE or
                      deviceType == "Tablet" and TABLET_BUTTON_SIZE or
                      DESKTOP_BUTTON_SIZE
    
    -- Make button larger for touch
    if deviceType ~= "Desktop" then
        button.Size = UDim2.fromOffset(buttonSize, buttonSize)
        
        -- Add touch feedback
        local touchFeedback = Instance.new("Frame")
        touchFeedback.Name = "TouchFeedback"
        touchFeedback.Size = UDim2.new(1, 4, 1, 4)
        touchFeedback.Position = UDim2.fromOffset(-2, -2)
        touchFeedback.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        touchFeedback.BackgroundTransparency = 0.8
        touchFeedback.BorderSizePixel = 0
        touchFeedback.Parent = button
        touchFeedback.ZIndex = button.ZIndex - 1
        
        local feedbackCorner = Instance.new("UICorner")
        feedbackCorner.CornerRadius = UDim.new(0, 8)
        feedbackCorner.Parent = touchFeedback
        
        -- Animate on touch
        button.MouseButton1Down:Connect(function()
            local tween = TweenService:Create(touchFeedback, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.4
            })
            tween:Play()
        end)
        
        button.MouseButton1Up:Connect(function()
            local tween = TweenService:Create(touchFeedback, TweenInfo.new(0.1), {
                BackgroundTransparency = 0.8
            })
            tween:Play()
        end)
    end
    
    -- Adjust font size
    local fontSize = deviceType == "Mobile" and MOBILE_FONT_SIZE or
                    deviceType == "Tablet" and TABLET_FONT_SIZE or
                    DESKTOP_FONT_SIZE
    
    button.TextSize = fontSize
end

local function adaptTextLabel(label: TextLabel, deviceType: string)
    local fontSize = deviceType == "Mobile" and MOBILE_FONT_SIZE or
                    deviceType == "Tablet" and TABLET_FONT_SIZE or
                    DESKTOP_FONT_SIZE
    
    label.TextSize = fontSize
    
    -- Adjust text wrapping for mobile
    if deviceType == "Mobile" then
        label.TextWrapped = true
        label.TextScaled = false
    end
end

local function adaptScrollingFrame(scrollFrame: ScrollingFrame, deviceType: string)
    -- Increase scroll bar size for touch
    if deviceType ~= "Desktop" then
        scrollFrame.ScrollBarThickness = 12
        
        -- Add elastic scrolling for mobile
        if deviceType == "Mobile" then
            scrollFrame.ElasticBehavior = Enum.ElasticBehavior.Always
        end
    end
end

-- Main adaptation function
function MobileAdaptation.AdaptUI(gui: ScreenGui)
    local deviceType = getDeviceType()
    local screenSize = getScreenSize()
    
    print("[MobileAdaptation] Adapting UI for device:", deviceType, "Screen:", screenSize.X .. "x" .. screenSize.Y)
    
    -- Adapt all UI elements
    local function adaptElement(element: Instance)
        if element:IsA("Frame") then
            adaptFrame(element, deviceType)
        elseif element:IsA("TextButton") then
            adaptButton(element, deviceType)
        elseif element:IsA("TextLabel") then
            adaptTextLabel(element, deviceType)
        elseif element:IsA("ScrollingFrame") then
            adaptScrollingFrame(element, deviceType)
        end
        
        -- Recursively adapt children
        for _, child in ipairs(element:GetChildren()) do
            adaptElement(child)
        end
    end
    
    -- Start adaptation from the root
    for _, child in ipairs(gui:GetChildren()) do
        adaptElement(child)
    end
    
    -- Add mobile-specific controls
    if deviceType == "Mobile" then
        addMobileControls(gui)
    end
end

-- Add mobile-specific controls
function addMobileControls(gui: ScreenGui)
    -- Add virtual joystick area
    local joystickArea = Instance.new("Frame")
    joystickArea.Name = "JoystickArea"
    joystickArea.Size = UDim2.new(0.3, 0, 0.3, 0)
    joystickArea.Position = UDim2.new(0, 20, 1, -20)
    joystickArea.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    joystickArea.BackgroundTransparency = 0.8
    joystickArea.BorderSizePixel = 0
    joystickArea.Parent = gui
    
    local joystickCorner = Instance.new("UICorner")
    joystickCorner.CornerRadius = UDim.new(0, 50)
    joystickCorner.Parent = joystickArea
    
    -- Add action buttons area
    local actionArea = Instance.new("Frame")
    actionArea.Name = "ActionArea"
    actionArea.Size = UDim2.new(0.3, 0, 0.3, 0)
    actionArea.Position = UDim2.new(1, -20, 1, -20)
    actionArea.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    actionArea.BackgroundTransparency = 0.8
    actionArea.BorderSizePixel = 0
    actionArea.Parent = gui
    
    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 50)
    actionCorner.Parent = actionArea
    
    -- Add mobile menu button
    local menuButton = Instance.new("TextButton")
    menuButton.Name = "MobileMenuButton"
    menuButton.Size = UDim2.fromOffset(MOBILE_BUTTON_SIZE, MOBILE_BUTTON_SIZE)
    menuButton.Position = UDim2.new(0, 10, 0, 10)
    menuButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    menuButton.BorderSizePixel = 0
    menuButton.Text = "☰"
    menuButton.TextColor3 = Color3.new(1, 1, 1)
    menuButton.TextSize = 24
    menuButton.Parent = gui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 8)
    menuCorner.Parent = menuButton
end

-- Auto-adaptation system
local function setupAutoAdaptation()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Adapt existing GUIs
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            MobileAdaptation.AdaptUI(gui)
        end
    end
    
    -- Adapt new GUIs as they're added
    playerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait(0.1) -- Wait for GUI to fully load
            MobileAdaptation.AdaptUI(child)
        end
    end)
    
    -- Re-adapt on device orientation change
    UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
        task.wait(0.5) -- Wait for device to stabilize
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                MobileAdaptation.AdaptUI(gui)
            end
        end
    end)
end

-- Public API
function MobileAdaptation.Initialize()
    print("[MobileAdaptation] Initializing mobile adaptation system...")
    
    local deviceType = getDeviceType()
    print("[MobileAdaptation] Detected device type:", deviceType)
    
    -- Setup auto-adaptation
    task.spawn(setupAutoAdaptation)
    
    print("[MobileAdaptation] Mobile adaptation system initialized")
end

function MobileAdaptation.GetDeviceType(): string
    return getDeviceType()
end

function MobileAdaptation.IsMobile(): boolean
    return getDeviceType() == "Mobile"
end

function MobileAdaptation.IsTablet(): boolean
    return getDeviceType() == "Tablet"
end

function MobileAdaptation.IsDesktop(): boolean
    return getDeviceType() == "Desktop"
end

return MobileAdaptation
