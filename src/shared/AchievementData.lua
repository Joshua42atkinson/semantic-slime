--!strict
-- Definition of all game achievements

export type Achievement = {
    Id: string,
    Name: string,
    Description: string,
    Icon: string,
    Category: "Collection" | "Progression" | "Cleverness" | "Social",
    Requirement: number, -- For progressive tracking (e.g., collect 10 words)
}

local AchievementData: { [string]: Achievement } = {
    -- Collection
    ["first_slime"] = {
        Id = "first_slime",
        Name = "It's Alive!",
        Description = "Fabricate your first Slime.",
        Icon = "🧪",
        Category = "Collection",
        Requirement = 1,
    },
    ["slime_collector_10"] = {
        Id = "slime_collector_10",
        Name = "Slime Rancher",
        Description = "Fabricate 10 Slimes.",
        Icon = "✨",
        Category = "Collection",
        Requirement = 10,
    },
    ["slime_collector_50"] = {
        Id = "slime_collector_50",
        Name = "Slime Hoarder",
        Description = "Fabricate 50 Slimes.",
        Icon = "🌟",
        Category = "Collection",
        Requirement = 50,
    },
    ["first_word"] = {
        Id = "first_word",
        Name = "Vocabulary Voyager",
        Description = "Capture your first wild Etymon.",
        Icon = "📖",
        Category = "Collection",
        Requirement = 1,
    },
    ["word_master_50"] = {
        Id = "word_master_50",
        Name = "Dictionary Dash",
        Description = "Capture 50 wild Etymons.",
        Icon = "📚",
        Category = "Collection",
        Requirement = 50,
    },

    -- Progression
    ["complete_tutorial"] = {
        Id = "complete_tutorial",
        Name = "Welcome to Syllable Springs",
        Description = "Complete the introductory tutorial.",
        Icon = "🎓",
        Category = "Progression",
        Requirement = 1,
    },
    ["quest_5"] = {
        Id = "quest_5",
        Name = "Helping Hand",
        Description = "Complete 5 Mad-Lib quests for NPCs.",
        Icon = "🤝",
        Category = "Progression",
        Requirement = 5,
    },
    ["quest_25"] = {
        Id = "quest_25",
        Name = "Town Hero",
        Description = "Complete 25 Mad-Lib quests.",
        Icon = "🏅",
        Category = "Progression",
        Requirement = 25,
    },

    -- Cleverness (was Combat)
    ["first_madlib"] = {
        Id = "first_madlib",
        Name = "Wordsmith Apprentice",
        Description = "Complete your first Mad Lib quest.",
        Icon = "📝",
        Category = "Cleverness",
        Requirement = 1,
    },
    ["shake_letters"] = {
        Id = "shake_letters",
        Name = "Not Today, Letters!",
        Description = "Shake off 10 clingy nuisance letters by using them in words.",
        Icon = "🤚",
        Category = "Cleverness",
        Requirement = 10,
    },
    ["wordbuilder"] = {
        Id = "wordbuilder",
        Name = "Walking Dictionary",
        Description = "Construct 25 words from collected letters.",
        Icon = "📖",
        Category = "Cleverness",
        Requirement = 25,
    },
    ["madlib_master"] = {
        Id = "madlib_master",
        Name = "Mad Lib Legend",
        Description = "Complete 10 Mad Lib quests.",
        Icon = "🏆",
        Category = "Cleverness",
        Requirement = 10,
    },

    -- Elements
    ["fire_master"] = {
        Id = "fire_master",
        Name = "Inferno Caller",
        Description = "Fabricate 5 Fire-element Slimes.",
        Icon = "🔥",
        Category = "Collection",
        Requirement = 5,
    },
    ["water_master"] = {
        Id = "water_master",
        Name = "Tide Bringer",
        Description = "Fabricate 5 Water-element Slimes.",
        Icon = "💧",
        Category = "Collection",
        Requirement = 5,
    },
    ["earth_master"] = {
        Id = "earth_master",
        Name = "Terra Former",
        Description = "Fabricate 5 Earth-element Slimes.",
        Icon = "🌿",
        Category = "Collection",
        Requirement = 5,
    },
    ["air_master"] = {
        Id = "air_master",
        Name = "Wind Walker",
        Description = "Fabricate 5 Air-element Slimes.",
        Icon = "💨",
        Category = "Collection",
        Requirement = 5,
    },
    ["shadow_master"] = {
        Id = "shadow_master",
        Name = "Void Schemer",
        Description = "Fabricate 5 Shadow-element Slimes.",
        Icon = "🌑",
        Category = "Collection",
        Requirement = 5,
    },
    ["light_master"] = {
        Id = "light_master",
        Name = "Sun Bringer",
        Description = "Fabricate 5 Light-element Slimes.",
        Icon = "✨",
        Category = "Collection",
        Requirement = 5,
    },

    -- Social / Other
    ["pet_companion"] = {
        Id = "pet_companion",
        Name = "Best Friends",
        Description = "Set a Slime as your Companion.",
        Icon = "❤️",
        Category = "Social",
        Requirement = 1,
    },
    ["explorer"] = {
        Id = "explorer",
        Name = "Globe Trotter",
        Description = "Visit all 4 districts of Syllable Springs.",
        Icon = "🗺️",
        Category = "Progression",
        Requirement = 4,
    }
}

return AchievementData
