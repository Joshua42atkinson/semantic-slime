--!strict
--==============================================================
-- MMMM Context: Physical manifestation of the ethical monetization layer. A giant, glowing monument in Syllable Springs honoring those who fund real-world teachers.
--==============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MonumentService = Knit.CreateService {
    Name = "MonumentService",
    Client = {},
}

-- Config
local MONUMENT_POSITION = Vector3.new(0, 10, 0) -- Center of town
local MONUMENT_SCALE = 1.5

-- Store references to the physical UI elements
local TopDonorsFrame = nil
local RecentDonorsFrame = nil

function MonumentService:KnitStart()
    print("[MonumentService] Erecting the Philanthropist's Monument...")
    
    task.spawn(function()
        self:BuildMonument()
        
        -- Hook into DonationService to update the massive physical board
        local DonationService = Knit.GetService("DonationService")
        if DonationService then
            -- Listen for periodic refreshes
            DonationService.Client.BoardUpdated:Connect(function(topData, recentData, charityTarget)
                self:UpdateBoardUI(topData, recentData, charityTarget)
            end)
            
            -- Wait for data to load
            task.wait(5)
            DonationService:RefreshBoardData()
        end
    end)
end

function MonumentService:BuildMonument()
    local monument = Instance.new("Model")
    monument.Name = "PhilanthropistMonument"
    
    -- The Base / Pedestal
    local base = Instance.new("Part")
    base.Name = "Base"
    base.Size = Vector3.new(30, 2, 30) * MONUMENT_SCALE
    base.Position = MONUMENT_POSITION
    base.Anchored = true
    base.Material = Enum.Material.Marble
    base.Color = Color3.fromHex("#FFD700") -- Gold-tinged marble
    base.Parent = monument
    
    -- The Obelisk
    local pillar = Instance.new("Part")
    pillar.Name = "Pillar"
    pillar.Size = Vector3.new(12, 40, 12) * MONUMENT_SCALE
    pillar.Position = base.Position + Vector3.new(0, 20 * MONUMENT_SCALE, 0)
    pillar.Anchored = true
    pillar.Material = Enum.Material.Slate
    pillar.Color = Color3.fromHex("#111111")
    pillar.Parent = monument
    
    -- Glowing top core
    local core = Instance.new("Part")
    core.Name = "Core"
    core.Shape = Enum.PartType.Ball
    core.Size = Vector3.new(8, 8, 8) * MONUMENT_SCALE
    core.Position = pillar.Position + Vector3.new(0, 20 * MONUMENT_SCALE + 4, 0)
    core.Anchored = true
    core.Material = Enum.Material.Neon
    core.Color = Color3.fromRGB(255, 215, 0)
    core.Parent = monument
    
    local light = Instance.new("PointLight")
    light.Color = core.Color
    light.Range = 60
    light.Brightness = 3
    light.Parent = core
    
    -- Build The Board UI (Front Face)
    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Name = "LeaderboardData"
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.CanvasSize = Vector2.new(800, 1200)
    surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
    surfaceGui.Parent = pillar
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05)
    bg.BackgroundTransparency = 0.2
    bg.Parent = surfaceGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.1, 0)
    title.BackgroundTransparency = 1
    title.Text = "THE PHILANTHROPISTS"
    title.TextColor3 = Color3.new(1, 0.8, 0)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.Parent = bg
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0.05, 0)
    subtitle.Position = UDim2.new(0, 0, 0.1, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Support the Developer of Syllable Springs"
    subtitle.TextColor3 = Color3.new(1, 1, 1)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = bg
    
    TopDonorsFrame = Instance.new("ScrollingFrame")
    TopDonorsFrame.Size = UDim2.new(0.9, 0, 0.8, 0)
    TopDonorsFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
    TopDonorsFrame.BackgroundTransparency = 1
    TopDonorsFrame.ScrollBarThickness = 0
    TopDonorsFrame.Parent = bg
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = TopDonorsFrame
    
    -- Build Donation Prompts (Left, Right, Back faces)
    self:CreateDonationPlaque(pillar, Enum.NormalId.Left, 1000001, "Bronze Letter", 50, Color3.fromHex("#CD7F32"))
    self:CreateDonationPlaque(pillar, Enum.NormalId.Right, 1000002, "Silver Letter", 500, Color3.fromHex("#C0C0C0"))
    self:CreateDonationPlaque(pillar, Enum.NormalId.Back, 1000003, "Golden Letter", 5000, Color3.fromHex("#FFD700"))
    
    monument.Parent = Workspace
    print("[MonumentService] Physical Philanthropist's Board generated in Town Square.")
end

function MonumentService:CreateDonationPlaque(pillar: Part, face: Enum.NormalId, productId: number, name: string, amount: number, color: Color3)
    local sg = Instance.new("SurfaceGui")
    sg.Face = face
    sg.CanvasSize = Vector2.new(600, 800)
    sg.Parent = pillar
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = color
    frame.BackgroundTransparency = 0.8
    frame.Parent = sg
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.2, 0)
    title.Position = UDim2.new(0, 0, 0.2, 0)
    title.BackgroundTransparency = 1
    title.Text = "Donate " .. amount .. " Robux"
    title.TextColor3 = color
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.Parent = frame
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(0.8, 0, 0.3, 0)
    desc.Position = UDim2.new(0.1, 0, 0.4, 0)
    desc.BackgroundTransparency = 1
    desc.Text = "Support Dev.\nUnlock a " .. name .. " on the board.\nBless the Server's Zeitgeist."
    desc.TextColor3 = Color3.new(1, 1, 1)
    desc.TextScaled = true
    desc.TextWrapped = true
    desc.Font = Enum.Font.Gotham
    desc.Parent = frame
    
    -- Physical Interaction Trigger
    local promptPart = Instance.new("Part")
    promptPart.Size = Vector3.new(4, 4, 4)
    promptPart.Transparency = 1
    promptPart.Anchored = true
    promptPart.CanCollide = false
    
    -- Position prompt slightly off the face
    local offset = Vector3.new()
    if face == Enum.NormalId.Left then offset = Vector3.new(-7 * MONUMENT_SCALE, 0, 0)
    elseif face == Enum.NormalId.Right then offset = Vector3.new(7 * MONUMENT_SCALE, 0, 0)
    elseif face == Enum.NormalId.Back then offset = Vector3.new(0, 0, 7 * MONUMENT_SCALE) end
    
    promptPart.Position = pillar.Position + offset - Vector3.new(0, 10 * MONUMENT_SCALE, 0)
    promptPart.Parent = pillar.Parent
    
    local prompt = Instance.new("ProximityPrompt")
    prompt.ActionText = "Donate " .. amount .. "R$"
    prompt.ObjectText = name
    prompt.HoldDuration = 1
    prompt.Parent = promptPart
    
    -- Fire prompt directly to MarketplaceService
    prompt.Triggered:Connect(function(player)
        local MarketplaceService = game:GetService("MarketplaceService")
        MarketplaceService:PromptProductPurchase(player, productId)
    end)
