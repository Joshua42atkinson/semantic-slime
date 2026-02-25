# 🌍 Worldbuilding Workflow
## Semantic Slime - Creative Development Process

> *"Language is the living matter of Psyche-Polis"*

---

## 🎨 The Vision

**Semantic Slime** is more than a game—it's a **living etymology lesson**. Every element should teach, every interaction should reveal the hidden stories within words.

---

## 🏛️ World Structure: Psyche-Polis

### The Four Districts (Jungian Archetypes)

| District | Element | Theme | Learning Focus |
|----------|---------|-------|----------------|
| **Logos** (North) | Air 🌬️ | Logic, Reason, Structure | Academic vocabulary, scientific terms |
| **Eros** (South) | Water 💧 | Emotion, Connection, Love | Emotional vocabulary, relationship words |
| **Pneuma** (East) | Light ✨ | Spirit, Inspiration, Dreams | Creative vocabulary, poetic terms |
| **Soma** (West) | Fire 🔥 | Body, Action, Conflict | Physical vocabulary, action words |

### The Hub: Town Square
- Neutral ground where all elements meet
- Tutorial zone for new players
- The Archive (word collection display)

### The Wilderness
- Ring surrounding the districts
- Where wild Etymons spawn
- Element distribution based on nearest district

---

## 📝 Content Creation Workflow

### Step 1: Word Selection
Choose words that serve the curriculum:

```
Target Grade Level: [K-2 | 3-5 | 6-8 | 9-12 | College]

Word Criteria:
✓ High-frequency in academic texts
✓ Interesting etymology (Latin/Greek roots)
✓ Multiple synonyms/antonyms
✓ Can be visualized as a creature
```

### Step 2: Etymology Mapping
For each word, define:

```lua
["word"] = {
    Synonyms = {"syn1", "syn2", "syn3", "syn4"},
    Antonyms = {"ant1", "ant2"},
    Distractors = {"wrong1", "wrong2", "wrong3"},
    Element = "Fire|Water|Earth|Air|Shadow|Light",
    Difficulty = 1-5,
    Root = "Latin/Greek origin",
    FunFact = "Interesting tidbit for players",
}
```

### Step 3: Visual Design
Describe the Etymon's appearance:

```
Word: "Ignite"
Element: Fire
Appearance: 
  - Body: Flickering orange sphere with flame particles
  - Eyes: Glowing yellow, intense
  - Personality: Energetic, jumpy, impatient
  - Capture animation: Bursts into sparkles
  - Evolution: "Greater Ignite" has crown of flames
```

### Step 4: Quest Integration
Create quests that use the word:

```
Quest: "The Blacksmith's Request"
NPC: The Forge (Logos District)
Dialogue: "I need something to start my fire..."
Objective: Capture an "Ignite" Etymon
Reward: 25 XP, 5 Insight, Fire Resistance badge
```

---

## 🎭 NPC Archetypes (12 Total)

Each district has 3 NPCs representing aspects of that archetype:

### Logos District (The Mind)
| NPC | Archetype | Role | Quest Type |
|-----|-----------|------|------------|
| The Archivist | Sage | Tutorial guide | Collection quests |
| Judge Reason | Ruler | Law & order | Logic puzzles |
| The Calculator | Scholar | Numbers & data | Math vocabulary |

### Eros District (The Heart)
| NPC | Archetype | Role | Quest Type |
|-----|-----------|------|------------|
| Mother Mercy | Caregiver | Healing | Support word quests |
| The Matchmaker | Lover | Connections | Relationship words |
| The Peacemaker | Diplomat | Conflict resolution | Peace vocabulary |

### Pneuma District (The Spirit)
| NPC | Archetype | Role | Quest Type |
|-----|-----------|------|------------|
| The Dreamer | Innocent | Imagination | Creative words |
| Oracle Visions | Seer | Prophecy | Future/past tense |
| The Artist | Creator | Beauty | Aesthetic vocabulary |

### Soma District (The Body)
| NPC | Archetype | Role | Quest Type |
|-----|-----------|------|------------|
| The Champion | Hero | Combat | Action words |
| The Rebel | Outlaw | Revolution | Rebellion vocabulary |
| The Athlete | Warrior | Competition | Sports vocabulary |

---

## 🔄 Weekly Content Cycle

