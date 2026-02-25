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
            StatFocus = "Debuff", -- Psychological Damage
            Color = Color3.fromRGB(107, 33, 168), -- Purple
            Examples = {"Umbra", "Cryptic"}
        },
        ["Lux"] = {
            Element = "Light",
            StatFocus = "Buff", -- Truth/Reveal
            Color = Color3.fromRGB(245, 158, 11), -- Orange/Gold
            Examples = {"Lucid", "Photon"}
        }
    } :: { [string]: RootData },

    Suffixes = {
        ["tion"] = { Role = "Tank", StatBonus = "Ethos", Examples = {"Ignition"} },
        ["ity"] = { Role = "Tank", StatBonus = "Ethos", Examples = {"Gravity"} },
        ["ment"] = { Role = "Bruiser", StatBonus = "Ethos", Examples = {"Element"} },
        
        ["ize"] = { Role = "Striker", StatBonus = "Logos", Examples = {"Memorize"} },
        ["ate"] = { Role = "Caster", StatBonus = "Logos", Examples = {"Create"} },
        ["fy"] = { Role = "Assassin", StatBonus = "Logos", Examples = {"Liquefy"} },
        
        ["ous"] = { Role = "Support", StatBonus = "Pathos", Examples = {"Joyous"} },
        ["al"] = { Role = "Buffer", StatBonus = "Pathos", Examples = {"Spatial"} },
        ["ive"] = { Role = "Healer", StatBonus = "Pathos", Examples = {"Alive"} },
    } :: { [string]: SuffixData }
}

return EtymologyDB
