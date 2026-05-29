--!strict
-- OntologicalMirrorService.lua
-- THE TRINITY COUSIN SYSTEM. 
-- "Words are not things. They are the shadows of the mind that cast them."
--
-- This service tracks the semantic footprint of the player's vocabulary choices.
-- Are they building violent words (strike, burn)? Ethereal words (float, dream)?
-- When the Night phase falls, it plunges the player into the Reflection Quest.
-- The AI stops being an NPC and becomes the Mirror, asking the player WHY they chose
-- the words they did, bridging the game state directly into their real-world affective domain.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- A player's semantic footprint
type SemanticFootprint = {
	WordsConstructed: {string},
	DominantElement: string,
	AverageBST: number,
	EmotionalValence: number, -- -1 (hostile/aggressive) to 1 (peaceful/creative)
}

local OntologicalMirrorService = Knit.CreateService {
	Name = "OntologicalMirrorService",
	Client = {
		EnterTheVoid = Knit.CreateSignal(), -- Teleports the client into the reflection UI
		ReturnToReality = Knit.CreateSignal(),
		AskSocraticQuestion = Knit.CreateSignal(),
		SubmitReflection = Knit.CreateSignal(), -- Client submitting their answer
	},
}

local playerFootprints: {[Player]: SemanticFootprint} = {}
local activeReflections: {[Player]: boolean} = {}

-- Initialize a fresh footprint
local function createFootprint(): SemanticFootprint
	return {
		WordsConstructed = {},
		DominantElement = "Neutral",
		AverageBST = 0,
		EmotionalValence = 0,
	}
end

function OntologicalMirrorService:KnitStart()
	print("[OntologicalMirrorService] 🪞 The Mirror is waking. Watching player intent.")
	
	Players.PlayerAdded:Connect(function(player)
		playerFootprints[player] = createFootprint()
	end)
	Players.PlayerRemoving:Connect(function(player)
		playerFootprints[player] = nil
		activeReflections[player] = nil
	end)

	-- We listen to the SlimeFactory. Every time a word is born, the Mirror watches.
	local SlimeFactory = Knit.GetService("SlimeFactory")
	if SlimeFactory then
		-- SlimeFactory calls OntologicalMirrorService:RecordWord() directly.
	end

	-- Connect to the GameLoop. When Night falls, The Void opens.
	-- Use task.defer to ensure GameLoopService's BindableEvents are fully initialized.
	task.defer(function()
		local ok, GameLoopService = pcall(function()
			return Knit.GetService("GameLoopService")
		end)
		if ok and GameLoopService and GameLoopService.PhaseChanged then
			GameLoopService.PhaseChanged:Connect(function(newPhase)
				if newPhase == "Rewards" or newPhase == "Night" or newPhase == "Reflection" then
					self:TriggerServerWideReflection()
				elseif newPhase == "Collection" then
					self:EndServerWideReflection()
				end
			end)
			print("[OntologicalMirrorService] Connected to GameLoopService.PhaseChanged")
		else
			warn("[OntologicalMirrorService] GameLoopService not available — The Void won't auto-trigger")
		end
	end)
	
	-- When the client submits their reflection
	self.Client.SubmitReflection:Connect(function(player, responseText)
		self:ProcessReflection(player, responseText)
	end)
end

-- Called by SlimeFactory when a player builds a word.
function OntologicalMirrorService:RecordWord(player: Player, word: string, stats: any, element: string)
	local footprint = playerFootprints[player]
	if not footprint then return end

	table.insert(footprint.WordsConstructed, word)
	
	-- Keep only the last 15 words to represent their current psychological state
	if #footprint.WordsConstructed > 15 then
		table.remove(footprint.WordsConstructed, 1)
	end

	-- Update averages
	footprint.DominantElement = element
	print(string.format("[OntologicalMirrorService] 🪞 %s constructed '%s'. The Mirror remembers.", player.Name, word))
	
	-- Here we would ideally run a local sentiment analysis, but we map simple vectors.
	-- If they use "fire", valence goes down (aggressive). "water", valence goes up (fluid).
	if element == "Fire" or element == "Shadow" then
		footprint.EmotionalValence -= 0.1
	elseif element == "Water" or element == "Light" then
		footprint.EmotionalValence += 0.1
	end
end

-- The core TRINITY crossover: AI as a Mirror
function OntologicalMirrorService:TriggerServerWideReflection()
	local AIService = Knit.GetService("AIService")
	
	for _, player in ipairs(Players:GetPlayers()) do
		local footprint = playerFootprints[player]
		if not footprint or #footprint.WordsConstructed == 0 then continue end
		
		activeReflections[player] = true
		
		-- Teleport player into the psychological void (handled on client side visually)
		self.Client.EnterTheVoid:Fire(player)
		print("[OntologicalMirrorService] 🌌 " .. player.Name .. " has entered The Void.")

		if not AIService then
			-- Fallback Question
			task.wait(3)
			self.Client.AskSocraticQuestion:Fire(player, "You have been building walls of words. What are you trying to protect, " .. player.Name .. "?")
			continue
		end

		-- The TRINITY Prompt: Generate the Socratic Reflection
		local wordsList = table.concat(footprint.WordsConstructed, ", ")
		local prompt = string.format([[
You are the Ontological Mirror, a Socratic guide inside the mind of the player.
The player has spent this session constructing these exact words to survive and progress: %s.

Analyze this linguistic footprint. What does it say about their current psychological state? Are they aggressive? Defensive? Creative? Avoiding something?

Ask them ONE direct, profound, and slightly uncomfortable Socratic question about their real-world feelings or mindset, based ONLY on the words they chose to build. Do not mention stats or elements. Focus entirely on the human behind the screen.
Keep the question under 2 sentences.
]], wordsList)

		-- We run the AI call asynchronously
		task.spawn(function()
			-- Simulate the AI call if AIService isn't fully wired for this exact prompt yet
			local ok, question = pcall(function()
				return AIService:GenerateTextInternal(prompt)
			end)
			
			if not ok or not question then
				question = "Looking at the words you've chosen... what are you searching for that you haven't found yet?"
			end

			if activeReflections[player] then
				self.Client.AskSocraticQuestion:Fire(player, question)
			end
		end)
	end
end

-- Process the player's introspective answer
function OntologicalMirrorService:ProcessReflection(player: Player, responseText: string)
	if not activeReflections[player] then return end
	
	print(string.format("[OntologicalMirrorService] 🪞 %s reflected: '%s'", player.Name, responseText))
	
	-- In TRINITY, the answer defines them. Here, it births the Ego Slime.
	-- We clear their footprint because they have synthesized it.
	playerFootprints[player] = createFootprint()
	activeReflections[player] = false
	
	self.Client.ReturnToReality:Fire(player, responseText)
	
	-- [Reward]: Spawn a hyper-rare "Ego Slime" representing their synthesis.
	-- The slime's element is derived from the sentiment of their answer.
	local SlimeFactory = Knit.GetService("SlimeFactory")
	if SlimeFactory then
		task.defer(function()
			pcall(function()
				-- Create a unique slime based on their exact answer snippet
				SlimeFactory:CreateEgoSlime(player, responseText)
			end)
		end)
	end
end

function OntologicalMirrorService:EndServerWideReflection()
	for player, active in pairs(activeReflections) do
		if active then
			activeReflections[player] = false
			self.Client.ReturnToReality:Fire(player, "Silence.")
		end
	end
end

return OntologicalMirrorService
