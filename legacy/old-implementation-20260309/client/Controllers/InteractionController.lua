--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local InteractionController = Knit.CreateController { Name = "InteractionController" }

-- Remotes (initialized in KnitStart)
local InteractFunction = nil

-- Constants
local INTERACTION_KEY = Enum.KeyCode.E

-- Public API

function InteractionController:KnitStart()
    print("InteractionController started.")
    
    local NPCService = Knit.GetService("NPCService")
    NPCService.TriggerInteraction:Connect(function(npcId)
    	self:Interact(npcId)
    end)
end

function InteractionController:Interact(npcId: string, optionId: string?)
	local DialogueUI = require(script.Parent.Parent.UI.DialogueUI)
    local Camera = workspace.CurrentCamera
	
	local NPCService = Knit.GetService("NPCService")
    local dialogueData = NPCService:Interact(npcId, optionId)
    print("Received dialogue:", dialogueData)
    
    if dialogueData and dialogueData.Text then
    	-- Determine NPC Name from ID or passed data
    	local npcName = dialogueData.Name or "Unknown Archetype"
    	
        -- Cinematic Zoom
        local npcModel = workspace:FindFirstChild(dialogueData.Name, true) -- Hacky search, should use ID/Service
        local originalCFrame = Camera.CFrame
        
        if npcModel then
            local head = npcModel:FindFirstChild("Head")
            if head then
                local targetCF = CFrame.new(head.Position + (head.CFrame.LookVector * 5) + Vector3.new(0, 0, 0), head.Position)
                local tween = game:GetService("TweenService"):Create(Camera, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = targetCF})
                tween:Play()
                Camera.CameraType = Enum.CameraType.Scriptable
            end
        end

    	DialogueUI.Show(npcName, dialogueData.Text, dialogueData.Options or {}, function(nextId)
            -- Reset Camera
            Camera.CameraType = Enum.CameraType.Custom
            -- Simple reset, arguably jarring, ideally tween back
            -- Camera.CFrame = originalCFrame 
            
    		if nextId then
    			-- Recursively call interact
    			print("Selected option:", nextId)
				self:Interact(npcId, nextId)
    		end
    	end)
    end
end

return InteractionController
