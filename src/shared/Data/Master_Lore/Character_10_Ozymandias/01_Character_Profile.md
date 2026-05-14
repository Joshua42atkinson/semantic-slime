# Character Profile: Ozymandias (Ozy)

## Basic Information
- **Character Number:** 10
- **Name:** Ozymandias (called "Ozy" by friends)
- **Monster Type:** Blind House Cat
- **Jungian Archetype:** The Sage (Analytical, seeks truth, desires to find wisdom and understand the universe, fears deception, illusion, and ignorance)
- **Location:** The Brainy Borough - On top of giant dictionary stacks or bumping into mailboxes
- **Ease of Build:** Easy to Moderate

---

## Lore & Personality

Ozymandias is not a magical beast, a demon, or a spirit. He is just a regular, scruffy alley cat who happened to sleep in the restricted section of the Brainy Borough library for so long that he absorbed the semantic energy of the universe. He ascended to a higher plane of linguistic understanding, losing his physical sight in the process, but gaining perfect 20/20 vision for meaning.

Ozymandias speaks exclusively in riddles, not to trap people, but because he genuinely believes that giving direct answers makes humans intellectually lazy. Because he is physically blind (wearing a tiny, dusty blindfold made from a dictionary page), he frequently trips over benches or gets stuck in corners. When he knocks a glass off a table, he isn't being a jerk—he claims he is "testing the morphological properties of gravity." He views the Weaver (the player) as a promising student and The Typos (The Static) as the ultimate tragedy: entities that have lost all meaning and become pure "blank space."

### Key Personality Traits
- ✅ Speaks exclusively in riddles
- ✅ Philosophically Wise
- ✅ Physically clumsy (blind)
- ✅ Ancient cosmic knowledge
- ✅ Cat mannerisms (grooming, purring)
- ✅ Tests people's intelligence
- ✅ Views player as student

---

## Visual Design Specifications

### Body Type
- **Rig:** Quadruped cat (use Roblox cat bundle or build with parts)
- **Scale:** Small (distinctly tiny compared to other monsters)
- **Overall Effect:** Scruffy alley cat with wise aura

### Face/Head
- Scruffy, bearded-looking cat face
- **Key Feature:** Tiny frayed blindfold (made from dictionary page)
- Empty eye area (covered by blindfold)

### Special Effects
- **Runic Text:** Glowing runic text scrolling across fur (using texture or beam)
- **Wisdom Aura:** Subtle glow around cat

### Accessories
- **Floating Book:** Giant open book hovers in front of him
- **Magical Aura:** He "reads" by batting at word auras with paws

### Animation Guidelines
- **Idle:** Gentle purring, tail swishing, very still and regal
- **Walk:** Hesitant, clumsy, occasionally bumps into things
- **Sniff:** Pauses to "smell" vocabulary in air
- **Grooming:** Licks paw while speaking wisdom

---

## The Lore Trinity & Data Integration

### 1. Isomorphism (Word = World)

Ozymandias feeds on the illumination of truth and the clarity of knowledge.

**Data Mapping (LoreDB.lua):**
```lua
NPCs.Ozymandias = {
    PreferredElement = {"Light", "Air"},  -- Illumination and intellect
    PreferredClass = {"Support", "Mage"},
    QuestType = "Riddle",
    District = "The Brainy Borough",
    Teaches = {"vis-", "vid-", "cogn-", "scien-", "-ology", "omni-"}
}
```

**Mechanic:** When players bring Ozy Light/Air or Support/Mage Etymons, they receive a **1.2x Friendship Point bonus**. The words literally light up his dark world and make him purr loudly.

### 2. Mechanics (The Cycle of Meaning)

Ozymandias views the GameLoopService as the breathing of the universe itself.

**Data Mapping:**
- Hooked into `GameLoopService.PhaseChanged`
- Dialogue is philosophical, comments on "mechanics" subtly
- During Dusk, MadLibService pulls from his riddle quest pool

**Quest Types:**
- Classic riddles where blanks ARE the answer
- Requires specific word types to solve

### 3. Learning (The Hero's Journey)

