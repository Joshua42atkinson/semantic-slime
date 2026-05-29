--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TutorialUI = {}
TutorialUI.__index = TutorialUI

-- State
local tutorialScreen: ScreenGui? = nil
local currentStep = 0
local isOpen = false

-- Tutorial steps
local TUTORIAL_STEPS = {
	{
		title = "Welcome to Syllable Springs!",
		content = "In this world, words are alive! You'll catch SLIMES made of letters and build WORDS OF POWER to save the city.",
		emoji = "🏛️",
	},
	{
		title = "Collect Letter Crystals",
		content = "Walk around the districts and collect letter crystals from the ground. Each letter is a building block for words!",
		emoji = "💎",
		keyHint = "Walk over crystals to collect them",
	},
	{
		title = "Build Words at the Fabricator",
		content = "Use your letters at the Slime Fabricator in the Town Hub to create words. Each word becomes a SLIME companion!",
		emoji = "🧪",
		keyHint = "Press F to open the Fabricator",
	},
	{
		title = "Set Your Companion",
		content = "Choose your favorite slime as a COMPANION! They'll follow you around and chat with you using element-based dialogue.",
		emoji = "⭐",
		keyHint = "Open Collection (I) and click 'Set as Companion'",
	},
	{
		title = "Complete Quests",
		content = "Talk to NPCs and use your slimes to solve word-based quests. Your slimes grow stronger through usage!",
		emoji = "📜",
		keyHint = "Press J to open Quest Log",
	},
	{
		title = "You're Ready!",
		content = "Explore Syllable Springs, collect slimes, and become a Word Master! Good luck, linguist!",
		emoji = "🎮",
		keyHint = "Have fun!",
	},
}

-- Colors
local COLORS = {
	Background = Color3.fromHex("#0F0E17"),
	CardBg = Color3.fromHex("#1A1A2E"),
	Accent = Color3.fromHex("#FF8906"),
	Text = Color3.fromHex("#FFFFFE"),
	TextDim = Color3.fromHex("#A7A9BE"),
	Success = Color3.fromHex("#2CB67D"),
}

