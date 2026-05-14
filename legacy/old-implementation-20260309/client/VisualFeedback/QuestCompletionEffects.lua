--!strict
-- Quest Completion Visual Effects System
-- Provides beautiful animations and effects for quest completion

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local QuestCompletionEffects = {}

-- Configuration
local COMPLETION_DURATION = 3
local PARTICLE_COUNT = 50
local GLOW_INTENSITY = 10
local CELEBRATION_DURATION = 5

-- Quest completion colors
local QUEST_COLORS = {
    Success = Color3.fromRGB(50, 255, 50),
    XP = Color3.fromRGB(255, 200, 50),
    Insight = Color3.fromRGB(100, 150, 255),
    Evolution = Color3.fromRGB(255, 100, 200),
    Reward = Color3.fromRGB(255, 255, 100)
}

-- Sound effects
local sounds = {
    complete = SoundService:CreateSound(),
    xp = SoundService:CreateSound(),
    insight = SoundService:CreateSound(),
    evolution = SoundService:CreateSound(),
    celebration = SoundService:CreateSound()
}

-- Initialize sounds
local function setupSounds()
    sounds.complete.SoundId = "rbxassetid://6788484923"
    sounds.complete.Volume = 0.5
    sounds.complete.Pitch = 1.2
    
    sounds.xp.SoundId = "rbxassetid://6788484923"
    sounds.xp.Volume = 0.4
    sounds.xp.Pitch = 1.3
    
    sounds.insight.SoundId = "rbxassetid://6788484923"
    sounds.insight.Volume = 0.4
    sounds.insight.Pitch = 1.1
    
    sounds.evolution.SoundId = "rbxassetid://6788484923"
    sounds.evolution.Volume = 0.5
    sounds.evolution.Pitch = 1.4
    
    sounds.celebration.SoundId = "rbxassetid://6788484923"
    sounds.celebration.Volume = 0.6
    sounds.celebration.Pitch = 1.5
end

-- Quest completion burst effect
local function createCompletionBurst(position: Vector3, questTitle: string)
    -- Create central burst
    local burstPart = Instance.new("Part")
    burstPart.Name = "QuestCompletionBurst"
    burstPart.Size = Vector3.new(0.1, 0.1, 0.1)
    burstPart.Material = Enum.Material.Neon
    burstPart.Color = QUEST_COLORS.Success
    burstPart.Transparency = 0
    burstPart.Anchored = true
    burstPart.CanCollide = false
    burstPart.Position = position + Vector3.new(0, 5, 0)
    burstPart.Parent = workspace
    
    local burstLight = Instance.new("PointLight")
    burstLight.Name = "BurstGlow"
    burstLight.Color = QUEST_COLORS.Success
    burstLight.Brightness = GLOW_INTENSITY * 2
    burstLight.Range = 30
    burstLight.Parent = burstPart
    
    -- Create quest title display
    local titleBillboard = Instance.new("BillboardGui")
    titleBillboard.Name = "QuestTitle"
    titleBillboard.Size = UDim2.fromScale(8, 4)
    titleBillboard.AlwaysOnTop = true
    titleBillboard.StudsOffset = Vector3.new(0, 8, 0)
    titleBillboard.Parent = burstPart
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.fromScale(1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextStrokeTransparency = 0
    titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.Text = "✨ QUEST COMPLETE! ✨\n" .. questTitle
    titleLabel.Parent = titleBillboard
    
    -- Create celebration particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "CelebrationParticles"
    attachment.Position = Vector3.new(0, 0, 0)
    attachment.Parent = burstPart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "CelebrationSparkles"
    particles.Color = ColorSequence.new(QUEST_COLORS.Success)
    particles.Transparency = NumberSequence.new(0.2, 1)
    particles.Size = NumberSequence.new(1, 0)
    particles.Rate = PARTICLE_COUNT
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Speed = NumberRange.new(5, 10)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate burst
    local burstTween = TweenService:Create(burstPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(20, 20, 20),
        Transparency = 1
    })
    
    burstTween:Play()
    
    -- Play completion sound
    sounds.complete:Play()
    
    -- Clean up
    Debris:AddItem(burstPart, COMPLETION_DURATION)
end

