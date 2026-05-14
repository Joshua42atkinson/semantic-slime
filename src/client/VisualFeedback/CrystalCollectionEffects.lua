--!strict
-- Crystal Collection Visual Effects System
-- Provides beautiful animations and effects for crystal collection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local CrystalCollectionEffects = {}

-- Configuration
local COLLECTION_DURATION = 1.5
local PARTICLE_COUNT = 30
local GLOW_INTENSITY = 8
local TRAIL_PARTICLES = 15

-- Crystal rarity colors and effects
local RARITY_EFFECTS = {
    Common = {
        Color = Color3.fromRGB(180, 180, 180),
        ParticleColor = ColorSequence.new(Color3.fromRGB(200, 200, 200)),
        SoundPitch = 1.0,
        ParticleCount = 20,
        GlowIntensity = 5
    },
    Uncommon = {
        Color = Color3.fromRGB(34, 197, 94),
        ParticleColor = ColorSequence.new(Color3.fromRGB(50, 255, 100)),
        SoundPitch = 1.1,
        ParticleCount = 25,
        GlowIntensity = 6
    },
    Rare = {
        Color = Color3.fromRGB(59, 130, 246),
        ParticleColor = ColorSequence.new(Color3.fromRGB(100, 150, 255)),
        SoundPitch = 1.2,
        ParticleCount = 30,
        GlowIntensity = 7
    },
    Epic = {
        Color = Color3.fromRGB(168, 85, 247),
        ParticleColor = ColorSequence.new(Color3.fromRGB(200, 100, 255)),
        SoundPitch = 1.3,
        ParticleCount = 35,
        GlowIntensity = 8
    },
    Legendary = {
        Color = Color3.fromRGB(234, 179, 8),
        ParticleColor = ColorSequence.new(Color3.fromRGB(255, 200, 50)),
        SoundPitch = 1.4,
        ParticleCount = 40,
        GlowIntensity = 10
    }
}

-- Sound effects
local sounds = {
    collect = Instance.new("Sound"),
    rare = Instance.new("Sound"),
    legendary = Instance.new("Sound"),
    inventory = Instance.new("Sound")
}

-- Initialize sounds
local function setupSounds()
    sounds.collect.SoundId = "rbxassetid://6788484923"
    sounds.collect.Volume = 0.4
    sounds.collect.Pitch = 1.0
    
    sounds.rare.SoundId = "rbxassetid://6788484923"
    sounds.rare.Volume = 0.5
    sounds.rare.Pitch = 1.2
    
    sounds.legendary.SoundId = "rbxassetid://6788484923"
    sounds.legendary.Volume = 0.6
    sounds.legendary.Pitch = 1.4
    
    sounds.inventory.SoundId = "rbxassetid://6788484923"
    sounds.inventory.Volume = 0.3
    sounds.inventory.Pitch = 0.9
end

-- Crystal collection beam effect
local function createCollectionBeam(crystalPosition: Vector3, playerPosition: Vector3, rarity: string)
    local effectConfig = RARITY_EFFECTS[rarity] or RARITY_EFFECTS.Common
    
    -- Create beam path
    local beamParts = {}
    local segments = 10
    
    for i = 0, segments do
        local alpha = i / segments
        local position = crystalPosition:Lerp(playerPosition, alpha)
        
        local beamPart = Instance.new("Part")
        beamPart.Name = "BeamSegment" .. i
        beamPart.Size = Vector3.new(0.5, 0.5, 0.5)
        beamPart.Material = Enum.Material.Neon
        beamPart.Color = effectConfig.Color
        beamPart.Transparency = 0.3
        beamPart.Anchored = true
        beamPart.CanCollide = false
        beamPart.Position = position
        beamPart.Parent = workspace
        
        -- Add glow
        local light = Instance.new("PointLight")
        light.Color = effectConfig.Color
        light.Brightness = effectConfig.GlowIntensity
        light.Range = 5
        light.Parent = beamPart
        
        table.insert(beamParts, beamPart)
        Debris:AddItem(beamPart, COLLECTION_DURATION)
    end
    
    -- Animate beam flow
    task.spawn(function()
        for _, beamPart in ipairs(beamParts) do
            if beamPart and beamPart.Parent then
                local glow = beamPart:FindFirstChild("PointLight")
                if glow then
                    local tween = TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                        Brightness = effectConfig.GlowIntensity * 2
                    })
                    tween:Play()
                    
                    task.delay(0.3, function()
                        if glow and glow.Parent then
                            local fadeTween = TweenService:Create(glow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                                Brightness = 0
                            })
                            fadeTween:Play()
                        end
                    end)
                end
            end
            task.wait(0.05)
        end
    end)
