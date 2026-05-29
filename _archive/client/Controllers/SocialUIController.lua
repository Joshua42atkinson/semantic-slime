--!strict
-- Social UI Controller for Semantic Slime
-- Manages all social interface elements and interactions

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local SocialUIController = Knit.CreateController { Name = "SocialUIController" }

-- Configuration
local UI_ANIMATION_DURATION = 0.3
local MAX_MESSAGE_LENGTH = 200
local MAX_OFFLINE_FRIENDS = 50
local CHAT_MESSAGE_COOLDOWN = 1

-- State
local isOpen = false
local currentTab = "Friends"
local selectedFriend = nil
local selectedGuild = nil
local activeTrade = nil
local lastMessageTime = 0

-- UI References
local socialUI: ScreenGui? = nil
local mainFrame: Frame? = nil
local tabButtons: {[string]: TextButton} = {}
local contentFrames: {[string]: Frame} = {}
local chatInput: TextBox? = nil
local messageList: ScrollingFrame? = nil
local friendList: ScrollingFrame? = nil
local guildList: ScrollingFrame? = nil

-- Services
local SocialService: any = nil
local SoundEffects: any = nil

-- Private functions
local function createSocialUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main GUI container
    socialUI = Instance.new("ScreenGui")
    socialUI.Name = "SocialUI"
    socialUI.ResetOnSpawn = false
    socialUI.Parent = playerGui
    
    -- Main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.8, 0, 0.8, 0)
    mainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 30, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.Parent = socialUI
    
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
    header.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
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
    titleLabel.Text = "🤝 Social Hub"
    titleLabel.Parent = header
    
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
    local tabs = {"Friends", "Guild", "Chat", "Trade"}
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
    contentContainer.Position = UDim2.fromOffset(20, 160)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = mainFrame
    
    -- Create content frames for each tab
    createFriendsContent(contentContainer)
    createGuildContent(contentContainer)
    createChatContent(contentContainer)
    createTradeContent(contentContainer)
    
    -- Initially hide all content except Friends
    self:SwitchTab("Friends")
end

local function createFriendsContent(parent: Frame)
    local friendsFrame = Instance.new("Frame")
    friendsFrame.Name = "FriendsContent"
    friendsFrame.Size = UDim2.new(1, 0, 1, 0)
    friendsFrame.BackgroundTransparency = 1
    friendsFrame.Visible = false
    friendsFrame.Parent = parent
    
    -- Friend list
    friendList = Instance.new("ScrollingFrame")
    friendList.Name = "FriendList"
    friendList.Size = UDim2.new(0.6, -10, 0.8, 0)
    friendList.Position = UDim2.fromOffset(0, 0)
    friendList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    friendList.BorderSizePixel = 0
    friendList.Parent = friendsFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = friendList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = friendList
    
    -- Friend details panel
    local detailsPanel = Instance.new("Frame")
    detailsPanel.Name = "DetailsPanel"
    detailsPanel.Size = UDim2.new(0.4, -10, 0.8, 0)
    detailsPanel.Position = UDim2.new(0.6, 10, 0, 0)
    detailsPanel.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    detailsPanel.BorderSizePixel = 0
    detailsPanel.Parent = friendsFrame
    
    local detailsCorner = Instance.new("UICorner")
    detailsCorner.CornerRadius = UDim.new(0, 10)
    detailsCorner.Parent = detailsPanel
    
    -- Add friend button
    local addFriendButton = Instance.new("TextButton")
    addFriendButton.Name = "AddFriendButton"
    addFriendButton.Size = UDim2.new(1, -20, 0, 40)
    addFriendButton.Position = UDim2.fromOffset(10, 10)
    addFriendButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    addFriendButton.BorderSizePixel = 0
    addFriendButton.Text = "+ Add Friend"
    addFriendButton.TextColor3 = Color3.new(1, 1, 1)
    addFriendButton.Font = Enum.Font.GothamBold
    addFriendButton.TextSize = 16
    addFriendButton.Parent = friendsFrame
    
    local addCorner = Instance.new("UICorner")
    addCorner.CornerRadius = UDim.new(0, 8)
    addCorner.Parent = addFriendButton
    
    addFriendButton.MouseButton1Click:Connect(function()
        self:ShowAddFriendDialog()
    end)
    
    contentFrames["Friends"] = friendsFrame
