--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local SlimeVisuals = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("SlimeVisuals"))

local WordConstructorController = Knit.CreateController { Name = "WordConstructorController" }

-- ────────────────────────────────────────────────
-- State (module-level, created once)
local isOpen = false
local currentWord = ""

-- All UI references live here after first build
local screenGui: ScreenGui? = nil
local wordLabel: TextLabel? = nil
local previewWorld: WorldModel? = nil
local previewModel: Model? = nil
local rotationConn: RBXScriptConnection? = nil

-- ────────────────────────────────────────────────
-- Forward declarations
local updateWordDisplay
local updatePreview

local function clearPreview()
	if previewModel then
		previewModel:Destroy()
		previewModel = nil
	end
end

-- ────────────────────────────────────────────────
-- UI construction (runs ONCE)
local function buildUI()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- Guard: only build once
	if playerGui:FindFirstChild("WordConstructor") then
		screenGui = playerGui:FindFirstChild("WordConstructor") :: ScreenGui
		return
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "WordConstructor"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Enabled = false  -- Start hidden
	gui.Parent = playerGui
	screenGui = gui

	-- ── Main frame: premium dark glass card ────────────────────────
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.fromOffset(560, 440)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(12, 14, 26)
	main.BackgroundTransparency = 0.08
	main.BorderSizePixel = 0
	main.Parent = gui

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 18)
	mainCorner.Parent = main

	-- Subtle border glow
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 140, 255)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	stroke.Parent = main

	-- ── Header bar ────────────────────────────────────────────────
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 52)
	header.BackgroundColor3 = Color3.fromRGB(20, 24, 48)
	header.BackgroundTransparency = 0.0
	header.BorderSizePixel = 0
	header.Parent = main

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 18)
	headerCorner.Parent = header

	-- Clip the bottom corners of the header
	local headerBottom = Instance.new("Frame")
	headerBottom.Size = UDim2.new(1, 0, 0, 18)
	headerBottom.Position = UDim2.new(0, 0, 1, -18)
	headerBottom.BackgroundColor3 = Color3.fromRGB(20, 24, 48)
	headerBottom.BorderSizePixel = 0
	headerBottom.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -16, 1, 0)
	title.Position = UDim2.fromOffset(16, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(180, 200, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "🧬  SLIME FABRICATOR"
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.fromOffset(36, 36)
	closeBtn.Position = UDim2.new(1, -44, 0, 8)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Text = "✕"
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		WordConstructorController:Hide()
	end)

	-- ── Left pane: word input area ─────────────────────────────────
	local leftPane = Instance.new("Frame")
	leftPane.Name = "LeftPane"
	leftPane.Size = UDim2.new(0.48, -8, 0, 100)
	leftPane.Position = UDim2.fromOffset(16, 64)
	leftPane.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
	leftPane.BackgroundTransparency = 0.1
	leftPane.BorderSizePixel = 0
	leftPane.Parent = main

	local leftCorner = Instance.new("UICorner")
	leftCorner.CornerRadius = UDim.new(0, 12)
	leftCorner.Parent = leftPane

	local wordLbl = Instance.new("TextLabel")
	wordLbl.Name = "WordLabel"
	wordLbl.Size = UDim2.fromScale(1, 1)
	wordLbl.BackgroundTransparency = 1
	wordLbl.TextColor3 = Color3.fromRGB(255, 210, 50)
	wordLbl.TextStrokeTransparency = 0.5
	wordLbl.TextStrokeColor3 = Color3.fromRGB(80, 60, 0)
	wordLbl.Font = Enum.Font.GothamBold
	wordLbl.TextSize = 32
	wordLbl.Text = "_ _ _ _"
	wordLbl.Parent = leftPane
	wordLabel = wordLbl

	-- Element preview badge (updates dynamically)
	local elementBadge = Instance.new("TextLabel")
	elementBadge.Name = "ElementBadge"
	elementBadge.Size = UDim2.new(0.48, -8, 0, 32)
	elementBadge.Position = UDim2.fromOffset(16, 172)
	elementBadge.BackgroundColor3 = Color3.fromRGB(28, 34, 72)
	elementBadge.BackgroundTransparency = 0.0
	elementBadge.TextColor3 = Color3.fromRGB(180, 200, 255)
	elementBadge.Font = Enum.Font.Gotham
	elementBadge.TextSize = 14
	elementBadge.Text = "🌿 Element: Normal"
	elementBadge.BorderSizePixel = 0
	elementBadge.Parent = main
	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 8)
	badgeCorner.Parent = elementBadge

	-- We'll update it in updateWordDisplay via closure
	local _elementBadge = elementBadge

	-- ── Right pane: 3D viewport ────────────────────────────────────
	local vpFrame = Instance.new("ViewportFrame")
	vpFrame.Name = "SlimePreview"
	vpFrame.Size = UDim2.new(0.48, -8, 0, 170)
	vpFrame.Position = UDim2.new(0.52, 0, 0, 64)
	vpFrame.BackgroundColor3 = Color3.fromRGB(5, 8, 18)
	vpFrame.BackgroundTransparency = 0.0
	vpFrame.BorderSizePixel = 0
	vpFrame.LightColor = Color3.new(1, 1, 1)
	vpFrame.LightDirection = Vector3.new(-1, -2, -1)
	vpFrame.Parent = main

	local vpCorner = Instance.new("UICorner")
	vpCorner.CornerRadius = UDim.new(0, 12)
	vpCorner.Parent = vpFrame

	local vpStroke = Instance.new("UIStroke")
	vpStroke.Color = Color3.fromRGB(80, 100, 200)
	vpStroke.Thickness = 1
	vpStroke.Transparency = 0.5
	vpStroke.Parent = vpFrame

	local wm = Instance.new("WorldModel")
	wm.Parent = vpFrame
	previewWorld = wm

	local cam = Instance.new("Camera")
	cam.FieldOfView = 44
	cam.CFrame = CFrame.new(Vector3.new(0, 1.5, 9), Vector3.new(0, 0.5, 0))
	cam.Parent = vpFrame
	vpFrame.CurrentCamera = cam

	-- Viewport label
	local vpLabel = Instance.new("TextLabel")
	vpLabel.Size = UDim2.new(1, 0, 0, 24)
	vpLabel.Position = UDim2.new(0, 0, 1, 4)
	vpLabel.BackgroundTransparency = 1
	vpLabel.TextColor3 = Color3.fromRGB(100, 120, 200)
	vpLabel.Font = Enum.Font.Gotham
	vpLabel.TextSize = 12
	vpLabel.Text = "Semantic Simulation"
	vpLabel.Parent = vpFrame

	-- ── Letter inventory grid ──────────────────────────────────────
	local inventoryFrame = Instance.new("Frame")
	inventoryFrame.Name = "InventoryFrame"
	inventoryFrame.Size = UDim2.new(1, -32, 0, 110)
	inventoryFrame.Position = UDim2.fromOffset(16, 210)
	inventoryFrame.BackgroundTransparency = 1
	inventoryFrame.Parent = main

	local letters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
	local cols = 13
	local btnSize = 36
	local spacing = 4

	-- Placeholder inventory — will be refreshed in Show()
	local inventory: { [string]: number } = {}

	for i, letter in ipairs(letters) do
		local btn = Instance.new("TextButton")
		btn.Name = "Letter_" .. letter
		btn.Size = UDim2.fromOffset(btnSize, btnSize)
		btn.Position = UDim2.fromOffset(
			((i - 1) % cols) * (btnSize + spacing),
			math.floor((i - 1) / cols) * (btnSize + spacing)
		)
		btn.BackgroundColor3 = Color3.fromRGB(30, 38, 80)
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.Text = letter
		btn.BorderSizePixel = 0
		btn.Parent = inventoryFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		local bStroke = Instance.new("UIStroke")
		bStroke.Color = Color3.fromRGB(60, 80, 160)
		bStroke.Thickness = 1
		bStroke.Parent = btn

		btn.MouseButton1Click:Connect(function()
			WordConstructorController:AddLetter(letter)
		end)
	end

	-- ── Bottom action buttons ──────────────────────────────────────
	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.Size = UDim2.new(1, -32, 0, 44)
	buttonRow.Position = UDim2.fromOffset(16, 378)
	buttonRow.BackgroundTransparency = 1
	buttonRow.Parent = main

	local clearBtn = Instance.new("TextButton")
	clearBtn.Name = "ClearBtn"
	clearBtn.Size = UDim2.fromScale(0.28, 1)
	clearBtn.BackgroundColor3 = Color3.fromRGB(160, 30, 30)
	clearBtn.TextColor3 = Color3.new(1, 1, 1)
	clearBtn.Font = Enum.Font.GothamBold
	clearBtn.TextSize = 16
	clearBtn.Text = "⌫ Clear"
	clearBtn.BorderSizePixel = 0
	clearBtn.Parent = buttonRow
	local clearCorner = Instance.new("UICorner")
	clearCorner.CornerRadius = UDim.new(0, 8)
	clearCorner.Parent = clearBtn

	clearBtn.MouseButton1Click:Connect(function()
		WordConstructorController:ClearWord()
	end)

	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackBtn"
	backBtn.Size = UDim2.fromScale(0.16, 1)
	backBtn.Position = UDim2.fromScale(0.30, 0)
	backBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
	backBtn.TextColor3 = Color3.new(1, 1, 1)
	backBtn.Font = Enum.Font.GothamBold
	backBtn.TextSize = 16
	backBtn.Text = "⬅"
	backBtn.BorderSizePixel = 0
	backBtn.Parent = buttonRow
	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0, 8)
	backCorner.Parent = backBtn

	backBtn.MouseButton1Click:Connect(function()
		WordConstructorController:RemoveLetter()
	end)

	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitBtn"
	submitBtn.Size = UDim2.fromScale(0.52, 1)
	submitBtn.Position = UDim2.fromScale(0.48, 0)
	submitBtn.BackgroundColor3 = Color3.fromRGB(30, 130, 60)
	submitBtn.TextColor3 = Color3.new(1, 1, 1)
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.TextSize = 17
	submitBtn.Text = "✨ Fabricate Slime!"
	submitBtn.BorderSizePixel = 0
	submitBtn.Parent = buttonRow
	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 8)
	submitCorner.Parent = submitBtn

	submitBtn.MouseButton1Click:Connect(function()
		WordConstructorController:SubmitWord()
	end)

	-- ── Keyboard input ────────────────────────────────────────────
	UserInputService.InputEnded:Connect(function(input, _)
		if not isOpen then return end
		if input.KeyCode ~= Enum.KeyCode.Unknown then
			local key = input.KeyCode.Name
			if #key == 1 and key:match("%a") then
				WordConstructorController:AddLetter(key:upper())
			elseif key == "Backspace" then
				WordConstructorController:RemoveLetter()
			elseif key == "Return" then
				WordConstructorController:SubmitWord()
			end
		end
	end)

	-- Expose for updateWordDisplay
	updateWordDisplay = function()
		if not wordLabel then return end

		local display = ""
		for i = 1, math.min(#currentWord, 14) do
			display = display .. currentWord:sub(i, i):upper() .. " "
		end
		local maxLen = 8
		while #display < maxLen * 2 do display = display .. "_ " end
		wordLabel.Text = display:sub(1, -2)

		-- Update element badge
		local elem = SlimeVisuals.GetElement(currentWord)
		local emap = {
			Fire="🔥 Element: Fire", Water="💧 Element: Water", Earth="🌿 Element: Earth",
			Air="💨 Element: Air", Shadow="🌑 Element: Shadow", Light="✨ Element: Light",
			Normal="⭐ Element: Normal"
		}
		_elementBadge.Text = emap[elem] or "⭐ Element: Normal"
		_elementBadge.BackgroundColor3 = SlimeVisuals.ELEMENT_COLORS[elem] and
			SlimeVisuals.ELEMENT_COLORS[elem]:Lerp(Color3.fromRGB(10,14,30), 0.6) or
			Color3.fromRGB(28, 34, 72)

		updatePreview()
	end

	updatePreview = function()
		clearPreview()
		if #currentWord == 0 then return end

		local elem = SlimeVisuals.GetElement(currentWord)
		local mdl = Instance.new("Model")
		mdl.Name = "PreviewSlime"
		SlimeVisuals.BuildStructure(mdl, currentWord, elem)
		mdl.Parent = previewWorld
		mdl:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
		previewModel = mdl
	end
end

-- ────────────────────────────────────────────────
function WordConstructorController:KnitStart()
	print("[WordConstructorController] Started.")

	-- Listen for Construction phase
	local GameLoopService = Knit.GetService("GameLoopService")
	GameLoopService.PhaseChanged:Connect(function(phase, _)
		if phase == "Construction" then
			self:Show()
		else
			self:Hide()
		end
	end)

	-- Listen for physical machine interaction
	local remotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
	local remotes = (remotesMod and remotesMod:IsA("ModuleScript")) and require(remotesMod) or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes", 10)
	local openEvent = remotes:WaitForChild("OpenWordConstructor")
	openEvent.OnClientEvent:Connect(function()
		self:Show()
	end)

	-- Keyboard shortcut
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.Escape then
			self:Hide()
		end
	end)
