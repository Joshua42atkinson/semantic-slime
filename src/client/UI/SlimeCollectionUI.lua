--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("GameConfig"))

local SlimeCollectionUI = {}
SlimeCollectionUI.__index = SlimeCollectionUI

-- State
local collectionScreen: ScreenGui? = nil
local isOpen = false
local selectedSlime: any = nil
local slimeCards: { Frame } = {}

-- Colors
local COLORS = {
	Background = Color3.fromHex("#0F0E17"),
	CardBg = Color3.fromHex("#1A1A2E"),
	CardBgHover = Color3.fromHex("#2A2A4E"),
	Accent = Color3.fromHex("#FF8906"),
	Text = Color3.fromHex("#FFFFFE"),
	TextDim = Color3.fromHex("#A7A9BE"),
	Border = Color3.fromHex("#2CB67D"),
}

-- Element colors
local ELEMENT_COLORS: { [string]: Color3 } = {
	Fire = Color3.fromHex("#EF4444"),
	Water = Color3.fromHex("#3B82F6"),
	Earth = Color3.fromHex("#22C55E"),
	Air = Color3.fromHex("#F59E0B"),
	Shadow = Color3.fromHex("#8B5CF6"),
	Light = Color3.fromHex("#FCD34D"),
	Normal = Color3.fromHex("#6B7280"),
}

-- Rarity colors
local RARITY_COLORS: { [string]: Color3 } = {
	Common = Color3.fromHex("#9CA3AF"),
	Uncommon = Color3.fromHex("#22C55E"),
	Rare = Color3.fromHex("#3B82F6"),
	Epic = Color3.fromHex("#8B5CF6"),
	Legendary = Color3.fromHex("#F59E0B"),
	Mythic = Color3.fromHex("#EC4899"),
}

function SlimeCollectionUI.Toggle()
	if isOpen then
		SlimeCollectionUI.Hide()
	else
		SlimeCollectionUI.Show()
	end
end

function SlimeCollectionUI.Show()
	if isOpen then return end
	isOpen = true
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create screen
	collectionScreen = Instance.new("ScreenGui")
	collectionScreen.Name = "SlimeCollectionUI"
	collectionScreen.ResetOnSpawn = false
	collectionScreen.IgnoreGuiInset = true
	collectionScreen.Parent = playerGui
	
	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = collectionScreen
	
	-- Main container
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(900, 600)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = COLORS.Background
	container.Parent = collectionScreen
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 16)
	containerCorner.Parent = container
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.1)
	header.BackgroundColor3 = COLORS.CardBg
	header.Parent = container
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 16)
	headerCorner.Parent = header
	
	-- Fix bottom corners
	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.fromScale(1, 0.5)
	headerFix.Position = UDim2.fromScale(0, 0.5)
	headerFix.BackgroundColor3 = COLORS.CardBg
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(0.5, 1)
	title.Position = UDim2.fromScale(0.25, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = COLORS.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.Text = "🧪 Slime Collection"
	title.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.fromOffset(40, 40)
	closeBtn.Position = UDim2.fromScale(1, 0.5)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.BackgroundColor3 = Color3.fromHex("#EF4444")
	closeBtn.TextColor3 = COLORS.Text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.Text = "X"
	closeBtn.Parent = header
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		SlimeCollectionUI.Hide()
	end)
	
	-- Content area (split into grid and detail view)
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.fromScale(1, 0.9)
	contentArea.Position = UDim2.fromScale(0, 0.1)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = container
	
	-- Slime grid (left side)
	local gridContainer = Instance.new("ScrollingFrame")
	gridContainer.Name = "SlimeGrid"
	gridContainer.Size = UDim2.fromScale(0.6, 0.95)
	gridContainer.Position = UDim2.fromScale(0.02, 0.025)
	gridContainer.BackgroundTransparency = 1
	gridContainer.ScrollBarThickness = 6
	gridContainer.ScrollBarImageColor3 = COLORS.Accent
	gridContainer.Parent = contentArea
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.fromOffset(140, 160)
	gridLayout.CellPadding = UDim2.fromOffset(10, 10)
	gridLayout.Parent = gridContainer
	
	-- Detail view (right side)
	local detailView = Instance.new("Frame")
	detailView.Name = "DetailView"
	detailView.Size = UDim2.fromScale(0.35, 0.95)
	detailView.Position = UDim2.fromScale(0.63, 0.025)
	detailView.BackgroundColor3 = COLORS.CardBg
	detailView.Parent = contentArea
	
	local detailCorner = Instance.new("UICorner")
	detailCorner.CornerRadius = UDim.new(0, 12)
	detailCorner.Parent = detailView
	
	-- Detail content (will be populated when slime is selected)
	local detailContent = Instance.new("Frame")
	detailContent.Name = "Content"
	detailContent.Size = UDim2.fromScale(0.95, 0.95)
	detailContent.Position = UDim2.fromScale(0.5, 0.5)
	detailContent.AnchorPoint = Vector2.new(0.5, 0.5)
	detailContent.BackgroundTransparency = 1
	detailContent.Parent = detailView
	
	-- Placeholder text
	local placeholder = Instance.new("TextLabel")
	placeholder.Name = "Placeholder"
	placeholder.Size = UDim2.fromScale(1, 1)
	placeholder.BackgroundTransparency = 1
	placeholder.TextColor3 = COLORS.TextDim
	placeholder.Font = Enum.Font.Gotham
	placeholder.TextSize = 16
	placeholder.Text = "Select a slime to view details"
	placeholder.Parent = detailContent
	
	-- Load slimes from SlimeFactory
	SlimeCollectionUI.LoadSlimes(gridContainer)
	
	-- Entrance animation
	container.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(900, 600)
	}):Play()
	
	-- Keyboard input
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.I then
			SlimeCollectionUI.Hide()
		end
	end)
