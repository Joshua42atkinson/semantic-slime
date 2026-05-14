--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local EvolutionUI = {}
EvolutionUI.__index = EvolutionUI

function EvolutionUI.new()
    local self = setmetatable({}, EvolutionUI)
    self.Screen = nil
    self.Visible = false
    return self
end

function EvolutionUI:Create()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EvolutionUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
    mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
    mainFrame.BorderSizePixel = 3
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    title.Text = "🔬 Evolution Chamber"
    title.TextColor3 = Color3.fromRGB(255, 255, 200)
    title.TextScaled = true
    title.Font = Enum.Font.Fantasy
    title.Parent = mainFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Name = "Subtitle"
    subtitle.Size = UDim2.new(1, 0, 0.05, 0)
    subtitle.Position = UDim2.new(0, 0, 0.1, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Choose how your slime will grow!"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 220)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = mainFrame
    
    local slimeContainer = Instance.new("Frame")
    slimeContainer.Name = "SlimeContainer"
    slimeContainer.Size = UDim2.new(0.35, 0, 0.35, 0)
    slimeContainer.Position = UDim2.new(0.05, 0, 0.2, 0)
    slimeContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    slimeContainer.BorderColor3 = Color3.fromRGB(80, 80, 120)
    slimeContainer.Parent = mainFrame
    
    local slimeName = Instance.new("TextLabel")
    slimeName.Name = "SlimeName"
    slimeName.Size = UDim2.new(1, 0, 0.2, 0)
    slimeName.Position = UDim2.new(0, 0, 0.7, 0)
    slimeName.BackgroundTransparency = 1
    slimeName.Text = "Your Slime"
    slimeName.TextColor3 = Color3.fromRGB(150, 255, 150)
    slimeName.TextScaled = true
    slimeName.Font = Enum.Font.GothamBold
    slimeName.Parent = slimeContainer
    
    local stageInfo = Instance.new("TextLabel")
    stageInfo.Name = "StageInfo"
    stageInfo.Size = UDim2.new(1, 0, 0.1, 0)
    stageInfo.Position = UDim2.new(0, 0, 0.85, 0)
    stageInfo.BackgroundTransparency = 1
    stageInfo.Text = "Stage 1 - Baseline"
    stageInfo.TextColor3 = Color3.fromRGB(180, 180, 180)
    stageInfo.TextScaled = true
    stageInfo.Font = Enum.Font.Gotham
    stageInfo.Parent = slimeContainer
    
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.Size = UDim2.new(0.55, 0, 0.6, 0)
    optionsContainer.Position = UDim2.new(0.42, 0, 0.2, 0)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.Parent = mainFrame
    
    local evolveButton = Instance.new("TextButton")
    evolveButton.Name = "EvolveButton"
    evolveButton.Size = UDim2.new(0.8, 0, 0.12, 0)
    evolveButton.Position = UDim2.new(0.1, 0, 0.85, 0)
    evolveButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
    evolveButton.Text = "🔄 Evolve!"
    evolveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    evolveButton.TextScaled = true
    evolveButton.Font = Enum.Font.GothamBold
    evolveButton.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.08, 0, 0.06, 0)
    closeButton.Position = UDim2.new(0.91, 0, 0.01, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame
    
    local xpLabel = Instance.new("TextLabel")
    xpLabel.Name = "XPLabel"
    xpLabel.Size = UDim2.new(0.4, 0, 0.08, 0)
    xpLabel.Position = UDim2.new(0.05, 0, 0.88, 0)
    xpLabel.BackgroundTransparency = 1
    xpLabel.Text = "XP Available: 0"
    xpLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    xpLabel.TextScaled = true
    xpLabel.Font = Enum.Font.Gotham
    xpLabel.Parent = mainFrame
    
    self.Screen = screenGui
    self.MainFrame = mainFrame
    self.SlimeName = slimeName
    self.StageInfo = stageInfo
    self.XPLabel = xpLabel
    self.EvolveButton = evolveButton
    self.CloseButton = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    return self
end

function EvolutionUI:Show(slimeData, availableEvolutions)
    if not self.Screen then
        self:Create()
    end
    
    self.Screen.Enabled = true
    self.Visible = true
    
    if slimeData then
        self.SlimeName.Text = slimeData.Term or "Unknown"
        local stageNames = {"Baseline", "Elementary", "Intermediate", "Advanced", "Graduate"}
        local stageName = stageNames[slimeData.EvolutionStage] or "Unknown"
        self.StageInfo.Text = "Stage " .. tostring(slimeData.EvolutionStage) .. " - " .. stageName
        self.XPLabel.Text = "XP Available: " .. tostring(slimeData.XP)
    end
    
    self:RefreshEvolutionOptions(availableEvolutions)
end

function EvolutionUI:RefreshEvolutionOptions(options)
    for _, child in ipairs(self.OptionsContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not options then return end
    
    local yPos = 0.05
    for i, option in ipairs(options) do
        local optionFrame = Instance.new("Frame")
        optionFrame.Size = UDim2.new(1, 0, 0.18, 0)
        optionFrame.Position = UDim2.new(0, 0, yPos, 0)
        optionFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        optionFrame.BorderColor3 = Color3.fromRGB(100, 100, 150)
        optionFrame.Parent = self.OptionsContainer
        
        local optionTitle = Instance.new("TextLabel")
        optionTitle.Size = UDim2.new(1, 0, 0.4, 0)
        optionTitle.BackgroundTransparency = 1
        optionTitle.Text = option.name .. " (" .. option.xpCost .. " XP)"
        optionTitle.TextColor3 = Color3.fromRGB(200, 220, 255)
        optionTitle.TextXAlignment = Enum.TextXAlignment.Left
        optionTitle.TextScaled = true
        optionTitle.Parent = optionFrame
        
        local optionDesc = Instance.new("TextLabel")
        optionDesc.Size = UDim2.new(1, 0, 0.5, 0)
        optionDesc.Position = UDim2.new(0, 0, 0.4, 0)
        optionDesc.BackgroundTransparency = 1
        optionDesc.Text = option.description
        optionDesc.TextColor3 = Color3.fromRGB(160, 160, 180)
        optionDesc.TextXAlignment = Enum.TextXAlignment.Left
        optionDesc.TextScaled = true
        optionDesc.Parent = optionFrame
        
        local selectBtn = Instance.new("TextButton")
        selectBtn.Size = UDim2.new(0.25, 0, 0.35, 0)
        selectBtn.Position = UDim2.new(0.7, 0, 0.3, 0)
        selectBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        selectBtn.Text = "Select"
        selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        selectBtn.TextScaled = true
        selectBtn.Parent = optionFrame
        
        yPos = yPos + 0.2
    end
end

function EvolutionUI:Hide()
    if self.Screen then
        self.Screen.Enabled = false
    end
    self.Visible = false
end

function EvolutionUI:ShowSuccessMessage(newStage)
    if not self.Screen then return end
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(0.6, 0, 0.2, 0)
    msg.Position = UDim2.new(0.2, 0, 0.4, 0)
    msg.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    msg.BorderColor3 = Color3.fromRGB(100, 255, 100)
    msg.Text = "🎉 Evolved to Stage " .. tostring(newStage) .. "!"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.TextScaled = true
    msg.Font = Enum.Font.GothamBold
    msg.Parent = self.MainFrame
    
    local tween = TweenService:Create(msg, TweenInfo.new(2), {BackgroundTransparency = 1, TextTransparency = 1})
    tween:Play()
    tween.Completed:Wait()
    msg:Destroy()
end

function EvolutionUI.Initialize()
    print("[EvolutionUI] Initializing evolution UI...")
    
    -- EvolutionUI is ready to show evolution effects when needed
    -- No persistent UI elements needed for initialization
    
    print("[EvolutionUI] Evolution UI initialized")
end

return EvolutionUI
