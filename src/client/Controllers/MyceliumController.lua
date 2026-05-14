--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Renders the creeping, pulsing network of glowing typos / decay
local MyceliumController = Knit.CreateController {
	Name = "MyceliumController",
}

function MyceliumController:KnitStart()
	print("[MyceliumController] Listening for Subterranean Pulses...")
	
	local SlimeMyceliumService = Knit.GetService("SlimeMyceliumService")
	local FeralTypoService = Knit.GetService("FeralTypoService")
	
	if SlimeMyceliumService then
		SlimeMyceliumService.MyceliumPulsed:Connect(function(position, severity)
			self:RenderPulse(position, severity)
		end)
	end
	
	if FeralTypoService then
		FeralTypoService.FeralTypoSpawned:Connect(function(word, pos)
			self:RenderJumpScare(word, pos)
		end)
	end
end

function MyceliumController:RenderPulse(position: Vector3, severity: number)
	-- Grow a visual mycelium patch
	local patch = Instance.new("Part")
	patch.Name = "MyceliumPatch"
	patch.Size = Vector3.new(0.1, 0.1, 0.1)
	patch.Position = position - Vector3.new(0, 3, 0)
	patch.Anchored = true
	patch.CanCollide = false
	patch.Material = Enum.Material.Neon
	patch.Color = Color3.fromRGB(100, 0, 150)
	patch.Transparency = 0.5
	patch.Shape = Enum.PartType.Cylinder
	patch.Orientation = Vector3.new(0, 0, 90)
	patch.Parent = Workspace
	
	local TweenService = game:GetService("TweenService")
	local targetSize = severity * 2
	local tween = TweenService:Create(patch, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.5, targetSize, targetSize),
		Transparency = 0.8
	})
	tween:Play()
	
	game.Debris:AddItem(patch, 30)
end

function MyceliumController:RenderJumpScare(word: string, position: Vector3)
	-- Play a bizarre error sound
	local SoundService = game:GetService("SoundService")
	local errorSnd = Instance.new("Sound")
	errorSnd.SoundId = "rbxassetid://160432334" -- Standard buzz/error
	errorSnd.Volume = 0.5
	errorSnd.Parent = SoundService
	errorSnd:Play()
	game.Debris:AddItem(errorSnd, 2)
end

return MyceliumController
