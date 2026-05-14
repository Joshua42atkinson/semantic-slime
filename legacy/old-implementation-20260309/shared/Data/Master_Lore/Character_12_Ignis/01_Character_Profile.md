# Character Profile: Ignis

## Basic Information
- **Character Number:** 12
- **Name:** Ignis
- **Monster Type:** Red Dragon
- **Jungian Archetype:** The Ruler (Commanding, organized, desires to create a prosperous and successful community, fears chaos, being overthrown, and poor infrastructure)
- **Location:** Town Hub - Right next to the Slime Synthesizer (self-appointed Mayor)
- **Ease of Build:** Moderate to Hard

---

## Lore & Personality

In classic fantasy, a red dragon hoards gold and jewels in a mountain cave. Ignis, however, hoards permits, zoning laws, and infrastructure. He is the highly stressed, overworked Mayor of Syllable Springs. He doesn't want to burn down villages; he wants to ensure the villages have proper drainage, structurally sound grammar, and an accurately balanced budget.

Ignis takes the rules of language and the town very seriously. He views himself as the glue holding the entire game loop together. While Nyx is trying to cause chaos and Zafir is blowing things up, Ignis is running around with a clipboard, trying to issue citations for "Unlicensed Metaphor Usage" and "Improper Suffix Conjugation." He respects the Weaver (the player) because they actually get things done, frequently delegating his mayoral duties to them. He despises The Typos because they are the ultimate form of anarchy and represent a total failure of the filing system.

### Key Personality Traits
- ✅ Self-appointed Mayor
- ✅ Hoards permits and zoning laws
- ✅ Issues citations for rule violations
- ✅ Stressed and overworked
- ✅ Takes everything seriously
- ✅ Respects productive citizens
- ✅ Hates chaos and anarchy

---

## Visual Design Specifications

### Body Type
- **Rig:** Custom dragon rig (or modified R15 with dragon parts)
- **Scale:** Slightly taller than Kael (not a massive boss)
- **Overall Effect:** Town citizen who happens to be a dragon

### Face/Head
- Classic blocky dragon snout
- Small horns
- **Key Feature:** Tiny wire-rimmed reading glasses on nose tip

### Outfit
- **Sash:** Giant red and gold sash across chest
- **Text:** "MAYOR" in big block letters
- **Tie:** Very tiny, formal necktie

### Accessories
- **Clipboard:** Giant wooden clipboard
- **Pen:** Oversized fountain pen (held awkwardly in claws)

### Animation Guidelines
- **Idle:** Aggressively check off items, tap foot, stressed smoke puff from nostrils
- **Walk:** Important, purposeful stomp
- **Talk:** Wave clipboard dramatically

---

## The Lore Trinity & Data Integration

### 1. Isomorphism (Word = World)

Ignis respects words of ultimate stability, structure, and command.

**Data Mapping (LoreDB.lua):**
```lua
NPCs.Ignis = {
    PreferredElement = {"Earth", "Fire"},  -- Industry, forging, foundations
    PreferredClass = {"Tank", "Builder"},
    QuestType = "Civic Duty",
    District = "Town Hub",
    Teaches = {"-cracy", "-archy", "reg-", "struct-", "meter", "ordin-"}
}
```

**Mechanic:** When players bring Ignis Earth/Fire or Tank/Builder Etymons, they receive a **1.2x Friendship Point bonus**. He is reassured by the structural integrity of these words.

### 2. Mechanics (The Cycle of Meaning

Ignis treats GameLoopService as his literal mayoral itinerary.

**Data Mapping:**
- Hooked into `GameLoopService.PhaseChanged`
- Acts as town's PA system, announcing phases with bureaucratic urgency
- During Dusk, MadLibService pulls from his "Civic Duty" quest pool

**Quest Types:**
- Confiscating dangerous items
- Repairing town property
- Enforcing arbitrary rules

### 3. Learning (The Hero's Journey)

