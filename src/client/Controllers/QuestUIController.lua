--!strict
-- Quest UI Controller
-- Handles quest display, slot filling, and quest completion UI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local QuestUIController = Knit.CreateController { Name = "QuestUIController" }

-- Configuration
local UI_FADE_DURATION = 0.3
local SLOT_HIGHLIGHT_DURATION = 1
local QUEST_COMPLETE_DURATION = 3

-- State
local currentQuest: any = nil
local isQuestActive = false
local selectedSlime: string = nil
local questUI: ScreenGui? = nil
local slotButtons: {[string]: TextButton} = {}
local questTimer: number = 0

-- Services
local MadLibService: any = nil
local GameLoopService: any = nil
local SlimeFactory: any = nil

-- Sound effects
local questSounds = {
	accept = Instance.new("Sound"),
	complete = Instance.new("Sound"),
	slotFill = Instance.new("Sound"),
	error = Instance.new("Sound")
}

-- Initialize sounds
local function setupSounds()
	questSounds.accept.SoundId = "rbxassetid://6788484923"
	questSounds.accept.Volume = 0.4
	questSounds.accept.Pitch = 1.1
	
	questSounds.complete.SoundId = "rbxassetid://6788484923"
	questSounds.complete.Volume = 0.6
	questSounds.complete.Pitch = 1.3
	
	questSounds.slotFill.SoundId = "rbxassetid://6788484923"
	questSounds.slotFill.Volume = 0.3
	questSounds.slotFill.Pitch = 1.0
	
	questSounds.error.SoundId = "rbxassetid://6788484923"
	questSounds.error.Volume = 0.4
	questSounds.error.Pitch = 0.7
end

-- UI Construction
local function buildQuestUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Main quest GUI
	questUI = Instance.new("ScreenGui")
	questUI.Name = "QuestUI"
	questUI.ResetOnSpawn = false
	questUI.Parent = playerGui
	
	-- Main container
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
	mainFrame.Position = UDim2.new(0.1, 0, 0.15, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
	mainFrame.BorderSizePixel = 0
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = questUI
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 20)
	mainCorner.Parent = mainFrame
	
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Color3.fromRGB(100, 150, 200)
	mainStroke.Thickness = 2
	mainStroke.Transparency = 0.5
	mainStroke.Parent = mainFrame
	
	-- Quest header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, -40, 0, 80)
	header.Position = UDim2.fromOffset(20, 20)
	header.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	-- Quest title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -120, 1, 0)
	titleLabel.Position = UDim2.fromOffset(20, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Quest Title"
	titleLabel.Parent = header
	
	-- Quest description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(1, -40, 0, 60)
	descLabel.Position = UDim2.fromOffset(20, 100)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.TextWrapped = true
	descLabel.Text = "Quest description will appear here..."
	descLabel.Parent = mainFrame
	
	-- Quest slots container
	local slotsContainer = Instance.new("Frame")
	slotsContainer.Name = "SlotsContainer"
	slotsContainer.Size = UDim2.new(1, -40, 0, 200)
	slotsContainer.Position = UDim2.fromOffset(20, 180)
	slotsContainer.BackgroundTransparency = 1
	slotsContainer.Parent = mainFrame
	
	-- Create slot buttons (up to 4 slots)
	for i = 1, 4 do
		local slotButton = Instance.new("TextButton")
		slotButton.Name = "Slot" .. i
		slotButton.Size = UDim2.new(0.45, -10, 0, 80)
		slotButton.Position = UDim2.new(0, (i - 1) % 2 * 0.5, 0, math.floor((i - 1) / 2) * 90)
		slotButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
		slotButton.BorderSizePixel = 0
		slotButton.Text = ""
		slotButton.Parent = slotsContainer
		
		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 10)
		slotCorner.Parent = slotButton
		
		local slotStroke = Instance.new("UIStroke")
		slotStroke.Color = Color3.fromRGB(100, 150, 200)
		slotStroke.Thickness = 1
		slotStroke.Transparency = 0.3
		slotStroke.Parent = slotButton
		
		-- Slot type label
		local typeLabel = Instance.new("TextLabel")
		typeLabel.Name = "TypeLabel"
		typeLabel.Size = UDim2.new(1, -20, 0, 25)
		typeLabel.Position = UDim2.fromOffset(10, 5)
		typeLabel.BackgroundTransparency = 1
		typeLabel.TextColor3 = Color3.fromRGB(150, 150, 255)
		typeLabel.Font = Enum.Font.GothamBold
		typeLabel.TextSize = 14
		typeLabel.TextXAlignment = Enum.TextXAlignment.Left
		typeLabel.Text = "ADJECTIVE"
		typeLabel.Parent = slotButton
		
		-- Slot content label
		local contentLabel = Instance.new("TextLabel")
		contentLabel.Name = "ContentLabel"
		contentLabel.Size = UDim2.new(1, -20, 0, 30)
		contentLabel.Position = UDim2.fromOffset(10, 30)
		contentLabel.BackgroundTransparency = 1
		contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		contentLabel.Font = Enum.Font.GothamBold
		contentLabel.TextSize = 18
		contentLabel.TextXAlignment = Enum.TextXAlignment.Left
		contentLabel.Text = "Empty"
		contentLabel.Parent = slotButton
		
		-- Store reference
		slotButtons["Slot" .. i] = slotButton
		
		-- Connect click handler
		slotButton.MouseButton1Click:Connect(function()
			onSlotClicked("Slot" .. i)
		end)
	end
	
	-- Action buttons
	local actionContainer = Instance.new("Frame")
	actionContainer.Name = "ActionContainer"
	actionContainer.Size = UDim2.new(1, -40, 0, 60)
	actionContainer.Position = UDim2.fromOffset(20, 400)
	actionContainer.BackgroundTransparency = 1
	actionContainer.Parent = mainFrame
	
	-- Complete quest button
	local completeButton = Instance.new("TextButton")
	completeButton.Name = "CompleteButton"
	completeButton.Size = UDim2.new(0, 150, 0, 50)
	completeButton.Position = UDim2.new(1, -150, 0, 5)
	completeButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	completeButton.BorderSizePixel = 0
	completeButton.Text = "Complete Quest"
	completeButton.TextColor3 = Color3.new(1, 1, 1)
	completeButton.Font = Enum.Font.GothamBold
	completeButton.TextSize = 16
	completeButton.Parent = actionContainer
	
	local completeCorner = Instance.new("UICorner")
	completeCorner.CornerRadius = UDim.new(0, 8)
	completeCorner.Parent = completeButton
	
	completeButton.MouseButton1Click:Connect(function()
		attemptQuestCompletion()
	end)
	
	-- Cancel quest button
	local cancelButton = Instance.new("TextButton")
	cancelButton.Name = "CancelButton"
	cancelButton.Size = UDim2.new(0, 100, 0, 50)
	cancelButton.Position = UDim2.new(1, -260, 0, 5)
	cancelButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
	cancelButton.BorderSizePixel = 0
	cancelButton.Text = "Cancel"
	cancelButton.TextColor3 = Color3.new(1, 1, 1)
	cancelButton.Font = Enum.Font.GothamBold
	cancelButton.TextSize = 16
	cancelButton.Parent = actionContainer
	
	local cancelCorner = Instance.new("UICorner")
	cancelCorner.CornerRadius = UDim.new(0, 8)
	cancelCorner.Parent = cancelButton
	
	cancelButton.MouseButton1Click:Connect(function()
		hideQuestUI()
	end)