end

function MonumentService:UpdateBoardUI(topData, recentData, charityTarget)
    if not TopDonorsFrame then return end
    
    -- Clear current
    for _, child in ipairs(TopDonorsFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    -- Populate Top Donors
    for i, data in ipairs(topData) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 80)
        entry.BackgroundColor3 = Color3.new(1, 1, 1)
        entry.BackgroundTransparency = i % 2 == 0 and 0.9 or 0.8
        entry.LayoutOrder = i
        entry.Parent = TopDonorsFrame
        
        local rankColor = Color3.new(1, 1, 1)
        if i == 1 then rankColor = Color3.fromHex("#FFD700")
        elseif i == 2 then rankColor = Color3.fromHex("#C0C0C0")
        elseif i == 3 then rankColor = Color3.fromHex("#CD7F32") end
        
        local rankTxt = Instance.new("TextLabel")
        rankTxt.Size = UDim2.new(0.1, 0, 1, 0)
        rankTxt.BackgroundTransparency = 1
        rankTxt.Text = "#" .. i
        rankTxt.TextColor3 = rankColor
        rankTxt.TextScaled = true
        rankTxt.Font = Enum.Font.GothamBlack
        rankTxt.Parent = entry
        
        local nameTxt = Instance.new("TextLabel")
        nameTxt.Size = UDim2.new(0.6, 0, 1, 0)
        nameTxt.Position = UDim2.new(0.15, 0, 0, 0)
        nameTxt.BackgroundTransparency = 1
        nameTxt.Text = tostring(data.Name)
        nameTxt.TextColor3 = Color3.new(1, 1, 1)
        nameTxt.TextScaled = true
        nameTxt.TextXAlignment = Enum.TextXAlignment.Left
        nameTxt.Font = Enum.Font.GothamBold
        nameTxt.Parent = entry
        
        local amountTxt = Instance.new("TextLabel")
        amountTxt.Size = UDim2.new(0.2, 0, 1, 0)
        amountTxt.Position = UDim2.new(0.8, 0, 0, 0)
        amountTxt.BackgroundTransparency = 1
        amountTxt.Text = tostring(data.Amount) .. " R$"
        amountTxt.TextColor3 = Color3.fromHex("#2CB67D")
        amountTxt.TextScaled = true
        amountTxt.Font = Enum.Font.Code
        amountTxt.Parent = entry
    end
end

return MonumentService