end

-- Crystal explosion effect
local function createCrystalExplosion(position: Vector3, rarity: string)
    local effectConfig = RARITY_EFFECTS[rarity] or RARITY_EFFECTS.Common
    
    -- Create explosion center
    local explosionPart = Instance.new("Part")
    explosionPart.Name = "CrystalExplosion"
    explosionPart.Size = Vector3.new(0.1, 0.1, 0.1)
    explosionPart.Material = Enum.Material.Neon
    explosionPart.Color = effectConfig.Color
    explosionPart.Transparency = 0
    explosionPart.Anchored = true
    explosionPart.CanCollide = false
    explosionPart.Position = position
    explosionPart.Parent = workspace
    
    local explosionLight = Instance.new("PointLight")
    explosionLight.Name = "ExplosionGlow"
    explosionLight.Color = effectConfig.Color
    explosionLight.Brightness = effectConfig.GlowIntensity * 2
    explosionLight.Range = 20
    explosionLight.Parent = explosionPart
    
    -- Create crystal shards
    local shardCount = effectConfig.ParticleCount
    for i = 1, shardCount do
        local shard = Instance.new("Part")
        shard.Name = "CrystalShard" .. i
        shard.Size = Vector3.new(0.3, 0.3, 0.3)
        shard.Material = Enum.Material.Glass
        shard.Color = effectConfig.Color
        shard.Transparency = 0.2
        shard.Anchored = false
        shard.CanCollide = false
        shard.Position = position
        shard.Parent = workspace
        
        -- Add physics
        local velocity = Vector3.new(
            math.random(-8, 8),
            math.random(3, 12),
            math.random(-8, 8)
        )
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Velocity = velocity
        bodyVelocity.Parent = shard
        
        -- Add rotation
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bodyAngularVelocity.AngularVelocity = Vector3.new(
            math.random(-5, 5),
            math.random(-5, 5),
            math.random(-5, 5)
        )
        bodyAngularVelocity.Parent = shard
        
        -- Add sparkle effect
        local attachment = Instance.new("Attachment")
        attachment.Name = "Sparkle"
        attachment.Parent = shard
        
        local particles = Instance.new("ParticleEmitter")
        particles.Color = effectConfig.ParticleColor
        particles.Transparency = NumberSequence.new(0.3, 1)
        particles.Size = NumberSequence.new(0.2, 0)
        particles.Rate = 10
        particles.Lifetime = NumberRange.new(0.3, 0.8)
        particles.Speed = NumberRange.new(1, 3)
        particles.SpreadAngle = Vector2.new(180, 180)
        particles.Parent = attachment
        
        -- Remove velocity after 1 second
        task.delay(1, function()
            if bodyVelocity and bodyVelocity.Parent then
                bodyVelocity:Destroy()
            end
            if bodyAngularVelocity and bodyAngularVelocity.Parent then
                bodyAngularVelocity:Destroy()
            end
        end)
        
        -- Clean up
        Debris:AddItem(shard, COLLECTION_DURATION)
    end
    
    -- Animate explosion
    local explosionTween = TweenService:Create(explosionPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(8, 8, 8),
        Transparency = 1
    })
    
    explosionTween:Play()
    
    -- Clean up
    Debris:AddItem(explosionPart, 0.5)
