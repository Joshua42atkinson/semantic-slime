--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DevCommandService = Knit.CreateService {
    Name = "DevCommandService",
    Client = {},
}

function DevCommandService:KnitStart()
    local LogosService = Knit.GetService("LogosService")
    local DataService = Knit.GetService("DataService")
    local QuestService = Knit.GetService("QuestService")
    local AIService = Knit.GetService("AIService")

    local function findWordInstance(player: Player, word: string)
        local inventory = LogosService:GetInventory(player)
        for id, instance in pairs(inventory) do
            if instance.Term:lower() == word:lower() then
                return id, instance
            end
        end
        return nil, nil
    end

    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            local args = msg:split(" ")
            local command = args[1]:lower()
            
            if command == "/addword" then
                local word = args[2]
                if word then
                    LogosService.CollectWord(player, word)
                    print("Cmd: Added word " .. word)
                end
                
            elseif command == "/feed" then
                local word = args[2]
                local amount = tonumber(args[3]) or 10
                if word then
                    local id, inst = findWordInstance(player, word)
                    if id then
                        LogosService.AddXP(player, id, amount)
                        print("Cmd: Fed " .. word .. " " .. amount .. " XP")
                    else
                        print("Cmd: Word not found " .. word)
                    end
                end
                
            elseif command == "/evolve" then
                local word = args[2]
                if word then
                    local id, inst = findWordInstance(player, word)
                    if id then
                        LogosService.Evolve(player, id)
                        print("Cmd: Evolved " .. word)
                    else
                        print("Cmd: Word not found " .. word)
                    end
                end
                
            elseif command == "/inventory" then
                local inventory = LogosService:GetInventory(player)
                print("--- Inventory for " .. player.Name .. " ---")
                for id, inst in pairs(inventory) do
                    print(string.format("[%s] Lvl %d %s (%s)", inst.Term, inst.Level, inst.Role, inst.Element))
                end
                print("-----------------------------------")
                
            elseif command == "/quest" then
                print("Cmd: Generating Dynamic Quest...")
                QuestService.GenerateDynamicQuest(player)
                
            elseif command == "/journal" then
                local profile = DataService:GetProfile(player)
                print("--- Journal for " .. player.Name .. " ---")
                for timestamp, entry in pairs(profile.Journal) do
                    print(os.date("%c", tonumber(timestamp)) .. ": " .. entry.Entry)
                end
                print("-----------------------------------")


            elseif command == "/wipedata" then
                print("Cmd: WIPING DATA for " .. player.Name)
                local DataStoreService = game:GetService("DataStoreService")
                local DATA_VERSION = "v3" -- Synced with DataService
                local store = DataStoreService:GetDataStore("LexicalLegendsData_" .. DATA_VERSION)
                store:RemoveAsync("Player_" .. player.UserId)
                player:Kick("Data Wiped. Rejoin.")
                
            elseif command == "/mockpurchase" then
                local type = args[2] -- "product" or "gamepass"
                local id = tonumber(args[3])
                
                local MonetizationService = Knit.GetService("MonetizationService")
                if type == "product" then
                    print("Cmd: Mocking Product " .. id)
                    MonetizationService:HandleProduct(player, id)

                elseif type == "gamepass" then
                    print("Cmd: Mocking GamePass " .. id)
                    MonetizationService:HandleGamePass(player, id)
                else
                    print("Usage: /mockpurchase <product|gamepass> <id>")
                end
                
            elseif command == "/spawnslime" then
                local term = args[2] or "Rebellion"
                local LureService = Knit.GetService("LureService")
                -- Spawn near player
                local char = player.Character
                local pos = char and char.PrimaryPart.Position + Vector3.new(10, 0, 0) or Vector3.new(0, 10, 0)
                LureService:SpawnWildSlime(term, pos)
                print("Cmd: Spawning Slime " .. term)
            end
        end)
    end)
    
    print("[DevCommandService] Started. Commands: /addword, /feed, /evolve, /inventory, /quest, /journal, /wipedata, /mockpurchase, /spawnslime")
end

return DevCommandService