end

local function createGuildContent(parent: Frame)
    local guildFrame = Instance.new("Frame")
    guildFrame.Name = "GuildContent"
    guildFrame.Size = UDim2.new(1, 0, 1, 0)
    guildFrame.BackgroundTransparency = 1
    guildFrame.Visible = false
    guildFrame.Parent = parent
    
    -- Guild list
    guildList = Instance.new("ScrollingFrame")
    guildList.Name = "GuildList"
    guildList.Size = UDim2.new(0.5, -10, 0.8, 0)
    guildList.Position = UDim2.fromOffset(0, 0)
    guildList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    guildList.BorderSizePixel = 0
    guildList.Parent = guildFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = guildList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = guildList
    
    -- Guild details panel
    local detailsPanel = Instance.new("Frame")
    detailsPanel.Name = "GuildDetails"
    detailsPanel.Size = UDim2.new(0.5, -10, 0.8, 0)
    detailsPanel.Position = UDim2.new(0.5, 10, 0, 0)
    detailsPanel.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    detailsPanel.BorderSizePixel = 0
    detailsPanel.Parent = guildFrame
    
    local detailsCorner = Instance.new("UICorner")
    detailsCorner.CornerRadius = UDim.new(0, 10)
    detailsCorner.Parent = detailsPanel
    
    -- Create guild button
    local createGuildButton = Instance.new("TextButton")
    createGuildButton.Name = "CreateGuildButton"
    createGuildButton.Size = UDim2.new(1, -20, 0, 40)
    createGuildButton.Position = UDim2.fromOffset(10, 10)
    createGuildButton.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
    createGuildButton.BorderSizePixel = 0
    createGuildButton.Text = "🏰 Create Guild"
    createGuildButton.TextColor3 = Color3.new(1, 1, 1)
    createGuildButton.Font = Enum.Font.GothamBold
    createGuildButton.TextSize = 16
    createGuildButton.Parent = guildFrame
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 8)
    createCorner.Parent = createGuildButton
    
    createGuildButton.MouseButton1Click:Connect(function()
        self:ShowCreateGuildDialog()
    end)
    
    contentFrames["Guild"] = guildFrame
end

local function createChatContent(parent: Frame)
    local chatFrame = Instance.new("Frame")
    chatFrame.Name = "ChatContent"
    chatFrame.Size = UDim2.new(1, 0, 1, 0)
    chatFrame.BackgroundTransparency = 1
    chatFrame.Visible = false
    chatFrame.Parent = parent
    
    -- Channel list
    local channelList = Instance.new("ScrollingFrame")
    channelList.Name = "ChannelList"
    channelList.Size = UDim2.new(0.3, -10, 0.8, 0)
    channelList.Position = UDim2.fromOffset(0, 0)
    channelList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    channelList.BorderSizePixel = 0
    channelList.Parent = chatFrame
    
    local channelCorner = Instance.new("UICorner")
    channelCorner.CornerRadius = UDim.new(0, 10)
    channelCorner.Parent = channelList
    
    local channelLayout = Instance.new("UIListLayout")
    channelLayout.SortOrder = Enum.SortOrder.LayoutOrder
    channelLayout.Padding = UDim.new(0, 3)
    channelLayout.Parent = channelList
    
    -- Message area
    local messageArea = Instance.new("Frame")
    messageArea.Name = "MessageArea"
    messageArea.Size = UDim2.new(0.7, -10, 0.8, 0)
    messageArea.Position = UDim2.new(0.3, 10, 0, 0)
    messageArea.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    messageArea.BorderSizePixel = 0
    messageArea.Parent = chatFrame
    
    local messageCorner = Instance.new("UICorner")
    messageCorner.CornerRadius = UDim.new(0, 10)
    messageCorner.Parent = messageArea
    
    -- Message list
    messageList = Instance.new("ScrollingFrame")
    messageList.Name = "MessageList"
    messageList.Size = UDim2.new(1, -20, 1, -60)
    messageList.Position = UDim2.fromOffset(10, 10)
    messageList.BackgroundTransparency = 1
    messageList.BorderSizePixel = 0
    messageList.Parent = messageArea
    
    local messageLayout = Instance.new("UIListLayout")
    messageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    messageLayout.Padding = UDim.new(0, 3)
    messageLayout.Parent = messageList
    
    -- Chat input
    local inputContainer = Instance.new("Frame")
    inputContainer.Name = "InputContainer"
    inputContainer.Size = UDim2.new(1, -20, 0, 50)
    inputContainer.Position = UDim2.fromOffset(10, 10)
    inputContainer.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    inputContainer.BorderSizePixel = 0
    inputContainer.Position = UDim2.new(0, 10, 1, -60)
    inputContainer.Parent = messageArea
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputContainer
    
    chatInput = Instance.new("TextBox")
    chatInput.Name = "ChatInput"
    chatInput.Size = UDim2.new(1, -80, 1, -10)
    chatInput.Position = UDim2.fromOffset(10, 5)
    chatInput.BackgroundColor3 = Color3.fromRGB(50, 60, 80)
    chatInput.BorderSizePixel = 0
    chatInput.PlaceholderText = "Type a message..."
    chatInput.TextColor3 = Color3.new(1, 1, 1)
    chatInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    chatInput.Font = Enum.Font.Gotham
    chatInput.TextSize = 14
    chatInput.Parent = inputContainer
    
    local inputInnerCorner = Instance.new("UICorner")
    inputInnerCorner.CornerRadius = UDim.new(0, 6)
    inputInnerCorner.Parent = chatInput
    
    -- Send button
    local sendButton = Instance.new("TextButton")
    sendButton.Name = "SendButton"
    sendButton.Size = UDim2.fromOffset(60, 40)
    sendButton.Position = UDim2.new(1, -70, 0, 5)
    sendButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    sendButton.BorderSizePixel = 0
    sendButton.Text = "Send"
    sendButton.TextColor3 = Color3.new(1, 1, 1)
    sendButton.Font = Enum.Font.GothamBold
    sendButton.TextSize = 14
    sendButton.Parent = inputContainer
    
    local sendCorner = Instance.new("UICorner")
    sendCorner.CornerRadius = UDim.new(0, 6)
    sendCorner.Parent = sendButton
    
    sendButton.MouseButton1Click:Connect(function()
        self:SendMessage()
    end)
    
    chatInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:SendMessage()
        end
    end)
    
    contentFrames["Chat"] = chatFrame
