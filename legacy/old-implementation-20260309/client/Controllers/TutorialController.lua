--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TutorialController = Knit.CreateController { Name = "TutorialController" }

local screenGui: ScreenGui? = nil
local isShowing = false

local function createTutorialUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	if playerGui:FindFirstChild("TutorialUI") then
		screenGui = playerGui:FindFirstChild("TutorialUI")
		return
	end
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "TutorialUI"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = playerGui
	screenGui = gui
	
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.fromOffset(480, 280)
	main.Position = UDim2.fromScale(0.5, 0.7)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(15, 20, 40)
	main.BackgroundTransparency = 0.05
	main.BorderSizePixel = 0
	main.Parent = gui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = main
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 140, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.3
	stroke.Parent = main
	
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(1, -32, 0, 50)
	header.Position = UDim2.fromOffset(16, 16)
	header.BackgroundTransparency = 1
	header.TextColor3 = Color3.fromRGB(255, 210, 120)
	header.Font = Enum.Font.GothamBold
	header.TextSize = 22
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "Welcome to Syllable Springs!"
	header.Parent = main
	
	local message = Instance.new("TextLabel")
	message.Name = "Message"
	message.Size = UDim2.new(1, -32, 0, 140)
	message.Position = UDim2.fromOffset(16, 70)
	message.BackgroundTransparency = 1
	message.TextColor3 = Color3.fromRGB(200, 210, 240)
	message.Font = Enum.Font.Gotham
	message.TextSize = 16
	message.TextWrapped = true
	message.TextYAlignment = Enum.TextYAlignment.Top
	message.Text = "Your adventure begins here!"
	message.Parent = main
	
	local progressLabel = Instance.new("TextLabel")
	progressLabel.Name = "ProgressLabel"
	progressLabel.Size = UDim2.new(0.5, -8, 0, 24)
	progressLabel.Position = UDim2.fromOffset(16, 220)
	progressLabel.BackgroundTransparency = 1
	progressLabel.TextColor3 = Color3.fromRGB(120, 140, 180)
	progressLabel.Font = Enum.Font.Gotham
	progressLabel.TextSize = 12
	progressLabel.Text = "Step 1 of 6"
	progressLabel.Parent = main
	
	local skipBtn = Instance.new("TextButton")
	skipBtn.Name = "SkipBtn"
	skipBtn.Size = UDim2.new(0.4, -8, 0, 36)
	skipBtn.Position = UDim2.new(0.51, 0, 0, 214)
	skipBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	skipBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
	skipBtn.Font = Enum.Font.GothamBold
	skipBtn.TextSize = 14
	skipBtn.Text = "Skip Tutorial"
	skipBtn.BorderSizePixel = 0
	skipBtn.Parent = main
	
	local skipCorner = Instance.new("UICorner")
	skipCorner.CornerRadius = UDim.new(0, 8)
	skipCorner.Parent = skipBtn
	
	local continueBtn = Instance.new("TextButton")
	continueBtn.Name = "ContinueBtn"
	continueBtn.Size = UDim2.new(0.4, -8, 0, 36)
	continueBtn.Position = UDim2.new(0.51, 0, 0, 214)
	continueBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
	continueBtn.TextColor3 = Color3.new(1, 1, 1)
	continueBtn.Font = Enum.Font.GothamBold
	continueBtn.TextSize = 15
	continueBtn.Text = "Got it!"
	continueBtn.BorderSizePixel = 0
	continueBtn.Parent = main
	
	local contCorner = Instance.new("UICorner")
	contCorner.CornerRadius = UDim.new(0, 8)
	contCorner.Parent = continueBtn
	
	continueBtn.MouseButton1Click:Connect(function()
		TutorialController:AdvanceStep()
	end)
	
	skipBtn.MouseButton1Click:Connect(function()
		TutorialController:SkipTutorial()
	end)
end

function TutorialController:KnitStart()
	print("[TutorialController] Started.")
	
	local TutorialService = Knit.GetService("TutorialService")
	
	TutorialService.TutorialStep:Connect(function(step, current, total)
		self:ShowTutorial(step, current, total)
	end)
	
	TutorialService.TutorialComplete:Connect(function()
		self:HideTutorial()
	end)
	
	task.wait(1)
	TutorialService:StartTutorial(Players.LocalPlayer)
end

function TutorialController:ShowTutorial(step, current, total)
	if not step then return end
	
	createTutorialUI()
	
	if not screenGui then return end
	screenGui.Enabled = true
	isShowing = true
	
	local main = screenGui:FindFirstChild("Main")
	if main then
		local header = main:FindFirstChild("Header")
		local message = main:FindFirstChild("Message")
		local progress = main:FindFirstChild("ProgressLabel")
		local continueBtn = main:FindFirstChild("ContinueBtn")
		
		if header and header:IsA("TextLabel") then
			header.Text = step.Title or "Tutorial"
		end
		
		if message and message:IsA("TextLabel") then
			message.Text = step.Message or ""
		end
		
		if progress and progress:IsA("TextLabel") then
			progress.Text = `Step {current} of {total}`
		end
		
		if continueBtn and continueBtn:IsA("TextButton") then
			continueBtn.Text = step.Action or "Continue"
		end
	end
end

function TutorialController:HideTutorial()
	if screenGui then
		screenGui.Enabled = false
	end
	isShowing = false
end

function TutorialController:AdvanceStep()
	local TutorialService = Knit.GetService("TutorialService")
	TutorialService:AdvanceStep(Players.LocalPlayer)
end

function TutorialController:SkipTutorial()
	local TutorialService = Knit.GetService("TutorialService")
	TutorialService:SkipTutorial(Players.LocalPlayer)
end

return TutorialController
