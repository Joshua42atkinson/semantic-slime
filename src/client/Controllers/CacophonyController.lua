--!strict
--==============================================================
-- MMMM Context: Renders the existential threat of lexical decay. Visualizes the server-wide challenge of solving grammar/spelling errors to cleanse the Cacophony.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CacophonyController = Knit.CreateController { Name = "CacophonyController" }

function CacophonyController:KnitStart()
    print("[CacophonyController] Linked into the Lexical Underworld.")
    
    local LexicalUnderworldService = Knit.GetService("LexicalUnderworldService")
    
    LexicalUnderworldService.CacophonySummoned:Connect(function(maxHealth)
        self:TriggerRaidUI(maxHealth)
    end)
    
    LexicalUnderworldService.CacophonyDefeated:Connect(function()
        self:DismissRaidUI()
    end)
end

function CacophonyController:TriggerRaidUI(maxHealth: number)
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "RaidUI"
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    
    -- Cinematic letterboxing
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.Parent = screenGui
    
    local bottomBar = Instance.new("Frame")
    bottomBar.Size = UDim2.new(1, 0, 0, 0)
    bottomBar.Position = UDim2.new(0, 0, 1, 0)
    bottomBar.AnchorPoint = Vector2.new(0, 1)
    bottomBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bottomBar.BorderSizePixel = 0
    bottomBar.Parent = screenGui
    
    TweenService:Create(topBar, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
    TweenService:Create(bottomBar, TweenInfo.new(1), {Size = UDim2.new(1, 0, 0.1, 0)}):Play()
    
    -- Main Warning Text
    local warningText = Instance.new("TextLabel")
    warningText.Size = UDim2.new(1, 0, 1, 0)
    warningText.Position = UDim2.new(0, 0, 0, 0)
    warningText.BackgroundTransparency = 1
    warningText.Text = "THE CACOPHONY HAS AWAKENED"
    warningText.TextColor3 = Color3.fromRGB(220, 0, 0)
    warningText.TextScaled = true
    warningText.Font = Enum.Font.GothamBlack
    warningText.TextTransparency = 1
    warningText.Parent = topBar
    
    TweenService:Create(warningText, TweenInfo.new(2), {TextTransparency = 0}):Play()
    
    -- Dungeon Prompt
    local promptText = Instance.new("TextLabel")
    promptText.Size = UDim2.new(1, 0, 0.5, 0)
    promptText.Position = UDim2.new(0, 0, 0.25, 0)
    promptText.BackgroundTransparency = 1
    promptText.Text = "A portal has opened in the Town Square. Descend into the Underworld!"
    promptText.TextColor3 = Color3.fromRGB(200, 200, 255)
    promptText.TextScaled = true
    promptText.Font = Enum.Font.Gotham
    promptText.TextTransparency = 1
    promptText.Parent = bottomBar
    
    TweenService:Create(promptText, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1), {TextTransparency = 0}):Play()
    
    -- Combat Input Box (Pedagogy System)
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.4, 0, 0.4, 0)
    inputBox.Position = UDim2.new(0.3, 0, 0.5, 0)
    inputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.PlaceholderText = "Type a complex word to attack..."
    inputBox.Text = ""
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 20
    inputBox.TextTransparency = 1
    inputBox.BackgroundTransparency = 1
    inputBox.ClearTextOnFocus = true
    inputBox.Parent = bottomBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = inputBox
    
    TweenService:Create(inputBox, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 1.5), {
        TextTransparency = 0, BackgroundTransparency = 0
    }):Play()
    
    -- Handle Submitting a Word
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and #inputBox.Text > 0 then
            local word = inputBox.Text
            inputBox.Text = ""
            
            local LexicalUnderworldService = Knit.GetService("LexicalUnderworldService")
            -- Submit pedagogical correction
            LexicalUnderworldService:SubmitCorrection(word):andThen(function(success, msg)
                if success then
                    -- Good hit! Show visual feedback
                    local originalColor = inputBox.BackgroundColor3
                    inputBox.BackgroundColor3 = Color3.fromRGB(0, 200, 50) -- Green flash
                    task.delay(0.2, function() inputBox.BackgroundColor3 = originalColor end)
                    
                    local SoundController = Knit.GetController("SoundController")
                    if SoundController then SoundController:Play("LevelUp") end
                else
                    -- Invalid word
                    local originalColor = inputBox.BackgroundColor3
                    inputBox.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Red flash
                    task.delay(0.2, function() inputBox.BackgroundColor3 = originalColor end)
                end
            end):catch(warn)
        end
    end)
    
    -- Change Lighting/Music
    local SoundController = Knit.GetController("SoundController")
    if SoundController then
        -- Theoretically trigger a tense music track
        SoundController:Play("Wind") -- Placeholder for eerie wind
    end
end

function CacophonyController:DismissRaidUI()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local raidUi = playerGui:FindFirstChild("RaidUI")
    if raidUi then
        -- Play victory sound
        local SoundController = Knit.GetController("SoundController")
        if SoundController then
            SoundController:Play("LevelUp")
        end
        
        local topBar = raidUi:FindFirstChild("Frame")
        if topBar then
            local msg = topBar:FindFirstChildWhichIsA("TextLabel")
            if msg then
                msg.Text = "CACOPHONY PURIFIED."
                msg.TextColor3 = Color3.fromRGB(0, 255, 100)
            end
        end
        
        task.delay(4, function()
            local fadeOut = TweenInfo.new(1)
            for _, child in ipairs(raidUi:GetChildren()) do
                if child:IsA("GuiObject") then
                    if child.Name == "Frame" then
                        TweenService:Create(child, fadeOut, {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    end
                end
            end
            task.wait(1)
            raidUi:Destroy()
        end)
    end
end

return CacophonyController
