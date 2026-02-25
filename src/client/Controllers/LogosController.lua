--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogosController = {}
LogosController.__index = LogosController

-- Remotes (TODO: Create LogosRemotes folder)
-- local Remotes = ReplicatedStorage:WaitForChild("LogosRemotes")
-- local WordDiscovered = Remotes:WaitForChild("WordDiscovered")

-- UI
local LogosUI = require(script.Parent.Parent.UI.LogosUI)
local uiContainer = nil

-- Public API

function LogosController.Start()
    print("LogosController started.")
    
    uiContainer = LogosUI.Create()
    
    local Remotes = ReplicatedStorage:WaitForChild("LogosRemotes")
    local WordDiscovered = Remotes:WaitForChild("WordDiscovered")
    
    WordDiscovered.OnClientEvent:Connect(function(etymon)
        LogosUI.ShowDiscovery(uiContainer, etymon)
    end)
end

return LogosController
