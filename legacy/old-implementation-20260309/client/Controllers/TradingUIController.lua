--!strict
-- Trading UI Controller for Semantic Slime
-- Educational trading interface with auction house and market

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TradingUIController = Knit.CreateController { Name = "TradingUIController" }

-- Configuration
local UI_ANIMATION_DURATION = 0.3
local MAX_TRADE_ITEMS = 8
local MAX_AUCTION_DISPLAY = 20
local MAX_MARKET_DISPLAY = 20

-- State
local isOpen = false
local currentTab = "Trade"
local selectedTradeItems = {}
local currentAuctions = {}
local currentMarketListings = {}
local playerEconomy = nil
local tradingUI: ScreenGui? = nil

-- UI References
local mainFrame: Frame? = nil
local tabButtons: {[string]: TextButton} = {}
local contentFrames: {[string]: Frame} = {}
local tradeOfferFrame: Frame? = nil
local auctionFrame: Frame? = nil
local marketFrame: Frame? = nil
local economyFrame: Frame? = nil

-- Services
local TradingService: any = nil
local SoundEffects: any = nil

-- Private functions
local function createTradingUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main GUI container
    tradingUI = Instance.new("ScreenGui")
    tradingUI.Name = "TradingUI"
    tradingUI.ResetOnSpawn = false
    tradingUI.Parent = playerGui
    
    -- Main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.9, 0, 0.9, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.05, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.Parent = tradingUI
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 15)
    mainCorner.Parent = mainFrame
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(100, 150, 200)
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.3
    mainStroke.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, -40, 0, 60)
    header.Position = UDim2.fromOffset(20, 20)
    header.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.fromOffset(20, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 24
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🤝 Educational Trading Hub"
    titleLabel.Parent = header
    
    -- Economy display
    local economyDisplay = Instance.new("Frame")
    economyDisplay.Name = "EconomyDisplay"
    economyDisplay.Size = UDim2.fromOffset(100, 40)
    economyDisplay.Position = UDim2.new(1, -120, 0, 10)
    economyDisplay.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    economyDisplay.BorderSizePixel = 0
    economyDisplay.Parent = header
    
    local economyCorner = Instance.new("UICorner")
    economyCorner.CornerRadius = UDim.new(0, 8)
    economyCorner.Parent = economyDisplay
    
    local economyLabel = Instance.new("TextLabel")
    economyLabel.Name = "EconomyLabel"
    economyLabel.Size = UDim2.new(1, -10, 1, 0)
    economyLabel.Position = UDim2.fromOffset(5, 0)
    economyLabel.BackgroundTransparency = 1
    economyLabel.TextColor3 = Color3.new(1, 1, 1)
    economyLabel.Font = Enum.Font.GothamBold
    economyLabel.TextSize = 14
    economyLabel.Text = "📚 0 KP"
    economyLabel.Parent = economyDisplay
    
    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.fromOffset(40, 40)
    closeButton.Position = UDim2.new(1, -50, 0, 10)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "✕"
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 20
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Tab navigation
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, -40, 0, 50)
    tabContainer.Position = UDim2.fromOffset(20, 90)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainFrame
    
    -- Create tab buttons
    local tabs = {"Trade", "Auction", "Market", "Economy"}
    local tabWidth = 1 / #tabs
    
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName .. "Tab"
        tabButton.Size = UDim2.new(tabWidth, -10, 1, 0)
        tabButton.Position = UDim2.new((i - 1) * tabWidth, 5, 0, 0)
        tabButton.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 16
        tabButton.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        tabButtons[tabName] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
    end
    
    -- Content area
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "ContentContainer"
    contentContainer.Size = UDim2.new(1, -40, 1, -170)
    contentContainer.Position = UDim2.fromOffset(20, 170)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Create content frames for each tab
    createTradeContent(contentContainer)
    createAuctionContent(contentContainer)
    createMarketContent(contentContainer)
    createEconomyContent(contentContainer)
    
    -- Initially show Trade tab
    self:SwitchTab("Trade")