end

local function createTradeContent(parent: Frame)
    local tradeFrame = Instance.new("Frame")
    tradeFrame.Name = "TradeContent"
    tradeFrame.Size = UDim2.new(1, 0, 1, 0)
    tradeFrame.BackgroundTransparency = 1
    tradeFrame.Visible = false
    tradeFrame.Parent = parent
    
    -- Trade list
    local tradeList = Instance.new("ScrollingFrame")
    tradeList.Name = "TradeList"
    tradeList.Size = UDim2.new(0.4, -10, 0.8, 0)
    tradeList.Position = UDim2.fromOffset(0, 0)
    tradeList.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    tradeList.BorderSizePixel = 0
    tradeList.Parent = tradeFrame
    
    local listCorner = Instance.new("UICorner")
    listCorner.CornerRadius = UDim.new(0, 10)
    listCorner.Parent = tradeList
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = tradeList
    
    -- Trade area
    local tradeArea = Instance.new("Frame")
    tradeArea.Name = "TradeArea"
    tradeArea.Size = UDim2.new(0.6, -10, 0.8, 0)
    tradeArea.Position = UDim2.new(0.4, 10, 0, 0)
    tradeArea.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    tradeArea.BorderSizePixel = 0
    tradeArea.Parent = tradeFrame
    
    local tradeCorner = Instance.new("UICorner")
    tradeCorner.CornerRadius = UDim.new(0, 10)
    tradeCorner.Parent = tradeArea
    
    -- Start trade button
    local startTradeButton = Instance.new("TextButton")
    startTradeButton.Name = "StartTradeButton"
    startTradeButton.Size = UDim2.new(1, -20, 0, 40)
    startTradeButton.Position = UDim2.fromOffset(10, 10)
    startTradeButton.BackgroundColor3 = Color3.fromRGB(200, 150, 50)
    startTradeButton.BorderSizePixel = 0
    startTradeButton.Text = "💰 Start Trade"
    startTradeButton.TextColor3 = Color3.new(1, 1, 1)
    startTradeButton.Font = Enum.Font.GothamBold
    startTradeButton.TextSize = 16
    startTradeButton.Parent = tradeFrame
    
    local startCorner = Instance.new("UICorner")
    startCorner.CornerRadius = UDim.new(0, 8)
    startCorner.Parent = startTradeButton
    
    startTradeButton.MouseButton1Click:Connect(function()
        self:ShowStartTradeDialog()
    end)
    
    contentFrames["Trade"] = tradeFrame
