--!strict
-- LetterNuisanceService.lua
-- "Annoying Letters" — clingy letter entities that follow players and try to "join" them.
-- Letters are incomplete "word fragments" seeking spelling. Players shake them off
-- by constructing words at NPC stations, which turns letters into SLIMES.
--
-- The pipeline: Nuisance Letter → clings to player → feeds 26-slot alphabet 
--   → player constructs word → SlimeFactory creates Slime → Slime fills Mad Lib
--
-- Core mechanic: Aversion (annoyance) not Attack. Cleverness not Combat.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local LetterNuisanceService = Knit.CreateService {
	Name = "LetterNuisanceService",
	Client = {
		LetterAttached = Knit.CreateSignal(),    -- (letter, dialogue, annoyance, emoji, label)
		LetterShaken = Knit.CreateSignal(),       -- (letter, annoyance, emoji, label)
		AnnoyanceChanged = Knit.CreateSignal(),   -- (annoyance, emoji, label)
		NuisancePhaseStarted = Knit.CreateSignal(),
		NuisancePhaseEnded = Knit.CreateSignal(),
	},
}

-- ============================================================
-- CONFIG
-- ============================================================
local NUISANCE_SPAWN_COUNT = 20
local MAX_ATTACHED = 8                -- max orbiting letters per player
local LETTER_CHASE_SPEED = 12         -- studs/sec
local LETTER_ATTACH_DISTANCE = 6      -- studs
local LETTER_DESPAWN_RADIUS = 1200    -- beyond this, letters vanish

-- Annoyance thresholds (each attached letter = 1 point)
local ANNOYANCE_TIERS = {
	{ threshold = 0, emoji = "😊", label = "Peaceful" },
	{ threshold = 3, emoji = "😤", label = "Getting Annoyed" },
	{ threshold = 5, emoji = "😠", label = "Really Annoyed" },
	{ threshold = 7, emoji = "🤯", label = "Overwhelmed!" },
}

-- Cheeky dialogue — letters cry out as they chase
local DIALOGUE = {
	"I just want to be part of a word!",
	"PLEASE spell me into something!",
	"I'm so lonely without my consonants!",
	"Nobody wants a lone letter! 😢",
	"If you'd just USE me in a sentence...",
	"I could be the start of something BEAUTIFUL!",
	"Just one Mad Lib, PLEASE!",
	"I'm not annoying, I'm ASPIRATIONAL!",
	"Don't run! I'm very spell-able!",
	"We could make a GREAT word together!",
	"I promise I'm not a silent letter!",
	"You look like you need more vowels!",
	"Adopt me! I'm housebroken!",
	"I'll be quiet if you spell me!",
	"All I need is context!",
	"I'm ONE letter away from greatness!",
}

-- Weighted table: common letters appear more, rare letters are extra clingy
local LETTER_POOL = {
	-- Common  (clinginess 1 = slow, polite)
	{ letter = "E", weight = 15, cling = 1 },
	{ letter = "A", weight = 12, cling = 1 },
	{ letter = "I", weight = 10, cling = 1 },
	{ letter = "O", weight = 10, cling = 1 },
	{ letter = "N", weight = 8,  cling = 1 },
	{ letter = "T", weight = 8,  cling = 1 },
	{ letter = "S", weight = 7,  cling = 1 },
	-- Uncommon (clinginess 2 = faster, chatty)
	{ letter = "R", weight = 5,  cling = 2 },
	{ letter = "L", weight = 5,  cling = 2 },
	{ letter = "D", weight = 4,  cling = 2 },
	{ letter = "H", weight = 3,  cling = 2 },
	{ letter = "U", weight = 4,  cling = 2 },
	{ letter = "C", weight = 3,  cling = 2 },
	{ letter = "M", weight = 3,  cling = 2 },
	-- Rare (clinginess 3 = very fast, desperate)
	{ letter = "Q", weight = 1,  cling = 3 },
	{ letter = "Z", weight = 1,  cling = 3 },
	{ letter = "X", weight = 1,  cling = 3 },
	{ letter = "J", weight = 1,  cling = 3 },
	{ letter = "K", weight = 2,  cling = 3 },
}