### Monday: Word Wednesday Prep
- Select 5 new words for the week
- Create Etymon designs
- Write fun facts and etymology notes

### Tuesday: Quest Writing
- Design 2-3 quests using new words
- Write NPC dialogue
- Create quest rewards

### Wednesday: Word Wednesday Release
- Deploy new content
- Announce "Word of the Week"
- Special bonus for capturing featured word

### Thursday: Testing & Feedback
- Playtest new content
- Gather player feedback
- Fix bugs

### Friday: Documentation
- Update session_turnover.md
- Record player progress data
- Plan next week's content

---

## 📊 Vocabulary Curriculum Mapping

### Grade 3-5 (Elementary)
```
Week 1-4: Basic Elements
- Fire words: burn, hot, flame, spark
- Water words: flow, wet, river, rain
- Earth words: ground, rock, solid, land
- Air words: wind, fly, breath, sky

Week 5-8: Emotions
- Happy words: joy, glad, cheer, bright
- Sad words: gloom, tear, sorrow, gray
- Angry words: fury, rage, storm, fire
- Calm words: peace, quiet, still, rest
```

### Grade 6-8 (Middle School)
```
Week 1-4: Academic Roots
- Latin: spect (look), dict (speak), port (carry)
- Greek: graph (write), phon (sound), chron (time)

Week 5-8: Science Vocabulary
- Biology: bio, life, cell, organism
- Physics: energy, force, motion, matter
- Chemistry: element, reaction, bond, mixture
```

### Grade 9-12 (High School)
```
Week 1-4: SAT/ACT Prep
- High-frequency SAT words
- Context clue practice
- Multiple meaning words

Week 5-8: Literary Terms
- Metaphor, simile, alliteration
- Theme, tone, mood
- Character, plot, setting
```

---

## 🎮 Gameplay Integration

### The Lure Minigame (Vocabulary Recognition)
- Player sees target word
- Must select synonym from 4 choices
- Time pressure creates engagement
- Wrong answers teach antonyms

### The Synthesis System (Word Construction)
- Combine Root + Suffix = New Word
- Example: "Ignis" (fire root) + "tion" (noun suffix) = "Ignition"
- Teaches morphological awareness
- Creates ownership of vocabulary

### The Battle System (Vocabulary Application)
- Use captured words to solve challenges
- Mad Libs style: "The dragon was [ADJECTIVE]"
- Select word from inventory
- Correct word = effective attack

### The Journal System (Metacognition)
- Record of words captured
- Etymology notes
- Personal reflections
- Progress tracking

---

## 🛠️ Tools & Templates

### Word Entry Template
```lua
["example"] = {
    Synonyms = {"sample", "instance", "model", "illustration"},
    Antonyms = {"exception", "anomaly"},
    Distractors = {"problem", "question", "answer"},
    Element = "Earth",
    Difficulty = 2,
    Root = "Latin 'exemplum' - a sample",
    FunFact = "The word 'example' comes from Latin meaning 'to take out' - like taking out a sample to show others!",
    Grade = "3-5",
    Category = "Academic",
},
```

### Quest Template
```lua
["quest_template"] = {
    Id = "quest_template",
    Name = "Quest Name Here",
    Description = "NPC Name needs your help with [task]. [Story context].",
    NPC = "NPC_Id",
    District = "Logos|Eros|Pneuma|Soma",
    Steps = {
        { Id = "step_1", Type = "Collect", TargetId = "word", Amount = 1, Description = "Capture [word]" },
        { Id = "step_2", Type = "Talk", TargetId = "npc_id", Description = "Return to NPC" },
    },
    Rewards = { xp = 25, insight = 5, badge = "Badge_Name" },
    Grade = "3-5",
    LearningObjective = "Students will understand the meaning of [word] and its synonyms.",
},
```

---

## 📈 Measuring Success

### Player Metrics
- Words captured per session
- Quest completion rate
- Synthesis attempts
- Battle win rate
- Time spent in each district

### Learning Metrics
- Pre/post vocabulary quizzes
- Synonym selection accuracy
- Word usage in battles
- Journal entry quality

### Engagement Metrics
- Daily active users
- Session length
- Return rate
- Social interactions (trades, co-op)

---

*This workflow ensures consistent, curriculum-aligned content creation.*