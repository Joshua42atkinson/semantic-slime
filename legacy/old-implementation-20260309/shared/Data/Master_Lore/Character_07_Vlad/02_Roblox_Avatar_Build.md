# Vlad - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Easy | **Time Estimate:** 30-45 minutes | **Cost:** ~200-400 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Vlad_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Scaling
```
Keep standard height but make thin:
- Head: 1x
- Torso: 0.9x width (thin)
- Arms: 0.85x (thin)
- Legs: 0.95x
- Overall: Slim and elegant
```

### Step 3: Pale Skin
```
Apply to all body parts:
- Material: SmoothPlastic
- Color: Ghostly Pale White (RGB: 220, 220, 220)
- Or use Roblox skin tone: Pale
```

---

## Part 2: Clothing & Accessories

### The Poet's Shirt
```
CREATE > Part > Block
├── Name: "PoetShirt"
├── Size: 1, 0.8, 0.5
├── Position: Torso
├── Color: White (RGB: 255, 255, 255)
└── Note: Puffy, ruffled appearance

ADD: Small spheres or blocks for ruffles
```

### The Velvet Vest
```
CREATE > Part > Block
├── Name: "VelvetVest"
├── Size: 0.9, 0.7, 0.4
├── Position: Over shirt
├── Color: Dark Purple/Velvet (RGB: 75, 0, 130)
└── Material: Velvet (use SmoothPlastic with dark color)
```

### The Dramatic Cape
```
CREATE > Part > Block
├── Name: "Cape"
├── Size: 1.2, 2.5, 0.1
├── Position: Back of torso
├── Color: Black (RGB: 20, 20, 20)
└── Note: Flowing, dramatic

CREATE > Part > Block
├── Name: "Collar"
├── Size: 1, 0.3, 0.3
├── Position: High collar around neck
├── Color: Deep Red (RGB: 139, 0, 0)
```

### Heart-Shaped Sunglasses
```
CREATE > Part > Sphere (scaled)
├── Name: "LeftLens"
├── Size: 0.4, 0.3, 0.1
├── Position: On face, left side
├── Color: Black

CREATE > Part > Sphere (scaled)
├── Name: "RightLens"
├── Size: 0.4, 0.3, 0.1
├── Position: On face, right side
├── Color: Black

CREATE > Part > Block (Bridge)
├── Name: "SunglassesBridge"
├── Size: 0.2, 0.1, 0.1
├── Position: Between lenses
└── Color: Black
```

### Accessories (Pick One)
```
Option A: Red Rose
CREATE > Part > Sphere (Rose)
├── Name: "Rose"
├── Size: 0.3, 0.3, 0.3
├── Position: Held in hand
├── Color: Red (RGB: 255, 0, 0)

CREATE > Part > Cylinder (Stem)
├── Name: "RoseStem"
├── Size: 0.05, 0.8, 0.05
├── Position: Below rose
└── Color: Green

Option B: Quill
CREATE > Part > Part (Cone)
├── Name: "Quill"
├── Size: 0.1, 0.6, 0.1
├── Position: Held in hand
├── Color: White (feather)

Option C: Tiny Parasol
CREATE > Part > Sphere (half)
├── Name: "ParasolTop"
├── Size: 0.6, 0.3, 0.6
├── Position: Above head
├── Color: Pink (RGB: 255, 182, 193)

CREATE > Part > Cylinder (Handle)
├── Name: "ParasolHandle"
├── Size: 0.05, 1, 0.05
└── Position: Held in hand
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Stand elegantly
2. 0.5s: Hand to forehead (swooning)
3. 1.0s: Dramatic sigh
4. 1.5s: Scribble in notebook
5. 2.0s: Loop

Expression: Melodramatic, emotional
```

#### Walk Animation
```
Keyframes:
1. Smooth, floating glide
2. Arms slightly out
3. Minimal foot movement
4. Overall: Elegant float

Timing: Slow and graceful (0.6 speed)
```

#### Swoon Animation
```
Keyframes:
1. Hand to chest
2. Lean back dramatically
3. Maybe stagger
4. Recover with sigh

Trigger: On dramatic dialogue
```

---

## Part 4: Script Implementation

### Vlad NPC Script
```lua
-- Vlad NPC Controller
-- Place in NPC's Humanoid

local Vlad = {}
Vlad.__index = Vlad

function Vlad.new(npc)
    local self = setmetatable({}, Vlad)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    
    -- Data from LoreDB
    self.PreferredElement = {"Water"}
    self.PreferredClass = {"Support"}
    self.QuestType = "Relationship"
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Swoon = self:LoadAnimation("rbxassetid://YOUR_SWOON_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    
    return self
end

function Vlad:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Vlad:StartDialogueSystem()
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

function Vlad:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "The sun rises, cruel and bright! Protect your eyes, my friend, and gather the crystals before they evaporate like a forgotten dream!",
            "Another day begins! The light is so... harsh. But perhaps that is why the crystals sparkle so beautifully!",
            "Do be careful in this harsh light, dear Weaver! A vampire's work is never done!"
        },
        Day = {
            "Listen to the Slime Synthesizer hum! It is the beating heart of Syllable Springs, forging love and logic from the ether!",
            "The words you craft today shall become the poetry of tomorrow! Make them BEAUTIFUL!",
            "Ah, the sweet sound of creation! It fills my unbeating heart with hope!"
        },
        Dusk = {
            "Ah, the twilight. The perfect lighting for melancholy. Come, let us solve the town's emotional turmoil before the dark takes hold!",
            "The shadows lengthen, and with them, my creativity blooms! A quest, you say? But of course!",
            "The evening brings wisdom to even the darkest of souls. What emotional challenge shall we conquer together?"
        },
        Night = {
            "The Static approaches! They seek to erase all beauty and color! Defend the poetry, Weaver!",
            "The Typos are here! They wish to destroy all that is beautiful! We must fight for ART!",
            "Stay behind me, my dramatic friend! I'll protect you... from a safe distance!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Vlad proclaims: " .. chosenDialogue)
end

function Vlad:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Vlad
```

### Quest Giver Script
```lua
-- Vlad's Quest Data
local VladQuests = {
    {
        QuestID = "tragic_sonnet_01",
        Title = "The Tragic Sonnet",
        Description: "Vlad needs inspiration for his poetry!",
        RequiredWords = {"WEEPING"}, -- Water/Support
        Reward = {Type = "Currency", Amount = 50},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "Oh, Weaver! I am composing an epic sonnet about the [Mundane Object]...",
            Complete = "It's beautiful. Simply beautiful. You have the soul of a poet!"
        }
    },
    {
        QuestID = "misunderstood_gift_01",
        Title = "The Misunderstood Gift",
        Description: "Vlad's gift to Martha was poorly received!",
        RequiredWords = {"CHARMING"}, -- High Charisma
        Reward = {Type = "Item", ID = "PoetryBook"},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "I tried to give Martha a [Gross/Spooky Noun] as a token of my eternal friendship...",
            Complete = "You've saved my social standing! I shall dedicate my next interpretive dance to you!"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns at correct location (Heartwood Grove, under flowers)
- [ ] Pale/ghostly skin visible
- [ ] Heart-shaped sunglasses on face
- [ ] Poet's shirt white and puffy
- [ ] Dark velvet vest
- [ ] Black cape with red collar
- [ ] Holding rose/quill/parasol
- [ ] Idle animation is melodramatic
- [ ] Walk animation is smooth float
- [ ] Dialogue triggers with dramatic flair
- [ ] Phase-specific dialogue works

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