Ozy's educational purpose is teaching about roots/affixes related to knowledge, sight, and truth.

**Data Mapping:**
- Completing a quest triggers DataService call
- Player unlocks "perception" and "academic" affixes in PlayerMeta.WordsDiscovered

**Teaches:**
- Roots: vis- (see), vid- (see), cogn- (know), scient- (know)
- Suffixes: -ology (study of), omni- (all)

---

## Dialogue Trees by Time Phase

### 🌅 Dawn (Collection Phase)
> "I cannot see the sun, Weaver, but I feel the weight of new vocabulary falling upon the grass. Gather the letters; the day demands meaning."

> "The dawn breaks like a new paragraph in the story of existence. What words shall we write today?"

> "Ah, the reset. The universe folds upon itself and begins again. The crystals await your collection."

### ☀️ Day (Construction Phase)
> "The Slime Synthesizer sings a song of creation. Can you hear the consonants colliding? It is the sound of order."

> "Words are living things, Weaver. Treat them with respect. Would you handle a butterfly with care? Then handle your vowels gently."

> "The Fabricator—pardon, the Synthesizer—hums with potential. What shall you forge from the chaos?"

### 🌆 Dusk (Quest Phase)
> "The light fades, and the world grows ambiguous. Come to me. Let us test your mind before the Static attempts to erase it."

> "The twilight brings questions. I have one for you. What walks on four legs at dawn, two at noon, and three at dusk?"

> "The shadows lengthen. The Static draws near. But first, a riddle. Are you ready?"

### 🌙 Night (Combat Phase)
> *(Ozy arches back, fur standing on end, hissing at darkness)* "The Typos approach! They are the void of meaning! Strike them with your most articulate Etymons!"

> "The enemies of meaning are here! They wish to erase all wisdom! Defend the truth, Weaver!"

> "I cannot see them, but I feel their emptiness. They are the absence of definition. FIGHT!"

---

## Quest System: Mad Libs Engine

### Scenario 1: The Classic Riddle
**Ozymandias says:** *"Greetings, Weaver. I have a puzzle for your mind. What has a [Noun] but no [Noun], and holds the [Abstract Concept] in its grasp? I require a word of pure [Element: Light] and [Class: Mage] to illuminate the answer!"*

**Example Resolution:**
- Player submits: "FORESIGHT" (Light/Mage)
- Ozymandias nods slowly: "Correct. You see clearly, even in the encroaching dusk."

### Scenario 2: The Abstract Concept
**Ozymandias says:** *"Listen closely. I am lighter than the [Element], yet no giant can hold me for long. I am the enemy of the [Plural Noun]. Bring me an Etymon with incredibly high [Target Stat: Logic/Accuracy] to prove you know my name."*

**Example Resolution:**
- Player submits: "BRILLIANCE" (High Accuracy)
- Small glowing aura surrounds the cat: "Ah, the sweet warmth of comprehension. Well done." *(then misses jump onto barrel)*

### Scenario 3: The Missing Definition
**Ozymandias says:** *"The word [Word] has lost its meaning in this realm. I need a word of [Element] and [Class] to restore its definition!"*

---

## Implementation Notes

### Scripting Priorities
1. **Riddle System:** Present classic riddles as quests
2. **Floating Book:** Always hovers in front
3. **Clumsy Movement:** Bumps into things
4. **Wisdom Aura:** Subtle glow effect

### Spawn Location
- The Brainy Borough - On dictionary stacks
- Coordinates: Library area
- Behavior: Sit regally, wander clumsily, give riddles

### Interaction Tips
- Ask riddle = engage philosopher mode
- Correct answer = pleased purring
- Wrong answer = gentle correction
- Bring Light words = 1.2x FP bonus

---

## Trivia & Fun Facts
- Lost sight sleeping in library's restricted section
- Blindfold made from dictionary page
- Speaks in riddles to prevent "intellectual laziness"
- Bumps into things constantly
- Claims knocking things over is "testing gravity"
- Has seen the "true meaning" of the universe
- Hates The Static because they're "blank space"

---

*Character Created: February 2026*
*Project: Syllable Springs Roblox Lore*
