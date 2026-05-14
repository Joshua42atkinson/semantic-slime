--!strict
--==============================================================
-- MMMM Context: Displays the poetic inner monologues of Slimes in text chat, reinforcing the Dreaming Layer's surreal atmosphere.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DreamController = Knit.CreateController {
    Name = "DreamController",
}

function DreamController:KnitStart()
    local SlimeDreamService = Knit.GetService("SlimeDreamService")
    
    SlimeDreamService.SlimeDreamed:Connect(function(player: Player, slimeInstanceId: string, dreamText: string)
        local channel = TextChatService:FindFirstChild("TextChannels")
        if channel then
            local RBXSystem = channel:FindFirstChild("RBXSystem")
            if RBXSystem then
                local formattedMsg = string.format("<font color='#A855F7'><i>💭 %s's Slime dreams: \"%s\"</i></font>", player.Name, dreamText)
                RBXSystem:DisplaySystemMessage(formattedMsg)
            end
        end
    end)
end

return DreamController
