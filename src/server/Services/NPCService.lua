--!strict
--==============================================================
-- MMMM Context: Manages the archetypal inhabitants of Syllable Springs. NPCs serve as conduits for specific etymological teachings.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local NPCDataList = require(ReplicatedStorage.Shared.NPCData)
local LoreDB = require(ReplicatedStorage.Shared.Data.Master_Lore.LoreDB)

local NPCService = Knit.CreateService {
    Name = "NPCService",
    Client = {
        TriggerInteraction = Knit.CreateSignal(),
    },
}

-- State
local SpawnedNPCs = {}

-- KnitStart
function NPCService:KnitStart()
    print("[NPCService] Started.")
end

-- Client method for interaction
function NPCService.Client:Interact(player: Player, npcId: string, optionId: string?)
    return self.Server:HandleInteraction(player, npcId, optionId)
end

-- Server method for interaction
function NPCService:HandleInteraction(player: Player, npcId: string, optionId: string?)
    print(player.Name .. " interacting with " .. npcId .. " option: " .. tostring(optionId))
    local npcData = NPCDataList[npcId]

    local AIService = Knit.GetService("AIService")
    local DataService = Knit.GetService("DataService")
	local MadLibService = Knit.GetService("MadLibService")

    if not npcData then
        return {
            Id = "error",
            Text = "The spirits are silent...",
            Options = { { Text = "Leave" } }
        }
    end

	local profile = DataService:GetProfile(player)
	if not profile then return { Text = "Error loading data" } end
	
	-- Determine player's progression with this NPC
	local tier = profile.NPCProgress[npcId] or 1
	
	-- Process Options
	if optionId == "accept_quest" then
		-- Automatically assign the Mad-Lib quest
		local quest = MadLibService:GenerateNPCQuest(player, npcId, tier)
		if quest then
			-- Increment their progress
			profile.NPCProgress[npcId] = tier + 1
			DataService.Client.DataUpdated:Fire(player, "NPCProgress", profile.NPCProgress)
			
			return {
				Id = npcData.Id .. "_quest_accepted",
				Name = npcData.Name,
				Text = "Excellent. The task is now yours to complete. Focus your intent: " .. quest.CompleteNarrative,
				Options = {
					{ Text = "I will return when it's done." }
				}
			}
		else
			return {
				Id = npcData.Id .. "_quest_error",
				Name = npcData.Name,
				Text = "I have no more tasks for you at this time.",
				Options = { { Text = "Goodbye." } }
			}
		end
	end

    -- Build Context for standard AI Dialogue
    local activeQuestName = "None"
    if profile.Quests then
        for _, q in pairs(profile.Quests) do
            if q.IsActive then activeQuestName = q.Name break end
        end
    end
    
    local context = string.format(
        "Player: %s (Lvl %d %s). Quest: %s. NPC: %s (%s, %s district).",
        player.Name,
        profile.Level or 1,
        profile.Stats and profile.Stats.Archetype or "Novice",
        activeQuestName,
        npcData.Name,
        npcData.Archetype,
        npcData.District
    )
    
    -- AI Call
    local GameLoopService = Knit.GetService("GameLoopService")
    local currentPhase = GameLoopService:GetGameState().Phase
    local phaseNames = {
        Collection = "The World Breathes in Letters",
        Construction = "Crystallizing Meaning",
        Quest = "Manifesting the Hero's Journey",
        Nuisance = "The Letters Are Restless",
        Rewards = "Resonance of Achievement",
    }
    local phaseContext = phaseNames[currentPhase] or currentPhase

	-- [LORE-001] Phase-aware base dialogue from LoreDB
	local lorePhaseMap = {
		Collection = "Dawn",
		Construction = "Day",
		Quest = "Day",
		Nuisance = "Dusk",
		Rewards = "Night",
	}
	local lorePhase = lorePhaseMap[currentPhase] or "Day"
	local npcLore = LoreDB.NPCs[npcId]
	local baseDialogue = "Hello!"
	
	if npcLore and npcLore.Dialogue and npcLore.Dialogue[lorePhase] then
		local dialogues = npcLore.Dialogue[lorePhase]
		baseDialogue = dialogues[math.random(1, #dialogues)]
	end

	local teachingContext = ""
	if npcLore and npcLore.Teaches then
		teachingContext = " You are currently teaching these morphemes: " .. table.concat(npcLore.Teaches, ", ") .. "."
	end

    local prompt = string.format(
        "Your base personality/current thought is: '%s'.%s The world is currently in the '%s' phase (Technical Context: %s). Greet the player using your archetype (%s) and this context. Keep it very brief (1-2 sentences)!",
        baseDialogue,
        teachingContext,
        phaseContext,
        currentPhase,
        npcData.Archetype
    )
    
	local chatOk, responseText = pcall(function()
		return AIService:Chat(npcId, prompt)
	end)
	if not chatOk or not responseText or responseText == "" then
		responseText = npcData.DialogueRoot or "Hello, traveler."
	end
	
	-- Inject a quest offer option if they aren't currently doing a MadLib quest
	local existingQuest = MadLibService:GetPlayerQuest(player)
	local options = {
		{ Text = "Tell me more.", Next = "detail" },
		{ Text = "Goodbye." }
	}
	
	if not existingQuest then
		table.insert(options, 1, { Text = "Do you have any tasks for me?", Next = "accept_quest" })
	end

    return {
        Id = npcData.Id .. "_dynamic",
        Name = npcData.Name,
        Text = responseText, 
        Options = options
    }
end

-- Private: Make NPC wander near their spawn point
local function startWandering(npcModel: Model, homePosition: Vector3)
	local hrp = npcModel.PrimaryPart
	if not hrp then return end
	
	local humanoid = npcModel:FindFirstChild("Humanoid")
	if not humanoid then return end
	
	local wanderRadius = 15 -- How far they can wander from home
	local idleTimeMin = 3 -- Seconds to stand still
	local idleTimeMax = 8
	local walkTimeMin = 2
	local walkTimeMax = 5
	
	while npcModel and npcModel.Parent do
		-- Wait random idle time
		task.wait(idleTimeMin + math.random() * (idleTimeMax - idleTimeMin))
		
		if not npcModel or not npcModel.Parent then break end
		
		-- Pick random position near home
		local angle = math.random() * math.pi * 2
		local distance = math.random() * wanderRadius
		local targetPos = homePosition + Vector3.new(
			math.cos(angle) * distance,
			0,
			math.sin(angle) * distance
		)
		
		-- Make sure Y stays the same (stay on ground)
		targetPos = Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z)
		
		-- Walk to target
		humanoid:MoveTo(targetPos)
		
		-- Wait while walking or until timeout
		local walkTime = walkTimeMin + math.random() * (walkTimeMax - walkTimeMin)
		local elapsed = 0
		while elapsed < walkTime do
			task.wait(0.5)
			elapsed = elapsed + 0.5
			if not npcModel or not npcModel.Parent then return end
			if (hrp.Position - targetPos).Magnitude < 3 then break end -- Reached target
		end
		
		-- Stop moving
		humanoid:MoveTo(homePosition) -- This stops the humanoid
	end
end

-- Private: Animate NPC idle state
local function animateNPC(npcModel: Model)
	local hrp = npcModel.PrimaryPart
	if not hrp then return end
	
	local startPos = hrp.Position
	local bobHeight = 1.5
	local bobTime = 2 + math.random() -- Randomize timing so they don't sync
	
	local info = TweenInfo.new(bobTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	local tween = TweenService:Create(hrp, info, { Position = startPos + Vector3.new(0, bobHeight, 0) })
	
	tween:Play()
	
	-- Start wandering behavior after a brief delay
	task.delay(3 + math.random() * 2, function()
		startWandering(npcModel, startPos)
	end)
end

-- Public API

function NPCService:SpawnNPC(npcId: string, location: CFrame, parent: Instance)
	local data = NPCDataList[npcId]
	if not data then
		warn("NPCService: Could not find data for NPCId: " .. tostring(npcId))
		return
	end

	-- Create Model
	local npcModel = Instance.new("Model")
	npcModel.Name = data.Name

	-- Per-NPC visual build (unique silhouette per character)
	local NPCVisualBuilders = require(ReplicatedStorage.Shared.NPCVisualBuilders)
	local hrp = NPCVisualBuilders.Build(npcId, location, npcModel, data)

	if not hrp then
		warn("[NPCService] NPCVisualBuilders.Build returned nil HRP for " .. npcId .. " — creating fallback")
		hrp = Instance.new("Part")
		hrp.Name = "HumanoidRootPart"
		hrp.Size = Vector3.new(2, 2, 1)
		hrp.Transparency = 1
		hrp.Anchored = true
		hrp.CFrame = location
		hrp.Parent = npcModel
		npcModel.PrimaryPart = hrp
	end

	-- Humanoid (display name + archetype)
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = data.Name .. " <" .. data.Archetype .. ">"
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = npcModel

	-- Interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = data.Archetype
	prompt.ActionText = "Speak"
	prompt.RequiresLineOfSight = false
	prompt.HoldDuration = 0.5
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = hrp

    -- Interaction Handler - use Knit signal
    local service = self
    prompt.Triggered:Connect(function(player)
        print("NPC Triggered: " .. data.Id)
        -- Fire to client via Knit signal
        service.Client.TriggerInteraction:Fire(player, npcId)
    end)

	-- Metadata
	npcModel:SetAttribute("NPCId", npcId)
	npcModel:SetAttribute("Archetype", data.Archetype)
	npcModel:SetAttribute("District", data.District)

	npcModel.Parent = parent
	SpawnedNPCs[npcId] = npcModel
	
	-- Start idle animation
	animateNPC(npcModel)
	
	print("[NPCService] Spawned " .. data.Name .. " (" .. data.Archetype .. ") at " .. data.District)
end

return NPCService
