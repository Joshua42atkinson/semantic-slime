--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local Blueprint = require(ReplicatedStorage.Shared.TownBlueprint)

local TerrainService = Knit.CreateService {
    Name = "TerrainService",
    Client = {},
}

-- Constants
local SEED = workspace:GetAttribute("Seed") or tick()
local RESOLUTION = 4 -- Studs per voxel (4 is Roblox default)
local HEIGHT_SCALE = 50 -- Max height variance

function TerrainService:KnitStart()
    print("[TerrainService] Storage Initialized. Waiting for Map Generation...")
end

function TerrainService:GenerateWilderness(districtName: string, config: any, center: Vector3, direction: Vector3)
    local width = Blueprint.Settings.DistrictSize
    local depth = Blueprint.Settings.DistrictSize * 0.5 -- Wilderness is the back half
    
    -- Calculate offset to place wilderness "behind" the district center
    -- Direction is vector to center (e.g. 0,0,-1 for North). 
    -- We want to go FURTHER in that direction.
    local startPos = center + (direction * (width * 0.25)) 
    
    local corner = startPos - Vector3.new(width/2, 0, width/2)
    
    -- We will fill a region with organic terrain
    -- Using WriteVoxels is faster/cleaner for large chunks vs FillBlock
    
    local material = config.Biome or Enum.Material.Grass
    local scale = config.Scale or 100
    local roughness = config.Roughness or 20
    
    for x = -width/2, width/2, RESOLUTION do
        for z = -width/2, width/2, RESOLUTION do
            -- Convert to world space
            local wx = center.X + x
            local wz = center.Z + z
            
            -- Check if we are "deep" enough to be wilderness
            -- Simple dot product check: are we further out than the buildings?
            local vecToPoint = Vector3.new(wx, 0, wz)
            local dist = vecToPoint.Magnitude
            local centerDist = center.Magnitude
            
            if dist > centerDist + 50 then -- buffer zone
                local noiseVal = math.noise(wx / scale, wz / scale, SEED)
                local height = noiseVal * roughness
                
                -- Fade in height as we get further out
                local distFactor = math.clamp((dist - (centerDist + 50)) / 200, 0, 1)
                height = height * distFactor
                
                -- Base height (ensure it connects to flat ground)
                local y = -2 + height 
                
                if y > -5 then -- Only fill if above a threshold
                   Workspace.Terrain:FillBlock(CFrame.new(wx, y/2 - 4, wz), Vector3.new(RESOLUTION, y + 8, RESOLUTION), material)
                end
                
                -- Add some "Juice" - props or secondary materials
                if noiseVal > 0.6 then
                     Workspace.Terrain:FillBlock(CFrame.new(wx, y, wz), Vector3.new(RESOLUTION, 1, RESOLUTION), Enum.Material.Rock)
                end
            end
        end
        if x % 100 == 0 then task.wait() end -- Prevent freezing
    end
    
    print("[TerrainService] Generated Wilderness for " .. districtName)
end

function TerrainService:GenerateDungeonWalls()
    local center = Vector3.new(0, 0, 0)
    local radius = 700 -- Encase everything
    local height = 150
    local thickness = 100
    
    print("[TerrainService] Generating Dungeon Walls...")
    
    -- Optimize by stepping in chunks
    for x = -radius - thickness, radius + thickness, 8 do
        for z = -radius - thickness, radius + thickness, 8 do
            local dist = math.sqrt(x^2 + z^2)
            
            if dist > radius then
                -- Wall
                local noise = math.noise(x/100, z/100, SEED) * 50
                local wallHeight = height + noise
                
                -- Fade in wall from radius
                local alpha = math.clamp((dist - radius) / 50, 0, 1)
                local finalHeight = wallHeight * alpha
                
                if finalHeight > 5 then
                     Workspace.Terrain:FillBlock(
                        CFrame.new(x, finalHeight/2 - 20, z), 
                        Vector3.new(10, finalHeight + 40, 10), 
                        Enum.Material.Rock
                    )
                end
            end
        end
        if x % 100 == 0 then task.wait() end
    end
    print("[TerrainService] Dungeon Walls Complete.")
end

function TerrainService:Clear()
    Workspace.Terrain:Clear()
end

return TerrainService