end

-- Letter trail effect
local function createLetterTrail(letter: string, fromPosition: Vector3, toPosition: Vector3, rarity: string)
    local effectConfig = RARITY_EFFECTS[rarity] or RARITY_EFFECTS.Common
    
    -- Create trail path
    local trailPositions = {}
    local segments = 8
    
    for i = 0, segments do
        local alpha = i / segments
        local position = fromPosition:Lerp(toPosition, alpha)
        table.insert(trailPositions, position)
    end
    
    -- Create trail particles
    for i, position in ipairs(trailPositions) do
        task.delay(i * 0.05, function()
            local trailPart = Instance.new("Part")
            trailPart.Name = "LetterTrail" .. i
            trailPart.Size = Vector3.new(1, 1, 0.5)
            trailPart.Material = Enum.Material.Neon
            trailPart.Color = effectConfig.Color
            trailPart.Transparency = 0.5
            trailPart.Anchored = true
            trailPart.CanCollide = false
            trailPart.Position = position
            trailPart.Parent = workspace
            
            -- Add letter display
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "LetterLabel"
            billboard.Size = UDim2.fromScale(2, 2)
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 0, 0)
            billboard.Parent = trailPart
            
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
            
            -- Add glow
            local light = Instance.new("PointLight")
            light.Color = effectConfig.Color
            light.Brightness = effectConfig.GlowIntensity
            light.Range = 3
            light.Parent = trailPart
            
            -- Animate trail
            local trailTween = TweenService:Create(trailPart, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = position + Vector3.new(0, 2, 0),
                Transparency = 1,
                Size = Vector3.new(0.5, 0.5, 0.5)
            })
            
            trailTween:Play()
            
            -- Add particles
            local attachment = Instance.new("Attachment")
            attachment.Name = "TrailParticles"
            attachment.Parent = trailPart
            
            local particles = Instance.new("ParticleEmitter")
            particles.Color = effectConfig.ParticleColor
            particles.Transparency = NumberSequence.new(0.5, 1)
            particles.Size = NumberSequence.new(0.3, 0)
            particles.Rate = TRAIL_PARTICLES
            particles.Lifetime = NumberRange.new(0.3, 0.8)
            particles.Speed = NumberRange.new(1, 3)
            particles.SpreadAngle = Vector2.new(180, 180)
            particles.Parent = attachment
            
            -- Clean up
            Debris:AddItem(trailPart, 0.8)
        end)
    end
end

-- Inventory update effect
local function createInventoryUpdateEffect(letter: string, rarity: string)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Create floating notification
    local notification = Instance.new("ScreenGui")
    notification.Name = "CrystalNotification"
    notification.ResetOnSpawn = false
    notification.Parent = playerGui
    
    local effectConfig = RARITY_EFFECTS[rarity] or RARITY_EFFECTS.Common
    
    local frame = Instance.new("Frame")
    frame.Name = "NotificationFrame"
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -220, 0, 100)
    frame.BackgroundColor3 = effectConfig.Color
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.2
    frame.Parent = notification
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = effectConfig.Color
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = frame
    
    -- Letter display
    local letterLabel = Instance.new("TextLabel")
    letterLabel.Name = "LetterDisplay"
    letterLabel.Size = UDim2.new(0, 60, 1, 0)
    letterLabel.Position = UDim2.fromOffset(10, 0)
    letterLabel.BackgroundTransparency = 1
    letterLabel.TextColor3 = Color3.new(1, 1, 1)
    letterLabel.Font = Enum.Font.GothamBold
    letterLabel.TextSize = 24
    letterLabel.Text = letter:upper()
    letterLabel.Parent = frame
    
    -- Rarity display
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "RarityDisplay"
    rarityLabel.Size = UDim2.new(1, -80, 1, 0)
    rarityLabel.Position = UDim2.fromOffset(70, 0)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.TextColor3 = Color3.new(1, 1, 1)
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextSize = 16
    rarityLabel.Text = rarity
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = frame
    
    -- Animate notification
    frame.Position = UDim2.new(1, 220, 0, 100) -- Start off-screen
    
    local slideIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -220, 0, 100)
    })
    slideIn:Play()
    
    -- Play inventory sound
    sounds.inventory:Play()
    
    -- Auto-remove after delay
    task.delay(3, function()
        if notification and notification.Parent then
            local slideOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 220, 0, 100)
            })
            slideOut:Play()
            
            slideOut.Completed:Connect(function()
                notification:Destroy()
            end)
        end
    end)
