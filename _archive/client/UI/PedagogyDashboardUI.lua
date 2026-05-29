--!strict
--==============================================================
-- MMMM Context: The Administrator's Lens. Allows Teachers/Parents to view the LinguisticLog and track real semantic progress.
--==============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local PedagogyDashboardUI = {}
PedagogyDashboardUI.__index = PedagogyDashboardUI

local isOpen = false
local screenGui: ScreenGui? = nil
local mainFrame: Frame? = nil
local listFrame: ScrollingFrame? = nil

function PedagogyDashboardUI.Initialize()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PedagogyDashboard"
    screenGui.ResetOnSpawn = false
    screenGui.Enabled = false
    screenGui.Parent = playerGui
    
    -- Main Container (Looks like a clipboard or report card)
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 700, 0, 500)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(240, 240, 245) -- Paper white
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local shadow = Instance.new("UIStroke")
    shadow.Color = Color3.fromRGB(150, 150, 150)
    shadow.Thickness = 1
    shadow.Parent = mainFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- EdTech Blue
    header.Parent = mainFrame
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 12)
    hCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 20, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Student Semantic Analytics"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18
    closeBtn.Parent = header
    
    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        PedagogyDashboardUI.Toggle()
    end)
    
    -- Subheader Columns
    local columns = Instance.new("Frame")
    columns.Size = UDim2.new(1, -40, 0, 30)
    columns.Position = UDim2.new(0, 20, 0, 70)
    columns.BackgroundTransparency = 1
    columns.Parent = mainFrame
    
    local function makeCol(text, pos, size)
        local lbl = Instance.new("TextLabel")
        lbl.Size = size
        lbl.Position = pos
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(100, 100, 100)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Parent = columns
    end
    
    makeCol("Root / Morpheme", UDim2.new(0, 10, 0, 0), UDim2.new(0.3, 0, 1, 0))
    makeCol("Uses", UDim2.new(0.4, 0, 0, 0), UDim2.new(0.2, 0, 1, 0))
    makeCol("Mistakes", UDim2.new(0.6, 0, 0, 0), UDim2.new(0.2, 0, 1, 0))
    makeCol("Mastery", UDim2.new(0.8, 0, 0, 0), UDim2.new(0.2, 0, 1, 0))
    
    -- List Frame
    listFrame = Instance.new("ScrollingFrame")
    listFrame.Size = UDim2.new(1, -40, 1, -120)
    listFrame.Position = UDim2.new(0, 20, 0, 100)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 6
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200)
    listFrame.Parent = mainFrame
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = listFrame
end

function PedagogyDashboardUI.RefreshData()
    if not listFrame then return end
    
    -- Clear current list
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local DataService = Knit.GetService("DataService")
    -- In a real scenario, this gets data via a Knit Client Request, but we can emit a signal or return a Promise
    -- Since we're client-side, we must request it.
    local profile = DataService:GetProfile() -- Provided we add a getter or pass data
end

-- Temporary mock load via signal injection
function PedagogyDashboardUI.PopulateData(logData)
    if not listFrame then return end
    
    -- Clear current list
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    if not logData or not logData.Morphemes then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 50)
        empty.BackgroundTransparency = 1
        empty.Text = "No linguistic data collected yet."
        empty.TextColor3 = Color3.fromRGB(150, 150, 150)
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 18
        empty.Parent = listFrame
        return
    end
    
    for morph, stats in pairs(logData.Morphemes) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -10, 0, 40)
        row.BackgroundColor3 = Color3.new(1, 1, 1)
        row.Parent = listFrame
        
        local rCorner = Instance.new("UICorner")
        rCorner.CornerRadius = UDim.new(0, 6)
        rCorner.Parent = row
        
        local total = stats.Pass + stats.Fail
        local mastery = total > 0 and math.floor((stats.Pass / total) * 100) or 0
        
        local function makeVal(text, pos, color)
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(0.2, 0, 1, 0)
            lbl.Position = pos
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = color
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 16
            lbl.Parent = row
        end
        
        makeVal(morph, UDim2.new(0, 10, 0, 0), Color3.fromRGB(50, 50, 50))
        makeVal(tostring(stats.Pass), UDim2.new(0.4, 0, 0, 0), Color3.fromRGB(34, 197, 94))
        makeVal(tostring(stats.Fail), UDim2.new(0.6, 0, 0, 0), Color3.fromRGB(239, 68, 68))
        
        -- Mastery Bar
        local barBg = Instance.new("Frame")
        barBg.Size = UDim2.new(0.18, 0, 0.4, 0)
        barBg.Position = UDim2.new(0.8, 0, 0.3, 0)
        barBg.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        barBg.Parent = row
        local b1 = Instance.new("UICorner") b1.CornerRadius = UDim.new(1,0) b1.Parent = barBg
        
        local barFill = Instance.new("Frame")
        barFill.Size = UDim2.new(mastery / 100, 0, 1, 0)
        barFill.BackgroundColor3 = mastery > 70 and Color3.fromRGB(34, 197, 94) or (mastery > 40 and Color3.fromRGB(250, 204, 21) or Color3.fromRGB(239, 68, 68))
        barFill.Parent = barBg
        local b2 = Instance.new("UICorner") b2.CornerRadius = UDim.new(1,0) b2.Parent = barFill
    end
end

function PedagogyDashboardUI.Toggle()
    if not screenGui then return end
    
    isOpen = not isOpen
    
    if isOpen then
        screenGui.Enabled = true
        if mainFrame then
            mainFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
            mainFrame.GroupTransparency = 1
            
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 0),
                GroupTransparency = 0
            }):Play()
        end
    else
        if mainFrame then
            TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.55, 0),
                GroupTransparency = 1
            }):Play()
            
            task.delay(0.2, function()
                if not isOpen then
                    screenGui.Enabled = false
                end
            end)
        end
    end
end

return PedagogyDashboardUI