function TutorialUI.Show()
	if isOpen then return end
	isOpen = true
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local DataService = Knit.GetService("DataService")
	DataService:GetProfile():andThen(function(profile)
	if profile and profile.TutorialCompleted then
		isOpen = false
		return -- Skip if already done
	end
	
	-- Create screen
	tutorialScreen = Instance.new("ScreenGui")
	tutorialScreen.Name = "TutorialUI"
	tutorialScreen.ResetOnSpawn = false
	tutorialScreen.IgnoreGuiInset = true
	tutorialScreen.Parent = playerGui
	
	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.7
	overlay.BorderSizePixel = 0
	overlay.Parent = tutorialScreen
	
	-- Main card
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.fromOffset(500, 350)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.BackgroundColor3 = COLORS.Background
	card.Parent = tutorialScreen
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 16)
	cardCorner.Parent = card
	
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = COLORS.Accent
	cardStroke.Thickness = 2
	cardStroke.Parent = card
	
	-- Progress dots container
	local dotsContainer = Instance.new("Frame")
	dotsContainer.Name = "ProgressDots"
	dotsContainer.Size = UDim2.fromScale(1, 0.1)
	dotsContainer.Position = UDim2.fromScale(0, 0.05)
	dotsContainer.BackgroundTransparency = 1
	dotsContainer.Parent = card
	
	-- Create progress dots
	for i = 1, #TUTORIAL_STEPS do
		local dot = Instance.new("Frame")
		dot.Size = UDim2.fromOffset(10, 10)
		dot.Position = UDim2.fromScale((i - 0.5) / #TUTORIAL_STEPS, 0.5)
		dot.AnchorPoint = Vector2.new(0.5, 0.5)
		dot.BackgroundColor3 = i == 1 and COLORS.Accent or COLORS.CardBg
		dot.Name = "Dot_" .. i
		dot.Parent = dotsContainer
		
		local dotCorner = Instance.new("UICorner")
		dotCorner.CornerRadius = UDim.new(1, 0)
		dotCorner.Parent = dot
	end
	
	-- Content container
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 0.8)
	content.Position = UDim2.fromScale(0, 0.15)
	content.BackgroundTransparency = 1
	content.Parent = card
	
	-- Emoji
	local emojiLabel = Instance.new("TextLabel")
	emojiLabel.Name = "Emoji"
	emojiLabel.Size = UDim2.fromScale(1, 0.25)
	emojiLabel.BackgroundTransparency = 1
	emojiLabel.Text = TUTORIAL_STEPS[1].emoji
	emojiLabel.Font = Enum.Font.Gotham
	emojiLabel.TextSize = 48
	emojiLabel.Parent = content
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.fromScale(1, 0.2)
	titleLabel.Position = UDim2.fromScale(0, 0.25)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = COLORS.Accent
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.Text = TUTORIAL_STEPS[1].title
	titleLabel.Parent = content
	
	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.fromScale(1, 0.35)
	descLabel.Position = UDim2.fromScale(0, 0.45)
	descLabel.BackgroundTransparency = 1
	descLabel.TextColor3 = COLORS.Text
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextSize = 16
	descLabel.TextWrapped = true
	descLabel.Text = TUTORIAL_STEPS[1].content
	descLabel.Parent = content
	
	-- Key hint (if exists)
	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "Hint"
	hintLabel.Size = UDim2.fromScale(1, 0.15)
	hintLabel.Position = UDim2.fromScale(0, 0.85)
	hintLabel.BackgroundTransparency = 1
	hintLabel.TextColor3 = COLORS.TextDim
	hintLabel.Font = Enum.Font.Gotham
	hintLabel.TextSize = 14
	hintLabel.Text = TUTORIAL_STEPS[1].keyHint or ""
	hintLabel.Visible = TUTORIAL_STEPS[1].keyHint ~= nil
	hintLabel.Parent = content
	
	-- Navigation buttons
	local navContainer = Instance.new("Frame")
	navContainer.Name = "NavButtons"
	navContainer.Size = UDim2.fromScale(1, 0.1)
	navContainer.Position = UDim2.fromScale(0, 0.9)
	navContainer.BackgroundTransparency = 1
	navContainer.Parent = card
	
	-- Back button (hidden on first)
	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.fromOffset(80, 35)
	backBtn.Position = UDim2.fromScale(0, 0.5)
	backBtn.AnchorPoint = Vector2.new(0, 0.5)
	backBtn.BackgroundColor3 = COLORS.CardBg
	backBtn.TextColor3 = COLORS.Text
	backBtn.Font = Enum.Font.GothamBold
	backBtn.TextSize = 14
	backBtn.Text = "← Back"
	backBtn.Visible = false
	backBtn.Parent = navContainer
	
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0, 8)
	backCorner.Parent = backBtn
	
	-- Skip button
	local skipBtn = Instance.new("TextButton")
	skipBtn.Name = "SkipBtn"
	skipBtn.Size = UDim2.fromOffset(80, 35)
	skipBtn.Position = UDim2.fromScale(0.5, 0.5)
	skipBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	skipBtn.BackgroundColor3 = COLORS.CardBg
	skipBtn.TextColor3 = COLORS.TextDim
	skipBtn.Font = Enum.Font.Gotham
	skipBtn.TextSize = 12
	skipBtn.Text = "Skip Tutorial"
	skipBtn.Parent = navContainer
	
	local skipCorner = Instance.new("UICorner")
	skipCorner.CornerRadius = UDim.new(0, 8)
	skipCorner.Parent = skipBtn
	
	-- Next button
	local nextBtn = Instance.new("TextButton")
	nextBtn.Name = "NextBtn"
	nextBtn.Size = UDim2.fromOffset(100, 35)
	nextBtn.Position = UDim2.fromScale(1, 0.5)
	nextBtn.AnchorPoint = Vector2.new(1, 0.5)
	nextBtn.BackgroundColor3 = COLORS.Accent
	nextBtn.TextColor3 = COLORS.Text
	nextBtn.Font = Enum.Font.GothamBold
	nextBtn.TextSize = 14
	nextBtn.Text = "Next →"
	nextBtn.Parent = navContainer
	
	local nextCorner = Instance.new("UICorner")
	nextCorner.CornerRadius = UDim.new(0, 8)
	nextCorner.Parent = nextBtn
	
	-- Button handlers
	local function updateStep(stepIndex: number)
		currentStep = stepIndex
		local step = TUTORIAL_STEPS[stepIndex]
		
		-- Update content
		emojiLabel.Text = step.emoji
		titleLabel.Text = step.title
		descLabel.Text = step.content
		hintLabel.Text = step.keyHint or ""
		hintLabel.Visible = step.keyHint ~= nil
		
		-- Update dots
		for i = 1, #TUTORIAL_STEPS do
			local dot = dotsContainer:FindFirstChild("Dot_" .. i)
			if dot then
				dot.BackgroundColor3 = i <= stepIndex and COLORS.Accent or COLORS.CardBg
			end
		end
		
		-- Update buttons
		backBtn.Visible = stepIndex > 1
		nextBtn.Text = stepIndex == #TUTORIAL_STEPS and "Finish!" or "Next →"
		
		-- Animate content
		content.Position = UDim2.fromScale(-0.2, 0.15)
		TweenService:Create(content, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			Position = UDim2.fromScale(0, 0.15)
		}):Play()
	end
	
	local function nextStep()
		if currentStep < #TUTORIAL_STEPS then
			updateStep(currentStep + 1)
		else
			TutorialUI.Complete()
		end
	end
	
	local function prevStep()
		if currentStep > 1 then
			updateStep(currentStep - 1)
		end
	end
	
	nextBtn.MouseButton1Click:Connect(nextStep)
	backBtn.MouseButton1Click:Connect(prevStep)
	skipBtn.MouseButton1Click:Connect(TutorialUI.Complete)
	
	-- Keyboard navigation
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.Space then
			nextStep()
		elseif input.KeyCode == Enum.KeyCode.Left and currentStep > 1 then
			prevStep()
		elseif input.KeyCode == Enum.KeyCode.Escape then
			TutorialUI.Complete()
		end
	end)
	
	-- Entrance animation
	card.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(500, 350)
	}):Play()
	
	-- Store references for updates
	tutorialScreen:SetAttribute("CurrentStep", 1)
	end):catch(function(err)
		isOpen = false
		warn("[TutorialUI]", err)
	end)
