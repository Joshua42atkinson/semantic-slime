# Pygmalion - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Moderate | **Time Estimate:** 45-60 minutes | **Cost:** ~300-500 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Pygmalion_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Scaling
```
Scale up for massive golem:
- Head: 1.5x
- Torso: 1.5x width, 1.5x height
- Arms: 1.5x
- Legs: 1.5x
- Overall: Bulk and solid
```

### Step 3: Frost-Clay Material
```
Apply to all body parts:
- Material: Concrete or Stone
- Color: Grey (RGB: 128, 128, 128)
- ADD: Icy blue accents (frost)

Surface Ice Layer:
- Use light blue parts overlaid on body
- Or use ParticleEmitter with snow/ice
```

---

## Part 2: The Golem Head

### Head Construction
```
CREATE > Part > Block
├── Name: "HeadBase"
├── Size: 1.5, 1.5, 1.5
├── Position: Head
└── Color: Grey (stone/clay)

CREATE > Part > Sphere (Eyes)
├── Name: "LeftEye"
├── Size: 0.4, 0.4, 0.3
├── Position: Left eye socket
├── Material: Neon
└── Color: Glowing Blue (RGB: 0, 191, 255)

CREATE > Part > Sphere (Right Eye)
├── Name: "RightEye"
├── Size: 0.4, 0.4, 0.3
├── Position: Right eye socket
├── Material: Neon
└── Color: Glowing Blue
```

---

## Part 3: Clothing & Accessories

### The Paint-Splattered Apron
```
CREATE > Part > Block
├── Name: "Apron"
├── Size: 1.8, 2, 0.2
├── Position: Torso front
├── Color: Brown leather (RGB: 139, 69, 19)
└── Note: Gigantic, covers most of torso

ADD: Paint splatters (small colored parts)
- Red, blue, yellow, green dots
```

### Tools (Strapped to Back)

#### Mallet
```
CREATE > Part > Cylinder (Handle)
├── Name: "MalletHandle"
├── Size: 0.2, 2, 0.2
├── Position: Diagonal, on back
└── Color: Brown

CREATE > Part > Block (Head)
├── Name: "MalletHead"
├── Size: 1, 0.6, 0.6
├── Position: Top of handle
└── Color: Dark Wood
```

#### Chisel
```
CREATE > Part > Cylinder
├── Name: "ChiselHandle"
├── Size: 0.1, 1.5, 0.1
├── Position: On back
└── Color: Brown

CREATE > Part > Cone
├── Name: "ChiselTip"
├── Size: 0.2, 0.4, 0.2
├── Position: Tip of handle
└── Color: Silver/Grey
```

### The Hovering Snowflake
```
CREATE > Part > Sphere
├── Name: "Snowflake"
├── Size: 0.8, 0.8, 0.2
├── Position: Above head
├── Material: Neon
└── Color: Light Blue

ADD: ParticleEmitter
├── Name: "SnowParticles"
├── Color: White
├── Rate: 30
├── Lifetime: 2-3 seconds
└── Behavior: Float downward
```

---

## Part 4: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Stand massive and still
2. 0.5s: Step back slightly
3. 1.0s: Hold up thumb and index to "frame" player
4. 1.5s: Stroke rocky chin thoughtfully
5. 2.0s: Loop

Expression: Contemplative, artistic
```

#### Walk Animation
```
Keyframes:
1. Slow, deliberate steps
2. Heavy body movement
3. Arms slightly swinging
4. Overall: Very heavy, deliberate

Timing: Slow (0.4 speed)
```

#### Sculpt Animation
```
Keyframes:
1. Hands move as if shaping clay
2. Mallet raised
3. Chisel positioned
4. Strike motion

Trigger: During quest interactions
```

---

## Part 5: Script Implementation

### Pygmalion NPC Script
```lua
-- Pygmalion NPC Controller
-- Place in NPC's Humanoid

