--!strict
-- NPCTeacher.server.luau
-- Detects when a player is near Pete and shows/hides the [E] prompt

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(
	ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig")
)

local Shared  = ReplicatedStorage:WaitForChild("Shared", 10)
local remotes = Shared and Shared:WaitForChild("Remotes", 10)

if not remotes then
	warn("[NPCTeacher] Remotes folder not found - NPC proximity prompts disabled.")
	return
end

local ShowPetePrompt = remotes:FindFirstChild("ShowPetePrompt")
if not ShowPetePrompt then
	-- Create it if Boot hasn't run yet (race condition safety)
	ShowPetePrompt = Instance.new("RemoteEvent")
	ShowPetePrompt.Name = "ShowPetePrompt"
	ShowPetePrompt.Parent = remotes
end


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
