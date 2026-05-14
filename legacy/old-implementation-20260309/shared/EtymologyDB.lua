--!strict
export type RootData = {
    Element: string,
    StatFocus: string,
    Color: Color3,
    Examples: {string}
}

export type SuffixData = {
    Role: string,
    StatBonus: string,
    Examples: {string}
}

local EtymologyDB = {
    Roots = {
        ["Ignis"] = {
            Element = "Fire",
            StatFocus = "Logos", -- Logic/Attack
            Color = Color3.fromRGB(239, 68, 68), -- Red
            Examples = {"Ignition", "Pyrotechnic"}
        },
        ["Aqua"] = {
            Element = "Water",
            StatFocus = "Pathos", -- Emotion/Health
            Color = Color3.fromRGB(59, 130, 246), -- Blue
            Examples = {"Aquatic", "Hydraulic"}
        },
        ["Terra"] = {
            Element = "Earth",
            StatFocus = "Ethos", -- Trust/Defense
            Color = Color3.fromRGB(34, 197, 94), -- Green
            Examples = {"Terrain", "Geology"}
        },
        ["Aer"] = {
            Element = "Air",
            StatFocus = "Speed", -- Intellect
            Color = Color3.fromRGB(202, 138, 4), -- Yellow/Gold
            Examples = {"Aerial", "Pneumatic"}
        },
        ["Umbra"] = {
            Element = "Shadow",
            StatFocus = "Pathos",
            Color = Color3.fromRGB(107, 33, 168), -- Purple
            Examples = {"Umbra", "Cryptic"}
        },
        ["Lux"] = {
            Element = "Light",
            StatFocus = "Logos",
            Color = Color3.fromRGB(245, 158, 11), -- Orange/Gold
            Examples = {"Lucid", "Photon"}
        },
		["Chron"] = {
			Element = "Air",
			StatFocus = "Speed",
			Color = Color3.fromRGB(168, 162, 158), -- Gray
			Examples = {"Chronicle", "Chronology"}
		},
		["Mort"] = {
			Element = "Shadow",
			StatFocus = "Pathos",
			Color = Color3.fromRGB(31, 41, 55), -- Dark Gray
			Examples = {"Mortal", "Mortify"}
		},
		["Vita"] = {
			Element = "Light",
			StatFocus = "Ethos",
			Color = Color3.fromRGB(16, 185, 129), -- Emerald
			Examples = {"Vital", "Vitamin"}
		},
		["Cryo"] = {
			Element = "Water",
			StatFocus = "Speed",
			Color = Color3.fromRGB(165, 243, 252), -- Cyan
			Examples = {"Cryogenic", "Cryosphere"}
		},
		["Astr"] = {
			Element = "Light",
			StatFocus = "Logos",
			Color = Color3.fromRGB(253, 224, 71), -- Bright Yellow
			Examples = {"Astronomy", "Asterisk"}
		},
		["Psych"] = {
			Element = "Shadow",
			StatFocus = "Logos",
			Color = Color3.fromRGB(217, 70, 239), -- Fuchsia
			Examples = {"Psychology", "Psychic"}
		}
    } :: { [string]: RootData },

    Suffixes = {
        -- Noun Suffixes (Tanks / Bruisers)
        ["tion"] = { Role = "Tank", StatBonus = "Ethos", Examples = {"Ignition"} },
        ["ity"] = { Role = "Tank", StatBonus = "Ethos", Examples = {"Gravity"} },
        ["ment"] = { Role = "Bruiser", StatBonus = "Ethos", Examples = {"Element"} },
        ["ness"] = { Role = "Tank", StatBonus = "Pathos", Examples = {"Darkness"} },
        ["ance"] = { Role = "Bruiser", StatBonus = "Ethos", Examples = {"Defiance"} },
        ["ence"] = { Role = "Bruiser", StatBonus = "Ethos", Examples = {"Silence"} },
        ["ship"] = { Role = "Support", StatBonus = "Pathos", Examples = {"Friendship"} },
        ["er"] = { Role = "Bruiser", StatBonus = "Speed", Examples = {"Fighter"} },
        ["or"] = { Role = "Tank", StatBonus = "Ethos", Examples = {"Creator"} },
        
        -- Verb Suffixes (Strikers / Assassins / Casters)
        ["ize"] = { Role = "Striker", StatBonus = "Logos", Examples = {"Memorize"} },
        ["ate"] = { Role = "Caster", StatBonus = "Logos", Examples = {"Create"} },
        ["fy"] = { Role = "Assassin", StatBonus = "Logos", Examples = {"Liquefy"} },
        ["en"] = { Role = "Striker", StatBonus = "Logos", Examples = {"Harden"} },
        ["ish"] = { Role = "Assassin", StatBonus = "Speed", Examples = {"Banish"} },
        
        -- Adjective Suffixes (Supports / Healers / Buffers)
        ["ous"] = { Role = "Support", StatBonus = "Pathos", Examples = {"Joyous"} },
        ["al"] = { Role = "Buffer", StatBonus = "Pathos", Examples = {"Spatial"} },
        ["ive"] = { Role = "Healer", StatBonus = "Pathos", Examples = {"Alive"} },
        ["able"] = { Role = "Healer", StatBonus = "Pathos", Examples = {"Readable"} },
        ["ible"] = { Role = "Buffer", StatBonus = "Ethos", Examples = {"Visible"} },
        ["y"] = { Role = "Support", StatBonus = "Speed", Examples = {"Shiny"} },
        ["less"] = { Role = "Striker", StatBonus = "Logos", Examples = {"Fearless"} },
        ["ful"] = { Role = "Buffer", StatBonus = "Ethos", Examples = {"Hopeful"} },
        ["ic"] = { Role = "Caster", StatBonus = "Logos", Examples = {"Heroic"} },
    } :: { [string]: SuffixData },

    -- Morpheme Whitelist for validation (Part VI of Technical Bible)
    -- These are known words that genuinely use the morpheme as a morphological component
    MorphemeWhitelist = {
        ["un-"] = {
            "unhappy", "unfair", "undo", "unclear", "unbreakable", "unknown", "unusual",
            "undo", "untie", "unwrap", "unfold", "unlock", "unplug", "unzip", "unfasten",
            "unwise", "unclear", "unlike", "until", "untrue", "unreal", "unfit"
        },
        ["de-"] = {
            "defrost", "decode", "deactivate", "decompose", "demolish", "demagnetize",
            "deplane", "derail", "destring", "devalue", "deform", "dehydrate", "deflate",
            "decompose", "dethrone", "detrain", "debug", "decolonize"
        },
        ["anti-"] = {
            "antifreeze", "antihero", "antibody", "antivirus", "antiperspirant",
            "anticlimax", "antithesis", "antigen", "antibiotic", "antisocial"
        },
        ["re-"] = {
            "rewrite", "redo", "replay", "rebuild", "reopen", "return", "reappear",
            "rearrange", "reconsider", "recompute", "recharge", "rebound", "recycle"
        },
        ["pre-"] = {
            "preheat", "preview", "preorder", "prepay", "pretest", "prehistoric",
            "preamble", "preface", "prejudge", "predict", "preliminary"
        },
        ["-ify"] = {
            "simplify", "purify", "certify", "modify", "qualify", "intensify", "amplify",
            "液化", "solidify", "beautify", "clarify", "unify", "justify", "ratify"
        },
        ["-ize"] = {
            "realize", "organize", "recognize", "emphasize", "specialize", "characterize",
            "hypothesize", "summarize", "criticize", "maximize", "minimize", "standardize"
        },
        ["-s"] = {
            "cats", "dogs", "books", "houses", "cars", "trees", "friends", "toys"
        },
        ["-ed"] = {
            "walked", "jumped", "played", "talked", "helped", "wanted", "liked", "loved"
        },
        ["-ing"] = {
            "walking", "jumping", "playing", "talking", "helping", "wanting", "liking", "loving"
        },
        ["-er"] = {
            "teacher", "fighter", "runner", "writer", "reader", "speaker", "builder", "maker"
        },
        ["-ful"] = {
            "beautiful", "wonderful", "powerful", "colorful", "helpful", "peaceful", "careful"
        },
        ["-ly"] = {
            "quickly", "slowly", "happily", "carefully", "easily", "quietly", "loudly", "daily"
        },
        ["-ness"] = {
            "happiness", "sadness", "kindness", "darkness", "brightness", "softness", "hardness"
        },
        ["-able"] = {
            "readable", "breakable", " countable", "drinkable", "eatable", "playable", "lovable"
        },
        ["-ible"] = {
            "visible", "edible", "audible", "flexible", "accessible", "comprehensible"
        },
        ["-ish"] = {
            "childish", "foolish", "selfish", "reddish", "bluish", "bookish", "snobbish"
        },
        ["-ous"] = {
            "dangerous", "famous", "joyous", "curious", "generous", "courageous", "prosperous"
        },
        ["struct-"] = {
            "structure", "construct", "destruct", "instruct", "obstruct", "reconstruct"
        },
        ["form-"] = {
            "form", "transform", "reform", "conform", "deform", "formal", "formula"
        },
        ["morph-"] = {
            "morph", "morphology", "metamorphosis", "amorphous", "poly morph"
        },
        ["phil-"] = {
            "philosophy", "philanthropy", "philodendron", "bibliophile"
        },
        ["amat-"] = {
            "amateur", "amatory", "paramour"
        },
        ["path-"] = {
            "pathos", "sympathy", "empathy", "antipathy", "apathy", "telepathy"
        },
        ["vis-"] = {
            "vision", "visible", "visual", "visit", "television", "supervise"
        },
        ["vid-"] = {
            "video", "evidence", "provide", "revise", "divide", "predict"
        },
        ["cogn-"] = {
            "cognition", "recognize", "cognizant", "incognizant", "precognition"
        },
        ["-ology"] = {
            "biology", "psychology", "geology", "technology", "anthropology", "archaeology"
        },
        ["omni-"] = {
            "omniscient", "omnipotent", "omnipresent", "omnivorous"
        },
        ["trans-"] = {
            "transform", "translate", "transport", "transplant", "transaction", "transit"
        },
        ["meta-"] = {
            "metaphor", "metadata", "metamorphosis", "metacognition", "metalanguage"
        },
        ["hyper-"] = {
            "hyperactive", "hyperbole", "hypertext", "hypertension", "hypermarket"
        },
        ["-cracy"] = {
            "democracy", "bureaucracy", "aristocracy", "theocracy", "plutocracy"
        },
        ["-archy"] = {
            "monarchy", "anarchy", "hierarchy", "oligarchy", "patriarchy"
        },
        ["reg-"] = {
            "region", "regular", "regulate", "regime", "reign", "royal"
        },
        ["meter"] = {
            "meter", "diameter", "perimeter", "speedometer", "thermometer", "barometer"
        },
        ["ordin-"] = {
            "order", "ordinary", "coordinate", "subordinate", "insubordinate"
        },
        ["pseudo-"] = {
            "pseudonym", "pseudoscience", "pseudoclassic", "pseudointellectual"
        },
        ["quasi-"] = {
            "quasi-scientific", "quasi-professional", "quasi-judicial", "quasi-religious"
        },
    }
}

return EtymologyDB
