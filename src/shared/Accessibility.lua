--!strict
-- Accessibility System for Semantic Slime
-- Ensures the game is playable by users with various disabilities

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")

local Accessibility = {}

-- Configuration
local HIGH_CONTRAST_COLORS = {
    Background = Color3.fromRGB(0, 0, 0),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(255, 255, 0),
    Success = Color3.fromRGB(0, 255, 0),
    Error = Color3.fromRGB(255, 0, 0),
    Warning = Color3.fromRGB(255, 165, 0)
}

local COLORBLIND_FRIENDLY_COLORS = {
    Background = Color3.fromRGB(240, 240, 240),
    Text = Color3.fromRGB(0, 0, 0),
    Accent = Color3.fromRGB(0, 114, 178),  -- Blue
    Success = Color3.fromRGB(0, 158, 115),  -- Green
    Error = Color3.fromRGB(213, 94, 0),     -- Orange
    Warning = Color3.fromRGB(0, 114, 178)   -- Blue
}

-- Accessibility settings
local settings = {
    highContrast = false,
    colorblindMode = false,
    largeText = false,
    screenReader = false,
    reducedMotion = false,
    visualIndicators = true,
    audioCues = true,
    keyboardNavigation = true,
    autoClick = false,
    simplifiedUI = false
}

-- Text-to-speech (basic implementation)
local function speakText(text: string, priority: string?)
    if not settings.screenReader then return end
    
    -- This would integrate with a proper TTS system
    -- For now, we'll just print the text for debugging
    print("[ScreenReader]:", text)
    
    -- In a real implementation, this would use:
    -- - Roblox's TextService for text-to-speech
    -- - Or external TTS API
    -- - Or platform-specific accessibility APIs
end

-- Visual accessibility helpers
local function applyHighContrast(gui: ScreenGui)
    if not settings.highContrast then return end
    
    local function applyContrast(element: Instance)
        if element:IsA("Frame") or element:IsA("ScrollingFrame") then
            element.BackgroundColor3 = HIGH_CONTRAST_COLORS.Background
        elseif element:IsA("TextLabel") or element:IsA("TextButton") then
            element.TextColor3 = HIGH_CONTRAST_COLORS.Text
            element.BackgroundColor3 = HIGH_CONTRAST_COLORS.Background
        end
        
        -- Apply to children
        for _, child in ipairs(element:GetChildren()) do
            applyContrast(child)
        end
    end
    
    for _, child in ipairs(gui:GetChildren()) do
        applyContrast(child)
    end
end

local function applyColorblindMode(gui: ScreenGui)
    if not settings.colorblindMode then return end
    
    local function applyColors(element: Instance)
        if element:IsA("Frame") or element:IsA("ScrollingFrame") then
            element.BackgroundColor3 = COLORBLIND_FRIENDLY_COLORS.Background
        elseif element:IsA("TextLabel") or element:IsA("TextButton") then
            element.TextColor3 = COLORBLIND_FRIENDLY_COLORS.Text
        end
        
        -- Apply to children
        for _, child in ipairs(element:GetChildren()) do
            applyColors(child)
        end
    end
    
    for _, child in ipairs(gui:GetChildren()) do
        applyColors(child)
    end
end

local function applyLargeText(gui: ScreenGui)
    if not settings.largeText then return end
    
    local function increaseTextSize(element: Instance)
        if element:IsA("TextLabel") or element:IsA("TextButton") then
            element.TextSize = element.TextSize * 1.5
        end
        
        -- Apply to children
        for _, child in ipairs(element:GetChildren()) do
            increaseTextSize(child)
        end
    end
    
    for _, child in ipairs(gui:GetChildren()) do
        increaseTextSize(child)
    end
end

-- Reduced motion
local function applyReducedMotion(gui: ScreenGui)
    if not settings.reducedMotion then return end
    
    -- Disable all TweenService animations
    local function disableAnimations(element: Instance)
        -- This would need to be implemented in the actual UI components
        -- For now, we'll just mark elements for reduced motion
        element:SetAttribute("ReducedMotion", true)
        
        -- Apply to children
        for _, child in ipairs(element:GetChildren()) do
            disableAnimations(child)
        end
    end
    
    for _, child in ipairs(gui:GetChildren()) do
        disableAnimations(child)
    end
