--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local HUDController = Knit.CreateController { Name = "HUDController" }

-- UI Modules
local QuestLog = require(script.Parent.Parent.UI.QuestLog)
local BattleUI = require(script.Parent.Parent.UI.BattleUI)
local SlimeCollectionUI = require(script.Parent.Parent.UI.SlimeCollectionUI)
local DialogueUI = require(script.Parent.Parent.UI.DialogueUI)
local LureUI = require(script.Parent.Parent.UI.LureUI)
local TutorialUI = require(script.Parent.Parent.UI.TutorialUI)
local InventoryUI = require(script.Parent.Parent.UI.InventoryUI)
local AchievementUI = require(script.Parent.Parent.UI.AchievementUI)
local EvolutionUI = require(script.Parent.Parent.UI.EvolutionUI)
local GalleryUI = require(script.Parent.Parent.UI.GalleryUI)

-- State
local playerStats = {
	Level = 1,
	XP = 0,
	Insight = 0,
}

function HUDController:KnitStart()
	print("[HUDController] Starting...")
	
	-- Initialize UI components with error handling
	local success, result = pcall(function()
		self:CreateMainHUD()
	end)
	if not success then
		warn("[HUDController] Failed to create main HUD:", result)
	end
	
	success, result = pcall(function()
		self:InitializeServiceConnections()
	end)
	if not success then
		warn("[HUDController] Failed to initialize service connections:", result)
	end
	
	success, result = pcall(function()
		self:SetupKeyboardShortcuts()
	end)
	if not success then
		warn("[HUDController] Failed to setup keyboard shortcuts:", result)
	end
	
	-- Initialize UI modules with error handling
	local uiModules = {
		{ name = "BattleUI", module = BattleUI },
		{ name = "SlimeCollectionUI", module = SlimeCollectionUI },
		{ name = "TutorialUI", module = TutorialUI },
		{ name = "InventoryUI", module = InventoryUI },
		{ name = "DialogueUI", module = DialogueUI },
		{ name = "LureUI", module = LureUI },
		{ name = "QuestLog", module = QuestLog },
		{ name = "AchievementUI", module = AchievementUI },
		{ name = "EvolutionUI", module = EvolutionUI },
		{ name = "GalleryUI", module = GalleryUI },
	}
	
	for _, uiModule in ipairs(uiModules) do
		success, result = pcall(function()
			if uiModule.module and uiModule.module.Initialize then
				uiModule.module.Initialize()
				print("[HUDController] Initialized", uiModule.name)
			else
				print("[HUDController] Skipping", uiModule.name, "- no Initialize method")
			end
		end)
		
		if not success then
			warn("[HUDController] Failed to initialize", uiModule.name, ":", result)
		end
	end
	
	
	print("[HUDController] Started successfully.")
end

function HUDController:CreateMainHUD()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Main HUD ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainHUD"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	
	-- Top-center: Phase indicator
	self:CreatePhasePanel(screenGui)
	
	-- Right side: Quest Log (handled by QuestLog)
	
	-- Bottom: Action Bar
	self:CreateActionBar(screenGui)
	
	-- Bottom-right: Mini-map placeholder
	self:CreateMiniMap(screenGui)
	
	-- Full-screen Phase Splash
	self:CreatePhaseSplash(screenGui)
end