end

-- Public methods
function SocialUIController:Show()
    if not socialUI then
        createSocialUI()
    end
    
    isOpen = true
    
    -- Fade in
    local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.2
    })
    fadeIn:Play()
    
    -- Load initial data
    self:RefreshFriends()
    self:RefreshGuilds()
    self:RefreshChannels()
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function SocialUIController:Hide()
    if not socialUI or not isOpen then return end
    
    isOpen = false
    
    -- Fade out
    local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    
    fadeOut.Completed:Connect(function()
        if socialUI then
            socialUI.Parent = nil
        end
    end)
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function SocialUIController:SwitchTab(tabName: string)
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

function SocialUIController:SendMessage()
    if not chatInput or not SocialService then return end
    
    local message = chatInput.Text
    if #message == 0 or #message > MAX_MESSAGE_LENGTH then return end
    
    -- Check cooldown
    local currentTime = tick()
    if currentTime - lastMessageTime < CHAT_MESSAGE_COOLDOWN then return end
    
    lastMessageTime = currentTime
    
    -- Send message (would need to implement channel selection)
    local success = SocialService:SendMessage("Global", message)
    
    if success then
        chatInput.Text = ""
        if SoundEffects then
            SoundEffects.Play("UIButton")
        end
    else
        if SoundEffects then
            SoundEffects.Play("UIError")
        end
    end
end

function SocialUIController:RefreshFriends()
    if not SocialService or not friendList then return end
    
    -- Clear existing friend entries
    for _, child in ipairs(friendList:GetChildren()) do
        child:Destroy()
    end
    
    -- Load friends
    local player = Players.LocalPlayer
    local friends = SocialService:GetFriends(player.UserId)
    
    for _, friend in ipairs(friends) do
        local profile = SocialService:GetPlayerProfile(friend.UserId)
        if profile then
            createFriendEntry(profile, friend.Status)
        end
    end
end

function SocialUIController:RefreshGuilds()
    if not SocialService or not guildList then return end
    
    -- Clear existing guild entries
    for _, child in ipairs(guildList:GetChildren()) do
        child:Destroy()
    end
    
    -- Load player's guild
    local player = Players.LocalPlayer
    local guild = SocialService:GetPlayerGuild(player.UserId)
    
    if guild then
        createGuildEntry(guild)
    end
end

function SocialUIController:RefreshChannels()
    if not SocialService then return end
    
    -- Load channels
    local player = Players.LocalPlayer
    local channels = SocialService:GetPlayerChannels(player.UserId)
    
    -- Update channel list (would need to implement)
end

-- Private helper functions
function createFriendEntry(profile: PlayerProfile, status: string)
    if not friendList then return end
    
    local entry = Instance.new("Frame")
    entry.Name = "FriendEntry"
    entry.Size = UDim2.new(1, -10, 0, 60)
    entry.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    entry.BorderSizePixel = 0
    entry.Parent = friendList
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry
    
    -- Username
    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Name = "Username"
    usernameLabel.Size = UDim2.new(0.6, 0, 0, 25)
    usernameLabel.Position = UDim2.fromOffset(10, 5)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    usernameLabel.Font = Enum.Font.GothamBold
    usernameLabel.TextSize = 16
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.Text = profile.Username
    usernameLabel.Parent = entry
    
    -- Status
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "Status"
    statusLabel.Size = UDim2.new(0.6, 0, 0, 20)
    statusLabel.Position = UDim2.fromOffset(10, 30)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Text = profile.Status
    statusLabel.Parent = entry
    
    -- Online indicator
    local onlineIndicator = Instance.new("Frame")
    onlineIndicator.Name = "OnlineIndicator"
    onlineIndicator.Size = UDim2.fromOffset(10, 10)
    onlineIndicator.Position = UDim2.new(1, -20, 0, 25)
    onlineIndicator.BackgroundColor3 = profile.IsOnline and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(100, 100, 100)
    onlineIndicator.BorderSizePixel = 0
    onlineIndicator.Parent = entry
    
    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(0, 5)
    indicatorCorner.Parent = onlineIndicator
    
    -- Action buttons
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.Size = UDim2.fromOffset(60, 25)
    actionButton.Position = UDim2.new(1, -90, 0, 35)
    actionButton.BackgroundColor3 = Color3.fromRGB(50, 150, 250)
    actionButton.BorderSizePixel = 0
    actionButton.Text = status == "Pending" and "Accept" or "Chat"
    actionButton.TextColor3 = Color3.new(1, 1, 1)
    actionButton.Font = Enum.Font.GothamBold
    actionButton.TextSize = 12
    actionButton.Parent = entry
    
    local actionCorner = Instance.new("UICorner")
    actionCorner.CornerRadius = UDim.new(0, 4)
    actionCorner.Parent = actionButton
