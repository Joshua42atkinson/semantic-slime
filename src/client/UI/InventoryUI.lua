--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local InventoryUI = {}
InventoryUI.__index = InventoryUI

-- State
local inventoryScreen: ScreenGui? = nil
local isOpen = false
local inventoryData: { [string]: number } = {}

-- Colors
local COLORS = {
	Background = Color3.fromHex("#0F0E17"),
	CardBg = Color3.fromHex("#1A1A2E"),
	Accent = Color3.fromHex("#FF8906"),
	Text = Color3.fromHex("#FFFFFE"),
	TextDim = Color3.fromHex("#A7A9BE"),
	Success = Color3.fromHex("#2CB67D"),
}

-- Letter colors (by frequency/rarity)
local LETTER_COLORS: { [string]: Color3 } = {
	["E"] = Color3.fromRGB(255, 200, 200),  -- Most common
	["A"] = Color3.fromRGB(200, 255, 200),
	["I"] = Color3.fromRGB(200, 200, 255),
	["O"] = Color3.fromRGB(255, 255, 200),
	["N"] = Color3.fromRGB(255, 200, 255),
	["R"] = Color3.fromRGB(200, 255, 255),
	["T"] = Color3.fromRGB(255, 220, 180),
	["L"] = Color3.fromRGB(180, 255, 220),
	["S"] = Color3.fromRGB(220, 180, 255),
	["U"] = Color3.fromRGB(180, 220, 255),
}

function InventoryUI.Toggle()
	if isOpen then
		InventoryUI.Hide()
	else
		InventoryUI.Show()
	end
end

function InventoryUI.Show()
	if isOpen then return end
	isOpen = true
	
	-- Refresh inventory data
	InventoryUI.RefreshInventory()
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Create screen
	inventoryScreen = Instance.new("ScreenGui")
	inventoryScreen.Name = "InventoryUI"
	inventoryScreen.ResetOnSpawn = false
	inventoryScreen.IgnoreGuiInset = true
	inventoryScreen.Parent = playerGui
	
	-- Dark overlay
	local overlay = Instance.new("Frame")
	overlay.Name = "Overlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.5
	overlay.BorderSizePixel = 0
	overlay.Parent = inventoryScreen
	
	-- Main container
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(400, 300)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = COLORS.Background
	container.Parent = inventoryScreen
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 16)
	containerCorner.Parent = container
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.15)
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
	title.TextSize = 24
	title.Text = "📦 Letter Inventory"
	title.Parent = header
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.fromOffset(35, 35)
	closeBtn.Position = UDim2.fromScale(1, 0.5)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.BackgroundColor3 = Color3.fromHex("#EF4444")
	closeBtn.TextColor3 = COLORS.Text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 16
	closeBtn.Text = "X"
	closeBtn.Parent = header
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		InventoryUI.Hide()
	end)
	
	-- Letter grid
	local gridContainer = Instance.new("ScrollingFrame")
	gridContainer.Name = "LetterGrid"
	gridContainer.Size = UDim2.fromScale(0.9, 0.75)
	gridContainer.Position = UDim2.fromScale(0.5, 0.55)
	gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	gridContainer.BackgroundTransparency = 1
	gridContainer.ScrollBarThickness = 6
	gridContainer.ScrollBarImageColor3 = COLORS.Accent
	gridContainer.Parent = container
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.fromOffset(60, 60)
	gridLayout.CellPadding = UDim2.fromOffset(8, 8)
	gridLayout.Parent = gridContainer
	
	-- Populate letters
	InventoryUI.PopulateLetters(gridContainer)
	
	-- Entrance animation
	container.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(400, 300)
	}):Play()
	
	-- Keyboard input
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.B then
			InventoryUI.Hide()
		end
	end)
end

function InventoryUI.Hide()
	if not isOpen or not inventoryScreen then return end
	
	isOpen = false
	
	-- Animate out
	local container = inventoryScreen:FindFirstChild("Container")
	if container then
		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.fromOffset(0, 0)
		}):Play()
	end
	
	task.wait(0.35)
	if inventoryScreen then
		inventoryScreen:Destroy()
		inventoryScreen = nil
	end
end

function InventoryUI.RefreshInventory()
	-- Get inventory from CrystalCollector
	local CrystalCollector = Knit.GetController("CrystalCollector")
	if CrystalCollector and CrystalCollector.GetInventory then
		inventoryData = CrystalCollector:GetInventory()
	else
		-- Fallback: empty inventory
		inventoryData = {}
	end
end

function InventoryUI.PopulateLetters(gridContainer: ScrollingFrame)
	-- Clear existing
	for _, child in ipairs(gridContainer:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Show letters we have
	for letter, count in pairs(inventoryData) do
		if count > 0 then
			local letterCard = Instance.new("Frame")
			letterCard.Size = UDim2.fromOffset(60, 60)
			letterCard.BackgroundColor3 = COLORS.CardBg
			letterCard.Parent = gridContainer
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = letterCard
			
			-- Letter color border
			local border = Instance.new("UIStroke")
			border.Color = LETTER_COLORS[letter] or COLORS.Accent
			border.Thickness = 2
			border.Parent = letterCard
			
			-- Letter
			local letterLabel = Instance.new("TextLabel")
			letterLabel.Size = UDim2.fromScale(0.6, 0.6)
			letterLabel.Position = UDim2.fromScale(0.5, 0.35)
			letterLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			letterLabel.BackgroundTransparency = 1
			letterLabel.TextColor3 = LETTER_COLORS[letter] or COLORS.Text
			letterLabel.Font = Enum.Font.GothamBold
			letterLabel.TextSize = 28
			letterLabel.Text = letter
			letterLabel.Parent = letterCard
			
			-- Count
			local countLabel = Instance.new("TextLabel")
			countLabel.Size = UDim2.fromScale(1, 0.3)
			countLabel.Position = UDim2.fromScale(0, 0.7)
			countLabel.BackgroundTransparency = 1
			countLabel.TextColor3 = COLORS.TextDim
			countLabel.Font = Enum.Font.Gotham
			countLabel.TextSize = 12
			countLabel.Text = "x" .. count
			countLabel.Parent = letterCard
		end
	end
	
	-- Show empty state if no letters
	local totalLetters = 0
	for _, count in pairs(inventoryData) do
		totalLetters += count
	end
	
	if totalLetters == 0 then
		local emptyLabel = Instance.new("TextLabel")
		emptyLabel.Size = UDim2.fromScale(1, 1)
		emptyLabel.BackgroundTransparency = 1
		emptyLabel.TextColor3 = COLORS.TextDim
		emptyLabel.Font = Enum.Font.Gotham
		emptyLabel.TextSize = 16
		emptyLabel.Text = "No letters yet!\n\nWalk near letter crystals\nto collect them."
		emptyLabel.TextWrapped = true
		emptyLabel.Parent = gridContainer
	end
end

-- Initialize
function InventoryUI.Initialize()
	-- Listen for inventory updates
	local CrystalService = Knit.GetService("CrystalService")
	CrystalService.Client.CrystalCollected:Connect(function(player, letter, rarity)
		-- Refresh if it's our player
		if player == Players.LocalPlayer then
			InventoryUI.RefreshInventory()
			if isOpen and inventoryScreen then
				local gridContainer = inventoryScreen:FindFirstChild("LetterGrid", true)
				if gridContainer then
					InventoryUI.PopulateLetters(gridContainer)
				end
			end
		end
	end)
	
	print("[InventoryUI] Initialized")
end

return InventoryUI
