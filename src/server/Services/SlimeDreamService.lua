--!strict
--==============================================================
-- MMMM Context: Manages the Semantic Ecology's idle state by allowing Pet Slimes to procedurally generate haikus based on their Etymology.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local EtymologyDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("EtymologyDB"))

local SlimeDreamService = Knit.CreateService {
    Name = "SlimeDreamService",
    Client = {
        SlimeDreamed = Knit.CreateSignal(),
    },
}

-- Poetry templates based on element
local TEMPLATES = {
    Fire = {
        "The ash of %s waits to be kindled.",
        "%s is but a spark in the dark.",
        "Burn through %s, and leave only light."
    },
    Water = {
        "Does %s flow or stagnate?",
        "Drowning in thoughts of %s...",
        "The tides whisper of %s."
    },
    Earth = {
        "%s is etched in stone.",
        "Roots dig deep seeking %s.",
        "Can a mountain feel %s?"
    },
    Air = {
        "%s scatters to the four winds.",
        "A breath of %s.",
        "The sky holds nothing but %s."
    },
    Shadow = {
        "%s hides from the sun.",
        "The void echoes with %s.",
        "Every shadow is cast by %s."
    },
    Light = {
        "%s illuminates the truth.",
        "Blinded by the brilliance of %s.",
        "Dawn breaks over %s."
    },
    Normal = {
        "I ponder the meaning of %s.",
        "%s is a strange concept.",
        "Why did you weave %s into me?"
    }
}

function SlimeDreamService:KnitStart()
    print("[SlimeDreamService] Slimes have begun to dream.")
    
    task.spawn(function()
        while true do
            task.wait(math.random(15, 30)) -- Every 15-30 seconds
            pcall(function() self:TriggerRandomDream() end)
        end
    end)
end

function SlimeDreamService:TriggerRandomDream()
    local SlimeFactory = Knit.GetService("SlimeFactory")
    if not SlimeFactory then return end
    
    local players = Players:GetPlayers()
    if #players == 0 then return end
    local randPlayer = players[math.random(1, #players)]
    
    local slimes = SlimeFactory:GetPlayerSlimes(randPlayer)
    if not slimes then return end
    
    local slimeArray = {}
    for _, slime in pairs(slimes) do
        table.insert(slimeArray, slime)
    end
    
    if #slimeArray == 0 then return end
    
    local dreamer = slimeArray[math.random(1, #slimeArray)]
    
    local templates = TEMPLATES[dreamer.Element] or TEMPLATES.Normal
    local phrase = templates[math.random(1, #templates)]
    local dreamText = string.format(phrase, dreamer.Term)
    
    self.Client.SlimeDreamed:FireAll(randPlayer, dreamer.InstanceId, dreamText)
end

return SlimeDreamService
