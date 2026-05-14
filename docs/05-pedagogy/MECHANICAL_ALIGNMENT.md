# Mechanical Alignment Map
> Every game mechanic must serve a learning objective. Every learning objective must be served by a game mechanic. No exceptions.

---

## The Rule

If a mechanic doesn't teach something, cut it.  
If a learning goal doesn't have a mechanic, build one.

This document is the contract between design and education.

---

## Alignment Table

### Tier 1: Core Loop (Must Ship)

| Mechanic | Lua Implementation | Learning Objective | How We Know It's Working |
|----------|-------------------|-------------------|------------------------|
| **Letter Crystal Collection** | `CrystalService.lua` spawns A–Z crystals with rarity weighting | Letter frequency awareness — rare letters (Q, X, Z) are valuable, reinforcing that they're uncommon in English | Player can explain why Z crystals are rarer than E crystals |
| **Word Construction** | `SlimeFactory.lua` validates spelling via `WordDatabase.lua`, decomposes via `EtymologyDB.lua` | Spelling accuracy, morpheme decomposition (root + suffix identification) | Player correctly spells words and identifies their component parts |
| **Etymon Element Assignment** | `EtymologyDB.lua` maps Latin/Greek roots → elements (ignis→fire, aqua→water) | Etymology awareness — Latin/Greek root meanings | Player predicts a new word's element based on its root |
| **Etymon Role Assignment** | `EtymologyDB.lua` maps suffixes → combat roles (-tion→tank, -ize→striker) | Morphological awareness — how suffixes change word function | Player can explain why "-tion" makes nouns and "-ize" makes verbs |
| **Mad-Lib Quests** | `MadLibService.lua` generates sentence templates with typed slots | Parts of speech usage, contextual word selection | Player correctly fills noun/verb/adjective slots |
| **Synonym/Antonym Battle Combos** | `BattleService.lua` checks `SynonymDatabase.lua` for word relationships | Semantic network building — understanding word relationships | Player identifies synonyms under time pressure for battle advantage |

### Tier 2: Retention Systems (Sprint 3–4)

| Mechanic | Lua Implementation | Learning Objective | How We Know It's Working |
|----------|-------------------|-------------------|------------------------|
| **Slime Evolution** | `EvolutionService.lua` requires repeated word usage across sessions | Spaced repetition — encountering the same morphemes over days/weeks | Player recognizes a root they first saw days ago |
| **Context Points** | `SlimeFactory.lua` tracks usage count per slime | Depth of processing — words used more become stronger | Player chooses to reuse same words in new contexts |
| **Linguistic Log** | `DataService.lua` stores per-player word mastery metrics | Adaptive difficulty — system identifies weak areas | Quest difficulty matches player's current vocabulary level |
| **District Vocabulary Theming** | `TownBlueprint.lua` + `NPCData.lua` assign vocab domains per district | Domain-specific vocabulary acquisition | Player uses different vocabulary when discussing different districts |

### Tier 3: Social Learning (Sprint 5+)

| Mechanic | Lua Implementation | Learning Objective | How We Know It's Working |
|----------|-------------------|-------------------|------------------------|
| **Multiplayer Quest Competition** | `GameLoopService.lua` allows multiple players to bid for same slot | Peer learning, collaborative vocabulary discussion | Players discuss word choices before committing to slots |
| **Trading** | `TradingService.lua` enables slime exchange | Vocabulary valuation — assigning worth to word knowledge | Player can articulate why one word-slime is more valuable than another |
| **Guild Quests** | `GuildService.lua` for cooperative objectives | Collaborative problem-solving with vocabulary | Players divide vocabulary tasks by individual strengths |

---

## Anti-Patterns to Avoid

These are traps that break the alignment:

### ❌ "Learn to Unlock"
> "Answer 5 vocab questions to unlock the next area"

This separates learning from gameplay. The learning becomes the tax. **Never gate fun behind quizzes.**

**Instead:** The vocabulary IS the key. You can't enter the Scholar's District without constructing a word with a "-tion" suffix. The gate IS the lesson.

### ❌ "Bonus XP for Studying"
> "Visit the Learning Station for extra XP!"

This makes learning optional and signals it's less fun than the "real" game. **Never make learning a side activity.**

**Instead:** All XP comes from using words in quests and battles. There is no XP source that isn't vocabulary-driven.

### ❌ "Vocabulary Skins"
> "This sword is called 'Lexicon' because our game is educational"

Naming things after vocabulary concepts doesn't teach vocabulary. **Never use educational theming as a substitute for educational mechanics.**

**Instead:** The word "lexicon" should only appear if the player constructed it from letters, analyzed its root (lex = law/word), and deployed it in a quest about language.

### ❌ "Quiz Battles"
> "A wild monster appears! What does 'ephemeral' mean? A) Short-lived B) Eternal C) Small"

Multiple choice under a game skin is still multiple choice. **Never use quiz mechanics as combat.**

**Instead:** Combat uses word relationships. Using a synonym of your opponent's word gives a critical hit. Using an antonym gives damage resistance. The player must *know* the relationships, not *guess* from options.

---

## The Golden Test

For any mechanic, ask:

1. **Would a non-educational version of this mechanic be less fun?**
   - If yes → the learning IS the fun. ✅ Ship it.
   - If no → the learning is decoration. ❌ Redesign it.

2. **Can a player get better at the game without learning vocabulary?**
   - If yes → you have a leaky mechanic. Plug the hole.
   - If no → vocabulary mastery = game mastery. ✅

3. **Would a teacher see a student playing this and feel they're learning?**
   - Not "see them answer a quiz" but "see them solve a problem using word knowledge"
   - If the teacher would say "they're just playing a game" → the learning is invisible (which might actually be perfect, or might mean it's absent — test it)

---

## Mapping to Existing Pedagogy Docs

| This Document | References |
|--------------|-----------|
| Why the design works | [WHY_THIS_WORKS.md](WHY_THIS_WORKS.md) |
| The VaaM framework (words as physics objects) | [VAAM_MECHANICS.md](VAAM_MECHANICS.md) |
| Gamification without corruption | [GAMIFICATION_THEORY.md](GAMIFICATION_THEORY.md) |
| Jungian world structure | [PSYCHE_POLIS_BLUEPRINT.md](PSYCHE_POLIS_BLUEPRINT.md) |
| Technical implementation lessons | [LESSONS_LEARNED.md](LESSONS_LEARNED.md) |
