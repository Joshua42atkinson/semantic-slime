--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MorphemeReportUI = {}
MorphemeReportUI.__index = MorphemeReportUI

function MorphemeReportUI.new()
    local self = setmetatable({}, MorphemeReportUI)
    self.Screen = nil
    self.Visible = false
    return self
end

function MorphemeReportUI:Create()
    local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MorphemeReportUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.7, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.15, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
    mainFrame.BorderSizePixel = 3
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 60, 100)
    title.Text = "📊 Morpheme Progress Report"
    title.TextColor3 = Color3.fromRGB(255, 255, 200)
    title.TextScaled = true
    title.Font = Enum.Font.Fantasy
    title.Parent = mainFrame
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
    scrollFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, 0, 0.12, 0)
    statsContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
    statsContainer.BorderColor3 = Color3.fromRGB(100, 100, 150)
    statsContainer.Parent = scrollFrame
    
    local totalWords = Instance.new("TextLabel")
    totalWords.Name = "TotalWords"
    totalWords.Size = UDim2.new(0.5, 0, 1, 0)
    totalWords.BackgroundTransparency = 1
    totalWords.Text = "Total Words Learned: 0"
    totalWords.TextColor3 = Color3.fromRGB(200, 220, 255)
    totalWords.TextScaled = true
    totalWords.Font = Enum.Font.Gotham
    totalWords.Parent = statsContainer
    
    local accuracy = Instance.new("TextLabel")
    accuracy.Name = "Accuracy"
    accuracy.Size = UDim2.new(0.5, 0, 1, 0)
    accuracy.Position = UDim2.new(0.5, 0, 0, 0)
    accuracy.BackgroundTransparency = 1
    accuracy.Text = "Accuracy: 0%"
    accuracy.TextColor3 = Color3.fromRGB(150, 255, 150)
    accuracy.TextScaled = true
    accuracy.Font = Enum.Font.Gotham
    accuracy.Parent = statsContainer
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.15, 0, 0.08, 0)
    closeButton.Position = UDim2.new(0.8, 0, 0.9, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
    closeButton.Text = "Continue →"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local shareButton = Instance.new("TextButton")
    shareButton.Name = "ShareButton"
    shareButton.Size = UDim2.new(0.15, 0, 0.08, 0)
    shareButton.Position = UDim2.new(0.55, 0, 0.9, 0)
    shareButton.BackgroundColor3 = Color3.fromRGB(80, 80, 150)
    shareButton.Text = "📤 Share"
    shareButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    shareButton.TextScaled = true
    shareButton.Font = Enum.Font.Gotham
    shareButton.Parent = mainFrame
    
    self.Screen = screenGui
    self.MainFrame = mainFrame
    self.ScrollFrame = scrollFrame
    self.TotalWords = totalWords
    self.Accuracy = accuracy
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    return self
end

function MorphemeReportUI:Show(morphemeData)
    if not self.Screen then
        self:Create()
    end
    
    self.ScrollFrame.CanvasPosition = Vector2.new(0, 0)
    self.Screen.Enabled = true
    self.Visible = true
    
    if morphemeData then
        local totalAttempts = morphemeData.totalAttempts or 0
        local correctAttempts = morphemeData.correctAttempts or 0
        local accuracy = totalAttempts > 0 and math.floor((correctAttempts / totalAttempts) * 100) or 0
        
        self.TotalWords.Text = "Total Words Learned: " .. tostring(morphemeData.uniqueWords or 0)
        self.Accuracy.Text = "Accuracy: " .. tostring(accuracy) .. "%"
        
        if accuracy >= 80 then
            self.Accuracy.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif accuracy >= 50 then
            self.Accuracy.TextColor3 = Color3.fromRGB(255, 255, 100)
        else
            self.Accuracy.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
    
    self:RefreshMorphemeList(morphemeData)
end

function MorphemeReportUI:RefreshMorphemeList(morphemeData)
    for _, child in ipairs(self.ScrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "StatsContainer" then
            child:Destroy()
        end
    end
    
    if not morphemeData or not morphemeData.morphemes then return end
    
    for morpheme, data in pairs(morphemeData.morphemes) do
        local morphemeFrame = Instance.new("Frame")
        morphemeFrame.Size = UDim2.new(1, 0, 0.15, 0)
        morphemeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
        morphemeFrame.BorderColor3 = Color3.fromRGB(80, 80, 120)
        morphemeFrame.Parent = self.ScrollFrame
        
        local morphemeLabel = Instance.new("TextLabel")
        morphemeLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
        morphemeLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
        morphemeLabel.BackgroundTransparency = 1
        morphemeLabel.Text = morpheme
        morphemeLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        morphemeLabel.TextXAlignment = Enum.TextXAlignment.Left
        morphemeLabel.TextScaled = true
        morphemeLabel.Font = Enum.Font.GothamBold
        morphemeLabel.Parent = morphemeFrame
        
        local attemptsLabel = Instance.new("TextLabel")
        attemptsLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
        attemptsLabel.Position = UDim2.new(0.35, 0, 0.1, 0)
        attemptsLabel.BackgroundTransparency = 1
        attemptsLabel.Text = "Attempts: " .. tostring(data.attempts or 0)
        attemptsLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
        attemptsLabel.TextScaled = true
        attemptsLabel.Font = Enum.Font.Gotham
        attemptsLabel.Parent = morphemeFrame
        
        local masteryBar = Instance.new("Frame")
        masteryBar.Size = UDim2.new(0.3, 0, 0.3, 0)
        masteryBar.Position = UDim2.new(0.68, 0, 0.35, 0)
        masteryBar.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        masteryBar.Parent = morphemeFrame
        
        local masteryFill = Instance.new("Frame")
        masteryFill.Size = UDim2.new(math.min((data.mastery or 0) / 10, 1), 0, 1, 0)
        masteryFill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
        masteryFill.Parent = masteryBar
        
        local masteryLabel = Instance.new("TextLabel")
        masteryLabel.Size = UDim2.new(0.3, 0, 0.4, 0)
        masteryLabel.Position = UDim2.new(0.68, 0, 0.1, 0)
        masteryLabel.BackgroundTransparency = 1
        masteryLabel.Text = "Mastery: " .. tostring(data.mastery or 0) .. "/10"
        masteryLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
        masteryLabel.TextScaled = true
        masteryLabel.Font = Enum.Font.Gotham
        masteryLabel.Parent = morphemeFrame
    end
end

function MorphemeReportUI:Hide()
    if self.Screen then
        self.Screen.Enabled = false
    end
    self.Visible = false
end

function MorphemeReportUI.Initialize()
    print("[MorphemeReportUI] Initializing morpheme report UI...")
    
    -- MorphemeReportUI is ready to show morpheme reports when needed
    -- No persistent UI elements needed for initialization
    
    print("[MorphemeReportUI] Morpheme report UI initialized")
end

return MorphemeReportUI
