# Chesty - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Easy to Moderate | **Time Estimate:** 35-50 minutes | **Cost:** ~250-450 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Custom Assembly (No Standard Rig)
Since Chesty is a treasure chest, build directly with parts:
1. Open Roblox Studio
2. Create a Model named "Chesty_NPC"
3. Build using primitive parts

### Step 2: The Chest Body
```
CREATE > Part > Block (Main Body)
├── Name: "ChestBody"
├── Size: 2, 1.5, 1
├── Position: Center
└── Color: Wood Brown (RGB: 139, 69, 19)

CREATE > Part > Block (Lid - separate for animation)
├── Name: "ChestLid"
├── Size: 2, 0.5, 1
├── Position: Top of body
└── Color: Wood Brown

CREATE > Part > Block (Iron Bands)
├── Name: "BandHorizontal"
├── Size: 2.1, 0.2, 1.05
├── Position: Middle of body
└── Color: Dark Grey (RGB: 64, 64, 64)

CREATE > Part > Block (Band Vertical)
├── Size: 0.2, 1.5, 1.05
├── Position: Center
└── Color: Dark Grey
```

---

## Part 2: The Goofy Face (When Open)

### When Lid Opens
```
Inside the chest (visible when open):

CREATE > Part > Sphere (Left Eye)
├── Name: "GooglyEyeLeft"
├── Size: 0.6, 0.6, 0.3
├── Position: Inside lid, left side
├── Material: Neon
└── Color: White

CREATE > Part > Sphere (Pupil Left)
├── Name: "PupilLeft"
├── Size: 0.3, 0.3, 0.1
├── Position: Forward from eye
└── Color: Black

CREATE > Part > Sphere (Right Eye)
├── Name: "GooglyEyeRight"
├── Size: 0.6, 0.6, 0.3
├── Position: Inside lid, right side
├── Material: Neon
└── Color: White

CREATE > Part > Sphere (Pupil Right)
├── Name: "PupilRight"
├── Size: 0.3, 0.3, 0.1
└── Position: Forward from eye

CREATE > Part > Block (Teeth)
├── Name: "Teeth"
├── Size: 1.5, 0.3, 0.3
├── Position: Below eyes
└── Color: White (piano key pattern)

CREATE > Part > Part (Tongue)
├── Name: "Tongue"
├── Size: 0.8, 0.6, 0.3
├── Position: Hanging out below teeth
├── Material: SmoothPlastic
└── Color: Purple (RGB: 128, 0, 128)
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle (Closed) Animation
```
Keyframes:
1. Start: Completely still (like a prop)
2. Slight wobble occasionally
3. Loop

Expression: Looks like normal treasure chest
```

#### Open Animation (Triggered)
```
Keyframes:
1. Lid springs open suddenly
2. Googly eyes appear
3. Tongue flops out
4. Confetti bursts
5. Eyes look around wildly

Trigger: Player interaction
```

#### Walk/Hop Animation
```
Keyframes:
1. Chest hops up slightly
2. Lands with "ka-chunk" sound
3. Repeat
4. Lid rattles

Timing: Comedic, bouncy
```

---

## Part 4: Script Implementation

### Chesty NPC Script
```lua
-- Chesty NPC Controller
-- Place in NPC Model

local Chesty = {}
Chesty.__index = Chesty

function Chesty.new(npc)
    local self = setmetatable({}, Chesty)
    self.NPC = npc
    self.CurrentPhase = "Dawn"
    self.IsOpen = false
    self.CurrentLocation = Vector3.new(0, 0, 0)
    
    -- Data from LoreDB
    self.PreferredElement = {"Air", "Shadow"}
    self.PreferredClass = {"Striker"}
    self.QuestType = "Prank"
    
    -- Start behaviors
    self:StartDialogueSystem()
    self:RandomizeLocation()
    
    return self
end

