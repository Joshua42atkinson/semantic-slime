--!strict
-- EnvironmentConfig: authoritative data for districts, ambient layers, and events

export type AmbientLayer = {
    Id: string,
    Type: "Audio" | "VFX" | "Prop",
    AssetId: string?,
    Color: Color3?,
    Size: Vector3?,
    AttachmentOffset: Vector3?,
    Intensity: number?,
    Trigger: "AlwaysOn" | "PlayerProximity" | "Event",
    TriggerParams: {[string]: any}?,
}

export type District = {
    Name: string,
    Archetype: string,
    Position: Vector3,
    Radius: number,
    Description: string,
    AmbientLayers: {AmbientLayer},
    NPCSchedules: {
        Morning: {string},
        Noon: {string},
        Evening: {string},
        Night: {string},
    },
    MicroEvents: {{
        Id: string,
        Interval: number,
        Duration: number,
        Description: string,
        AudioCue: string?,
        VFXCue: string?,
    }},
    MacroEvents: {{
        Id: string,
        Trigger: "Hourly" | "Daily" | "CommunityGoal",
        Description: string,
        AudioCue: string?,
        VFXCue: string?,
    }},
}

local EnvironmentConfig = {}

EnvironmentConfig.Districts = {
    ["Town Square"] = {
        Name = "Town Square",
        Archetype = "Self",
        Position = Vector3.new(0, 0, 0),
        Radius = 90,
        Description = "Central hub with fountain, bulletin board, and event stage",
        AmbientLayers = {
            {
                Id = "TS_BaseLoop",
                Type = "Audio",
                AssetId = "rbxassetid://9123456701",
                Trigger = "AlwaysOn",
                Intensity = 0.7,
            },
            {
                Id = "TS_FountainMist",
                Type = "VFX",
                AssetId = "rbxassetid://8123456702",
                Trigger = "AlwaysOn",
                Intensity = 1,
            },
            {
                Id = "TS_Spotlight",
                Type = "Prop",
                AssetId = "rbxassetid://7123456703",
                Trigger = "Event",
                TriggerParams = {Event = "HeraldBroadcast"},
            },
        },
        NPCSchedules = {
            Morning = {"Barnaby", "Yorick"},
            Noon = {"Barnaby", "Ozymandias", "Ignis"},
            Evening = {"Ignis", "Vlad"},
            Night = {"Vlad"},
        },
        MicroEvents = {
            {
                Id = "TS_BulletinReveal",
                Interval = 300,
                Duration = 30,
                Description = "New community challenges posted",
                AudioCue = "rbxassetid://6123456704",
                VFXCue = "rbxassetid://5123456705",
            },
        },
        MacroEvents = {
            {
                Id = "HeraldBroadcast",
                Trigger = "Hourly",
                Description = "Ring-wide announcement and light show",
                AudioCue = "rbxassetid://4123456706",
                VFXCue = "rbxassetid://3123456707",
            },
        },
    },
    ["Scholar's District"] = {
        Name = "Scholar's District",
        Archetype = "Wise Old Man",
        Position = Vector3.new(110, 0, 0),
        Radius = 70,
        Description = "Tiered libraries with holographic lexicons",
        AmbientLayers = {
            {
                Id = "SD_BaseLoop",
                Type = "Audio",
                AssetId = "rbxassetid://9023456701",
                Trigger = "AlwaysOn",
                Intensity = 0.6,
            },
            {
                Id = "SD_HoloPages",
                Type = "VFX",
                AssetId = "rbxassetid://8023456702",
                Trigger = "PlayerProximity",
                TriggerParams = {Radius = 12},
            },
        },
        NPCSchedules = {
            Morning = {"Ozymandias", "Martha"},
            Noon = {"Ozymandias", "Ignis"},
            Evening = {"Martha"},
            Night = {"Pygmalion"},
        },
        MicroEvents = {
            {
                Id = "SD_StudyCircle",
                Interval = 240,
                Duration = 45,
                Description = "NPCs host pronunciation drills",
                AudioCue = "rbxassetid://7023456703",
            },
        },
        MacroEvents = {
            {
                Id = "SD_LexiconCascade",
                Trigger = "CommunityGoal",
                Description = "Unlocked when players complete 50 MadLibs",
                AudioCue = "rbxassetid://6023456704",
                VFXCue = "rbxassetid://5023456705",
            },
        },
    },
    -- Additional districts (Merchant's Quarter, etc.) would follow the same pattern
}

EnvironmentConfig.GlobalEvents = {
    HeraldBell = {
        Interval = 3600,
        AudioCue = "rbxassetid://4023456706",
        Payload = {
            TownSquare = "HeraldBroadcast",
            ScholarsDistrict = "SD_LexiconCascade",
        },
    },
}

return EnvironmentConfig
