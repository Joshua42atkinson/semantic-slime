--!strict
--==============================================================
-- MMMM Context: Orchestrates complex multi-stage quests. Ensures that word-building tasks have narrative stakes rather than isolated quizzes.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local ScenarioService = Knit.CreateService {
	Name = "ScenarioService",
	Client = {
		ScenarioStarted = Knit.CreateSignal(),
		ScenarioCompleted = Knit.CreateSignal(),
		PromptGenerated = Knit.CreateSignal(),
	},
}

-- Types
export type ScenarioCard = {
	CardId: string,
	Title: string,
	Description: string,
	MorphemeFocus: string,
	Difficulty: "Easy" | "Medium" | "Hard",
	TimeLimit: number, -- seconds
	Questions: { ScenarioQuestion },
}

export type ScenarioQuestion = {
	QuestionId: string,
	Prompt: string,
	CorrectAnswer: string,
	MorphemeRequired: string?,
	Points: number,
}

export type ActiveScenario = {
	ScenarioId: string,
	CardId: string,
	PlayerId: number,
	Status: "InProgress" | "Completed" | "TimedOut",
	CurrentQuestion: number,
	TotalQuestions: number,
	Score: number,
	StartedAt: number,
	EndedAt: number?,
	MorphemeProgress: { [string]: number }, -- morpheme -> correct count
}