function Chesty:StartDialogueSystem()
    local function onTouch(otherPart)
        local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
        if player then
            self:Interact(player)
        end
    end
    
    local detector = Instance.new("Part")
    detector.Name = "DialogueDetector"
    detector.Size = Vector3.new(5, 5, 5)
    detector.Anchored = false
    detector.CanCollide = false
    detector.Transparency = 1
    detector.Parent = self.NPC
    detector.Touched:Connect(onTouch)
end

function Chesty:Interact(player)
    -- Open chest animation
    self:OpenChest()
    -- Show dialogue
    self:TriggerDialogue(player)
    -- Close after delay
    task.delay(5, function()
        self:CloseChest()
    end)
end

function Chesty:OpenChest()
    self.IsOpen = true
    -- Animate lid opening
    -- Play confetti particles
    -- Show googly eyes
end

function Chesty:CloseChest()
    self.IsOpen = false
    -- Animate lid closing
    -- Hide face
end

function Chesty:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "Ding ding! The daily reset! Quick, grab those letters before the server sweeps them up!",
            "New day, new location! Did you find me yet? I'm a tricky little chest!",
            "The game has respawned! Time for a fresh batch of chaos!"
        },
        Day = {
            "The Slime Synthesizer is just a giant blender, change my mind. Toss those vowels in and see what explodes!",
            "Words are just LEGO blocks for adults! Build something silly!",
            "Hehehe, want to cause some chaos later? I've got IDEAS!"
        },
        Dusk = {
            "Sun's going down! Time for the serious NPCs to hand out boring chores. Come to me for the actual fun stuff!",
            "Psst! Want to pull a prank? I've got a great bit planned!",
            "The golden hour of tomfoolery is upon us! Let's cause some harmless trouble!"
        },
        Night = {
            "Uh oh, The Static is here! I am just a normal, boring box! Nothing to see here!",
            "The humorless blobs are here! They're such buzzkills!",
            "I'm going into hiding! Pretend I'm just decor! Good luck, partner!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Chesty says: " .. chosenDialogue)
end

function Chesty:RandomizeLocation()
    -- At Dawn, move to random location in Town Hub
    task.spawn(function()
        while true do
            task.wait()
            if self.CurrentPhase == "Dawn" then
                -- Pick random spot in Town Hub area
                local randomX = math.random(-50, 50)
                local randomZ = math.random(-50, 50)
                self.CurrentLocation = Vector3.new(randomX, 0, randomZ)
                -- Teleport NPC
            end
        end
    end)
end

function Chesty:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Chesty
```

### Quest Giver Script
```lua
-- Chesty's Quest Data
local ChestyQuests = {
    {
        QuestID = "switcheroo_01",
        Title = "The Ol' Switcheroo",
        Description: "Prank Yorick with an illusion!",
        RequiredWords = {"ILLUSORY"}, -- Shadow/Support
        Reward = {Type = "Currency", Amount = 45},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "Let's replace Yorick's [Tool] with a fake!",
            Complete = "He's going to be so confused!"
        }
    },
    {
        QuestID = "sneak_attack_01",
        Title = "The Sneak Attack",
        Description: "Prank Kael with speed!",
        RequiredWords = {"SNEAKY"}, -- High Speed
        Reward = {Type = "Item", ID = "Confetti"},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "Kael needs a scare! I need speed!",
            Complete = "Bullseye! Best prank ever!"
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns in Town Hub area
- [ ] Looks like normal treasure chest when closed
- [ ] Lid opens on interaction
- [ ] Googly eyes visible inside
- [ ] Purple tongue lolls out
- [ ] Confetti particles on open
- [ ] Hop animation works
- [ ] Random location each Dawn
- [ ] Dialogue triggers properly
- [ ] Prank quests work

---

## Part 6: Optimization Tips

1. **Confetti Particles** - Use particle emitter for celebration effect
2. **Sound Effects** - Add "ka-chunk" sounds for hopping
3. **Random Spawn** - Use table of predefined Town Hub locations

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
