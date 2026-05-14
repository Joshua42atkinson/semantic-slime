--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- The FeralTypoService spawns glitched, chaotic slimes when players attempt to spell invalid words.
local FeralTypoService = Knit.CreateService {
	Name = "FeralTypoService",
	Client = {
		FeralTypoSpawned = Knit.CreateSignal(),
	},
}

function FeralTypoService:KnitStart()
	print("[FeralTypoService] The Underworld is listening for typos...")
end

-- Hooked from SlimeFactory when a word fails validation
function FeralTypoService:SpawnTypo(player: Player, failedWord: string)
	if not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	print("[FeralTypoService] Spawning Feral Typo for failed word: " .. failedWord)
	
	-- Tell Mycelium to grow
	local SlimeMyceliumService = Knit.GetService("SlimeMyceliumService")
	if SlimeMyceliumService then
		SlimeMyceliumService:AddDecay(player, failedWord, hrp.Position)
	end
	
	-- In a full implementation, we would clone a Glitch Model here.
	-- For this creative expansion, we notify the client to render the jump scare or physical typo.
	self.Client.FeralTypoSpawned:Fire(player, failedWord, hrp.Position)
	
	-- We also spawn a physical part representation of the typo for fun
	local typoPart = Instance.new("Part")
	typoPart.Size = Vector3.new(2, 2, 2)
	typoPart.Position = hrp.Position + Vector3.new(math.random(-5, 5), 5, math.random(-5, 5))
	typoPart.Color = Color3.fromHSV(math.random(), 1, 1)
	typoPart.Material = Enum.Material.Neon
	typoPart.Anchored = false
	typoPart.Name = "FeralTypo_" .. failedWord
	typoPart.Parent = Workspace
	
	-- Add a BillboardGui to show the typo
	local bg = Instance.new("BillboardGui")
	bg.Size = UDim2.new(0, 100, 0, 50)
	bg.StudsOffset = Vector3.new(0, 2, 0)
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = "ERR: " .. failedWord
	textLabel.TextColor3 = Color3.new(1, 0, 0)
	textLabel.TextScaled = true
	textLabel.Parent = bg
	bg.Parent = typoPart
	
	game.Debris:AddItem(typoPart, 15) -- Fades into the mycelium after 15 seconds
end

return FeralTypoService
