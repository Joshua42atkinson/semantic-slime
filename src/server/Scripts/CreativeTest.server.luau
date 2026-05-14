--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- This script automatically runs the three new creative systems to let the user view them
-- instantly when testing the game in Roblox Studio.
-- Set DEV_MODE to true to enable automatic creative simulations.
local DEV_MODE = false

if not DEV_MODE then
    print("[CreativeTest] DEV_MODE is OFF — skipping creative simulations. Set DEV_MODE = true in CreativeTest to enable.")
    return
end

Knit.OnStart():andThen(function()
    print("[CreativeTest] Waiting for a player to run the creative simulation...")
    
    local function runSimulation(player: Player)
        task.wait(5)
        
        -- 1. Feral Typo Spawn
        print("[CreativeTest] SCENARIO 1: Triggering a Feral Typo spawn")
        local FeralTypoService = Knit.GetService("FeralTypoService")
        if FeralTypoService then
            pcall(function() FeralTypoService:SpawnTypo(player, "gibbrsh") end)
        end
        
        task.wait(15)
        
        -- 2. Slime Dreams
        print("[CreativeTest] SCENARIO 2: Forcing a Slime Dream")
        local SlimeFactory = Knit.GetService("SlimeFactory")
        if SlimeFactory then
            pcall(function() SlimeFactory:CreateSlime(player, "lucid") end)
            pcall(function() SlimeFactory:CreateSlime(player, "ignis") end)
        end
        
        task.wait(2)
        
        local SlimeDreamService = Knit.GetService("SlimeDreamService")
        if SlimeDreamService then
            pcall(function() SlimeDreamService:TriggerRandomDream() end)
        end
        
        task.wait(15)
        
        -- 3. Zeitgeist Paradigm Shift
        print("[CreativeTest] SCENARIO 3: Surging Zeitgeist with Fire Words")
        local ZeitgeistService = Knit.GetService("ZeitgeistService")
        if ZeitgeistService then
            pcall(function()
                for i = 1, 15 do
                    ZeitgeistService:RecordSemanticEvent("Creation", "Fire", "ignis")
                end
                
                -- Support both the older pre-existing version and the expanded version's methodologies
                if ZeitgeistService.EvaluateZeitgeist then
                    ZeitgeistService:EvaluateZeitgeist()
                end
            end)
        end
        
        print("[CreativeTest] Creative Simulations finished.")
    end

    Players.PlayerAdded:Connect(runSimulation)
    
    -- Handle case where player is already loaded when this script starts in Solo Play
    for _, p in ipairs(Players:GetPlayers()) do
        task.spawn(function() runSimulation(p) end)
    end
end)
