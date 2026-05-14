# Chesty - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_09 |
| **Name** | Chesty |
| **Monster Type** | Mimic (Treasure Chest) |
| **Archetype** | The Jester |
| **District** | Town Hub (Randomizes daily) |
| **Difficulty** | Easy to Moderate |

---

## Visual Elements Checklist

### Body Parts
- [ ] Classic rounded-top treasure chest shape
- [ ] Wooden body with iron bands
- [ ] Animated lid (opens/closes)

### Face (When Open)
- [ ] Giant googly eyes (white with moving pupils)
- [ ] Piano-key teeth
- [ ] Purple tongue lolling out

### Effects
- [ ] Confetti burst on open
- [ ] Optional: Sparkle effects

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Wood | Brown | #8B4513 |
| Iron Bands | Dark Grey | #404040 |
| Tongue | Purple | #800080 |
| Eyes | White/Neon | #FFFFFF |
| Confetti | Multi | Various |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Chesty = {
    PreferredElement = {"Air", "Shadow"},
    PreferredClass = {"Striker"},
    QuestType = "Prank"
}
```

**Friendship Bonus:** 1.2x when bringing Air/Shadow or Striker Etymons

### Learning (Teaches)
- Suffixes: -ish, -esque
- Prefixes: pseudo-, quasi-

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Closed) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Open | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Hop (Walk) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Close | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Dialogue Quick Reference

### Dawn
- "Ding ding! Daily reset!"

### Day
- "Words are just LEGO blocks!"

### Dusk
- "Want to pull a prank?"

### Night
- "I'm just a normal box!"

---

## Quest Reference

### Quest 1: The Ol' Switcheroo
- **Type:** Illusion/Prank
- **Required:** Shadow + Support word
- **Example:** ILLUSORY

### Quest 2: The Sneak Attack
- **Type:** Speed/Agility
- **Required:** High Speed word
- **Example:** SNEAKY

---

## Spawn Data
```
Location: Town Hub (randomizes daily)
Dawn: New random location chosen
Can be: Near Synthesizer, in bushes, etc.
Behavior: Hop around, cause chaos
```

---

## Related Characters
- **Friends:** Player (partner in crime)
- **Targets:** Yorick, Kael, Martha (prank victims)
- **Enemy:** The Static (no humor)

---

## Unique Behaviors
- **Random Spawn:** Different location each day
- **Open/Close:** Springs open on interaction
- **Prank Quests:** Causes harmless chaos
- **1.2x FP:** Air/Shadow or Striker words

---

## Fun Quotes
- "Best prank ever!"
- "I'm just decor!"
- "Zero sense of comedic timing!"
- "Lives for the bit!"

---

*Asset Reference Created: February 2026*
