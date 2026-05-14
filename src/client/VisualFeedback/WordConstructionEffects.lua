--!strict
-- Word Construction Visual Effects System
-- Provides beautiful visual feedback for word construction

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local WordConstructionEffects = {}

-- Configuration
local EFFECT_DURATION = 2
local PARTICLE_COUNT = 20
local GLOW_INTENSITY = 5
local SUCCESS_COLOR = Color3.fromRGB(100, 255, 100)
local ERROR_COLOR = Color3.fromRGB(255, 100, 100)
local CONSTRUCTING_COLOR = Color3.fromRGB(100, 150, 255)

-- Sound effects
local sounds = {
    letterAdd = Instance.new("Sound"),
    wordComplete = Instance.new("Sound"),
    wordError = Instance.new("Sound"),
    success = Instance.new("Sound")
}

-- Initialize sounds
local function setupSounds()
    sounds.letterAdd.SoundId = "rbxassetid://6788484923"
    sounds.letterAdd.Volume = 0.3
    sounds.letterAdd.Pitch = 1.1
    
    sounds.wordComplete.SoundId = "rbxassetid://6788484923"
    sounds.wordComplete.Volume = 0.5
    sounds.wordComplete.Pitch = 1.3
    
    sounds.wordError.SoundId = "rbxassetid://6788484923"
    sounds.wordError.Volume = 0.4
    sounds.wordError.Pitch = 0.8
    
    sounds.success.SoundId = "rbxassetid://6788484923"
    sounds.success.Volume = 0.6
    sounds.success.Pitch = 1.5
end

-- Letter addition effect
local function createLetterAddEffect(letter: string, position: Vector3)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    -- Create floating letter
    local letterPart = Instance.new("Part")
    letterPart.Name = "FloatingLetter"
    letterPart.Size = Vector3.new(2, 2, 0.5)
    letterPart.Material = Enum.Material.Neon
    letterPart.Color = CONSTRUCTING_COLOR
    letterPart.Transparency = 0.3
    letterPart.Anchored = true
    letterPart.CanCollide = false
    letterPart.Position = position + Vector3.new(0, 3, 0)
    letterPart.Parent = workspace
    
    -- Add letter text
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "LetterLabel"
    billboard.Size = UDim2.fromScale(3, 3)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 0, 0)
    billboard.Parent = letterPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = letter:upper()
    label.Parent = billboard
    
    -- Add glow effect
    local light = Instance.new("PointLight")
    light.Name = "Glow"
    light.Color = CONSTRUCTING_COLOR
    light.Brightness = GLOW_INTENSITY
    light.Range = 10
    light.Parent = letterPart
    
    -- Add particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "Particles"
    attachment.Position = Vector3.new(0, 0, 0)
    attachment.Parent = letterPart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "Sparkles"
    particles.Color = ColorSequence.new(CONSTRUCTING_COLOR)
    particles.Transparency = NumberSequence.new(0.5, 1)
    particles.Size = NumberSequence.new(0.5, 0)
    particles.Rate = PARTICLE_COUNT
    particles.Lifetime = NumberRange.new(0.5, 1.5)
    particles.Speed = NumberRange.new(1, 3)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate floating up and fading
    local floatTween = TweenService:Create(letterPart, TweenInfo.new(EFFECT_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = position + Vector3.new(0, 8, 0),
        Transparency = 1,
        Size = Vector3.new(1, 1, 0.5)
    })
    
    floatTween:Play()
    
    -- Play sound
    sounds.letterAdd:Play()
    
    -- Clean up
    Debris:AddItem(letterPart, EFFECT_DURATION)
end

