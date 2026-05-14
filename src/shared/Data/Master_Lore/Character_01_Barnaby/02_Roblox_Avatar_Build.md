# Barnaby - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Extremely Easy | **Time Estimate:** 30-45 minutes | **Cost:** ~200-400 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Barnaby_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Scaling
```
Important: Scale the entire model, not individual parts!

- Head: Scale 2.5x (make it HUGE)
- Torso: Scale 2x width, 2.5x height
- Arms: Scale 2x all dimensions  
- Legs: Scale 2x all dimensions
- Overall: Apply at once to maintain proportions
```

### Step 3: The Eye (Signature Feature)
```
CREATE > Part > Sphere
├── Name: "CyclopsEye"
├── Position: Head.Center (slightly forward)
├── Size: 2, 2, 1.5 (oval shape)
├── Material: Neon
├── Color: White (255, 255, 255)
└── BrickColor: White

CREATE > Part > Sphere (child of CyclopsEye)
├── Name: "Pupil"
├── Position: Forward slightly from eye center
├── Size: 0.8, 0.8, 0.3
├── Material: SmoothPlastic
├── Color: Black
└── BrickColor: Black

OPTIONAL: Add SurfaceLight inside eye for subtle glow
```

---

## Part 2: Clothing & Accessories

### Clothing IDs (Catalog)
| Item | Recommended Style | Notes |
|------|------------------|-------|
| Pants | Blue Overalls | Use Shirt ID from catalog, tint blue |
| Shirt | Plain light color | Keeps focus on eye |
| Hat | Propeller Beanie | Bright colors - red/yellow/green |

### DIY Overalls (No Catalog Needed)
```
Create Pants manually:
1. Create Shirt and Pants in clothing creator
2. Or use simple Part-based overalls:

CREATE > Part > Block
├── Name: "OverallLeft"
├── Size: 0.5, 2, 0.2
├── Position: Left hip area
└── Color: Blue (RGB: 0, 100, 200)

CREATE > Part > Block  
├── Name: "OverallRight"
├── Size: 0.5, 2, 0.2
├── Position: Right hip area
└── Color: Blue (RGB: 0, 100, 200)

CREATE > Part > Block
├── Name: "OverallTop"
├── Size: 2, 0.5, 0.2
├── Position: Waist
└── Color: Blue (RGB: 0, 100, 200)
```

### Propeller Beanie
```
CREATE > Part > Sphere (half)
├── Name: "BeanieTop"
├── Size: 1.5, 0.5, 1.5
├── Position: Top of head
└── Color: Red (RGB: 255, 50, 50)

CREATE > Part > Block
├── Name: "Propeller"
├── Size: 2, 0.1, 0.1
├── Position: Top of beanie
└── Color: Yellow

Script: Rotate propeller continuously
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Standing tall, eye looking around
2. 0.5s: Eye blinks slowly
3. 1.0s: Look to side with wonder
4. 1.5s: Return to center
5. 2.0s: Loop

Expression: Big, innocent, curious
```

#### Walk Animation
```
Keyframes:
1. Arms swinging opposite to legs
2. Slight body sway
3. One foot slightly lifted
4. Overall: Clumsy but eager

Timing: Slower than normal (0.6 speed)
```

#### Run Animation
```
Keyframes:
1. Arms pumping
2. Big steps
3. Slight bounce in body

Timing: Lumbering (0.5 speed)
```

---

## Part 4: Script Implementation

