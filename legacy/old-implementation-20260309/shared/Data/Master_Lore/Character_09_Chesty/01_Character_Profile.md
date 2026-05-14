# Character Profile: Chesty

## Basic Information
- **Character Number:** 09
- **Name:** Chesty
- **Monster Type:** Mimic (Currently a Treasure Chest)
- **Jungian Archetype:** The Jester (Playful, trickster, humorous, desires to live in the moment with full enjoyment, fears boredom or being "too serious")
- **Location:** Dynamic! Assigned to Town Hub, but randomizes daily (next to Synthesizer, in bushes, etc.)
- **Ease of Build:** Easy to Moderate

---

## Lore & Personality

Chesty lives entirely for "the bit." In a town where everyone takes the rules of language very seriously, Chesty is here to remind them that words can be silly, confusing, and totally absurd. He isn't malicious—he doesn't want to bite adventurers; he just thinks it's hilarious when they try to open him for loot and he licks their hands instead.

Chesty uses humor to defuse the tension of the game loop. If Kael is being too dramatic or Ignis is being too bossy, Chesty will intentionally cause a minor, goofy distraction. He views the player (the Weaver) as his ultimate partner in crime, constantly trying to recruit them for elaborate, harmless pranks across Syllable Springs. He absolutely hates The Static (the night enemies) because they have "zero sense of comedic timing."

### Key Personality Traits
- ✅ Lives for "the bit"
- ✅ Ultimate prankster
- ✅ Goofy and harmless
- ✅ Defuses tension with humor
- ✅ Partner in crime with player
- ✅ Hates being "too serious"
- ✅ Random daily location

---

## Visual Design Specifications

### Body Type
- **Rig:** Custom assembly (no standard rig needed)
- **Shape:** Classic rounded-top wooden treasure chest
- **Size:** Medium (human chest height when closed)
- **Overall Effect:** Looks like a normal prop until opened

### Face (When Open)
- **Eyes:** Giant, goofy googly eyes (white with moving pupils)
- **Teeth:** Blunt piano-key teeth
- **Tongue:** Massive cartoonish purple tongue that lolls out

### Closed State
- Looks like normal treasure chest
- Wooden with iron bands
- No face visible

### Animation Guidelines
- **Idle (Closed):** Completely still (looks like prop)
- **Idle (Open):** Googly eyes look around, tongue lolls
- **Walk:** Loud ka-chunk ka-chunk hopping motion
- **Interact:** Springs open with confetti burst

---

## The Lore Trinity & Data Integration

### 1. Isomorphism (Word = World)

Chesty loves words that are chaotic, deceptive, or represent movement and surprise.

**Data Mapping (LoreDB.lua):**
```lua
NPCs.Chesty = {
    PreferredElement = {"Air", "Shadow"},  -- Speed and stealth
    PreferredClass = {"Striker"},
    QuestType = "Prank",
    District = "Town Hub (Randomizes)",
    Teaches = {"-ish", "-esque", "pseudo-", "quasi-"}
}
```

**Mechanic:** When players bring Chesty Air/Shadow or Striker Etymons, they receive a **1.2x Friendship Point bonus**. He feeds on the kinetic energy of "fast" and "tricky" words.

### 2. Mechanics (The Cycle of Meaning)

Chesty treats the GameLoopService like a game of hide-and-seek.

**Data Mapping:**
- Hooked into `GameLoopService.PhaseChanged`
- Location shifts at Dawn phase reset (random spawn)
- During Dusk, MadLibService pulls from his prank quest pool

**Quest Types:**
- Causes harmless chaos
- Hides items, surprises NPCs
- Creates literal optical illusions

### 3. Learning (The Hero's Journey)

Chesty's educational purpose is teaching about language flexibility: puns, homophones, synonyms, and "fake" suffixes.

**Data Mapping:**
- Completing a quest triggers DataService call
- Player unlocks "trickster" affixes in PlayerMeta.WordsDiscovered

**Teaches:**
- Suffixes: -ish (somewhat), -esque (in the style of)
- Prefixes: pseudo- (fake), quasi- (almost)

---

## Dialogue Trees by Time Phase

### 🌅 Dawn (Collection Phase)
> "Ding ding! The daily reset! Quick, grab those letters before the server sweeps them up!"

> "New day, new location! Did you find me yet? I'm a tricky little chest!"

> "The game has respawned! Time for a fresh batch of chaos!"

### ☀️ Day (Construction Phase)
> "The Slime Synthesizer is just a giant blender, change my mind. Toss those vowels in and see what explodes!"

> "Words are just LEGO blocks for adults! Build something silly!"

> "Hehehe, want to cause some chaos later? I've got IDEAS!"

### 🌆 Dusk (Quest Phase)
> "Sun's going down! Time for the serious NPCs to hand out boring chores. Come to me for the actual fun stuff!"

> "Psst! Want to pull a prank? I've got a great bit planned!"

> "The golden hour of tomfoolery is upon us! Let's cause some harmless trouble!"

### 🌙 Night (Combat Phase)
> *(Chesty snaps lid shut, hiding)* "Uh oh, The Static is here! I am just a normal, boring box! Nothing to see here! You deal with them, Weaver!"

> "The humorless blobs are here! They're such buzzkills!"

> "I'm going into hiding! Pretend I'm just decor! Good luck, partner!"

---

## Quest System: Mad Libs Engine

### Scenario 1: The Ol' Switcheroo
**Chesty says:** *"Hehehe! Yorick left his favorite [Tool/Item] on the bench in Action Alley! Let's play a trick on him! We need to replace it with a fake! Craft me an Etymon of pure [Element: Shadow] and [Class: Support] so we can make a [Silly Noun] look exactly like his stuff!"*

**Example Resolution:**
- Player submits: "ILLUSORY" (Shadow/Support)
- Chesty bounces up and down: "Perfect! He's going to be so confused when his broom turns into a rubber chicken!"

### Scenario 2: The Sneak Attack
**Chesty says:** *"Kael is taking his guard duty way too seriously today. Let's give him a harmless scare! I need a word with incredibly high [Target Stat: Speed/Agility] to sneak up behind him and drop this [Gross Noun] right on his helmet!"*

**Example Resolution:**
- Player submits: "SNEAKY" (High Speed)
- Chesty spits out confetti: "Bullseye! Did you hear him squeak? Best prank ever!"

### Scenario 3: The Invisible Buffer
**Chesty says:** *"Martha is knitting AGAIN. Let's make her think her yarn has gone invisible! I need a word of [Element] and [Class] to create an optical illusion!"*

---

## Implementation Notes

### Scripting Priorities
1. **Random Location:** Spawns in different spot each Dawn
2. **Open/Close:** Spring animation on interaction
3. **Confetti:** Particle effect on open
4. **Prank System:** Quests cause harmless chaos

### Spawn Location
- Town Hub (but randomizes daily)
- Dawn: Random location chosen
- Can be near Synthesizer, in bushes, etc.

### Interaction Tips
- Open chest = googly eyes and tongue appear
- Prank talk = excited energy
- Bring Air/Shadow words = 1.2x FP bonus
- Combat =pretends to be normal box

---

## Trivia & Fun Facts
- Mimic that licks instead of bites
- Lives for "the bit"
- Daily location randomizes
- Partner in crime with player
- Hates The Static because no humor
- Confetti burst when opened
- Sometimes wears props (lampshade on lid)

---

*Character Created: February 2026*
*Project: Syllable Springs Roblox Lore*