end

-- Visual indicators for audio cues
local function createVisualIndicator(parent: Instance, type: string, message: string)
    if not settings.visualIndicators then return end
    
    local indicator = Instance.new("Frame")
    indicator.Name = "VisualIndicator"
    indicator.Size = UDim2.new(0, 200, 0, 60)
    indicator.Position = UDim2.new(0.5, -100, 0.1, 0)
    indicator.BackgroundColor3 = type == "success" and HIGH_CONTRAST_COLORS.Success or
                               type == "error" and HIGH_CONTRAST_COLORS.Error or
                               type == "warning" and HIGH_CONTRAST_COLORS.Warning or
                               HIGH_CONTRAST_COLORS.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = indicator
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = HIGH_CONTRAST_COLORS.Text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = message
    label.Parent = indicator
    
    -- Auto-remove after 3 seconds
    task.delay(3, function()
        if indicator and indicator.Parent then
            indicator:Destroy()
        end
    end)
end

-- Keyboard navigation
local function setupKeyboardNavigation(gui: ScreenGui)
    if not settings.keyboardNavigation then return end
    
    local selectableElements = {}
    local currentIndex = 1
    
    -- Find all selectable elements
    local function findSelectables(element: Instance)
        if element:IsA("TextButton") or element:IsA("ImageButton") then
            table.insert(selectableElements, element)
        end
        
        for _, child in ipairs(element:GetChildren()) do
            findSelectables(child)
        end
    end
    
    findSelectables(gui)
    
    -- Add keyboard navigation
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.Tab then
            -- Navigate to next element
            currentIndex = (currentIndex % #selectableElements) + 1
            local currentElement = selectableElements[currentIndex]
            
            if currentElement then
                -- Visual focus indicator
                local focusIndicator = Instance.new("Frame")
                focusIndicator.Name = "FocusIndicator"
                focusIndicator.Size = UDim2.new(1, 4, 1, 4)
                focusIndicator.Position = UDim2.fromOffset(-2, -2)
                focusIndicator.BackgroundColor3 = HIGH_CONTRAST_COLORS.Accent
                focusIndicator.BorderSizePixel = 0
                focusIndicator.Parent = currentElement
                
                local focusCorner = Instance.new("UICorner")
                focusCorner.CornerRadius = UDim.new(0, 4)
                focusCorner.Parent = focusIndicator
                
                -- Remove previous focus indicators
                for _, element in ipairs(selectableElements) do
                    local existing = element:FindFirstChild("FocusIndicator")
                    if existing and existing ~= focusIndicator then
                        existing:Destroy()
                    end
                end
                
                -- Auto-remove focus indicator when element is no longer selected
                task.delay(0.1, function()
                    if focusIndicator and focusIndicator.Parent then
                        focusIndicator:Destroy()
                    end
                end)
            end
        elseif input.KeyCode == Enum.KeyCode.Return then
            -- Activate current element
            local currentElement = selectableElements[currentIndex]
            if currentElement and currentElement:IsA("GuiButton") then
                currentElement:Activate()
            end
        end
    end)
end

-- Auto-click for accessibility
local function setupAutoClick(gui: ScreenGui)
    if not settings.autoClick then return end
    
    local hoverTime = 0
    local HOVER_DURATION = 2.0 -- seconds to hover before auto-click
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            -- Reset hover timer
            hoverTime = 0
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, processed)
        if processed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            -- Track hover time
            hoverTime += task.wait()
            
            if hoverTime >= HOVER_DURATION then
                -- Find what's under the mouse
                local mousePos = input.Position
                local guiObjects = GuiService:GetGuiObjectsAtPosition(mousePos.X, mousePos.Y)
                
                for _, obj in ipairs(guiObjects) do
                    if obj:IsA("GuiButton") and obj.Parent == gui then
                        -- Auto-click
                        obj:Activate()
                        hoverTime = 0
                        break
                    end
                end
            end
        end
    end)