-- XP gain effect
local function createXPGainEffect(position: Vector3, xpAmount: number)
    -- Create XP orb
    local xpOrb = Instance.new("Part")
    xpOrb.Name = "XPGainOrb"
    xpOrb.Size = Vector3.new(2, 2, 2)
    xpOrb.Material = Enum.Material.Neon
    xpOrb.Color = QUEST_COLORS.XP
    xpOrb.Transparency = 0.3
    xpOrb.Anchored = true
    xpOrb.CanCollide = false
    xpOrb.Position = position + Vector3.new(0, 3, 0)
    xpOrb.Parent = workspace
    
    local xpLight = Instance.new("PointLight")
    xpLight.Name = "XPGlow"
    xpLight.Color = QUEST_COLORS.XP
    xpLight.Brightness = GLOW_INTENSITY
    xpLight.Range = 15
    xpLight.Parent = xpOrb
    
    -- Create XP text
    local xpBillboard = Instance.new("BillboardGui")
    xpBillboard.Name = "XPDisplay"
    xpBillboard.Size = UDim2.fromScale(4, 2)
    xpBillboard.AlwaysOnTop = true
    xpBillboard.StudsOffset = Vector3.new(0, 3, 0)
    xpBillboard.Parent = xpOrb
    
    local xpLabel = Instance.new("TextLabel")
    xpLabel.Size = UDim2.fromScale(1, 1)
    xpLabel.BackgroundTransparency = 1
    xpLabel.TextColor3 = Color3.new(1, 1, 1)
    xpLabel.TextStrokeTransparency = 0
    xpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    xpLabel.Font = Enum.Font.GothamBold
    xpLabel.TextScaled = true
    xpLabel.Text = "+" .. xpAmount .. " XP"
    xpLabel.Parent = xpBillboard
    
    -- Create XP particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "XPParticles"
    attachment.Parent = xpOrb
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "XPSparkles"
    particles.Color = ColorSequence.new(QUEST_COLORS.XP)
    particles.Transparency = NumberSequence.new(0.3, 1)
    particles.Size = NumberSequence.new(0.5, 0)
    particles.Rate = PARTICLE_COUNT / 2
    particles.Lifetime = NumberRange.new(0.5, 1.5)
    particles.Speed = NumberRange.new(3, 6)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate XP orb
    local floatTween = TweenService:Create(xpOrb, TweenInfo.new(COMPLETION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = position + Vector3.new(0, 8, 0),
        Transparency = 1,
        Size = Vector3.new(0.5, 0.5, 0.5)
    })
    
    floatTween:Play()
    
    -- Play XP sound
    sounds.xp:Play()
    
    -- Clean up
    Debris:AddItem(xpOrb, COMPLETION_DURATION)
end

-- Insight gain effect
local function createInsightGainEffect(position: Vector3, insightAmount: number)
    -- Create insight orb
    local insightOrb = Instance.new("Part")
    insightOrb.Name = "InsightGainOrb"
    insightOrb.Size = Vector3.new(1.5, 1.5, 1.5)
    insightOrb.Material = Enum.Material.Neon
    insightOrb.Color = QUEST_COLORS.Insight
    insightOrb.Transparency = 0.3
    insightOrb.Anchored = true
    insightOrb.CanCollide = false
    insightOrb.Position = position + Vector3.new(0, 2, 0)
    insightOrb.Parent = workspace
    
    local insightLight = Instance.new("PointLight")
    insightLight.Name = "InsightGlow"
    insightLight.Color = QUEST_COLORS.Insight
    insightLight.Brightness = GLOW_INTENSITY
    insightLight.Range = 12
    insightLight.Parent = insightOrb
    
    -- Create insight text
    local insightBillboard = Instance.new("BillboardGui")
    insightBillboard.Name = "InsightDisplay"
    insightBillboard.Size = UDim2.fromScale(3, 2)
    insightBillboard.AlwaysOnTop = true
    insightBillboard.StudsOffset = Vector3.new(0, 2, 0)
    insightBillboard.Parent = insightOrb
    
    local insightLabel = Instance.new("TextLabel")
    insightLabel.Size = UDim2.fromScale(1, 1)
    insightLabel.BackgroundTransparency = 1
    insightLabel.TextColor3 = Color3.new(1, 1, 1)
    insightLabel.TextStrokeTransparency = 0
    insightLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    insightLabel.Font = Enum.Font.GothamBold
    insightLabel.TextScaled = true
    insightLabel.Text = "+" .. insightAmount .. " Insight"
    insightLabel.Parent = insightBillboard
    
    -- Create insight particles (wisdom sparkles)
    local attachment = Instance.new("Attachment")
    attachment.Name = "InsightParticles"
    attachment.Parent = insightOrb
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "InsightSparkles"
    particles.Color = ColorSequence.new(QUEST_COLORS.Insight)
    particles.Transparency = NumberSequence.new(0.4, 1)
    particles.Size = NumberSequence.new(0.3, 0)
    particles.Rate = PARTICLE_COUNT / 3
    particles.Lifetime = NumberRange.new(0.8, 1.5)
    particles.Speed = NumberRange.new(2, 4)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate insight orb
    local floatTween = TweenService:Create(insightOrb, TweenInfo.new(COMPLETION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = position + Vector3.new(0, 6, 0),
        Transparency = 1,
        Size = Vector3.new(0.3, 0.3, 0.3)
    })
    
    floatTween:Play()
    
    -- Play insight sound
    sounds.insight:Play()
    
    -- Clean up
    Debris:AddItem(insightOrb, COMPLETION_DURATION)
