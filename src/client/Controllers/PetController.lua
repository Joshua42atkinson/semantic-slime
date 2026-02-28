--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local PetController = Knit.CreateController {
    Name = "PetController",
}

local player = Players.LocalPlayer
local character = player.Character

-- Config
local PET_FLOAT_OFFSET = Vector3.new(3, 4, 3) -- Relative to HRP
local IDLE_DIALOGUE_INTERVAL = 30 -- Seconds between idle dialogues

-- Idle dialogues based on element
local IDLE_DIALOGUES = {
    Fire = { "I feel the heat!", "Let's burn through this!", "Warm and cozy~", "Fire slimes are the best!", "*happy sizzle*" },
    Water = { "Splish splash!", "Flow like water...", "Nice day for a swim!", "Water you up to?", "*glub glub*" },
    Earth = { "Solid as a rock!", "Rooted and ready!", "Earth never sleeps~", "Stone cold awesome!", "*rumble*" },
    Air = { "Feeling breezy!", "Let's fly high!", "Wind in my hair!", "Up in the clouds!", "*whoosh*" },
    Shadow = { "In the shadows...", "Dark and mysterious~", "Silent but deadly!", "Embrace the void!", "*whisper*" },
    Light = { "Shine bright!", "Let's illuminate this!", "Radiant energy!", "Light overcomes dark!", "*sparkle*" },
    Normal = { "Hey there!", "Ready for adventure!", "What's next?", "Life is good~", "*bounce bounce*" },
}

function PetController:KnitStart()
    print("[PetController] Started.")
    
    player.CharacterAdded:Connect(function(char)
        character = char
        -- Check for existing pet or companion
        self:CheckForPet()
        self:CheckForCompanion()
    end)
    
    -- Listen for new pets spawning
    workspace.ChildAdded:Connect(function(child)
        if child.Name == player.Name .. "_Pet" then
            self:SetupPetPhysics(child)
        elseif child.Name == player.Name .. "_Companion" then
            self:SetupCompanionPhysics(child)
        end
    end)
    
    -- Check for existing pets/companions
    self:CheckForPet()
    self:CheckForCompanion()
    
    -- Start physics loops and systems
    self:StartIdleAnimation()
    self:StartIdleDialogue()
end

function PetController:CheckForPet()
    local pet = workspace:FindFirstChild(player.Name .. "_Pet")
    if pet then
        self:SetupPetPhysics(pet)
    end
end

function PetController:CheckForCompanion()
    local companion = workspace:FindFirstChild(player.Name .. "_Companion")
    if companion then
        self:SetupCompanionPhysics(companion)
    end
end

function PetController:SetupPetPhysics(pet: BasePart)
    if not character then return end
    
    -- Clean up physics constraints
    for _, child in ipairs(pet:GetChildren()) do
        if child:IsA("AlignPosition") or child:IsA("AlignOrientation") or child:IsA("Attachment") then
            child:Destroy()
        end
    end
    
    pet.Anchored = true -- Take control from physics engine
    self.currentPet = pet
    print("[PetController] Set up CFrame lerping for " .. pet.Name)
end

function PetController:SetupCompanionPhysics(companion: BasePart)
    if not character then return end
    
    -- Clean up physics constraints
    for _, child in ipairs(companion:GetChildren()) do
        if child:IsA("AlignPosition") or child:IsA("AlignOrientation") or child:IsA("Attachment") then
            child:Destroy()
        end
    end
    
    companion.Anchored = true -- Take control from physics engine
    self.currentCompanion = companion
    
    print("[PetController] Set up CFrame lerping for " .. companion.Name)
end

function PetController:StartIdleAnimation()
    -- Smooth Follow & Idle bobbing animation sequence
    RunService.RenderStepped:Connect(function(dt)
        local targetPet = self.currentCompanion or self.currentPet
        if not targetPet or not targetPet.Parent then return end
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local hrp = character.HumanoidRootPart
        
        -- Calculate base target position behind and slightly right of player
        local xOffset = 3.5
        local yOffset = 2.5
        local zOffset = 3.5
        
        -- Sine wave for idle floating (2 cycles per sec, 0.5 stud amplitude)
        local bobbing = math.sin(tick() * 4) * 0.5
        
        local targetCFrame = hrp.CFrame * CFrame.new(xOffset, yOffset + bobbing, zOffset)
        
        -- Make the pet constantly look forward with the player
        local lookCFrame = CFrame.lookAt(
            targetCFrame.Position, 
            targetCFrame.Position + hrp.CFrame.LookVector * 10
        )
        
        -- Smoothly interpolate current CFrame to target CFrame
        -- Lerp factor based on deltaTime for frame-rate independence
        local lerpFactor = 1 - math.exp(-6 * dt)
        targetPet.CFrame = targetPet.CFrame:Lerp(lookCFrame, lerpFactor)
    end)
end

function PetController:StartIdleDialogue()
    -- Show random dialogue from companion periodically
    task.spawn(function()
        while true do
            task.wait(IDLE_DIALOGUE_INTERVAL)
            
            local companion = self.currentCompanion
            if companion and companion.Parent then
                local element = companion:GetAttribute("SlimeElement") or "Normal"
                local dialogues = IDLE_DIALOGUES[element] or IDLE_DIALOGUES.Normal
                local dialogue = dialogues[math.random(1, #dialogues)]
                
                self:ShowDialogueBubble(companion, dialogue)
            end
        end
    end)
end

function PetController:ShowDialogueBubble(companion: BasePart, text: string)
    -- Create a billboard with the dialogue
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DialogueBubble"
    billboard.Size = UDim2.fromOffset(140, 45)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.Adornee = companion
    billboard.AlwaysOnTop = true
    billboard.Parent = companion
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(1, 1)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.2, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 150, 200)
    stroke.Thickness = 1.5
    stroke.Parent = frame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 14
    textLabel.TextWrapped = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = frame
    
    -- Auto destroy after 4 seconds
    task.delay(4, function()
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end)
end

return PetController
