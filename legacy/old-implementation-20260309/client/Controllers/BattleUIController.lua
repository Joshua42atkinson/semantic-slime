--!strict
-- Battle UI Controller
-- Handles battle interface, turn management, and combat feedback

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local BattleUIController = Knit.CreateController { Name = "BattleUIController" }

-- Configuration
local UI_ANIMATION_DURATION = 0.3
local TURN_TIME_DISPLAY = 30
local HEALTH_BAR_ANIMATION = 1

-- State
local currentBattle: any = nil
local isBattleActive = false
local battleUI: ScreenGui? = nil
local participantFrames: {[string]: Frame} = {}
local turnTimer: number = 0
local selectedAction: string = nil

-- Services
local BattleService: any = nil
local GameLoopService: any = nil

-- Sound effects
local battleSounds = {
	start = Instance.new("Sound"),
	turn = Instance.new("Sound"),
	attack = Instance.new("Sound"),
	defend = Instance.new("Sound"),
	victory = Instance.new("Sound"),
	defeat = Instance.new("Sound"),
	error = Instance.new("Sound")
}

-- Initialize sounds
local function setupSounds()
	battleSounds.start.SoundId = "rbxassetid://6788484923"
	battleSounds.start.Volume = 0.6
	battleSounds.start.Pitch = 1.0
	
	battleSounds.turn.SoundId = "rbxassetid://6788484923"
	battleSounds.turn.Volume = 0.4
	battleSounds.turn.Pitch = 0.9
	
	battleSounds.attack.SoundId = "rbxassetid://6788484923"
	battleSounds.attack.Volume = 0.5
	battleSounds.attack.Pitch = 1.2
	
	battleSounds.defend.SoundId = "rbxassetid://6788484923"
	battleSounds.defend.Volume = 0.4
	battleSounds.defend.Pitch = 0.8
	
	battleSounds.victory.SoundId = "rbxassetid://6788484923"
	battleSounds.victory.Volume = 0.7
	battleSounds.victory.Pitch = 1.3
	
	battleSounds.defeat.SoundId = "rbxassetid://6788484923"
	battleSounds.defeat.Volume = 0.6
	battleSounds.defeat.Pitch = 0.7
	
	battleSounds.error.SoundId = "rbxassetid://6788484923"
	battleSounds.error.Volume = 0.4
	battleSounds.error.Pitch = 0.6
end