end

-- Update quest display
local function updateQuestDisplay(quest: any)
	if not questUI or not questUI.Parent then return end
	
	local titleLabel = questUI:FindFirstChild("MainFrame"):FindFirstChild("Header"):FindFirstChild("Title")
	local descLabel = questUI:FindFirstChild("MainFrame"):FindFirstChild("Description")
	
	if titleLabel then
		titleLabel.Text = quest.Title or "Untitled Quest"
	end
	
	if descLabel then
		descLabel.Text = quest.DramaticSituation or "No description available."
	end
	
	-- Update slots
	if quest.Slots then
		for slotId, slotData in pairs(quest.Slots) do
			local slotButton = slotButtons[slotId]
			if slotButton then
				local typeLabel = slotButton:FindFirstChild("TypeLabel")
				local contentLabel = slotButton:FindFirstChild("ContentLabel")
				
				if typeLabel then
					typeLabel.Text = slotData.SlotType or "UNKNOWN"
				end
				
				if contentLabel then
					if slotData.PlayerEntry then
						contentLabel.Text = slotData.PlayerEntry
						contentLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					else
						contentLabel.Text = "Empty"
						contentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end
	end
end

-- Show quest UI
local function showQuestUI(quest: any)
	currentQuest = quest
	isQuestActive = true
	
	if not questUI then
		buildQuestUI()
	end
	
	updateQuestDisplay(quest)
	
	-- Fade in
	local mainFrame = questUI:FindFirstChild("MainFrame")
	if mainFrame then
		mainFrame.BackgroundTransparency = 0.2
		
		local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(UI_FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 0
		})
		fadeIn:Play()
	end
	
	questSounds.accept:Play()
	print("[QuestUIController] Showing quest:", quest.Title)
end

