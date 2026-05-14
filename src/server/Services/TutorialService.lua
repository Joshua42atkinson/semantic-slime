--!strict
--==============================================================
-- MMMM Context: Onboards players into the Semantic Ecology. Explains that letters are volatile entities, not just UI elements.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TutorialService = Knit.CreateService {
	Name = "TutorialService",
	Client = {
		TutorialStep = Knit.CreateSignal(),
		TutorialComplete = Knit.CreateSignal(),
	},
}

-- Client-facing method wrappers (Knit requires these to be in Client table)
function TutorialService.Client:StartTutorial(player: Player)
	return self.Server:StartTutorial(player)
end

function TutorialService.Client:AdvanceStep(player: Player)
	return self.Server:AdvanceStep(player)
end

function TutorialService.Client:SkipTutorial(player: Player)
	return self.Server:SkipTutorial(player)
end

local TutorialServiceServer = TutorialService

export type TutorialStep = {
	Title: string,
	Message: string,
	Highlight: string?,
	Action: string?,
}

local TUTORIAL_STEPS: { TutorialStep } = {
	{
		Title = "Welcome to Syllable Springs!",
		Message = "Your adventure begins here! I'm Zog, your guide to the world of words.",
		Action = "Continue",
	},
	{
		Title = "Collect Letter Crystals",
		Message = "Look for glowing crystals around you! Press E near them to collect letters. You'll need these to build words.",
		Highlight = "Crystals",
		Action = "Collect a crystal",
	},
	{
		Title = "Build Words",
		Message = "Press K to open the Slime Fabricator. Use your collected letters to spell words and create semantic slimes!",
		Highlight = "Fabricator",
		Action = "Open Fabricator",
	},
	{
		Title = "Complete Quests",
		Message = "Talk to NPCs (press E) to receive Mad-Lib quests. Fill in the blanks with your slimes to earn rewards!",
		Highlight = "Quest",
		Action = "Accept a quest",
	},
	{
		Title = "Battle for Slots",
		Message = "When multiple players want the same quest slot, you'll battle! Use Attack, Defend, or semantic wordplay to win!",
		Highlight = "Battle",
		Action = "Win a battle",
	},
	{
		Title = "You're Ready!",
		Message = "Explore Syllable Springs, catch Etymons, and become a Master Wordsmith! Good luck!",
		Action = "Start Playing",
	},
}

local playerProgress: { [Player]: number } = {}
local tutorialComplete: { [Player]: boolean } = {}

function TutorialService:KnitStart()
	print("[TutorialService] Started.")
	
	Players.PlayerAdded:Connect(function(player)
		playerProgress[player] = 0
		tutorialComplete[player] = false
	end)
	
	Players.PlayerRemoving:Connect(function(player)
		playerProgress[player] = nil
		tutorialComplete[player] = nil
	end)
end

function TutorialService:IsTutorialComplete(player: Player): boolean
	return tutorialComplete[player] == true
end

function TutorialService:GetCurrentStep(player: Player): TutorialStep?
	if tutorialComplete[player] then
		return nil
	end
	
	local stepIndex = playerProgress[player] or 0
	if stepIndex < 1 or stepIndex > #TUTORIAL_STEPS then
		return nil
	end
	
	return TUTORIAL_STEPS[stepIndex]
end

function TutorialService:AdvanceStep(player: Player): TutorialStep?
	if tutorialComplete[player] then
		return nil
	end
	
	local currentStep = playerProgress[player] or 0
	
	if currentStep >= #TUTORIAL_STEPS then
		tutorialComplete[player] = true
		self.Client.TutorialComplete:Fire(player)
		return nil
	end
	
	playerProgress[player] = currentStep + 1
	local newStep = TUTORIAL_STEPS[playerProgress[player]]
	
	self.Client.TutorialStep:Fire(player, newStep, playerProgress[player], #TUTORIAL_STEPS)
	
	return newStep
end

function TutorialService:SkipTutorial(player: Player)
	tutorialComplete[player] = true
	playerProgress[player] = #TUTORIAL_STEPS
	self.Client.TutorialComplete:Fire(player)
end

function TutorialService:StartTutorial(player: Player)
	playerProgress[player] = 1
	if #TUTORIAL_STEPS > 0 then
		self.Client.TutorialStep:Fire(player, TUTORIAL_STEPS[1], 1, #TUTORIAL_STEPS)
	end
end

return TutorialService
