# Pedagogy Guide

## Educational Philosophy

**Semantic Slime** is an MMO-Lit-RPG designed to teach vocabulary through engagement, not memorization. It applies three core educational frameworks:

### 1. Constructivism (Learning by Doing)
Players don't study definitions — they **build words** from letter crystals, **use words** in Mad Lib quests, and **battle with words** in semantic combat. Knowledge is constructed through active play.

### 2. Spaced Repetition (via Game Loop)
The game loop (Collection → Construction → Quest → Combat → Rewards) naturally spaces out vocabulary exposure. The `LinguisticLog` in `DataService` tracks morpheme success/failure rates and breadcrumbs for adaptive difficulty.

### 3. Intrinsic Motivation (via Gamification)
See `GAMIFICATION_THEORY.md` and `VAAM_MECHANICS.md` for detailed breakdowns. Key motivators:
- **Autonomy**: Players choose which words to construct, which quests to take
- **Mastery**: Slime evolution, level progression, resonance multiplier
- **Purpose**: Lore-driven narrative tying vocabulary to world-building

## Game Mechanics ↔ Learning Objectives

| Game Mechanic | Learning Objective | Assessment |
|--------------|-------------------|------------|
| Crystal Collection | Letter recognition, frequency awareness | Letters collected per session |
| Word Construction | Spelling, morpheme awareness | Words formed, accuracy rate |
| Mad Lib Quests | Parts of speech, context usage | Slots filled correctly |
| Semantic Combat (synonyms/antonyms) | Vocabulary depth, word relationships | Critical hit rate (correct synonyms) |
| Slime Evolution | Long-term retention | Words mastered over time |

## Key Data Files

| File | Purpose |
|------|---------|
| `SynonymDatabase.lua` | Synonym/antonym relationships for combat |
| `WordDatabase.lua` | Psycholinguistic metrics (concreteness, valence) |
| `EtymologyDB.lua` | Root/suffix etymological data for slime elements |
| `QuestData.lua` | Mad Lib template sentences |
| `LearningStationData.lua` | In-world tutorial content |

## Further Reading

- [GAMIFICATION_THEORY.md](GAMIFICATION_THEORY.md) — Theory of gamification applied to learning
- [VAAM_MECHANICS.md](VAAM_MECHANICS.md) — VAAM framework for engagement
- [PSYCHE_POLIS_BLUEPRINT.md](PSYCHE_POLIS_BLUEPRINT.md) — Jungian psychology in world design
- [LESSONS_LEARNED.md](LESSONS_LEARNED.md) — Development session insights