end

-- Evolution point effect
local function createEvolutionPointEffect(position: Vector3, evolutionPoints: number)
    -- Create evolution orb
    local evolutionOrb = Instance.new("Part")
    evolutionOrb.Name = "EvolutionGainOrb"
    evolutionOrb.Size = Vector3.new(2.5, 2.5, 2.5)
    evolutionOrb.Material = Enum.Material.Neon
    evolutionOrb.Color = QUEST_COLORS.Evolution
    evolutionOrb.Transparency = 0.3
    evolutionOrb.Anchored = true
    evolutionOrb.CanCollide = false
    evolutionOrb.Position = position + Vector3.new(0, 4, 0)
    evolutionOrb.Parent = workspace
    
    local evolutionLight = Instance.new("PointLight")
    evolutionLight.Name = "EvolutionGlow"
    evolutionLight.Color = QUEST_COLORS.Evolution
    evolutionLight.Brightness = GLOW_INTENSITY * 1.5
    evolutionLight.Range = 20
    evolutionLight.Parent = evolutionOrb
    
    -- Create evolution text
    local evolutionBillboard = Instance.new("BillboardGui")
    evolutionBillboard.Name = "EvolutionDisplay"
    evolutionBillboard.Size = UDim2.fromScale(5, 3)
    evolutionBillboard.AlwaysOnTop = true
    evolutionBillboard.StudsOffset = Vector3.new(0, 4, 0)
    evolutionBillboard.Parent = evolutionOrb
    
    local evolutionLabel = Instance.new("TextLabel")
    evolutionLabel.Size = UDim2.fromScale(1, 1)
    evolutionLabel.BackgroundTransparency = 1
    evolutionLabel.TextColor3 = Color3.new(1, 1, 1)
    evolutionLabel.TextStrokeTransparency = 0
    evolutionLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    evolutionLabel.Font = Enum.Font.GothamBold
    evolutionLabel.TextScaled = true
    evolutionLabel.Text = "🧬 +" .. evolutionPoints .. " Evolution Points 🧬"
    evolutionLabel.Parent = evolutionBillboard
    
    -- Create evolution particles (DNA-like helix)
    local attachment = Instance.new("Attachment")
    attachment.Name = "EvolutionParticles"
    attachment.Parent = evolutionOrb
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "EvolutionSparkles"
    particles.Color = ColorSequence.new(QUEST_COLORS.Evolution)
    particles.Transparency = NumberSequence.new(0.2, 1)
    particles.Size = NumberSequence.new(0.8, 0)
    particles.Rate = PARTICLE_COUNT
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Speed = NumberRange.new(4, 8)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate evolution orb
    local floatTween = TweenService:Create(evolutionOrb, TweenInfo.new(COMPLETION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = position + Vector3.new(0, 10, 0),
        Transparency = 1,
        Size = Vector3.new(0.5, 0.5, 0.5)
    })
    
    floatTween:Play()
    
    -- Play evolution sound
    sounds.evolution:Play()
    
    -- Clean up
    Debris:AddItem(evolutionOrb, COMPLETION_DURATION)
end

