# Ignis - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_12 |
| **Name** | Ignis |
| **Monster Type** | Red Dragon |
| **Archetype** | The Ruler |
| **District** | Town Hub (Mayor) |
| **Difficulty** | Moderate to Hard |

---

## Visual Elements Checklist

### Body Parts
- [ ] Dragon body (red scales)
- [ ] Blocky dragon snout
- [ ] Small horns
- [ ] Slightly larger than Kael

### Face
- [ ] Tiny reading glasses on nose
- [ ] Wire-rimmed glasses

### Outfit
- [ ] Red and gold "MAYOR" sash
- [ ] Tiny formal necktie

### Accessories
- [ ] Giant wooden clipboard
- [ ] Oversized fountain pen

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Scales | Dragon Red | #B41E1E |
| Horns | Dark Red | #5C1A1A |
| Sash | Red/Gold | #B41E1E/#FFD700 |
| Glasses | Light Blue | #ADD8E6 |
| Tie | Dark Red | #8B0000 |
| Clipboard | Brown | #8B4513 |
| Pen | Black/Gold | #000000/#FFD700 |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Ignis = {
    PreferredElement = {"Earth", "Fire"},
    PreferredClass = {"Tank", "Builder"},
    QuestType = "Civic Duty"
}
```

**Friendship Bonus:** 1.2x when bringing Earth/Fire or Tank/Builder Etymons

### Learning (Teaches)
- Suffixes: -cracy, -archy
- Roots: reg-, struct-, meter, ordin-

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Check) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Walk (Stomp) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Wave (Clipboard) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Smoke Puff | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Dialogue Quick Reference

### Dawn
- "Crystals have spawned on schedule!"

### Day
- "Class-A permit required!"

### Dusk
- "Three clipboards of municipal errors!"

### Night
- "Noise ordinance violations!"

---

## Quest Reference

### Quest 1: The Code Violation
- **Type:** Containment/Lockdown
- **Required:** Earth + Tank word
- **Example:** SECURE

### Quest 2: The Broken Infrastructure
- **Type:** Repair/Health
- **Required:** High Health word
- **Example:** RESTORE

---

## Spawn Data
```
Location: Town Hub - Right next to Slime Synthesizer
Position: X: 0, Y: 0, Z: 0 (central)
Behavior: Patrol, issue citations, delegate tasks
```

---

## Related Characters
- **Neighbor:** Kael (near Synthesizer)
- **Employee:** Player (delegated tasks)
- **Enemy:** The Static (anarchy)

---

## Unique Behaviors
- **Mayoral:** Acts as town mayor
- **Citations:** Issues rule violations
- **Clipboard:** Always checking things off
- **1.2x FP:** Earth/Fire or Tank/Builder words

---

## Fun Quotes
- "Form 27-B required!"
- "Total anarchy!"
- "The filing system is under attack!"
- "Improper Suffix Conjugation!"

---

*Asset Reference Created: February 2026*