function HUDController:CreatePlayerStatsPanel(parent: Instance)
	local statsPanel = Instance.new("Frame")
	statsPanel.Name = "PlayerStats"
	statsPanel.Size = UDim2.fromOffset(250, 100)
	statsPanel.Position = UDim2.fromScale(0.02, 0.02)
	statsPanel.BackgroundColor3 = GameConfig.Colors.Dark
	statsPanel.BackgroundTransparency = 0.3
	statsPanel.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = statsPanel
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.Colors.Primary
	stroke.Thickness = 2
	stroke.Parent = statsPanel
	
	-- Level badge
	local levelBadge = Instance.new("Frame")
	levelBadge.Name = "LevelBadge"
	levelBadge.Size = UDim2.fromOffset(50, 50)
	levelBadge.Position = UDim2.fromScale(0.05, 0.5)
	levelBadge.AnchorPoint = Vector2.new(0, 0.5)
	levelBadge.BackgroundColor3 = GameConfig.Colors.Primary
	levelBadge.Parent = statsPanel
	
	local levelCorner = Instance.new("UICorner")
	levelCorner.CornerRadius = UDim.new(1, 0)
	levelCorner.Parent = levelBadge
	
	self.levelLabel = Instance.new("TextLabel")
	self.levelLabel.Size = UDim2.fromScale(1, 1)
	self.levelLabel.BackgroundTransparency = 1
	self.levelLabel.TextColor3 = Color3.new(1, 1, 1)
	self.levelLabel.Font = Enum.Font.GothamBold
	self.levelLabel.TextSize = 20
	self.levelLabel.Text = "1"
	self.levelLabel.Parent = levelBadge
	
	-- XP Bar
	local xpBarBg = Instance.new("Frame")
	xpBarBg.Name = "XPBarBg"
	xpBarBg.Size = UDim2.fromOffset(150, 12)
	xpBarBg.Position = UDim2.fromOffset(70, 25)
	xpBarBg.BackgroundColor3 = Color3.fromHex("#1F2937")
	xpBarBg.Parent = statsPanel
	
	local xpCorner = Instance.new("UICorner")
	xpCorner.CornerRadius = UDim.new(0, 6)
	xpCorner.Parent = xpBarBg
	
	self.xpBar = Instance.new("Frame")
	self.xpBar.Name = "XPBar"
	self.xpBar.Size = UDim2.fromScale(0, 1)
	self.xpBar.BackgroundColor3 = GameConfig.Colors.Secondary
	self.xpBar.BorderSizePixel = 0
	self.xpBar.Parent = xpBarBg
	
	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(0, 6)
	xpFillCorner.Parent = self.xpBar
	
	self.xpLabel = Instance.new("TextLabel")
	self.xpLabel.Size = UDim2.fromScale(1, 1)
	self.xpLabel.BackgroundTransparency = 1
	self.xpLabel.TextColor3 = Color3.new(1, 1, 1)
	self.xpLabel.Font = Enum.Font.GothamBold
	self.xpLabel.TextSize = 10
	self.xpLabel.Text = "0 / 100 XP"
	self.xpLabel.Parent = xpBarBg
	
	-- Insight (Currency)
	self.insightLabel = Instance.new("TextLabel")
	self.insightLabel.Name = "InsightLabel"
	self.insightLabel.Size = UDim2.fromOffset(150, 20)
	self.insightLabel.Position = UDim2.fromOffset(70, 50)
	self.insightLabel.BackgroundTransparency = 1
	self.insightLabel.TextColor3 = GameConfig.Colors.Accent
	self.insightLabel.Font = Enum.Font.GothamBold
	self.insightLabel.TextSize = 14
	self.insightLabel.Text = "💎 Insight: 0"
	self.insightLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.insightLabel.Parent = statsPanel
	
	-- Player name
	self.nameLabel = Instance.new("TextLabel")
	self.nameLabel.Size = UDim2.fromOffset(150, 20)
	self.nameLabel.Position = UDim2.fromOffset(70, 70)
	self.nameLabel.BackgroundTransparency = 1
	self.nameLabel.TextColor3 = GameConfig.Colors.TextDim
	self.nameLabel.Font = Enum.Font.Gotham
	self.nameLabel.TextSize = 12
	self.nameLabel.Text = Players.LocalPlayer.Name
	self.nameLabel.Parent = statsPanel
end

