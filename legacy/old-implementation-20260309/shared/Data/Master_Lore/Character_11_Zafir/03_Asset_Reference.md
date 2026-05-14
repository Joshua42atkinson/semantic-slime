# Zafir - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_11 |
| **Name** | Zafir |
| **Monster Type** | Djinn (Genie) |
| **Archetype** | The Magician |
| **District** | Whisper Winds |
| **Difficulty** | Moderate |

---

## Visual Elements Checklist

### Body Parts
- [ ] Modified R15 (no legs)
- [ ] Genie tail instead of legs
- [ ] Swirling tornado/smoke cone

### Head & Face
- [ ] Grinning, mischievous face
- [ ] Glowing colorful turban
- [ ] Ornate headpiece with gems

### Outfit
- [ ] Bright purple silks
- [ ] Gold trim
- [ ] Emerald green sash

### Accessories
- [ ] Magic orbs (3-4, juggling)
- [ ] Sparkle trail particles

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Turban | Deep Purple | #4B0082 |
| Silks | Purple | #800080 |
| Trim | Gold | #FFD700 |
| Sash | Emerald | #32CD32 |
| Orbs | Multi (Fire/Air/Gold) | Various |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Zafir = {
    PreferredElement = {"Fire", "Air"},
    PreferredClass = {"Mage", "Striker"},
    QuestType = "Magical Mishap"
}
```

**Friendship Bonus:** 1.2x when bringing Fire/Air or Mage/Striker Etymons

### Learning (Teaches)
- Prefixes: trans-, meta-, hyper-
- Suffixes: -fy, -ize

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Juggle) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Float (Hover) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Cast (Magic) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Accident | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Dialogue Quick Reference

### Dawn
- "The server refreshes!"

### Day
- "Magical particle accelerator!"

### Dusk
- "Don't be mad! ...I may have accidentally..."

### Night
- "Failed magical formulas!"

---

## Quest Reference

### Quest 1: The Transmuted Object
- **Type:** Counter-spell/Ground
- **Required:** Earth + Mage word
- **Example:** PETRIFY

### Quest 2: The Runaway Spell
- **Type:** Containment/Defense
- **Required:** High Defense word
- **Example:** CONTAINMENT

---

## Spawn Data
```
Location: Whisper Winds - Near highest windmills
Position: X: 100, Y: 50, Z: 300 (high altitude)
Behavior: Float, experiment, cause chaos
```

---

## Related Characters
- **Friends:** Martha (neighbor in Whisper Winds)
- **Lab Assistant:** Player
- **Enemy:** The Static (failed spells)

---

## Unique Behaviors
- **Magical Accidents:** Constantly messes things up
- **Floating:** Never touches ground
- **Juggling:** Always juggling orbs
- **1.2x FP:** Fire/Air or Mage/Striker words

---

## Fun Quotes
- "What happens if I combine 'ultra' with 'explosion'?"
- "Don't be mad!"
- "Counter-morphogenesis!"
- "Science prevails again!"

---

*Asset Reference Created: February 2026*
