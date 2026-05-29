--!strict
--==============================================================
-- MMMM Context: Tracks the player's personal lexicon journey, reinforcing long-term exposure to Etymology mechanics.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local WordJournalService = Knit.CreateService {
	Name = "WordJournalService",
	Client = {
		WordDiscovered = Knit.CreateSignal(),
		AchievementUnlocked = Knit.CreateSignal(),
	},
}

-- Types
export type JournalEntry = {
	Word: string,
	Term: string,
	Definition: string,
	Etymology: string,
	Morphemes: { string },
	PartOfSpeech: string,
	ExampleSentence: string,
	DiscoveredAt: number,
	TimesUsed: number,
}

-- Configuration
local MORPHEME_MEANINGS: { [string]: string } = {
	["-s"] = "plural",
	["-ed"] = "past tense",
	["-ing"] = "continuous/progressive",
	["-er"] = "one who does",
	["-est"] = "most",
	["-ly"] = "in a way",
	["-ness"] = "state of being",
	["-ful"] = "full of",
	["-less"] = "without",
	["-able"] = "can be",
	["-tion"] = "action/result",
	["-ment"] = "result",
	["un-"] = "not/opposite",
	["pre-"] = "before",
	["re-"] = "again",
	["-ly"] = "manner",
}

-- Private state
local playerJournal: { [number]: { [string]: JournalEntry } } = {} -- userId -> word -> entry
local discoveredWords: { [string]: boolean } = {} -- global tracking

