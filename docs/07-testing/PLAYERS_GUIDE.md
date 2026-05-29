# 🎮 Semantic Slime — Player's Guide & Playtest Script

> **For:** First-time players, family testers, and playtest observers.
> **Goal:** Understand the game, play it, and capture what works vs. what doesn't.

---

## Part 1: How To Play (For the Player)

### You Are Here

You've just spawned in **Syllable Springs** — a circular city with four colorful districts surrounding a central hub. Glowing crystals float around you. Strange creatures stand near buildings around the edge. A tutorial panel pops up.

### Your Goal

**Collect letters. Build words. Create slime companions. Complete quests.**

That's it. The loop is:

```
🔮 Pick up letter crystals → 🧬 Spell a word → 🧪 Get a slime → 📜 Use it in a quest → 🎁 Earn rewards
                  ↑                                                                        |
                  └─────────────── keep going, get stronger! ──────────────────────────────┘
```

### Controls

| Key | What It Does |
|-----|-------------|
| **WASD** | Move around |
| **Mouse** | Look around |
| **Space** | Jump |
| **E** | Interact with NPC (when the prompt appears) |
| **B** | Open your **Letter Inventory** (see what letters you have) |
| **I** | Open your **Slime Collection** (see your slime companions) |
| **J** | Open your **Quest Log** (see active quests) |
| **K** | Open the **Slime Fabricator** (build words into slimes) |
| **U** | Open **Evolution** panel |
| **Y** | Open **Achievements** |
| **O** | Open **Gallery** |
| **Esc** | Close whatever panel is open |

### The Action Bar

At the bottom of your screen, you'll see a row of buttons. These are the same as the keyboard shortcuts — you can click them too.

### The Phase Banner

At the top of the screen, a banner tells you what **phase** the game is in. The game cycles through five phases automatically:

| Phase | What Happens | Sky Color | How Long |
|-------|-------------|-----------|----------|
| 🌅 **Collection** | Crystals appear! Run around and walk into them. | Dawn (warm orange) | ~45 seconds |
| 🔨 **Construction** | The Fabricator opens automatically. Spell words! | Morning (bright) | ~30 seconds |
| 📜 **Quest** | NPCs offer quests. Walk up to them, press E. | Afternoon (warm) | ~90 seconds |
| 😈 **Nuisance** | Clingy letters chase you! Shake them off. | Dusk (eerie) | ~45 seconds |
| 🎁 **Rewards** | XP and rewards arrive. Relax. | Night (dark blue) | ~30 seconds |

Then it loops back to Collection. The sky and music change with each phase so you always know where you are.

---

### Step-by-Step: Your First 5 Minutes

#### Minute 0-1: Arrival

1. **Read the tutorial** — Zog the guide appears. He tells you how the world works. Click "Continue" to advance, or "Skip Tutorial" to jump right in.
2. **Look around** — You're in the Town Square. Buildings ring the edges. Glowing crystals float nearby.

#### Minute 1-2: Collection Phase

3. **Walk into glowing crystals** — Each crystal contains a letter (A–Z). Walking into one picks it up automatically.
4. **Check your inventory** — Press **B** to see your 26-letter grid. Each letter shows how many you have. Common letters (E, A, T) appear often. Rare ones (Z, Q, X) are special finds.
5. **Explore the districts** — Walk outward from the hub. You'll find four different areas, each with different colors and buildings:
   - **Brainy Borough** (North) — Blue/marble, for knowledge lovers
   - **Action Alley** (East) — Red/industrial, for adventure
   - **Heartwood Grove** (South) — Green/natural, for friendship
   - **Whisper Winds** (West) — Purple/crystal, for creativity

#### Minute 2-3: Construction Phase

