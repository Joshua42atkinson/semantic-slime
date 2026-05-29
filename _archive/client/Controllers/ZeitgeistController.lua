--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- The ZeitgeistController listens for server-wide semantic phenomena
local ZeitgeistController = Knit.CreateController {
	Name = "ZeitgeistController",
}

function ZeitgeistController:KnitStart()
	print("[ZeitgeistController] Listening for Global Semantic Shifts...")
	
	local ZeitgeistService = Knit.GetService("ZeitgeistService")
	
	ZeitgeistService.ZeitgeistShifted:Connect(function(element)
		self:OnZeitgeistShift(element)
	end)
end

function ZeitgeistController:OnZeitgeistShift(element: string)
	print("[ZeitgeistController] Phenomenon Occurred: " .. element)
	
	local uiInfo = Instance.new("Message")
	uiInfo.Text = "THE SEMANTIC ZEITGEIST HAS SHIFTED TO: " .. element:upper()
	uiInfo.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	game.Debris:AddItem(uiInfo, 5)
	
	-- Dramatic screen shake
	local camera = workspace.CurrentCamera
	local startTime = os.clock()
	local connection
	connection = game:GetService("RunService").RenderStepped:Connect(function()
		local elapsed = os.clock() - startTime
		if elapsed > 2 then
			connection:Disconnect()
			return
		end
		local intensity = (2 - elapsed) * 2
		camera.CFrame = camera.CFrame * CFrame.Angles(
			math.rad((math.random()-0.5) * intensity),
			math.rad((math.random()-0.5) * intensity),
			math.rad((math.random()-0.5) * intensity)
		)
	end)
	
	-- Apply local lighting corrections (Server might do broad strokes, client adds finesse)
	local cc = Lighting:FindFirstChild("ZeitgeistCorrection") or Instance.new("ColorCorrectionEffect")
	cc.Name = "ZeitgeistCorrection"
	cc.Parent = Lighting
	
	if element == "Fire" then
		cc.TintColor = Color3.fromRGB(255, 200, 200)
		cc.Saturation = 0.5
		cc.Contrast = 0.2
	elseif element == "Shadow" then
		cc.TintColor = Color3.fromRGB(150, 150, 255)
		cc.Saturation = -0.3
		cc.Contrast = 0.5
	elseif element == "Water" then
		cc.TintColor = Color3.fromRGB(180, 220, 255)
		cc.Saturation = 0.2
		cc.Contrast = -0.1
	else
		-- Neutralize
		cc.TintColor = Color3.new(1,1,1)
		cc.Saturation = 0
		cc.Contrast = 0
	end
end

return ZeitgeistController