-- Celebration fireworks
local function createCelebrationFireworks(position: Vector3)
    -- Create multiple firework bursts
    for i = 1, 5 do
        task.delay(i * 0.5, function()
            local fireworkPosition = position + Vector3.new(
                math.random(-10, 10),
                math.random(5, 15),
                math.random(-10, 10)
            )
            
            -- Create firework explosion
            local firework = Instance.new("Part")
            firework.Name = "Firework" .. i
            firework.Size = Vector3.new(0.1, 0.1, 0.1)
            firework.Material = Enum.Material.Neon
            firework.Color = Color3.new(math.random(), math.random(), math.random())
            firework.Transparency = 0
            firework.Anchored = true
            firework.CanCollide = false
            firework.Position = fireworkPosition
            firework.Parent = workspace
            
            local fireworkLight = Instance.new("PointLight")
            fireworkLight.Color = firework.Color
            fireworkLight.Brightness = GLOW_INTENSITY
            fireworkLight.Range = 25
            fireworkLight.Parent = firework
            
            -- Create firework particles
            local attachment = Instance.new("Attachment")
            attachment.Parent = firework
            
            local particles = Instance.new("ParticleEmitter")
            particles.Color = ColorSequence.new(firework.Color)
            particles.Transparency = NumberSequence.new(0.1, 1)
            particles.Size = NumberSequence.new(1, 0)
            particles.Rate = PARTICLE_COUNT * 2
            particles.Lifetime = NumberRange.new(1, 2)
            particles.Speed = NumberRange.new(8, 15)
            particles.SpreadAngle = Vector2.new(180, 180)
            particles.Parent = attachment
            
            -- Animate firework
            local fireworkTween = TweenService:Create(firework, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = Vector3.new(15, 15, 15),
                Transparency = 1
            })
            
            fireworkTween:Play()
            
            -- Clean up
            Debris:AddItem(firework, 0.8)
        end)
    end
    
    -- Play celebration sound
    sounds.celebration:Play()
end

-- Reward summary display
local function createRewardSummary(position: Vector3, rewards: {XP: number, Insight: number, EvolutionPoints: number})
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create reward summary GUI
    local summaryGui = Instance.new("ScreenGui")
    summaryGui.Name = "QuestRewardSummary"
    summaryGui.ResetOnSpawn = false
    summaryGui.Parent = playerGui
    
    local summaryFrame = Instance.new("Frame")
    summaryFrame.Name = "SummaryFrame"
    summaryFrame.Size = UDim2.new(0, 300, 0, 200)
    summaryFrame.Position = UDim2.new(0.5, -150, 0.3, 0)
    summaryFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    summaryFrame.BorderSizePixel = 0
    summaryFrame.BackgroundTransparency = 0.2
    summaryFrame.Parent = summaryGui
    
    local summaryCorner = Instance.new("UICorner")
    summaryCorner.CornerRadius = UDim.new(0, 15)
    summaryCorner.Parent = summaryFrame
    
    local summaryStroke = Instance.new("UIStroke")
    summaryStroke.Color = QUEST_COLORS.Success
    summaryStroke.Thickness = 3
    summaryStroke.Transparency = 0.3
    summaryStroke.Parent = summaryFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 40)
    titleLabel.Position = UDim2.fromOffset(10, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = QUEST_COLORS.Success
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.Text = "🎉 QUEST REWARDS 🎉"
    titleLabel.Parent = summaryFrame
    
    -- XP reward
    if rewards.XP > 0 then
        local xpFrame = Instance.new("Frame")
        xpFrame.Name = "XPReward"
        xpFrame.Size = UDim2.new(1, -20, 0, 40)
        xpFrame.Position = UDim2.fromOffset(10, 60)
        xpFrame.BackgroundTransparency = 1
        xpFrame.Parent = summaryFrame
        
        local xpLabel = Instance.new("TextLabel")
        xpLabel.Size = UDim2.new(1, 0, 1, 0)
        xpLabel.BackgroundTransparency = 1
        xpLabel.TextColor3 = QUEST_COLORS.XP
        xpLabel.Font = Enum.Font.GothamBold
        xpLabel.TextSize = 16
        xpLabel.Text = "+" .. rewards.XP .. " XP"
        xpLabel.TextXAlignment = Enum.TextXAlignment.Left
        xpLabel.Parent = xpFrame
    end
    
    -- Insight reward
    if rewards.Insight > 0 then
        local insightFrame = Instance.new("Frame")
        insightFrame.Name = "InsightReward"
        insightFrame.Size = UDim2.new(1, -20, 0, 40)
        insightFrame.Position = UDim2.fromOffset(10, 100)
        insightFrame.BackgroundTransparency = 1
        insightFrame.Parent = summaryFrame
        
        local insightLabel = Instance.new("TextLabel")
        insightLabel.Size = UDim2.new(1, 0, 1, 0)
        insightLabel.BackgroundTransparency = 1
        insightLabel.TextColor3 = QUEST_COLORS.Insight
        insightLabel.Font = Enum.Font.GothamBold
        insightLabel.TextSize = 16
        insightLabel.Text = "+" .. rewards.Insight .. " Insight"
        insightLabel.TextXAlignment = Enum.TextXAlignment.Left
        insightLabel.Parent = insightFrame
    end
    
    -- Evolution reward
    if rewards.EvolutionPoints > 0 then
        local evoFrame = Instance.new("Frame")
        evoFrame.Name = "EvolutionReward"
        evoFrame.Size = UDim2.new(1, -20, 0, 40)
        evoFrame.Position = UDim2.fromOffset(10, 140)
        evoFrame.BackgroundTransparency = 1
        evoFrame.Parent = summaryFrame
        
        local evoLabel = Instance.new("TextLabel")
        evoLabel.Size = UDim2.new(1, 0, 1, 0)
        evoLabel.BackgroundTransparency = 1
        evoLabel.TextColor3 = QUEST_COLORS.Evolution
        evoLabel.Font = Enum.Font.GothamBold
        evoLabel.TextSize = 16
        evoLabel.Text = "+" .. rewards.EvolutionPoints .. " Evolution Points"
        evoLabel.TextXAlignment = Enum.TextXAlignment.Left
        evoLabel.Parent = evoFrame
    end
    
    -- Animate summary
    summaryFrame.Position = UDim2.new(0.5, -150, 0.3, -200) -- Start off-screen
    
    local slideIn = TweenService:Create(summaryFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -150, 0.3, 0)
    })
    slideIn:Play()
    
    -- Auto-remove after delay
    task.delay(CELEBRATION_DURATION, function()
        if summaryGui and summaryGui.Parent then
            local slideOut = TweenService:Create(summaryFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, -150, 0.3, -200)
            })
            slideOut:Play()
            
            slideOut.Completed:Connect(function()
                summaryGui:Destroy()
            end)
        end
    end)