-- [JOURNAL-001] Add word to journal
function WordJournalService:DiscoverWord(player: Player, word: string): JournalEntry?
	local lowerWord = word:lower()
	
	-- Check if already discovered
	if playerJournal[player.UserId] and playerJournal[player.UserId][lowerWord] then
		local entry = playerJournal[player.UserId][lowerWord]
		entry.TimesUsed = entry.TimesUsed + 1
		return entry
	end
	
	-- Parse word for morphemes
	local morphemes = {}
	local remaining = lowerWord
	
	-- Find prefixes
	for prefix, meaning in pairs(MORPHEME_MEANINGS) do
		if string.sub(prefix, 1, 1) ~= "-" and string.sub(prefix, -1) ~= "-" then
			if string.sub(remaining, 1, #prefix) == prefix then
				table.insert(morphemes, prefix)
				remaining = string.sub(remaining, #prefix + 1)
				break
			end
		end
	end
	
	-- Find suffixes
	for suffix, meaning in pairs(MORPHEME_MEANINGS) do
		if string.sub(suffix, 1, 1) == "-" then
			local cleanSuffix = string.sub(suffix, 2)
			if #remaining >= #cleanSuffix and string.sub(remaining, -#cleanSuffix) == cleanSuffix then
				table.insert(morphemes, suffix)
				remaining = string.sub(remaining, 1, -#cleanSuffix - 1)
				break
			end
		end
	end
	
	-- Create entry
	local entry: JournalEntry = {
		Word = lowerWord,
		Term = string.sub(lowerWord, 1, 1):upper() .. string.sub(lowerWord, 2),
		Definition = "A word discovered in Syllable Springs",
		Etymology = remaining ~= "" and remaining or lowerWord,
		Morphemes = morphemes,
		PartOfSpeech = "Unknown",
		ExampleSentence = "The word '" .. lowerWord .. "' was discovered in the wild!",
		DiscoveredAt = os.time(),
		TimesUsed = 1,
	}
	
	-- Store
	if not playerJournal[player.UserId] then
		playerJournal[player.UserId] = {}
	end
	playerJournal[player.UserId][lowerWord] = entry
	
	-- Global discovery
	if not discoveredWords[lowerWord] then
		discoveredWords[lowerWord] = true
	end
	
	self.Client.WordDiscovered:Fire(player, entry)
	print("[WordJournalService] " .. player.Name .. " discovered word: " .. lowerWord)
	
	-- Check for journal achievements
	self:CheckAchievements(player)
	
	return entry
end

-- [JOURNAL-002] Get player's journal
function WordJournalService:GetPlayerJournal(player: Player): { JournalEntry }
	local entries = {}
	if playerJournal[player.UserId] then
		for _, entry in pairs(playerJournal[player.UserId]) do
			table.insert(entries, entry)
		end
	end
	return entries
end

-- [JOURNAL-003] Get word details
function WordJournalService:GetWordDetails(player: Player, word: string): JournalEntry?
	if playerJournal[player.UserId] then
		return playerJournal[player.UserId][word:lower()]
	end
	return nil
end

-- [JOURNAL-004] Search journal
function WordJournalService:SearchJournal(player: Player, query: string): { JournalEntry }
	local results = {}
	local lowerQuery = query:lower()
	
	if playerJournal[player.UserId] then
		for _, entry in pairs(playerJournal[player.UserId]) do
			if string.find(entry.Word, lowerQuery) or string.find(entry.Term, lowerQuery) then
				table.insert(results, entry)
			end
		end
	end
	
	return results
end

-- [JOURNAL-005] Get morpheme breakdown
function WordJournalService:GetMorphemeBreakdown(word: string): { { morpheme: string, meaning: string, position: string } }
	local results = {}
	local remaining = word:lower()
	
	-- Check prefixes
	for morpheme, meaning in pairs(MORPHEME_MEANINGS) do
		if string.sub(morpheme, 1, 1) ~= "-" then
			if string.sub(remaining, 1, #morpheme) == morpheme then
				table.insert(results, {
					morpheme = morpheme,
					meaning = meaning,
					position = "prefix"
				})
				remaining = string.sub(remaining, #morpheme + 1)
				break
			end
		end
	end
	
	-- Check root
	if #remaining > 0 then
		table.insert(results, {
			morpheme = remaining,
			meaning = "root word",
			position = "root"
		})
	end
	
	-- Check suffixes
	for morpheme, meaning in pairs(MORPHEME_MEANINGS) do
		if string.sub(morpheme, 1, 1) == "-" then
			local cleanSuffix = string.sub(morpheme, 2)
			local wordCheck = word:lower()
			if #wordCheck >= #cleanSuffix and string.sub(wordCheck, -#cleanSuffix) == cleanSuffix then
				table.insert(results, {
					morpheme = morpheme,
					meaning = meaning,
					position = "suffix"
				})
				break
			end
		end
	end
	
	return results
end

-- [JOURNAL-006] Get journal statistics
function WordJournalService:GetJournalStats(player: Player): { totalWords: number, uniqueMorphemes: number, mostUsed: string? }
	local stats = {
		totalWords = 0,
		uniqueMorphemes = 0,
		mostUsed = nil,
	}
	
	if playerJournal[player.UserId] then
		stats.totalWords = 0
		local morphemeCounts = {}
		local maxUsage = 0
		
		for _, entry in pairs(playerJournal[player.UserId]) do
			stats.totalWords = stats.totalWords + 1
			
			if entry.TimesUsed > maxUsage then
				maxUsage = entry.TimesUsed
				stats.mostUsed = entry.Term
			end
			
			for _, morpheme in ipairs(entry.Morphemes) do
				morphemeCounts[morpheme] = (morphemeCounts[morpheme] or 0) + 1
			end
		end
		
		for morpheme, _ in pairs(morphemeCounts) do
			stats.uniqueMorphemes = stats.uniqueMorphemes + 1
		end
	end
	
	return stats
end

-- [JOURNAL-007] Check achievements
function WordJournalService:CheckAchievements(player: Player)
	local DataService = Knit.GetService("DataService")
	if not DataService then return end
	
	local stats = self:GetJournalStats(player)
	
	-- Word collector achievements
	if stats.totalWords >= 10 then
		DataService:UnlockAchievement(player, "journal_10")
	end
	if stats.totalWords >= 50 then
		DataService:UnlockAchievement(player, "journal_50")
	end
	if stats.totalWords >= 100 then
		DataService:UnlockAchievement(player, "journal_100")
	end
end

-- [JOURNAL-008] Load journal from save
function WordJournalService:LoadJournal(player: Player, data: { JournalEntry })
	playerJournal[player.UserId] = {}
	
	if data then
		for _, entry in ipairs(data) do
			playerJournal[player.UserId][entry.Word] = entry
			discoveredWords[entry.Word] = true
		end
	end
end

-- [JOURNAL-009] Save journal
function WordJournalService:GetSaveData(player: Player): { JournalEntry }
	if not playerJournal[player.UserId] then
		return {}
	end
	
	local entries = {}
	for _, entry in pairs(playerJournal[player.UserId]) do
		table.insert(entries, entry)
	end
	return entries
end

function WordJournalService:KnitStart()
	print("[WordJournalService] Started.")
end

return WordJournalService
