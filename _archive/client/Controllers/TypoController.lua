--!strict
--==============================================================
-- MMMM Context: Visualizes Feral Typos via chaotic shaders and glitch UI, rendering spelling errors as orthographic aberrations.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TypoController = Knit.CreateController {
    Name = "TypoController",
}

function TypoController:KnitStart()
    local FeralTypoService = Knit.GetService("FeralTypoService")
    
    if FeralTypoService then
        FeralTypoService.FeralTypoSpawned:Connect(function(failedWord: string, position: Vector3)
            local channel = TextChatService:FindFirstChild("TextChannels")
            if channel then
                local RBXSystem = channel:FindFirstChild("RBXSystem")
                if RBXSystem then
                    local msg = string.format("<font color='#FF0000'><b>[SYSTEM] An orthographic anomaly (Feral Typo '%s') has spawned nearby!</b></font>", tostring(failedWord))
                    RBXSystem:DisplaySystemMessage(msg)
                end
            end
        end)
    end
end

return TypoController
