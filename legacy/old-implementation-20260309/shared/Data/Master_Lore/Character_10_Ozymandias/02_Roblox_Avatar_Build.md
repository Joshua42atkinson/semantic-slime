# Ozymandias - Roblox Avatar Build Guide

## Quick Build Summary
**Difficulty:** Easy to Moderate | **Time Estimate:** 40-55 minutes | **Cost:** ~300-500 Robux (optional)

---

## Part 1: Body Setup

### Step 1: Base Rig
1. Open Roblox Studio
2. Insert quadruped cat model (Roblox cat bundle or build with parts)
3. Name it "Ozymandias_NPC"
4. Scale to be small (0.6x player height)

### Step 2: The Blindfold
```
CREATE > Part > Block
├── Name: "Blindfold"
├── Size: 0.6, 0.2, 0.1
├── Position: Over eyes
├── Color: Off-white/Parchment (RGB: 240, 230, 140)
└── Note: Frayed edges for dictionary page look
```

---

## Part 2: Special Features

### Floating Book
```
CREATE > Part > Block (Pages)
├── Name: "BookPages"
├── Size: 1.5, 1.8, 0.3
├── Position: Floating in front of cat
├── Color: White
└── Transparency: 0.3

CREATE > Part > Block (Cover)
├── Name: "BookCover"
├── Size: 1.6, 1.9, 0.1
├── Position: Behind pages
└── Color: Dark Brown

ADD: ParticleEmitter (Magical glow around book)
```

### Runic Text on Fur (Optional)
```
Use Scrolling Texture on body parts:
- Glowing runic symbols
- Light blue/white color
- Slowly scrolling across fur
```

### Wisdom Aura
```
CREATE > Part > Sphere (Transparency)
├── Name: "WisdomAura"
├── Size: 3, 3, 3
├── Position: Surrounding cat
├── Material: Neon
├── Color: Light Blue
└── Transparency: 0.8
```

---

## Part 3: Animation Setup

### Creating Animations (Animation Editor Plugin)

#### Idle Animation
```
Keyframes:
1. Start: Sit regal and still
2. 0.5s: Gentle purring (slight chest movement)
3. 1.0s: Tail swishing
4. 1.5s: Occasional blink (if blindfold moves)
5. 2.0s: Loop

Expression: Wise, calm, mysterious
```

#### Walk Animation
```
Keyframes:
1. Slow, hesitant steps
2. Pause to " sniff" air
3. Maybe bump into invisible obstacle
4. Recover gracefully
5. Overall: Clumsy but dignified

Timing: Slow and deliberate
```

#### Grooming Animation
```
Keyframes:
1. Lift paw
2. Lick paw
3. Smooth down fur
4. Continue conversation

Trigger: Randomly during dialogue
```

---

## Part 4: Script Implementation

### Ozymandias NPC Script
```lua
-- Ozymandias NPC Controller
-- Place in NPC Model

local Ozymandias = {}
Ozymandias.__index = Ozymandias

function Ozymandias.new(npc)
    local self = setmetatable({}, Ozymandias)
    self.NPC = npc
    self.CurrentPhase = "Dawn"
    
    -- Data from LoreDB
    self.PreferredElement = {"Light", "Air"}
    self.PreferredClass = {"Support", "Mage"}
    self.QuestType = "Riddle"
    
    -- Load animations
    self.Animations = {
        Idle = self:LoadAnimation("rbxassetid://YOUR_IDLE_ANIM_ID"),
        Walk = self:LoadAnimation("rbxassetid://YOUR_WALK_ANIM_ID"),
        Groom = self:LoadAnimation("rbxassetid://YOUR_GROOM_ANIM_ID")
    }
    
    -- Start behaviors
    self:StartDialogueSystem()
    
    return self
end

function Ozymandias:LoadAnimation(assetId)
    local anim = Instance.new("Animation")
    anim.AnimationId = assetId
    return self.AnimationController:LoadAnimation(anim)
end

function Ozymandias:StartDialogueSystem()
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

function Ozymandias:TriggerDialogue(player)
    local dialogues = {
        Dawn = {
            "I cannot see the sun, Weaver, but I feel the weight of new vocabulary falling upon the grass. Gather the letters; the day demands meaning.",
            "The dawn breaks like a new paragraph in the story of existence. What words shall we write today?",
            "Ah, the reset. The universe folds upon itself and begins again."
        },
        Day = {
            "The Slime Synthesizer sings a song of creation. Can you hear the consonants colliding? It is the sound of order.",
            "Words are living things, Weaver. Treat them with respect. Would you handle a butterfly with care?",
            "The Synthesizer hums with potential. What shall you forge from the chaos?"
        },
        Dusk = {
            "The light fades, and the world grows ambiguous. Come to me. Let us test your mind before the Static attempts to erase it.",
            "The twilight brings questions. I have one for you. What walks on four legs at dawn, two at noon, and three at dusk?",
            "The shadows lengthen. The Static draws near. But first, a riddle. Are you ready?"
        },
        Night = {
            "The Typos approach! They are the void of meaning! Strike them with your most articulate Etymons!",
            "The enemies of meaning are here! They wish to erase all wisdom! Defend the truth, Weaver!",
            "I cannot see them, but I feel their emptiness. They are the absence of definition. FIGHT!"
        }
    }
    
    local phaseDialogues = dialogues[self.CurrentPhase]
    local chosenDialogue = phaseDialogues[math.random(#phaseDialogues)]
    
    print("Ozymandias speaks: " .. chosenDialogue)
end

function Ozymandias:SetPhase(phaseName)
    self.CurrentPhase = phaseName
end

return Ozymandias
```

### Quest Giver Script (Riddle System)
```lua
-- Ozymandias's Quest Data (Riddles)
local OzyQuests = {
    {
        QuestID = "classic_riddle_01",
        Title = "The Classic Riddle",
        Description: "Ozymandias presents a riddle about sight and meaning",
        RequiredWords = {"FORESIGHT"}, -- Light/Mage
        Reward = {Type = "Currency", Amount = 60},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "What has a [Noun] but no [Noun], and holds the [Abstract Concept] in its grasp?",
            Correct = "Correct. You see clearly, even in the encroaching dusk."
        }
    },
    {
        QuestID = "abstract_concept_01",
        Title = "The Abstract Mystery",
        Description: "Ozymandias asks about an abstract concept",
        RequiredWords = {"BRILLIANCE"}, -- High Accuracy
        Reward = {Type = "Item", ID = "WisdomTome"},
        RewardBonus = {Type = "FriendshipPoints", Multiplier = 1.2},
        Dialogue = {
            Start = "I am lighter than the [Element], yet no giant can hold me long. I am the enemy of [Plural Noun]. What am I?",
            Correct = "Ah, the sweet warmth of comprehension. Well done."
        }
    }
}
```

---

## Part 5: Testing Checklist

- [ ] NPC spawns in The Brainy Borough
- [ ] Cat model is small compared to other NPCs
- [ ] Blindfold visible over eyes
- [ ] Floating book hovers in front
- [ ] Wisdom aura surrounds cat
- [ ] Runic text scrolls across fur (optional)
- [ ] Idle animation is calm and regal
- [ ] Walk is hesitant and clumsy
- [ ] Dialogue is riddle/philosophical
- [ ] Riddle quests work

---

## Part 6: Optimization Tips

1. **Floating Book** - Use BodyVelocity or Constraints for hovering
2. **Runic Text** - Use ScrollingTexture for simplicity
3. **Wisdom Aura** - Use low transparency Sphere with Neon material

---

*Avatar Build Guide Created: February 2026*
*For: Syllable Springs Roblox Project*
