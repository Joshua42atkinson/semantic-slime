--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local SoundManager = require(ReplicatedStorage.Shared.SoundManager)

local NotificationController = {}
NotificationController.__index = NotificationController

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NotificationUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Toast Container
local toastContainer = Instance.new("Frame")
toastContainer.Name = "ToastContainer"
toastContainer.Size = UDim2.new(0, 300, 1, 0)
toastContainer.Position = UDim2.new(1, -320, 0, 0) -- Right side
toastContainer.BackgroundTransparency = 1
toastContainer.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.Parent = toastContainer

-- Public API

function NotificationController.ShowToast(message: string, icon: string?, color: Color3?)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 50)
	frame.BackgroundColor3 = Color3.fromHex("#1F2937")
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromHex("#F59E0B")
	stroke.Thickness = 2
	stroke.Parent = frame
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = (icon or "") .. "  " .. message
	label.Parent = frame
	
	frame.Parent = toastContainer
	
	-- Animate In
	frame.Position = UDim2.new(1, 50, 0, 0) -- Start off screen (layout overrides this though)
	-- Layout handles position, but we can animate transparency/size
	
	SoundManager.PlaySFX("UI_Hover", 0.5, 1.5) -- Small blip
	
	task.delay(4, function()
		TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
		TweenService:Create(label, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.5), {Transparency = 1}):Play()
		task.wait(0.5)
		frame:Destroy()
	end)
end

function NotificationController.ShowCelebration(title: string, subtitle: string?)
	SoundManager.PlaySFX("QuestComplete")
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 150)
	frame.Position = UDim2.new(0, 0, 0.3, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 0.6, 0)
	text.BackgroundTransparency = 1
	text.Text = title
	text.TextColor3 = Color3.fromHex("#F59E0B")
	text.Font = Enum.Font.GothamBlack
	text.TextSize = 40
	text.TextStrokeTransparency = 0.5
	text.Parent = frame
	
	if subtitle then
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, 0, 0.4, 0)
		sub.Position = UDim2.new(0, 0, 0.6, 0)
		sub.BackgroundTransparency = 1
		sub.Text = subtitle
		sub.TextColor3 = Color3.new(1, 1, 1)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 24
		sub.Parent = frame
	end
	
	-- Pop in
	frame.Position = UDim2.new(0, 0, 0.4, 0)
	frame.BackgroundTransparency = 1
	
	TweenService:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0.3, 0)
	}):Play()
	
	task.delay(3, function()
		TweenService:Create(frame, TweenInfo.new(0.5), {Position = UDim2.new(0, 0, 0.2, 0)}):Play()
		-- Fade out texts
		for _, c in ipairs(frame:GetChildren()) do
			if c:IsA("TextLabel") then
				TweenService:Create(c, TweenInfo.new(0.5), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
			end
		end
		task.wait(0.5)
		frame:Destroy()
	end)
end

function NotificationController.Start()
	print("[NotificationController] Started")
end

return NotificationController
