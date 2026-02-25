--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local WordConstructorController = Knit.CreateController { Name = "WordConstructorController" }

-- State
local isOpen = false
local currentWord = ""

function WordConstructorController:KnitStart()
	print("[WordConstructorController] Started.")
	
	-- Listen for Construction phase
	local GameLoopService = Knit.GetService("GameLoopService")
	GameLoopService.Client.PhaseChanged:Connect(function(phase, _)
		if phase == "Construction" then
			self:Show()
		else
			self:Hide()
		end
	end)
	
	-- Input handling
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		
		if input.KeyCode == Enum.KeyCode.Escape then
			self:Toggle()
		end
	end)
end

function WordConstructorController:Toggle()
	if isOpen then
		self:Hide()
	else
		self:Show()
	end
end

function WordConstructorController:Show()
	if isOpen then return end
	isOpen = true
	
	-- Get letter inventory from CrystalService
	local CrystalService = Knit.GetService("CrystalService")
	local inventory = CrystalService:GetPlayerInventory(Players.LocalPlayer)
	
	-- Create UI
	self:CreateUI(inventory)
	
	print("[WordConstructorController] UI Shown")
end

function WordConstructorController:Hide()
	if not isOpen then return end
	isOpen = false
	
	if self.screenGui and self.screenGui.Parent then
		self.screenGui:Destroy()
	end
	
	print("[WordConstructorController] UI Hidden")
end

function WordConstructorController:CreateUI(inventory: { [string]: number })
	-- Clean up old UI
	if self.screenGui then
		self.screenGui:Destroy()
	end
	
	-- Create ScreenGui
	self.screenGui = Instance.new("ScreenGui")
	self.screenGui.Name = "WordConstructor"
	self.screenGui.IgnoreGuiInset = true
	self.screenGui.ResetOnSpawn = false
	self.screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Main Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromOffset(500, 400)
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	mainFrame.BackgroundTransparency = 0.2
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = self.screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15)
	corner.Parent = mainFrame
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.fromScale(1, 0.15)
	title.Position = UDim2.fromScale(0, 0.05)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.new(1, 1, 1)
	title.TextStrokeTransparency = 0
	title.Font = Enum.Font.GothamBold
	title.TextSize = 28
	title.Text = "🔨 Word Constructor"
	title.Parent = mainFrame
	
	-- Letter Display (center)
	local letterFrame = Instance.new("Frame")
	letterFrame.Name = "LetterFrame"
	letterFrame.Size = UDim2.fromScale(0.9, 0.25)
	letterFrame.Position = UDim2.fromScale(0.05, 0.25)
	letterFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	letterFrame.BorderSizePixel = 0
	letterFrame.Parent = mainFrame
	
	local letterCorner = Instance.new("UICorner")
	letterCorner.CornerRadius = UDim.new(0, 10)
	letterCorner.Parent = letterFrame
	
	self.wordLabel = Instance.new("TextLabel")
	self.wordLabel.Name = "WordLabel"
	self.wordLabel.Size = UDim2.fromScale(1, 1)
	self.wordLabel.BackgroundTransparency = 1
	self.wordLabel.TextColor3 = Color3.new(1, 0.8, 0)
	self.wordLabel.TextStrokeTransparency = 0
	self.wordLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	self.wordLabel.Font = Enum.Font.GothamBold
	self.wordLabel.TextSize = 48
	self.wordLabel.Text = "_ _ _ _"
	self.wordLabel.Parent = letterFrame
	
	-- Letter Inventory Display
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "InventoryFrame"
	inventoryFrame.Size = UDim2.fromScale(0.9, 0.3)
	inventoryFrame.Position = UDim2.fromScale(0.05, 0.55)
	inventoryFrame.BackgroundTransparency = 1
	inventoryFrame.Parent = mainFrame
	
	-- Create letter buttons
	local letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	local cols = 10
	local btnSize = 40
	local spacing = 5
	
	for i, letter in ipairs(letters) do
		local btn = Instance.new("TextButton")
		btn.Name = "Letter_" .. letter
		btn.Size = UDim2.fromOffset(btnSize, btnSize)
		btn.Position = UDim2.fromOffset(
			((i - 1) % cols) * (btnSize + spacing),
			(math.floor((i - 1) / cols)) * (btnSize + spacing)
		)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 18
		btn.Text = letter .. " (" .. (inventory[letter] or 0) .. ")"
		btn.Parent = inventoryFrame
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 5)
		btnCorner.Parent = btn
		
		-- Click handler
		btn.MouseButton1Click:Connect(function()
			self:AddLetter(letter)
		end)
		
		-- Disable if no inventory
		if (inventory[letter] or 0) <= 0 then
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			btn.TextColor3 = Color3.fromRGB(100, 100, 100)
		end
	end
	
	-- Buttons (bottom)
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = "ButtonFrame"
	buttonFrame.Size = UDim2.fromScale(0.9, 0.12)
	buttonFrame.Position = UDim2.fromScale(0.05, 0.88)
	buttonFrame.BackgroundTransparency = 1
	buttonFrame.Parent = mainFrame
	
	-- Clear button
	local clearBtn = Instance.new("TextButton")
	clearBtn.Name = "ClearBtn"
	clearBtn.Size = UDim2.fromScale(0.3, 1)
	clearBtn.Position = UDim2.fromScale(0, 0)
	clearBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	clearBtn.TextColor3 = Color3.new(1, 1, 1)
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = 16
	clearBtn.Text = "Clear"
	clearBtn.Parent = buttonFrame
	
	local clearCorner = Instance.new("UICorner")
	clearCorner.CornerRadius = UDim.new(0, 5)
	clearCorner.Parent = clearBtn
	
	clearBtn.MouseButton1Click:Connect(function()
		self:ClearWord()
	end)
	
	-- Submit button
	self.submitBtn = Instance.new("TextButton")
	self.submitBtn.Name = "SubmitBtn"
	self.submitBtn.Size = UDim2.fromScale(0.65, 1)
	self.submitBtn.Position = UDim2.fromScale(0.35, 0)
	self.submitBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	self.submitBtn.TextColor3 = Color3.new(1, 1, 1)
	self.submitBtn.Font = Enum.Font.GothamBold
	self.submitBtn.TextSize = 18
	self.submitBtn.Text = "Create Slime!"
	self.submitBtn.Parent = buttonFrame
	
	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 5)
	submitCorner.Parent = self.submitBtn
	
	self.submitBtn.MouseButton1Click:Connect(function()
		self:SubmitWord()
	end)
	
	-- Keyboard input
	UserInputService.InputEnded:Connect(function(input, _)
		if not isOpen then return end
		
		-- Handle letter keys
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			local key = input.KeyCode.Name
			if #key == 1 and key:match("%a") then
				self:AddLetter(key:upper())
			elseif key == "Backspace" then
				self:RemoveLetter()
			elseif key == "Return" or key == "Space" then
				self:SubmitWord()
			end
		end
	end)
