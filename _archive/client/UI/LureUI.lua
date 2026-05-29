--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

local LureUI = {}
LureUI.__index = LureUI

-- State
local activeMenu: ScreenGui? = nil
local timerConnection: RBXScriptConnection? = nil
local timeRemaining: number = 0
local currentWord: string = ""
local onSelectCallback: ((string) -> ())? = nil

-- Sound Effects (created on demand)
local function playSound(soundType: string)
	local sound = Instance.new("Sound")
	sound.Parent = SoundService
	
	if soundType == "open" then
		sound.SoundId = "rbxassetid://6895079853" -- UI Open
		sound.Volume = 0.5
	elseif soundType == "hover" then
		sound.SoundId = "rbxassetid://6895079806" -- UI Hover
		sound.Volume = 0.3
	elseif soundType == "success" then
		sound.SoundId = "rbxassetid://6895079754" -- Success
		sound.Volume = 0.7
	elseif soundType == "fail" then
		sound.SoundId = "rbxassetid://6895079689" -- Fail
		sound.Volume = 0.7
	elseif soundType == "tick" then
		sound.SoundId = "rbxassetid://6895079937" -- Tick
		sound.Volume = 0.2
	end
	
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end

-- Create visual effects
local function createCaptureEffect(position: Vector2, success: boolean)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screen = playerGui:FindFirstChild("LureUI")
	if not screen then return end
	
	local effect = Instance.new("Frame")
	effect.Size = UDim2.fromOffset(100, 100)
	effect.Position = UDim2.fromOffset(position.X, position.Y)
	effect.AnchorPoint = Vector2.new(0.5, 0.5)
	effect.BackgroundColor3 = success and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(239, 68, 68)
	effect.BackgroundTransparency = 0.5
	effect.BorderSizePixel = 0
	effect.Parent = screen
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = effect
	
	-- Expand and fade
	TweenService:Create(effect, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
		Size = UDim2.fromOffset(300, 300),
		BackgroundTransparency = 1
	}):Play()
	
	game:GetService("Debris"):AddItem(effect, 0.6)
end

-- Timer update function
local function updateTimer(timerBar: Frame, timerLabel: TextLabel)
	if not timerBar or not timerLabel then return end
	
	local maxTime = GameConfig.LURE_TIMER
	local percent = timeRemaining / maxTime
	
	-- Update bar
	TweenService:Create(timerBar, TweenInfo.new(0.1), {
		Size = UDim2.fromScale(percent, 1)
	}):Play()
	
	-- Update label
	timerLabel.Text = string.format("%.1f", timeRemaining)
	
	-- Color change based on time
	if percent > 0.5 then
		timerBar.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
	elseif percent > 0.25 then
		timerBar.BackgroundColor3 = Color3.fromRGB(245, 158, 11) -- Yellow
	else
		timerBar.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Red
		-- Pulse effect when low
		local pulse = TweenService:Create(timerBar, TweenInfo.new(0.2, Enum.EasingStyle.Pulse), {
			BackgroundTransparency = 0.5
		})
		pulse:Play()
		pulse.Completed:Connect(function()
			timerBar.BackgroundTransparency = 0
		end)
	end
	
	-- Tick sound when low
	if timeRemaining <= 3 and timeRemaining > 0 then
		playSound("tick")
	end
end

-- Handle timeout
local function onTimeout()
	if activeMenu and onSelectCallback then
		playSound("fail")
		createCaptureEffect(Vector2.new(0.5, 0.5).X, false)
		LureUI.Unmount()
		-- Pass empty string to indicate timeout
		onSelectCallback("")
	end
end

