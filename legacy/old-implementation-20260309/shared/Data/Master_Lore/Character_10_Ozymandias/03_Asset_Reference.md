# Ozymandias - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_10 |
| **Name** | Ozymandias (Ozy) |
| **Monster Type** | Blind House Cat |
| **Archetype** | The Sage |
| **District** | The Brainy Borough |
| **Difficulty** | Easy to Moderate |

---

## Visual Elements Checklist

### Body Parts
- [ ] Quadruped cat model (small)
- [ ] Scruffy fur appearance
- [ ] Tiny blindfold over eyes
- [ ] Frayed dictionary page blindfold

### Special Features
- [ ] Floating book (hovers in front)
- [ ] Wisdom aura (surrounds cat)
- [ ] Runic text on fur (optional)

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Fur | Grey/Scruffy | #808080 |
| Blindfold | Parchment | #F0E68C |
| Book | Dark Brown | #8B4513 |
| Aura | Light Blue | #ADD8E6 |
| Runes | Glowing Blue | #00BFFF |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Ozymandias = {
    PreferredElement = {"Light", "Air"},
    PreferredClass = {"Support", "Mage"},
    QuestType = "Riddle"
}
```

**Friendship Bonus:** 1.2x when bringing Light/Air or Support/Mage Etymons

### Learning (Teaches)
- Roots: vis-, vid-, cogn-, scient-
- Suffixes: -ology, omni-

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Purr) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Walk (Clumsy) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Groom | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Bump | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Dialogue Quick Reference

### Dawn
- "I feel new vocabulary falling upon the grass."

### Day
- "The Synthesizer sings a song of creation."

### Dusk
- "Let us test your mind before the Static erases it."

### Night
- "The Typos are the void of meaning!"

---

## Quest Reference

### Quest 1: The Classic Riddle
- **Type:** Riddle/Sight
- **Required:** Light + Mage word
- **Example:** FORESIGHT

### Quest 2: The Abstract Mystery
- **Type:** Logic/Accuracy
- **Required:** High Accuracy word
- **Example:** BRILLIANCE

---

## Spawn Data
```
Location: The Brainy Borough - On dictionary stacks
Position: X: 400, Y: 5, Z: 200 (example)
Behavior: Sit regally, wander clumsily, give riddles
```

---

## Related Characters
- **Friends:** Gribble (neighbor in Brainy Borough)
- **Student:** Player
- **Enemy:** The Static (blank space)

---

## Unique Behaviors
- **Speaks in Riddles:** Exclusive riddle-speak
- **Blind:** Bumps into things constantly
- **Riddle Quests:** Classic puzzles as quests
- **1.2x FP:** Light/Air or Support/Mage words

---

## Fun Quotes
- "What walks on four legs at dawn...?"
- "You see clearly, even in the encroaching dusk."
- "They are the absence of definition."
- "Testing the morphological properties of gravity."

---

*Asset Reference Created: February 2026*