function HUDController:CreatePhasePanel(parent: Instance)
	local phaseFrame = Instance.new("Frame")
	phaseFrame.Name = "PhasePanel"
	phaseFrame.Size = UDim2.fromOffset(300, 60)
	phaseFrame.Position = UDim2.fromScale(0.5, 0.05)
	phaseFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	phaseFrame.BackgroundColor3 = GameConfig.Colors.Dark
	phaseFrame.BackgroundTransparency = 0.3
	phaseFrame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = phaseFrame

	self.phaseLabel = Instance.new("TextLabel")
	self.phaseLabel.Name = "PhaseLabel"
	self.phaseLabel.Size = UDim2.fromScale(1, 0.6)
	self.phaseLabel.BackgroundTransparency = 1
	self.phaseLabel.TextColor3 = Color3.new(1, 1, 1)
	self.phaseLabel.Font = Enum.Font.GothamBold
	self.phaseLabel.TextSize = 22
	self.phaseLabel.Text = "Waiting..."
	self.phaseLabel.Parent = phaseFrame

	self.timerLabel = Instance.new("TextLabel")
	self.timerLabel.Name = "TimerLabel"
	self.timerLabel.Size = UDim2.fromScale(1, 0.4)
	self.timerLabel.Position = UDim2.fromScale(0, 0.6)
	self.timerLabel.BackgroundTransparency = 1
	self.timerLabel.TextColor3 = GameConfig.Colors.TextDim
	self.timerLabel.Font = Enum.Font.Gotham
	self.timerLabel.TextSize = 16
	self.timerLabel.Text = ""
	self.timerLabel.Visible = false
	self.timerLabel.Parent = phaseFrame
end

function HUDController:CreateActionBar(parent: Instance)
	local actionBar = Instance.new("Frame")
	actionBar.Name = "ActionBar"
	actionBar.Size = UDim2.fromOffset(400, 60)
	actionBar.Position = UDim2.fromScale(0.5, 0.95)
	actionBar.AnchorPoint = Vector2.new(0.5, 1)
	actionBar.BackgroundColor3 = GameConfig.Colors.Dark
	actionBar.BackgroundTransparency = 0.3
	actionBar.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = actionBar
	
	-- Action buttons
	local actions = {
		{ Name = "Collection", Key = "I", Icon = "🧪", Callback = function() SlimeCollectionUI.Toggle() end },
		{ Name = "Archetype Manifestations", Key = "J", Icon = "📜", Callback = function() self:ToggleQuestLog() end },
		{ Name = "Achievements", Key = "Y", Icon = "🏆", Callback = function() AchievementUI.Toggle() end },
		{ Name = "Settings", Key = "Esc", Icon = "⚙️", Callback = function() self:OpenSettings() end },
	}
	
	for i, action in ipairs(actions) do
		local btn = Instance.new("TextButton")
		btn.Name = action.Name .. "Btn"
		btn.Size = UDim2.fromOffset(80, 45)
		btn.Position = UDim2.fromOffset(20 + (i - 1) * 95, 7)
		btn.BackgroundColor3 = GameConfig.Colors.Charcoal
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 12
		btn.Text = action.Icon .. "\n[" .. action.Key .. "]"
		btn.Parent = actionBar
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn
		
		btn.MouseButton1Click:Connect(action.Callback)
		
		-- Hover effect
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {
				BackgroundColor3 = GameConfig.Colors.Primary
			}):Play()
		end)
		
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {
				BackgroundColor3 = GameConfig.Colors.Charcoal
			}):Play()
		end)
	end
end