function LureUI.Mount(targetTerm: string, choices: {string}, onSelect: (string) -> ())
	if activeMenu then LureUI.Unmount() end
	
	currentWord = targetTerm
	onSelectCallback = onSelect
	
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screen = Instance.new("ScreenGui")
	screen.Name = "LureUI"
	screen.ResetOnSpawn = false
	screen.Parent = playerGui
	
	activeMenu = screen
	
	playSound("open")
	
	-- Darken background
	local background = Instance.new("Frame")
	background.Name = "Background"
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 0.5
	background.BorderSizePixel = 0
	background.Parent = screen
	
	-- Main Container
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.fromOffset(400, 400)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromHex("1E1B4B") -- Deep navy
	container.BackgroundTransparency = 0.1
	container.Parent = screen
	
	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 16)
	containerCorner.Parent = container
	
	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = Color3.fromHex("4F46E5") -- Indigo
	containerStroke.Thickness = 2
	containerStroke.Parent = container
	
	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.fromOffset(300, 40)
	titleLabel.Position = UDim2.fromScale(0.5, 0.08)
	titleLabel.AnchorPoint = Vector2.new(0.5, 0)
	titleLabel.Text = "🎯 LURE THE ETYMON"
	titleLabel.TextColor3 = Color3.fromHex("FCD34D") -- Gold
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 24
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = container
	
	-- Target Word Display
	local wordFrame = Instance.new("Frame")
	wordFrame.Name = "WordFrame"
	wordFrame.Size = UDim2.fromOffset(200, 60)
	wordFrame.Position = UDim2.fromScale(0.5, 0.22)
	wordFrame.AnchorPoint = Vector2.new(0.5, 0)
	wordFrame.BackgroundColor3 = Color3.fromHex("4F46E5")
	wordFrame.Parent = container
	
	local wordFrameCorner = Instance.new("UICorner")
	wordFrameCorner.CornerRadius = UDim.new(0, 12)
	wordFrameCorner.Parent = wordFrame
	
	local wordLabel = Instance.new("TextLabel")
	wordLabel.Name = "TargetWord"
	wordLabel.Size = UDim2.fromScale(1, 1)
	wordLabel.Text = targetTerm:upper()
	wordLabel.TextColor3 = Color3.new(1, 1, 1)
	wordLabel.Font = Enum.Font.GothamBold
	wordLabel.TextSize = 28
	wordLabel.BackgroundTransparency = 1
	wordLabel.Parent = wordFrame
	
	-- Instruction
	local instruction = Instance.new("TextLabel")
	instruction.Name = "Instruction"
	instruction.Size = UDim2.fromOffset(300, 30)
	instruction.Position = UDim2.fromScale(0.5, 0.38)
	instruction.AnchorPoint = Vector2.new(0.5, 0)
	instruction.Text = "Select the SYNONYM to capture it!"
	instruction.TextColor3 = Color3.fromHex("A5B4FC") -- Muted lavender
	instruction.Font = Enum.Font.Gotham
	instruction.TextSize = 16
	instruction.BackgroundTransparency = 1
	instruction.Parent = container
	
	-- Timer Bar Background
	local timerBg = Instance.new("Frame")
	timerBg.Name = "TimerBg"
	timerBg.Size = UDim2.fromOffset(300, 20)
	timerBg.Position = UDim2.fromScale(0.5, 0.48)
	timerBg.AnchorPoint = Vector2.new(0.5, 0)
	timerBg.BackgroundColor3 = Color3.fromHex("374151")
	timerBg.Parent = container
	
	local timerBgCorner = Instance.new("UICorner")
	timerBgCorner.CornerRadius = UDim.new(0, 10)
	timerBgCorner.Parent = timerBg
	
	-- Timer Bar Fill
	local timerBar = Instance.new("Frame")
	timerBar.Name = "TimerBar"
	timerBar.Size = UDim2.fromScale(1, 1)
	timerBar.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Green
	timerBar.BorderSizePixel = 0
	timerBar.Parent = timerBg
	
	local timerBarCorner = Instance.new("UICorner")
	timerBarCorner.CornerRadius = UDim.new(0, 10)
	timerBarCorner.Parent = timerBar
	
	-- Timer Label
	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "TimerLabel"
	timerLabel.Size = UDim2.fromOffset(50, 20)
	timerLabel.Position = UDim2.fromScale(0.5, 0.54)
	timerLabel.AnchorPoint = Vector2.new(0.5, 0)
	timerLabel.Text = tostring(GameConfig.LURE_TIMER)
	timerLabel.TextColor3 = Color3.new(1, 1, 1)
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.TextSize = 18
	timerLabel.BackgroundTransparency = 1
	timerLabel.Parent = container
	
	-- Choices Container
	local choicesContainer = Instance.new("Frame")
	choicesContainer.Name = "Choices"
	choicesContainer.Size = UDim2.fromOffset(350, 150)
	choicesContainer.Position = UDim2.fromScale(0.5, 0.75)
	choicesContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	choicesContainer.BackgroundTransparency = 1
	choicesContainer.Parent = container
	
	-- Create Choice Buttons in a 2x2 grid
	local buttonSize = UDim2.fromOffset(150, 50)
	local positions = {
		UDim2.fromOffset(0, 0),
		UDim2.fromOffset(180, 0),
		UDim2.fromOffset(0, 70),
		UDim2.fromOffset(180, 70),
	}
	
	for i, word in ipairs(choices) do
		if i > 4 then break end -- Max 4 choices
		
		local btn = Instance.new("TextButton")
		btn.Name = "Choice_" .. i
		btn.Size = buttonSize
		btn.Position = positions[i]
		btn.Text = word
		btn.BackgroundColor3 = Color3.fromHex("1F2937")
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 18
		btn.Parent = choicesContainer
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn
		
		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Color3.fromHex("4B5563")
		btnStroke.Thickness = 1
		btnStroke.Parent = btn
		
		-- Hover effect
		btn.MouseEnter:Connect(function()
			playSound("hover")
			TweenService:Create(btn, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromHex("4F46E5"),
				StrokeColor = Color3.fromHex("818CF8")
			}):Play()
		end)
		
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.1), {
				BackgroundColor3 = Color3.fromHex("1F2937"),
				StrokeColor = Color3.fromHex("4B5563")
			}):Play()
		end)
		
		-- Click handler
		btn.MouseButton1Click:Connect(function()
			local success = onSelect(word)
			if success then
				playSound("success")
				btn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
				createCaptureEffect(btn.AbsolutePosition + btn.AbsoluteSize / 2, true)
			else
				playSound("fail")
				btn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
				createCaptureEffect(btn.AbsolutePosition + btn.AbsoluteSize / 2, false)
			end
			
			task.wait(0.3)
			LureUI.Unmount()
		end)
		
		-- Entrance animation
		btn.Size = UDim2.fromOffset(0, 50)
		TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = buttonSize
		}):Play()
	end
	
	-- Start Timer
	timeRemaining = GameConfig.LURE_TIMER
	local startTime = tick()
	
	timerConnection = RunService.Heartbeat:Connect(function()
		local elapsed = tick() - startTime
		timeRemaining = math.max(0, GameConfig.LURE_TIMER - elapsed)
		
		updateTimer(timerBar, timerLabel)
		
		if timeRemaining <= 0 then
			onTimeout()
		end
	end)
	
	-- Entrance animation for container
	container.Size = UDim2.fromOffset(0, 0)
	container.BackgroundTransparency = 1
	TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
		Size = UDim2.fromOffset(400, 400),
		BackgroundTransparency = 0.1
	}):Play()
end

function LureUI.Unmount()
	if timerConnection then
		timerConnection:Disconnect()
		timerConnection = nil
	end
	
	if activeMenu then
		-- Exit animation
		local container = activeMenu:FindFirstChild("Container")
		if container then
			TweenService:Create(container, TweenInfo.new(0.2), {
				Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1
			}):Play()
		end
		
		task.wait(0.25)
		activeMenu:Destroy()
		activeMenu = nil
	end
	
	onSelectCallback = nil
	currentWord = ""
end

-- Check if Lure UI is currently active
function LureUI.IsActive(): boolean
	return activeMenu ~= nil
end

-- Get remaining time
function LureUI.GetTimeRemaining(): number
	return timeRemaining
end

function LureUI.Initialize()
    print("[LureUI] Initializing lure minigame UI...")
    
    -- LureUI is ready to show lure minigames when needed
    -- No persistent UI elements needed for initialization
    
    print("[LureUI] Lure minigame UI initialized")
end

return LureUI