--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DevCommandService = Knit.CreateService {
    Name = "DevCommandService",
    Client = {},
}

-- Chat command handlers
local function setupChatCommands()
    -- Register chat commands
    local function onChatted(player, message)
        local cmd = string.lower(message)
        
        -- /regen - Regenerate the world
        if cmd == "/regen" or cmd == "/regenerate" then
            if player:GetRankInGroup(4198713) >= 0 then -- Your group ID or check for dev
                print("[DevCommandService] Regenerating world...")
                local TownGenerator = require(game.ServerScriptService.Server.Services.TownGenerator)
                TownGenerator.SpawnWorld()
                return
            end
        end
        
        -- /givletters - Give test letters
        if string.sub(cmd, 1, 11) == "/givletters" then
            local letter = string.sub(cmd, 13, 13)
            local count = tonumber(string.sub(cmd, 15)) or 1
            if letter and #letter == 1 then
                local CrystalService = Knit.GetService("CrystalService")
                local inventory = CrystalService:GetPlayerInventory(player)
                inventory[letter] = (inventory[letter] or 0) + count
                player:ClearCharacter()
                player:LoadCharacter()
                return
            end
        end
        
        -- /giveall - Give all letters
        if cmd == "/giveall" then
            local CrystalService = Knit.GetService("CrystalService")
            local inventory = CrystalService:GetPlayerInventory(player)
            local letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
            for _, letter in ipairs(letters) do
                inventory[letter] = (inventory[letter] or 0) + 5
            end
            player:ClearCharacter()
            player:LoadCharacter()
            return
        end
        
        -- /spawncrystal - Spawn a crystal near player
        if cmd == "/spawncrystal" then
            local CrystalService = Knit.GetService("CrystalService")
            CrystalService:SpawnCrystal()
            return
        end
        
        -- /skipphase - Skip to next phase (admin)
        if cmd == "/skipphase" then
            local GameLoopService = Knit.GetService("GameLoopService")
            if GameLoopService.SkipPhase then
                GameLoopService:SkipPhase()
            end
            return
        end
        
        -- /help - Show commands
        if cmd == "/help" then
            player:ClearCharacter()
            task.wait(0.5)
            local msg = Instance.new("Message")
            msg.Text = "Dev Commands:\n/givletters [letter] [count] - Give letters\n/giveall - Give all letters\n/regen - Regenerate world\n/spawncrystal - Spawn crystal\n/skipphase - Skip phase"
            msg.Parent = player.PlayerGui
            task.delay(10, function() msg:Destroy() end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            onChatted(player, msg)
        end)
    end)
end

function DevCommandService:KnitStart()
    print("[DevCommandService] Started.")
    setupChatCommands()
end

return DevCommandService