function HUDController:CreateMiniMap(parent: Instance)
	local miniMap = Instance.new("Frame")
	miniMap.Name = "MiniMap"
	miniMap.Size = UDim2.fromOffset(150, 150)
	miniMap.Position = UDim2.fromScale(0.98, 0.02)
	miniMap.AnchorPoint = Vector2.new(1, 0)
	miniMap.BackgroundColor3 = GameConfig.Colors.Dark
	miniMap.BackgroundTransparency = 0.3
	miniMap.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = miniMap
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = GameConfig.Colors.Primary
	stroke.Thickness = 2
	stroke.Parent = miniMap
	
	-- Map title
	local mapTitle = Instance.new("TextLabel")
	mapTitle.Size = UDim2.fromScale(1, 0.15)
	mapTitle.BackgroundTransparency = 1
	mapTitle.TextColor3 = GameConfig.Colors.TextDim
	mapTitle.Font = Enum.Font.GothamBold
	mapTitle.TextSize = 10
	mapTitle.Text = "Syllable Springs"
	mapTitle.Parent = miniMap
	
	-- District indicators
	local districts = {
		{ Name = "BrainyBorough", Position = UDim2.fromScale(0.5, 0.25), Color = Color3.fromHex("#3B82F6") },
		{ Name = "HeartwoodGrove", Position = UDim2.fromScale(0.5, 0.75), Color = Color3.fromHex("#22C55E") },
		{ Name = "WhisperWinds", Position = UDim2.fromScale(0.8, 0.5), Color = Color3.fromHex("#8B5CF6") },
		{ Name = "ActionAlley", Position = UDim2.fromScale(0.2, 0.5), Color = Color3.fromHex("#EF4444") },
	}
	
	for _, district in ipairs(districts) do
		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.fromOffset(20, 20)
		indicator.Position = district.Position
		indicator.AnchorPoint = Vector2.new(0.5, 0.5)
		indicator.BackgroundColor3 = district.Color
		indicator.Parent = miniMap
		
		local indicatorCorner = Instance.new("UICorner")
		indicatorCorner.CornerRadius = UDim.new(0, 4)
		indicatorCorner.Parent = indicator
	end
	
	-- Player indicator (center)
	local playerIndicator = Instance.new("Frame")
	playerIndicator.Name = "PlayerIndicator"
	playerIndicator.Size = UDim2.fromOffset(10, 10)
	playerIndicator.Position = UDim2.fromScale(0.5, 0.5)
	playerIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	playerIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
	playerIndicator.Parent = miniMap
	
	local playerCorner = Instance.new("UICorner")
	playerCorner.CornerRadius = UDim.new(1, 0)
	playerCorner.Parent = playerIndicator
end

function HUDController:CreatePhaseSplash(parent: Instance)
	self.splashFrame = Instance.new("Frame")
	self.splashFrame.Name = "PhaseSplash"
	self.splashFrame.Size = UDim2.fromScale(1, 0.2)
	self.splashFrame.Position = UDim2.fromScale(0.5, 0.5)
	self.splashFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.splashFrame.BackgroundColor3 = GameConfig.Colors.Primary
	self.splashFrame.BackgroundTransparency = 1
	self.splashFrame.BorderSizePixel = 0
	self.splashFrame.Parent = parent

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	gradient.Parent = self.splashFrame

	self.splashLabel = Instance.new("TextLabel")
	self.splashLabel.Name = "SplashLabel"
	self.splashLabel.Size = UDim2.fromScale(1, 1)
	self.splashLabel.BackgroundTransparency = 1
	self.splashLabel.TextColor3 = Color3.new(1, 1, 1)
	self.splashLabel.TextTransparency = 1
	self.splashLabel.Font = Enum.Font.GothamBold
	self.splashLabel.TextSize = 60
	self.splashLabel.Text = "PHASE START"
	self.splashLabel.Parent = self.splashFrame
end

