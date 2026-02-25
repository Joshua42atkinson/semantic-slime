--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local PetService = Knit.CreateService {
    Name = "PetService",
    Client = {},
}

-- Config
local PET_OFFSET = Vector3.new(3, 4, 3) -- Behind and above

--[=[
    @private
    Gets or creates a basic Slime template.
]=]
function PetService:_getSlimeTemplate()
    local Assets = ReplicatedStorage:FindFirstChild("Assets")
    if not Assets then
        Assets = Instance.new("Folder")
        Assets.Name = "Assets"
        Assets.Parent = ReplicatedStorage
    end
    
    local template = Assets:FindFirstChild("Slime")
    if not template then
        -- Procedural fallback
        template = Instance.new("Part")
        template.Name = "Slime"
        template.Size = Vector3.new(1.5, 1.5, 1.5)
        template.Shape = Enum.PartType.Ball
        template.Material = Enum.Material.Neon
        template.Color = Color3.fromRGB(0, 255, 150)
        template.Transparency = 0.3
        template.CanCollide = false -- Important for pets to not push players
        template.CastShadow = false
        
        -- Add Attachment for AlignPosition
        local att = Instance.new("Attachment")
        att.Name = "BodyAttachment"
        att.Parent = template
        
        -- Add Eyes (Decal mock)
        local face = Instance.new("Decal")
        face.Texture = "rbxasset://textures/face.png" -- Default smile
        face.Face = Enum.NormalId.Front
        face.Parent = template
        
        template.Parent = Assets
    end
    return template
end

function PetService:SpawnPet(player: Player)
    -- Remove existing pet if any
    local character = player.Character
    if not character then return end
    
    local existing = workspace:FindFirstChild(player.Name .. "_Pet")
    if existing then existing:Destroy() end
    
    local template = self:_getSlimeTemplate()
    local pet = template:Clone()
    pet.Name = player.Name .. "_Pet"
    pet.CFrame = character:GetPivot() * CFrame.new(PET_OFFSET)
    
    -- Tag it so client can find it
    pet:SetAttribute("OwnerUserId", player.UserId)
    
    -- Parent to workspace
    pet.Parent = workspace
    
    -- Set Network Ownership to player for smooth client-side physics
    pet:SetNetworkOwner(player)
    
    print("[PetService] Spawned pet for " .. player.Name)
end

function PetService:KnitStart()
    print("[PetService] Started.")
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(char)
            -- Wait a moment for char to be ready
            task.wait(1)
            self:SpawnPet(player)
        end)
    end)
end

return PetService