end

function TutorialUI.Complete()
	if not isOpen or not tutorialScreen then return end
	
	isOpen = false
	
	-- Mark tutorial as completed
	local DataService = Knit.GetService("DataService")
	DataService:CompleteTutorial():catch(warn)
	
	-- Animate out
	local card = tutorialScreen:FindFirstChild("Card")
	if card then
		TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.fromOffset(0, 0)
		}):Play()
	end
	
	task.wait(0.35)
	if tutorialScreen then
		tutorialScreen:Destroy()
		tutorialScreen = nil
	end
	
	-- Trigger first quest
	task.spawn(function()
		task.wait(1)
		local QuestService = Knit.GetService("QuestService")
		if QuestService and QuestService.AssignFirstQuest then
			QuestService:AssignFirstQuest(Players.LocalPlayer)
		end
	end)
	
	print("[TutorialUI] Tutorial completed!")
end

function TutorialUI.Hide()
	if not isOpen or not tutorialScreen then return end
	
	isOpen = false
	
	if tutorialScreen then
		tutorialScreen:Destroy()
		tutorialScreen = nil
	end
end

-- Initialize - show tutorial on first join
function TutorialUI.Initialize()
	-- Wait for data to load, then show tutorial
	task.spawn(function()
		task.wait(2) -- Wait for services to initialize
		
		local DataService = Knit.GetService("DataService")
		local SlimeFactory = Knit.GetService("SlimeFactory")
		
		DataService:GetProfile():andThen(function(profile)
			SlimeFactory:GetPlayerSlimes():andThen(function(slimes)
				local slimeCount = 0
				if slimes then
					for _ in pairs(slimes) do slimeCount += 1 end
				end
				
				if profile and not profile.TutorialCompleted and slimeCount == 0 then
					task.wait(3) -- Small delay for player to get oriented
					-- TutorialUI.Show() -- Disabled for UI Simplification
				end
			end):catch(warn)
		end):catch(warn)
	end)
	
	print("[TutorialUI] Initialized")
end

return TutorialUI
