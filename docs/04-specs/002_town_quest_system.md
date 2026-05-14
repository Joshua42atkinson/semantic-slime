# Spec: Town & Quest System (Lexical Legends)

**Created:** 2026-02-18
**Status:** DRAFT

## 1. Overview
**Goal:** Establish the core loop of "Talk to NPC -> Get Quest -> Find Word -> Complete Quest".
**User Story:** As a player, I want to explore the town, meet NPCs, and undertake quests that require me to find and understand specific words, so that I can build my vocabulary arsenal.

## 2. Architecture

### Data Structures
#### QuestData
```lua
{
    Id = "quest_001_welcome",
    Title = "Welcome to the Iron Network",
    Description = "Speak to Pete at the Station.",
    Steps = {
        {
            Id = "speak_pete",
            Description = "Find Pete.",
            Type = "Talk", -- | "Collect" | "Location"
            TargetId = "npc_pete", -- | "word_precarious" | "loc_station"
            IsComplete = false
        }
    },
    Rewards = {
        XP = 100,
        Words = { "initiate" }
    }
}
```

#### NpcData
```lua
{
    Id = "npc_pete",
    Name = "Pete (Station Master)",
    Model = "rbxassetid://...", -- or workspace name
    Dialogues = {
        {
            Id = "intro",
            Text = "Welcome, Traveler. The rails are silent today.",
            Options = {
                { Text = "Who are you?", Next = "role_desc" },
                { Text = "I'm looking for work.", Quest = "quest_001_welcome" }
            }
        }
    }
}
```

### Services (Server)
- **QuestService**: Manages player quest state (Active, Completed, Failed).
    - `AcceptQuest(player, questId)`
    - `CompleteStep(player, questId, stepId)`
    - `GetPlayerQuests(player)`
- **NpcService**: Handles dialogue flow and triggers.
    - `Interact(player, npcId)` -> Returns current dialogue node.

### Controllers (Client)
- **QuestController**: Renders the Quest Log HUD.
- **InteractionController**: Detects proximity to NPCs, handles "E to Interact", and renders Dialogue UI.

### Network
- `RemoteFunction: InteractWithNpc(npcId)` -> `DialogueData`
- `RemoteEvent: QuestUpdated(questData)`
- `RemoteEvent: QuestCompleted(questId, rewards)`

## 3. Implementation Details

### The "Pokemon with Words" Mechanic
- **Words as Entities**: Words are not just strings; they are collectibles.
- **Collection**: Finding a "Word Orb" adds the word to the player's `WordInventory`.
- **Quest Requirement**: "Bring me the word 'Precarious'." -> Player must have {Id="precarious"} in inventory.

### VaaM Integration
- **WordService** (separate spec later) will handle the `WordInventory`.
- `QuestService` will check `WordService:HasWord(player, wordId)` for "Collect" type steps.

## 4. Acceptance Criteria
- [ ] Player can walk up to an NPC (e.g., Pete) and see an interaction prompt.
- [ ] Interacting opens a Dialogue UI.
- [ ] Selecting a specific dialogue option adds a Quest to the player's Quest Log.
- [ ] Quest Log displays the active quest and its current step.
- [ ] Completing the step (debug/simulated) updates the UI and grants rewards.