end

function WordConstructorController:AddLetter(letter: string)
	currentWord = currentWord .. letter
	self:UpdateWordDisplay()
end

function WordConstructorController:RemoveLetter()
	if #currentWord > 0 then
		currentWord = currentWord:sub(1, -2)
		self:UpdateWordDisplay()
	end
end

function WordConstructorController:ClearWord()
	currentWord = ""
	self:UpdateWordDisplay()
end

function WordConstructorController:UpdateWordDisplay()
	if not self.wordLabel then return end
	
	-- Display word with underscores for empty spaces
	local display = ""
	for i = 1, #currentWord do
		local char = currentWord:sub(i, i)
		display = display .. char .. " "
	end
	
	-- Pad with underscores
	local maxLen = 12
	while #display < maxLen * 2 do
		display = display .. "_ "
	end
	
	self.wordLabel.Text = display:sub(1, -2)
end

function WordConstructorController:SubmitWord()
	if #currentWord < 3 then
		self.wordLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
		task.delay(0.5, function()
			if self.wordLabel then
				self.wordLabel.TextColor3 = Color3.new(1, 0.8, 0)
			end
		end)
		return
	end
	
	-- Try to create slime
	local GameLoopService = Knit.GetService("GameLoopService")
	local success = GameLoopService:CompleteWordConstruction(Players.LocalPlayer, currentWord)
	
	if success then
		self.wordLabel.TextColor3 = Color3.new(0.3, 1, 0.3)
		print("[WordConstructorController] Created slime: " .. currentWord)
		task.delay(1, function()
			self:ClearWord()
			if self.wordLabel then
				self.wordLabel.TextColor3 = Color3.new(1, 0.8, 0)
			end
		end)
	else
		self.wordLabel.TextColor3 = Color3.new(1, 0.3, 0.3)
		task.delay(0.5, function()
			if self.wordLabel then
				self.wordLabel.TextColor3 = Color3.new(1, 0.8, 0)
			end
		end)
	end
end

return WordConstructorController