end

function SlimeCollectionUI.Hide()
	if not isOpen or not collectionScreen then return end
	
	isOpen = false
	
	-- Animate out
	local container = collectionScreen:FindFirstChild("Container")
	if container then
		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.fromOffset(0, 0)
		}):Play()
	end
	
	task.wait(0.35)
	if collectionScreen then
		collectionScreen:Destroy()
		collectionScreen = nil
	end
	
	slimeCards = {}
	selectedSlime = nil
end

function SlimeCollectionUI.LoadSlimes(gridContainer: ScrollingFrame)
	-- Clear existing cards
	for _, card in ipairs(slimeCards) do
		card:Destroy()
	end
	slimeCards = {}
	
	-- Get slimes from service
	local SlimeFactory = Knit.GetService("SlimeFactory")
	SlimeFactory:GetPlayerSlimes():andThen(function(slimes)
		-- Create cards
		for instanceId, slime in pairs(slimes) do
			local card = SlimeCollectionUI.CreateSlimeCard(slime)
			card.Parent = gridContainer
			table.insert(slimeCards, card)
		end
		
		-- If no slimes, show empty state
		if #slimeCards == 0 then
			local emptyLabel = Instance.new("TextLabel")
			emptyLabel.Size = UDim2.fromScale(1, 1)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.TextColor3 = COLORS.TextDim
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.TextSize = 18
			emptyLabel.Text = "No slimes collected yet!\n\nCollect letter crystals and construct words to create slimes."
			emptyLabel.TextWrapped = true
			emptyLabel.Parent = gridContainer
		end
	end):catch(warn)
end

