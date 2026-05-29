--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local AchievementData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AchievementData"))

local AchievementUI = {}
AchievementUI.__index = AchievementUI

local screenGui: ScreenGui? = nil
local isOpen = false
local achievementCards = {}

function AchievementUI.Initialize()
    print("[AchievementUI] Initialized")
end

function AchievementUI.Toggle()
    if isOpen then
        AchievementUI.Hide()
    else
        AchievementUI.Show()
    end
end

function AchievementUI.Show()
    if isOpen then return end
    isOpen = true
    
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AchievementUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.5
    overlay.BorderSizePixel = 0
    overlay.Parent = screenGui
    
    local container = Instance.new("Frame")
    container.Size = UDim2.fromOffset(800, 500)
    container.Position = UDim2.fromScale(0.5, 0.5)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = GameConfig.Colors.Background
    container.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 16)
    containerCorner.Parent = container
    
    local header = Instance.new("Frame")
    header.Size = UDim2.fromScale(1, 0.12)
    header.BackgroundColor3 = GameConfig.Colors.CardBg
    header.Parent = container
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 16)
    headerCorner.Parent = header
    
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.fromScale(1, 0.5)
    headerFix.Position = UDim2.fromScale(0, 0.5)
    headerFix.BackgroundColor3 = GameConfig.Colors.CardBg
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(0.5, 1)
    title.Position = UDim2.fromScale(0.25, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = GameConfig.Colors.Accent
    title.Font = Enum.Font.GothamBold
    title.TextSize = 28
    title.Text = "🏆 Achievements"
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.fromOffset(40, 40)
    closeBtn.Position = UDim2.fromScale(0.95, 0.5)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromHex("#EF4444")
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 20
    closeBtn.Text = "X"
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        AchievementUI.Hide()
    end)
    
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Size = UDim2.fromScale(0.95, 0.8)
    scrollingFrame.Position = UDim2.fromScale(0.025, 0.15)
    scrollingFrame.BackgroundTransparency = 1
    scrollingFrame.ScrollBarThickness = 8
    scrollingFrame.Parent = container
    
    local uiGridLayout = Instance.new("UIGridLayout")
    uiGridLayout.CellSize = UDim2.fromOffset(360, 80)
    uiGridLayout.CellPadding = UDim2.fromOffset(15, 15)
    uiGridLayout.Parent = scrollingFrame
    
    -- Load Data
    local DataService = Knit.GetService("DataService")
    DataService:GetProfile():andThen(function(profile)
        local unlockedAchievements = profile and profile.Achievements or {}
        
        for id, data in pairs(AchievementData) do
            local currentProgress = unlockedAchievements[id] or 0
            local isUnlocked = currentProgress >= data.Requirement
            
            local card = Instance.new("Frame")
            card.BackgroundColor3 = isUnlocked and Color3.fromHex("#2A2A4E") or GameConfig.Colors.CardBg
            card.Parent = scrollingFrame
            
            if isUnlocked then
                local uiStroke = Instance.new("UIStroke")
                uiStroke.Color = Color3.fromHex("#FCD34D") -- Gold stroke for unlocked
                uiStroke.Thickness = 2
                uiStroke.Parent = card
            end
            
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 8)
            cardCorner.Parent = card
            
            local iconF = Instance.new("Frame")
            iconF.Size = UDim2.fromOffset(60, 60)
            iconF.Position = UDim2.fromOffset(10, 10)
            iconF.BackgroundColor3 = isUnlocked and Color3.fromHex("#FCD34D") or Color3.fromHex("#374151")
            iconF.Parent = card
            
            local iCorner = Instance.new("UICorner")
            iCorner.CornerRadius = UDim.new(0, 8)
            iCorner.Parent = iconF
            
            local iconL = Instance.new("TextLabel")
            iconL.Size = UDim2.fromScale(1, 1)
            iconL.BackgroundTransparency = 1
            iconL.Text = data.Icon
            iconL.TextSize = 30
            iconL.Parent = iconF
            
            local nameL = Instance.new("TextLabel")
            nameL.Size = UDim2.fromOffset(200, 20)
            nameL.Position = UDim2.fromOffset(80, 12)
            nameL.BackgroundTransparency = 1
            nameL.TextColor3 = isUnlocked and GameConfig.Colors.Text or GameConfig.Colors.TextDim
            nameL.Font = Enum.Font.GothamBold
            nameL.TextSize = 16
            nameL.TextXAlignment = Enum.TextXAlignment.Left
            nameL.Text = data.Name
            nameL.Parent = card
            
            local descL = Instance.new("TextLabel")
            descL.Size = UDim2.fromOffset(260, 30)
            descL.Position = UDim2.fromOffset(80, 35)
            descL.BackgroundTransparency = 1
            descL.TextColor3 = GameConfig.Colors.TextDim
            descL.Font = Enum.Font.Gotham
            descL.TextSize = 12
            descL.TextXAlignment = Enum.TextXAlignment.Left
            descL.TextYAlignment = Enum.TextYAlignment.Top
            descL.TextWrapped = true
            descL.Text = data.Description
            descL.Parent = card
            
            if data.Requirement > 1 and not isUnlocked then
                -- Add a progress bar overlay
                local progBarBg = Instance.new("Frame")
                progBarBg.Size = UDim2.fromOffset(260, 6)
                progBarBg.Position = UDim2.fromOffset(80, 68)
                progBarBg.BackgroundColor3 = Color3.fromHex("#1F2937")
                progBarBg.Parent = card
                
                local pBarCorner = Instance.new("UICorner")
                pBarCorner.CornerRadius = UDim.new(0, 3)
                pBarCorner.Parent = progBarBg
                
                local progBar = Instance.new("Frame")
                progBar.Size = UDim2.fromScale(math.clamp(currentProgress / data.Requirement, 0, 1), 1)
                progBar.BackgroundColor3 = GameConfig.Colors.Accent
                progBar.Parent = progBarBg
                
                local pfCorner = Instance.new("UICorner")
                pfCorner.CornerRadius = UDim.new(0, 3)
                pfCorner.Parent = progBar
                
                local progText = Instance.new("TextLabel")
                progText.Size = UDim2.fromScale(1, 1)
                progText.BackgroundTransparency = 1
                progText.TextColor3 = Color3.new(1, 1, 1)
                progText.Font = Enum.Font.SourceSansBold
                progText.TextSize = 10
                progText.Text = currentProgress .. " / " .. data.Requirement
                progText.Parent = progBarBg
            end
        end
        
        -- Fix scrolling frame bounds
        task.delay(0.1, function()
            scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiGridLayout.AbsoluteContentSize.Y + 30)
        end)
    end)
    
    -- Animate in
    container.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
        Size = UDim2.fromOffset(800, 500)
    }):Play()
end

function AchievementUI.Hide()
    if not isOpen or not screenGui then return end
    isOpen = false
    
    local container = screenGui:FindFirstChild("Frame")
    if container then
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = UDim2.fromOffset(0, 0)
        }):Play()
    end
    
    task.delay(0.35, function()
        if screenGui then
            screenGui:Destroy()
            screenGui = nil
        end
    end)
end

return AchievementUI
