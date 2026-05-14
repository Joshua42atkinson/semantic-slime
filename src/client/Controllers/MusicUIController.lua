--!strict
-- Music UI Controller for Semantic Slime
-- Manages music player interface and player preferences

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local MusicUIController = Knit.CreateController { Name = "MusicUIController" }

-- Configuration
local UI_ANIMATION_DURATION = 0.3
local VOLUME_SLIDER_PRECISION = 0.01
local MAX_CUSTOM_PLAYLISTS = 10

-- State
local isOpen = false
local currentTrack = nil
local currentDistrict = nil
local playerPreferences = nil
local musicUI: ScreenGui? = nil

-- UI References
local mainFrame: Frame? = nil
local trackInfo: Frame? = nil
local volumeControls: Frame? = nil
local districtControls: Frame? = nil
local customPlaylists: Frame? = nil

-- Services
local MusicManager: any = nil
local SoundEffects: any = nil

-- Private functions
local function createMusicUI()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main GUI container
    musicUI = Instance.new("ScreenGui")
    musicUI.Name = "MusicUI"
    musicUI.ResetOnSpawn = false
    musicUI.Parent = playerGui
    
    -- Main frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 600)
    mainFrame.Position = UDim2.new(1, -420, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.Parent = musicUI
    
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
    header.Size = UDim2.new(1, -20, 0, 60)
    header.Position = UDim2.fromOffset(10, 10)
    header.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 10)
    headerCorner.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.fromOffset(20, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🎵 Music Player"
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
    closeButton.TextSize = 18
    closeButton.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    -- Current track info
    createTrackInfoSection()
    
    -- Volume controls
    createVolumeControlsSection()
    
    -- District controls
    createDistrictControlsSection()
    
    -- Custom playlists
    createCustomPlaylistsSection()
end

local function createTrackInfoSection()
    trackInfo = Instance.new("Frame")
    trackInfo.Name = "TrackInfo"
    trackInfo.Size = UDim2.new(1, -20, 0, 120)
    trackInfo.Position = UDim2.fromOffset(10, 80)
    trackInfo.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    trackInfo.BorderSizePixel = 0
    trackInfo.Parent = mainFrame
    
    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 10)
    infoCorner.Parent = trackInfo
    
    -- Track name
    local trackNameLabel = Instance.new("TextLabel")
    trackNameLabel.Name = "TrackName"
    trackNameLabel.Size = UDim2.new(1, -20, 0, 30)
    trackNameLabel.Position = UDim2.fromOffset(10, 10)
    trackNameLabel.BackgroundTransparency = 1
    trackNameLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    trackNameLabel.Font = Enum.Font.GothamBold
    trackNameLabel.TextSize = 16
    trackNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    trackNameLabel.Text = "No track playing"
    trackNameLabel.Parent = trackInfo
    
    -- District name
    local districtLabel = Instance.new("TextLabel")
    districtLabel.Name = "DistrictName"
    districtLabel.Size = UDim2.new(1, -20, 0, 25)
    districtLabel.Position = UDim2.fromOffset(10, 40)
    districtLabel.BackgroundTransparency = 1
    districtLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
    districtLabel.Font = Enum.Font.Gotham
    districtLabel.TextSize = 14
    districtLabel.TextXAlignment = Enum.TextXAlignment.Left
    districtLabel.Text = "Unknown district"
    districtLabel.Parent = trackInfo
    
    -- Time of day
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeOfDay"
    timeLabel.Size = UDim2.new(1, -20, 0, 25)
    timeLabel.Position = UDim2.fromOffset(10, 65)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(200, 150, 255)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 14
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Text = "Unknown time"
    timeLabel.Parent = trackInfo
    
    -- Mood indicator
    local moodLabel = Instance.new("TextLabel")
    moodLabel.Name = "Mood"
    moodLabel.Size = UDim2.new(1, -20, 0, 25)
    moodLabel.Position = UDim2.fromOffset(10, 90)
    moodLabel.BackgroundTransparency = 1
    moodLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
    moodLabel.Font = Enum.Font.Gotham
    moodLabel.TextSize = 14
    moodLabel.TextXAlignment = Enum.TextXAlignment.Left
    moodLabel.Text = "Peaceful"
    moodLabel.Parent = trackInfo
