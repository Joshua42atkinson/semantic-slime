# Gamification & Cognitive Load in Education

## Overview
Gamification in using game design principles to drive **intrinsic motivation** and **deep learning**.

## Core Principles

### 1. Goal Alignment
- Game mechanics must *be* the learning mechanism (VaaM).
- **Success in Game = Mastery of Subject.**

## VaaM: Code Implementation Pattern

How to represent "Vocabulary as a Mechanic" in Luau.

### The Word Object
Every word is an object with "Physics" properties based on psycholinguistics.

```lua
-- src/shared/Data/WordDatabase.lua
export type WordStats = {
    Mass: number,       -- Complexity (Cognitive Load)
    Velocity: number,   -- Urgency (How fast must it be answered?)
    Valence: number,    -- Emotional charge (Positive/Negative)
}

local WordDatabase = {
    ["ephemeral"] = {
        Mass = 8.5,     -- Heavy concept, requires high "Engine Power" (Intelligence)
        Velocity = 2.0, -- Slow, contemplative
        Valence = 0.5,  -- Neutral/Melancholy
    },
    ["run"] = {
        Mass = 1.0,     -- Light concept
        Velocity = 9.0, -- Fast action
        Valence = 0.8,  -- Active
    }
}

return WordDatabase
```

### The Weigh Station (Cognitive Load Check)
Before a player accepts a quest, we weigh their "Cargo" capacity against the "Mass" of the lesson.

```lua
function WeighStation:CanAcceptQuest(player, questId)
    local playerCapacity = PlayerStats:GetCognitiveCapacity(player)
    local questMass = QuestData:GetTotalMass(questId)
    
    if questMass > playerCapacity then
        return false, "Overload Warning: This lesson is too heavy for your current engine."
    end
    return true
end
```

## Best Practices
- **Visual Feedback**: When `Mass` is high, the player's movement should visibly slow down (simulating mental effort).
- **Flow State**: Match `QuestMass` to `PlayerCapacity` to keep them in the Flow Channel.
