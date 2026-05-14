# Character Profile: Pygmalion (Pyg)

## Basic Information
- **Character Number:** 08
- **Name:** Pygmalion (called "Pyg" by friends)
- **Monster Type:** Frost-Clay Golem
- **Jungian Archetype:** The Creator (Innovative, artistic, visionary, desires to create things of enduring value, fears producing mediocre or unoriginal work)
- **Location:** 8 Winter Street (Border of The Brainy Borough and Heartwood Grove) - Open-air art studio
- **Ease of Build:** Moderate

---

## Lore & Personality

Pygmalion is a massive, gentle giant made of enchanted, frost-covered clay. While other monsters are out fighting or studying, Pygmalion is at his studio at 8 Winter St., obsessively trying to sculpt the perfect masterpiece. He views language not just as a tool or a weapon, but as the ultimate artistic medium.

He is a lovable perfectionist who is constantly starting over. He will build a breathtakingly beautiful ice sculpture of a swan, decide its "vibes are slightly off," and immediately smash it to try again. He treats the player (the Weaver) as a fellow artist and frequently asks for their "creative vision" to help him finish his wild, abstract projects. He is highly critical of The Static (the night enemies) not because they are evil, but because they are "visually uninspired" and "completely lack structural integrity."

### Key Personality Traits
- ✅ Perfectionist artist
- ✅ Constantly starts over
- ✅ Obsessed with "vibes"
- ✅ Treats words as art medium
- ✅ Smash his own work regularly
- ✅ Views player as fellow artist
- ✅ Critical of ugly things (including enemies)

---

## Visual Design Specifications

### Body Type
- **Rig:** R15 standard rig
- **Scale:** 1.5x height and width (bulky, solid)
- **Material:** Frost-covered clay (grey with icy blue accents)
- **Overall Effect:** Massive, gentle, artistic

### Face/Head
- Blocky, golem-like head
- No real mouth - just glowing blue crystal eyes
- Frosted stone texture

### Outfit
- **Apron:** Gigantic paint-splattered blacksmith's apron
- **Tools:** Carving tools, brushes, spare letter crystals in apron pockets
- **Color Palette:** Grey clay, icy blue, paint splatters

### Accessories
- **Mallet:** Large wooden mallet strapped to back
- **Chisel:** Giant chisel strapped to back
- **Snowflake:** Magical perpetually glowing snowflake hovering over head

### Animation Guidelines
- **Idle:** Step back, hold up thumb/index to "frame" player, stroke rocky chin thoughtfully
- **Walk:** Slow, deliberate, heavy steps
- **Create:** Sculpting motions with hands
- **Smash:** Angry destruction of his own work

---

## The Lore Trinity & Data Integration

### 1. Isomorphism (Word = World)

Pygmalion desires words that act as foundational building blocks, bringing stability and form to his art.

**Data Mapping (LoreDB.lua):**
```lua
NPCs.Pygmalion = {
    PreferredElement = {"Earth", "Water/Ice"},  -- Frost, clay, foundation
    PreferredClass = {"Tank", "Builder"},
    QuestType = "Crafting",
    District = "8 Winter Street",
    Teaches = {"struct-", "form-", "-ify", "-ize", "morph-"}
}
```

**Mechanic:** When players bring Pygmalion Earth/Tank or Builder Etymons, they receive a **1.2x Friendship Point bonus**. The literal "weight" and "density" of these words make for better sculpting materials.

### 2. Mechanics (The Cycle of Meaning)

Pygmalion uses the Game Loop phases as a strict artistic schedule.

**Data Mapping:**
- Hooked into `GameLoopService.PhaseChanged`
- Dialogue triggers based on lighting (affects his "aesthetic process")
- During Dusk, MadLibService pulls from his crafting/sculpting quest pool

**Quest Types:**
- Acts as a resource sink
- Asks for specific Etymons to act as "glue," "paint," or "armature" for statues

### 3. Learning (The Hero's Journey)

Pygmalion's educational purpose is teaching roots and affixes related to creation, structure, and physical forms.

**Data Mapping:**
- Completing a quest triggers DataService call
- Player unlocks "form-altering" affixes in PlayerMeta.WordsDiscovered

