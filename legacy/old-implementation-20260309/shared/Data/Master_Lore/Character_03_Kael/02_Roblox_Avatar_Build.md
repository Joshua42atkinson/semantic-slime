# Kael - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Moderate/Easy | **Time Estimate:** 45-60 minutes | **Cost:** ~300-500 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Kael_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Scaling
```
Scale up for imposing Minotaur presence:
- Head: 1.5x (larger for horns)
- Torso: 1.8x width, 2x height (broad chest)
- Arms: 1.5x (muscular)
- Legs: 1.5x (thick, powerful)
- Overall: Apply proportionally

This makes him tower over players (8ft equivalent)
```

### Step 3: The Minotaur Head
```
Option A: Roblox Catalog Accessory
1. Go to Toolbox > Catalog
2. Search for "Bull" or "Minotaur" head
3. Import and attach to head

Option B: Custom Build
CREATE > Part > Sphere
├── Name: "HeadBase"
├── Size: 1.2, 1.2, 1.2
├── Position: Head
└── Color: Brown/Fur (RGB: 139, 90, 43)

CREATE > Part > Cylinder (Horns)
├── Name: "LeftHorn"
├── Size: 0.3, 1, 0.3
├── Position: Top-left of head
├── Color: Cream/Ivory
└── Rotation: Angled outward

CREATE > Part > Cylinder (Right Horn)
├── Name: "RightHorn"
├── Size: 0.3, 1, 0.3
├── Position: Top-right of head
├── Color: Cream/Ivory
└── Rotation: Angled outward

CREATE > Part > Block (Snout)
├── Name: "Snout"
├── Size: 0.8, 0.4, 0.5
├── Position: Front of face
├── Color: Brown
```

---

## Part 2: Clothing & Accessories

### Knight's Armor (Mismatched Style)
```
Chest Plate
CREATE > Part > Block
├── Name: "ChestPlate"
├── Size: 1.5, 1.2, 0.3
├── Position: Torso front
├── Material: Metal
├── Color: Silver (RGB: 192, 192, 192)
└── Detail: Add gold trim (small yellow blocks)

Shoulder Pauldrons
CREATE > Part > Sphere (half)
├── Name: "LeftPauldron"
├── Size: 0.8, 0.8, 0.8
├── Position: Left shoulder
├── Color: Gold (RGB: 255, 215, 0)

CREATE > Part > Sphere (half)
├── Name: "RightPauldron"
├── Size: 0.8, 0.8, 0.8
├── Position: Right shoulder
├── Color: Gold
```

### The Cape (Too Short)
```
CREATE > Part > Block
├── Name: "Cape"
├── Size: 1.2, 2, 0.1
├── Position: Back of torso (slightly high)
├── Color: Crimson (RGB: 220, 20, 60)
└── Note: Should be slightly short for his height
```

### The Massive Sword (Always Sheathed)
```
CREATE > Part > Cylinder (Handle)
├── Name: "SwordHandle"
├── Size: 0.2, 1.5, 0.2
├── Position: Diagonal, on back
├── Color: Brown (RGB: 139, 69, 19)

CREATE > Part > Cylinder (Blade - hidden)
├── Name: "SwordBlade"
├── Size: 0.3, 3, 0.3
├── Position: Extending from handle
├── Color: Silver
└── Transparency: 1 (sheathed/hidden)

CREATE > Part > Block (Guard)
├── Name: "SwordGuard"
├── Size: 0.8, 0.2, 0.2
├── Position: Top of handle
├── Color: Gold
```

### Helmet (Optional, Often Askew)
```
CREATE > Part > Sphere (half)
├── Name: "Helmet"
├── Size: 1.3, 0.8, 1.3
├── Position: Top of head
├── Color: Silver
└── Rotation: Slightly askew (for comedy)
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Stand tall, chest puffed out
2. 0.5s: Hands on hips (heroic pose)
3. 1.0s: Look around dramatically
4. 1.5s: Strike different heroic pose
5. 2.0s: Loop

Expression: Noble, proud, dramatic
```

#### Tiptoe Walk Animation
```
Keyframes:
1. Lift feet high with each step
2. Place down carefully (contrasts size)
3. Slight sway in torso
4. Arms held out for balance

Timing: Slower, overly careful (0.7 speed)
```

#### Dramatic Freeze
```
Keyframes:
1. suddenly stop movement
2. Hold breath (chest still)
3. Slowly look down
4. Freeze completely

Trigger: When small creatures/npcs nearby
```

