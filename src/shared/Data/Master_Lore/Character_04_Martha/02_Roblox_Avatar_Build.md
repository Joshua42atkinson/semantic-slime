# Martha - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Moderate | **Time Estimate:** 45-60 minutes | **Cost:** ~300-500 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Martha_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Stone Texturing
```
Apply grey/stone material to entire body:
1. Select all body parts
2. Apply Material: Concrete or Stone
3. Color: Grey (RGB: 128, 128, 128)
4. Use BrickColor: Medium stone grey

Key: She should look like a living statue
```

### Step 3: The Gargoyle Head
```
Option A: Roblox Catalog Accessory
1. Go to Toolbox > Catalog
2. Search for "Gargoyle" or "Dragon" head
3. Import and attach to head

Option B: Custom Build
CREATE > Part > Sphere
├── Name: "HeadBase"
├── Size: 1, 1, 1
├── Position: Head
└── Color: Grey (stone)

CREATE > Part > Cylinder (Ears/horns)
├── Name: "LeftEar"
├── Size: 0.3, 0.8, 0.3
├── Position: Top-left of head
└── Color: Grey

CREATE > Part > Cylinder (Right Ear)
├── Name: "RightEar"
├── Size: 0.3, 0.8, 0.3
├── Position: Top-right of head
└── Color: Grey

CREATE > Part > Block (Snout)
├── Name: "Snout"
├── Size: 0.6, 0.4, 0.5
├── Position: Front of face
└── Color: Grey

CREATE > Part > Cone (Fangs)
├── Name: "Fangs"
├── Size: 0.1, 0.3, 0.1
├── Position: Bottom of snout
└── Color: White
```

### Reading Glasses (Key Accessory)
```
CREATE > Part > Torus
├── Name: "GlassesLeft"
├── Size: 0.3, 0.1, 0.3
├── Position: On snout, left side
└── Color: Black

CREATE > Part > Torus (Right)
├── Name: "GlassesRight"
├── Size: 0.3, 0.1, 0.3
├── Position: On snout, right side
└── Color: Black

CREATE > Part > Block (Bridge)
├── Name: "GlassesBridge"
├── Size: 0.2, 0.05, 0.05
├── Position: Between glasses
└── Color: Black
```

---

## Part 2: Clothing & Accessories

### The Floral Apron (Key Visual)
```
CREATE > Part > Block
├── Name: "Apron"
├── Size: 1, 1.2, 0.1
├── Position: Waist/lower torso
├── Color: Pink (RGB: 255, 182, 193)
└── Note: Pastel floral pattern - contrast with stone body!

ADD: Apron strings (small blocks on sides)
```

### Stone Bat Wings
```
CREATE > Part > Block (Left Wing)
├── Name: "LeftWing"
├── Size: 1.5, 0.1, 0.8
├── Position: Upper back, left side
├── Color: Grey (stone)
└── Rotation: Angled back

CREATE > Part > Block (Right Wing)
├── Name: "RightWing"
├── Size: 1.5, 0.1, 0.8
├── Position: Upper back, right side
├── Color: Grey
└── Rotation: Angled back

Note: Wings should be folded against back
```

### The Soup Bowl (Essential)
```
CREATE > Part > Sphere (half)
├── Name: "Bowl"
├── Size: 0.5, 0.3, 0.5
├── Position: Held in hands
├── Color: Brown (RGB: 139, 69, 19)

CREATE > Part > ParticleEmitter (Steam)
├── Name: "SoupSteam"
├── Position: Above bowl
├── Color: White
├── Rate: 20
└── Lifetime: 1-2 seconds
```

### Knitting Needles (Alternative)
```
CREATE > Part > Cylinder (Left Needle)
├── Name: "NeedleLeft"
├── Size: 0.05, 1, 0.05
├── Position: Held in left hand
├── Color: Silver

CREATE > Part > Cylinder (Right Needle)
├── Name: "NeedleRight"
├── Size: 0.05, 1, 0.05
├── Position: Held in right hand
└── Color: Silver
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Hover slightly off ground
2. 0.5s: Knitting motion with hands
3. 1.0s: Look around protectively
4. 1.5s: Continue knitting
5. 2.0s: Loop

Expression: Warm, motherly, watchful
```

#### Hover Movement
```
Keyframes:
1. Gentle bob up and down
2. Slight sway side to side
3. Wings occasionally flutter
4. Never touches ground when moving

Timing: Slow, floating (0.3 speed)
```

#### Special: Offer Soup
```
Keyframes:
1. Hold bowl forward
2. Nod insistently
3. Wait for player to "take" it
4. If rejected, look disappointed

Trigger: On player interaction
```

