--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LoreDB = require(ReplicatedStorage.Shared.Data.Master_Lore.LoreDB)

export type NPCData = {
	Id: string,
	Name: string,
	Archetype: string,
	District: string,
	Color: Color3,
	DialogueRoot: string,
	BuildingName: string,
}

local elementColors = {
    Water = Color3.fromHex("#3B82F6"),
    Earth = Color3.fromHex("#22C55E"),
    Light = Color3.fromHex("#FCD34D"),
    Air = Color3.fromHex("#A78BFA"),
    Fire = Color3.fromHex("#EF4444"),
    Shadow = Color3.fromHex("#4B5563"),
}

local buildingMap = {
    -- North (Brainy Borough)
    Barnaby = { District = "BrainyBorough", BuildingName = "The Grand Pavilion" },
    Ozymandias = { District = "BrainyBorough", BuildingName = "The Archive" },
    Ignis = { District = "BrainyBorough", BuildingName = "City Hall" },
    
    -- East (Action Alley)
    Gribble = { District = "ActionAlley", BuildingName = "The Outpost" },
    Kael = { District = "ActionAlley", BuildingName = "The Arena" },
    Zafir = { District = "ActionAlley", BuildingName = "The Sanctum" },
    
    -- South (Heartwood Grove)
    Vlad = { District = "HeartwoodGrove", BuildingName = "The Sanctuary" },
    Chesty = { District = "HeartwoodGrove", BuildingName = "The Market" },
    Yorick = { District = "HeartwoodGrove", BuildingName = "The Docks" },
    
    -- West (Whisper Winds)
    Martha = { District = "WhisperWinds", BuildingName = "Cloud Spire" },
    Nyx = { District = "WhisperWinds", BuildingName = "The Speakers" },
    Pygmalion = { District = "WhisperWinds", BuildingName = "The Studio" },
}

local NPCDataList: { [string]: NPCData } = {}

if LoreDB and LoreDB.NPCs then
    local npcCount = 0
    for name, data in pairs(LoreDB.NPCs) do
        npcCount = npcCount + 1
    end
    print("[NPCData] Loaded " .. npcCount .. " NPCs from LoreDB")
    
    for name, data in pairs(LoreDB.NPCs) do
        local mapping = buildingMap[name] or { District = "Hub", BuildingName = "TownSquare" }
        local elem = data.PreferredElement[1] or "Water"
        local color = elementColors[elem] or Color3.new(1,1,1)
        
        NPCDataList[name] = {
            Id = name,
            Name = name,
            Archetype = data.Archetype,
            District = mapping.District,
            Color = color,
            DialogueRoot = data.Dialogue and data.Dialogue.Dawn and data.Dialogue.Dawn[1] or "Hello!",
            BuildingName = mapping.BuildingName,
        }
    end
end

return NPCDataList