function HUDController:InitializeServiceConnections()
	-- Connect to DataService for stats updates
	local DataService = Knit.GetService("DataService")
	
	DataService.DataLoaded:Connect(function(data)
		self:UpdateStats(data)
	end)
	
	DataService.DataUpdated:Connect(function(key, value)
		if key == "Stats" or key == "Level" or key == "XP" then
			self:UpdateStats(value)
		elseif key == "AchievementUnlocked" then
			local AchievementData = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("AchievementData"))
			local data = AchievementData[value]
			if data then
				self:ShowAchievementPopup(data)
			end
		end
	end)
	
	-- Connect to CrystalService for crystal collection
	local CrystalService = Knit.GetService("CrystalService")
	
	CrystalService.CrystalCollected:Connect(function(letter, rarity)
		self:ShowNotification("Collected " .. rarity .. " crystal: " .. letter, 2)
	end)
	
	-- Connect to SlimeFactory for slime creation
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	SlimeFactory.SlimeCreated:Connect(function(slime)
		self:ShowNotification("New Slime: " .. slime.Term .. " (" .. slime.Rarity .. ")", 3)
	end)
	
	-- Connect to MadLibService for quest updates
	local MadLibService = Knit.GetService("MadLibService")
	
	MadLibService.QuestGenerated:Connect(function(quest)
		self:ShowNotification("New Quest: " .. quest.Title, 3)
		-- Update quest log
		local container = QuestLog.Create()
		QuestLog.UpdateQuest(container, quest)
	end)
	
	MadLibService.QuestCompleted:Connect(function(quest)
		self:ShowNotification("Quest Complete! +" .. quest.Rewards.XP .. " XP", 4)
		QuestLog.RemoveQuest(quest.QuestId)
	end)
	
	-- Connect to GameLoopService for phase changes
	local GameLoopService = Knit.GetService("GameLoopService")
	
	GameLoopService.PhaseChanged:Connect(function(phase, duration)
		self:OnPhaseChanged(phase, duration)
	end)
	
	GameLoopService.GameLoopEvent:Connect(function(eventType, data)
		self:OnGameEvent(eventType, data)
	end)
end

function HUDController:SetupKeyboardShortcuts()
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		
		-- I = Slime Collection
		if input.KeyCode == Enum.KeyCode.I then
			SlimeCollectionUI.Toggle()
		-- J = Quest Log
		elseif input.KeyCode == Enum.KeyCode.J then
			self:ToggleQuestLog()
		elseif input.KeyCode == Enum.KeyCode.B then
			InventoryUI.Toggle()
		-- K = Slime Fabricator (during Construction phase)
		elseif input.KeyCode == Enum.KeyCode.K then
			local SlimeFabricatorController = Knit.GetController("WordConstructorController")
			if SlimeFabricatorController then
				SlimeFabricatorController:Toggle()
			end
		-- U = Evolution UI
		elseif input.KeyCode == Enum.KeyCode.U then
			EvolutionUI.Show = EvolutionUI.Show or function() end
			EvolutionUI.Show(EvolutionUI)
		-- O = Gallery UI
		elseif input.KeyCode == Enum.KeyCode.O then
			GalleryUI.Show = GalleryUI.Show or function() end
			GalleryUI.Show(GalleryUI)
		end
	end)
end

function HUDController:UpdateStats(data: any)
	if not data then return end
	
	if data.Level and self.levelLabel then
		self.levelLabel.Text = tostring(data.Level)
	end
	
	if data.XP and self.xpLabel then
		local xpReq = 100 * (data.Level or 1)
		local percent = math.clamp(data.XP / xpReq, 0, 1)
		self.xpBar.Size = UDim2.fromScale(percent, 1)
		self.xpLabel.Text = data.XP .. " / " .. xpReq .. " XP"
	end
	
	if data.Stats and data.Stats.Insight and self.insightLabel then
		self.insightLabel.Text = "💎 Insight: " .. data.Stats.Insight
	end
end

function HUDController:OnPhaseChanged(phase: string, duration: number)
	local phaseNames = {
		Collection = "The World Breathes in Letters",
		Construction = "Crystallizing Meaning",
		Quest = "Manifesting the Hero's Journey",
		Combat = "Discord in the Psyche",
		Rewards = "Resonance of Achievement",
		Reflection = "Reflective Silence",
	}
	
	self:ShowNotification(phaseNames[phase] or phase, 3)
	
	if self.phaseLabel then
		self.phaseLabel.Text = phaseNames[phase] or phase
	end
	
	if self.timerLabel then
		self.timerLabel.Visible = false
	end
	
	self:PlayPhaseSplash(phaseNames[phase] or phase)
