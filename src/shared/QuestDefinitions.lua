--!strict
export type StepDefinition = {
    Id: string,
    Description: string,
    Type: string,
    TargetId: string,
    Target: number?
}

export type QuestDefinition = {
    Id: string,
    Title: string,
    Description: string,
    Steps: { StepDefinition },
    Rewards: {
        XP: number,
        Words: { string }?
    }
}

local QuestDefinitions: { [string]: QuestDefinition } = {
    ["quest_001_welcome"] = {
        Id = "quest_001_welcome",
        Title = "Welcome to Psyche-Polis",
        Description = "Speak to The Administrator in the Logos District to get your bearings.",
        Steps = {
            {
                Id = "speak_admin",
                Description = "Find The Administrator at City Hall (Logos District).",
                Type = "Talk",
                TargetId = "Ruler_01",
                Target = 1
            }
        },
        Rewards = {
            XP = 100,
            Words = { "initiate" }
        }
    },
    ["quest_002_first_word"] = {
        Id = "quest_002_first_word",
        Title = "The Power of Words",
        Description = "Words have power here. Find a Word Orb to start your collection.",
        Steps = {
            {
                Id = "collect_word",
                Description = "Find and collect a Word Orb.",
                Type = "Collect",
                TargetId = "any_word", -- simplified for now
                Target = 1
            }
        },
        Rewards = {
            XP = 150
        }
    }
}

return QuestDefinitions
