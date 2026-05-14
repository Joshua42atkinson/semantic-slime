--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local TestController = Knit.CreateController { Name = "TestController" }

function TestController:KnitStart()
	print("[TestController] ✅ Client controller started!")
	
	-- Try to call server
	local TestService = Knit.GetService("TestService")
	if TestService then
		local result = TestService:TestConnection()
		print("[TestController] ✅ Server responded: " .. tostring(result.Success))
	end
end

return TestController