end

function HUDController:PlayPhaseSplash(text: string)
	if not self.splashFrame or not self.splashLabel then return end
	
	self.splashLabel.Text = text:upper()
	
	-- Reset state
	self.splashFrame.BackgroundTransparency = 1
	self.splashLabel.TextTransparency = 1
	self.splashFrame.Size = UDim2.fromScale(1, 0)
	
	-- Play Sound (SoundController handles its own signals, but we can call it if needed)
	local SoundController = Knit.GetController("SoundController")
	if SoundController then
		SoundController:Play("LevelUp") -- Reusing for impact
	end

	-- Animation sequence
	local info = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	
	TweenService:Create(self.splashFrame, info, {
		BackgroundTransparency = 0.5,
		Size = UDim2.fromScale(1, 0.2)
	}):Play()
	
	TweenService:Create(self.splashLabel, info, {
		TextTransparency = 0
	}):Play()
	
	task.delay(2.5, function()
		local fadeInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(self.splashFrame, fadeInfo, {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0)
		}):Play()
		
		TweenService:Create(self.splashLabel, fadeInfo, {
			TextTransparency = 1
		}):Play()
	end)
end

function HUDController:UpdateTimer(timeLeft: number)
	if not self.timerLabel then return end
	
	if timeLeft <= 10 and timeLeft > 0 then
		self.timerLabel.Visible = true
		self.timerLabel.Text = "The Phase Fades in " .. tostring(timeLeft) .. "s"
		
		-- Subtle pulse effect
		if timeLeft % 2 == 0 then
			self.timerLabel.TextColor3 = GameConfig.Colors.Accent
		else
			self.timerLabel.TextColor3 = GameConfig.Colors.TextDim
		end
	else
		self.timerLabel.Visible = false
	end
end

function HUDController:OnGameEvent(eventType: string, data: any)
	if eventType == "SlimeCreated" then
		self:ShowNotification("🧪 Created: " .. tostring(data), 3)
	elseif eventType == "QuestCompleted" then
		self:ShowNotification("🎉 Quest Complete: " .. tostring(data), 4)
	elseif eventType == "ObjectiveComplete" then
		self:ShowNotification("🎯 Objective Complete: " .. tostring(data.Bonus), 4)
		self:UpdateObjectiveUI(data)
	elseif eventType == "HighResonance" then
		self:ShowNotification("⚡ HIGH RESONANCE ACTIVATED! ⚡", 5)
		self:ShowResonanceUI(data)
	elseif eventType == "ResonanceIncreased" then
		self:UpdateResonanceUI(data)
	end
end