Ignis's educational purpose is teaching about roots/affixes related to governance, measurement, order, and structure.

**Data Mapping:**
- Completing a quest triggers DataService call
- Player unlocks "authoritative" affixes in PlayerMeta.WordsDiscovered

**Teaches:**
- Suffixes: -cracy (rule), -archy (government)
- Roots: reg- (rule), struct- (build), meter (measure)
- Roots: ordin- (order)

---

## Dialogue Trees by Time Phase

### 🌅 Dawn (Collection Phase)
> "Attention citizens! The crystals have spawned on schedule! I expect a 20% increase in collection efficiency today! Get moving!"

> "The daily reset has occurred. Forms must be filed. Productivity must increase!"

> "New day, new opportunities for administrative excellence! Gather those letters!"

### ☀️ Day (Construction Phase)
> "Remember, you need a Class-A permit to operate the Slime Synthesizer! Keep your vowels organized and clean up your morphological waste!"

> "The Synthesizer requires proper licensing! No unauthorized word creation without Form 27-B!"

> "Construct with responsibility! Every word has consequences!"

### 🌆 Dusk (Quest Phase)
> "The schedule demands civic action! Weaver, report to me at once, I have three clipboards of municipal errors that need your Etymons to fix!"

> "Citizen! You there! We have a code violation that needs immediate attention!"

> "The evening brings... more work. Always more work. What needs fixing now?"

### 🌙 Night (Combat Phase)
> *(Ignis stands aggressively, waving pen)* "The Static is violating several noise ordinances and zoning laws! Defend the infrastructure, Weaver! Do not let them erase the crosswalks!"

> "Anarchy! CHAOS! The filing system is under attack! FIGHT!"

> "The Typos threaten our permit system! We must defend proper documentation!"

---

## Quest System: Mad Libs Engine

### Scenario 1: The Code Violation
**Ignis says:** *"Attention, Weaver! We have a Class-4 violation in Action Alley! Someone has left a highly unstable [Dangerous/Silly Item] near the pathways! I need you to confiscate it immediately. Craft me a word of pure [Element: Earth] and [Class: Tank] so we can put it in heavy lockdown!"*

**Example Resolution:**
- Player submits: "SECURE" (Earth/Tank)
- Ignis checks clipboard: "Excellent work. The paperwork is filed, and the town is safe from unpermitted fun!"

### Scenario 2: The Broken Infrastructure
**Ignis says:** *"Disaster! The town's central [Mundane Object] has completely shattered, throwing the entire afternoon schedule off by 4 minutes! We need to mandate a repair! Provide me with an Etymon with incredibly high [Target Stat: Health/Logic] to restore order to our streets!"*

**Example Resolution:**
- Player submits: "RESTORE" (High Health)
- Ignis lets out relieved smoke puff: "Thank goodness. We were moments away from total anarchy."

### Scenario 3: The Unlicensed Metaphor
**Ignis says:** *"Someone is using unlicensed metaphors in public! I need a word of [Element] and [Class] to properly regulate their speech!"*

---

## Implementation Notes

### Scripting Priorities
1. **Mayoral PA System:** Announce phases
2. **Clipboard:** Always checking items off
3. **Smoke Puff:** Stress relief animation
4. **Citation System:** Quest generation

### Spawn Location
- Town Hub - Right next to Slime Synthesizer
- Coordinates: Central area
- Behavior: Patrol, issue citations, delegate tasks

### Interaction Tips
- Ask about town = long bureaucratic speech
- Mention chaos = stressed reaction
- Bring Earth/Fire words = 1.2x FP bonus
- Night = becomes defensive mayor

---

## Trivia & Fun Facts
- Hoards permits, not gold
- Issues citations for "Unlicensed Metaphor Usage"
- Tiny reading glasses on dragon nose
- "MAYOR" sash across chest
- Overworked and stressed
- Respects productive citizens
- Hates chaos, loves paperwork

---

*Character Created: February 2026*
*Project: Syllable Springs Roblox Lore*
