--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local GalleryUI = {}
GalleryUI.__index = GalleryUI

function GalleryUI.new()
    local self = setmetatable({}, GalleryUI)
    self.Screen = nil
    self.Visible = false
    return self
end

function GalleryUI:Create()
    local playerGui = players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GalleryUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 130)
    mainFrame.BorderSizePixel = 3
    mainFrame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(0.7, 0, 0.08, 0)
    title.Position = UDim2.new(0.15, 0, 0.01, 0)
    title.BackgroundTransparency = 1
    title.Text = "🏛️ Slime Gallery"
    title.TextColor3 = Color3.fromRGB(255, 230, 150)
    title.TextScaled = true
    title.Font = Enum.Font.Fantasy
    title.Parent = mainFrame
    
    local categoryTabs = Instance.new("Frame")
    categoryTabs.Name = "CategoryTabs"
    categoryTabs.Size = UDim2.new(0.9, 0, 0.06, 0)
    categoryTabs.Position = UDim2.new(0.05, 0, 0.1, 0)
    categoryTabs.BackgroundTransparency = 1
    categoryTabs.Parent = mainFrame
    
    local categories = {"Newest", "TopRated", "Rarest", "MostEvolved"}
    local tabWidth = 0.22
    for i, cat in ipairs(categories) do
        local tab = Instance.new("TextButton")
        tab.Name = "Tab_" .. cat
        tab.Size = UDim2.new(tabWidth, 0, 1, 0)
        tab.Position = UDim2.new((i-1) * tabWidth, 0, 0, 0)
        tab.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
        tab.Text = cat
        tab.TextColor3 = Color3.fromRGB(200, 200, 220)
        tab.TextScaled = true
        tab.Font = Enum.Font.Gotham
        tab.Parent = categoryTabs
    end
    
    local gridFrame = Instance.new("ScrollingFrame")
    gridFrame.Name = "GridFrame"
    gridFrame.Size = UDim2.new(0.95, 0, 0.75, 0)
    gridFrame.Position = UDim2.new(0.025, 0, 0.17, 0)
    gridFrame.BackgroundTransparency = 1
    gridFrame.ScrollBarThickness = 4
    gridFrame.Parent = mainFrame
    
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.23, 0, 0.3, 0)
    gridLayout.CellPadding = UDim2.new(0.01, 0, 0.01, 0)
    gridLayout.Parent = gridFrame
    
    local addButton = Instance.new("TextButton")
    addButton.Name = "AddButton"
    addButton.Size = UDim2.new(0.15, 0, 0.06, 0)
    addButton.Position = UDim2.new(0.8, 0, 0.93, 0)
    addButton.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    addButton.Text = "+ Add My Slime"
    addButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    addButton.TextScaled = true
    addButton.Font = Enum.Font.GothamBold
    addButton.Parent = mainFrame
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0.06, 0, 0.05, 0)
    closeButton.Position = UDim2.new(0.93, 0, 0.01, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextScaled = true
    closeButton.Parent = mainFrame
    
    self.Screen = screenGui
    self.MainFrame = mainFrame
    self.GridFrame = gridFrame
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    return self
end

function GalleryUI:Show(exhibits)
    if not self.Screen then
        self:Create()
    end
    
    self.Screen.Enabled = true
    self.Visible = true
    
    self:RefreshGrid(exhibits)
end

function GalleryUI:RefreshGrid(exhibits)
    for _, child in ipairs(self.GridFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if not exhibits then return end
    
    for _, exhibit in ipairs(exhibits) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 1, 0)
        card.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
        card.BorderColor3 = Color3.fromRGB(80, 80, 120)
        card.Parent = self.GridFrame
        
        local slimeName = Instance.new("TextLabel")
        slimeName.Size = UDim2.new(1, 0, 0.25, 0)
        slimeName.BackgroundTransparency = 1
        slimeName.Text = exhibit.SlimeTerm or "Unknown"
        slimeName.TextColor3 = Color3.fromRGB(150, 255, 150)
        slimeName.TextScaled = true
        slimeName.Font = Enum.Font.GothamBold
        slimeName.Parent = card
        
        local rarityLabel = Instance.new("TextLabel")
        rarityLabel.Size = UDim2.new(1, 0, 0.15, 0)
        rarityLabel.Position = UDim2.new(0, 0, 0.25, 0)
        rarityLabel.BackgroundTransparency = 1
        rarityLabel.Text = exhibit.SlimeRarity or "Common"
        rarityLabel.TextColor3 = Color3.fromRGB(200, 180, 100)
        rarityLabel.TextScaled = true
        rarityLabel.Font = Enum.Font.Gotham
        rarityLabel.Parent = card
        
        local stageLabel = Instance.new("TextLabel")
        stageLabel.Size = UDim2.new(1, 0, 0.15, 0)
        stageLabel.Position = UDim2.new(0, 0, 0.4, 0)
        stageLabel.BackgroundTransparency = 1
        stageLabel.Text = "Stage " .. tostring(exhibit.EvolutionStage or 1)
        stageLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
        stageLabel.TextScaled = true
        stageLabel.Font = Enum.Font.Gotham
        stageLabel.Parent = card
        
        local likeButton = Instance.new("TextButton")
        likeButton.Size = UDim2.new(0.4, 0, 0.2, 0)
        likeButton.Position = UDim2.new(0.05, 0, 0.75, 0)
        likeButton.BackgroundColor3 = Color3.fromRGB(80, 150, 80)
        likeButton.Text = "❤️ " .. tostring(exhibit.Likes or 0)
        likeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        likeButton.TextScaled = true
        likeButton.Font = Enum.Font.Gotham
        likeButton.Parent = card
        
        local playerLabel = Instance.new("TextLabel")
        playerLabel.Size = UDim2.new(0.5, 0, 0.15, 0)
        playerLabel.Position = UDim2.new(0.5, 0, 0.8, 0)
        playerLabel.BackgroundTransparency = 1
        playerLabel.Text = "by " .. (exhibit.PlayerName or "Anonymous")
        playerLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
        playerLabel.TextScaled = true
        playerLabel.Font = Enum.Font.Gotham
        playerLabel.Parent = card
    end
end

function GalleryUI:Hide()
    if self.Screen then
        self.Screen.Enabled = false
    end
    self.Visible = false
end

function GalleryUI.Initialize()
    print("[GalleryUI] Initializing slime gallery UI...")
    
    -- GalleryUI is ready to show slime gallery when needed
    -- No persistent UI elements needed for initialization
    
    print("[GalleryUI] Slime gallery UI initialized")
end

return GalleryUI