end

-- Public API
function QuestCompletionEffects.ShowQuestCompleted(position: Vector3, questTitle: string, rewards: {XP: number, Insight: number, EvolutionPoints: number})
    -- Create completion burst
    createCompletionBurst(position, questTitle)
    
    -- Create individual reward effects
    if rewards.XP > 0 then
        createXPGainEffect(position, rewards.XP)
    end
    
    if rewards.Insight > 0 then
        createInsightGainEffect(position, rewards.Insight)
    end
    
    if rewards.EvolutionPoints > 0 then
        createEvolutionPointEffect(position, rewards.EvolutionPoints)
    end
    
    -- Create celebration fireworks
    task.delay(1, function()
        createCelebrationFireworks(position)
    end)
    
    -- Create reward summary
    createRewardSummary(position, rewards)
end

function QuestCompletionEffects.ClearEffects()
    -- Clear all quest effects
    local player = Players.LocalPlayer
    local character = player.Character
    
    if character then
        local position = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new(0, 0, 0)
        
        -- Remove all effects within range
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:match("QuestCompletion") or 
               obj.Name:match("XPGain") or 
               obj.Name:match("InsightGain") or 
               obj.Name:match("EvolutionGain") or 
               obj.Name:match("Firework") then
                local distance = (obj.Position - position).Magnitude
                if distance < 50 then
                    obj:Destroy()
                end
            end
        end
    end
    
    -- Clear UI summaries
    local playerGui = player:WaitForChild("PlayerGui")
    local summary = playerGui:FindFirstChild("QuestRewardSummary")
    if summary then
        summary:Destroy()
    end
end

-- Initialize
function QuestCompletionEffects.Initialize()
    print("[QuestCompletionEffects] Initializing quest completion visual effects...")
    
    setupSounds()
    
    print("[QuestCompletionEffects] Visual effects initialized")
end

return QuestCompletionEffects
