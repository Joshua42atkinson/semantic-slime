--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local GameLoopController = Knit.CreateController { Name = "GameLoopController" }

-- State
local currentPhase = "Collection"
local timeRemaining = 0

-- UI References
local phaseLabel: TextLabel? = nil
local timerLabel: TextLabel? = nil

function GameLoopController:KnitStart()
	print("[GameLoopController] Started.")
	
	-- Get GameLoopService
	local GameLoopService = Knit.GetService("GameLoopService")
	
	-- Listen for phase changes
	GameLoopService.PhaseChanged:Connect(function(phase, duration)
		self:OnPhaseChanged(phase, duration)
	end)

	-- Listen for game events
	GameLoopService.GameLoopEvent:Connect(function(eventType, data)
		self:OnGameEvent(eventType, data)
	end)
end -- KnitStart

function GameLoopController:OnPhaseChanged(phase: string, duration: number)
	currentPhase = phase
	timeRemaining = duration
	
	print("[GameLoopController] Phase changed to: " .. phase)
	
	-- Pass to HUDController
	local HUDController = Knit.GetController("HUDController")
	if HUDController then
		HUDController:OnPhaseChanged(phase, duration)
	end
end

function GameLoopController:OnGameEvent(eventType: string, data: any)
	print("[GameLoopController] Event: " .. eventType .. " - " .. tostring(data))
	
	local HUDController = Knit.GetController("HUDController")
	if HUDController then
		HUDController:OnGameEvent(eventType, data)
	end
end

-- Update timer every second and notify HUD
task.spawn(function()
	while true do
		task.wait(1)
		if timeRemaining > 0 then
			timeRemaining -= 1
			local HUDController = Knit.GetController("HUDController")
			if HUDController then
				HUDController:UpdateTimer(timeRemaining)
			end
		end
	end
end)

return GameLoopController
