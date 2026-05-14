--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LogosController = {}
LogosController.__index = LogosController

-- UI
local LogosUI = require(script.Parent.Parent.UI.LogosUI)
local uiContainer = nil

-- Public API

function LogosController.Start()
    print("LogosController started.")
    
    uiContainer = LogosUI.Create()
    
    local LogosRemotes = ReplicatedStorage:WaitForChild("LogosRemotes", 10)
    if LogosRemotes then
        local WordDiscovered = LogosRemotes:FindFirstChild("WordDiscovered")
        if WordDiscovered then
            WordDiscovered.OnClientEvent:Connect(function(etymon)
                LogosUI.ShowDiscovery(uiContainer, etymon)
            end)
        else
            warn("[LogosController] WordDiscovered event not found")
        end
    else
        warn("[LogosController] LogosRemotes not found — word discovery UI disabled")
    end
end

return LogosController
