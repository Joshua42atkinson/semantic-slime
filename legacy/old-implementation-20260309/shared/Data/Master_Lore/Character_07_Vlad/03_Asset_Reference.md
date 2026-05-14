# Vlad - Asset & Visual Reference

## Character Summary
| Field | Value |
|-------|-------|
| **ID** | NPC_07 |
| **Name** | Vlad |
| **Monster Type** | Vampire |
| **Archetype** | The Lover |
| **District** | Heartwood Grove |
| **Difficulty** | Easy |

---

## Visual Elements Checklist

### Body Parts
- [ ] R15 standard rig (slim build)
- [ ] Pale/ghostly white skin
- [ ] Classic vampire fangs
- [ ] Emotionally expressive face (not evil)

### Clothing
- [ ] Puffy white poet's shirt
- [ ] Dark velvet vest
- [ ] Black cape with red collar
- [ ] Gothic romantic style

### Accessories
- [ ] Heart-shaped sunglasses
- [ ] Red rose OR quill OR parasol
- [ ] Optional: Poetry notebook

### Colors
| Element | Color | Hex Code |
|---------|-------|----------|
| Skin | Ghostly Pale | #DCDCDC |
| Shirt | White | #FFFFFF |
| Vest | Dark Purple | #4B0082 |
| Cape | Black | #141414 |
| Collar | Deep Red | #8B0000 |
| Rose | Red | #FF0000 |
| Sunglasses | Black | #000000 |

---

## Lore Trinity Data

### Isomorphism (LoreDB.lua)
```lua
NPCs.Vlad = {
    PreferredElement = {"Water"},
    PreferredClass = {"Support"},
    QuestType = "Relationship"
}
```

**Friendship Bonus:** 1.2x when bringing Water/Support Etymons

### Learning (Teaches)
- Roots: phil-, amat-, path-
- Suffixes: -ous, -ly

---

## Animation IDs (To Be Created)

| Animation | Asset ID | Status |
|-----------|----------|--------|
| Idle (Swoon) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Walk (Float) | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Swoon | rbxassetid://xxxxxxxxxx | 🔲 To Create |
| Write Poetry | rbxassetid://xxxxxxxxxx | 🔲 Optional |

---

## Sound Effects (Optional)

| Sound | Description | Recommended |
|-------|-------------|-------------|
| Voice | Dramatic, melodramatic | Theatrical |
| Swooning | Dramatic sigh | Theatrical |
| Cape | Flowing fabric | Whoosh |

---

## Dialogue Quick Reference

### Dawn
- "The sun rises, cruel and bright!"

### Day
- "The Slime Synthesizer hums with love!"

### Dusk
- "The twilight brings melancholy!"

### Night
- "The Static approaches! Defend the poetry!"

---

## Quest Reference

### Quest 1: The Tragic Sonnet
- **Type:** Poetry/Inspiration
- **Required:** Water + Support word
- **Example:** WEEPING

### Quest 2: The Misunderstood Gift
- **Type:** Relationship/Charisma
- **Required:** High Charisma word
- **Example:** CHARMING

---

## Spawn Data
```
Location: Heartwood Grove - Under giant glowing flowers
Position: X: 150, Y: 0, Z: 200 (example)
Behavior: Float, write poetry, admire beauty
```

---

## Related Characters
- **Friends:** All town residents (tries to set everyone up)
- **Neighbor:** Barnaby (in Heartwood Grove)
- **Interest:** Martha (tries to give gifts)

---

## Unique Behaviors
- **Melodramatic:** Everything is a grand tragedy or romance
- **Poetry:** Constantly writing terrible poems
- **Matchmaker:** Tries to set up all characters
- **1.2x FP:** Water/Support Etymons

---

## Fun Quotes
- "You have the soul of a poet!"
- "Defend the poetry, Weaver!"
- "It's beautiful. Simply beautiful."
- "I shall dedicate my next interpretive dance to you!"

---

*Asset Reference Created: February 2026*