end

-- Simplified UI mode
local function applySimplifiedUI(gui: ScreenGui)
    if not settings.simplifiedUI then return end
    
    -- Remove complex animations and effects
    local function simplifyElement(element: Instance)
        -- Remove particle effects
        local particles = element:FindFirstChildWhichIsA("ParticleEmitter")
        if particles then
            particles:Destroy()
        end
        
        -- Remove complex gradients
        local gradient = element:FindFirstChildWhichIsA("UIGradient")
        if gradient then
            gradient:Destroy()
        end
        
        -- Simplify corners
        local corner = element:FindFirstChildWhichIsA("UICorner")
        if corner then
            corner.CornerRadius = UDim.new(0, 4) -- Smaller, simpler corners
        end
        
        -- Apply to children
        for _, child in ipairs(element:GetChildren()) do
            simplifyElement(child)
        end
    end
    
    for _, child in ipairs(gui:GetChildren()) do
        simplifyElement(child)
    end
end

-- Main accessibility application
function Accessibility.ApplyAccessibility(gui: ScreenGui)
    print("[Accessibility] Applying accessibility settings...")
    
    -- Apply all enabled accessibility features
    applyHighContrast(gui)
    applyColorblindMode(gui)
    applyLargeText(gui)
    applyReducedMotion(gui)
    setupKeyboardNavigation(gui)
    setupAutoClick(gui)
    applySimplifiedUI(gui)
    
    print("[Accessibility] Accessibility settings applied")
end

-- Settings management
function Accessibility.SetSetting(setting: string, value: boolean)
    if settings[setting] ~= nil then
        settings[setting] = value
        print("[Accessibility] Setting", setting, "to", value)
        
        -- Apply to all existing GUIs
        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                Accessibility.ApplyAccessibility(gui)
            end
        end
    end
end

function Accessibility.GetSetting(setting: string): boolean
    return settings[setting] or false
end

function Accessibility.GetAllSettings(): {[string]: boolean}
    return settings
end

-- Audio cues for visual events
function Accessibility.PlayAudioCue(cueType: string)
    if not settings.audioCues then return end
    
    local sounds = {
        crystalCollected = "rbxassetid://6788484923",
        wordConstructed = "rbxassetid://6788484923",
        questCompleted = "rbxassetid://6788484923",
        battleWon = "rbxassetid://6788484923",
        error = "rbxassetid://6788484923"
    }
    
    local soundId = sounds[cueType]
    if soundId then
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 0.5
        sound:Play()
    end
end

-- Screen reader announcements
function Accessibility.Announce(message: string, priority: string?)
    speakText(message, priority)
end

-- Visual feedback for audio events
function Accessibility.ShowVisualFeedback(eventType: string, message: string)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create or get feedback container
    local feedbackGui = playerGui:FindFirstChild("AccessibilityFeedback")
    if not feedbackGui then
        feedbackGui = Instance.new("ScreenGui")
        feedbackGui.Name = "AccessibilityFeedback"
        feedbackGui.ResetOnSpawn = false
        feedbackGui.Parent = playerGui
    end
    
    createVisualIndicator(feedbackGui, eventType, message)
end

-- Initialize accessibility system
function Accessibility.Initialize()
    print("[Accessibility] Initializing accessibility system...")
    
    -- Detect system accessibility settings
    local isHighContrast = GuiService:IsHighContrastMode()
    if isHighContrast then
        Accessibility.SetSetting("highContrast", true)
    end
    
    -- Setup auto-adaptation for new GUIs
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    playerGui.ChildAdded:Connect(function(child)
        if child:IsA("ScreenGui") then
            task.wait(0.1) -- Wait for GUI to fully load
            Accessibility.ApplyAccessibility(child)
        end
    end)
    
    print("[Accessibility] Accessibility system initialized")
end

return Accessibility
