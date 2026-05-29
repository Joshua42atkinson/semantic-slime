--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- The Semantic Zeitgeist tracks the server's holistic emotional and elemental sum of created words
local ZeitgeistService = Knit.CreateService {
	Name = "ZeitgeistService",
	Client = {
		ZeitgeistShifted = Knit.CreateSignal(),
	},
}

local ElementalWeights = {
	Fire = 0, Water = 0, Earth = 0, Air = 0, Shadow = 0, Light = 0, Normal = 0
}

function ZeitgeistService:KnitStart()
	print("[ZeitgeistService] Global Semantics tracking started.")
	
	-- Periodically check for dominant Zeitgeist
	task.spawn(function()
		while task.wait(30) do
			self:EvaluateZeitgeist()
		end
	end)
end

function ZeitgeistService:RecordSemanticEvent(eventType: string, element: string, word: string)
	if ElementalWeights[element] then
		ElementalWeights[element] += 1
		print("[ZeitgeistService] Global " .. element .. " increased by word: " .. word)
	end
end

function ZeitgeistService:EvaluateZeitgeist()
	local maxElement = "Normal"
	local maxVal = -1
	
	for el, val in pairs(ElementalWeights) do
		if val > maxVal then
			maxVal = val
			maxElement = el
		end
	end
	
	if maxVal >= 5 then -- Threshold for a shift
		print("[ZeitgeistService] THE ZEITGEIST SHIFTS TO: " .. maxElement:upper())
		
		-- Modify lighting based on Zeitgeist
		if maxElement == "Fire" then
			Lighting.Ambient = Color3.fromRGB(255, 100, 100)
			Lighting.ColorShift_Top = Color3.fromRGB(255, 50, 0)
		elseif maxElement == "Shadow" then
			Lighting.Ambient = Color3.fromRGB(50, 0, 100)
			Lighting.ClockTime = 0
		elseif maxElement == "Light" then
			Lighting.Ambient = Color3.fromRGB(255, 255, 200)
			Lighting.ClockTime = 12
		end
		
		self.Client.ZeitgeistShifted:FireAll(maxElement)
		
		-- Reset weights after shift
		for el, _ in pairs(ElementalWeights) do
			ElementalWeights[el] = 0
		end
	end
end

return ZeitgeistService