-- ============================================================
-- TYPES
-- ============================================================
export type NuisanceLetter = {
	Id: string,
	Letter: string,
	Cling: number,         -- 1-3
	Dialogue: string,
	Model: Model?,
	Target: Player?,
	Attached: boolean,
	Pos: Vector3,
}

-- ============================================================
-- STATE
-- ============================================================
local active: { [string]: NuisanceLetter } = {}
local playerLetters: { [Player]: { NuisanceLetter } } = {}
local safeZones: { { center: Vector3, radius: number } } = {}
local nuisanceActive = false

-- pre-calculate total weight
local totalWeight = 0
for _, e in ipairs(LETTER_POOL) do totalWeight += e.weight end

-- ============================================================
-- HELPERS
-- ============================================================
local function pickLetter(): (string, number)
	local roll = math.random() * totalWeight
	local running = 0
	for _, e in ipairs(LETTER_POOL) do
		running += e.weight
		if roll <= running then return e.letter, e.cling end
	end
	return "E", 1
end

local function pickDialogue(): string
	return DIALOGUE[math.random(#DIALOGUE)]
end

local function isInSafe(pos: Vector3): boolean
	for _, z in ipairs(safeZones) do
		if (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(z.center.X, 0, z.center.Z)).Magnitude < z.radius then
			return true
		end
	end
	return false
end

local function annoyanceOf(player: Player): number
	local list = playerLetters[player]
	return list and #list or 0
end

local function tierOf(level: number): { emoji: string, label: string }
	local result = ANNOYANCE_TIERS[1]
	for _, t in ipairs(ANNOYANCE_TIERS) do
		if level >= t.threshold then result = t end
	end
	return result
end

-- ============================================================
-- VISUALS: build a glowing floating letter model
-- ============================================================
local function buildModel(letter: NuisanceLetter): Model
	local model = Instance.new("Model")
	model.Name = "Nuisance_" .. letter.Id

	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = Vector3.new(2, 2.5, 0.5)
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Position = letter.Pos

	-- Color by clinginess
	local colors = {
		[1] = Color3.fromHex("#60A5FA"), -- calm blue
		[2] = Color3.fromHex("#FBBF24"), -- warning yellow
		[3] = Color3.fromHex("#F87171"), -- annoying red
	}
	part.Color = colors[letter.Cling] or colors[1]
	part.Parent = model

	-- Billboard: big letter + cheeky dialogue
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromScale(4, 3)
	bb.AlwaysOnTop = true
	bb.Parent = part

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 0.65)
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.TextStrokeTransparency = 0
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Text = letter.Letter
	lbl.Parent = bb

	local dlg = Instance.new("TextLabel")
	dlg.Size = UDim2.fromScale(1, 0.35)
	dlg.Position = UDim2.fromScale(0, 0.65)
	dlg.BackgroundTransparency = 1
	dlg.TextColor3 = Color3.fromHex("#FEF3C7")
	dlg.TextStrokeTransparency = 0.3
	dlg.Font = Enum.Font.GothamMedium
	dlg.TextScaled = true
	dlg.Text = letter.Dialogue
	dlg.Parent = bb

	-- Glow
	local light = Instance.new("PointLight")
	light.Color = part.Color
	light.Brightness = letter.Cling + 1
	light.Range = 8
	light.Parent = part

	-- Sparkles
	local att = Instance.new("Attachment"); att.Parent = part
	local pe = Instance.new("ParticleEmitter")
	pe.Rate = 5 * letter.Cling
	pe.Lifetime = NumberRange.new(0.3, 0.8)
	pe.Speed = NumberRange.new(1, 3)
	pe.Size = NumberSequence.new(0.2, 0)
	pe.Color = ColorSequence.new(part.Color)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Parent = att

	model.Parent = Workspace
	return model
end

-- ============================================================
-- CHASE BEHAVIOR
-- ============================================================
local function chase(letter: NuisanceLetter)
	task.spawn(function()
		while letter.Model and letter.Model.Parent and not letter.Attached do
			local best: Player?, bestDist = nil, math.huge
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character and p.Character.PrimaryPart then
					local pl = playerLetters[p]
					if not pl or #pl < MAX_ATTACHED then
						local d = (p.Character.PrimaryPart.Position - letter.Pos).Magnitude
						if d < bestDist and d < 200 then
							bestDist = d
							best = p
						end
					end
				end
			end

			if best and best.Character and best.Character.PrimaryPart then
				letter.Target = best
				local tp = best.Character.PrimaryPart.Position
				local body = letter.Model:FindFirstChild("Body")
				if body then
					local dir = (tp - body.Position)
					if dir.Magnitude > 0.1 then
						dir = dir.Unit
					end
					local speed = LETTER_CHASE_SPEED * (0.5 + letter.Cling * 0.3)
					local np = body.Position + dir * speed * 0.1
					local bob = math.sin(tick() * 3 + letter.Cling) * 1.5
					np = Vector3.new(np.X, tp.Y + 3 + bob, np.Z)
					body.Position = np
					letter.Pos = np

					local d2 = (Vector3.new(np.X, 0, np.Z) - Vector3.new(tp.X, 0, tp.Z)).Magnitude
					if d2 < LETTER_ATTACH_DISTANCE then
						LetterNuisanceService:AttachToPlayer(best, letter)
					end
				end
			end
			task.wait(0.1)
		end
	end)
end

-- ============================================================
-- PUBLIC API
-- ============================================================
function LetterNuisanceService:KnitStart()
	print("[LetterNuisanceService] 📝 Started. The letters are restless...")

	-- Hub is always a safe zone
	table.insert(safeZones, { center = Vector3.new(0, 0, 0), radius = 120 })

	Players.PlayerAdded:Connect(function(p) playerLetters[p] = {} end)
	Players.PlayerRemoving:Connect(function(p) playerLetters[p] = nil end)
	for _, p in ipairs(Players:GetPlayers()) do playerLetters[p] = {} end
end

-- Called by TownGenerator to mark paths & buildings as letter-free
function LetterNuisanceService:RegisterSafeZone(center: Vector3, radius: number)
	table.insert(safeZones, { center = center, radius = radius })
end

-- Called by GameLoopService to start the Nuisance phase
function LetterNuisanceService:SpawnNuisanceLetters(count: number?)
	local n = count or NUISANCE_SPAWN_COUNT
	nuisanceActive = true
	print("[LetterNuisanceService] 📝 Spawning " .. n .. " clingy letters!")
	self.Client.NuisancePhaseStarted:FireAll()

	for i = 1, n do
		local ch, cling = pickLetter()
		local pos: Vector3
		local tries = 0
		repeat
			local angle = math.random() * math.pi * 2
			local dist = 150 + math.random() * 600
			pos = Vector3.new(math.cos(angle) * dist, 5 + math.random(0, 15), math.sin(angle) * dist)
			tries += 1
		until not isInSafe(pos) or tries > 10

		local l: NuisanceLetter = {
			Id = HttpService:GenerateGUID(false),
			Letter = ch,
			Cling = cling,
			Dialogue = pickDialogue(),
			Model = nil,
			Target = nil,
			Attached = false,
			Pos = pos,
		}
		l.Model = buildModel(l)
		active[l.Id] = l
		chase(l)
		if i % 5 == 0 then task.wait(0.5) end
	end
	print("[LetterNuisanceService] All " .. n .. " letters spawned and hunting!")
end

-- Attach a letter to a player: adds to orbit AND puts it into CrystalService's 26-slot inventory
function LetterNuisanceService:AttachToPlayer(player: Player, letter: NuisanceLetter)
	if letter.Attached then return end
	if not player.Character or not player.Character.PrimaryPart then return end

	local list = playerLetters[player]
	if not list then list = {}; playerLetters[player] = list end
	if #list >= MAX_ATTACHED then return end

	letter.Attached = true
	letter.Target = player
	table.insert(list, letter)

	-- === PIPELINE INTEGRATION ===
	-- Feed the letter into CrystalService's alphabet inventory
	-- This is the key connection: nuisance letters become usable inventory
	task.defer(function()
		local ok, CrystalService = pcall(function() return Knit.GetService("CrystalService") end)
		if ok and CrystalService then
			pcall(function()
				CrystalService:AddLetterToInventory(player, letter.Letter, 1)
			end)
		end
	end)

	-- Orbit animation around player's head
	local body = letter.Model and letter.Model:FindFirstChild("Body")
	if body and player.Character.PrimaryPart then
		local idx = #list
		local baseAngle = (idx / MAX_ATTACHED) * math.pi * 2
		task.spawn(function()
			while letter.Attached and letter.Model and letter.Model.Parent
				and player.Character and player.Character.PrimaryPart do
				local pp = player.Character.PrimaryPart.Position
				local r = 4 + idx * 0.5
				local a = baseAngle + tick() * (1 + letter.Cling * 0.3)
				local b = math.sin(tick() * 2 + idx) * 0.5
				body.Position = pp + Vector3.new(math.cos(a) * r, 3 + b + idx * 0.8, math.sin(a) * r)
				task.wait()
			end
		end)
	end

	local lvl = annoyanceOf(player)
	local info = tierOf(lvl)
	self.Client.LetterAttached:Fire(player, letter.Letter, letter.Dialogue, lvl, info.emoji, info.label)
	self.Client.AnnoyanceChanged:Fire(player, lvl, info.emoji, info.label)
	print("[LetterNuisanceService] '" .. letter.Letter .. "' clung to " .. player.Name .. " — " .. info.emoji .. " " .. info.label)
end

-- Remove one letter from orbit (called when player uses a letter to build a word / completes Mad Lib)
function LetterNuisanceService:ShakeOff(player: Player, specificId: string?): string?
	local list = playerLetters[player]
	if not list or #list == 0 then return nil end

	local target: NuisanceLetter?, idx: number?
	if specificId then
		for i, l in ipairs(list) do
			if l.Id == specificId then target = l; idx = i; break end
		end
	else
		-- remove the most clingy first
		local best = 0
		for i, l in ipairs(list) do
			if l.Cling > best then best = l.Cling; target = l; idx = i end
		end
	end

	if target and idx then
		table.remove(list, idx)
		target.Attached = false

		-- Pop animation
		if target.Model then
			local body = target.Model:FindFirstChild("Body")
			if body then
				TweenService:Create(body, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
					Size = body.Size * 2, Transparency = 1,
				}):Play()
			end
			Debris:AddItem(target.Model, 0.4)
		end
		active[target.Id] = nil

		local lvl = annoyanceOf(player)
		local info = tierOf(lvl)
		self.Client.LetterShaken:Fire(player, target.Letter, lvl, info.emoji, info.label)
		self.Client.AnnoyanceChanged:Fire(player, lvl, info.emoji, info.label)
		return target.Letter
	end
	return nil
