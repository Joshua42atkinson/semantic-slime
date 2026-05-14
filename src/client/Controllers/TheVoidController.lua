--!strict
-- TheVoidController.lua
-- The visual and atmospheric layer for the Ontological Mirror (TRINITY Crossover).
-- When Night falls, the player is pulled from the Town Square into their own mind.
-- This handles the teleportation, the atmospheric shift, the Socratic text rendering,
-- and the UI for their introspection.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TheVoidController = Knit.CreateController {
	Name = "TheVoidController",
}

-- State variables
local inVoid = false
local originalPos: CFrame?
local voidRoom: Model?
local previousLightingState = {}
local heartbeatSound: Sound?
local currentTween: TweenBase?

local player = Players.LocalPlayer

function TheVoidController:KnitStart()
	print("[TheVoidController] 🌌 The Void is ready to consume the screen.")
	
	local OntologicalMirrorService = Knit.GetService("OntologicalMirrorService")
	if not OntologicalMirrorService then return end
	
	-- Setup the Void Room geometry deep underground
	voidRoom = Instance.new("Model")
	voidRoom.Name = "TheOntologicalVoid"
	
	local floor = Instance.new("Part")
	floor.Name = "GlassFloor"
	floor.Anchored = true
	floor.Size = Vector3.new(500, 1, 500)
	floor.Position = Vector3.new(0, -5000, 0)
	floor.Material = Enum.Material.Glass
	floor.Color = Color3.new(0, 0, 0)
	floor.Reflectance = 0.8
	floor.Parent = voidRoom
	
	voidRoom.Parent = Workspace
	
	-- Setup Sounds
	heartbeatSound = Instance.new("Sound")
	heartbeatSound.SoundId = "rbxassetid://4977457782" -- Deep, slow heartbeat
	heartbeatSound.Looped = true
	heartbeatSound.Volume = 0.5
	heartbeatSound.Parent = SoundService
	
	-- Connect Server Events
	OntologicalMirrorService.EnterTheVoid:Connect(function()
		self:ShatterReality()
	end)
	
	OntologicalMirrorService.AskSocraticQuestion:Connect(function(question)
		self:DisplayTheQuestion(question)
	end)
	
	OntologicalMirrorService.ReturnToReality:Connect(function(answer)
		self:RestoreReality()
	end)
end

function TheVoidController:ShatterReality()
	if inVoid then return end
	inVoid = true
	
	local char = player.Character
	if not char or not char.PrimaryPart then return end
	
	-- 1. Save reality state
	originalPos = char.PrimaryPart.CFrame
	previousLightingState = {
		Ambient = Lighting.Ambient,
		Brightness = Lighting.Brightness,
		ClockTime = Lighting.ClockTime,
		FogEnd = Lighting.FogEnd,
	}
	
	-- 2. Flash bang effect
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Brightness = 1
	cc.Contrast = 2
	cc.Parent = Lighting
	
	TweenService:Create(cc, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = -1, -- Pitch black
	}):Play()
	
	task.wait(0.5)
	
	-- 3. Transition to void
	Lighting.Ambient = Color3.new(0, 0, 0)
	Lighting.Brightness = 0
	Lighting.ClockTime = 0
	Lighting.FogEnd = 150
	Lighting.FogColor = Color3.new(0,0,0)
	
	if heartbeatSound then heartbeatSound:Play() end
	char:SetPrimaryPartCFrame(CFrame.new(0, -4995, 0))
	
	cc.Brightness = 0
	Debris(cc, 1)

	-- Lock movement
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then humanoid.WalkSpeed = 0 end
end

function TheVoidController:DisplayTheQuestion(questionText: string)
	if not inVoid then return end
	
	local pgui = player:WaitForChild("PlayerGui")
	local sg = Instance.new("ScreenGui")
	sg.Name = "VoidGUI"
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn = false
	sg.Parent = pgui
	
	-- The Question
	local qLabel = Instance.new("TextLabel")
	qLabel.Size = UDim2.fromScale(0.8, 0.4)
	qLabel.Position = UDim2.fromScale(0.1, 0.2)
	qLabel.BackgroundTransparency = 1
	qLabel.Font = Enum.Font.GothamMedium
	qLabel.TextColor3 = Color3.fromHex("#F3F4F6")
	qLabel.TextScaled = true
	qLabel.TextTransparency = 1
	qLabel.Text = questionText
	qLabel.Parent = sg
	
	TweenService:Create(qLabel, TweenInfo.new(3, Enum.EasingStyle.Sine), {
		TextTransparency = 0
	}):Play()
	
	-- The Input Field
	task.wait(2)
	local iBox = Instance.new("TextBox")
	iBox.Size = UDim2.fromScale(0.6, 0.1)
	iBox.Position = UDim2.fromScale(0.2, 0.6)
	iBox.BackgroundColor3 = Color3.new(0,0,0)
	iBox.BorderColor3 = Color3.fromHex("#4B5563")
	iBox.BorderSizePixel = 1
	iBox.Font = Enum.Font.Code
	iBox.TextColor3 = Color3.fromHex("#10B981")
	iBox.TextScaled = true
	iBox.TextTransparency = 1
	iBox.BackgroundTransparency = 1
	iBox.Text = ""
	iBox.PlaceholderText = "> Speak your truth..."
	iBox.Parent = sg
	
	TweenService:Create(iBox, TweenInfo.new(2, Enum.EasingStyle.Sine), {
		TextTransparency = 0,
		BackgroundTransparency = 0.5
	}):Play()
	
	iBox.FocusLost:Connect(function(enterPressed)
		if enterPressed and iBox.Text ~= "" then
			local ans = iBox.Text
			iBox.Interactable = false
			local OntoService = Knit.GetService("OntologicalMirrorService")
			if OntoService then
				OntoService.SubmitReflection:Fire(ans)
			end
		end
	end)
	
	-- Auto focus
	task.wait(1)
	iBox:CaptureFocus()
end

function TheVoidController:RestoreReality()
	if not inVoid then return end
	
	-- Shatter effect
	local pgui = player:WaitForChild("PlayerGui")
	local sg = pgui:FindFirstChild("VoidGUI")
	if sg then
		-- Flash white
		local f = Instance.new("Frame")
		f.Size = UDim2.fromScale(1, 1)
		f.BackgroundColor3 = Color3.new(1, 1, 1)
		f.BackgroundTransparency = 1
		f.Parent = sg
		
		TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Linear), {
			BackgroundTransparency = 0
		}):Play()
		task.wait(0.3)
		sg:Destroy()
	end
	
	if heartbeatSound then heartbeatSound:Stop() end
	
	-- Restore Physical World
	local char = player.Character
	if char and originalPos then
		char:SetPrimaryPartCFrame(originalPos)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = 16 end
	end
	
	-- Restore Lighting
	Lighting.Ambient = previousLightingState.Ambient
	Lighting.Brightness = previousLightingState.Brightness
	Lighting.ClockTime = previousLightingState.ClockTime
	Lighting.FogEnd = previousLightingState.FogEnd
	
	inVoid = false
	print("[TheVoidController] ☀️ Reality restored.")
end

-- Polyfill for Debris since we don't have exactly game.Debris in standard lua scope
function Debris(item, time)
	game:GetService("Debris"):AddItem(item, time)
end

return TheVoidController