-- UI Construction
local function buildBattleUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Main battle GUI
	battleUI = Instance.new("ScreenGui")
	battleUI.Name = "BattleUI"
	battleUI.ResetOnSpawn = false
	battleUI.Parent = playerGui
	
	-- Main container
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
	mainFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = battleUI
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 20)
	mainCorner.Parent = mainFrame
	
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(150, 100, 200)
	mainStroke.Thickness = 3
	mainStroke.Transparency = 0.3
	mainStroke.Parent = mainFrame
	
	-- Battle header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, -40, 0, 80)
	header.Position = UDim2.fromOffset(20, 20)
	header.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	-- Battle title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.fromOffset(20, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "BATTLE!"
	titleLabel.Parent = header
	
	-- Turn timer
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "Timer"
	timerLabel.Size = UDim2.fromOffset(80, 40)
	timerLabel.Position = UDim2.new(1, -100, 0, 20)
	timerLabel.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
	timerLabel.BorderSizePixel = 0
	timerLabel.TextColor3 = Color3.new(1, 1, 1)
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 18
	timerLabel.Text = "30"
	timerLabel.Parent = header
	
	local timerCorner = Instance.new("UICorner")
	timerCorner.CornerRadius = UDim.new(0, 8)
	timerCorner.Parent = timerLabel
	
	-- Participants container
	local participantsContainer = Instance.new("Frame")
	participantsContainer.Name = "ParticipantsContainer"
	participantsContainer.Size = UDim2.new(1, -40, 0, 300)
	participantsContainer.Position = UDim2.fromOffset(20, 120)
	participantsContainer.BackgroundTransparency = 1
	participantsContainer.Parent = mainFrame
	
	-- Create participant frames (up to 4 participants)
	for i = 1, 4 do
		local participantFrame = Instance.new("Frame")
		participantFrame.Name = "Participant" .. i
		participantFrame.Size = UDim2.new(0.45, -10, 0, 120)
		participantFrame.Position = UDim2.new(0, (i - 1) % 2 * 0.5, 0, math.floor((i - 1) / 2) * 130)
		participantFrame.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
		participantFrame.BorderSizePixel = 0
		participantFrame.BackgroundTransparency = 1
		participantFrame.Parent = participantsContainer
		
		local participantCorner = Instance.new("UICorner")
		participantCorner.CornerRadius = UDim.new(0, 12)
		participantCorner.Parent = participantFrame
		
		local participantStroke = Instance.new("UIStroke")
		participantStroke.Color = Color3.fromRGB(100, 150, 200)
		participantStroke.Thickness = 2
		participantStroke.Transparency = 0.5
		participantStroke.Parent = participantFrame
		
		-- Player name
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Name = "Name"
		nameLabel.Size = UDim2.new(1, -20, 0, 25)
		nameLabel.Position = UDim2.fromOffset(10, 10)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Text = "Player " .. i
		nameLabel.Parent = participantFrame
		
		-- Slime name
		local slimeLabel = Instance.new("TextLabel")
		slimeLabel.Name = "SlimeName"
		slimeLabel.Size = UDim2.new(1, -20, 0, 20)
		slimeLabel.Position = UDim2.fromOffset(10, 35)
		slimeLabel.BackgroundTransparency = 1
		slimeLabel.TextColor3 = Color3.fromRGB(255, 220, 150)
		slimeLabel.Font = Enum.Font.Gotham
		slimeLabel.TextSize = 14
		slimeLabel.TextXAlignment = Enum.TextXAlignment.Left
		slimeLabel.Text = "Slime Name"
		slimeLabel.Parent = participantFrame
		
		-- Health bar container
		local healthContainer = Instance.new("Frame")
		healthContainer.Name = "HealthContainer"
		healthContainer.Size = UDim2.new(1, -20, 0, 20)
		healthContainer.Position = UDim2.fromOffset(10, 60)
		healthContainer.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
		healthContainer.BorderSizePixel = 0
		healthContainer.Parent = participantFrame
		
		local healthCorner = Instance.new("UICorner")
		healthCorner.CornerRadius = UDim.new(0, 4)
		healthCorner.Parent = healthContainer
		
		-- Health bar
		local healthBar = Instance.new("Frame")
		healthBar.Name = "HealthBar"
		healthBar.Size = UDim2.new(1, 0, 1, 0)
		healthBar.Position = UDim2.fromScale(0, 0)
		healthBar.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		healthBar.BorderSizePixel = 0
		healthBar.Parent = healthContainer
		
		local healthBarCorner = Instance.new("UICorner")
		healthBarCorner.CornerRadius = UDim.new(0, 4)
		healthBarCorner.Parent = healthBar
		
		-- Health text
		local healthText = Instance.new("TextLabel")
		healthText.Name = "HealthText"
		healthText.Size = UDim2.new(1, 0, 1, 0)
		healthText.BackgroundTransparency = 1
		healthText.TextColor3 = Color3.new(1, 1, 1)
		healthText.Font = Enum.Font.GothamBold
		healthText.TextSize = 12
		healthText.Text = "100/100"
		healthText.Parent = healthContainer
		
		-- Stats display
		local statsFrame = Instance.new("Frame")
		statsFrame.Name = "Stats"
		statsFrame.Size = UDim2.new(1, -20, 0, 25)
		statsFrame.Position = UDim2.fromOffset(10, 85)
		statsFrame.BackgroundTransparency = 1
		statsFrame.Parent = participantFrame
		
		local statsLabel = Instance.new("TextLabel")
		statsLabel.Name = "StatsText"
		statsLabel.Size = UDim2.new(1, 0, 1, 0)
		statsLabel.BackgroundTransparency = 1
		statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
		statsLabel.Font = Enum.Font.Gotham
		statsLabel.TextSize = 12
		statsLabel.TextXAlignment = Enum.TextXAlignment.Left
		statsLabel.Text = "Logos:10 Pathos:10 Ethos:10 Speed:10"
		statsLabel.Parent = statsFrame
		
		-- Store reference
		participantFrames["Participant" .. i] = participantFrame
	end
	
	-- Action buttons container
	local actionContainer = Instance.new("Frame")
	actionContainer.Name = "ActionContainer"
	actionContainer.Size = UDim2.new(1, -40, 0, 80)
	actionContainer.Position = UDim2.fromOffset(20, 440)
	actionContainer.BackgroundTransparency = 1
	actionContainer.Parent = mainFrame
	
	-- Attack button
	local attackButton = Instance.new("TextButton")
	attackButton.Name = "AttackButton"
	attackButton.Size = UDim2.new(0, 120, 0, 60)
	attackButton.Position = UDim2.new(0, 0, 0, 10)
	attackButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	attackButton.BorderSizePixel = 0
	attackButton.Text = "ATTACK"
	attackButton.TextColor3 = Color3.new(1, 1, 1)
	attackButton.Font = Enum.Font.GothamBold
	attackButton.TextSize = 18
	attackButton.Parent = actionContainer
	
	local attackCorner = Instance.new("UICorner")
	attackCorner.CornerRadius = UDim.new(0, 8)
	attackCorner.Parent = attackButton
	
	attackButton.MouseButton1Click:Connect(function()
		selectAction("attack")
	end)
	
	-- Defend button
	local defendButton = Instance.new("TextButton")
	defendButton.Name = "DefendButton"
	defendButton.Size = UDim2.new(0, 120, 0, 60)
	defendButton.Position = UDim2.new(0, 140, 0, 10)
	defendButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
	defendButton.BorderSizePixel = 0
	defendButton.Text = "DEFEND"
	defendButton.TextColor3 = Color3.new(1, 1, 1)
	defendButton.Font = Enum.Font.GothamBold
	defendButton.TextSize = 18
	defendButton.Parent = actionContainer
	
	local defendCorner = Instance.new("UICorner")
	defendCorner.CornerRadius = UDim.new(0, 8)
	defendCorner.Parent = defendButton
	
	defendButton.MouseButton1Click:Connect(function()
		selectAction("defend")
	end)
	
	-- Special button
	local specialButton = Instance.new("TextButton")
	specialButton.Name = "SpecialButton"
	specialButton.Size = UDim2.new(0, 120, 0, 60)
	specialButton.Position = UDim2.new(0, 280, 0, 10)
	specialButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
	specialButton.BorderSizePixel = 0
	specialButton.Text = "SPECIAL"
	specialButton.TextColor3 = Color3.new(1, 1, 1)
	specialButton.Font = Enum.Font.GothamBold
	specialButton.TextSize = 18
	specialButton.Parent = actionContainer
	
	local specialCorner = Instance.new("UICorner")
	specialCorner.CornerRadius = UDim.new(0, 8)
	specialCorner.Parent = specialButton
	
	specialButton.MouseButton1Click:Connect(function()
		selectAction("special")
	end)
end

-- Update participant display
local function updateParticipantDisplay(participant: any, frameName: string)
	local frame = participantFrames[frameName]
	if not frame then return end
	
	local nameLabel = frame:FindFirstChild("Name")
	local slimeLabel = frame:FindFirstChild("SlimeName")
	local healthBar = frame:FindFirstChild("HealthContainer"):FindFirstChild("HealthBar")
	local healthText = frame:FindFirstChild("HealthContainer"):FindFirstChild("HealthText")
	local statsLabel = frame:FindFirstChild("Stats"):FindFirstChild("StatsText")
	
	if nameLabel then
		nameLabel.Text = participant.PlayerId or "Unknown"
	end
	
	if slimeLabel then
		slimeLabel.Text = participant.SlimeName or "Unknown Slime"
	end
	
	if healthBar and participant.HP and participant.MaxHP then
		local healthPercent = participant.HP / participant.MaxHP
		local healthColor = healthPercent > 0.5 and Color3.fromRGB(50, 200, 50) or 
		                    healthPercent > 0.25 and Color3.fromRGB(200, 200, 50) or 
		                    Color3.fromRGB(200, 50, 50)
		
		healthBar.BackgroundColor3 = healthColor
		
		local healthTween = TweenService:Create(healthBar, TweenInfo.new(HEALTH_BAR_ANIMATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(healthPercent, 0, 1, 0)
		})
		healthTween:Play()
	end
	
	if healthText then
		healthText.Text = (participant.HP or 0) .. "/" .. (participant.MaxHP or 0)
	end
	
	if statsLabel and participant.Stats then
		local statsText = string.format("Logos:%d Pathos:%d Ethos:%d Speed:%d",
			participant.Stats.Logos or 0,
			participant.Stats.Pathos or 0,
			participant.Stats.Ethos or 0,
			participant.Stats.Speed or 0
		)
		statsLabel.Text = statsText
	end
	
	-- Highlight current turn
	if participant.IsCurrentTurn then
		frame.BackgroundTransparency = 0
		local highlightTween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0.2
		})
		highlightTween:Play()
	else
		frame.BackgroundTransparency = 1
	end
