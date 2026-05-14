--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TestService = Knit.CreateService {
	Name = "TestService",
	Client = {},
}

function TestService:KnitStart()
	print("[TestService] ✅ Server service started successfully!")
	
	-- Test if we can access other services
	local CrystalService = Knit.GetService("CrystalService")
	print("[TestService] ✅ CrystalService accessible: " .. tostring(CrystalService ~= nil))
	
	local SlimeFactory = Knit.GetService("SlimeFactory")
	print("[TestService] ✅ SlimeFactory accessible: " .. tostring(SlimeFactory ~= nil))
	
	local GameLoopService = Knit.GetService("GameLoopService")
	print("[TestService] ✅ GameLoopService accessible: " .. tostring(GameLoopService ~= nil))
end

-- Remote function for client to test
function TestService.Client:TestConnection(player)
	print("[TestService] ✅ Client test connection from: " .. player.Name)
	return {
		Success = true,
		Message = "Server is working!",
	}
end

return TestService