---

## Part 4: Script Implementation

### Martha NPC Script
```lua
-- Martha NPC Controller
-- Place in NPC's Humanoid

local Martha = {}
Martha.__index = Martha

function Martha.new(npc)
    local self = setmetatable({}, Martha)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    self.IsHovering = true
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Hover = self:LoadAnimation("rbxassetid://YOUR_HOVER_ANIM_ID"),
        Knit = self:LoadAnimation("rbxassetid://YOUR_KNIT_ANIM_ID"),
        OfferSoup = self:LoadAnimation("rbxassetid://YOUR_OFFER_SOUP_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartHovering()
    
    return self
end

function Martha:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Martha:StartDialogueSystem()
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

function Martha:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Good morning, sweetie! The crystals are lovely today, but don't run too fast while you collect them, or you'll trip and skin your knee!",
            "Oh, look at you! You're up so early! Did you eat? I have some hot gravel water, it's very nourishing!",
            "The dawn is beautiful, dear, but don't forget your breakfast! Growing letters need fuel!"
        },
        Day = {
            "Working at the Fabricator takes so much energy. Make sure your Etymons have plenty of vowels, they need a balanced diet to grow big and strong!",
            "Sweetie, you're working too hard! Take a break and have some soup. The hot water is very hydrating!",
            "A well-fed word is a strong word! Now eat your consonants, they're good for you!"
        },
        Dusk = {
            "The air is getting chilly, and the shadows are looking a bit peeky. Come here, let me fix this [Mundane Problem] before the night sets in.",
            "Oh dear, you look tired. Let me make you something warm. What? Oh, the quest! Yes, yes, after soup!",
            "The wind is picking up! Are you wearing enough layers? Never mind, I'll knit you something!"
        },
        Night = {
            "Oh, I don't like this Discord one bit! You stay behind me, dear! If any shadows try to touch you, they'll get a swift smack on the bottom!",
            "Don't worry, I'll protect you! I've chased away scarier things than some measly shadows. Back in my day, we didn't HAVE Discord, we just had stern looks!",
            "Shadows! In MY village?! Absolutely not! Scram before I call the neighborhood watch!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Martha says: " .. chosenDialogue)
end

function Martha:StartHovering()
    -- Gentle hovering motion
    task.spawn(function()
        while true do
            -- Bob up and down
            local startPos = self.RootPart.Position
            for i = 1, 30 do
                self.RootPart.Position = startPos + Vector3.new(0, math.sin(i / 5) * 0.2, 0)
                task.wait(0.05)
            end
        end
    end)
end

function Martha:OfferSoup()
    -- Trigger offer soup animation and dialogue
end

function Martha:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Martha
```

### Quest Giver Script
```lua
-- Martha's Quest Data
local MarthaQuests = {
    {
        QuestID = "magical_sniffles_01",
        Title = "The Magical Sniffles",
        Description: "Poor Pip the Slime has a cold!",
        RequiredWords = {"WARMING"}, -- Fire/Support
        Reward = {Type = "Currency", Amount = 40},
        Dialogue = {
            Start = "Oh, dear! Poor Pip was playing in the [Cold Weather Noun] and now he has [Silly Disease]!",
            Complete = "Perfect! He'll be back to bouncing in no time. Did you want a bowl for yourself, dear?"
        }
    },
    {
        QuestID = "preventive_sweater_01",
        Title = "The Preventive Sweater",
        Description: "Martha needs to bundle everyone up!",
        RequiredWords = {"WHOLESOME"}, -- High HP
        Reward = {Type = "Item", ID = "EtherealSweater"},
        Dialogue = {
            Start = "The wind from the [Location] is picking up! I need a word with high [Target Stat] to stitch into this scarf!",
            Complete = "There now, nice and snug! Don't stay out too late!"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns at correct location (Pneuma District, near fountain)
- [ ] Stone/gargoyle body texture is visible
- [ ] Reading glasses on snout
- [ ] Floral apron contrasts with stone body
- [ ] Bat wings folded on back
- [ ] Holding steaming bowl of soup
- [ ] Hovering animation plays (not walking)
- [ ] Knitting motions visible
- [ ] Dialogue triggers with motherly concern
- [ ] Different dialogue for each time phase

---

## Part 6: Optimization Tips

1. **Stone Material** - Use Roblox material variants for realism
2. **Hover Script** - Simple sine wave for floating
3. **Particle Effects** - Steam from soup bowl
4. **Apron Contrast** - Pastel colors stand out against grey

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
