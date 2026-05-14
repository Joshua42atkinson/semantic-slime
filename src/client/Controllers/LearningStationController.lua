--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LearningStationController = {}

function LearningStationController:KnitStart()
    print("[LearningStationController] Initialized")
    
    -- Wait for remotes
    local remotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
    local remotes = (remotesMod and remotesMod:IsA("ModuleScript")) and require(remotesMod) or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes", 10)
    local showLearningEvent = remotes:WaitForChild("ShowLearningStation")
    
    -- Listen for learning station triggers
    showLearningEvent:Connect(function(stationData)
        self:ShowLearningUI(stationData)
    end)
end

function LearningStationController:ShowLearningUI(stationData: table)
    -- Create UI if it doesn't exist
    if not self.UI then
        self:CreateUI()
    end
    
    -- Update content
    self.UI.TitleLabel.Text = stationData.Title
    self.UI.ContentLabel.Text = stationData.Content
    
    -- Color based on word root
    if stationData.WordRoot then
        local rootColors = {
            Ignis = Color3.fromRGB(239, 68, 68),   -- Fire/Red
            Aqua = Color3.fromRGB(59, 130, 246),    -- Water/Blue
            Terra = Color3.fromRGB(34, 197, 94),   -- Earth/Green
            Aer = Color3.fromRGB(202, 138, 4),      -- Air/Yellow
            Umbra = Color3.fromRGB(107, 33, 168),  -- Shadow/Purple
            Lux = Color3.fromRGB(245, 158, 11),     -- Light/Orange
        }
        
        local color = rootColors[stationData.WordRoot] or Color3.fromRGB(100, 100, 100)
        self.UI.BorderFrame.BorderColor3 = color
        self.UI.Orb.ImageColor3 = color
    end
    
    -- Show UI with animation
    self.UI.MainFrame.Visible = true
    self.UI.MainFrame.Position = UDim2.new(0.5, 0, 1.5, 0) -- Start below screen
    
    local enterTween = TweenService:Create(
        self.UI.MainFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Position = UDim2.new(0.5, 0, 0.5, 0) }
    )
    enterTween:Play()
end

function LearningStationController:HideUI()
    if not self.UI then return end
    
    local exitTween = TweenService:Create(
        self.UI.MainFrame,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Position = UDim2.new(0.5, 0, 1.5, 0) }
    )
    exitTween:Play()
    
    exitTween.Completed:Wait()
    self.UI.MainFrame.Visible = false
end

function LearningStationController:CreateUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main screen GUI
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LearningStationUI"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main Frame (centered)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Rounded corners
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 16)
    mainCorner.Parent = mainFrame
    
    -- Border frame
    local borderFrame = Instance.new("Frame")
    borderFrame.Name = "BorderFrame"
    borderFrame.Size = UDim2.new(1, 8, 1, 8)
    borderFrame.Position = UDim2.new(0, -4, 0, -4)
    borderFrame.BackgroundTransparency = 1
    borderFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
    borderFrame.BorderMode = Enum.BorderMode.Outline
    borderFrame.BorderThickness = 3
    borderFrame.Parent = mainFrame
    
    local borderCorner = Instance.new("UICorner")
    borderCorner.CornerRadius = UDim.new(0, 16)
    borderCorner.Parent = borderFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -40, 0, 60)
    titleLabel.Position = UDim2.new(0, 20, 0, 20)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Learning Station"
    titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = mainFrame
    
    -- Content
    local contentLabel = Instance.new("TextLabel")
    contentLabel.Name = "ContentLabel"
    contentLabel.Size = UDim2.new(1, -60, 0, 220)
    contentLabel.Position = UDim2.new(0, 30, 0, 90)
    contentLabel.BackgroundTransparency = 1
    contentLabel.Text = "Loading knowledge..."
    contentLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    contentLabel.TextWrapped = true
    contentLabel.TextScaled = true
    contentLabel.Font = Enum.Font.Gotham
    contentLabel.TextXAlignment = Enum.TextXAlignment.Left
    contentLabel.TextYAlignment = Enum.TextYAlignment.Top
    contentLabel.Parent = mainFrame
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextScaled = true
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:HideUI()
    end)
    
    -- Continue button
    local continueButton = Instance.new("TextButton")
    continueButton.Name = "ContinueButton"
    continueButton.Size = UDim2.new(0, 200, 0, 50)
    continueButton.Position = UDim2.new(0.5, -100, 1, -60)
    continueButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    continueButton.Text = "Continue Exploring"
    continueButton.TextColor3 = Color3.new(1, 1, 1)
    continueButton.TextScaled = true
    continueButton.Font = Enum.Font.GothamBold
    continueButton.Parent = mainFrame
    
    local continueCorner = Instance.new("UICorner")
    continueCorner.CornerRadius = UDim.new(0, 12)
    continueCorner.Parent = continueButton
    
    continueButton.MouseButton1Click:Connect(function()
        self:HideUI()
    end)
    
    -- Knowledge orb decoration
    local orb = Instance.new("ImageLabel")
    orb.Name = "Orb"
    orb.Size = UDim2.new(0, 80, 0, 80)
    orb.Position = UDim2.new(0.5, -40, 0, -40)
    orb.BackgroundTransparency = 1
    orb.Image = "rbxasset://textures/particles/sparkles_main.png"
    orb.ImageColor3 = Color3.fromRGB(100, 150, 255)
    orb.ImageTransparency = 0.3
    orb.Parent = mainFrame
    
    -- Store references
    self.UI = {
        MainFrame = mainFrame,
        TitleLabel = titleLabel,
        ContentLabel = contentLabel,
        BorderFrame = borderFrame,
        Orb = orb,
    }
    
    -- Close on escape key
    local contextActionService = game:GetService("ContextActionService")
    contextActionService:BindAction("CloseLearningUI", function(_, inputState)
        if inputState == Enum.UserInputState.End then
            self:HideUI()
        end
    end, false, Enum.KeyboardKeyCode.Escape)
end

return LearningStationController
