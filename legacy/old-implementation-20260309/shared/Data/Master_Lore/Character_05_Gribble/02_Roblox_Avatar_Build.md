# Gribble - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Easy | **Time Estimate:** 30-45 minutes | **Cost:** ~200-400 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Gribble_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Scaling
```
IMPORTANT: Keep him SMALL - distinctive from other characters!

- Head: 0.6x
- Torso: 0.6x
- Arms: 0.5x
- Legs: 0.5x

This makes him distinctly smaller than the player
```

### Step 3: The Goblin Head
```
Option A: Roblox Catalog Accessory
1. Go to Toolbox > Catalog
2. Search for "Goblin" or "Orc" head
3. Import and attach to head

Option B: Custom Build
CREATE > Part > Sphere
├── Name: "HeadBase"
├── Size: 0.8, 0.8, 0.8
├── Position: Head
└── Color: Bright Green (RGB: 50, 205, 50)

CREATE > Part > Cylinder (Left Ear)
├── Name: "LeftEar"
├── Size: 0.3, 0.6, 0.1
├── Position: Top-left of head
├── Color: Green
└── Rotation: Pointed outward

CREATE > Part > Cylinder (Right Ear)
├── Name: "RightEar"
├── Size: 0.3, 0.6, 0.1
├── Position: Top-right of head
└── Color: Green

CREATE > Part > Sphere (Nose)
├── Name: "Nose"
├── Size: 0.3, 0.2, 0.2
├── Position: Center of face
└── Color: Darker Green
```

---

## Part 2: Clothing & Accessories

### Explorer Outfit (Dusty/Overgrown)
```
Shirt
CREATE > Part > Block
├── Name: "Shirt"
├── Size: 0.8, 0.6, 0.4
├── Position: Torso
├── Color: Tan/Khaki (RGB: 210, 180, 140)
└── Note: Oversized, slightly torn

Pants
CREATE > Part > Block
├── Name: "Pants"
├── Size: 0.5, 0.8, 0.4
├── Position: Legs
└── Color: Brown (RGB: 139, 69, 19)
```

### The Overstuffed Backpack
```
CREATE > Part > Block
├── Name: "Backpack"
├── Size: 0.8, 1, 0.6
├── Position: Back of torso
├── Color: Olive Green (RGB: 85, 107, 47)
└── Note: Comically large, bulging with "supplies"

ADD: Various small bumps to show it's stuffed
```

### Goggles (Key Accessory)
```
CREATE > Part > Torus (Left Lens)
├── Name: "GoggleLeft"
├── Size: 0.3, 0.1, 0.3
├── Position: On forehead
├── Color: Black

CREATE > Part > Torus (Right Lens)
├── Name: "GoggleRight"
├── Size: 0.3, 0.1, 0.3
├── Position: Next to left lens
└── Color: Black

CREATE > Part > Block (Strap)
├── Name: "GoggleStrap"
├── Size: 0.8, 0.1, 0.1
├── Position: Around head
└── Color: Brown
```

### Tools (Dual-Wielding)
```
Magnifying Glass
CREATE > Part > Cylinder (Handle)
├── Name: "MagnifyingHandle"
├── Size: 0.05, 0.5, 0.05
├── Position: Held in hand
├── Color: Brown

CREATE > Part > Torus (Lens)
├── Name: "MagnifyingLens"
├── Size: 0.3, 0.05, 0.3
├── Position: Top of handle
└── Color: Light Blue (transparent)

Pickaxe (Slightly Bent)
CREATE > Part > Cylinder (Handle)
├── Name: "PickHandle"
├── Size: 0.05, 0.8, 0.05
├── Position: Held in other hand
├── Color: Brown

CREATE > Part > Block (Head)
├── Name: "PickHead"
├── Size: 0.3, 0.1, 0.1
├── Position: Top of handle
└── Color: Grey
└── Note: Slightly bent/crooked
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Twitch, look around
2. 0.3s: Examine ground with magnifying glass
3. 0.6s: Look over shoulder suspiciously
4. 0.9s: Scribble on parchment
5. 1.2s: Twitch, repeat

Expression: Hyperactive, curious, jittery
```

#### Walk Animation
```
Keyframes:
1. Fast scurry steps
2. Arms pumping
3. Backpack jiggling
4. Head bobbing

Timing: Fast (1.5x speed) - always in a rush
```

#### Run Animation
```
Keyframes:
1. Even faster sprint
2. Arms flailing slightly
3. Maximum energy

Timing: Very fast (2x speed)
```

---

## Part 4: Script Implementation

