# Yorick - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Extremely Easy | **Time Estimate:** 20-30 minutes | **Cost:** ~100-200 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert new R15 Character (`RigBuilder` > `R15`)
3. Name it "Yorick_NPC"
4. Set Humanoid RigType to "R15"

### Step 2: Using the Skeleton Bundle
```
RECOMMENDED: Use the built-in Roblox Skeleton package
1. Go to Toolbox > Catalog
2. Search for "Skeleton" or "Classic Skeleton"
3. Import the R15 Skeleton bundle
4. Apply to your NPC rig

Alternative: Build manually using white bone parts
- Torso: Transparent shirt with visible ribs
- Arms: Bone segments with joints
- Legs: Bone segments
- Head: Skull mesh
```

### Step 3: The Skull Face
```
Option A: Use Skeleton head (recommended)
- Standard skull appearance
- No modifications needed

Option B: Custom skull
- Use Sphere or custom mesh
- White/cream color
- Empty eye sockets (black spheres)
- Nose hole (small black cylinder)
- Teeth row (small white boxes)
```

### Step 4: Scaling
```
IMPORTANT: Keep him STANDARD size!

- Head: 1x (standard)
- Torso: 1x (standard)
- Arms: 1x (standard)
- Legs: 1x (standard)

This emphasizes his "average guy" status compared to Barnaby
```

---

## Part 2: Clothing & Accessories

### Safety Vest (Key Item)
```
CREATE > Part > Block
├── Name: "SafetyVest"
├── Size: 1.2, 0.8, 0.3
├── Position: Torso front
├── Material: SmoothPlastic
├── Color: Neon Orange (RGB: 255, 140, 0)
└── Transparency: 0.3 (slightly see-through over ribs)

ADD: Stripes using smaller black parts
```

### Hat Options
```
Option A: Faded Trucker Hat
CREATE > Part > Sphere (half)
├── Name: "TruckerHat"
├── Size: 0.8, 0.4, 0.8
├── Position: Top of head
├── Color: Faded Blue (RGB: 100, 120, 140)
└── Brim: Small block extending forward

Option B: Hard Hat
CREATE > Part > Sphere (half)
├── Name: "HardHat"
├── Size: 1, 0.5, 1
├── Position: Top of head
├── Color: Yellow (RGB: 255, 220, 0)
└── Brim: Rim around bottom edge
```

### The Broom (Essential Accessory)
```
CREATE > Part > Cylinder (Handle)
├── Name: "BroomHandle"
├── Size: 0.1, 3, 0.1
├── Position: Diagonal, held in hand
├── Color: Brown (RGB: 139, 69, 19)

CREATE > Part > Block (Bristles)
├── Name: "BroomHead"
├── Size: 0.8, 0.5, 0.2
├── Position: Bottom of handle
├── Color: Straw/Tan (RGB: 228, 198, 140)

Script: Allow NPC to hold broom in hand attachment
```

### Clipboard (Alternative)
```
CREATE > Part > Block
├── Name: "Clipboard"
├── Size: 0.6, 0.8, 0.1
├── Position: Held in other hand
├── Color: Brown (RGB: 139, 69, 19)

ADD: White paper on front (thin block)
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation (Recommended)
```
Keyframes:
1. Start: Standing slightly slouched
2. 0.5s: Check invisible pocket watch
3. 1.0s: Lean on broom
4. 1.5s: Let out long silent sigh (body shake)
5. 2.0s: Loop

Expression: Tired, professional, unbothered
```

#### Work Animation
```
Keyframes:
1. Arms extended holding broom
2. Push broom back and forth
3. Slight body movement with push
4. Occasional pause to check watch

Timing: Rhythmic, 0.8 speed
```

#### Walk Animation
```
Keyframes:
1. Purposeful stride
2. Broom held at angle
3. Slight foot drag
4. Overall: "Just trying to get to work"

Timing: Normal speed (1.0)
```

---

## Part 4: Script Implementation

### Yorick NPC Script
```lua
-- Yorick NPC Controller
-- Place in NPC's Humanoid

local Yorick = {}
Yorick.__index = Yorick

