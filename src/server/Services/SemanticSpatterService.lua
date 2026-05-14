--!strict
--==============================================================
-- MMMM Context: Manages localized visual effects based on word usage. A physical manifestation of linguistic meaning splashing into the world.
--==============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LexicalEffectsDB = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("LexicalEffectsDB"))

local SemanticSpatterService = Knit.CreateService {
	Name = "SemanticSpatterService",
	Client = {
		OozeSpilled = Knit.CreateSignal(), -- Fired when an ooze drops (position, element, root, role)
	},
}

-- Config
local SPATTER_INTERVAL = 1.5 -- seconds between ooze drops
local OOZE_LIFETIME = 15 -- seconds before ooze evaporates

-- State
local activeOozes = {}
local trackedSlimes = {} -- [instanceId] = { model, lastPos, element, root, role }

function SemanticSpatterService:KnitStart()
	print("[SemanticSpatterService] Started. The world is leaking meaning.")
	
	-- Regularly check tracked slimes to drop ooze
	RunService.Heartbeat:Connect(function(dt)
		for id, data in pairs(trackedSlimes) do
			if not data.model or not data.model.Parent then
				trackedSlimes[id] = nil
				continue
			end
			
			local currentPos = data.model:GetPivot().Position
			if data.lastPos then
				local dist = (currentPos - data.lastPos).Magnitude
				if dist > 3 and (os.clock() - data.lastDropTime > SPATTER_INTERVAL) then
					data.lastDropTime = os.clock()
					data.lastPos = currentPos
					self:SpillOoze(currentPos, data.element, data.root, data.role)
				end
			else
				data.lastPos = currentPos
				data.lastDropTime = os.clock()
			end
		end
	end)
end

-- Call this when a Slime is summoned into the physical world
function SemanticSpatterService:TrackSlime(instanceId: string, model: Model, element: string, root: string, role: string)
	trackedSlimes[instanceId] = {
		model = model,
		element = element,
		root = root,
		role = role,
		lastPos = nil,
		lastDropTime = 0
	}
	print("[SemanticSpatterService] Tracking Slime for spatter: " .. instanceId)
end

function SemanticSpatterService:UntrackSlime(instanceId: string)
	trackedSlimes[instanceId] = nil
end

function SemanticSpatterService:SpillOoze(position: Vector3, element: string, root: string, role: string)
	-- Cast ray down to find floor
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	-- We don't want to cast against players or slimes
	local filter = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p.Character then table.insert(filter, p.Character) end
	end
	params.FilterDescendantsInstances = filter
	
	local result = workspace:Raycast(position + Vector3.new(0, 2, 0), Vector3.new(0, -10, 0), params)
	
	if result then
		local oozeStats = LexicalEffectsDB.Elements[element] or LexicalEffectsDB.Elements.Normal
		local roleStats = LexicalEffectsDB.Roles[role] or LexicalEffectsDB.Roles.Civilian
		
		-- Create the physical puddle server-side so it has collision
		local part = Instance.new("Part")
		part.Size = Vector3.new(4 * roleStats.SizeMultiplier, 0.2, 4 * roleStats.SizeMultiplier)
		part.Position = result.Position
		part.Anchored = true
		part.CanCollide = false -- Don't block movement, just touch
		part.Material = oozeStats.Material
		part.Color = oozeStats.Color
		part.Transparency = oozeStats.Transparency
		part.Shape = Enum.PartType.Cylinder
		part.Orientation = Vector3.new(0, 0, 90) -- Face up
		part.Name = "SemanticOoze_" .. element
		
		-- Add attributes for the client to read when touched
		part:SetAttribute("LexicalElement", element)
		part:SetAttribute("LexicalRoot", root)
		part:SetAttribute("LexicalRole", role)
		part:SetAttribute("IsSemanticOoze", true)
		
		-- Parent to a folder
		local folder = workspace:FindFirstChild("SemanticOozeFolder")
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = "SemanticOozeFolder"
			folder.Parent = workspace
		end
		
		part.Parent = folder
		
		-- Cleanup timer
		task.delay(OOZE_LIFETIME, function()
			if part and part.Parent then
				-- Fading effect could be handled by a client controller, but we just destroy it here
				part:Destroy()
			end
		end)
		
		-- Notify clients for any extra visual effects
		self.Client.OozeSpilled:FireAll(result.Position, element, root, role)
	end
end

return SemanticSpatterService