end

local function createVolumeControlsSection()
    volumeControls = Instance.new("Frame")
    volumeControls.Name = "VolumeControls"
    volumeControls.Size = UDim2.new(1, -20, 0, 150)
    volumeControls.Position = UDim2.fromOffset(10, 210)
    volumeControls.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    volumeControls.BorderSizePixel = 0
    volumeControls.Parent = mainFrame
    
    local volumeCorner = Instance.new("UICorner")
    volumeCorner.CornerRadius = UDim.new(0, 10)
    volumeCorner.Parent = volumeControls
    
    -- Section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.fromOffset(10, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🔊 Volume Controls"
    titleLabel.Parent = volumeControls
    
    -- Master volume
    createVolumeSlider(volumeControls, "Master Volume", 40, 0.4, function(value)
        if MusicManager then
            MusicManager:SetMasterVolume(value)
        end
    end)
    
    -- District volumes (will be populated dynamically)
    local districtVolumeFrame = Instance.new("Frame")
    districtVolumeFrame.Name = "DistrictVolumes"
    districtVolumeFrame.Size = UDim2.new(1, -20, 0, 80)
    districtVolumeFrame.Position = UDim2.fromOffset(10, 90)
    districtVolumeFrame.BackgroundTransparency = 1
    districtVolumeFrame.Parent = volumeControls
    
    local districtLayout = Instance.new("UIListLayout")
    districtLayout.SortOrder = Enum.SortOrder.LayoutOrder
    districtLayout.Padding = UDim.new(0, 5)
    districtLayout.Parent = districtVolumeFrame
end

local function createVolumeSlider(parent: Frame, label: string, yOffset: number, defaultValue: number, callback: (number) -> ())
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = label .. "Slider"
    sliderFrame.Size = UDim2.new(1, -20, 0, 30)
    sliderFrame.Position = UDim2.fromOffset(10, yOffset)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = parent
    
    -- Label
    local labelLabel = Instance.new("TextLabel")
    labelLabel.Name = "Label"
    labelLabel.Size = UDim2.new(0, 150, 1, 0)
    labelLabel.Position = UDim2.fromOffset(0, 0)
    labelLabel.BackgroundTransparency = 1
    labelLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    labelLabel.Font = Enum.Font.Gotham
    labelLabel.TextSize = 14
    labelLabel.TextXAlignment = Enum.TextXAlignment.Left
    labelLabel.Text = label
    labelLabel.Parent = sliderFrame
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Name = "SliderBackground"
    sliderBg.Size = UDim2.new(0, 150, 0, 6)
    sliderBg.Position = UDim2.new(1, -160, 0.5, -3)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = sliderFrame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 3)
    sliderBgCorner.Parent = sliderBg
    
    -- Slider fill
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "SliderFill"
    sliderFill.Size = UDim2.new(defaultValue, 0, 1, 0)
    sliderFill.Position = UDim2.fromOffset(0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = sliderFill
    
    -- Slider handle
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Name = "SliderHandle"
    sliderHandle.Size = UDim2.fromOffset(16, 16)
    sliderHandle.Position = UDim2.new(defaultValue, -8, 0.5, -8)
    sliderHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderHandle.BorderSizePixel = 0
    sliderHandle.Text = ""
    sliderHandle.Parent = sliderFrame
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(0, 8)
    handleCorner.Parent = sliderHandle
    
    -- Volume value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.Size = UDim2.fromOffset(40, 20)
    valueLabel.Position = UDim2.new(1, -50, 0.5, -10)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.Text = math.floor(defaultValue * 100) .. "%"
    valueLabel.Parent = sliderFrame
    
    -- Slider interaction
    local isDragging = false
    
    sliderHandle.MouseButton1Down:Connect(function()
        isDragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local sliderPos = sliderBg.AbsolutePosition.X
            local sliderSize = sliderBg.AbsoluteSize.X
            local mousePos = input.Position.X
            
            local relativePos = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            
            -- Update handle position
            sliderHandle.Position = UDim2.new(relativePos, -8, 0.5, -8)
            
            -- Update fill
            sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
            
            -- Update value label
            valueLabel.Text = math.floor(relativePos * 100) .. "%"
            
            -- Call callback
            callback(relativePos)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
end

local function createDistrictControlsSection()
    districtControls = Instance.new("Frame")
    districtControls.Name = "DistrictControls"
    districtControls.Size = UDim2.new(1, -20, 0, 120)
    districtControls.Position = UDim2.fromOffset(10, 370)
    districtControls.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    districtControls.BorderSizePixel = 0
    districtControls.Parent = mainFrame
    
    local districtCorner = Instance.new("UICorner")
    districtCorner.CornerRadius = UDim.new(0, 10)
    districtCorner.Parent = districtControls
    
    -- Section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.fromOffset(10, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🏘️ District Settings"
    titleLabel.Parent = districtControls
    
    -- Time of day toggle
    local timeToggleFrame = Instance.new("Frame")
    timeToggleFrame.Name = "TimeOfDayToggle"
    timeToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    timeToggleFrame.Position = UDim2.fromOffset(10, 45)
    timeToggleFrame.BackgroundTransparency = 1
    timeToggleFrame.Parent = districtControls
    
    local timeToggleLabel = Instance.new("TextLabel")
    timeToggleLabel.Name = "Label"
    timeToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    timeToggleLabel.Position = UDim2.fromOffset(0, 0)
    timeToggleLabel.BackgroundTransparency = 1
    timeToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    timeToggleLabel.Font = Enum.Font.Gotham
    timeToggleLabel.TextSize = 14
    timeToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeToggleLabel.Text = "Time of Day Variations"
    timeToggleLabel.Parent = timeToggleFrame
    
    local timeToggle = Instance.new("TextButton")
    timeToggle.Name = "Toggle"
    timeToggle.Size = UDim2.fromOffset(60, 25)
    timeToggle.Position = UDim2.new(1, -70, 0.5, -12)
    timeToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    timeToggle.BorderSizePixel = 0
    timeToggle.Text = "ON"
    timeToggle.TextColor3 = Color3.new(1, 1, 1)
    timeToggle.Font = Enum.Font.GothamBold
    timeToggle.TextSize = 12
    timeToggle.Parent = timeToggleFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = timeToggle
    
    -- Crossfade toggle
    local crossfadeToggleFrame = Instance.new("Frame")
    crossfadeToggleFrame.Name = "CrossfadeToggle"
    crossfadeToggleFrame.Size = UDim2.new(1, -20, 0, 30)
    crossfadeToggleFrame.Position = UDim2.fromOffset(10, 80)
    crossfadeToggleFrame.BackgroundTransparency = 1
    crossfadeToggleFrame.Parent = districtControls
    
    local crossfadeToggleLabel = Instance.new("TextLabel")
    crossfadeToggleLabel.Name = "Label"
    crossfadeToggleLabel.Size = UDim2.new(0, 200, 1, 0)
    crossfadeToggleLabel.Position = UDim2.fromOffset(0, 0)
    crossfadeToggleLabel.BackgroundTransparency = 1
    crossfadeToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    crossfadeToggleLabel.Font = Enum.Font.Gotham
    crossfadeToggleLabel.TextSize = 14
    crossfadeToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    crossfadeToggleLabel.Text = "Smooth Crossfades"
    crossfadeToggleLabel.Parent = crossfadeToggleFrame
    
    local crossfadeToggle = Instance.new("TextButton")
    crossfadeToggle.Name = "Toggle"
    crossfadeToggle.Size = UDim2.fromOffset(60, 25)
    crossfadeToggle.Position = UDim2.new(1, -70, 0.5, -12)
    crossfadeToggle.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    crossfadeToggle.BorderSizePixel = 0
    crossfadeToggle.Text = "ON"
    crossfadeToggle.TextColor3 = Color3.new(1, 1, 1)
    crossfadeToggle.Font = Enum.Font.GothamBold
    crossfadeToggle.TextSize = 12
    crossfadeToggle.Parent = crossfadeToggleFrame
    
    local crossfadeCorner = Instance.new("UICorner")
    crossfadeCorner.CornerRadius = UDim.new(0, 6)
    crossfadeCorner.Parent = crossfadeToggle
end

local function createCustomPlaylistsSection()
    customPlaylists = Instance.new("Frame")
    customPlaylists.Name = "CustomPlaylists"
    customPlaylists.Size = UDim2.new(1, -20, 0, 100)
    customPlaylists.Position = UDim2.fromOffset(10, 500)
    customPlaylists.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    customPlaylists.BorderSizePixel = 0
    customPlaylists.Parent = mainFrame
    
    local playlistCorner = Instance.new("UICorner")
    playlistCorner.CornerRadius = UDim.new(0, 10)
    playlistCorner.Parent = customPlaylists
    
    -- Section title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, -20, 0, 30)
    titleLabel.Position = UDim2.fromOffset(10, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = "🎼 Custom Playlists"
    titleLabel.Parent = customPlaylists
    
    -- Create playlist button
    local createButton = Instance.new("TextButton")
    createButton.Name = "CreateButton"
    createButton.Size = UDim2.new(1, -20, 0, 35)
    createButton.Position = UDim2.fromOffset(10, 50)
    createButton.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
    createButton.BorderSizePixel = 0
    createButton.Text = "+ Create Custom Playlist"
    createButton.TextColor3 = Color3.new(1, 1, 1)
    createButton.Font = Enum.Font.GothamBold
    createButton.TextSize = 14
    createButton.Parent = customPlaylists
    
    local createCorner = Instance.new("UICorner")
    createCorner.CornerRadius = UDim.new(0, 8)
    createCorner.Parent = createButton
    
    createButton.MouseButton1Click:Connect(function()
        self:ShowCreatePlaylistDialog()
    end)
end

-- Public methods
function MusicUIController:Show()
    if not musicUI then
        createMusicUI()
    end
    
    isOpen = true
    
    -- Load current preferences
    if MusicManager then
        local player = Players.LocalPlayer
        playerPreferences = MusicManager:GetPlayerPreferences(player.UserId)
        
        if playerPreferences then
            updateUIWithPreferences()
        end
    end
    
    -- Animate in
    local slideIn = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -420, 0.5, -300)
    })
    slideIn:Play()
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function MusicUIController:Hide()
    if not musicUI or not isOpen then return end
    
    isOpen = false
    
    -- Animate out
    local slideOut = TweenService:Create(mainFrame, TweenInfo.new(UI_ANIMATION_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, 50, 0.5, -300)
    })
    slideOut:Play()
    
    slideOut.Completed:Connect(function()
        if musicUI then
            musicUI.Parent = nil
        end
    end)
    
    if SoundEffects then
        SoundEffects.Play("UIButton")
    end