end

local function createTradeContent(parent: Frame)
    local tradeFrame = Instance.new("Frame")
    tradeFrame.Name = "TradeContent"
    tradeFrame.Size = UDim2.new(1, 0, 1, 0)
    tradeFrame.BackgroundTransparency = 1
    tradeFrame.Visible = false
    tradeFrame.Parent = parent
    
    -- Trade offer section
    tradeOfferFrame = Instance.new("Frame")
    tradeOfferFrame.Name = "TradeOffer"
    tradeOfferFrame.Size = UDim2.new(0.5, -10, 1, 0)
    tradeOfferFrame.Position = UDim2.fromOffset(0, 0)
    tradeOfferFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    tradeOfferFrame.BorderSizePixel = 0
    tradeOfferFrame.Parent = tradeFrame
    
    local offerCorner = Instance.new("UICorner")
    offerCorner.CornerRadius = UDim.new(0, 10)
    offerCorner.Parent = tradeOfferFrame
    
    -- Offer title
    local offerTitle = Instance.new("TextLabel")
    offerTitle.Name = "OfferTitle"
    offerTitle.Size = UDim2.new(1, -20, 0, 30)
    offerTitle.Position = UDim2.fromOffset(10, 10)
    offerTitle.BackgroundTransparency = 1
    offerTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    offerTitle.Font = Enum.Font.GothamBold
    offerTitle.TextSize = 18
    offerTitle.TextXAlignment = Enum.TextXAlignment.Left
    offerTitle.Text = "Your Offer"
    offerTitle.Parent = tradeOfferFrame
    
    -- Offer items list
    local offerList = Instance.new("ScrollingFrame")
    offerList.Name = "OfferList"
    offerList.Size = UDim2.new(1, -20, 0, 200)
    offerList.Position = UDim2.fromOffset(10, 50)
    offerList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    offerList.BorderSizePixel = 0
    offerList.Parent = tradeOfferFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 8)
    listCorner.Parent = offerList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = offerList
    
    -- Add item button
    local addItemButton = Instance.new("TextButton")
    addItemButton.Name = "AddItemButton"
    addItemButton.Size = UDim2.new(1, -20, 0, 40)
    addItemButton.Position = UDim2.fromOffset(10, 260)
    addItemButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    addItemButton.BorderSizePixel = 0
    addItemButton.Text = "+ Add Item to Offer"
    addItemButton.TextColor3 = Color3.new(1, 1, 1)
    addItemButton.Font = Enum.Font.GothamBold
    addItemButton.TextSize = 16
    addItemButton.Parent = tradeOfferFrame
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 8)
    addCorner.Parent = addItemButton
    
    addItemButton.MouseButton1Click:Connect(function()
        self:ShowAddItemDialog()
    end)
    
    -- Trade requests section
    local requestsFrame = Instance.new("Frame")
    requestsFrame.Name = "TradeRequests"
    requestsFrame.Size = UDim2.new(0.5, -10, 1, 0)
    requestsFrame.Position = UDim2.new(0.5, 10, 0, 0)
    requestsFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    requestsFrame.BorderSizePixel = 0
    requestsFrame.Parent = tradeFrame
    
    local requestsCorner = Instance.new("UICorner")
    requestsCorner.CornerRadius = UDim.new(0, 10)
    requestsCorner.Parent = requestsFrame
    
    -- Requests title
    local requestsTitle = Instance.new("TextLabel")
    requestsTitle.Name = "RequestsTitle"
    requestsTitle.Size = UDim2.new(1, -20, 0, 30)
    requestsTitle.Position = UDim2.fromOffset(10, 10)
    requestsTitle.BackgroundTransparency = 1
    requestsTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    requestsTitle.Font = Enum.Font.GothamBold
    requestsTitle.TextSize = 18
    requestsTitle.TextXAlignment = Enum.TextXAlignment.Left
    requestsTitle.Text = "Trade Requests"
    requestsTitle.Parent = requestsFrame
    
    -- Requests list
    local requestsList = Instance.new("ScrollingFrame")
    requestsList.Name = "RequestsList"
    requestsList.Size = UDim2.new(1, -20, 1, -50)
    requestsList.Position = UDim2.fromOffset(10, 50)
    requestsList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    requestsList.BorderSizePixel = 0
    requestsList.Parent = requestsFrame
    
    local requestsListCorner = Instance.new("UICorner")
    requestsListCorner.CornerRadius = UDim.new(0, 8)
    requestsListCorner.Parent = requestsList
    
    local requestsListLayout = Instance.new("UIListLayout")
    requestsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    requestsListLayout.Padding = UDim.new(0, 5)
    requestsListLayout.Parent = requestsList
    
    contentFrames["Trade"] = tradeFrame
