--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local DebugController = Knit.CreateController { Name = "DebugController" }

function DebugController:KnitStart()
	print("[DebugController] Started. Press 'G' to Jump to Slime. Press 'H' for God Mode.")
	
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		
		if input.KeyCode == Enum.KeyCode.G then
			self:JumpToSlime()
		elseif input.KeyCode == Enum.KeyCode.H then
			self:ToggleGodMode()
		end
	end)
end

function DebugController:JumpToSlime()
	local slimes = CollectionService:GetTagged("Slime")
	if #slimes == 0 then
		warn("No Slimes found!")
		return
	end
	
	local target = slimes[math.random(1, #slimes)]
	local root = target:FindFirstChild("RootPart")
	
	local player = Players.LocalPlayer
	local char = player.Character
	if char and char.PrimaryPart and root then
		char:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 5, 0))
		print("Jumped to: " .. target.Name)
	end
end

function DebugController:ToggleGodMode()
	local player = Players.LocalPlayer
	local char = player.Character
	if not char then return end
	
	local hum = char:FindFirstChild("Humanoid")
	if hum then
		if hum.WalkSpeed > 16 then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
			print("God Mode OFF")
		else
			hum.WalkSpeed = 100
			hum.JumpPower = 200
			print("God Mode ON")
		end
	end
end

return DebugController
