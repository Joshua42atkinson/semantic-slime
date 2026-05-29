--!strict
--==============================================================
-- MMMM Context: Ethical Monetization Frontier. Displays the Philanthropist's Board, proving to players that vanity purchases tangibly benefit real-world teachers.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DonationBoardController = Knit.CreateController { Name = "DonationBoardController" }

function DonationBoardController:KnitStart()
    print("[DonationBoardController] Connecting to Ethical Monetization Engine...")
    
    local DonationService = Knit.GetService("DonationService")

    -- 1. Listen for new donations to trigger global celebration
    DonationService.DonationOccurred:Connect(function(donorName, amount, productName, message)
        self:TriggerCelebration(donorName, amount, productName, message)
    end)

    -- 2. Build the massive text chat announcement
    print("[DonationBoardController] Online. Listening for Philanthropic events.")
end

-- Visually celebrate a donation
function DonationBoardController:TriggerCelebration(donorName: string, amount: number, productName: string, message: string)
    -- Fire a System Message to the TextChatService
    local channel = TextChatService:FindFirstChild("TextChannels")
    if channel then
        local RBXSystem = channel:FindFirstChild("RBXSystem")
        if RBXSystem then
            local formattedMsg = string.format(
                "<font color='#FFD700' size='20'><b>🌟 PHILANTHROPIST ALERT 🌟</b></font>\n<font color='#FFFFFF'><b>%s</b> just purchased the %s (%d Robux)!\n<i>%s</i>\n<b><font color='#00FF00'>This huge donation supports the Developer!</font></b></font>", 
                donorName, productName, amount, message
            )
            RBXSystem:DisplaySystemMessage(formattedMsg)
        end
    end

    -- Trigger a massive screen shake or particle effect if it's the 5000 R$ tier
    if amount >= 5000 then
        self:GoldenShowerEffect()
    end
end

-- A massive screen effect for huge donations
function DonationBoardController:GoldenShowerEffect()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CharityCelebration"
    screenGui.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = screenGui

    local text = Instance.new("TextLabel")
    text.Text = "🌟 THE DEVELOPER WAS FUNDED! 🌟"
    text.Size = UDim2.new(1, 0, 0.2, 0)
    text.Position = UDim2.new(0, 0, 0.4, 0)
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBlack
    text.BackgroundTransparency = 1
    text.TextTransparency = 1
    text.Parent = frame

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
    TweenService:Create(frame, tweenInfo, {BackgroundTransparency = 0.8}):Play()
    TweenService:Create(text, tweenInfo, {TextTransparency = 0}):Play()

    task.delay(4, function()
        local fadeOut = TweenInfo.new(2)
        TweenService:Create(frame, fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(text, fadeOut, {TextTransparency = 1}):Play()
        task.delay(2, function()
            screenGui:Destroy()
        end)
    end)
    
    -- Play a triumphant sound locally
    local SoundController = Knit.GetController("SoundController")
    if SoundController then
        SoundController:Play("LevelUp")
    end
end

-- Prompt the player to open the donation UI or trigger prompt
function DonationBoardController:PromptPurchase(productId: number)
    local DonationService = Knit.GetService("DonationService")
    DonationService:PromptDonation(productId)
end

return DonationBoardController