---

## Part 4: Script Implementation

### Kael NPC Script
```lua
-- Kael NPC Controller
-- Place in NPC's Humanoid

local Kael = {}
Kael.__index = Kael

function Kael.new(npc)
    local self = setmetatable({}, Kael)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    self.IsNearSmallCreature = false
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Dramatic = self:LoadAnimation("rbxassetid://YOUR_DRAMATIC_ANIM_ID"),
        Freeze = self:LoadAnimation("rbxassetid://YOUR_FREEZE_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartGuardPatrol()
    
    return self
end

function Kael:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Kael:StartDialogueSystem()
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

function Kael:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "The sun rises, and with it, a new campaign! Gather the scattered crystals of fate, squire! Leave no vowel behind!",
            "By the horns of my ancestors! Another day dawns! Go forth and collect the letters of destiny!",
            "The dawn calls to us, brave one! Will you answer with the valor of a thousand knights?!"
        },
        Day = {
            "The Fabricator hums with the power of a thousand bards! Forge your Slimes well, for they are your linguistic broadswords!",
            "A true hero strengthens their arsenal! Build your words with the precision of a master blacksmith!",
            "Remember, squire: a well-constructed word is mightier than any physical blade!"
        },
        Dusk = {
            "Halt! The shadows lengthen, and the realm cries out for aid! Will you answer the call of duty, or will this [Mundane Item] remain unpolished?!",
            "A dark threat emerges! Well... moderately concerning issue... But it needs a HERO! ...I mean, it needs YOU!",
            "I sense great disturbance in the linguistic balance. The realm requires your unique skills!"
        },
        Night = {
            "The Discord of the Psyche is upon us! Stand firm! If any shadow comes near the flowerbeds, they shall taste my steel!",
            "Fear not, companion! I shall hold the line! ...What line? Oh, the... imaginary one! Yes!",
            "The darkness tests us! But we are the LIGHT! ...mostly me. You're doing great too though!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Kael declares: " .. chosenDialogue)
end

function Kael:StartGuardPatrol()
    -- Guard near the Fabricator
    task.spawn(function()
        while true do
            task.wait(math.random(10, 20))
            -- Patrol short distance, return to post
            -- Always tiptoes
        end
    end)
end

function Kael:OnNearbySmallCreature()
    -- Trigger dramatic freeze animation
    -- "Oh no, don't move, don't want to hurt it!"
    self.IsNearSmallCreature = true
end

function Kael:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Kael
```

### Quest Giver Script
```lua
-- Kael's Quest Data
local KaelQuests = {
    {
        QuestID = "fearsome_beast_01",
        Title = "The Fearsome Beast",
        Description = "A terrifying creature threatens the realm! (It's probably just a cat)",
        RequiredWords = {"GENTLE"}, -- Air/Support
        Reward = {Type = "Currency", Amount = 50},
        Dialogue = {
            Start = "Hail, champion! A terrifying [Small Animal] has laid siege to the [Location]!...",
            Complete = "A flawless victory! The beast has been vanquished to a nice farm upstate!"
        }
    },
    {
        QuestID = "broken_aegis_01",
        Title = "The Broken Aegis",
        Description = "The realm's defenses have fallen! (The fence is broken)",
        RequiredWords = {"FORTIFY"}, -- Earth/High Defense
        Reward = {Type = "Item", ID = "HeroBadge"},
        Dialogue = {
            Start = "Disaster strikes! The great barrier—uh, I mean, the [Mundane Object]—has been shattered...",
            Complete = "The realm is secure once more, thanks to your linguistic valor!"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns at correct location (Town Hub, near Fabricator)
- [ ] Minotaur head with horns visible
- [ ] Armor is mismatched but shiny
- [ ] Cape is slightly too short
- [ ] Sword is massive and ornate (sheathed)
- [ ] Idle animation shows heroic poses
- [ ] Walk animation shows tiptoeing (comedic)
- [ ] Freezes when small creatures nearby
- [ ] Dialogue triggers with dramatic flair
- [ ] Different dialogue for each time phase

---

## Part 6: Optimization Tips

1. **Bulk Package** - Use Roblox's Superhero or muscular bundle
2. **Custom Horns** - Simple cylinders work well
3. **Sheathed Sword** - Hide blade, show only handle/guard
4. **Voice Lines** - Consider adding dramatic music cue

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
