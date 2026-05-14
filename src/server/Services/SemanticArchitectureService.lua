--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Allows players to feed active Slimes to buildings to permanently alter the town architecture
local SemanticArchitectureService = Knit.CreateService {
	Name = "SemanticArchitectureService",
	Client = {
		BuildingEvolved = Knit.CreateSignal(),
	},
}

local BuildingStates = {}

function SemanticArchitectureService:KnitStart()
	print("[SemanticArchitectureService] Living architecture ready to consume semantics.")
end

-- Invoked by the Mycelial Node ProximityPrompt
function SemanticArchitectureService:PromptFeedBuilding(player: Player, buildingName: string)
	local PetService = Knit.GetService("PetService")
	if not PetService then return end
	
	-- We feed the building the player's active companion!
	local activeInstances = PetService:GetActivePets()
	local companionId = activeInstances[player]
	
	if not companionId then
		print("[SemanticArchitectureService] " .. player.Name .. " tried to feed " .. buildingName .. " but had no companion out!")
		-- Optionally notify client
		return
	end
	
	self:FeedBuilding(player, buildingName, companionId)
end

-- Feeds a Slime to a building's Mycelial Node
function SemanticArchitectureService:FeedBuilding(player: Player, buildingName: string, instanceId: string)
	local SlimeFactory = Knit.GetService("SlimeFactory")
	if not SlimeFactory then return end
	
	local playerSlimes = SlimeFactory.Client:GetPlayerSlimes(player)
	local slime = playerSlimes and playerSlimes[instanceId]
	if not slime then return end
	
	print("[SemanticArchitectureService] " .. player.Name .. " fed " .. slime.WordId .. " to " .. buildingName)
	
	-- Initialize building state if n/a
	if not BuildingStates[buildingName] then
		BuildingStates[buildingName] = { ScaleY = 1, Element = "Neutral", RoleInfluence = {} }
	end
	
	local state = BuildingStates[buildingName]
	
	-- Evolve the building based on the Slime's traits
	state.Element = slime.Element
	if slime.Role == "Tank" then
		state.ScaleY += 0.5 -- Building grows taller!
	elseif slime.Role == "Striker" then
		-- Building produces items faster (e.g. bakery)
	end
	
	-- Find physical representation in Workspace to scale it dynamically
	local buildingModel = Workspace:FindFirstChild(buildingName, true)
	if buildingModel and buildingModel:IsA("Model") and buildingModel.PrimaryPart then
		-- Scale the PrimaryPart or entire model as a visual indicator
		local currentSize = buildingModel.PrimaryPart.Size
		buildingModel.PrimaryPart.Size = Vector3.new(currentSize.X, currentSize.Y + 2, currentSize.Z)
	end
	
	-- We destroy the slime as a sacrifice
	-- Note: in a full implementation, SlimeFactory would expose a DestroySlime function
	
	self.Client.BuildingEvolved:FireAll(buildingName, state)
	
	-- Let Zeitgeist know about this sacrifice
	local ZeitgeistService = Knit.GetService("ZeitgeistService")
	if ZeitgeistService then
		ZeitgeistService:RecordSemanticEvent("Sacrifice", slime.Element, slime.WordId)
	end
end

return SemanticArchitectureService
