--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local NuisanceController = Knit.CreateController { Name = "NuisanceController" }

local originalOutdoorAmbient: Color3
local alarmColorCorrection: ColorCorrectionEffect? = nil

function NuisanceController:KnitStart()
	print("[NuisanceController] Started.")
	
	-- Setup lighting effect
	originalOutdoorAmbient = Lighting.OutdoorAmbient
	
	alarmColorCorrection = Instance.new("ColorCorrectionEffect")
	alarmColorCorrection.Name = "NuisanceAlarm"
	alarmColorCorrection.TintColor = Color3.new(1, 1, 1)
	alarmColorCorrection.Parent = Lighting
	
	local GameLoopService = Knit.GetService("GameLoopService")
	
	GameLoopService.PhaseChanged:Connect(function(phase: string, duration: number)
		if phase == "Nuisance" then
			self:StartNuisanceEffects()
		else
			self:StopNuisanceEffects()
		end
	end)
	
	local LetterNuisanceService = Knit.GetService("LetterNuisanceService")
	if LetterNuisanceService then
		LetterNuisanceService.NuisanceCaptured:Connect(function(player: Player, letter: string)
			if player == Players.LocalPlayer then
				-- Play happy capture sound / visual
				local SoundController = Knit.GetController("SoundController")
				if SoundController then
					SoundController:Play("Victory")
				end
			end
		end)
		
		LetterNuisanceService.NuisanceDespawned:Connect(function(nuisanceId: string, captured: boolean, targetPlayerId: string?)
			-- If not captured, play hit effects if it was local player (directly notified or matched)
			if not captured and (targetPlayerId == tostring(Players.LocalPlayer.UserId) or not targetPlayerId) then
				local SoundController = Knit.GetController("SoundController")
				if SoundController then
					SoundController:Play("Error")
				end
				self:PlayHitEffect()
			end
		end)
	end
end

function NuisanceController:StartNuisanceEffects()
	if not alarmColorCorrection then return end
	
	-- Red tint pulsing
	local info = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(alarmColorCorrection, info, {
		TintColor = Color3.fromRGB(255, 180, 180)
	}):Play()
	
	local SoundController = Knit.GetController("SoundController")
	if SoundController then
		-- SoundController:Play("Alarm")
	end
end

function NuisanceController:StopNuisanceEffects()
	if not alarmColorCorrection then return end
	
	-- Stop tween
	local tweens = TweenService:GetTweensOf(alarmColorCorrection)
	for _, tween in ipairs(tweens) do
		tween:Cancel()
	end
	
	TweenService:Create(alarmColorCorrection, TweenInfo.new(1), {
		TintColor = Color3.new(1, 1, 1)
	}):Play()
end

function NuisanceController:PlayHitEffect()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "HitEffect"
	gui.Parent = playerGui
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(1, 0, 0)
	frame.BackgroundTransparency = 0.5
	frame.Parent = gui
	
	TweenService:Create(frame, TweenInfo.new(0.5), {
		BackgroundTransparency = 1
	}):Play()
	
	task.delay(0.5, function()
		gui:Destroy()
	end)
end

return NuisanceController