### Barnaby NPC Script
```lua
-- Barnaby NPC Controller
-- Place in NPC's Humanoid

local Barnaby = {}
Barnaby.__index = Barnaby

function Barnaby.new(npc)
    local self = setmetatable({}, Barnaby)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Run = self:LoadAnimation("rbxassetid://YOUR_RUN_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartWanderBehavior()
    
    return self
end

function Barnaby:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Barnaby:StartDialogueSystem()
    -- Proximity dialogue trigger
    local function onTouch(otherPart)
        local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
        if player then
            self:TriggerDialogue(player)
        end
    end
    
    local detector = Instance.new("Part")
    detector.Name = "DialogueDetector"
    detector.Size = Vector3.new(10, 10, 10)
    detector.Anchored = false
    detector.CanCollide = false
    detector.Transparency = 1
    detector.Parent = self.NPC
    detector.Touched:Connect(onTouch)
end

function Barnaby:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Look at all the shiny letters! I tried to eat an 'O' once because it looked like a donut. It tasted like math.",
            "Good morning friend! Did you sleep good? I don't really sleep 'cause I think with my eye and eyes are always open!",
            "The sunrise is SO PRETTY! Almost as pretty as... oh wait, nothing is as pretty as YOU, best friend!"
        },
        Day = {
            "You're making words? Wow! Can you make a word for when you really want a hug but your arms are too long?",
            "I tried to help build a house once but I used flowers instead of bricks. It was VERY pretty but also VERY leaky...",
            "Words are like people - they all have jobs! Some words are strong like builders and some are soft like pillows!"
        },
        Dusk = {
            "Friend! I have a tiny problem that is actually a giant disaster! Please help!",
            "I was trying to help but I think I made it worse? Don't be mad! Please? I didn't mean to!",
            "The sky is getting dark and that makes my tummy feel funny... can you help me find a super bright word?"
        },
        Night = {
            "I don't like the dark! The shadows look like mean broccoli! Be careful out there!",
            "Friend! Please don't leave me! The dark has too many corners and corners are scary!",
            "I know I'm big but big things can be scared too! Will you protect me? I'll protect you too! Maybe..."
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    -- Show dialogue (use your game's dialogue system)
    print("Barnaby says: " .. chosenDialogue)
end

function Barnaby:StartWanderBehavior()
    -- Gentle wandering near flower patches
    task.spawn(function()
        while true do
            task.wait(math.random(5, 15))
            -- Wander to random nearby position
            -- Stay within Eros District bounds
        end
    end)
end

function Barnaby:SetPhase(phaseName)
    self.CurrentPhase = phaseName
    -- Adjust behavior based on phase
    if phaseName == "Night" then
        -- Move to hiding spot
    end
end

return Barnaby
```

### Propeller Beanie Script
```lua
-- Propeller Spin Script
-- Place inside Propeller part

local propeller = script.Parent
local TweenService = game:GetService("TweenService")

while true do
    -- Rotate 360 degrees
    local rotation = TweenService:Create(
        propeller,
        TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Clockwise),
        {CFrame = propeller.CFrame * CFrame.Angles(0, math.rad(360), 0)}
    )
    rotation:Play()
    rotation.Completed:Wait()
end
```

---

## Part 5: Quest System Integration

### Barnaby's Quest Giver
```lua
-- Quest Data Structure
local BarnabyQuests = {
    {
        QuestID = "clumsy_giant_01",
        Title = "The Clumsy Giant",
        Description = "Barnaby accidentally caused a mishap and needs your help!",
        RequiredWords = {"SOOTHING"}, -- Water/Support
        Reward = {Type = "Currency", Amount = 50},
        Dialogue = {
            Start = "Oh no! I was trying to pet the [Noun] but I accidentally stepped on it!",
            Complete = "THANK YOU! You're the best friend ever! *happy tears*"
        }
    },
    {
        QuestID = "pure_heart_01",
        Title = "A Surprise for the Mayor",
        Description = "Barnaby wants to throw a party and needs decoration words!",
        RequiredWords = {"RADIANT"}, -- Light Element
        Reward = {Type = "Item", ID = "FlowerCrown"},
        Dialogue = {
            Start = "I want to throw a surprise party! I need a [Noun] that's incredibly [Adjective]!",
            Complete = "WOW! It's so pretty! The Mayor will LOVE it!"
        }
    }
}
```

---

## Part 6: Testing Checklist

- [ ] NPC spawns at correct location (Eros District, near flowers)
- [ ] Eye is visible and centered on face
- [ ] Propeller beanie spins continuously
- [ ] Idle animation plays on spawn
- [ ] Walking animation triggers when NPC moves
- [ ] Dialogue triggers when player gets close (10 stud radius)
- [ ] Different dialogue appears for each time phase
- [ ] NPC stays within Eros District bounds
- [ ] Night phase makes NPC seek shelter/hiding spot
- [ ] Quest system properly initializes at Dusk

---

## Part 7: Optimization Tips

1. **Use a Character Dummy** - Build once, duplicate for all 12 characters
2. **Shared Animation Library** - Many animations can be reused across NPCs
3. **Dialogue Module** - Externalize all dialogue to a data module
4. **Quest Data Module** - Store all quests in a separate module script
5. **Consider Using** - Nobloxx or other NPC plugins for faster setup

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