**Teaches:**
- Roots: struct- (build), form- (shape), morph- (change)
- Suffixes: -ify (make), -ize (become)

---

## Dialogue Trees by Time Phase

### 🌅 Dawn (Collection Phase)
> "Ah, the canvas resets! The morning frost brings fresh, uncarved letters to 8 Winter Street. Gather the raw clay, my friend!"

> "The new day sparkles like untouched snow! Perfect for gathering creative materials!"

> "Dawn at 8 Winter Street is magical - the snow never melts here! Perfect conditions for inspiration!"

### ☀️ Day (Construction Phase)
> "The Slime Synthesizer hums a beautiful, creative tune! Remember, there are no mistakes in word-crafting, only happy little grammatical accidents!"

> "Words are my paint! Letters are my clay! The possibilities are ENDLESS!"

> "Every word you forge today could be part of my next masterpiece! Choose wisely, artist!"

### 🌆 Dusk (Quest Phase)
> "The golden hour! The lighting is perfect, but my sculpture is missing its final piece! Quick, before we lose the aesthetic shadows!"

> "Weaver! I need your creative vision! The piece simply isn't complete without the right linguistic material!"

> "The evening brings clarity. Help me find the perfect word to finish this absolutely MAGNIFICENT failure... I mean, masterpiece!"

### 🌙 Night (Combat Phase)
> *(Pygmalion stands protectively in front of his statues)* "The Static is here! They have no appreciation for form or structure! Defend the gallery, Weaver!"

> "They dare enter my studio?! The nerve of those glitchy, poorly-rendered monstrosities!"

> "Quick, protect the sculptures! The Static wants to erase all beauty from the world!"

---

## Quest System: Mad Libs Engine

### Scenario 1: The Melting Masterpiece
**Pygmalion says:** *"Weaver! Disaster strikes at 8 Winter Street! I am trying to sculpt a majestic [Animal] out of pure frost, but the afternoon sun is melting the base! I need structural integrity! Craft me an Etymon of pure [Element: Earth/Ice] and [Class: Tank] to hold it together!"*

**Example Resolution:**
- Player submits: "SOLIDIFY" (Earth/Tank)
- Pygmalion claps his giant stone hands: "Yes! The foundation holds! It is a triumph of modern art!"

### Scenario 2: The Missing Hue
**Pygmalion says:** *"My painting of the [Location] is almost complete, but it completely lacks emotional depth. The [Plural Noun] in the foreground are too boring! I need a word with incredibly high [Target Stat: Magic/Charisma] to act as a splash of vibrant color!"*

**Example Resolution:**
- Player submits: "DAZZLING" (High Charisma)
- Pygmalion pretends to splash the word onto a canvas: "Magnificent! The composition is finally balanced!"

### Scenario 3: The Vibe Check
**Pygmalion says:** *"I crafted this beautiful [Abstract Noun] but the vibes are... off. I need an Etymon of [Element] and [Class] to balance the energy!"*

---

## Implementation Notes

### Scripting Priorities
1. **Phase Dialogue:** Hook into GameLoopService.PhaseChanged
2. **Sculpting Animation:** Hands working on invisible project
3. **Smash Mechanic:** Randomly destroys his own work
4. **Snowflake Particle:** Always hovering

### Spawn Location
- 8 Winter Street - Border of Brainy Borough and Heartwood Grove
- Coordinates: District border, snowy area
- Behavior: Sculpt, paint, smash work, admire

### Interaction Tips
- Compliment his art = very happy
- Ask about his work = long explanation about "vibes"
- Bring Earth/Tank words = 1.2x FP bonus
- Mention The Static = aesthetic disgust

---

## Trivia & Fun Facts
- 8 Winter Street always has snow because of his hovering snowflake
- Has destroyed hundreds of "perfect" sculptures
- Calls his failed works "beautiful failures"
- Treats the player as fellow artist
- His tools are oversized for his massive hands
- Sometimes uses Etymons as "paint" for his word-art
- The snow never melts even in summer

---

*Character Created: February 2026*
*Project: Syllable Springs Roblox Lore*
