--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Knit = require(ReplicatedStorage.Packages.Knit)

local JournalController = Knit.CreateController { Name = "JournalController" }

function JournalController:KnitStart()
    local DataService = Knit.GetService("DataService")
    
    self.DataService = DataService
    
    -- Create UI
    local gui = Instance.new("ScreenGui")
    gui.Name = "PhoenixJournal"
    gui.ResetOnSpawn = false
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    gui.Enabled = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromHex("#0f172a") -- Slate 900
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = gui
    
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    -- Tabs (Top Buttons)
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Size = UDim2.new(1, 0, 0, 40)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Parent = tabsContainer
    
    -- Pages Container
    local pages = Instance.new("Frame")
    pages.Size = UDim2.new(1, -20, 1, -60)
    pages.Position = UDim2.new(0, 10, 0, 50)
    pages.BackgroundTransparency = 1
    pages.Parent = mainFrame
    
    -- Create Pages
    self.InventoryPage = self:CreatePage("Inventory", pages)
    self.QuestsPage = self:CreatePage("Quests", pages)
    self.ReflectionPage = self:CreatePage("Reflection", pages)
    
    -- Helper to switch tabs
    local function switchTab(name)
        self.InventoryPage.Visible = (name == "Inventory")
        self.QuestsPage.Visible = (name == "Quests")
        self.ReflectionPage.Visible = (name == "Reflection")
    end
    
    -- Create Tab Buttons
    self:CreateTabButton("Inventory", tabsContainer, function() switchTab("Inventory") end)
    self:CreateTabButton("Quests", tabsContainer, function() switchTab("Quests") end)
    self:CreateTabButton("Reflection", tabsContainer, function() switchTab("Reflection") end)
    
    -- Default Tab
    switchTab("Inventory")
    
    self.Gui = gui
    self.Pages = pages
    
    -- Data Updates
    DataService.DataUpdated:Connect(function(key, value)
        if key == "Inventory" then
            self:UpdateInventory(value)
        elseif key == "Quests" then
            self:UpdateQuests(value)
        elseif key == "Journal" then
            self:UpdateReflection(value)
        end
    end)
    
    DataService.DataLoaded:Connect(function(data)
        if data then
            self:UpdateInventory(data.Inventory)
            self:UpdateQuests(data.Quests)
            self:UpdateReflection(data.Journal)
        end
    end)
    
    -- Input Toggle (J)
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.J then
            gui.Enabled = not gui.Enabled
        end
    end)
end

function JournalController:CreatePage(name, parent)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = parent
    
    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 5)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page
    
    return page
end

function JournalController:CreateTabButton(text, parent, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.33, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromHex("#334155") -- Slate 700
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = parent
    
    btn.MouseButton1Click:Connect(callback)
end

-- Render Functions

function JournalController:UpdateInventory(inventory)
    -- Clear
    for _, child in ipairs(self.InventoryPage:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end
    
    if not inventory then return end
    
    for id, item in pairs(inventory) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromHex("#1e293b")
        frame.BorderSizePixel = 0
        frame.Parent = self.InventoryPage
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -10, 1, 0)
        text.Position = UDim2.new(0, 10, 0, 0)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1,1,1)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.Text = string.format("%s (Lvl %d %s)", item.Term, item.Level, item.Role)
        text.Parent = frame
    end
end

function JournalController:UpdateQuests(quests)
    for _, child in ipairs(self.QuestsPage:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not quests then return end
    
    for id, quest in pairs(quests) do
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 60)
        frame.BackgroundColor3 = quest.IsActive and Color3.fromHex("#0EA5E9") or Color3.fromHex("#334155") -- Sky 500 or Grey
        frame.BorderSizePixel = 0
        frame.Parent = self.QuestsPage
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -10, 0, 20)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.new(1,1,1)
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Text = (quest.Name or "Unknown") .. (quest.IsCompleted and " (Completed)" or "")
        title.Parent = frame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -10, 0, 30)
        desc.Position = UDim2.new(0, 10, 0, 25)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.new(0.8,0.8,0.8)
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextYAlignment = Enum.TextYAlignment.Top
        desc.TextWrapped = true -- Ensure text wraps
        desc.Text = quest.Description or "..."
        desc.Parent = frame
    end
end

function JournalController:UpdateReflection(journal)
    for _, child in ipairs(self.ReflectionPage:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not journal then return end
    
    -- We need to sort by timestamp effectively
    local sorted = {}
    for ts, entry in pairs(journal) do
        table.insert(sorted, {ts = tonumber(ts), entry = entry})
    end
    table.sort(sorted, function(a,b) return a.ts > b.ts end) -- Newest first
    
    for _, data in ipairs(sorted) do
        local entry = data.entry
        local frame = Instance.new("Frame")
        -- Auto-sizing would be better, but fixed for prototype
        frame.Size = UDim2.new(1, 0, 0, 80)
        frame.BackgroundColor3 = Color3.fromHex("#475569")
        frame.BorderSizePixel = 0
        frame.Parent = self.ReflectionPage
        
        local dateLabel = Instance.new("TextLabel")
        dateLabel.Text = os.date("%c", data.ts)
        dateLabel.Size = UDim2.new(1, -10, 0, 20)
        dateLabel.Position = UDim2.new(0, 5, 0, 0)
        dateLabel.BackgroundTransparency = 1
        dateLabel.TextColor3 = Color3.fromHex("#94a3b8")
        dateLabel.TextXAlignment = Enum.TextXAlignment.Left
        dateLabel.Parent = frame
        
        local text = Instance.new("TextLabel")
        text.Text = entry.Entry
        text.Size = UDim2.new(1, -10, 1, -20)
        text.Position = UDim2.new(0, 5, 0, 20)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.new(1,1,1)
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextYAlignment = Enum.TextYAlignment.Top
        text.TextWrapped = true
        text.Parent = frame
    end
end

return JournalController