-- Word completion effect
local function createWordCompleteEffect(word: string, position: Vector3, success: boolean)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    local color = success and SUCCESS_COLOR or ERROR_COLOR
    
    -- Create word explosion
    for i = 1, #word do
        local letterPart = Instance.new("Part")
        letterPart.Name = "ExplodingLetter"
        letterPart.Size = Vector3.new(1.5, 1.5, 0.5)
        letterPart.Material = Enum.Material.Neon
        letterPart.Color = color
        letterPart.Transparency = 0.3
        letterPart.Anchored = false
        letterPart.CanCollide = false
        letterPart.Position = position + Vector3.new(math.random(-2, 2), 0, math.random(-2, 2))
        letterPart.Parent = workspace
        
        -- Add letter text
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "LetterLabel"
        billboard.Size = UDim2.fromScale(2, 2)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 0, 0)
        billboard.Parent = letterPart
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.fromScale(1, 1)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Text = word:sub(i, i):upper()
        label.Parent = billboard
        
        -- Add physics
        local velocity = Vector3.new(
            math.random(-5, 5),
            math.random(5, 10),
            math.random(-5, 5)
        )
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = velocity
        bodyVelocity.Parent = letterPart
        
        -- Add glow
        local light = Instance.new("PointLight")
        light.Name = "Glow"
        light.Color = color
        light.Brightness = GLOW_INTENSITY
        light.Range = 8
        light.Parent = letterPart
        
        -- Add particles
        local attachment = Instance.new("Attachment")
        attachment.Name = "Particles"
        attachment.Position = Vector3.new(0, 0, 0)
        attachment.Parent = letterPart
        
        local particles = Instance.new("ParticleEmitter")
        particles.Name = "Sparkles"
        particles.Color = ColorSequence.new(color)
        particles.Transparency = NumberSequence.new(0.3, 1)
        particles.Size = NumberSequence.new(0.3, 0)
        particles.Rate = PARTICLE_COUNT / 2
        particles.Lifetime = NumberRange.new(0.3, 1)
        particles.Speed = NumberRange.new(2, 5)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.Parent = attachment
        
        -- Remove velocity after 1 second
        task.delay(1, function()
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end
        end)
        
        -- Clean up
        Debris:AddItem(letterPart, EFFECT_DURATION)
    end
    
    -- Create central burst effect
    local burstPart = Instance.new("Part")
    burstPart.Name = "WordBurst"
    burstPart.Size = Vector3.new(0.1, 0.1, 0.1)
    burstPart.Material = Enum.Material.Neon
    burstPart.Color = color
    burstPart.Transparency = 0
    burstPart.Anchored = true
    burstPart.CanCollide = false
    burstPart.Position = position
    burstPart.Parent = workspace
    
    local burstLight = Instance.new("PointLight")
    burstLight.Name = "BurstGlow"
    burstLight.Color = color
    burstLight.Brightness = GLOW_INTENSITY * 2
    burstLight.Range = 20
    burstLight.Parent = burstPart
    
    -- Animate burst
    local burstTween = TweenService:Create(burstPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(15, 15, 15),
        Transparency = 1
    })
    
    burstTween:Play()
    
    -- Play appropriate sound
    if success then
        sounds.wordComplete:Play()
        task.delay(0.5, function()
            sounds.success:Play()
        end)
    else
        sounds.wordError:Play()
    end
    
    -- Clean up
    Debris:AddItem(burstPart, 0.5)
end

-- Progress indicator effect
local function createProgressEffect(currentWord: string, position: Vector3)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    -- Create progress ring
    local progressPart = Instance.new("Part")
    progressPart.Name = "ProgressRing"
    progressPart.Size = Vector3.new(4, 4, 0.5)
    progressPart.Material = Enum.Material.Neon
    progressPart.Color = CONSTRUCTING_COLOR
    progressPart.Transparency = 0.5
    progressPart.Anchored = true
    progressPart.CanCollide = false
    progressPart.Position = position + Vector3.new(0, 2, 0)
    progressPart.Parent = workspace
    
    -- Create ring effect using multiple parts
    local ringParts = {}
    for i = 1, 8 do
        local angle = (i / 8) * math.pi * 2
        local ringPiece = Instance.new("Part")
        ringPiece.Name = "RingPiece" .. i
        ringPiece.Size = Vector3.new(0.5, 0.5, 0.5)
        ringPiece.Material = Enum.Material.Neon
        ringPiece.Color = CONSTRUCTING_COLOR
        ringPiece.Transparency = 0.3
        ringPiece.Anchored = true
        ringPiece.CanCollide = false
        ringPiece.Position = position + Vector3.new(
            math.cos(angle) * 2,
            2,
            math.sin(angle) * 2
        )
        ringPiece.Parent = workspace
        
        table.insert(ringParts, ringPiece)
        
        -- Add glow
        local light = Instance.new("PointLight")
        light.Color = CONSTRUCTING_COLOR
        light.Brightness = 2
        light.Range = 5
        light.Parent = ringPiece
        
        Debris:AddItem(ringPiece, EFFECT_DURATION)
    end
    
    -- Animate ring rotation
    task.spawn(function()
        local rotation = 0
        while progressPart and progressPart.Parent do
            rotation += 0.1
            
            for i, ringPiece in ipairs(ringParts) do
                if ringPiece and ringPiece.Parent then
                    local angle = (i / 8) * math.pi * 2 + rotation
                    ringPiece.Position = position + Vector3.new(
                        math.cos(angle) * 2,
                        2,
                        math.sin(angle) * 2
                    )
                end
            end
            
            task.wait(0.05)
        end
    end)
    
    -- Add word display
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "WordDisplay"
    billboard.Size = UDim2.fromScale(4, 2)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = progressPart
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = currentWord:upper()
    label.Parent = billboard
    
    -- Clean up
    Debris:AddItem(progressPart, EFFECT_DURATION)