-- Create/update objective progress UI
function HUDController:UpdateObjectiveUI(objectiveData: any)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Find or create objective panel
	local objectivePanel = playerGui:FindFirstChild("ObjectivePanel")
	if not objectivePanel then
		objectivePanel = Instance.new("Frame")
		objectivePanel.Name = "ObjectivePanel"
		objectivePanel.Size = UDim2.fromOffset(250, 80)
		objectivePanel.Position = UDim2.fromScale(0.5, 0.15)
		objectivePanel.AnchorPoint = Vector2.new(0.5, 0)
		objectivePanel.BackgroundColor3 = GameConfig.Colors.Primary
		objectivePanel.BackgroundTransparency = 0.3
		objectivePanel.Parent = playerGui
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = objectivePanel
		
		local stroke = Instance.new("UIStroke")
		stroke.Color = GameConfig.Colors.Accent
		stroke.Thickness = 2
		stroke.Parent = objectivePanel
		
		-- Title
		local titleLabel = Instance.new("TextLabel")
		titleLabel.Name = "TitleLabel"
		titleLabel.Size = UDim2.fromScale(1, 0.4)
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextColor3 = Color3.new(1, 1, 1)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 14
		titleLabel.Text = "🎯 Phase Objective"
		titleLabel.Parent = objectivePanel
		
		-- Progress bar
		local progressBg = Instance.new("Frame")
		progressBg.Name = "ProgressBg"
		progressBg.Size = UDim2.fromScale(0.9, 0.25)
		progressBg.Position = UDim2.fromScale(0.05, 0.45)
		progressBg.BackgroundColor3 = Color3.fromHex("#1F2937")
		progressBg.Parent = objectivePanel
		
		local progressCorner = Instance.new("UICorner")
		progressCorner.CornerRadius = UDim.new(0, 4)
		progressCorner.Parent = progressBg
		
		-- Bonus label
		local bonusLabel = Instance.new("TextLabel")
		bonusLabel.Name = "BonusLabel"
		bonusLabel.Size = UDim2.fromScale(1, 0.3)
		bonusLabel.Position = UDim2.fromScale(0, 0.7)
		bonusLabel.BackgroundTransparency = 1
		bonusLabel.TextColor3 = GameConfig.Colors.Accent
		bonusLabel.Font = Enum.Font.GothamBold
		bonusLabel.TextSize = 12
		bonusLabel.Parent = objectivePanel
	end
	
	-- Update with new objective data
	local bonusLabel = objectivePanel:FindFirstChild("BonusLabel")
	if bonusLabel and objectiveData then
		bonusLabel.Text = "✓ " .. objectiveData.Bonus .. " COMPLETED!"
	end
end

function HUDController:ShowResonanceUI(data: any)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Update ObjectivePanel to "Resonance" mode
	local objectivePanel = playerGui:FindFirstChild("ObjectivePanel")
	if not objectivePanel then
		self:UpdateObjectiveUI({ Bonus = "Resonance" })
		objectivePanel = playerGui:FindFirstChild("ObjectivePanel")
	end
	
	if objectivePanel then
		local title = objectivePanel:FindFirstChild("TitleLabel")
		if title then title.Text = "⚡ RESONANCE LEVEL ⚡" end
		
		local bonus = objectivePanel:FindFirstChild("BonusLabel")
		if bonus then bonus.Text = "Multiplier: 1.0x" end
		
		-- Flash effect for high impact
		local originalColor = objectivePanel.BackgroundColor3
		objectivePanel.BackgroundColor3 = GameConfig.Colors.Accent
		task.delay(0.5, function()
			TweenService:Create(objectivePanel, TweenInfo.new(1), {
				BackgroundColor3 = originalColor
			}):Play()
		end)
	end
	
	-- Play special sound
	local SoundController = Knit.GetController("SoundController")
	if SoundController then
		SoundController:Play("Victory")
	end
end

function HUDController:UpdateResonanceUI(data: any)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local objectivePanel = playerGui:FindFirstChild("ObjectivePanel")
	
	if objectivePanel then
		local bonus = objectivePanel:FindFirstChild("BonusLabel")
		if bonus then 
			bonus.Text = "Multiplier: " .. string.format("%.1f", data.Multiplier) .. "x"
		end
		
		-- Subtle pulse to show growth
		local info = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true)
		TweenService:Create(objectivePanel, info, {
			Size = UDim2.fromOffset(260, 90)
		}):Play()
		
		-- Change color based on tier
		if data.Multiplier >= 5.0 then
			objectivePanel.BackgroundColor3 = Color3.fromHex("#F59E0B") -- Transcendent (Amber)
		elseif data.Multiplier >= 2.5 then
			objectivePanel.BackgroundColor3 = Color3.fromHex("#8B5CF6") -- Harmonic (Purple)
		elseif data.Multiplier >= 1.5 then
			objectivePanel.BackgroundColor3 = Color3.fromHex("#3B82F6") -- Resonant (Blue)
		end
	end