end

function MusicUIController:UpdateTrackInfo(track: any, district: string, timeOfDay: string)
    currentTrack = track
    currentDistrict = district
    
    if trackInfo then
        local trackNameLabel = trackInfo:FindFirstChild("TrackName")
        local districtLabel = trackInfo:FindFirstChild("DistrictName")
        local timeLabel = trackInfo:FindFirstChild("TimeOfDay")
        local moodLabel = trackInfo:FindFirstChild("Mood")
        
        if trackNameLabel then
            trackNameLabel.Text = track.Name or "Unknown track"
        end
        
        if districtLabel then
            districtLabel.Text = "📍 " .. (district or "Unknown district")
        end
        
        if timeLabel then
            timeLabel.Text = "🕐 " .. (timeOfDay or "Unknown time")
        end
        
        if moodLabel then
            moodLabel.Text = "😊 " .. (track.Mood or "Peaceful")
        end
    end
end

function MusicUIController:UpdateVolume(controlType: string, value: number)
    if volumeControls then
        if controlType == "Master" then
            local slider = volumeControls:FindFirstChild("Master VolumeSlider")
            if slider then
                local handle = slider:FindFirstChild("SliderHandle")
                local fill = slider:FindFirstChild("SliderBackground"):FindFirstChild("SliderFill")
                local valueLabel = slider:FindFirstChild("ValueLabel")
                
                if handle and fill and valueLabel then
                    handle.Position = UDim2.new(value, -8, 0.5, -8)
                    fill.Size = UDim2.new(value, 0, 1, 0)
                    valueLabel.Text = math.floor(value * 100) .. "%"
                end
            end
        end
    end