function SlimeCollectionUI.CreateSlimeCard(slime: any): Frame
	local card = Instance.new("Frame")
	card.Name = "SlimeCard_" .. slime.InstanceId
	card.BackgroundColor3 = COLORS.CardBg
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 12)
	cardCorner.Parent = card
	
	-- Element border
	local border = Instance.new("UIStroke")
	border.Color = ELEMENT_COLORS[slime.Element] or ELEMENT_COLORS.Normal
	border.Thickness = 2
	border.Parent = card
	
	-- Slime visual (colored circle)
	local slimeVisual = Instance.new("Frame")
	slimeVisual.Name = "SlimeVisual"
	slimeVisual.Size = UDim2.fromOffset(60, 60)
	slimeVisual.Position = UDim2.fromScale(0.5, 0.35)
	slimeVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	slimeVisual.BackgroundColor3 = ELEMENT_COLORS[slime.Element] or ELEMENT_COLORS.Normal
	slimeVisual.Parent = card
	
	local visualCorner = Instance.new("UICorner")
	visualCorner.CornerRadius = UDim.new(1, 0)
	visualCorner.Parent = slimeVisual
	
	-- Glow effect for rare+ slimes
	if slime.Rarity == "Legendary" or slime.Rarity == "Mythic" then
		local glow = Instance.new("UIStroke")
		glow.Color = RARITY_COLORS[slime.Rarity]
		glow.Thickness = 3
		glow.Parent = slimeVisual
	end
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.fromScale(1, 0.2)
	nameLabel.Position = UDim2.fromScale(0, 0.65)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 14
	nameLabel.Text = slime.Term
	nameLabel.Parent = card
	
	-- Level and rarity
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Name = "Info"
	infoLabel.Size = UDim2.fromScale(1, 0.15)
	infoLabel.Position = UDim2.fromScale(0, 0.82)
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = RARITY_COLORS[slime.Rarity] or COLORS.TextDim
	infoLabel.Font = Enum.Font.Gotham
	infoLabel.TextSize = 11
	infoLabel.Text = "Lv." .. slime.Level .. " " .. slime.Rarity
	infoLabel.Parent = card
	
	-- Element icon
	local elementIcon = Instance.new("TextLabel")
	elementIcon.Size = UDim2.fromOffset(24, 24)
	elementIcon.Position = UDim2.fromScale(0.1, 0.1)
	elementIcon.BackgroundColor3 = ELEMENT_COLORS[slime.Element] or ELEMENT_COLORS.Normal
	elementIcon.BackgroundTransparency = 0.3
	elementIcon.TextColor3 = COLORS.Text
	elementIcon.Font = Enum.Font.GothamBold
	elementIcon.TextSize = 10
	elementIcon.Text = GameConfig.Elements[slime.Element] and GameConfig.Elements[slime.Element].Emoji or "?"
	elementIcon.Parent = card
	
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 4)
	iconCorner.Parent = elementIcon
	
	-- Role badge
	local roleBadge = Instance.new("TextLabel")
	roleBadge.Size = UDim2.fromOffset(50, 18)
	roleBadge.Position = UDim2.fromScale(0.9, 0.1)
	roleBadge.AnchorPoint = Vector2.new(1, 0)
	roleBadge.BackgroundColor3 = Color3.fromHex("#374151")
	roleBadge.TextColor3 = COLORS.TextDim
	roleBadge.Font = Enum.Font.Gotham
	roleBadge.TextSize = 9
	roleBadge.Text = slime.Role
	roleBadge.Parent = card
	
	local roleCorner = Instance.new("UICorner")
	roleCorner.CornerRadius = UDim.new(0, 4)
	roleCorner.Parent = roleBadge
	
	-- Click handler
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(1, 1)
	button.BackgroundTransparency = 1
	button.Text = ""
	button.Parent = card
	
	button.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.1), {
			BackgroundColor3 = COLORS.CardBgHover
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.1), {
			BackgroundColor3 = COLORS.CardBg
		}):Play()
	end)
	
	button.MouseButton1Click:Connect(function()
		SlimeCollectionUI.SelectSlime(slime)
	end)
	
	return card
end