end

function WordConstructorController:Show()
	if isOpen then return end
	isOpen = true

	buildUI()

	if screenGui then
		screenGui.Enabled = true
	end

	-- Start rotation loop (bound to RenderStepped for smoothness, auto-stops when hidden)
	if rotationConn then rotationConn:Disconnect() end
	rotationConn = RunService.RenderStepped:Connect(function(dt)
		if previewModel and previewModel.PrimaryPart then
			previewModel:SetPrimaryPartCFrame(
				previewModel:GetPrimaryPartCFrame() * CFrame.Angles(0, math.rad(90 * dt), 0)
			)
		end
	end)

	-- Show current word state
	updateWordDisplay()

	print("[WordConstructorController] UI shown.")
end

function WordConstructorController:Hide()
	if not isOpen then return end
	isOpen = false

	-- Stop rotation — don't destroy the UI, just hide it
	if rotationConn then
		rotationConn:Disconnect()
		rotationConn = nil
	end

	clearPreview()

	if screenGui then
		screenGui.Enabled = false
	end

	print("[WordConstructorController] UI hidden.")
end

function WordConstructorController:Toggle()
	if isOpen then self:Hide() else self:Show() end
end

function WordConstructorController:AddLetter(letter: string)
	if #currentWord >= 14 then return end
	currentWord = currentWord .. letter:lower()
	if updateWordDisplay then updateWordDisplay() end
