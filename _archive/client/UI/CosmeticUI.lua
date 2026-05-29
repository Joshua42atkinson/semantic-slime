--!strict
--==============================================================
-- MMMM Context: Visualizing Philanthropic Fashion. This UI allows players to preview and purchase Slime Auras.
--==============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local CosmeticUI = {}
CosmeticUI.__index = CosmeticUI

local isOpen = false
local screenGui: ScreenGui? = nil
local mainFrame: Frame? = nil

-- The same data from the Server (duplicated here for UI rendering)
local COSMETIC_PASSES = {
    { Id = 2000001, Name = "Galactic Aura", Desc = "Swirling starlight and nebula dust.", Color = Color3.fromRGB(150, 0, 255) },
    { Id = 2000002, Name = "Holographic Aurora", Desc = "Digital scanlines and hyper-light.", Color = Color3.fromRGB(0, 255, 200) },
    { Id = 2000003, Name = "Abyssal Void", Desc = "A singularity of pure shadow.", Color = Color3.fromRGB(0, 0, 0) },
}

function CosmeticUI.Initialize()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CosmeticUI"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.Parent = playerGui
    
    -- Main Container
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = GameConfig.Colors.Dark
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = mainFrame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = GameConfig.Colors.Primary
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = GameConfig.Colors.Charcoal
    header.Text = "🌟 SLIME COSMETICS & AURAS 🌟"
    header.TextColor3 = GameConfig.Colors.Accent
    header.Font = Enum.Font.GothamBlack
    header.TextSize = 20
    header.Parent = mainFrame
    
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 16)
    hCorner.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        CosmeticUI.Toggle()
    end)
    
    -- Scroll Frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -40, 1, -70)
    scroll.Position = UDim2.new(0, 20, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.Parent = mainFrame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = scroll
    
    -- Build Cosmestic Cards
    for i, data in ipairs(COSMETIC_PASSES) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -10, 0, 100)
        card.BackgroundColor3 = GameConfig.Colors.Base
        card.BackgroundTransparency = 0.5
        card.Parent = scroll
        
        local corner2 = Instance.new("UICorner")
        corner2.CornerRadius = UDim.new(0, 8)
        corner2.Parent = card
        
        -- Color Display
        local colorDisplay = Instance.new("Frame")
        colorDisplay.Size = UDim2.new(0, 80, 0, 80)
        colorDisplay.Position = UDim2.new(0, 10, 0, 10)
        colorDisplay.BackgroundColor3 = data.Color
        colorDisplay.Parent = card
        local corner3 = Instance.new("UICorner")
        corner3.CornerRadius = UDim.new(1, 0)
        corner3.Parent = colorDisplay
        
        -- Name
        local nameTxt = Instance.new("TextLabel")
        nameTxt.Size = UDim2.new(0.5, 0, 0.4, 0)
        nameTxt.Position = UDim2.new(0, 100, 0, 10)
        nameTxt.BackgroundTransparency = 1
        nameTxt.Text = data.Name
        nameTxt.TextColor3 = Color3.new(1, 1, 1)
        nameTxt.TextXAlignment = Enum.TextXAlignment.Left
        nameTxt.Font = Enum.Font.GothamBold
        nameTxt.TextSize = 22
        nameTxt.Parent = card
        
        -- Desc
        local descTxt = Instance.new("TextLabel")
        descTxt.Size = UDim2.new(0.5, 0, 0.4, 0)
        descTxt.Position = UDim2.new(0, 100, 0, 50)
        descTxt.BackgroundTransparency = 1
        descTxt.Text = data.Desc
        descTxt.TextColor3 = GameConfig.Colors.TextDim
        descTxt.TextXAlignment = Enum.TextXAlignment.Left
        descTxt.TextYAlignment = Enum.TextYAlignment.Top
        descTxt.Font = Enum.Font.Gotham
        descTxt.TextSize = 14
        descTxt.TextWrapped = true
        descTxt.Parent = card
        
        -- Purchase / Equip Button
        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(0, 120, 0, 60)
        actionBtn.Position = UDim2.new(1, -130, 0, 20)
        actionBtn.BackgroundColor3 = GameConfig.Colors.Primary
        actionBtn.Text = "Purchase"
        actionBtn.TextColor3 = Color3.new(1, 1, 1)
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.TextSize = 18
        actionBtn.Parent = card
        local corner4 = Instance.new("UICorner")
        corner4.CornerRadius = UDim.new(0, 8)
        corner4.Parent = actionBtn
        
        -- Click Event
        actionBtn.MouseButton1Click:Connect(function()
            -- Check ownership using MarketplaceService
            local owns = false
            pcall(function() owns = MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, data.Id) end)
            
            local CosmeticController = Knit.GetController("CosmeticController")
            if owns then
                if CosmeticController then
                    actionBtn.Text = "Equipping..."
                    CosmeticController:EquipAura(data.Id)
                    task.wait(1)
                    actionBtn.Text = "Equipped!"
                    actionBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                end
            else
                if CosmeticController then
                    CosmeticController:PromptPurchase(data.Id)
                end
            end
        end)
    end
end

function CosmeticUI.Toggle()
    if not screenGui then return end
    
    isOpen = not isOpen
    
    if isOpen then
        screenGui.Enabled = true
        if mainFrame then
            mainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
            mainFrame.GroupTransparency = 1
            
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                GroupTransparency = 0
            }):Play()
        end
    else
        if mainFrame then
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.55, 0),
                GroupTransparency = 1
            }):Play()
            
            task.delay(0.2, function()
                if not isOpen then
                    screenGui.Enabled = false
                end
            end)
        end
    end
end

return CosmeticUI
