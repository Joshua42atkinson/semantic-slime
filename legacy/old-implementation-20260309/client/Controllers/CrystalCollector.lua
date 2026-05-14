--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local CrystalCollector = Knit.CreateController {
	Name = "CrystalCollector",
}

-- Remotes
local RemotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
local Remotes = (RemotesMod and RemotesMod:IsA("ModuleScript")) and require(RemotesMod) or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes", 10)
local CollectCrystalRF = Remotes:WaitForChild("CollectCrystal")
local GetInventoryRF = Remotes:WaitForChild("GetInventory")

-- State
local player = Players.LocalPlayer
local character = player.Character
local isCollecting = false

-- Known crystal positions from server
local knownCrystals: { [string]: Vector3 } = {}

function CrystalCollector:KnitStart()
	print("[CrystalCollector] Started.")
	
	-- Track character
	player.CharacterAdded:Connect(function(char)
		character = char
	end)
	
	-- Listen for crystal spawns from server
	local CrystalService = Knit.GetService("CrystalService")
	CrystalService.CrystalSpawned:Connect(function(crystalId, letter, position, rarity)
		knownCrystals[crystalId] = position
	end)
	
	CrystalService.CrystalCollected:Connect(function(playerWhoCollected, letter, rarity)
		-- Could show notification if it's the local player
	end)
	
	-- Start collection loop
	task.spawn(function()
		self:CollectionLoop()
	end)
end

function CrystalCollector:CollectionLoop()
	while true do
		task.wait(0.2) -- Check every 200ms
		
		if not character or not character:FindFirstChild("HumanoidRootPart") then
			continue
		end
		
		local hrp = character.HumanoidRootPart
		local playerPos = hrp.Position
		
		-- Check distance to known crystals
		for crystalId, crystalPos in pairs(knownCrystals) do
			local distance = (playerPos - crystalPos).Magnitude
			
			-- Collection range (5 studs)
			if distance < 5 then
				self:CollectCrystal(crystalId)
			end
		end
	end
end

function CrystalCollector:CollectCrystal(crystalId: string)
	if isCollecting then return end
	isCollecting = true
	
	-- Remove from known crystals immediately to prevent double collection
	knownCrystals[crystalId] = nil
	
	-- Call server
	local success, result = pcall(function()
		return CollectCrystalRF:InvokeServer(crystalId)
	end)
	
	if success and result then
		-- Show collection feedback
		self:ShowCollectionFeedback(result)
		
		-- Notify HUD
		local HUDController = Knit.GetController("HUDController")
		if HUDController and HUDController.ShowNotification then
			HUDController:ShowNotification("Collected " .. result.Letter .. " (" .. result.Rarity .. ")", 2)
		end
	else
		-- Crystal might have been collected by someone else
		warn("[CrystalCollector] Failed to collect crystal: " .. tostring(result))
	end
	
	task.wait(0.3) -- Small cooldown
	isCollecting = false
end

function CrystalCollector:ShowCollectionFeedback(result: { Letter: string, Rarity: string, NewCount: number })
	-- Create floating text effect
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	
	local hrp = character.HumanoidRootPart
	
	-- Create billboard for floating text
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(100, 40)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = hrp
	billboard.Parent = workspace
	
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = billboard
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Text = "+" .. result.Letter .. " (" .. result.Rarity .. ")"
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Font = Enum.Font.GothamBold
	text.TextSize = 16
	text.Parent = frame
	
	-- Float up and fade
	task.spawn(function()
		local startY = billboard.StudsOffset.Y
		for i = 1, 20 do
			billboard.StudsOffset = Vector3.new(0, startY + (i * 0.1), 0)
			frame.BackgroundTransparency = 0.5 + (i * 0.025)
			text.TextTransparency = i * 0.05
			task.wait(0.05)
		end
		billboard:Destroy()
	end)
end

-- Get player inventory (for UI)
function CrystalCollector:GetInventory()
	local success, result = pcall(function()
		return GetInventoryRF:InvokeServer()
	end)
	
	if success then
		return result
	end
	return {}
end

return CrystalCollector