function Yorick.new(npc)
    local self = setmetatable({}, Yorick)
    self.NPC = npc
    self.Humanoid = npc:WaitForChild("Humanoid")
    self.RootPart = npc:WaitForChild("HumanoidRootPart")
    self.AnimationController = npc:WaitForChild("AnimationController")
    self.CurrentPhase = "Dawn"
    self.IsOnBreak = false
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Work = self:LoadAnimation("rbxassetid://YOUR_WORK_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Break = self:LoadAnimation("rbxassetid://YOUR_BREAK_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:StartWorkSchedule()
    
    return self
end

function Yorick:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Yorick:StartDialogueSystem()
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

function Yorick:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Morning. Watch your step, I just swept up all those loose vowels. Slip hazard.",
            "Early shift today. The letters get all over the place overnight. And DON'T get me started on the semicolons - they're everywhere.",
            "You know, I used to work the night shift. That's when the scary stuff comes out. Much prefer the day shift."
        },
        Day = {
            "Fabricator is running hot today. Make sure you lift those heavy syllables with your knees, not your back.",
            "Word of advice: don't stack your consonants too high. Last guy did that and the whole thing came crashing down. Took me three hours to sweep it up.",
            "You know what makes a good word? Balance. Not too flashy, not too weak. Just gets the job done. Like me."
        },
        Dusk = {
            "Hey. Clock's ticking and I got a situation preventing me from clocking out. Help a guy out?",
            "Look, I would do this myself but I've got three other tasks on my queue. Union rules - can't exceed my workload.",
            "Listen, I would've handled this already but something came up. Literally. A letter 'S' fell on my lunch break. Workers' comp nightmare."
        },
        Night = {
            "Mandatory overtime. Great. Guess I'll just stand here and rattle menacingly. Don't forget to log your combat hours.",
            "You know, I've seen worse. Last week there was a whole swarm of exclamation points. THAT was a nightmare.",
            "Night shift differential doesn't even cover the danger pay. I told the Mayor - either more pay or I'm walking. Still waiting on an answer."
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Yorick says: " .. chosenDialogue)
end

function Yorick:StartWorkSchedule()
    task.spawn(function()
        while true do
            -- Work for 45 minutes
            self:StartWork()
            task.wait(45 * 60)
            
            -- Take 15 minute break (union mandated)
            self:TakeBreak()
            task.wait(15 * 60)
        end
    end)
end

function Yorick:StartWork()
    self.IsOnBreak = false
    if self.Animations.Work then
        self.Animations.Work:Play()
    end
    -- Wander and sweep
end

function Yorick:TakeBreak()
    self.IsOnBreak = true
    if self.Animations.Work then
        self.Animations.Work:Stop()
    end
    if self.Animations.Break then
        self.Animations.Break:Play()
    end
    -- Sit on bench
end

function Yorick:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Yorick
```

### Quest Giver Script
```lua
-- Yorick's Quest Data
local YorickQuests = {
    {
        QuestID = "mundane_inconvenience_01",
        Title = "The Mundane Inconvenience",
        Description = "Yorick's tools have been magically transformed!",
        RequiredWords = {"STURDY"}, -- Earth/Striker
        Reward = {Type = "Currency", Amount = 35},
        Dialogue = {
            Start = "Listen kid, I was trying to fix the [Household Item] but some wizard turned my wrench into a [Silly Animal]...",
            Complete = "Good craftsmanship on this word. You'd make a great contractor."
        }
    },
    {
        QuestID = "noisy_neighbor_01",
        Title = "The Annoying Neighbor",
        Description = "The Banshee is at it again. Yorick needs peace and quiet.",
        RequiredWords = {"SILENCE"}, -- Shadow/Defense
        Reward = {Type = "Item", ID = "Sandwich"},
        Dialogue = {
            Start = "I'm trying to take my lunch break, but the Banshee next door keeps screaming about her [Abstract Noun]...",
            Complete = "*thumbs up* Finally. *takes bite of sandwich*"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns at correct location (Soma District, border area)
- [ ] Skeleton appearance is correct (no glowing eyes)
- [ ] Safety vest is visible and orange
- [ ] Holding broom or clipboard
- [ ] Idle animation plays (leaning, sighing)
- [ ] Work animation shows sweeping motions
- [ ] Takes mandatory 15-minute break periodically
- [ ] Dialogue triggers when player gets close
- [ ] Different dialogue for each time phase
- [ ] Unbothered demeanor during Night/Combat

---

## Part 6: Optimization Tips

1. **Skeleton Bundle** - Use the built-in Roblox Skeleton
2. **Simple Animations** - Most can be reused from other NPCs
3. **Broom Attachment** - Use Roblox attachment system for holding items
4. **Work Timer** - Simple loop for work/break cycle

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