end

function createGuildEntry(guild: any)
    if not guildList then return end
    
    local entry = Instance.new("Frame")
    entry.Name = "GuildEntry"
    entry.Size = UDim2.new(1, -10, 0, 80)
    entry.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
    entry.BorderSizePixel = 0
    entry.Parent = guildList
    
    local entryCorner = Instance.new("UICorner")
    entryCorner.CornerRadius = UDim.new(0, 8)
    entryCorner.Parent = entry
    
    -- Guild name
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "GuildName"
    nameLabel.Size = UDim2.new(1, -20, 0, 25)
    nameLabel.Position = UDim2.fromOffset(10, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Text = guild.Name
    nameLabel.Parent = entry
    
    -- Guild description
    local descLabel = Instance.new("TextLabel")
    descLabel.Name = "Description"
    descLabel.Size = UDim2.new(1, -20, 0, 40)
    descLabel.Position = UDim2.fromOffset(10, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 12
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.TextYAlignment = Enum.TextYAlignment.Top
    descLabel.TextWrapped = true
    descLabel.Text = guild.Description
    descLabel.Parent = entry
    
    -- Member count
    local memberLabel = Instance.new("TextLabel")
    memberLabel.Name = "MemberCount"
    memberLabel.Size = UDim2.fromOffset(100, 20)
    memberLabel.Position = UDim2.new(1, -110, 0, 55)
    memberLabel.BackgroundTransparency = 1
    memberLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    memberLabel.Font = Enum.Font.Gotham
    memberLabel.TextSize = 12
    memberLabel.TextXAlignment = Enum.TextXAlignment.Right
    memberLabel.Text = #guild.Members .. " members"
    memberLabel.Parent = entry
end

-- Placeholder methods for dialog systems
function SocialUIController:ShowAddFriendDialog()
    print("[SocialUIController] Add friend dialog (to be implemented)")
end

function SocialUIController:ShowCreateGuildDialog()
    print("[SocialUIController] Create guild dialog (to be implemented)")
end

function SocialUIController:ShowStartTradeDialog()
    print("[SocialUIController] Start trade dialog (to be implemented)")
end

-- Service lifecycle
function SocialUIController:KnitStart()
    print("[SocialUIController] Starting social UI...")
    
    -- Get services
    local success, service = pcall(function()
        return Knit.GetService("SocialService")
    end)
    
    if success then
        SocialService = service
        
        -- Connect to social events
        SocialService.MessageReceived:Connect(function(message)
            -- Handle incoming message
            print("[SocialUIController] Received message:", message.Username, message.Message)
        end)
        
        SocialService.FriendRequestReceived:Connect(function(profile)
            -- Handle friend request
            print("[SocialUIController] Friend request from:", profile.Username)
            self:RefreshFriends()
        end)
        
        SocialService.GuildCreated:Connect(function(guild)
            -- Handle guild creation
            print("[SocialUIController] Guild created:", guild.Name)
            self:RefreshGuilds()
        end)
        
        SocialService.TradeRequestReceived:Connect(function(trade)
            -- Handle trade request
            print("[SocialUIController] Trade request received")
        end)
    else
        warn("[SocialUIController] SocialService not available")
    end
    
    -- Get sound effects
    success, service = pcall(function()
        return require(ReplicatedStorage.Shared.SoundEffects)
    end)
    
    if success then
        SoundEffects = service
    end
    
    print("[SocialUIController] Social UI started.")
end

function SocialUIController:KnitStop()
    self:Hide()
    print("[SocialUIController] Social UI stopped.")
end

return SocialUIController