end

function HUDController:ShowNotification(text: string, duration: number)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Find or create notification container
	local container = playerGui:FindFirstChild("NotificationContainer")
	if not container then
		container = Instance.new("ScreenGui")
		container.Name = "NotificationContainer"
		container.ResetOnSpawn = false
		container.Parent = playerGui
	end
	
	-- Create notification
	local notification = Instance.new("Frame")
	notification.Size = UDim2.fromOffset(400, 50)
	notification.Position = UDim2.fromScale(0.5, 0.15)
	notification.AnchorPoint = Vector2.new(0.5, 0)
	notification.BackgroundColor3 = GameConfig.Colors.Primary
	notification.BackgroundTransparency = 0.2
	notification.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = notification
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.Text = text
	label.Parent = notification
	
	-- Animate in
	notification.Size = UDim2.fromOffset(0, 50)
	TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(400, 50)
	}):Play()
	
	-- Remove after duration
	task.delay(duration, function()
		TweenService:Create(notification, TweenInfo.new(0.3), {
			Size = UDim2.fromOffset(0, 50),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.4)
		notification:Destroy()
	end)
end

function HUDController:ShowAchievementPopup(data: any)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local container = playerGui:FindFirstChild("AchievementContainer")
	if not container then
		container = Instance.new("ScreenGui")
		container.Name = "AchievementContainer"
		container.ResetOnSpawn = false
		container.Parent = playerGui
	end
	
	local popup = Instance.new("Frame")
	popup.Size = UDim2.fromOffset(300, 80)
	popup.Position = UDim2.fromScale(0.5, 0.8)
	popup.AnchorPoint = Vector2.new(0.5, 0)
	popup.BackgroundColor3 = Color3.fromHex("#FFD700") -- Gold
	popup.BackgroundTransparency = 0.1
	popup.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = popup
	
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.new(1, 1, 1)
	uiStroke.Thickness = 2
	uiStroke.Parent = popup
	
	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.fromOffset(60, 60)
	iconLabel.Position = UDim2.fromOffset(10, 10)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = data.Icon or "🏆"
	iconLabel.TextSize = 40
	iconLabel.Parent = popup
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.4)
	titleLabel.Position = UDim2.fromOffset(80, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.new(0, 0, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Text = "Achievement Unlocked!"
	titleLabel.Parent = popup
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0.6)
	nameLabel.Position = UDim2.fromOffset(80, 35)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(50, 50, 50)
	nameLabel.Font = Enum.Font.Gotham
	nameLabel.TextSize = 14
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Text = data.Name
	nameLabel.TextWrapped = true
	nameLabel.Parent = popup
	
	-- Play sound
	local SoundController = Knit.GetController("SoundController")
	if SoundController then
		SoundController:Play("Victory")
	end
	
	-- Animate in
	popup.Position = UDim2.fromScale(0.5, 1.2)
	TweenService:Create(popup, TweenInfo.new(0.6, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.85)
	}):Play()
	
	-- Remove after 5 seconds
	task.delay(5, function()
		TweenService:Create(popup, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0.5, 1.2)
		}):Play()
		
		task.wait(0.5)
		popup:Destroy()
	end)
end

function HUDController:ToggleQuestLog()
	-- Toggle quest log visibility
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local questLogUI = playerGui:FindFirstChild("QuestLogUI")
	
	if questLogUI then
		local container = questLogUI:FindFirstChild("Container")
		if container then
			if container.Visible then
				container.Visible = false
			else
				container.Visible = true
			end
		end
	else
		-- Create quest log
		QuestLog.Create()
	end
end

function HUDController:OpenShop()
	self:ShowNotification("Shop coming soon!", 2)
end

function HUDController:OpenSettings()
	self:ShowNotification("Settings coming soon!", 2)
end

return HUDController