-- Hide quest UI
local function hideQuestUI()
	if not questUI or not questUI.Parent then return end
	
	local mainFrame = questUI:FindFirstChild("MainFrame")
	if mainFrame then
		local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(UI_FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		})
		fadeOut:Play()
		fadeOut.Completed:Connect(function()
			questUI.Parent = nil
		end)
	end
	
	isQuestActive = false
	currentQuest = nil
	selectedSlime = nil
end

-- Handle slot clicks
local function onSlotClicked(slotId: string)
	if not isQuestActive or not currentQuest then return end
	
	if selectedSlime then
		-- Try to fill the slot
		local success, result = pcall(function()
			return MadLibService:FillQuestSlot(Players.LocalPlayer, currentQuest.QuestId, slotId, selectedSlime)
		end)
		
		if success and result then
			questSounds.slotFill:Play()
			print("[QuestUIController] Filled slot:", slotId, "with slime:", selectedSlime)
			
			-- Update display
			local slotData = currentQuest.Slots[slotId]
			if slotData then
				slotData.PlayerEntry = selectedSlime
				slotData.InstanceId = selectedSlime
				updateQuestDisplay(currentQuest)
			end
		else
			questSounds.error:Play()
			warn("[QuestUIController] Failed to fill slot:", result)
		end
		
		selectedSlime = nil
	else
		-- Select a slime (would need slime selection UI)
		questSounds.error:Play()
		print("[QuestUIController] No slime selected")
	end
end

-- Attempt quest completion
local function attemptQuestCompletion()
	if not isQuestActive or not currentQuest then return end
	
	local success, result = pcall(function()
		return MadLibService:CompleteQuest(Players.LocalPlayer)
	end)
	
	if success and result then
		questSounds.complete:Play()
		print("[QuestUIController] Quest completed!")
		
		-- Show completion message
		local mainFrame = questUI:FindFirstChild("MainFrame")
		if mainFrame then
			local completeLabel = Instance.new("TextLabel")
			completeLabel.Name = "CompleteMessage"
			completeLabel.Size = UDim2.new(1, -40, 0, 50)
			completeLabel.Position = UDim2.fromOffset(20, 250)
			completeLabel.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
			completeLabel.BorderSizePixel = 0
			completeLabel.Text = "✓ Quest Completed! +20 XP"
			completeLabel.TextColor3 = Color3.new(1, 1, 1)
			completeLabel.Font = Enum.Font.GothamBold
			completeLabel.TextSize = 20
			completeLabel.Parent = mainFrame
			
			local completeCorner = Instance.new("UICorner")
			completeCorner.CornerRadius = UDim.new(0, 10)
			completeCorner.Parent = completeLabel
			
			-- Auto-hide after delay
			task.delay(QUEST_COMPLETE_DURATION, function()
				hideQuestUI()
			end)
		end
	else
		questSounds.error:Play()
		warn("[QuestUIController] Failed to complete quest:", result)
	end
end

-- Service connections
local function connectToServices()
	-- Get MadLibService
	local success, service = pcall(function()
		return Knit.GetService("MadLibService")
	end)
	
	if success and service then
		MadLibService = service
		
		-- Connect to quest events
		MadLibService.QuestGenerated:Connect(function(quest)
			showQuestUI(quest)
		end)
		
		MadLibService.QuestCompleted:Connect(function(questTitle)
			print("[QuestUIController] Quest completed:", questTitle)
		end)
	else
		warn("[QuestUIController] MadLibService not available")
	end
	
	-- Get GameLoopService
	local success, service = pcall(function()
		return Knit.GetService("GameLoopService")
	end)
	
	if success and service then
		GameLoopService = service
		
		-- Listen for phase changes
		GameLoopService.PhaseChanged:Connect(function(phase)
			if phase ~= "Quest" then
				hideQuestUI()
			end
		end)
	else
		warn("[QuestUIController] GameLoopService not available")
	end
	
	-- Get SlimeFactory
	local success, service = pcall(function()
		return Knit.GetService("SlimeFactory")
	end)
	
	if success and service then
		SlimeFactory = service
	else
		warn("[QuestUIController] SlimeFactory not available")
	end
end

-- Controller lifecycle
function QuestUIController:KnitStart()
	print("[QuestUIController] Starting...")
	
	setupSounds()
	connectToServices()
	
	print("[QuestUIController] Started.")
end

function QuestUIController:KnitStop()
	hideQuestUI()
	print("[QuestUIController] Stopped.")
end

-- Public methods
function QuestUIController:ShowQuest(quest: any)
	showQuestUI(quest)
end

function QuestUIController:HideQuest()
	hideQuestUI()
end

function QuestUIController:IsQuestActive(): boolean
	return isQuestActive
end

return QuestUIController