end

local function createAuctionContent(parent: Frame)
    local auctionFrame = Instance.new("Frame")
    auctionFrame.Name = "AuctionContent"
    auctionFrame.Size = UDim2.new(1, 0, 1, 0)
    auctionFrame.BackgroundTransparency = 1
    auctionFrame.Visible = false
    auctionFrame.Parent = parent
    
    -- Create auction section
    local createSection = Instance.new("Frame")
    createSection.Name = "CreateSection"
    createSection.Size = UDim2.new(0.4, -10, 0, 200)
    createSection.Position = UDim2.fromOffset(0, 0)
    createSection.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    createSection.BorderSizePixel = 0
    createSection.Parent = auctionFrame
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 10)
    createCorner.Parent = createSection
    
    -- Create auction title
    local createTitle = Instance.new("TextLabel")
    createTitle.Name = "CreateTitle"
    createTitle.Size = UDim2.new(1, -20, 0, 30)
    createTitle.Position = UDim2.fromOffset(10, 10)
    createTitle.BackgroundTransparency = 1
    createTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    createTitle.Font = Enum.Font.GothamBold
    createTitle.TextSize = 18
    createTitle.TextXAlignment = Enum.TextXAlignment.Left
    createTitle.Text = "Create Auction"
    createTitle.Parent = createSection
    
    -- Active auctions section
    local activeSection = Instance.new("Frame")
    activeSection.Name = "ActiveSection"
    activeSection.Size = UDim2.new(0.6, -10, 1, 0)
    activeSection.Position = UDim2.new(0.4, 10, 0, 0)
    activeSection.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    activeSection.BorderSizePixel = 0
    activeSection.Parent = auctionFrame
    
    local activeCorner = Instance.new("UICorner")
    activeCorner.CornerRadius = UDim.new(0, 10)
    activeCorner.Parent = activeSection
    
    -- Active auctions title
    local activeTitle = Instance.new("TextLabel")
    activeTitle.Name = "ActiveTitle"
    activeTitle.Size = UDim2.new(1, -20, 0, 30)
    activeTitle.Position = UDim2.fromOffset(10, 10)
    activeTitle.BackgroundTransparency = 1
    activeTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    activeTitle.Font = Enum.Font.GothamBold
    activeTitle.TextSize = 18
    activeTitle.TextXAlignment = Enum.TextXAlignment.Left
    activeTitle.Text = "Active Auctions"
    activeTitle.Parent = activeSection
    
    -- Active auctions list
    local activeList = Instance.new("ScrollingFrame")
    activeList.Name = "ActiveList"
    activeList.Size = UDim2.new(1, -20, 1, -50)
    activeList.Position = UDim2.fromOffset(10, 50)
    activeList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    activeList.BorderSizePixel = 0
    activeList.Parent = activeSection
    
    local activeListCorner = Instance.new("UICorner")
    activeListCorner.CornerRadius = UDim.new(0, 8)
    activeListCorner.Parent = activeList
    
    local activeListLayout = Instance.new("UIListLayout")
    activeListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    activeListLayout.Padding = UDim.new(0, 5)
    activeListLayout.Parent = activeList
    
    auctionFrame = auctionFrame
    contentFrames["Auction"] = auctionFrame
