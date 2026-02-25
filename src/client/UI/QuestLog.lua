--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local QuestLog = {}
QuestLog.__index = QuestLog

-- State
local questContainer: Frame? = nil
local questEntries: { [string]: Frame } = {}

-- Colors
local COLORS = {
	Background = Color3.fromHex("#1E1B4B"),
	CardBg = Color3.fromHex("#312E81"),
	Accent = Color3.fromHex("#FCD34D"),
	Text = Color3.fromHex("#EEF2FF"),
	TextDim = Color3.fromHex("#A5B4FC"),
	Success = Color3.fromHex("#10B981"),
	Progress = Color3.fromHex("#4F46E5"),
}

function QuestLog.Create(): Frame
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Check if already exists
	local existing = playerGui:FindFirstChild("QuestLogUI")
	if existing then
		questContainer = existing:FindFirstChild("Container")
		return questContainer :: Frame
	end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestLogUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Main Container (Right side of screen)
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(300, 400)
	container.Position = UDim2.fromScale(1, 0.5)
	container.AnchorPoint = Vector2.new(1, 0.5)
	container.BackgroundColor3 = COLORS.Background
	container.BackgroundTransparency = 0.2
	container.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = container
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.Progress
	stroke.Thickness = 2
	stroke.Parent = container
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromScale(1, 0.1)
	title.Position = UDim2.fromScale(0, 0.02)
	title.BackgroundTransparency = 1
	title.TextColor3 = COLORS.Accent
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Text = "📜 Active Quests"
	title.Parent = container
	
	-- Quest List Container
	local listContainer = Instance.new("ScrollingFrame")
	listContainer.Name = "QuestList"
	listContainer.Size = UDim2.fromScale(0.95, 0.85)
	listContainer.Position = UDim2.fromScale(0.025, 0.12)
	listContainer.BackgroundTransparency = 1
	listContainer.ScrollBarThickness = 6
	listContainer.ScrollBarImageColor3 = COLORS.Progress
	listContainer.Parent = container
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = listContainer
	
	questContainer = listContainer
	return listContainer
end

function QuestLog.UpdateQuest(container: Frame, questData: any)
	if not container then return end
	
	local questId = questData.Id or questData.QuestId
	if not questId then return end
	
	-- Remove existing entry if updating
	if questEntries[questId] then
		questEntries[questId]:Destroy()
	end
	
	-- Create quest card
	local card = Instance.new("Frame")
	card.Name = "Quest_" .. questId
	card.Size = UDim2.fromScale(1, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = COLORS.CardBg
	card.BackgroundTransparency = 0.3
	card.Parent = container
	
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card
	
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = card
	
	-- Quest Title
	local questTitle = Instance.new("TextLabel")
	questTitle.Name = "Title"
	questTitle.Size = UDim2.fromScale(1, 0)
	questTitle.AutomaticSize = Enum.AutomaticSize.Y
	questTitle.BackgroundTransparency = 1
	questTitle.TextColor3 = COLORS.Text
	questTitle.Font = Enum.Font.GothamBold
	questTitle.TextSize = 16
	questTitle.TextWrapped = true
	questTitle.TextXAlignment = Enum.TextXAlignment.Left
	questTitle.Text = questData.Title or "Unknown Quest"
	questTitle.Parent = card
	
	-- Quest Description
	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.Size = UDim2.fromScale(1, 0)
	desc.AutomaticSize = Enum.AutomaticSize.Y
	desc.Position = UDim2.fromScale(0, 0.3)
	desc.BackgroundTransparency = 1
	desc.TextColor3 = COLORS.TextDim
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 12
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Text = questData.Description or ""
	desc.Parent = card
	
	-- Progress bar (if steps exist)
	if questData.Steps then
		local completedSteps = 0
		local totalSteps = 0
		
		if type(questData.Steps) == "table" then
			for _, step in pairs(questData.Steps) do
				totalSteps += 1
				if step.IsComplete then
					completedSteps += 1
				end
			end
		end
		
		if totalSteps > 0 then
			local progressBg = Instance.new("Frame")
			progressBg.Name = "ProgressBg"
			progressBg.Size = UDim2.fromScale(1, 8)
			progressBg.Position = UDim2.fromScale(0, 1)
			progressBg.AnchorPoint = Vector2.new(0, 1)
			progressBg.BackgroundColor3 = Color3.fromHex("#1F2937")
			progressBg.Parent = card
			
			local progressCorner = Instance.new("UICorner")
			progressCorner.CornerRadius = UDim.new(0, 4)
			progressCorner.Parent = progressBg
			
			local progressFill = Instance.new("Frame")
			progressFill.Name = "ProgressFill"
			progressFill.Size = UDim2.fromScale(completedSteps / totalSteps, 1)
			progressFill.BackgroundColor3 = COLORS.Success
			progressFill.Parent = progressBg
			
			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(0, 4)
			fillCorner.Parent = progressFill
			
			-- Progress text
			local progressText = Instance.new("TextLabel")
			progressText.Size = UDim2.fromScale(1, 0)
			progressText.AutomaticSize = Enum.AutomaticSize.Y
			progressText.Position = UDim2.fromScale(0, 1)
			progressText.BackgroundTransparency = 1
			progressText.TextColor3 = COLORS.TextDim
			progressText.Font = Enum.Font.Gotham
			progressText.TextSize = 10
			progressText.Text = completedSteps .. "/" .. totalSteps .. " steps"
			progressText.Parent = card
		end
	end
	
	-- Rewards preview
	if questData.Rewards then
		local rewardsText = Instance.new("TextLabel")
		rewardsText.Name = "Rewards"
		rewardsText.Size = UDim2.fromScale(1, 0)
		rewardsText.AutomaticSize = Enum.AutomaticSize.Y
		rewardsText.BackgroundTransparency = 1
		rewardsText.TextColor3 = COLORS.Accent
		rewardsText.Font = Enum.Font.Gotham
		rewardsText.TextSize = 11
		rewardsText.TextXAlignment = Enum.TextXAlignment.Left
		rewardsText.Text = "🎁 " .. (questData.Rewards.XP or 0) .. " XP, " .. (questData.Rewards.Insight or 0) .. " Insight"
		rewardsText.Parent = card
	end
	
	questEntries[questId] = card
	
	-- Animate in
	card.Size = UDim2.fromScale(0, 0)
	TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.fromScale(1, 0)
	}):Play()
end

function QuestLog.RemoveQuest(questId: string)
	if questEntries[questId] then
		questEntries[questId]:Destroy()
		questEntries[questId] = nil
	end
end

function QuestLog.ClearAll()
	for id, _ in pairs(questEntries) do
		if questEntries[id] then
			questEntries[id]:Destroy()
		end
	end
	questEntries = {}
end

return QuestLog