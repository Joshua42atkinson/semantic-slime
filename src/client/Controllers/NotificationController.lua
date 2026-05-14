--!strict
-- NotificationController: Simple toast/celebration notification system
-- This was missing from the Controllers/ directory, causing QuestController to crash on load.

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local NotificationController = {}

function NotificationController.ShowToast(text: string, icon: string?, color: Color3?)
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return end
	
	local container = playerGui:FindFirstChild("ToastContainer")
	if not container then
		container = Instance.new("ScreenGui")
		container.Name = "ToastContainer"
		container.ResetOnSpawn = false
		container.DisplayOrder = 100
		container.Parent = playerGui
	end
	
	local toast = Instance.new("Frame")
	toast.Size = UDim2.fromOffset(350, 45)
	toast.Position = UDim2.fromScale(0.5, 0.12)
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.BackgroundColor3 = color or Color3.fromHex("#6366F1")
	toast.BackgroundTransparency = 0.15
	toast.Parent = container
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toast
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Text = (icon or "📢") .. "  " .. text
	label.Parent = toast
	
	-- Slide in
	toast.Position = UDim2.fromScale(0.5, -0.1)
	TweenService:Create(toast, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.12)
	}):Play()
	
	-- Auto dismiss
	task.delay(3, function()
		TweenService:Create(toast, TweenInfo.new(0.3), {
			Position = UDim2.fromScale(0.5, -0.1),
			BackgroundTransparency = 1
		}):Play()
		task.wait(0.4)
		if toast.Parent then toast:Destroy() end
	end)
end

function NotificationController.ShowCelebration(title: string, subtitle: string?)
	local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return end
	
	local celebrationGui = Instance.new("ScreenGui")
	celebrationGui.Name = "CelebrationScreen"
	celebrationGui.DisplayOrder = 200
	celebrationGui.Parent = playerGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 0.25)
	frame.Position = UDim2.fromScale(0.5, 0.4)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromHex("#7C3AED")
	frame.BackgroundTransparency = 0.3
	frame.Parent = celebrationGui
	
	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(0.7, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	gradient.Parent = frame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.6)
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextColor3 = Color3.fromHex("#FDE68A")
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 48
	titleLabel.Text = "🎉 " .. title .. " 🎉"
	titleLabel.Parent = frame
	
	if subtitle then
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.fromScale(1, 0.4)
		sub.Position = UDim2.fromScale(0, 0.6)
		sub.BackgroundTransparency = 1
		sub.TextColor3 = Color3.new(1, 1, 1)
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 20
		sub.Text = subtitle
		sub.Parent = frame
	end
	
	-- Animate in
	frame.BackgroundTransparency = 1
	titleLabel.TextTransparency = 1
	TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
		BackgroundTransparency = 0.3
	}):Play()
	TweenService:Create(titleLabel, TweenInfo.new(0.5), {
		TextTransparency = 0
	}):Play()
	
	-- Auto dismiss
	task.delay(4, function()
		TweenService:Create(frame, TweenInfo.new(0.8), {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(titleLabel, TweenInfo.new(0.8), {
			TextTransparency = 1
		}):Play()
		task.wait(1)
		if celebrationGui.Parent then celebrationGui:Destroy() end
	end)
end

return NotificationController
