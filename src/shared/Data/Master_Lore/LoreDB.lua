--!strict
-- src/shared/Data/Master_Lore/LoreDB.lua
-- The single source of truth for NPC data and Quests in Syllable Springs
-- Maps directly from the Lore Trinity documentation

local LoreDB = {}

LoreDB.Phases = {
    Dawn = "06:00",
    Day = "12:00",
    Dusk = "18:00",
    Night = "20:00"
}

LoreDB.NPCs = {
    Barnaby = {
        Archetype = "The Innocent",
        District = "Brainy Borough",
        PreferredElement = {"Water"},
        PreferredClass = {"Support"},
        Teaches = {"-s", "-ed"}, -- Baseline: plurals and past tense
        EvolutionRole = "word_identification", -- Teaches what word types ARE
        Dialogue = {
            Dawn = {
                "Look at all the shiny letters! I tried to eat an 'O' once because it looked like a donut. It tasted like math.",
                "Good morning friend! Did you sleep good? I don't really sleep 'cause I think with my eye and eyes are always open!",
                "The sunrise is SO PRETTY! Almost as pretty as... oh wait, nothing is as pretty as YOU, best friend!"
            },
            Day = {
                "You're making words? Wow! Can you make a word for when you really want a hug but your arms are too long?",
                "I tried to help build a house once but I used flowers instead of bricks. It was VERY pretty but also VERY leaky...",
                "Words are like people - they all have jobs! Some words are strong like builders and some are soft like pillows!"
            },
            Dusk = {
                "Friend! I have a tiny problem that is actually a giant disaster! Please help!",
                "I was trying to help but I think I made it worse? Don't be mad! Please? I didn't mean to!",
                "The sky is getting dark and that makes my tummy feel funny... can you help me find a super bright word?"
            },
            Night = {
                "I don't like the dark! The shadows look like mean broccoli! Be careful out there!",
                "Friend! Please don't leave me! The dark has too many corners and corners are scary!",
                "I know I'm big but big things can be scared too! Will you protect me? I'll protect you too! Maybe..."
            }
        },
        Quests = {
            -- Mad Lib quests are generated from QuestData.NPCChains
            -- This field kept for potential future quest board features
        }
    },
    Yorick = {
        Archetype = "The Everyman",
        District = "Heartwood Grove",
        PreferredElement = {"Earth"},
        PreferredClass = {"Striker"},
        Teaches = {"struct-", "-ment", "-tion", "-able"}, -- Construction/Utility
        EvolutionRole = "fuse_noun", -- Noun Fusion - combines two words into a phrase
        Dialogue = {
            Dawn = {
                "Morning. Watch your step, I just swept up all those loose vowels. Slip hazard.",
                "Early shift today. The letters get all over the place overnight. And DON'T get me started on the semicolons - they're everywhere.",
                "You know, I used to work the night shift. That's when the scary stuff comes out. Much prefer the day shift."
            },
            Day = {
                "The Slime Synthesizer is running hot today. Make sure you lift those heavy syllables with your knees, not your back.",
                "Word of advice: don't stack your consonants too high. Last guy did that and the whole thing came crashing down. Took me three hours to sweep it up.",
                "You know what makes a good word? Balance. Not too flashy, not too weak. Just gets the job done. Like me."
            },
            Dusk = {
                "Hey. Clock's ticking and I got a situation preventing me from clocking out. Help a guy out?",
                "Look, I would do this myself but I've got three other tasks on my queue. Union rules - can't exceed my workload.",
                "Listen, I would've handled this already but something came up. Literally. A letter 'S' fell on my lunch break. Workers' comp nightmare."
            },
            Night = {
                "Mandatory overtime. Great. Guess I'll just stand here and rattle menacingly. Don't forget to log your combat hours against The Typos.",
                "You know, I've seen worse. Last week there was a whole swarm of exclamation points. THAT was a nightmare.",
                "Night shift differential doesn't even cover the danger pay. I told the Mayor - either more pay or I'm walking. Still waiting on an answer."
            }
        },
        Quests = {}
    },
    Kael = {
        Archetype = "The Hero",
        District = "Action Alley",
        PreferredElement = {"Light"},
        PreferredClass = {"Defense"},
        Teaches = {"-ing", "-er"}, -- Progressive and agent suffixes
        EvolutionRole = "action_pairing", -- Action Pairing - adds verb-derived nouns to phrases
        Dialogue = {
            Dawn = {
                "The sun rises, and with it, a new campaign! Gather the scattered crystals of fate, squire! Leave no vowel behind!",
                "By the horns of my ancestors! Another day dawns! Go forth and collect the letters of destiny!",
                "The dawn calls to us, brave one! Will you answer with the valor of a thousand knights?!"
            },
            Day = {
                "The Slime Synthesizer hums with the power of a thousand bards! Forge your Etymons well, for they are your linguistic broadswords!",
                "A true hero strengthens their arsenal! Build your words with the precision of a master blacksmith!",
                "Remember, squire: a well-constructed word is mightier than any physical blade!"
            },
            Dusk = {
                "Halt! The shadows lengthen, and the realm cries out for aid! Will you answer the call of duty, or will this [Mundane Item] remain unpolished?!",
                "A dark threat emerges! Well... moderately concerning issue... But it needs a HERO! ...I mean, it needs YOU!",
                "I sense great disturbance in the linguistic balance. The realm requires your unique skills!"
            },
            Night = {
                "The Typos are upon us! Stand firm! If any shadow comes near the flowerbeds, they shall taste my steel!",
                "Fear not, companion! I shall hold the line! ...What line? Oh, the... imaginary one! Yes!",
                "The darkness tests us! But we are the LIGHT! ...mostly me. You're doing great too though!"
            }
        },
        Quests = {}
    },
    Martha = {
        Archetype = "The Caregiver",
        District = "Whisper Winds",
        PreferredElement = {"Water", "Light"},
        PreferredClass = {"Support"},
        Teaches = {"-ful", "-ly", "-ness"}, -- Fullness, adverb, state
        EvolutionRole = "emotional_adjectives", -- Emotional Adjectives - adds feeling-words to phrases
        Dialogue = {
            Dawn = {
                 "Good morning, sweetie! The letter crystals are lovely today, but don't run too fast while you collect them, or you'll trip and skin your knee!",
                 "Oh, look at you! You're up so early! Did you eat? I have some hot gravel water, it's very nourishing!",
                 "The dawn is beautiful, dear, but don't forget your breakfast! Growing letters need fuel!"
            },
            Day = {
                "Working at the Slime Synthesizer takes so much energy. Make sure your Etymons have plenty of vowels, they need a balanced diet to grow big and strong!",
                "Sweetie, you're working too hard! Take a break and have some soup. The hot water is very hydrating!",
                "A well-fed word is a strong word! Now eat your consonants, they're good for you!"
            },
            Dusk = {
                "The air is getting chilly, and the shadows are looking a bit peeky. Come here, let me fix this [Mundane Problem] before the night sets in.",
                "Oh dear, you look tired. Let me make you something warm. What? Oh, the quest! Yes, yes, after soup!",
                "The wind is picking up! Are you wearing enough layers? Never mind, I'll knit you something!"
            },
            Night = {
                "Oh, I don't like these Typos one bit! You stay behind me, dear! If any shadows try to touch you, they'll get a swift smack on the bottom!",
                "Don't worry, I'll protect you! I've chased away scarier things than some measly shadows. Back in my day, we didn't HAVE The Static, we just had stern looks!",
                "The Typos! In MY town?! Absolutely not! Scram before I call the neighborhood watch!"
            }
        },
        Quests = {}
    },
    Gribble = {
        Archetype = "The Explorer",
        District = "Action Alley",
        PreferredElement = {"Air"},
        PreferredClass = {"Striker"},
        Teaches = {"-able", "-ible"}, -- Capability suffixes
        EvolutionRole = "possessives", -- Possessives - teaches ownership with apostrophe-s
        Dialogue = {
            Dawn = {
                "The reset! Fascinating! New letter crystals, fresh typography scattered across the terrain! I must chart their spawn coordinates immediately!",
                "Another cycle begins! The letter distribution has refreshed! Quick, to the field notes!",
                "Did you know the letters spawn in predictable patterns? I charted it! Want to see my charts? They're mostly guesses but they're PROFESSIONAL guesses!"
            },
            Day = {
                "Have you studied the internal mechanisms of the Slime Synthesizer? I tried to take it apart once to see how it synthesizes vowels. Martha hit me with a broom.",
                "The Synthesizer's output follows mathematical sequences! I've mapped seventeen different patterns! Okay, I got distracted after that and mapped the cobwebs.",
                "Words are just linguistic organisms! Study their morphology! Know their taxonomy! CLASSIFY THEM!"
            },
            Dusk = {
                "The lighting is changing, which means hidden runes might reveal themselves! Grab your gear, we have an anomaly to investigate involving a [Mundane Object]!",
                "Twilight reveals secrets! The shadows form ancient glyphs! Or maybe that's just the fence. Either way, we must INVESTIGATE!",
                "My instruments detect unusual linguistic fluctuations! Quick, before the data is lost to the darkness!"
            },
            Night = {
                "Look at the morphological degradation on these Typos! Astounding! Hold still, you terrifying beast, I need to measure your cranial capacity!",
                "Fascinating! The Static creatures exhibit unique behavioral patterns! They're attacking! How INTERESTING!",
                "The shadows reveal hidden truths! Don't just fight them, STUDY them! Note their attack patterns!"
            }
        },
        Quests = {}
    },
    Nyx = {
        Archetype = "The Rebel",
        District = "Whisper Winds",
        PreferredElement = {"Air", "Shadow"},
        PreferredClass = {"Striker"},
        Teaches = {"un-", "de-", "anti-", "-ify"},
        EvolutionRole = "negation_suffixes",
        Dialogue = {
            Dawn = {
                "Ugh, morning already? Time to pick up the alphabet off the ground. Again. Who even scatters these things anyway?",
                "The sun's too bright. My eyeliner is running. And the crystals are spawning RIGHT in the middle of my nap spot.",
                "Hey, did you know that if you say 'dawn' backwards it's 'nwad'? That's not a real word but it SHOULD be."
            },
            Day = {
                "The Slime Synthesizer is cool and all, but have you tried plugging a guitar into it? The feedback loop is insane.",
                "Everyone's being so PRODUCTIVE today. It's disgusting. Come on, let's make a word that's totally useless but sounds awesome.",
                "Words are just sounds we all agreed to. What if we UN-agree? What does THAT sound like?"
            },
            Dusk = {
                "Hey! You! Quit running errands for the squares and help me cause some actual fun around here!",
                "The golden hour is perfect for one thing: MISCHIEF. You in or what?",
                "Kael's been standing at attention for SIX HOURS. That can't be healthy. Let's... help him relax."
            },
            Night = {
                "Finally, the Typos are here! Turn up the volume! Let's see how these glitches handle a high-C power chord!",
                "The Static thinks it can erase everything? HA! Try erasing THIS! *SCREEEEEECH*",
                "Chaos vs. chaos! Finally, a fair fight! Let's GOOOO!"
            }
        },
        Quests = {}
    },
    Vlad = {
        Archetype = "The Lover",
        District = "Heartwood Grove",
        PreferredElement = {"Water"},
        PreferredClass = {"Support"},
        Teaches = {"phil-", "amat-", "path-", "-ous", "-ly"},
        EvolutionRole = "descriptive_adjectives",
        Dialogue = {
            Dawn = {
                "The sun rises, cruel and bright! Protect your eyes, my friend, and gather the crystals before they evaporate like a forgotten dream!",
                "Another day begins! The light is so... harsh. But perhaps that is why the crystals sparkle so beautifully!",
                "Do be careful in this harsh light, dear Weaver! A vampire's work is never done!"
            },
            Day = {
                "Listen to the Slime Synthesizer hum! It is the beating heart of Syllable Springs, forging love and logic from the ether!",
                "The words you craft today shall become the poetry of tomorrow! Make them BEAUTIFUL!",
                "Ah, the sweet sound of creation! It fills my unbeating heart with hope!"
            },
            Dusk = {
                "Ah, the twilight. The perfect lighting for melancholy. Come, let us solve the town's emotional turmoil before the dark takes hold!",
                "The shadows lengthen, and with them, my creativity blooms! A quest, you say? But of course!",
                "The evening brings wisdom to even the darkest of souls. What emotional challenge shall we conquer together?"
            },
            Night = {
                "The Static approaches! They seek to erase all beauty and color! Defend the poetry, Weaver!",
                "The Typos are here! They wish to destroy all that is beautiful! We must fight for ART!",
                "Stay behind me, my dramatic friend! I'll protect you... from a safe distance!"
            }
        },
        Quests = {}
    },
    Pygmalion = {
        Archetype = "The Creator",
        District = "Whisper Winds",
        PreferredElement = {"Earth", "Ice", "Water"},
        PreferredClass = {"Tank", "Builder"},
        Teaches = {"struct-", "form-", "-ify", "-ize", "morph-"},
        EvolutionRole = "structural_suffixes",
        Dialogue = {
            Dawn = {
                "Ah, the canvas resets! The morning frost brings fresh, uncarved letters to 8 Winter Street. Gather the raw clay, my friend!",
                "The new day sparkles like untouched snow! Perfect for gathering creative materials!",
                "Dawn at 8 Winter Street is magical - the snow never melts here! Perfect conditions for inspiration!"
            },
            Day = {
                "The Slime Synthesizer hums a beautiful, creative tune! Remember, there are no mistakes in word-crafting, only happy little grammatical accidents!",
                "Words are my paint! Letters are my clay! The possibilities are ENDLESS!",
                "Every word you forge today could be part of my next masterpiece! Choose wisely, artist!"
            },
            Dusk = {
                "The golden hour! The lighting is perfect, but my sculpture is missing its final piece! Quick, before we lose the aesthetic shadows!",
                "Weaver! I need your creative vision! The piece simply isn't complete without the right linguistic material!",
                "The evening brings clarity. Help me find the perfect word to finish this absolutely MAGNIFICENT failure... I mean, masterpiece!"
            },
            Night = {
                "The Static is here! They have no appreciation for form or structure! Defend the gallery, Weaver!",
                "They dare enter my studio?! The nerve of those glitchy, poorly-rendered monstrosities!",
                "Quick, protect the sculptures! The Static wants to erase all beauty from the world!"
            }
        },
        Quests = {}
    },
    Chesty = {
        Archetype = "The Jester",
        District = "Heartwood Grove",
        PreferredElement = {"Air", "Shadow"},
        PreferredClass = {"Striker"},
        Teaches = {"-ish", "-esque", "pseudo-", "quasi-"},
        EvolutionRole = "approximation_suffixes",
        Dialogue = {
            Dawn = {
                "Ding ding! The daily reset! Quick, grab those letters before the server sweeps them up!",
                "New day, new location! Did you find me yet? I'm a tricky little chest!",
                "The game has respawned! Time for a fresh batch of chaos!"
            },
            Day = {
                "The Slime Synthesizer is just a giant blender, change my mind. Toss those vowels in and see what explodes!",
                "Words are just LEGO blocks for adults! Build something silly!",
                "Hehehe, want to cause some chaos later? I've got IDEAS!"
            },
            Dusk = {
                "Sun's going down! Time for the serious NPCs to hand out boring chores. Come to me for the actual fun stuff!",
                "Psst! Want to pull a prank? I've got a great bit planned!",
                "The golden hour of tomfoolery is upon us! Let's cause some harmless trouble!"
            },
            Night = {
                "Uh oh, The Static is here! I am just a normal, boring box! Nothing to see here! You deal with them, Weaver!",
                "The humorless blobs are here! They're such buzzkills!",
                "I'm going into hiding! Pretend I'm just decor! Good luck, partner!"
            }
        },
        Quests = {}
    },
    Ozymandias = {
        Archetype = "The Sage",
        District = "The Brainy Borough",
        PreferredElement = {"Light", "Air"},
        PreferredClass = {"Support", "Mage"},
        Teaches = {"vis-", "vid-", "cogn-", "scien-", "-ology", "omni-"},
        EvolutionRole = "determiners",
        Dialogue = {
            Dawn = {
                "I cannot see the sun, Weaver, but I feel the weight of new vocabulary falling upon the grass. Gather the letters; the day demands meaning.",
                "The dawn breaks like a new paragraph in the story of existence. What words shall we write today?",
                "Ah, the reset. The universe folds upon itself and begins again. The crystals await your collection."
            },
            Day = {
                "The Slime Synthesizer sings a song of creation. Can you hear the consonants colliding? It is the sound of order.",
                "Words are living things, Weaver. Treat them with respect. Would you handle a butterfly with care? Then handle your vowels gently.",
                "The Fabricator—pardon, the Synthesizer—hums with potential. What shall you forge from the chaos?"
            },
            Dusk = {
                "The light fades, and the world grows ambiguous. Come to me. Let us test your mind before the Static attempts to erase it.",
                "The twilight brings questions. I have one for you. What walks on four legs at dawn, two at noon, and three at dusk?",
                "The shadows lengthen. The Static draws near. But first, a riddle. Are you ready?"
            },
            Night = {
                "The Typos approach! They are the void of meaning! Strike them with your most articulate Etymons!",
                "The enemies of meaning are here! They wish to erase all wisdom! Defend the truth, Weaver!",
                "I cannot see them, but I feel their emptiness. They are the absence of definition. FIGHT!"
            }
        },
        Quests = {}
    },
    Zafir = {
        Archetype = "The Magician",
        District = "Action Alley",
        PreferredElement = {"Fire", "Air"},
        PreferredClass = {"Mage", "Striker"},
        Teaches = {"trans-", "meta-", "hyper-", "-fy", "-ize"},
        EvolutionRole = "transformation_suffixes",
        Dialogue = {
            Dawn = {
                "The server refreshes! Do you feel the static electricity of the Letter Crystals? Gather them quickly before their potential energy decays!",
                "A new day, a new dimension of possibilities! The vocabulary is reshaping!",
                "The dawn brings fresh potential! The morphemes are aligniiiing!"
            },
            Day = {
                "The Slime Synthesizer is essentially a magical particle accelerator. Smash those vowels together and let's see what kind of semantic radiation we get!",
                "Words are just magical formulas waiting to be cast! Add the right suffixes and watch them transform!",
                "Ooh, what happens if I combine 'ultra' with 'explosion'? ...Let's find out together!"
            },
            Dusk = {
                "The ambient lighting is perfect for complex spellwork! Come here, Weaver, I need you to help me test a highly unstable hypothesis!",
                "I may have... slightly... accidentally... enchanted the wrong thing. Don't be mad!",
                "Quick! Before the spell becomes permanent! We need to counter-morphogenesis this situation!"
            },
            Night = {
                "The Typos have breached the quarantine zone! Time to test our defensive vocabulary! Unleash the syllables!",
                "These are just failed magical formulas! We can REWRITE them!",
                "The semantic barrier is weakening! Channel your inner wizard, Weaver!"
            }
        },
        Quests = {}
    },
    Ignis = {
        Archetype = "The Ruler",
        District = "Brainy Borough",
        PreferredElement = {"Earth", "Fire"},
        PreferredClass = {"Tank", "Builder"},
        Teaches = {"-cracy", "-archy", "reg-", "struct-", "meter", "ordin-"},
        EvolutionRole = "formal_certification",
        Dialogue = {
            Dawn = {
                "Attention citizens! The crystals have spawned on schedule! I expect a 20% increase in collection efficiency today! Get moving!",
                "The daily reset has occurred. Forms must be filed. Productivity must increase!",
                "New day, new opportunities for administrative excellence! Gather those letters!"
            },
            Day = {
                "Remember, you need a Class-A permit to operate the Slime Synthesizer! Keep your vowels organized and clean up your morphological waste!",
                "The Synthesizer requires proper licensing! No unauthorized word creation without Form 27-B!",
                "Construct with responsibility! Every word has consequences!"
            },
            Dusk = {
                "The schedule demands civic action! Weaver, report to me at once, I have three clipboards of municipal errors that need your Etymons to fix!",
                "Citizen! You there! We have a code violation that needs immediate attention!",
                "The evening brings... more work. Always more work. What needs fixing now?"
            },
            Night = {
                "The Static is violating several noise ordinances and zoning laws! Defend the infrastructure, Weaver! Do not let them erase the crosswalks!",
                "Anarchy! CHAOS! The filing system is under attack! FIGHT!",
                "The Typos threaten our permit system! We must defend proper documentation!"
            }
        },
        Quests = {}
    }
}

return LoreDB
