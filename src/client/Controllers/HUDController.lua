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

-- State
local playerStats = {
	Level = 1,
	XP = 0,
	Insight = 0,
}

function HUDController:KnitStart()
	print("[HUDController] Starting...")
	
	-- Initialize UI components
	self:CreateMainHUD()
	self:InitializeServiceConnections()
	self:SetupKeyboardShortcuts()
	
	-- Initialize Battle UI
	BattleUI.Initialize()
	
	-- Initialize Slime Collection UI
	SlimeCollectionUI.Initialize()
	
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
	
	-- Top-left: Player Stats
	self:CreatePlayerStatsPanel(screenGui)
	
	-- Top-center: Phase indicator (handled by GameLoopController)
	-- Right side: Quest Log (handled by QuestLog)
	
	-- Bottom: Action Bar
	self:CreateActionBar(screenGui)
	
	-- Bottom-right: Mini-map placeholder
	self:CreateMiniMap(screenGui)
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
	self.nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.nameLabel.Parent = statsPanel
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
		{ Name = "Quests", Key = "J", Icon = "📜", Callback = function() self:ToggleQuestLog() end },
		{ Name = "Shop", Key = "P", Icon = "🛒", Callback = function() self:OpenShop() end },
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
	mapTitle.Text = "Psyche-Polis"
	mapTitle.Parent = miniMap
	
	-- District indicators
	local districts = {
		{ Name = "Logos", Position = UDim2.fromScale(0.5, 0.25), Color = Color3.fromHex("#3B82F6") },
		{ Name = "Eros", Position = UDim2.fromScale(0.5, 0.75), Color = Color3.fromHex("#22C55E") },
		{ Name = "Pneuma", Position = UDim2.fromScale(0.8, 0.5), Color = Color3.fromHex("#8B5CF6") },
		{ Name = "Soma", Position = UDim2.fromScale(0.2, 0.5), Color = Color3.fromHex("#EF4444") },
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

function HUDController:InitializeServiceConnections()
	-- Connect to DataService for stats updates
	local DataService = Knit.GetService("DataService")
	
	DataService.Client.DataLoaded:Connect(function(data)
		self:UpdateStats(data)
	end)
	
	DataService.Client.DataUpdated:Connect(function(key, value)
		if key == "Stats" or key == "Level" or key == "XP" then
			self:UpdateStats(value)
		end
	end)
	
	-- Connect to CrystalService for crystal collection
	local CrystalService = Knit.GetService("CrystalService")
	
	CrystalService.Client.CrystalCollected:Connect(function(letter, rarity)
		self:ShowNotification("Collected " .. rarity .. " crystal: " .. letter, 2)
	end)
	
	-- Connect to SlimeFactory for slime creation
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	SlimeFactory.Client.SlimeCreated:Connect(function(slime)
		self:ShowNotification("New Slime: " .. slime.Term .. " (" .. slime.Rarity .. ")", 3)
	end)
	
	-- Connect to MadLibService for quest updates
	local MadLibService = Knit.GetService("MadLibService")
	
	MadLibService.Client.QuestGenerated:Connect(function(quest)
		self:ShowNotification("New Quest: " .. quest.Title, 3)
		-- Update quest log
		local container = QuestLog.Create()
		QuestLog.UpdateQuest(container, quest)
	end)
	
	MadLibService.Client.QuestCompleted:Connect(function(quest)
		self:ShowNotification("Quest Complete! +" .. quest.Rewards.XP .. " XP", 4)
		QuestLog.RemoveQuest(quest.QuestId)
	end)
	
	-- Connect to GameLoopService for phase changes
	local GameLoopService = Knit.GetService("GameLoopService")
	
	GameLoopService.Client.PhaseChanged:Connect(function(phase, duration)
		self:OnPhaseChanged(phase, duration)
	end)
	
	GameLoopService.Client.GameLoopEvent:Connect(function(eventType, data)
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
		-- K = Word Constructor (during Construction phase)
		elseif input.KeyCode == Enum.KeyCode.K then
			local WordConstructorController = Knit.GetController("WordConstructorController")
			if WordConstructorController then
				WordConstructorController:Toggle()
			end
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
	-- Show phase notification
	local phaseNames = {
		Collection = "🌟 Collection Phase - Collect letter crystals!",
		Construction = "🔨 Construction Phase - Build words!",
		Quest = "📜 Quest Phase - Complete Mad Libs!",
		Combat = "⚔️ Combat Phase - Battle for slots!",
		Rewards = "🎁 Rewards Phase - Claim your rewards!",
	}
	
	self:ShowNotification(phaseNames[phase] or phase .. " Phase", 3)
end

function HUDController:OnGameEvent(eventType: string, data: any)
	if eventType == "SlimeCreated" then
		self:ShowNotification("🧪 Created: " .. tostring(data), 3)
	elseif eventType == "QuestCompleted" then
		self:ShowNotification("🎉 Quest Complete: " .. tostring(data), 4)
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