end

-- Slime creation celebration
local function createSlimeCreationEffect(slimeName: string, position: Vector3)
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end
    
    -- Create celebration beam
    local beamPart = Instance.new("Part")
    beamPart.Name = "CelebrationBeam"
    beamPart.Size = Vector3.new(0.5, 10, 0.5)
    beamPart.Material = Enum.Material.Neon
    beamPart.Color = SUCCESS_COLOR
    beamPart.Transparency = 0.3
    beamPart.Anchored = true
    beamPart.CanCollide = false
    beamPart.Position = position + Vector3.new(0, 5, 0)
    beamPart.Parent = workspace
    
    local beamLight = Instance.new("PointLight")
    beamLight.Name = "BeamGlow"
    beamLight.Color = SUCCESS_COLOR
    beamLight.Brightness = GLOW_INTENSITY * 3
    beamLight.Range = 30
    beamLight.Parent = beamPart
    
    -- Create slime name display
    local nameBillboard = Instance.new("BillboardGui")
    nameBillboard.Name = "SlimeName"
    nameBillboard.Size = UDim2.fromScale(6, 3)
    nameBillboard.AlwaysOnTop = true
    nameBillboard.StudsOffset = Vector3.new(0, 8, 0)
    nameBillboard.Parent = beamPart
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.fromScale(1, 1)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.Text = "✨ " .. slimeName:upper() .. " CREATED! ✨"
    nameLabel.Parent = nameBillboard
    
    -- Create celebration particles
    local attachment = Instance.new("Attachment")
    attachment.Name = "CelebrationParticles"
    attachment.Position = Vector3.new(0, 0, 0)
    attachment.Parent = beamPart
    
    local particles = Instance.new("ParticleEmitter")
    particles.Name = "CelebrationSparkles"
    particles.Color = ColorSequence.new(SUCCESS_COLOR)
    particles.Transparency = NumberSequence.new(0.2, 1)
    particles.Size = NumberSequence.new(1, 0)
    particles.Rate = PARTICLE_COUNT * 2
    particles.Lifetime = NumberRange.new(1, 2)
    particles.Speed = NumberRange.new(3, 8)
    particles.SpreadAngle = Vector2.new(180, 180)
    particles.Parent = attachment
    
    -- Animate beam
    local beamTween = TweenService:Create(beamPart, TweenInfo.new(EFFECT_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1,
        Size = Vector3.new(0.5, 20, 0.5)
    })
    
    beamTween:Play()
    
    -- Play success sound
    sounds.success:Play()
    
    -- Clean up
    Debris:AddItem(beamPart, EFFECT_DURATION)
end

-- Public API
function WordConstructionEffects.ShowLetterAdded(letter: string, position: Vector3)
    createLetterAddEffect(letter, position)
end

function WordConstructionEffects.ShowWordCompleted(word: string, position: Vector3, success: boolean)
    createWordCompleteEffect(word, position, success)
end

function WordConstructionEffects.ShowProgress(currentWord: string, position: Vector3)
    createProgressEffect(currentWord, position)
end

function WordConstructionEffects.ShowSlimeCreated(slimeName: string, position: Vector3)
    createSlimeCreationEffect(slimeName, position)
end

function WordConstructionEffects.ClearEffects()
    -- Clear all visual effects
    local player = Players.LocalPlayer
    local character = player.Character
    
    if character then
        local position = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new(0, 0, 0)
        
        -- Remove all effects within range
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:match("FloatingLetter") or 
               obj.Name:match("ExplodingLetter") or 
               obj.Name:match("WordBurst") or 
               obj.Name:match("ProgressRing") or 
               obj.Name:match("CelebrationBeam") then
                local distance = (obj.Position - position).Magnitude
                if distance < 20 then
                    obj:Destroy()
                end
            end
        end
    end
end

-- Initialize
function WordConstructionEffects.Initialize()
    print("[WordConstructionEffects] Initializing word construction visual effects...")
    
    setupSounds()
    
    print("[WordConstructionEffects] Visual effects initialized")
end

return WordConstructionEffects