-- Pre-built Scenario Cards (10 cards)
local SCENARIO_CARDS: { [string]: ScenarioCard } = {
	["word_building_1"] = {
		CardId = "word_building_1",
		Title = "Building Blocks",
		Description = "Learn how to add suffixes to change word meaning",
		MorphemeFocus = "-s",
		Difficulty = "Easy",
		TimeLimit = 120,
		Questions = {
			{ QuestionId = "q1", Prompt = "What do you add to 'cat' to mean more than one?", CorrectAnswer = "s", Points = 10 },
			{ QuestionId = "q2", Prompt = "Add a suffix to 'dog' for plurals", CorrectAnswer = "s", Points = 10 },
			{ QuestionId = "q3", Prompt = "How do we show 'book' is plural?", CorrectAnswer = "s", Points = 10 },
		},
	},
	["past_tense_1"] = {
		CardId = "past_tense_1",
		Title = "Time Travel",
		Description = "Practice adding -ed for past tense",
		MorphemeFocus = "-ed",
		Difficulty = "Easy",
		TimeLimit = 120,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add -ed to 'walk' to show it happened before", CorrectAnswer = "walked", Points = 10 },
			{ QuestionId = "q2", Prompt = "What is 'play' with -ed added?", CorrectAnswer = "played", Points = 10 },
			{ QuestionId = "q3", Prompt = "How do you say 'help' in past tense?", CorrectAnswer = "helped", Points = 10 },
		},
	},
	["suffix_master_1"] = {
		CardId = "suffix_master_1",
		Title = "Suffix Superstar",
		Description = "Master various suffixes",
		MorphemeFocus = "mixed",
		Difficulty = "Medium",
		TimeLimit = 180,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 'er' to 'run' for one who does it", CorrectAnswer = "runner", Points = 15 },
			{ QuestionId = "q2", Prompt = "Add 'ing' to 'sing'", CorrectAnswer = "singing", Points = 15 },
			{ QuestionId = "q3", Prompt = "Add 'ful' to 'help'", CorrectAnswer = "helpful", Points = 15 },
			{ QuestionId = "q4", Prompt = "Add 'ness' to 'happy'", CorrectAnswer = "happiness", Points = 15 },
		},
	},
	["negation_1"] = {
		CardId = "negation_1",
		Title = "Saying NO",
		Description = "Learn to negate with un- and -less",
		MorphemeFocus = "un-",
		Difficulty = "Medium",
		TimeLimit = 150,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 'un' to 'happy' to mean not happy", CorrectAnswer = "unhappy", Points = 15 },
			{ QuestionId = "q2", Prompt = "What is 'do' with un- at front?", CorrectAnswer = "undo", Points = 15 },
			{ QuestionId = "q3", Prompt = "Add 'un' to 'known'", CorrectAnswer = "unknown", Points = 15 },
		},
	},
	["prefix_adventure_1"] = {
		CardId = "prefix_adventure_1",
		Title = "Prefix Explorer",
		Description = "Discover how prefixes change words",
		MorphemeFocus = "pre-",
		Difficulty = "Medium",
		TimeLimit = 150,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 'pre' to 'view' for before viewing", CorrectAnswer = "preview", Points = 15 },
			{ QuestionId = "q2", Prompt = "What is 'heat' with pre-?", CorrectAnswer = "preheat", Points = 15 },
			{ QuestionId = "q3", Prompt = "Add 'pre' to 'history'", CorrectAnswer = "prehistory", Points = 15 },
		},
	},
	["compound_words_1"] = {
		CardId = "compound_words_1",
		Title = "Word Combo",
		Description = "Combine words to make new ones",
		MorphemeFocus = "compound",
		Difficulty = "Hard",
		TimeLimit = 180,
		Questions = {
			{ QuestionId = "q1", Prompt = "Combine 'rain' and 'bow'", CorrectAnswer = "rainbow", Points = 20 },
			{ QuestionId = "q2", Prompt = "Combine 'book' and 'shelf'", CorrectAnswer = "bookshelf", Points = 20 },
			{ QuestionId = "q3", Prompt = "Combine 'sun' and 'flower'", CorrectAnswer = "sunflower", Points = 20 },
			{ QuestionId = "q4", Prompt = "Combine 'star' and 'fish'", CorrectAnswer = "starfish", Points = 20 },
		},
	},
	["suffix_scientist_1"] = {
		CardId = "suffix_scientist_1",
		Title = "Suffix Scientist",
		Description = "Advanced suffix combinations",
		MorphemeFocus = "-tion",
		Difficulty = "Hard",
		TimeLimit = 180,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 'tion' to 'act'", CorrectAnswer = "action", Points = 20 },
			{ QuestionId = "q2", Prompt = "What is 'educate' with -tion?", CorrectAnswer = "education", Points = 20 },
			{ QuestionId = "q3", Prompt = "Add 'tion' to 'invite'", CorrectAnswer = "invitation", Points = 20 },
			{ QuestionId = "q4", Prompt = "What does 'create' become with -tion?", CorrectAnswer = "creation", Points = 20 },
		},
	},
	["morpheme_mixologist_1"] = {
		CardId = "morpheme_mixologist_1",
		Title = "Morpheme Mixologist",
		Description = "Complex word building challenges",
		MorphemeFocus = "mixed",
		Difficulty = "Hard",
		TimeLimit = 200,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 're' and 'ing' to 'do'", CorrectAnswer = "redoing", Points = 25 },
			{ QuestionId = "q2", Prompt = "Add 'un' and 'able' to 'lock'", CorrectAnswer = "unlockable", Points = 25 },
			{ QuestionId = "q3", Prompt = "Add 'pre' and 'ed' to 'heat'", CorrectAnswer = "preheated", Points = 25 },
		},
	},
	["possession_1"] = {
		CardId = "possession_1",
		Title = "Ownership",
		Description = "Learning to show ownership with 's",
		MorphemeFocus = "'s",
		Difficulty = "Easy",
		TimeLimit = 120,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add apostrophe s to 'mom' to show she owns something", CorrectAnswer = "mom's", Points = 10 },
			{ QuestionId = "q2", Prompt = "How do you show 'dog has a bone'?", CorrectAnswer = "dog's", Points = 10 },
			{ QuestionId = "q3", Prompt = "Show ownership for 'the book belongs to John'", CorrectAnswer = "John's", Points = 10 },
		},
	},
	["adjective_creator_1"] = {
		CardId = "adjective_creator_1",
		Title = "Adjective Creator",
		Description = "Making descriptive words",
		MorphemeFocus = "-ful",
		Difficulty = "Easy",
		TimeLimit = 120,
		Questions = {
			{ QuestionId = "q1", Prompt = "Add 'ful' to 'care' to describe full of care", CorrectAnswer = "careful", Points = 10 },
			{ QuestionId = "q2", Prompt = "What is 'help' with 'ful' added?", CorrectAnswer = "helpful", Points = 10 },
			{ QuestionId = "q3", Prompt = "Add 'ful' to 'beauty'", CorrectAnswer = "beautiful", Points = 10 },
		},
	},
}

-- Private state
local activeScenarios: { [string]: ActiveScenario } = {}

-- [SCENARIO-001] Get available scenario cards
function ScenarioService:GetAvailableScenarios(): { ScenarioCard }
	local cards = {}
	for _, card in pairs(SCENARIO_CARDS) do
		table.insert(cards, card)
	end
	return cards
end

-- [SCENARIO-002] Get scenario by difficulty
function ScenarioService:GetScenariosByDifficulty(difficulty: string): { ScenarioCard }
	local cards = {}
	for _, card in pairs(SCENARIO_CARDS) do
		if card.Difficulty == difficulty then
			table.insert(cards, card)
		end
	end
	return cards
end