### Gribble NPC Script
```lua
-- Gribble NPC Controller
-- Place in NPC's Humanoid

local Gribble = {}
Gribble.__index = Gribble

function Gribble.new(npc)
    local self = setmetatable({}, Gribble)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    self.IsHyperactive = true
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Run = self:LoadAnimation("rbxassetid://YOUR_RUN_ANIM_ID"),
        Examine = self:LoadAnimation("rbxassetid://YOUR_EXAMINE_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartHyperactiveWander()
    
    return self
end

function Gribble:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Gribble:StartDialogueSystem()
    local function onTouch(otherPart)
        local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
        if player then
            self:TriggerDialogue(player)
        end
    end
    
    local detector = Instance.new("Part")
    detector.Name = "DialogueDetector"
    detector.Size = Vector3.new(8, 8, 8)
    detector.Anchored = false
    detector.CanCollide = false
    detector.Transparency = 1
    detector.Parent = self.NPC
    detector.Touched:Connect(onTouch)
end

function Gribble:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "The reset! Fascinating! New crystals, fresh typography scattered across the terrain! I must chart their spawn coordinates immediately!",
            "Another cycle begins! The letter distribution has refreshed! Quick, to the field notes!",
            "Did you know the letters spawn in predictable patterns? I charted it! Want to see my charts?"
        },
        Day = {
            "Have you studied the internal mechanisms of the Slime Fabricator? I tried to take it apart once to see how it synthesizes vowels. Martha hit me with a broom.",
            "The Fabricator's output follows mathematical sequences! I've mapped seventeen different patterns!",
            "Words are just linguistic organisms! Study their morphology! Know their taxonomy!"
        },
        Dusk = {
            "The lighting is changing, which means hidden runes might reveal themselves! Grab your gear, we have an anomaly to investigate!",
            "Twilight reveals secrets! The shadows form ancient glyphs! Or maybe that's just the fence. Either way, we must INVESTIGATE!",
            "My instruments detect unusual linguistic fluctuations! Quick, before the data is lost to the darkness!"
        },
        Night = {
            "Look at the morphological degradation on these Shadow entities! Astounding! Hold still, you terrifying beast, I need to measure your cranial capacity!",
            "Fascinating! The Discord creatures exhibit unique behavioral patterns! They're attacking! How INTERESTING!",
            "The shadows reveal hidden truths! Don't just fight them, STUDY them!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Gribble exclaims: " .. chosenDialogue)
end

function Gribble:StartHyperactiveWander()
    -- Never stays still for long
    task.spawn(function()
        while true do
            task.wait(math.random(2, 5))
            -- Wander to random location quickly
            -- Always appears to be in a rush
        end
    end)
end

function Gribble:OnCombat()
    -- Instead of running away, chase enemies to study them
    -- "Wait, let me get a closer look!"
end

function Gribble:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Gribble
```

### Quest Giver Script
```lua
-- Gribble's Quest Data
local GribbleQuests = {
    {
        QuestID = "unyielding_door_01",
        Title = "The Unyielding Door",
        Description: "Ancient door blocked by something! Must investigate!",
        RequiredWords = {"VOLATILE"}, -- Fire/Striker
        Reward = {Type = "Currency", Amount = 45},
        Dialogue = {
            Start = "Eureka! I've found the hidden entrance to the [Ancient Location]! But blocked by [Gross Noun]!",
            Complete = "Brilliant! Now, let's see what's in—oh, it's just a linen closet. The plot thickens!"
        }
    },
    {
        QuestID = "dark_chasm_01",
        Title = "The Dark Chasm",
        Description: "Need light to explore the darkness!",
        RequiredWords = {"CLARITY"}, -- Light/High Accuracy
        Reward = {Type = "Item", ID = "AncientRock"},
        Dialogue = {
            Start = "My map says the legendary [Shiny Object] is just past this corridor, but it's pitch black!",
            Complete = "Ah! I see it! Wait, that's just a shiny rock. I'm bagging it anyway!"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns at correct location (Logos District, near library)
- [ ] Green goblin skin visible
- [ ] Pointy ears
- [ ] Oversized explorer outfit
- [ ] Giant overstuffed backpack
- [ ] Goggles on forehead
- [ ] Holding magnifying glass and pickaxe
- [ ] Idle animation is jittery/hyperactive
- [ ] Walk animation is fast scurry
- [ ] Dialogue triggers with excitement
- [ ] During combat, chases enemies instead of fleeing

---

## Part 6: Optimization Tips

1. **Small Scale** - Distinctive from other characters
2. **Jitter Script** - Random small movements for hyperactivity
3. **Backpack Physics** - Use constraints for jiggling
4. **Chase AI** - Unique combat behavior

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