end

function WordConstructorController:RemoveLetter()
	if #currentWord > 0 then
		currentWord = currentWord:sub(1, -2)
		if updateWordDisplay then updateWordDisplay() end
	end
end

function WordConstructorController:ClearWord()
	currentWord = ""
	if updateWordDisplay then updateWordDisplay() end
end

function WordConstructorController:SubmitWord()
	if #currentWord < 3 then
		if wordLabel then
			wordLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
			task.delay(0.5, function()
				if wordLabel then wordLabel.TextColor3 = Color3.fromRGB(255, 210, 50) end
			end)
		end
		return
	end

	-- Get GameLoopService with error handling
	local gameLoopSuccess, GameLoopService = pcall(function()
		return Knit.GetService("GameLoopService")
	end)
	
	if not gameLoopSuccess or not GameLoopService then
		warn("[WordConstructorController] GameLoopService not available")
		if wordLabel then
			wordLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
		return
	end
	
	-- Complete word construction with error handling
	local completeSuccess, completeResult = pcall(function()
		return GameLoopService:CompleteWordConstruction(currentWord)
	end)
	
	if not completeSuccess then
		warn("[WordConstructorController] Error calling CompleteWordConstruction:", completeResult)
		if wordLabel then
			wordLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
		return
	end
	
	completeResult:andThen(function(success)
		if success then
			if wordLabel then wordLabel.TextColor3 = Color3.fromRGB(100, 255, 100) end
			print("[WordConstructorController] Fabricated slime: " .. currentWord)
			task.delay(0.8, function()
				self:ClearWord()
				if wordLabel then wordLabel.TextColor3 = Color3.fromRGB(255, 210, 50) end
			end)
		else
			if wordLabel then
				wordLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
				task.delay(0.5, function()
					if wordLabel then wordLabel.TextColor3 = Color3.fromRGB(255, 210, 50) end
				end)
			end
		end
	end):catch(function(err)
		warn("[WordConstructorController] Failed to construct word: " .. tostring(err))
		if wordLabel then
			wordLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
		end
	end)
end

return WordConstructorController
