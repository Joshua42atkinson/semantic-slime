# Ignis - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Moderate to Hard | **Time Estimate:** 50-70 minutes | **Cost:** ~400-600 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert R15 Character (`RigBuilder` > `R15`)
3. Name it "Ignis_NPC"
4. Scale to be slightly taller than Kael (1.6x standard)
5. Apply dragon textures/colors to body parts

### Step 2: Dragon Body
```
Apply to all body parts:
- Material: SmoothPlastic or Metallic
- Color: Dragon Red (RGB: 180, 30, 30)
- ADD: Scale body parts to be more draconic
```

---

## Part 2: Dragon Head

### Head Construction
```
CREATE > Part > Block (Snout)
├── Name: "DragonSnout"
├── Size: 1, 0.6, 0.8
├── Position: Forward from head
└── Color: Red

CREATE > Part > Cylinder (Horn 1)
├── Name: "HornLeft"
├── Size: 0.2, 0.5, 0.2
├── Position: Top left of head
└── Color: Dark Red/Brown

CREATE > Part > Cylinder (Horn 2)
├── Name: "HornRight"
├── Size: 0.2, 0.5, 0.2
├── Position: Top right of head
└── Color: Dark Red/Brown
```

### The Reading Glasses
```
CREATE > Part > Block (Left Lens)
├── Name: "GlassesLeft"
├── Size: 0.4, 0.2, 0.05
├── Position: On nose tip
├── Material: Neon
└── Color: Light Blue (wire-frame look)

CREATE > Part > Block (Right Lens)
├── Name: "GlassesRight"
├── Size: 0.4, 0.2, 0.05
├── Position: On nose tip
├── Material: Neon
└── Color: Light Blue

CREATE > Part > Block (Bridge)
├── Name: "GlassesBridge"
├── Size: 0.1, 0.05, 0.05
└── Position: Between lenses
```

---

## Part 3: The Mayoral Outfit

### The "MAYOR" Sash
```
CREATE > Part > Block
├── Name: "Sash"
├── Size: 1.8, 0.8, 0.1
├── Position: Diagonal across torso
├── Color: Red and Gold
└── NOTE: Use decal for "MAYOR" text

ADD: Decal
├── Name: "MayorText"
├── Image: "MAYOR" in big block letters
├── Color: Gold on Red
└── Position: Center of sash
```

### The Tiny Tie
```
CREATE > Part > Block
├── Name: "Tie"
├── Size: 0.15, 0.4, 0.05
├── Position: Center of chest, below sash
└── Color: Dark Red
```

---

## Part 4: Accessories

### The Giant Clipboard
```
CREATE > Part > Block (Board)
├── Name: "Clipboard"
├── Size: 1, 1.2, 0.1
├── Position: Held in hand
├── Color: Brown (wood)
└── Transparency: 0.1

ADD: Decal (Paper/Form)
- Lines representing text
- Checkboxes

CREATE > Part > Cylinder (Clip)
├── Name: "Clip"
├── Size: 0.3, 0.1, 0.15
├── Position: Top of clipboard
└── Color: Silver/Grey
```

### The Fountain Pen
```
CREATE > Part > Cylinder (Pen Body)
├── Name: "PenBody"
├── Size: 0.1, 0.8, 0.1
├── Position: Held in other hand
└── Color: Black

CREATE > Part > Cone (Pen Tip)
├── Name: "PenTip"
├── Size: 0.1, 0.2, 0.1
├── Position: Bottom of pen
└── Color: Gold
```

---

## Part 5: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation
```
Keyframes:
1. Start: Stand authoritatively
2. 0.5s: Aggressively check items off clipboard
3. 1.0s: Tap foot impatiently
4. 1.5s: Small puff of smoke from nostrils
5. 2.0s: Check watch/invisible clock
6. 2.5s: Loop

Expression: Stressed, important, impatient
```

#### Walk Animation
```
Keyframes:
1. Important, purposeful stomp
2. Head held high
3. Clipboard tucked under arm
4. Overall: "I have places to be"

Timing: Moderate (0.7 speed)
```

#### Talk/Wave Animation
```
Keyframes:
1. Raise clipboard
2. Wave it dramatically
3. Point with pen
4. Shake head at bureaucracy

Trigger: During dialogue
```

---

## Part 6: Script Implementation

### Ignis NPC Script
```lua
-- Ignis NPC Controller
-- Place in NPC's Humanoid

local Ignis = {}
Ignis.__index = Ignis

function Ignis.new(npc)
    local self = setmetatable({}, Ignis)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.CurrentPhase = "Dawn"
    
    -- Data from LoreDB
    self.PreferredElement = {"Earth", "Fire"}
    self.PreferredClass = {"Tank", "Builder"}
    self.QuestType = "Civic Duty"
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Wave = self:LoadAnimation("rbxassetid://YOUR_WAVE_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartSmokePuff()
    
    return self
end

function Ignis:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Ignis:StartDialogueSystem()
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

function Ignis:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Attention citizens! The crystals have spawned on schedule! I expect a 20% increase in collection efficiency today! Get moving!",
            "The daily reset has occurred. Forms must be filed. Productivity must increase!",
            "New day, new opportunities for administrative excellence! Gather those letters!"
        },
        Day = {
            "Remember, you need a Class-A permit to operate the Slime Synthesizer! Keep your vowels organized!",
            "The Synthesizer requires proper licensing! No unauthorized word creation without Form 27-B!",
            "Construct with responsibility! Every word has consequences!"
        },
        Dusk = {
            "The schedule demands civic action! Weaver, report to me at once, I have three clipboards of municipal errors!",
            "Citizen! You there! We have a code violation that needs immediate attention!",
            "The evening brings... more work. Always more work. What needs fixing now?"
        },
        Night = {
            "The Static is violating several noise ordinances and zoning laws! Defend the infrastructure, Weaver!",
            "Anarchy! CHAOS! The filing system is under attack! FIGHT!",
            "The Typos threaten our permit system! We must defend proper documentation!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Mayor Ignis announces: " .. chosenDialogue)
end

function Ignis:StartSmokePuff()
    -- Add ParticleEmitter for stress smoke puffs
end

function Ignis:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Ignis
```

---

## Part 7: Testing Checklist

- [ ] NPC spawns in Town Hub (near Synthesizer)
- [ ] Dragon body (red scales)
- [ ] Tiny reading glasses on nose
- [ ] "MAYOR" sash visible
- [ ] Tiny formal tie
- [ ] Giant clipboard in hand
- [ ] Fountain pen in other hand
- [ ] Idle checks clipboard
- [ ] Smoke puff from nostrils
- [ ] Walk is important stomp

---

## Part 8: Optimization Tips

1. **Dragon Texture** - Use scales texture on body parts
2. **Reading Glasses** - Use Neon material for wire-frame look
3. **Sash Decal** - Create custom decal for "MAYOR" text

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