end

local function createMarketContent(parent: Frame)
    local marketFrame = Instance.new("Frame")
    marketFrame.Name = "MarketContent"
    marketFrame.Size = UDim2.new(1, 0, 1, 0)
    marketFrame.BackgroundTransparency = 1
    marketFrame.Visible = false
    marketFrame.Parent = parent
    
    -- Create listing section
    local createSection = Instance.new("Frame")
    createSection.Name = "CreateSection"
    createSection.Size = UDim2.new(0.4, -10, 0, 200)
    createSection.Position = UDim2.fromOffset(0, 0)
    createSection.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    createSection.BorderSizePixel = 0
    createSection.Parent = marketFrame
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 10)
    createCorner.Parent = createSection
    
    -- Create listing title
    local createTitle = Instance.new("TextLabel")
    createTitle.Name = "CreateTitle"
    createTitle.Size = UDim2.new(1, -20, 0, 30)
    createTitle.Position = UDim2.fromOffset(10, 10)
    createTitle.BackgroundTransparency = 1
    createTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    createTitle.Font = Enum.Font.GothamBold
    createTitle.TextSize = 18
    createTitle.TextXAlignment = Enum.TextXAlignment.Left
    createTitle.Text = "Create Listing"
    createTitle.Parent = createSection
    
    -- Market listings section
    local listingsSection = Instance.new("Frame")
    listingsSection.Name = "ListingsSection"
    listingsSection.Size = UDim2.new(0.6, -10, 1, 0)
    listingsSection.Position = UDim2.new(0.4, 10, 0, 0)
    listingsSection.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    listingsSection.BorderSizePixel = 0
    listingsSection.Parent = marketFrame
    
    local listingsCorner = Instance.new("UICorner")
    listingsCorner.CornerRadius = UDim.new(0, 10)
    listingsCorner.Parent = listingsSection
    
    -- Listings title
    local listingsTitle = Instance.new("TextLabel")
    listingsTitle.Name = "ListingsTitle"
    listingsTitle.Size = UDim2.new(1, -20, 0, 30)
    listingsTitle.Position = UDim2.fromOffset(10, 10)
    listingsTitle.BackgroundTransparency = 1
    listingsTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    listingsTitle.Font = Enum.Font.GothamBold
    listingsTitle.TextSize = 18
    listingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    listingsTitle.Text = "Market Listings"
    listingsTitle.Parent = listingsSection
    
    -- Listings list
    local listingsList = Instance.new("ScrollingFrame")
    listingsList.Name = "ListingsList"
    listingsList.Size = UDim2.new(1, -20, 1, -50)
    listingsList.Position = UDim2.fromOffset(10, 50)
    listingsList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    listingsList.BorderSizePixel = 0
    listingsList.Parent = listingsSection
    
    local listingsListCorner = Instance.new("UICorner")
    listingsListCorner.CornerRadius = UDim.new(0, 8)
    listingsListCorner.Parent = listingsList
    
    local listingsListLayout = Instance.new("UIListLayout")
    listingsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listingsListLayout.Padding = UDim.new(0, 5)
    listingsListLayout.Parent = listingsList
    
    marketFrame = marketFrame
    contentFrames["Market"] = marketFrame
end