function SlimeCollectionUI.SelectSlime(slime: any)
	selectedSlime = slime
	
	-- Update detail view
	if not collectionScreen then return end
	
	local detailContent = collectionScreen:FindFirstChild("DetailView", true)
	if not detailContent then return end
	
	detailContent = detailContent:FindFirstChild("Content")
	if not detailContent then return end
	
	-- Clear existing content
	for _, child in ipairs(detailContent:GetChildren()) do
		child:Destroy()
	end
	
	-- Create detail view
	-- Slime visual
	local slimeVisual = Instance.new("Frame")
	slimeVisual.Size = UDim2.fromOffset(100, 100)
	slimeVisual.Position = UDim2.fromScale(0.5, 0.18)
	slimeVisual.AnchorPoint = Vector2.new(0.5, 0.5)
	slimeVisual.BackgroundColor3 = ELEMENT_COLORS[slime.Element] or ELEMENT_COLORS.Normal
	slimeVisual.Parent = detailContent
	
	local visualCorner = Instance.new("UICorner")
	visualCorner.CornerRadius = UDim.new(1, 0)
	visualCorner.Parent = slimeVisual
	
	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromScale(1, 0)
	nameLabel.AutomaticSize = Enum.AutomaticSize.Y
	nameLabel.Position = UDim2.fromScale(0, 0.34)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 24
	nameLabel.Text = slime.Term
	nameLabel.Parent = detailContent
	
	-- Element and Role
	local typeLabel = Instance.new("TextLabel")
	typeLabel.Size = UDim2.fromScale(1, 0)
	typeLabel.AutomaticSize = Enum.AutomaticSize.Y
	typeLabel.Position = UDim2.fromScale(0, 0.42)
	typeLabel.BackgroundTransparency = 1
	typeLabel.TextColor3 = COLORS.TextDim
	typeLabel.Font = Enum.Font.Gotham
	typeLabel.TextSize = 14
	typeLabel.Text = slime.Element .. " " .. slime.Role
	typeLabel.Parent = detailContent
	
	-- Rarity
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.fromScale(1, 0)
	rarityLabel.AutomaticSize = Enum.AutomaticSize.Y
	typeLabel.Position = UDim2.fromScale(0, 0.48)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.TextColor3 = RARITY_COLORS[slime.Rarity] or COLORS.TextDim
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.TextSize = 16
	rarityLabel.Text = "★ " .. slime.Rarity .. " ★"
	rarityLabel.Parent = detailContent
	
	-- Level and XP
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.fromScale(1, 0)
	levelLabel.AutomaticSize = Enum.AutomaticSize.Y
	levelLabel.Position = UDim2.fromScale(0, 0.54)
	levelLabel.BackgroundTransparency = 1
	levelLabel.TextColor3 = COLORS.Text
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextSize = 14
	levelLabel.Text = "Level " .. slime.Level .. " (XP: " .. slime.XP .. ")"
	levelLabel.Parent = detailContent
	
	-- Stats
	local statsFrame = Instance.new("Frame")
	statsFrame.Size = UDim2.fromScale(1, 0.22)
	statsFrame.Position = UDim2.fromScale(0, 0.62)
	statsFrame.BackgroundTransparency = 1
	statsFrame.Parent = detailContent
	
	local stats = slime.Stats or {}
	local statList = {
		{ Name = "Logos (ATK)", Value = stats.Logos or 0, Color = Color3.fromHex("#EF4444") },
		{ Name = "Pathos (HP)", Value = stats.Pathos or 0, Color = Color3.fromHex("#22C55E") },
		{ Name = "Ethos (DEF)", Value = stats.Ethos or 0, Color = Color3.fromHex("#3B82F6") },
		{ Name = "Speed", Value = stats.Speed or 0, Color = Color3.fromHex("#F59E0B") },
	}
	
	for i, stat in ipairs(statList) do
		local statRow = Instance.new("Frame")
		statRow.Size = UDim2.fromScale(1, 0.25)
		statRow.Position = UDim2.fromScale(0, (i - 1) * 0.25)
		statRow.BackgroundTransparency = 1
		statRow.Parent = statsFrame
		
		local statName = Instance.new("TextLabel")
		statName.Size = UDim2.fromScale(0.5, 1)
		statName.BackgroundTransparency = 1
		statName.TextColor3 = COLORS.TextDim
		statName.Font = Enum.Font.Gotham
		statName.TextSize = 12
		statName.Text = stat.Name
		statName.TextXAlignment = Enum.TextXAlignment.Left
		statName.Parent = statRow
		
		local statValue = Instance.new("TextLabel")
		statValue.Size = UDim2.fromScale(0.5, 1)
		statValue.Position = UDim2.fromScale(0.5, 0)
		statValue.BackgroundTransparency = 1
		statValue.TextColor3 = stat.Color
		statValue.Font = Enum.Font.GothamBold
		statValue.TextSize = 14
		statValue.Text = tostring(stat.Value)
		statValue.TextXAlignment = Enum.TextXAlignment.Right
		statValue.Parent = statRow
	end
	
	-- Context Points
	local contextY = 0.84
	if slime.ContextPoints and slime.ContextPoints > 0 then
		local contextLabel = Instance.new("TextLabel")
		contextLabel.Size = UDim2.fromScale(1, 0)
		contextLabel.AutomaticSize = Enum.AutomaticSize.Y
		contextLabel.Position = UDim2.fromScale(0, 0.84)
		contextLabel.BackgroundTransparency = 1
		contextLabel.TextColor3 = COLORS.Accent
		contextLabel.Font = Enum.Font.Gotham
		contextLabel.TextSize = 12
		contextLabel.Text = "Context Points: " .. slime.ContextPoints
		contextLabel.Parent = detailContent
		contextY = 0.92
	end
	
	-- Evolve button
	local evolveBtn = Instance.new("TextButton")
	evolveBtn.Name = "EvolveBtn"
	evolveBtn.Size = UDim2.fromScale(1, 0.08)
	evolveBtn.Position = UDim2.fromScale(0, contextY)
	evolveBtn.BackgroundColor3 = COLORS.Border
	evolveBtn.TextColor3 = COLORS.Background
	evolveBtn.Font = Enum.Font.GothamBold
	evolveBtn.TextSize = 14
	evolveBtn.Text = "🧬 Evolve"
	evolveBtn.Parent = detailContent
	
	local evolveCorner = Instance.new("UICorner")
	evolveCorner.CornerRadius = UDim.new(0, 8)
	evolveCorner.Parent = evolveBtn
	
	evolveBtn.MouseButton1Click:Connect(function()
		local SlimeFactory = Knit.GetService("SlimeFactory")
		SlimeFactory:GetAvailableEvolutions(slime.InstanceId):andThen(function(evolutions)
			if #evolutions > 0 then
				local evo = evolutions[1] -- Just use first available for now
				if slime.XP >= evo.xpCost then
					SlimeFactory:EvolveSlime(slime.InstanceId, evo.type):andThen(function(newSlime)
						if newSlime then
							print("[SlimeCollectionUI] Evolved slime to " .. newSlime.Term)
							SlimeCollectionUI.SelectSlime(newSlime)
						end
					end):catch(warn)
				else
					evolveBtn.Text = "Not enough XP (" .. slime.XP .. "/" .. evo.xpCost .. ")"
					task.delay(2, function() evolveBtn.Text = "🧬 Evolve" end)
				end
			else
				evolveBtn.Text = "No Evolutions Available"
				task.delay(2, function() evolveBtn.Text = "🧬 Evolve" end)
			end
		end):catch(warn)
	end)

	-- Set as Companion button
	local companionBtn = Instance.new("TextButton")
	companionBtn.Name = "SetCompanionBtn"
	companionBtn.Size = UDim2.fromScale(1, 0.08)
	companionBtn.Position = UDim2.fromScale(0, contextY + 0.1)
	companionBtn.BackgroundColor3 = COLORS.Accent
	companionBtn.TextColor3 = COLORS.Text
	companionBtn.Font = Enum.Font.GothamBold
	companionBtn.TextSize = 14
	companionBtn.Text = "⭐ Set as Companion"
	companionBtn.Parent = detailContent
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = companionBtn
	
	-- Check if this slime is already the companion
	local DataService = Knit.GetService("DataService")
	DataService:GetProfile():andThen(function(profile)
		if profile and profile.CompanionSlimeId == slime.InstanceId then
			companionBtn.Text = "⭐ Current Companion"
			companionBtn.BackgroundColor3 = COLORS.Border
		end
	end):catch(warn)
	
	-- Button click handler
	companionBtn.MouseButton1Click:Connect(function()
		-- Call server to set companion
		local SlimeFactory = Knit.GetService("SlimeFactory")
		SlimeFactory:SetCompanion(slime.InstanceId):andThen(function(success)
			if success then
				companionBtn.Text = "⭐ Current Companion"
				companionBtn.BackgroundColor3 = COLORS.Border
				print("[SlimeCollectionUI] Set " .. slime.Term .. " as companion!")
			else
				warn("[SlimeCollectionUI] Failed to set companion")
			end
		end):catch(warn)
	end)
end

-- Initialize and connect to services
function SlimeCollectionUI.Initialize()
	-- Listen for new slimes
	local SlimeFactory = Knit.GetService("SlimeFactory")
	
	SlimeFactory.SlimeCreated:Connect(function(slime)
		if isOpen and collectionScreen then
			local gridContainer = collectionScreen:FindFirstChild("SlimeGrid", true)
			if gridContainer then
				SlimeCollectionUI.LoadSlimes(gridContainer)
			end
		end
	end)
	
	-- Keyboard shortcut
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.I then
			SlimeCollectionUI.Toggle()
		end
	end)
	
	print("[SlimeCollectionUI] Initialized")
end

return SlimeCollectionUI
