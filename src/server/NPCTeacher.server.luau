--!strict
-- NPCTeacher.server.luau
-- Detects when a player is near Pete and shows/hides the [E] prompt

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig")
)

local remotes        = ReplicatedStorage:WaitForChild("Remotes")
local ShowPetePrompt = remotes:WaitForChild("ShowPetePrompt")

local INTERACT_DIST = GameConfig.INTERACT_DISTANCE
local NPC_NAME      = GameConfig.NPC_NAME

-- Track which players are currently near Pete
local nearPete: {[Player]: boolean} = {}

RunService.Heartbeat:Connect(function()
	local pete = workspace:FindFirstChild(NPC_NAME)
	if not pete then return end

	local peteRoot = pete:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not peteRoot then return end

	for _, player in Players:GetPlayers() do
		local char = player.Character
		if not char then continue end
		local root = char:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not root then continue end

		local dist = (root.Position - peteRoot.Position).Magnitude
		local isNear = dist <= INTERACT_DIST

		if isNear ~= nearPete[player] then
			nearPete[player] = isNear
			ShowPetePrompt:FireClient(player, isNear)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	nearPete[player] = nil
end)

print("[IronNet] NPCTeacher loaded ✓")