end

-- Private helper functions
function updateUIWithPreferences()
    if not playerPreferences or not volumeControls then return end
    
    -- Update master volume
    local masterSlider = volumeControls:FindFirstChild("Master VolumeSlider")
    if masterSlider then
        local handle = masterSlider:FindFirstChild("SliderHandle")
        local fill = masterSlider:FindFirstChild("SliderBackground"):FindFirstChild("SliderFill")
        local valueLabel = masterSlider:FindFirstChild("ValueLabel")
        
        if handle and fill and valueLabel then
            handle.Position = UDim2.new(playerPreferences.MasterVolume, -8, 0.5, -8)
            fill.Size = UDim2.new(playerPreferences.MasterVolume, 0, 1, 0)
            valueLabel.Text = math.floor(playerPreferences.MasterVolume * 100) .. "%"
        end
    end
end

function MusicUIController:ShowCreatePlaylistDialog()
    print("[MusicUIController] Create playlist dialog (to be implemented)")
end

-- Service lifecycle
function MusicUIController:KnitStart()
    print("[MusicUIController] Starting music UI...")
    
    -- Get services
    local success, service = pcall(function()
        return Knit.GetService("MusicManager")
    end)
    
    if success then
        MusicManager = service
        
        -- Connect to music events
        MusicManager.TrackChanged:Connect(function(track, district, timeOfDay)
            self:UpdateTrackInfo(track, district, timeOfDay)
        end)
        
        MusicManager.VolumeAdjusted:Connect(function(controlType, value)
            self:UpdateVolume(controlType, value)
        end)
        
        MusicManager.DistrictChanged:Connect(function(oldDistrict, newDistrict)
            currentDistrict = newDistrict
            if trackInfo then
                local districtLabel = trackInfo:FindFirstChild("DistrictName")
                if districtLabel then
                    districtLabel.Text = "📍 " .. (newDistrict or "Unknown district")
                end
            end
        end)
        
        MusicManager.TimeOfDayChanged:Connect(function(timeOfDay)
            if trackInfo then
                local timeLabel = trackInfo:FindFirstChild("TimeOfDay")
                if timeLabel then
                    timeLabel.Text = "🕐 " .. (timeOfDay or "Unknown time")
                end
            end
        end)
    else
        warn("[MusicUIController] MusicManager not available")
    end
    
    -- Get sound effects
    success, service = pcall(function()
        return require(ReplicatedStorage.Shared.SoundEffects)
    end)
    
    if success then
        SoundEffects = service
    end
    
    print("[MusicUIController] Music UI started.")
end

function MusicUIController:KnitStop()
    self:Hide()
    print("[MusicUIController] Music UI stopped.")
end

return MusicUIController
