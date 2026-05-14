--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

-- Tracks semantic decay when letters are ignored or words are misspelled
local SlimeMyceliumService = Knit.CreateService {
	Name = "SlimeMyceliumService",
	Client = {
		MyceliumPulsed = Knit.CreateSignal(),
	},
}

-- The server-wide compost of meaning
local globalDecayMeter = 0
local decayPositions = {}

function SlimeMyceliumService:KnitStart()
	print("[SlimeMyceliumService] Subterranean Mycelium active.")
	
	-- Periodically check if decay breaches threshold
	task.spawn(function()
		while task.wait(10) do
			if globalDecayMeter > 100 then
				self:TriggerOutbreak()
			end
		end
	end)
end

function SlimeMyceliumService:AddDecay(player: Player, wordOrLetter: string, position: Vector3)
	local severity = #wordOrLetter
	globalDecayMeter += severity
	table.insert(decayPositions, position)
	
	print("[SlimeMyceliumService] Decay increased by " .. severity .. ". Current: " .. globalDecayMeter)
	self.Client.MyceliumPulsed:FireAll(position, severity)
end

function SlimeMyceliumService:TriggerOutbreak()
	print("[SlimeMyceliumService] MYCELIAL OUTBREAK!!! The ground shifts semantics.")
	globalDecayMeter = 0 -- Reset
	
	-- In an outbreak, the Mycelium erupts, turning the ground color and spawning feral typos everywhere
	-- For this implementation, we broadcast a global pulse
	self.Client.MyceliumPulsed:FireAll(Vector3.new(0,0,0), 100)
end

return SlimeMyceliumService