end

-- Public API
function CrystalCollectionEffects.ShowCrystalCollected(crystalPosition: Vector3, playerPosition: Vector3, letter: string, rarity: string)
    -- Create collection beam
    createCollectionBeam(crystalPosition, playerPosition, rarity)
    
    -- Create explosion effect
    createCrystalExplosion(crystalPosition, rarity)
    
    -- Create letter trail
    createLetterTrail(letter, crystalPosition, playerPosition, rarity)
    
    -- Create inventory notification
    createInventoryUpdateEffect(letter, rarity)
    
    -- Play appropriate sound
    local effectConfig = RARITY_EFFECTS[rarity] or RARITY_EFFECTS.Common
    if rarity == "Legendary" then
        sounds.legendary:Play()
    elseif rarity == "Epic" or rarity == "Rare" then
        sounds.rare:Play()
    else
        sounds.collect:Play()
    end
end

function CrystalCollectionEffects.ShowNearbyIndicator(crystalCount: number)
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Remove existing indicators
    local existing = playerGui:FindFirstChild("NearbyIndicator")
    if existing then
        existing:Destroy()
    end
    
    if crystalCount == 0 then return end
    
    -- Create indicator
    local indicator = Instance.new("ScreenGui")
    indicator.Name = "NearbyIndicator"
    indicator.ResetOnSpawn = false
    indicator.Parent = playerGui
    
    local frame = Instance.new("Frame")
    frame.Name = "IndicatorFrame"
    frame.Size = UDim2.new(0, 150, 0, 40)
    frame.Position = UDim2.new(0.5, -75, 0.9, -50)
    frame.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = indicator
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "🔮 " .. crystalCount .. " nearby"
    label.Parent = frame
    
    -- Pulse animation
    local pulse = TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1), {
        BackgroundTransparency = 0.1
    })
    pulse:Play()
end

function CrystalCollectionEffects.ClearEffects()
    -- Clear all crystal effects
    local player = Players.LocalPlayer
    local character = player.Character
    
    if character then
        local position = character.PrimaryPart and character.PrimaryPart.Position or Vector3.new(0, 0, 0)
        
        -- Remove all effects within range
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj.Name:match("BeamSegment") or 
               obj.Name:match("CrystalExplosion") or 
               obj.Name:match("CrystalShard") or 
               obj.Name:match("LetterTrail") then
                local distance = (obj.Position - position).Magnitude
                if distance < 30 then
                    obj:Destroy()
                end
            end
        end
    end
    
    -- Clear UI indicators
    local playerGui = player:WaitForChild("PlayerGui")
    local indicator = playerGui:FindFirstChild("NearbyIndicator")
    if indicator then
        indicator:Destroy()
    end
    
    local notification = playerGui:FindFirstChild("CrystalNotification")
    if notification then
        notification:Destroy()
    end
end

-- Initialize
function CrystalCollectionEffects.Initialize()
    print("[CrystalCollectionEffects] Initializing crystal collection visual effects...")
    
    setupSounds()
    
    print("[CrystalCollectionEffects] Visual effects initialized")
end

return CrystalCollectionEffects
