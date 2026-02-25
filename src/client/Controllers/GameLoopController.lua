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
	GameLoopService.Client.PhaseChanged:Connect(function(phase, duration)
		self:OnPhaseChanged(phase, duration)
	end)
	
	-- Listen for game events
	GameLoopService.Client.GameLoopEvent:Connect(function(eventType, data)
		self:OnGameEvent(eventType, data)
	end)
	
	-- Create simple HUD if not exists
	self:CreateHUD()
end

function GameLoopController:OnPhaseChanged(phase: string, duration: number)
	currentPhase = phase
	timeRemaining = duration
	
	print("[GameLoopController] Phase changed to: " .. phase)
	
	-- Update UI
	self:UpdateHUD()
	
	-- Show phase notification
	self:ShowNotification("Phase: " .. phase, 2)
end

function GameLoopController:OnGameEvent(eventType: string, data: any)
	print("[GameLoopController] Event: " .. eventType .. " - " .. tostring(data))
	
	if eventType == "SlimeCreated" then
		self:ShowNotification("New Slime: " .. tostring(data) .. "!", 3)
	elseif eventType == "QuestStarted" then
		self:ShowNotification("Quest: " .. tostring(data), 3)
	elseif eventType == "SlotFilled" then
		self:ShowNotification("Slot filled with: " .. tostring(data), 2)
	elseif eventType == "QuestCompleted" then
		self:ShowNotification("Quest Complete: " .. tostring(data) .. "!", 4)
	end
end

function GameLoopController:CreateHUD()
	-- Create a simple on-screen HUD
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GameLoopHUD"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Phase indicator (top center)
	local phaseFrame = Instance.new("Frame")
	phaseFrame.Name = "PhaseFrame"
	phaseFrame.Size = UDim2.fromOffset(300, 50)
	phaseFrame.Position = UDim2.fromScale(0.5, 0.05)
	phaseFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	phaseFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	phaseFrame.BackgroundTransparency = 0.3
	phaseFrame.BorderSizePixel = 0
	phaseFrame.Parent = screenGui
	
	local phaseCorner = Instance.new("UICorner")
	phaseCorner.CornerRadius = UDim.new(0, 10)
	phaseCorner.Parent = phaseFrame
	
	phaseLabel = Instance.new("TextLabel")
	phaseLabel.Name = "PhaseLabel"
	phaseLabel.Size = UDim2.fromScale(1, 1)
	phaseLabel.BackgroundTransparency = 1
	phaseLabel.TextColor3 = Color3.new(1, 1, 1)
	phaseLabel.TextStrokeTransparency = 0
	phaseLabel.Font = Enum.Font.GothamBold
	phaseLabel.TextSize = 24
	phaseLabel.Text = "Collection Phase"
	phaseLabel.Parent = phaseFrame
	
	-- Timer (below phase)
	timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.fromOffset(100, 30)
	timerLabel.Position = UDim2.fromScale(0.5, 0.12)
	timerLabel.AnchorPoint = Vector2.new(0.5, 0)
	timerLabel.BackgroundTransparency = 1
	timerLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
	timerLabel.TextStrokeTransparency = 0
	timerLabel.Font = Enum.Font.Gotham
	timerLabel.TextSize = 18
	timerLabel.Text = "30s"
	timerLabel.Parent = screenGui
	
	-- Notification area (center)
	self.notificationFrame = Instance.new("Frame")
	self.notificationFrame.Name = "NotificationFrame"
	self.notificationFrame.Size = UDim2.fromOffset(400, 60)
	self.notificationFrame.Position = UDim2.fromScale(0.5, 0.3)
	self.notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.notificationFrame.BackgroundColor3 = Color3.fromRGB(79, 70, 229)
	self.notificationFrame.BackgroundTransparency = 0.3
	self.notificationFrame.BorderSizePixel = 0
	self.notificationFrame.Parent = screenGui
	
	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = self.notificationFrame
	
	self.notificationLabel = Instance.new("TextLabel")
	self.notificationLabel.Size = UDim2.fromScale(1, 1)
	self.notificationLabel.BackgroundTransparency = 1
	self.notificationLabel.TextColor3 = Color3.new(1, 1, 1)
	self.notificationLabel.TextStrokeTransparency = 0
	self.notificationLabel.Font = Enum.Font.GothamBold
	self.notificationLabel.TextSize = 20
	self.notificationLabel.Text = ""
	self.notificationLabel.Parent = self.notificationFrame
	
	print("[GameLoopController] HUD created.")
end

function GameLoopController:UpdateHUD()
	if phaseLabel then
		local phaseNames = {
			Collection = "🌟 Collection Phase",
			Construction = "🔨 Construction Phase",
			Quest = "📜 Quest Phase",
			Combat = "⚔️ Combat Phase",
			Rewards = "🎁 Rewards Phase",
		}
		phaseLabel.Text = phaseNames[currentPhase] or currentPhase
	end
	
	if timerLabel then
		timerLabel.Text = tostring(timeRemaining) .. "s"
	end
end

function GameLoopController:ShowNotification(text: string, duration: number)
	if not self.notificationLabel then return end
	
	self.notificationLabel.Text = text
	self.notificationFrame.Visible = true
	
	-- Hide after duration
	task.delay(duration, function()
		if self.notificationFrame then
			self.notificationFrame.Visible = false
		end
	end)
end

-- Update timer every second
task.spawn(function()
	while true do
		task.wait(1)
		if timeRemaining > 0 then
			timeRemaining -= 1
			if timerLabel then
				timerLabel.Text = tostring(timeRemaining) .. "s"
			end
		end
	end
end)

return GameLoopController