-- [SCENARIO-003] Start a scenario
function ScenarioService:StartScenario(player: Player, cardId: string): (ActiveScenario?, string?)
	local card = SCENARIO_CARDS[cardId]
	if not card then
		return nil, "Scenario card not found"
	end
	
	-- Create active scenario
	local scenario: ActiveScenario = {
		ScenarioId = HttpService:GenerateGUID(false),
		CardId = cardId,
		PlayerId = player.UserId,
		Status = "InProgress",
		CurrentQuestion = 1,
		TotalQuestions = #card.Questions,
		Score = 0,
		StartedAt = os.time(),
		MorphemeProgress = {},
	}
	
	activeScenarios[scenario.ScenarioId] = scenario
	
	self.Client.ScenarioStarted:Fire(player, scenario)
	print("[ScenarioService] " .. player.Name .. " started scenario: " .. card.Title)
	
	return scenario, nil
end

-- [SCENARIO-004] Answer a question
function ScenarioService:AnswerQuestion(player: Player, scenarioId: string, answer: string): (boolean, number?, string?)
	local scenario = activeScenarios[scenarioId]
	if not scenario then
		return false, 0, "Scenario not found"
	end
	
	if scenario.PlayerId ~= player.UserId then
		return false, 0, "Not your scenario"
	end
	
	if scenario.Status ~= "InProgress" then
		return false, 0, "Scenario already completed"
	end
	
	local card = SCENARIO_CARDS[scenario.CardId]
	local question = card.Questions[scenario.CurrentQuestion]
	
	if not question then
		return false, 0, "No more questions"
	end
	
	-- Check answer
	local isCorrect = answer:lower() == question.CorrectAnswer:lower()
	
	if isCorrect then
		scenario.Score = scenario.Score + question.Points
		
		-- Track morpheme progress
		if question.MorphemeRequired then
			local current = scenario.MorphemeProgress[question.MorphemeRequired] or 0
			scenario.MorphemeProgress[question.MorphemeRequired] = current + 1
		end
		
		print("[ScenarioService] " .. player.Name .. " answered correctly: " .. question.CorrectAnswer)
	else
		print("[ScenarioService] " .. player.Name .. " answered incorrectly: " .. answer .. " vs " .. question.CorrectAnswer)
	end
	
	-- Move to next question
	scenario.CurrentQuestion = scenario.CurrentQuestion + 1
	
	-- Check if completed
	if scenario.CurrentQuestion > scenario.TotalQuestions then
		scenario.Status = "Completed"
		scenario.EndedAt = os.time()
		self.Client.ScenarioCompleted:Fire(player, scenario)
		print("[ScenarioService] " .. player.Name .. " completed scenario with score: " .. scenario.Score)
	end
	
	return isCorrect, scenario.Score, nil
end

-- [SCENARIO-005] Get current question
function ScenarioService:GetCurrentQuestion(player: Player, scenarioId: string): (ScenarioQuestion?, number?)
	local scenario = activeScenarios[scenarioId]
	if not scenario then
		return nil, 0
	end
	
	if scenario.PlayerId ~= player.UserId then
		return nil, 0
	end
	
	if scenario.Status ~= "InProgress" then
		return nil, 0
	end
	
	local card = SCENARIO_CARDS[scenario.CardId]
	return card.Questions[scenario.CurrentQuestion], scenario.CurrentQuestion
end

-- [SCENARIO-006] Get scenario results
function ScenarioService:GetScenarioResults(scenarioId: string): ActiveScenario?
	return activeScenarios[scenarioId]
end

-- [SCENARIO-007] Get morpheme progress from completed scenario
function ScenarioService:GetMorphemeProgress(scenarioId: string): { [string]: number }?
	local scenario = activeScenarios[scenarioId]
	if not scenario or scenario.Status ~= "Completed" then
		return nil
	end
	return scenario.MorphemeProgress
end

-- [SCENARIO-008] Timeout scenario
function ScenarioService:CheckTimeouts()
	for scenarioId, scenario in pairs(activeScenarios) do
		if scenario.Status == "InProgress" then
			local card = SCENARIO_CARDS[scenario.CardId]
			local elapsed = os.time() - scenario.StartedAt
			
			if elapsed >= card.TimeLimit then
				scenario.Status = "TimedOut"
				scenario.EndedAt = os.time()
				
				local player = Players:GetPlayerByUserId(scenario.PlayerId)
				if player then
					self.Client.ScenarioCompleted:Fire(player, scenario)
				end
				
				print("[ScenarioService] Scenario " .. scenarioId .. " timed out")
			end
		end
	end
end

function ScenarioService:KnitStart()
	-- Check for timeouts every 10 seconds
	task.spawn(function()
		while true do
			task.wait(10)
			self:CheckTimeouts()
		end
	end)
	
	print("[ScenarioService] Started.")
end

return ScenarioService
