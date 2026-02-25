--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local NPCDataList = require(ReplicatedStorage.Shared.NPCData)

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
function NPCService.Client:Interact(player: Player, npcId: string)
    return self.Server:HandleInteraction(player, npcId)
end

-- Server method for interaction
function NPCService:HandleInteraction(player: Player, npcId: string)
    print(player.Name .. " interacting with " .. npcId)
    local npcData = NPCDataList[npcId]

    local AIService = Knit.GetService("AIService")
    local DataService = Knit.GetService("DataService")

    if npcData then
        -- Build Context
        local profile = DataService:GetProfile(player)
        local activeQuestName = "None"
        if profile and profile.Quests then
            for _, q in pairs(profile.Quests) do
                if q.IsActive then activeQuestName = q.Name break end
            end
        end
        
        local context = string.format(
            "Player: %s (Lvl %d %s). Quest: %s. NPC: %s (%s, %s district).",
            player.Name,
            profile and profile.Level or 1,
            profile and profile.Stats.Archetype or "Novice",
            activeQuestName,
            npcData.Name,
            npcData.Archetype,
            npcData.District
        )
        
        -- AI Call
        local prompt = "Greet the player. If they have no quest, hint at adventure. If they have a quest, offer encouragement related to your archetype."
        local responseText = AIService:Chat(context, prompt)

        return {
            Id = npcData.Id .. "_dynamic",
            Name = npcData.Name,
            Text = responseText, 
            Options = {
                { Text = "Tell me more.", Next = "detail" },
                { Text = "Goodbye." }
            }
        }
    else
        return {
            Id = "error",
            Text = "The spirits are silent...",
            Options = { { Text = "Leave" } }
        }
    end
end

-- Public API

function NPCService:SpawnNPC(npcId: string, location: CFrame, parent: Instance)
	local data = NPCDataList[npcId]
	if not data then
		warn("NPCService: Could not find data for NPCId: " .. tostring(npcId))
		return
	end

	-- Create Model (R15 Style Block Rig)
	local npcModel = Instance.new("Model")
	npcModel.Name = data.Name

	-- Helper for parts
	local function createLimb(name: string, size: Vector3, color: Color3, posOffset: Vector3)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Color = color
		part.Material = Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = location * CFrame.new(posOffset)
		part.Parent = npcModel
		return part
	end

	-- 1. Torso (Center)
	-- Rig dims approx: 2x2x1
	local torso = createLimb("Torso", Vector3.new(2, 2, 1), data.Color, Vector3.new(0, 3, 0))
	
	-- 2. Head (Top)
	local head = createLimb("Head", Vector3.new(1.2, 1.2, 1.2), Color3.new(1, 0.8, 0.6), Vector3.new(0, 4.6, 0)) -- Skin tone
	-- Face decal
	local face = Instance.new("Decal")
	face.Texture = "rbxasset://textures/face.png"
	face.Parent = head

	-- 3. Arms
	local lArm = createLimb("LeftArm", Vector3.new(1, 2, 1), data.Color, Vector3.new(-1.5, 3, 0))
	local rArm = createLimb("RightArm", Vector3.new(1, 2, 1), data.Color, Vector3.new(1.5, 3, 0))

	-- 4. Legs
	local lLeg = createLimb("LeftLeg", Vector3.new(1, 2, 1), Color3.new(0.2, 0.2, 0.2), Vector3.new(-0.5, 1, 0)) -- Dark pants
	local rLeg = createLimb("RightLeg", Vector3.new(1, 2, 1), Color3.new(0.2, 0.2, 0.2), Vector3.new(0.5, 1, 0))

	-- 5. Humanoid Root Part (Invisible hitbox)
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = Vector3.new(2, 5, 1)
	hrp.Transparency = 1
	hrp.Anchored = true
	hrp.CFrame = location * CFrame.new(0, 2.5, 0)
	hrp.Parent = npcModel
	npcModel.PrimaryPart = hrp

	-- 6. Humanoid
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
	humanoid.DisplayName = data.Name .. " <" .. data.Archetype .. ">"
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = npcModel
	
	-- 7. Accessories (Procedural)
	if data.Archetype == "Ruler" or data.Archetype == "Sage" then
		-- Crown/Hat
		local hat = Instance.new("Part")
		hat.Name = "Crown"
		hat.Size = Vector3.new(1.4, 0.4, 1.4)
		hat.Color = Color3.fromHex("#FCD34D") -- Gold
		hat.Material = Enum.Material.Neon
		hat.Anchored = true
		hat.CFrame = head.CFrame * CFrame.new(0, 0.8, 0)
		hat.Parent = npcModel
	elseif data.Archetype == "Hero" or data.Archetype == "Rebel" then
		-- Sword on back
		local sword = Instance.new("Part")
		sword.Name = "Sword"
		sword.Size = Vector3.new(0.5, 4, 0.2)
		sword.Color = Color3.fromHex("#94A3B8") -- Steel
		sword.Anchored = true
		sword.CFrame = torso.CFrame * CFrame.new(0, 0, 0.6) * CFrame.Angles(0, 0, math.rad(45))
		sword.Parent = npcModel
	elseif data.Archetype == "Magician" or data.Archetype == "Innocent" then
		-- Floating Orb
		local orb = Instance.new("Part")
		orb.Name = "MagicOrb"
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(1, 1, 1)
		orb.Color = Color3.fromHex("#A855F7") -- Purple
		orb.Material = Enum.Material.Neon
		orb.Anchored = true
		orb.CFrame = rArm.CFrame * CFrame.new(0, -1.5, 1)
		orb.Parent = npcModel
	end

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
	
	print("[NPCService] Spawned " .. data.Name .. " at " .. data.District)
end

return NPCService
