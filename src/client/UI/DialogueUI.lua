--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local DialogueUI = {}

-- Style Constants
local COLORS = {
	Background = Color3.fromHex("#1e293b"), -- Slate 800
	Accent = Color3.fromHex("#facc15"), -- Yellow 400
	Text = Color3.fromHex("#f8fafc"), -- Slate 50
    OptionBg = Color3.fromHex("#334155"), -- Slate 700
    OptionHover = Color3.fromHex("#475569"), -- Slate 600
}

function DialogueUI.Create()
    local gui = Instance.new("ScreenGui")
    gui.Name = "DialogueUI"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 600, 0, 200)
    frame.Position = UDim2.new(0.5, -300, 1, -220) -- Bottom Center
    frame.BackgroundColor3 = COLORS.Background
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Visible = false
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, -40, 0, 30)
    nameLabel.Position = UDim2.new(0, 20, 0, 10)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = COLORS.Accent
    nameLabel.Font = Enum.Font.FredokaOne
    nameLabel.TextSize = 20
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = "NPC Name"
    nameLabel.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "DialogueText"
    textLabel.Size = UDim2.new(1, -40, 1, -50)
    textLabel.Position = UDim2.new(0, 20, 0, 40)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = COLORS.Text
    textLabel.Font = Enum.Font.GothamMedium
    textLabel.TextSize = 18
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Text = "..."
    textLabel.Parent = frame
    
    -- Options Container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "OptionsFrame"
    optionsFrame.Size = UDim2.new(0, 200, 0, 200)
    optionsFrame.Position = UDim2.new(1, 10, 1, 0) -- Right side
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.AnchorPoint = Vector2.new(0, 1)
    optionsFrame.Parent = frame
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.VerticalAlignment = Enum.VerticalAlignment.Bottom
    list.Parent = optionsFrame
    
    return gui
end

function DialogueUI.Show(npcName: string, text: string, options: {any}, callback: (string?) -> ())
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local gui = playerGui:FindFirstChild("DialogueUI") or DialogueUI.Create()
    local frame = gui.MainFrame
    
    frame.NameLabel.Text = npcName
    frame.DialogueText.Text = "" -- Clear for typing
    frame.Visible = true
    
    -- Clear old options
    for _, child in ipairs(frame.OptionsFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    -- Typewriter Effect
    local length = #text
    for i = 1, length do
        frame.DialogueText.Text = string.sub(text, 1, i)
        
        -- Play sound every few chars
        if i % 3 == 0 then
             local SoundManager = require(game.ReplicatedStorage.Shared.SoundManager)
             SoundManager.PlaySFX("UI_Hover", 0.5, 1.5) -- High pitch click
        end
        
        RunService.Heartbeat:Wait()
    end
    
    -- Show Options
    for _, opt in ipairs(options) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = COLORS.OptionBg
        btn.Text = opt.Text
        btn.TextColor3 = COLORS.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.AutoButtonColor = true
        btn.Parent = frame.OptionsFrame
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            frame.Visible = false
            callback(opt.Next) -- Pass next node ID
        end)
    end
    
    -- If no options, basic "Close"
    if #options == 0 then
         local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = COLORS.OptionBg
        btn.Text = "Goodbye."
        btn.TextColor3 = COLORS.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.Parent = frame.OptionsFrame
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            frame.Visible = false
            callback(nil)
        end)
    end
end

return DialogueUI