local function createEconomyContent(parent: Frame)
    local economyFrame = Instance.new("Frame")
    economyFrame.Name = "EconomyContent"
    economyFrame.Size = UDim2.new(1, 0, 1, 0)
    economyFrame.BackgroundTransparency = 1
    economyFrame.Visible = false
    economyFrame.Parent = parent
    
    -- Economy overview
    local overviewFrame = Instance.new("Frame")
    overviewFrame.Name = "OverviewFrame"
    overviewFrame.Size = UDim2.new(1, -20, 0, 150)
    overviewFrame.Position = UDim2.fromOffset(10, 10)
    overviewFrame.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    overviewFrame.BorderSizePixel = 0
    overviewFrame.Parent = economyFrame
    
    local overviewCorner = Instance.new("UICorner")
    overviewCorner.CornerRadius = UDim.new(0, 10)
    overviewCorner.Parent = overviewFrame
    
    -- Overview title
    local overviewTitle = Instance.new("TextLabel")
    overviewTitle.Name = "OverviewTitle"
    overviewTitle.Size = UDim2.new(1, -20, 0, 30)
    overviewTitle.Position = UDim2.fromOffset(10, 10)
    overviewTitle.BackgroundTransparency = 1
    overviewTitle.TextColor3 = Color3.fromRGB(255, 220, 100)
    overviewTitle.Font = Enum.Font.GothamBold
    overviewTitle.TextSize = 18
    overviewTitle.TextXAlignment = Enum.TextXAlignment.Left
    overviewTitle.Text = "Economy Overview"
    overviewTitle.Parent = overviewFrame
    
    -- Statistics section
    local statsFrame = Instance.new("Frame")
    statsFrame.Name = "StatsFrame"
    statsFrame.Size = UDim2.new(1, -20, 1, -170)
    statsFrame.Position = UDim2.fromOffset(10, 170)
    statsFrame.BackgroundTransparency = 1
    statsFrame.Parent = economyFrame
    
    local statsLayout = Instance.new("UIListLayout")
    statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    statsLayout.Padding = UDim.new(0, 10)
    statsLayout.Parent = statsFrame
    
    economyFrame = economyFrame
    contentFrames["Economy"] = economyFrame
end

-- Public methods
function TradingUIController:Show()
    if not tradingUI then
        createTradingUI()
    end
    
    isOpen = true
    
    -- Load player economy
    if TradingService then
        local player = Players.LocalPlayer
        playerEconomy = TradingService:GetPlayerEconomy(player.UserId)
        
        if playerEconomy then
            updateEconomyDisplay()
        end
        
        -- Load market data
        refreshMarketData()
    end
    
    -- Animate in
    local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    })
    fadeIn:Play()
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function TradingUIController:Hide()
    if not tradingUI or not isOpen then return end
    
    isOpen = false
    
    -- Animate out
    local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    
    fadeOut.Completed:Connect(function()
        if tradingUI then
            tradingUI.Parent = nil
        end
    end)
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function TradingUIController:SwitchTab(tabName: string)
    currentTab = tabName
    
    -- Update tab button appearances
    for name, button in pairs(tabButtons) do
        if name == tabName then
            button.BackgroundColor3 = Color3.fromRGB(70, 80, 100)
            button.TextColor3 = Color3.new(1, 1, 1)
        else
            button.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    
    -- Show/hide content frames
    for name, frame in pairs(contentFrames) do
        frame.Visible = (name == tabName)
    end
    
    if SoundEffects then
        SoundEffects.Play("UIToggle")
    end
end

function TradingUIController:ShowAddItemDialog()
    print("[TradingUIController] Add item dialog (to be implemented)")
end

function TradingUIController:ShowCreateAuctionDialog()
    print("[TradingUIController] Create auction dialog (to be implemented)")
end

function TradingUIController:ShowCreateListingDialog()
    print("[TradingUIController] Create listing dialog (to be implemented)")
end

-- Private helper functions
function updateEconomyDisplay()
    if not playerEconomy or not tradingUI then return end
    
    local economyDisplay = tradingUI.Header:FindFirstChild("EconomyDisplay")
    if economyDisplay then
        local economyLabel = economyDisplay:FindFirstChild("EconomyLabel")
        if economyLabel then
            economyLabel.Text = "📚 " .. playerEconomy.KnowledgePoints .. " KP"
        end
    end