end

-- Show battle UI
local function showBattleUI(battle: any)
	currentBattle = battle
	isBattleActive = true
	
	if not battleUI then
		buildBattleUI()
	end
	
	-- Update participants
	if battle.Participants then
		for i, participant in ipairs(battle.Participants) do
			local frameName = "Participant" .. i
			updateParticipantDisplay(participant, frameName)
		end
	end
	
	-- Fade in
	local mainFrame = battleUI:FindFirstChild("MainFrame")
	if mainFrame then
		mainFrame.BackgroundTransparency = 0.2
		
		local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		})
		fadeIn:Play()
	end
	
	battleSounds.start:Play()
	print("[BattleUIController] Battle started with", #battle.Participants, "participants")
end

-- Hide battle UI
local function hideBattleUI()
	if not battleUI or not battleUI.Parent then return end
	
	local mainFrame = battleUI:FindFirstChild("MainFrame")
	if mainFrame then
		local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			battleUI.Parent = nil
		end)
	end
	
	isBattleActive = false
	currentBattle = nil
	selectedAction = nil
end

-- Select action
local function selectAction(action: string)
	if not isBattleActive or not currentBattle then return end
	
	selectedAction = action
	
	-- Disable action buttons temporarily
	local actionContainer = battleUI:FindFirstChild("MainFrame"):FindFirstChild("ActionContainer")
	if actionContainer then
		for _, child in ipairs(actionContainer:GetChildren()) do
			if child:IsA("TextButton") then
				child.Active = false
			end
		end
	end
	
	-- Execute action (would need to communicate with BattleService)
	local success, result = pcall(function()
		-- This would be implemented in BattleService
		-- return BattleService:ExecuteAction(currentBattle.BattleId, action)
		print("[BattleUIController] Executing action:", action)
		return true
	end)
	
	if success then
		battleSounds.attack:Play()
		print("[BattleUIController] Action executed:", action)
	else
		battleSounds.error:Play()
		warn("[BattleUIController] Failed to execute action:", result)
	end
	
	-- Re-enable buttons after delay
	task.delay(1, function()
		if actionContainer then
			for _, child in ipairs(actionContainer:GetChildren()) do
				if child:IsA("TextButton") then
					child.Active = true
				end
			end
		end
	end)