local Pygmalion = {}
Pygmalion.__index = Pygmalion

function Pygmalion.new(npc)
    local self = setmetatable({}, Pygmalion)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    
    -- Data from LoreDB
    self.PreferredElement = {"Earth", "Water/Ice"}
    self.PreferredClass = {"Tank", "Builder"}
    self.QuestType = "Crafting"
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Sculpt = self:LoadAnimation("rbxassetid://YOUR_SCULPT_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartSnowflake()
    
    return self
end

function Pygmalion:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Pygmalion:StartDialogueSystem()
    local function onTouch(otherPart)
        local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
        if player then
            self:TriggerDialogue(player)
        end
    end
    
    local detector = Instance.new("Part")
    detector.Name = "DialogueDetector"
    detector.Size = Vector3.new(12, 12, 12)
    detector.Anchored = false
    detector.CanCollide = false
    detector.Transparency = 1
    detector.Parent = self.NPC
    detector.Touched:Connect(onTouch)
end

function Pygmalion:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Ah, the canvas resets! The morning frost brings fresh, uncarved letters to 8 Winter Street. Gather the raw clay, my friend!",
            "The new day sparkles like untouched snow! Perfect for gathering creative materials!",
            "Dawn at 8 Winter Street is magical - the snow never melts here!"
        },
        Day = {
            "The Slime Synthesizer hums a beautiful, creative tune! Remember, there are no mistakes in word-crafting, only happy little grammatical accidents!",
            "Words are my paint! Letters are my clay! The possibilities are ENDLESS!",
            "Every word you forge today could be part of my next masterpiece!"
        },
        Dusk = {
            "The golden hour! The lighting is perfect, but my sculpture is missing its final piece! Quick, before we lose the aesthetic shadows!",
            "Weaver! I need your creative vision! The piece simply isn't complete without the right linguistic material!",
            "The evening brings clarity. Help me find the perfect word to finish this MAGNIFICENT failure... I mean, masterpiece!"
        },
        Night = {
            "The Static is here! They have no appreciation for form or structure! Defend the gallery, Weaver!",
            "They dare enter my studio?! The nerve of those glitchy, poorly-rendered monstrosities!",
            "Quick, protect the sculptures! The Static wants to erase all beauty from the world!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Pygmalion says: " .. chosenDialogue)
end

function Pygmalion:StartSnowflake()
    -- Particle effect for hovering snowflake
end

function Pygmalion:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Pygmalion
```

### Quest Giver Script
```lua
-- Pygmalion's Quest Data
local PygmalionQuests = {
    {
        QuestID = "melting_masterpiece_01",
        Title = "The Melting Masterpiece",
        Description: "Pyg's frost sculpture is melting!",
        RequiredWords = {"SOLIDIFY"}, -- Earth/Tank
        Reward = {Type = "Currency", Amount = 55},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "Weaver! Disaster strikes! I am sculpting a [Animal] but it's melting!",
            Complete = "Yes! The foundation holds! It is a triumph of modern art!"
        }
    },
    {
        QuestID = "missing_hue_01",
        Title = "The Missing Hue",
        Description: "Pyg needs vibrant colors for his painting!",
        RequiredWords = {"DAZZLING"}, -- High Charisma
        Reward = {Type = "Item", ID = "ArtSupply"},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "My painting of the [Location] lacks emotional depth!",
            Complete = "Magnificent! The composition is finally balanced!"
        }
    }
}
```

---

## Part 6: Testing Checklist

- [ ] NPC spawns at 8 Winter Street (border of districts)
- [ ] Frost-clay body visible (grey with icy blue)
- [ ] Glowing blue crystal eyes
- [ ] Paint-splattered apron
- [ ] Mallet and chisel on back
- [ ] Snowflake hovering over head with particles
- [ ] Snow falling around NPC
- [ ] Idle animation involves "framing" player
- [ ] Walk is slow and heavy
- [ ] Dialogue triggers with artistic language

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
