--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local BattleUI = {}
BattleUI.__index = BattleUI

-- State
local battleScreen: ScreenGui? = nil
local currentBattle: any = nil
local hpBars: { [string]: Frame } = {}

-- Colors
local COLORS = {
	Background = Color3.fromHex("#0F0E17"),
	CardBg = Color3.fromHex("#1A1A2E"),
	Accent = Color3.fromHex("#FF8906"),
	Text = Color3.fromHex("#FFFFFE"),
	TextDim = Color3.fromHex("#A7A9BE"),
	HPBar = Color3.fromHex("#E53170"),
	HPBarLow = Color3.fromHex("#F9BC2F"),
	HPBarCritical = Color3.fromHex("#E53170"),
	Player = Color3.fromHex("#2CB67D"),
	Enemy = Color3.fromHex("#E53170"),
	LogBg = Color3.fromHex("#16161A"),
}

-- Element colors for participant cards
local ELEMENT_COLORS: { [string]: Color3 } = {
	Fire = Color3.fromHex("#EF4444"),
	Water = Color3.fromHex("#3B82F6"),
	Earth = Color3.fromHex("#22C55E"),
	Air = Color3.fromHex("#F59E0B"),
	Shadow = Color3.fromHex("#8B5CF6"),
	Light = Color3.fromHex("#FCD34D"),
	Normal = Color3.fromHex("#6B7280"),
}

function BattleUI.Create(): ScreenGui
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Check if already exists
	local existing = playerGui:FindFirstChild("BattleUI")
	if existing then
		return existing :: ScreenGui
	end
	
	local screen = Instance.new("ScreenGui")
	screen.Name = "BattleUI"
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.Parent = playerGui
	
	battleScreen = screen
	return screen
end

