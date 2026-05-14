--!strict
local Players = game:GetService("Players")
local MarketPlaceService = game:GetService("MarketplaceService")

local StoreUI = {}

-- Style Constants
local COLORS = {
	Background = Color3.fromHex("#1e293b"), -- Slate 800
	Accent = Color3.fromHex("#facc15"), -- Yellow 400
	Text = Color3.fromHex("#f8fafc"), -- Slate 50
	Button = Color3.fromHex("#3b82f6"), -- Blue 500
	ButtonHover = Color3.fromHex("#2563eb"), -- Blue 600
}

function StoreUI.Create()
	-- Prevent duplicates
	if Players.LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("StoreUI") then
		return Players.LocalPlayer.PlayerGui.StoreUI, Players.LocalPlayer.PlayerGui.StoreUI.ShopFrame.ScrollingFrame
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "StoreUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- 1. Toggle Button (Bottom Left)
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Name = "ToggleShop"
	toggleBtn.Size = UDim2.new(0, 60, 0, 60)
	toggleBtn.Position = UDim2.new(0, 20, 1, -80)
	toggleBtn.BackgroundColor3 = COLORS.Accent
	toggleBtn.Text = "Shop"
	toggleBtn.TextColor3 = COLORS.Background
	toggleBtn.Font = Enum.Font.FredokaOne
	toggleBtn.TextSize = 20
	toggleBtn.Parent = gui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0) -- Circle
	corner.Parent = toggleBtn
	
	-- 2. Main Frame (Centered)
	local frame = Instance.new("Frame")
	frame.Name = "ShopFrame"
	frame.Size = UDim2.new(0, 600, 0, 400)
	frame.Position = UDim2.new(0.5, -300, 0.5, -200)
	frame.BackgroundColor3 = COLORS.Background
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = gui
	
	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 12)
	frameCorner.Parent = frame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Text = "Psychic Emporium"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.TextColor3 = COLORS.Accent
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 32
	title.Parent = frame
	
	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Text = "X"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.TextColor3 = Color3.new(1, 0.4, 0.4)
	closeBtn.Font = Enum.Font.FredokaOne
	closeBtn.TextSize = 24
	closeBtn.Parent = frame
	
	-- Items Container (Scrolling)
	local container = Instance.new("ScrollingFrame")
	container.Size = UDim2.new(1, -40, 1, -70)
	container.Position = UDim2.new(0, 20, 0, 60)
	container.BackgroundTransparency = 1
	container.ScrollBarThickness = 6
	container.Parent = frame
	
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 170, 0, 200)
	layout.CellPadding = UDim2.new(0, 15, 0, 15)
	layout.Parent = container
	
	-- Interactions
	toggleBtn.MouseButton1Click:Connect(function()
		frame.Visible = not frame.Visible
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
	end)

	return gui, container
end

-- Function to add an item card
function StoreUI.AddItem(container, id, name, price, type, callback)
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Color3.fromHex("#334155") -- Slate 700
	card.Parent = container
	
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = card
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0, 40)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = COLORS.Text
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextWrapped = true
	nameLabel.TextSize = 16
	nameLabel.Parent = card
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, -10, 0, 30)
	priceLabel.Position = UDim2.new(0, 5, 0, 45)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Text = (type == "GamePass" and "GP: " or "R$ ") .. price
	priceLabel.TextColor3 = COLORS.Accent
	priceLabel.Font = Enum.Font.Gotham
	priceLabel.TextSize = 14
	priceLabel.Parent = card

    -- Buy Button
    local buyBtn = Instance.new("TextButton")
    buyBtn.Size = UDim2.new(0.8, 0, 0, 35)
    buyBtn.Position = UDim2.new(0.1, 0, 1, -45)
    buyBtn.BackgroundColor3 = COLORS.Button
    buyBtn.Text = "Purchase"
    buyBtn.TextColor3 = Color3.new(1,1,1)
    buyBtn.Font = Enum.Font.GothamBold
    buyBtn.TextSize = 14
    buyBtn.Parent = card
    
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = buyBtn
    
    buyBtn.MouseButton1Click:Connect(function()
        callback(id)
    end)
    
    return card
end

function StoreUI.Initialize()
    print("[StoreUI] Initializing store UI...")
    
    -- StoreUI is ready to show store when needed
    -- No persistent UI elements needed for initialization
    
    print("[StoreUI] Store UI initialized")
end

return StoreUI
