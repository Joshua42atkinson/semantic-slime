--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local PetController = Knit.CreateController {
    Name = "PetController",
}

local player = Players.LocalPlayer
local character = player.Character

-- Config
local PET_FLOAT_OFFSET = Vector3.new(3, 4, 3) -- Relative to HRP

function PetController:KnitStart()
    print("[PetController] Started.")
    
    player.CharacterAdded:Connect(function(char)
        character = char
        -- Check for existing pet
        self:CheckForPet()
    end)
    
    -- Listen for new pets spawning
    workspace.ChildAdded:Connect(function(child)
        if child.Name == player.Name .. "_Pet" then
            self:SetupPetPhysics(child)
        end
    end)
    
    self:CheckForPet()
end

function PetController:CheckForPet()
    local pet = workspace:FindFirstChild(player.Name .. "_Pet")
    if pet then
        self:SetupPetPhysics(pet)
    end
end

function PetController:SetupPetPhysics(pet: BasePart)
    if not character then return end
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Clean up old constraints if any
    local oldAlign = pet:FindFirstChild("PetAlignPosition")
    if oldAlign then oldAlign:Destroy() end
    
    local oldOrient = pet:FindFirstChild("PetAlignOrientation")
    if oldOrient then oldOrient:Destroy() end
    
    -- Create Attachments
    local petAtt = pet:FindFirstChild("BodyAttachment") or Instance.new("Attachment", pet)
    petAtt.Name = "BodyAttachment"
    
    local playerAtt = hrp:FindFirstChild("PetAttachment")
    if not playerAtt then
        playerAtt = Instance.new("Attachment")
        playerAtt.Name = "PetAttachment"
        playerAtt.Parent = hrp
        playerAtt.Position = PET_FLOAT_OFFSET -- Offset relative to HRP
    end
    
    -- Align Position
    local alignPos = Instance.new("AlignPosition")
    alignPos.Name = "PetAlignPosition"
    alignPos.Mode = Enum.PositionAlignmentMode.TwoAttachment
    alignPos.Attachment0 = petAtt
    alignPos.Attachment1 = playerAtt
    alignPos.RigidityEnabled = false
    alignPos.Responsiveness = 10
    alignPos.MaxForce = 10000
    alignPos.Parent = pet
    
    -- Align Orientation (Keep it upright but maybe let it bobble?)
    local alignOrient = Instance.new("AlignOrientation")
    alignOrient.Name = "PetAlignOrientation"
    alignOrient.Mode = Enum.OrientationAlignmentMode.TwoAttachment
    alignOrient.Attachment0 = petAtt
    alignOrient.Attachment1 = playerAtt
    alignOrient.RigidityEnabled = false
    alignOrient.Responsiveness = 5
    alignOrient.MaxTorque = 10000
    alignOrient.Parent = pet
    
    print("[PetController] Physics setup for " .. pet.Name)
end

return PetController