function BattleUI.ShowBattle(battleData: any)
	if not battleScreen then BattleUI.Create() end
	
	currentBattle = battleData
	
	-- Clear previous battle UI
	for _, child in ipairs(battleScreen:GetChildren()) do
		child:Destroy()
	end
	hpBars = {}
	
	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = COLORS.Background
	overlay.BackgroundTransparency = 0.3
	overlay.BorderSizePixel = 0
	overlay.Parent = battleScreen
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromOffset(400, 50)
	title.Position = UDim2.fromScale(0.5, 0.05)
	title.AnchorPoint = Vector2.new(0.5, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = COLORS.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 32
	title.Text = "⚔️ BATTLE FOR QUEST SLOT ⚔️"
	title.Parent = battleScreen
	
	-- Battle Arena (center)
	local arena = Instance.new("Frame")
	arena.Name = "Arena"
	arena.Size = UDim2.fromOffset(800, 300)
	arena.Position = UDim2.fromScale(0.5, 0.4)
	arena.AnchorPoint = Vector2.new(0.5, 0.5)
	arena.BackgroundColor3 = COLORS.CardBg
	arena.BackgroundTransparency = 0.2
	arena.Parent = battleScreen
	
	local arenaCorner = Instance.new("UICorner")
	arenaCorner.CornerRadius = UDim.new(0, 16)
	arenaCorner.Parent = arena
	
	-- Participant cards container
	local participantsContainer = Instance.new("Frame")
	participantsContainer.Name = "Participants"
	participantsContainer.Size = UDim2.fromScale(0.95, 0.8)
	participantsContainer.Position = UDim2.fromScale(0.5, 0.5)
	participantsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	participantsContainer.BackgroundTransparency = 1
	participantsContainer.Parent = arena
	
	-- Create participant cards
	local participants = battleData.Participants or {}
	local cardWidth = 180
	local spacing = 20
	local totalWidth = (#participants * cardWidth) + ((#participants - 1) * spacing)
	local startX = -totalWidth / 2
	
	for i, participant in ipairs(participants) do
		local cardX = startX + ((i - 1) * (cardWidth + spacing))
		
		local card = BattleUI.CreateParticipantCard(participant)
		card.Position = UDim2.fromOffset(cardX, 0)
		card.Parent = participantsContainer
		
		-- Store HP bar reference
		local hpBar = card:FindFirstChild("HPBar", true)
		if hpBar then
			hpBars[participant.InstanceId] = hpBar
		end
	end
	
	-- Battle Log (bottom)
	local logContainer = Instance.new("Frame")
	logContainer.Name = "BattleLog"
	logContainer.Size = UDim2.fromOffset(600, 150)
	logContainer.Position = UDim2.fromScale(0.5, 0.85)
	logContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	logContainer.BackgroundColor3 = COLORS.LogBg
	logContainer.BackgroundTransparency = 0.3
	logContainer.Parent = battleScreen
	
	local logCorner = Instance.new("UICorner")
	logCorner.CornerRadius = UDim.new(0, 12)
	logCorner.Parent = logContainer
	
	local logTitle = Instance.new("TextLabel")
	logTitle.Size = UDim2.fromScale(1, 0.2)
	logTitle.BackgroundTransparency = 1
	logTitle.TextColor3 = COLORS.TextDim
	logTitle.Font = Enum.Font.GothamBold
	logTitle.TextSize = 14
	logTitle.Text = "Battle Log"
	logTitle.Parent = logContainer
	
	local logScroll = Instance.new("ScrollingFrame")
	logScroll.Name = "LogScroll"
	logScroll.Size = UDim2.fromScale(0.95, 0.75)
	logScroll.Position = UDim2.fromScale(0.5, 0.6)
	logScroll.AnchorPoint = Vector2.new(0.5, 0.5)
	logScroll.BackgroundTransparency = 1
	logScroll.ScrollBarThickness = 4
	logScroll.Parent = logContainer
	
	local logLayout = Instance.new("UIListLayout")
	logLayout.Parent = logScroll
	
	-- Populate initial log
	for _, entry in ipairs(battleData.Log or {}) do
		BattleUI.AddLogEntry(entry)
	end
	
	-- Turn indicator
	local turnLabel = Instance.new("TextLabel")
	turnLabel.Name = "TurnIndicator"
	turnLabel.Size = UDim2.fromOffset(200, 30)
	turnLabel.Position = UDim2.fromScale(0.5, 0.12)
	turnLabel.AnchorPoint = Vector2.new(0.5, 0)
	turnLabel.BackgroundTransparency = 1
	turnLabel.TextColor3 = COLORS.Text
	turnLabel.Font = Enum.Font.Gotham
	turnLabel.TextSize = 18
	turnLabel.Text = "Turn " .. (battleData.Turn or 1)
	turnLabel.Parent = battleScreen
	
	-- Entrance animation
	arena.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(arena, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(800, 300)
	}):Play()
	
	print("[BattleUI] Battle started with " .. #participants .. " participants")
end

function BattleUI.CreateParticipantCard(participant: any): Frame
	local card = Instance.new("Frame")
	card.Name = "Participant_" .. participant.InstanceId
	card.Size = UDim2.fromOffset(180, 200)
	card.BackgroundColor3 = COLORS.CardBg
	card.BackgroundTransparency = 0.1
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = ELEMENT_COLORS[participant.Element] or ELEMENT_COLORS.Normal
	cardStroke.Thickness = 2
	cardStroke.Parent = card
	
	-- Slime name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.fromScale(1, 0.15)
	nameLabel.Position = UDim2.fromScale(0, 0.05)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.Text = participant.SlimeName
	nameLabel.Parent = card
	
	-- Element badge
	local elementBadge = Instance.new("TextLabel")
	elementBadge.Size = UDim2.fromOffset(60, 20)
	elementBadge.Position = UDim2.fromScale(0.5, 0.22)
	elementBadge.AnchorPoint = Vector2.new(0.5, 0)
	elementBadge.BackgroundColor3 = ELEMENT_COLORS[participant.Element] or ELEMENT_COLORS.Normal
	elementBadge.BackgroundTransparency = 0.3
	elementBadge.TextColor3 = COLORS.Text
	elementBadge.Font = Enum.Font.GothamBold
	elementBadge.TextSize = 10
	elementBadge.Text = participant.Element:upper()
	elementBadge.Parent = card
	
	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 4)
	badgeCorner.Parent = elementBadge
	
	-- Role badge
	local roleBadge = Instance.new("TextLabel")
	roleBadge.Size = UDim2.fromOffset(60, 20)
	roleBadge.Position = UDim2.fromScale(0.5, 0.35)
	roleBadge.AnchorPoint = Vector2.new(0.5, 0)
	roleBadge.BackgroundColor3 = Color3.fromHex("#374151")
	roleBadge.TextColor3 = COLORS.TextDim
	roleBadge.Font = Enum.Font.Gotham
	roleBadge.TextSize = 10
	roleBadge.Text = participant.Role
	roleBadge.Parent = card
	
	local roleCorner = Instance.new("UICorner")
	roleCorner.CornerRadius = UDim.new(0, 4)
	roleCorner.Parent = roleBadge
	
	-- HP Bar Background
	local hpBg = Instance.new("Frame")
	hpBg.Name = "HPBarBg"
	hpBg.Size = UDim2.fromScale(0.9, 20)
	hpBg.Position = UDim2.fromScale(0.5, 0.55)
	hpBg.AnchorPoint = Vector2.new(0.5, 0)
	hpBg.BackgroundColor3 = Color3.fromHex("#1F2937")
	hpBg.Parent = card
	
	local hpBgCorner = Instance.new("UICorner")
	hpBgCorner.CornerRadius = UDim.new(0, 4)
	hpBgCorner.Parent = hpBg
	
	-- HP Bar Fill
	local hpFill = Instance.new("Frame")
	hpFill.Name = "HPBar"
	hpFill.Size = UDim2.fromScale(1, 1)
	hpFill.BackgroundColor3 = COLORS.Player
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg
	
	local hpFillCorner = Instance.new("UICorner")
	hpFillCorner.CornerRadius = UDim.new(0, 4)
	hpFillCorner.Parent = hpFill
	
	-- HP Text
	local hpText = Instance.new("TextLabel")
	hpText.Name = "HPText"
	hpText.Size = UDim2.fromScale(1, 1)
	hpText.BackgroundTransparency = 1
	hpText.TextColor3 = COLORS.Text
	hpText.Font = Enum.Font.GothamBold
	hpText.TextSize = 12
	hpText.Text = participant.HP .. "/" .. participant.MaxHP
	hpText.Parent = hpBg
	
	-- Stats display
	local statsFrame = Instance.new("Frame")
	statsFrame.Size = UDim2.fromScale(0.9, 0.25)
	statsFrame.Position = UDim2.fromScale(0.5, 0.75)
	statsFrame.AnchorPoint = Vector2.new(0.5, 0)
	statsFrame.BackgroundTransparency = 1
	statsFrame.Parent = card
	
	local stats = participant.Stats or {}
	local statLabels = {
		{ Name = "ATK", Value = stats.Logos or 0, Color = Color3.fromHex("#EF4444") },
		{ Name = "DEF", Value = stats.Ethos or 0, Color = Color3.fromHex("#3B82F6") },
		{ Name = "SPD", Value = stats.Speed or 0, Color = Color3.fromHex("#F59E0B") },
	}
	
	for i, stat in ipairs(statLabels) do
		local statLabel = Instance.new("TextLabel")
		statLabel.Size = UDim2.fromScale(0.33, 1)
		statLabel.Position = UDim2.fromScale((i - 1) * 0.33, 0)
		statLabel.BackgroundTransparency = 1
		statLabel.TextColor3 = stat.Color
		statLabel.Font = Enum.Font.Gotham
		statLabel.TextSize = 11
		statLabel.Text = stat.Name .. ": " .. stat.Value
		statLabel.Parent = statsFrame
	end
	
	-- Rarity indicator
	if participant.Rarity then
		local rarityColors = {
			Common = Color3.fromHex("#9CA3AF"),
			Uncommon = Color3.fromHex("#22C55E"),
			Rare = Color3.fromHex("#3B82F6"),
			Epic = Color3.fromHex("#8B5CF6"),
			Legendary = Color3.fromHex("#F59E0B"),
			Mythic = Color3.fromHex("#EC4899"),
		}
		
		local rarityGlow = Instance.new("UIStroke")
		rarityGlow.Color = rarityColors[participant.Rarity] or rarityColors.Common
		rarityGlow.Thickness = participant.Rarity == "Mythic" and 4 or 2
		rarityGlow.Parent = card
	end
	
	return card
end

function BattleUI.UpdateHP(instanceId: string, currentHP: number, maxHP: number)
	local hpBar = hpBars[instanceId]
	if not hpBar then return end
	
	local percent = math.clamp(currentHP / maxHP, 0, 1)
	
	-- Update fill
	TweenService:Create(hpBar, TweenInfo.new(0.3), {
		Size = UDim2.fromScale(percent, 1)
	}):Play()
	
	-- Update color based on HP
	if percent > 0.5 then
		hpBar.BackgroundColor3 = COLORS.Player
	elseif percent > 0.25 then
		hpBar.BackgroundColor3 = COLORS.HPBarLow
	else
		hpBar.BackgroundColor3 = COLORS.HPBarCritical
	end
	
	-- Update text
	local hpText = hpBar:FindFirstChild("HPText")
	if hpText then
		hpText.Text = currentHP .. "/" .. maxHP
	end
end

function BattleUI.AddLogEntry(text: string)
	if not battleScreen then return end
	
	local logScroll = battleScreen:FindFirstChild("BattleLog", true)
	if not logScroll then return end
	
	logScroll = logScroll:FindFirstChild("LogScroll")
	if not logScroll then return end
	
	local entry = Instance.new("TextLabel")
	entry.Size = UDim2.fromScale(1, 0)
	entry.AutomaticSize = Enum.AutomaticSize.Y
	entry.BackgroundTransparency = 1
	entry.TextColor3 = COLORS.Text
	entry.Font = Enum.Font.Gotham
	entry.TextSize = 12
	entry.TextWrapped = true
	entry.TextXAlignment = Enum.TextXAlignment.Left
	entry.Text = "• " .. text
	entry.Parent = logScroll
	
	-- Scroll to bottom
	task.defer(function()
		logScroll.CanvasPosition = Vector2.new(0, math.huge)
	end)
end

function BattleUI.UpdateTurn(turnNumber: number)
	if not battleScreen then return end
	
	local turnLabel = battleScreen:FindFirstChild("TurnIndicator")
	if turnLabel then
		turnLabel.Text = "Turn " .. turnNumber
	end
end

function BattleUI.ShowVictory(winnerName: string)
	if not battleScreen then return end
	
	-- Victory overlay
	local victoryOverlay = Instance.new("Frame")
	victoryOverlay.Name = "VictoryOverlay"
	victoryOverlay.Size = UDim2.fromScale(1, 1)
	victoryOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
	victoryOverlay.BackgroundTransparency = 0.5
	victoryOverlay.ZIndex = 100
	victoryOverlay.Parent = battleScreen
	
	local victoryText = Instance.new("TextLabel")
	victoryText.Size = UDim2.fromOffset(500, 100)
	victoryText.Position = UDim2.fromScale(0.5, 0.5)
	victoryText.AnchorPoint = Vector2.new(0.5, 0.5)
	victoryText.BackgroundTransparency = 1
	victoryText.TextColor3 = COLORS.Accent
	victoryText.Font = Enum.Font.GothamBold
	victoryText.TextSize = 48
	victoryText.Text = "🏆 " .. winnerName .. " WINS! 🏆"
	victoryText.ZIndex = 101
	victoryText.Parent = victoryOverlay
	
	-- Animate
	victoryText.Size = UDim2.fromOffset(0, 100)
	TweenService:Create(victoryText, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(500, 100)
	}):Play()
	
	-- Auto-close after delay
	task.delay(3, function()
		BattleUI.Hide()
	end)