6. **The Fabricator opens** — When Construction phase starts, the Slime Fabricator panel appears automatically (you can also press **K**).
7. **Spell a word** — Click letters from your inventory grid, or just **type on your keyboard**. You'll see your word build letter-by-letter in glowing yellow text. A 3D preview of your slime rotates on the right.
8. **Hit "Fabricate Slime!"** — If the word is real (3+ letters), a slime is born! It gets:
   - An **element** (Fire, Water, Earth, Air, Shadow, Light) based on its root meaning
   - A **role** (Tank, Striker, Support, etc.) based on its suffix
   - **Stats** (Logos, Pathos, Ethos, Speed)
   - A **rarity** based on word complexity

   If the word isn't valid, the text flashes red. Try again!

9. **Check your collection** — Press **I** to see your new slime with all its stats.

#### Minute 3-4: Quest Phase

10. **Walk to an NPC** — Head toward one of the buildings on the ring. You'll see characters standing near their homes — a cyclops, a skeleton, a vampire, a dragon…
11. **Press E** — The camera zooms in and the NPC speaks. Each one has a unique personality tied to a [Jungian archetype](https://en.wikipedia.org/wiki/Jungian_archetypes).
12. **Accept a quest** — The NPC gives you a **Mad Lib** — a story with blanks. Each blank needs a specific type of word (noun, verb, adjective, or a word with a specific morpheme like "un-" or "-ful").
13. **Fill in the blanks** — Use your slimes (or type words) to complete the Mad Lib. The NPC reacts to your choices!

#### Minute 4-5: Nuisance + Rewards

14. **Survive the nuisance!** — During the Nuisance phase, oversized clingy letters spawn and chase you. They're annoying, not dangerous — they want you to spell them into words! Letters that cling to you get added to your inventory automatically.
15. **Collect rewards** — The Rewards phase grants XP, Insight (currency), and Evolution Points. Your slimes level up. The cycle starts again!

---

## Part 2: The Scripted Playthrough (Observer's Narration)

> **Use this to walk through the game step-by-step, noting exactly where things work vs. break.**

### Scene 1: Boot & Spawn (0:00 – 0:30)

```
EXPECTED:
- Screen loads. World appears.
- Tutorial panel slides in: "Welcome to Syllable Springs!"
- Phase banner at top reads: "The World Breathes in Letters" (Collection)
- Action bar visible at bottom with 7 icon buttons.
- Minimap in top-right corner shows 4 colored districts.
- Glowing crystals visible in the world.

OBSERVE: Does the tutorial appear? Is the world visible? Any error text?
```

### Scene 2: Crystal Collection (0:30 – 1:30)

```
EXPECTED:
- Walk toward a glowing crystal → it disappears on touch.
- Notification appears: "Collected [Rarity] crystal: [Letter]"
- Press B → Letter Inventory shows the letter with count = 1.
- Collect 5+ crystals → inventory reflects all letters.

OBSERVE: Do crystals disappear on touch? Does the notification appear?
         Does pressing B open the inventory? Are letters actually counted?
```

### Scene 3: Word Construction (1:30 – 2:30)

```
EXPECTED:
- Phase changes to "Crystallizing Meaning" (Construction).
- Fabricator panel auto-opens (or press K).
- Type "earth" on keyboard → letters appear one by one in gold text.
- 3D slime preview rotates on the right panel.
- Element badge shows "🌿 Element: Earth".
- Click "Fabricate Slime!" → word flashes green → notification says "New Slime: earth (Rare)".
- Press I → slime appears in collection with stats.

OBSERVE: Does the Fabricator open? Can you type? Does the preview show?
         Does submitting work? What happens with a fake word like "xyzzy"?
```

### Scene 4: NPC Interaction (2:30 – 3:30)

```
EXPECTED:
- Walk toward a building on the ring → see an NPC character.
- Walk close → ProximityPrompt appears ("Press E to talk").
- Press E → Camera zooms to NPC face. Dialogue box appears.
- NPC speaks in-character (Barnaby is cheerful, Nyx is sarcastic, etc.)
- Dialogue options appear → click one → conversation continues.

OBSERVE: Are NPCs visible? Does the E prompt appear? Does dialogue show?
         Does the camera zoom work? Is the dialogue text appropriate?
```

### Scene 5: Phase Transitions (3:30 – 4:30)

```
EXPECTED:
- Phase banner changes text + shows full-screen splash briefly.
- Lighting shifts smoothly (dawn → morning → afternoon → dusk → night).
- Different notifications for each phase.
- The cycle completes: Collection → Construction → Quest → Nuisance → Rewards → Collection.

OBSERVE: Does the phase banner update? Does lighting actually change?
         Is there a noticeable transition or does it just "jump"?
         Do you always know what you should be doing?
```

---

## Part 3: The Playtest Audit Template

> **Print this out (or keep it open). Fill in the "Actual" column during your playtest.**

| # | Category | What to Check | Expected | Actual | Grade |
|---|---|---|---|---|---|
| 1 | **First 30s** | Tutorial appears? | Yes, immediately | | |
| 2 | | Tutorial text makes sense? | Clear, friendly | | |
| 3 | | World is visible + interesting? | 4 districts + crystals | | |
| 4 | | Phase banner visible at top? | Shows "Collection" | | |
| 5 | | Action bar visible at bottom? | 7 buttons with icons | | |
| 6 | **Crystals** | Walk into crystal = collected? | Crystal disappears | | |
| 7 | | Notification appears? | "[Rarity] crystal: [Letter]" | | |
| 8 | | Press B = inventory shows letters? | Grid with counts | | |
| 9 | | Letters match what you collected? | Yes, accurate | | |
| 10 | | Crystals spawn during Collection phase? | Regularly | | |
| 11 | **Fabricator** | Press K = Fabricator opens? | Panel appears | | |
| 12 | | Can type letters on keyboard? | Letters show in gold | | |
| 13 | | Can click letter buttons? | Same effect | | |
| 14 | | 3D slime preview visible? | Rotating model | | |
| 15 | | Submit valid word = slime created? | Green flash + notification | | |
| 16 | | Submit invalid word = red flash? | Text turns red briefly | | |
| 17 | | Press I = see new slime in collection? | Card with stats | | |
| 18 | **NPCs** | Walk near NPC = E prompt? | ProximityPrompt appears | | |
| 19 | | Press E = dialogue appears? | Camera zoom + text box | | |
| 20 | | NPC speaks in character? | Personality matches archetype | | |
| 21 | | Can click dialogue options? | Conversation continues | | |
| 22 | **Phases** | Phase changes happen on timer? | Every 30-90 seconds | | |
| 23 | | Phase banner text updates? | New phase name shown | | |
| 24 | | Full-screen splash appears? | Brief overlay text | | |
| 25 | | Lighting changes? | Sky color shifts smoothly | | |
| 26 | | Know what to do in each phase? | Clear from banner/context | | |
| 27 | **Nuisance** | Letters chase you? | Visible letter entities | | |
| 28 | | Letters cling and add to inventory? | Auto-collected | | |
| 29 | **Rewards** | XP granted? | Notification or stat update | | |
| 30 | | Cycle restarts cleanly? | Back to Collection, no crash | | |

### Grading Scale

| Grade | Meaning |
|---|---|
| ✅ | Works as expected |
| ⚠️ | Works but feels off (UX friction) |
| ❌ | Doesn't work (bug) |
| 🔇 | Nothing happens (missing feature) |
| 💥 | Crashes or freezes |

---

## Part 4: Soft Spot Finder

After your playtest, every non-✅ item falls into one of five categories:

### Category 1: 💥 Game-Breaking (Fix immediately)
> The game crashes, freezes, or becomes unplayable.

**Examples:** Screen goes black. Error popup. Character falls through floor. Infinite loop.

**What we do:** I fix the code before we test again.

### Category 2: ❌ Missing Wiring (Feature exists but isn't connected)
> The UI exists. The service exists. But they don't talk to each other.

**Examples:**
- Pressing K opens Fabricator but letters don't come from inventory
- NPC dialogue appears but quests don't generate
- Phase changes but lighting doesn't shift

**What we do:** Trace the signal path (Service → Signal → Controller → UI) and connect the broken link.

### Category 3: ⚠️ UX Friction (Works but feels wrong)
> Technically functional, but a player would be confused or frustrated.

**Examples:**
- "I didn't know what to do during Construction phase"
- "The notification disappeared too fast to read"
- "I couldn't tell which building had which NPC"
- "The Fabricator opened during Quest phase when I didn't need it"

**What we do:** Adjust timing, add hints, improve visual cues, update text.

### Category 4: 🔇 Missing Content (Feature isn't built yet)
> Nothing happens because the feature is a stub or placeholder.

**Examples:**
- NPC gives quest but there's no way to fill the Mad Lib
- Evolution panel opens but is empty
- Sound effects are silent

**What we do:** Add it to the Gate 2 or Gate 3 roadmap.

### Category 5: 📊 Pedagogical Gap (Teaching doesn't land)
> The player doesn't learn anything, or the morpheme teaching is invisible.

**Examples:**
- "I completed a quest but didn't notice any word roots"
- "The NPC didn't explain what '-ful' means"
- "My kid just typed random words and didn't care about meaning"

**What we do:** Add scaffolding hints, NPC personality into prompts, morpheme badges.

---

## Part 5: What's Real vs. Aspirational

> [!IMPORTANT]
> Not everything in the Technical Bible is implemented yet. Here's what's **actually wired in code** vs. what's **designed but not built.**

| Feature | Status | Notes |
|---|---|---|
| Crystal spawning + collection | ✅ **Wired** | CrystalService → touch collection → inventory |
| 26-slot letter inventory | ✅ **Wired** | InventoryUI with grid display |
| Word Constructor / Fabricator | ✅ **Wired** | Keyboard + click input → 3D preview → slime creation |
| Slime creation from words | ✅ **Wired** | SlimeFactory validates word → assigns element/role/stats |
| Pet companion (follows you) | ✅ **Wired** | PetService renders a following slime model |
| Phase cycle (5 phases) | ✅ **Wired** | GameLoopService ticks through phases with timers |
| Phase-based lighting | ✅ **Wired** | LightingService tweens ambient/brightness per phase |
| Tutorial flow | ✅ **Wired** | TutorialService → TutorialController → 6-step guide |
| NPC spawning + ProximityPrompt | ✅ **Wired** | NPCService spawns 12 NPCs with E prompts |
| NPC dialogue (basic) | ✅ **Wired** | InteractionController → DialogueUI → text display |
| Phase banner + splash | ✅ **Wired** | HUDController shows phase name + full-screen overlay |
| Nuisance letters chase player | ⚠️ **Wired, untested** | LetterNuisanceService exists, needs playtest verification |
| Mad Lib quest generation | ⚠️ **Wired, untested** | MadLibService generates quests, unclear if slots work |
| Equipped slime → quest content | ❌ **Not wired** | MadLibService doesn't read companion slime yet |
| Morpheme-targeted quest slots | ❌ **Not wired** | Slots are generic {NOUN}, not {un-:word} yet |
| AI-generated NPC dialogue | ❌ **Not wired** | Needs Gemini API key in ServerStorage |
| Sound effects + music | ❌ **Blocked** | HTTP 403 until game is published to Roblox |
| DataStore persistence | ❌ **Blocked** | Unavailable until game is published |
| Slime evolution system | ⚠️ **Partial** | Backend exists, UI is minimal |
| Parent/educator dashboard | ⚠️ **Partial** | PedagogyDashboardUI exists, data flow untested |
| Mobile controls | ❌ **Not wired** | Desktop-only keybinds currently |

---

> [!TIP]
> **Your playtest mission:** Play through Scenes 1-5. Fill in the audit template. Every ❌, ⚠️, or 🔇 you find is a soft spot we fix in the next session. Your observations are the single most valuable input for making this game great.
