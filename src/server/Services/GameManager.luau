--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes")
local GameStateChanged = Remotes:WaitForChild("GameStateChanged")

local GameManager = {}

-- State
local State = "Lobby"
local Timer = 0
local PlayersInRound = {}

-- Constants
local MIN_PLAYERS = 2
local ROUND_TIME = 300
local INTERMISSION_TIME = 10

function GameManager:Start()
	task.spawn(function()
		while true do
			self:GameLoop()
			task.wait(1)
		end
	end)
end

function GameManager:GameLoop()
	if State == "Lobby" then
		if #Players:GetPlayers() >= MIN_PLAYERS then
			self:SetState("Intermission")
		end
	elseif State == "Intermission" then
		Timer = Timer - 1
		if Timer <= 0 then
			self:SetState("Round")
		end
	elseif State == "Round" then
		Timer = Timer - 1
		if Timer <= 0 then
			self:SetState("Lobby")
		end
	end
end

function GameManager:SetState(newState: string)
	State = newState
	if newState == "Intermission" then
		Timer = INTERMISSION_TIME
	elseif newState == "Round" then
		Timer = ROUND_TIME
	else
		Timer = 0
	end
	
	print("State changed to:", State)
	GameStateChanged:FireAllClients(State, Timer)
end

return GameManager