end

function refreshMarketData()
    if not TradingService then return end
    
    -- Load active auctions
    currentAuctions = TradingService:GetActiveAuctions()
    
    -- Load market listings
    currentMarketListings = TradingService:GetMarketListings()
    
    -- Update UI
    updateAuctionDisplay()
    updateMarketDisplay()
end

function updateAuctionDisplay()
    if not auctionFrame then return end
    
    local activeList = auctionFrame:FindFirstChild("ActiveSection"):FindFirstChild("ActiveList")
    if not activeList then return end
    
    -- Clear existing items
    for _, child in ipairs(activeList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add auction items
    for i, auction in ipairs(currentAuctions) do
        if i > MAX_AUCTION_DISPLAY then break end
        
        createAuctionItem(activeList, auction)
    end
end

function updateMarketDisplay()
    if not marketFrame then return end
    
    local listingsList = marketFrame:FindFirstChild("ListingsSection"):FindFirstChild("ListingsList")
    if not listingsList then return end
    
    -- Clear existing items
    for _, child in ipairs(listingsList:GetChildren()) do
        child:Destroy()
    end
    
    -- Add market items
    for i, listing in ipairs(currentMarketListings) do
        if i > MAX_MARKET_DISPLAY then break end
        
        createMarketItem(listingsList, listing)
    end
end

function createAuctionItem(parent: ScrollingFrame, auction: any)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = "AuctionItem"
    itemFrame.Size = UDim2.new(1, -10, 0, 80)
    itemFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    itemFrame.BorderSizePixel = 0
    itemFrame.Parent = parent
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = itemFrame
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemName"
    nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
    nameLabel.Position = UDim2.fromOffset(10, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = auction.Item.Name
    nameLabel.Parent = itemFrame
    
    -- Current bid
    local bidLabel = Instance.new("TextLabel")
    bidLabel.Name = "CurrentBid"
    bidLabel.Size = UDim2.new(0.4, -10, 0, 25)
    bidLabel.Position = UDim2.new(0.6, 10, 5, 0)
    bidLabel.BackgroundTransparency = 1
    bidLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    bidLabel.Font = Enum.Font.GothamBold
    bidLabel.TextSize = 14
    bidLabel.TextXAlignment = Enum.TextXAlignment.Right
    bidLabel.Text = "📚 " .. auction.CurrentBid .. " KP"
    bidLabel.Parent = itemFrame
    
    -- Time remaining
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeRemaining"
    timeLabel.Size = UDim2.new(1, -20, 0, 20)
    timeLabel.Position = UDim2.fromOffset(10, 30)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 12
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Text = "⏰ " .. math.max(0, auction.EndTime - os.time()) .. "s remaining"
    timeLabel.Parent = itemFrame
    
    -- Bid button
    local bidButton = Instance.new("TextButton")
    bidButton.Name = "BidButton"
    bidButton.Size = UDim2.fromOffset(80, 30)
    bidButton.Position = UDim2.new(1, -90, 0.5, -15)
    bidButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    bidButton.BorderSizePixel = 0
    bidButton.Text = "Bid"
    bidButton.TextColor3 = Color3.new(1, 1, 1)
    bidButton.Font = Enum.Font.GothamBold
    bidButton.TextSize = 12
    bidButton.Parent = itemFrame
    
    local bidCorner = Instance.new("UICorner")
    bidCorner.CornerRadius = UDim.new(0, 6)
    bidCorner.Parent = bidButton
    
    bidButton.MouseButton1Click:Connect(function()
        self:ShowBidDialog(auction)
    end)
end

function createMarketItem(parent: ScrollingFrame, listing: any)
    local itemFrame = Instance.new("Frame")
    itemFrame.Name = "MarketItem"
    itemFrame.Size = UDim2.new(1, -10, 0, 60)
    itemFrame.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    itemFrame.BorderSizePixel = 0
    itemFrame.Parent = parent
    
    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = itemFrame
    
    -- Item name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "ItemName"
    nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
    nameLabel.Position = UDim2.fromOffset(10, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextYAlignment = Enum.TextYAlignment.Center
    nameLabel.Text = listing.Item.Name
    nameLabel.Parent = itemFrame
    
    -- Price
    local priceLabel = Instance.new("TextLabel")
    priceLabel.Name = "Price"
    priceLabel.Size = UDim2.fromOffset(100, 20)
    priceLabel.Position = UDim2.new(1, -110, 0.5, -10)
    priceLabel.BackgroundTransparency = 1
    priceLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    priceLabel.Font = Enum.Font.GothamBold
    priceLabel.TextSize = 14
    priceLabel.TextXAlignment = Enum.TextXAlignment.Right
    priceLabel.TextYAlignment = Enum.TextYAlignment.Center
    priceLabel.Text = "📚 " .. listing.Price .. " KP"
    priceLabel.Parent = itemFrame
    
    -- Buy button
    local buyButton = Instance.new("TextButton")
    buyButton.Name = "BuyButton"
    buyButton.Size = UDim2.fromOffset(60, 30)
    buyButton.Position = UDim2.new(1, -50, 0.5, -15)
    buyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    buyButton.BorderSizePixel = 0
    buyButton.Text = "Buy"
    buyButton.TextColor3 = Color3.new(1, 1, 1)
    buyButton.Font = Enum.Font.GothamBold
    buyButton.TextSize = 12
    buyButton.Parent = itemFrame
    
    local buyCorner = Instance.new("UICorner")
    buyCorner.CornerRadius = UDim.new(0, 6)
    buyCorner.Parent = buyButton
    
    buyButton.MouseButton1Click:Connect(function()
        if TradingService then
            TradingService:BuyFromMarket(listing.Id)
        end
    end)
end

function TradingUIController:ShowBidDialog(auction: any)
    print("[TradingUIController] Bid dialog for", auction.Item.Name, "(to be implemented)")
end

-- Service lifecycle
function TradingUIController:KnitStart()
    print("[TradingUIController] Starting educational trading UI...")
    
    -- Get services
    local success, service = pcall(function()
        return Knit.GetService("TradingService")
    end)
    
    if success then
        TradingService = service
        
        -- Connect to trading events
        TradingService.TradeRequestReceived:Connect(function(trade)
            print("[TradingUIController] Trade request received")
            -- Update UI with new trade request
        end)
        
        TradingService.TradeCompleted:Connect(function(trade)
            print("[TradingUIController] Trade completed")
            -- Update UI and refresh economy
            if playerEconomy then
                playerEconomy = TradingService:GetPlayerEconomy(Players.LocalPlayer.UserId)
                updateEconomyDisplay()
            end
        end)
        
        TradingService.AuctionCreated:Connect(function(auction)
            print("[TradingUIController] New auction created")
            refreshMarketData()
        end)
        
        TradingService.AuctionBid:Connect(function(auction, bid)
            print("[TradingUIController] New bid placed")
            updateAuctionDisplay()
        end)
        
        TradingService.MarketItemListed:Connect(function(listing)
            print("[TradingUIController] New market listing")
            refreshMarketData()
        end)
        
        TradingService.MarketItemSold:Connect(function(listing)
            print("[TradingUIController] Market item sold")
            refreshMarketData()
        end)
    else
        warn("[TradingUIController] TradingService not available")
    end
    
    -- Get sound effects
    success, service = pcall(function()
        return require(ReplicatedStorage.Shared.SoundEffects)
    end)
    
    if success then
        SoundEffects = service
    end
    
    print("[TradingUIController] Educational trading UI started.")
end

function TradingUIController:KnitStop()
    self:Hide()
    print("[TradingUIController] Educational trading UI stopped.")
end

return TradingUIController