end

-- Remove ALL letters (reward for completing a Mad Lib)
function LetterNuisanceService:ShakeOffAll(player: Player): { string }
	local list = playerLetters[player]
	if not list then return {} end
	local letters = {}
	for i = #list, 1, -1 do
		local l = list[i]
		table.insert(letters, l.Letter)
		l.Attached = false
		if l.Model then l.Model:Destroy() end
		active[l.Id] = nil
	end
	playerLetters[player] = {}
	self.Client.AnnoyanceChanged:Fire(player, 0, "😊", "Peaceful")
	print("[LetterNuisanceService] " .. player.Name .. " shook off ALL letters! Sweet relief! 😊")
	return letters
end

function LetterNuisanceService:GetAttached(player: Player): { NuisanceLetter }
	return playerLetters[player] or {}
end

function LetterNuisanceService:GetAnnoyance(player: Player): number
	return annoyanceOf(player)
end

-- Called by GameLoopService when Nuisance phase ends
function LetterNuisanceService:EndNuisancePhase()
	nuisanceActive = false
	self.Client.NuisancePhaseEnded:FireAll()
	print("[LetterNuisanceService] Phase ended. Unattached letters dispersing...")

	for id, l in pairs(active) do
		if not l.Attached then
			if l.Model then
				local body = l.Model:FindFirstChild("Body")
				if body then
					TweenService:Create(body, TweenInfo.new(2, Enum.EasingStyle.Sine), {
						Transparency = 1, Position = body.Position + Vector3.new(0, 20, 0),
					}):Play()
				end
				Debris:AddItem(l.Model, 2.5)
			end
			active[id] = nil
		end
	end
end

function LetterNuisanceService:Cleanup()
	for _, l in pairs(active) do
		if l.Model then l.Model:Destroy() end
	end
	active = {}
	playerLetters = {}
end

return LetterNuisanceService