end

function BattleUI.Hide()
	if battleScreen then
		-- Fade out
		for _, child in ipairs(battleScreen:GetChildren()) do
			TweenService:Create(child, TweenInfo.new(0.3), {
				BackgroundTransparency = 1
			}):Play()
		end
		
		task.wait(0.4)
		battleScreen:Destroy()
		battleScreen = nil
	end
	
	currentBattle = nil
	hpBars = {}
end

-- Connect to BattleService
function BattleUI.Initialize()
	local BattleService = Knit.GetService("BattleService")
	
	BattleService.Client.BattleStarted:Connect(function(battleData)
		BattleUI.ShowBattle(battleData)
	end)
	
	BattleService.Client.BattleTurn:Connect(function(battleData)
		-- Update HP for all participants
		for _, participant in ipairs(battleData.Participants or {}) do
			BattleUI.UpdateHP(participant.InstanceId, participant.HP, participant.MaxHP)
		end
		
		-- Update turn
		BattleUI.UpdateTurn(battleData.Turn)
		
		-- Add new log entries
		local log = battleData.Log or {}
		if #log > 0 then
			BattleUI.AddLogEntry(log[#log])
		end
	end)
	
	BattleService.Client.BattleEnded:Connect(function(battleData)
		if battleData.Winner then
			-- Find winner name
			local winnerName = "Unknown"
			for _, p in ipairs(battleData.Participants or {}) do
				if p.InstanceId == battleData.Winner then
					winnerName = p.SlimeName
					break
				end
			end
			BattleUI.ShowVictory(winnerName)
		else
			BattleUI.Hide()
		end
	end)
	
	print("[BattleUI] Initialized and connected to BattleService")
end

return BattleUI