end

-- Update turn timer
local function updateTurnTimer()
	if not isBattleActive or not currentBattle then return end
	
	local timerLabel = battleUI:FindFirstChild("MainFrame"):FindFirstChild("Header"):FindFirstChild("Timer")
	if timerLabel then
		-- This would need to be updated based on actual battle timing
		timerLabel.Text = tostring(math.max(0, TURN_TIME_DISPLAY - turnTimer))
	end
end

-- Service connections
local function connectToServices()
	-- Get BattleService
	local success, service = pcall(function()
		return Knit.GetService("BattleService")
	end)
	
	if success and service then
		BattleService = service
		
		-- Connect to battle events
		BattleService.BattleStarted:Connect(function(battle)
			showBattleUI(battle)
		end)
		
		BattleService.BattleTurn:Connect(function(battleState)
			if battleState then
				currentBattle = battleState
				turnTimer = 0
				
				-- Update all participants
				if battleState.Participants then
					for i, participant in ipairs(battleState.Participants) do
						local frameName = "Participant" .. i
						updateParticipantDisplay(participant, frameName)
					end
				end
				
				battleSounds.turn:Play()
			end
		end)
		
		BattleService.BattleEnded:Connect(function(battleState)
			if battleState.Winner then
				battleSounds.victory:Play()
				print("[BattleUIController] Battle won!")
			else
				battleSounds.defeat:Play()
				print("[BattleUIController] Battle lost!")
			end
			
			-- Show result and hide after delay
			task.delay(3, function()
				hideBattleUI()
			end)
		end)
	else
		warn("[BattleUIController] BattleService not available")
	end
	
	-- Get GameLoopService
	local success, service = pcall(function()
		return Knit.GetService("GameLoopService")
	end)
	
	if success and service then
		GameLoopService = service
		
		-- Listen for phase changes
		GameLoopService.PhaseChanged:Connect(function(phase)
			if phase ~= "Combat" then
				hideBattleUI()
			end
		end)
	else
		warn("[BattleUIController] GameLoopService not available")
	end
end

-- Controller lifecycle
function BattleUIController:KnitStart()
	print("[BattleUIController] Starting...")
	
	setupSounds()
	connectToServices()
	
	-- Start turn timer update loop
	task.spawn(function()
		while true do
			if isBattleActive then
				turnTimer += 0.1
				updateTurnTimer()
			end
			task.wait(0.1)
		end
	end)
	
	print("[BattleUIController] Started.")
end

function BattleUIController:KnitStop()
	hideBattleUI()
	print("[BattleUIController] Stopped.")
end

-- Public methods
function BattleUIController:ShowBattle(battle: any)
	showBattleUI(battle)
end

function BattleUIController:HideBattle()
	hideBattleUI()
end

function BattleUIController:IsBattleActive(): boolean
	return isBattleActive
end

return BattleUIController
