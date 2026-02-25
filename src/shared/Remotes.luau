local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = Instance.new("Folder")
Remotes.Name = "Remotes"
Remotes.Parent = ReplicatedStorage:WaitForChild("Shared")

local GameStateChanged = Instance.new("RemoteEvent")
GameStateChanged.Name = "GameStateChanged"
GameStateChanged.Parent = Remotes

return Remotes
