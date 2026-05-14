# Pygmalion - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_08 |
| **Name** | Pygmalion (Pyg) |
| **Monster Type** | Frost-Clay Golem |
| **Archetype** | The Creator |
| **District** | 8 Winter Street (Border of Brainy Borough & Heartwood Grove) |
| **Difficulty** | Moderate |

---

## Visual Elements Checklist

### Body Parts
- [ ] R15 standard rig (1.5x scale - massive)
- [ ] Frost-covered clay body (grey)
- [ ] Glowing blue crystal eyes
- [ ] Blocky golem head

### Clothing
- [ ] Paint-splattered blacksmith's apron
- [ ] Tools in apron pockets

### Accessories
- [ ] Large wooden mallet (on back)
- [ ] Giant chisel (on back)
- [ ] Hovering snowflake (above head)
- [ ] Snow particles falling

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Body | Grey/Clay | #808080 |
| Eyes | Glowing Blue | #00BFFF |
| Apron | Brown | #8B4513 |
| Snowflake | Light Blue | #ADD8E6 |
| Snow | White | #FFFFFF |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Pygmalion = {
    PreferredElement = {"Earth", "Water/Ice"},
    PreferredClass = {"Tank", "Builder"},
    QuestType = "Crafting"
}
```

**Friendship Bonus:** 1.2x when bringing Earth/Tank or Builder Etymons

### Learning (Teaches)
- Roots: struct-, form-, morph-
- Suffixes: -ify, -ize

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Frame) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Walk (Heavy) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Sculpt | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Smash | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Dialogue Quick Reference

### Dawn
- "The canvas resets! Fresh, uncarved letters!"

### Day
- "No mistakes in word-crafting, only happy little accidents!"

### Dusk
- "The sculpture is missing its final piece!"

### Night
- "The Static has no appreciation for form!"

---

## Quest Reference

### Quest 1: The Melting Masterpiece
- **Type:** Structural/Foundation
- **Required:** Earth + Tank word
- **Example:** SOLIDIFY

### Quest 2: The Missing Hue
- **Type:** Artistic/Charisma
- **Required:** High Charisma word
- **Example:** DAZZLING

---

## Spawn Data
```
Location: 8 Winter Street (Border of Brainy Borough & Heartwood Grove)
Position: X: 250, Y: 0, Z: 200 (example)
Behavior: Sculpt, paint, destroy own work
Environment: Always snowing
```

---

## Related Characters
- **Neighbors:** Gribble (Brainy Borough), Barnaby (Heartwood Grove)
- **Friends:** Artists, creative characters

---

## Unique Behaviors
- **Perfectionist:** Constantly destroys own work
- **"Vibes":** Judges everything by aesthetics
- **Snow:** Always snowing at 8 Winter Street
- **1.2x FP:** Earth/Tank or Builder Etymons

---

## Fun Quotes
- "The vibes are... off."
- "Beautiful failure!"
- "Only happy little grammatical accidents!"
- "Defend the gallery!"

---

*Asset Reference Created: February 2026*
