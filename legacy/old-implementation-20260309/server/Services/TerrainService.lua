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

-- Enhanced noise functions for more natural terrain
local function fbm(x: number, z: number, octaves: number, persistence: number, lacunarity: number): number
    local total = 0
    local frequency = 1
    local amplitude = 1
    local maxValue = 0
    
    for i = 1, octaves do
        total += math.noise(x * frequency, z * frequency, SEED + i * 100) * amplitude
        maxValue += amplitude
        amplitude *= persistence
        frequency *= lacunarity
    end
    
    return total / maxValue
end

-- Generate a grand, impressive tree with multiple foliage layers
local function generateGrandTree(parent: Instance, position: Vector3, sizeMultiplier: number, treeType: string)
    local treeModel = Instance.new("Model")
    treeModel.Name = "GrandTree"
    
    local baseHeight = 40 + math.random(30) -- Much taller: 40-70 studs
    local trunkWidth = 5 + math.random(4) -- Thicker trunks: 5-9 studs
    local actualHeight = baseHeight * sizeMultiplier
    local actualTrunkWidth = trunkWidth * sizeMultiplier
    
    -- Trunk with texture variation
    local trunk = Instance.new("Part")
    trunk.Name = "Trunk"
    trunk.Size = Vector3.new(actualTrunkWidth, actualHeight, actualTrunkWidth)
    trunk.Position = position + Vector3.new(0, actualHeight / 2, 0)
    trunk.Anchored = true
    trunk.Material = Enum.Material.Wood
    
    -- Vary trunk color based on tree type
    local trunkColors = {
        Oak = Color3.fromHex("#5D4037"),
        Pine = Color3.fromHex("#4E342E"),
        Birch = Color3.fromHex("#D7CCC8"),
        Willow = Color3.fromHex("#6D4C41"),
        Autumn = Color3.fromHex("#5D4037"),
    }
    trunk.Color = trunkColors[treeType] or Color3.fromHex("#5D4037")
    trunk.Parent = treeModel
    
    -- Roots (visible base spread)
    for i = 1, 4 do
        local root = Instance.new("Part")
        root.Name = "Root_" .. i
        local angle = (i - 1) * math.pi / 2
        local rootLength = actualTrunkWidth * 2
        root.Size = Vector3.new(rootLength, 3, actualTrunkWidth * 0.6)
        root.CFrame = CFrame.new(position + Vector3.new(math.cos(angle) * rootLength/2, 1.5, math.sin(angle) * rootLength/2))
            * CFrame.Angles(0, angle, math.rad(20))
        root.Anchored = true
        root.Material = trunk.Material
        root.Color = trunk.Color
        root.Parent = treeModel
    end
    
    -- Foliage colors based on tree type
    local foliageColors = {
        Oak = { Color3.fromHex("#2E7D32"), Color3.fromHex("#388E3C"), Color3.fromHex("#43A047") },
        Pine = { Color3.fromHex("#1B5E20"), Color3.fromHex("#2E7D32"), Color3.fromHex("#1B5E20") },
        Birch = { Color3.fromHex("#66BB6A"), Color3.fromHex("#81C784"), Color3.fromHex("#A5D6A7") },
        Willow = { Color3.fromHex("#4CAF50"), Color3.fromHex("#66BB6A"), Color3.fromHex("#81C784") },
        Autumn = { Color3.fromHex("#E65100"), Color3.fromHex("#F57C00"), Color3.fromHex("#FF9800"), Color3.fromHex("#FFC107") },
    }
    local colors = foliageColors[treeType] or foliageColors.Oak
    
    -- Multi-layered foliage for full, impressive canopy
    if treeType == "Pine" then
        -- Pine tree: stacked cone shapes
        for layer = 1, 5 do
            local cone = Instance.new("Part")
            cone.Name = "Foliage_Layer_" .. layer
            cone.Shape = Enum.PartType.Ball
            local layerSize = (25 - layer * 3) * sizeMultiplier
            cone.Size = Vector3.new(layerSize, layerSize * 0.6, layerSize)
            cone.Position = position + Vector3.new(0, actualHeight - 5 + layer * 8, 0)
            cone.Anchored = true
            cone.Material = Enum.Material.Grass
            cone.Color = colors[math.random(1, #colors)]
            cone.Parent = treeModel
        end
    elseif treeType == "Willow" then
        -- Willow: drooping foliage
        local mainCanopy = Instance.new("Part")
        mainCanopy.Name = "MainCanopy"
        mainCanopy.Shape = Enum.PartType.Ball
        mainCanopy.Size = Vector3.new(35, 25, 35) * sizeMultiplier
        mainCanopy.Position = position + Vector3.new(0, actualHeight + 5, 0)
        mainCanopy.Anchored = true
        mainCanopy.Material = Enum.Material.Grass
        mainCanopy.Color = colors[1]
        mainCanopy.Parent = treeModel
        
        -- Drooping branches
        for i = 1, 12 do
            local angle = (i / 12) * math.pi * 2
            local branch = Instance.new("Part")
            branch.Name = "WillowBranch_" .. i
            branch.Size = Vector3.new(1, 25 * sizeMultiplier, 1)
            branch.CFrame = CFrame.new(
                position + Vector3.new(math.cos(angle) * 12, actualHeight - 5, math.sin(angle) * 12)
            ) * CFrame.Angles(math.rad(30), 0, 0)
            branch.Anchored = true
            branch.Material = Enum.Material.Grass
            branch.Color = colors[math.random(1, #colors)]
            branch.Parent = treeModel
        end
    else
        -- Oak/Autumn/Birch: large rounded canopy with multiple clusters
        local canopyLayers = {
            { Size = 30, Y = actualHeight + 5, X = 0, Z = 0 },
            { Size = 25, Y = actualHeight + 15, X = 8, Z = 5 },
            { Size = 25, Y = actualHeight + 15, X = -8, Z = -5 },
            { Size = 22, Y = actualHeight + 12, X = 5, Z = -8 },
            { Size = 22, Y = actualHeight + 12, X = -5, Z = 8 },
            { Size = 20, Y = actualHeight + 25, X = 0, Z = 0 },
            { Size = 15, Y = actualHeight + 32, X = 3, Z = 3 },
        }
        
        for i, layer in ipairs(canopyLayers) do
            local foliage = Instance.new("Part")
            foliage.Name = "Foliage_Cluster_" .. i
            foliage.Shape = Enum.PartType.Ball
            foliage.Size = Vector3.new(layer.Size, layer.Size, layer.Size) * sizeMultiplier
            foliage.Position = position + Vector3.new(layer.X, layer.Y, layer.Z) * sizeMultiplier
            foliage.Anchored = true
            foliage.Material = Enum.Material.Grass
            foliage.Color = colors[math.random(1, #colors)]
            foliage.Parent = treeModel
        end
    end
    
    -- Add subtle point light for atmosphere (parented to trunk part)
    local canopyLight = Instance.new("PointLight")
    canopyLight.Color = Color3.fromRGB(200, 255, 200)
    canopyLight.Brightness = 0.3
    canopyLight.Range = 30 * sizeMultiplier
    canopyLight.Parent = trunk
    
    treeModel.Parent = parent
    return treeModel
end

-- Generate decorative walkways connecting areas
local function generateWalkway(parent: Instance, startPos: Vector3, endPos: Vector3, width: number, style: string)
    local walkwayModel = Instance.new("Model")
    walkwayModel.Name = "Walkway"
    
    local direction = (endPos - startPos)
    local length = direction.Magnitude
    local midPoint = startPos + direction / 2
    
    -- Main path
    local path = Instance.new("Part")
    path.Name = "Path"
    path.Size = Vector3.new(width, 1, length)
    path.CFrame = CFrame.lookAt(midPoint + Vector3.new(0, 0.5, 0), endPos)
    path.Anchored = true
    
    -- Style-based materials
    local pathStyles = {
        Cobblestone = { Material = Enum.Material.Cobblestone, Color = Color3.fromHex("#9E9E9E") },
        Brick = { Material = Enum.Material.Brick, Color = Color3.fromHex("#8D6E63") },
        Marble = { Material = Enum.Material.Marble, Color = Color3.fromHex("#ECEFF1") },
        Sandstone = { Material = Enum.Material.Sandstone, Color = Color3.fromHex("#D7CCC8") },
        Slate = { Material = Enum.Material.Slate, Color = Color3.fromHex("#546E7A") },
    }
    local styleData = pathStyles[style] or pathStyles.Cobblestone
    path.Material = styleData.Material
    path.Color = styleData.Color
    path.Parent = walkwayModel
    
    -- Path edges
    for side = -1, 1, 2 do
        local edge = Instance.new("Part")
        edge.Name = "PathEdge_" .. side
        edge.Size = Vector3.new(1, 2, length)
        edge.CFrame = CFrame.lookAt(midPoint + Vector3.new(side * (width/2 + 0.5), 1, 0), endPos)
        edge.Anchored = true
        edge.Material = Enum.Material.Rock
        edge.Color = styleData.Color:Lerp(Color3.new(0, 0, 0), 0.2)
        edge.Parent = walkwayModel
    end
    
    -- Lamp posts along the walkway
    local lampSpacing = 40
    local numLamps = math.floor(length / lampSpacing)
    for i = 0, numLamps do
        local t = i / math.max(numLamps, 1)
        local lampPos = startPos:Lerp(endPos, t)
        local side = (i % 2 == 0) and 1 or -1
        
        -- Lamp post
        local post = Instance.new("Part")
        post.Name = "LampPost_" .. i
        post.Size = Vector3.new(2, 18, 2)
        post.Position = lampPos + Vector3.new(side * (width/2 + 3), 9, 0)
        post.CFrame = CFrame.new(post.Position, endPos)
        post.Anchored = true
        post.Material = Enum.Material.Metal
        post.Color = Color3.fromHex("#37474F")
        post.Parent = walkwayModel
        
        -- Lamp light
        local lamp = Instance.new("Part")
        lamp.Name = "Lamp_" .. i
        lamp.Shape = Enum.PartType.Ball
        lamp.Size = Vector3.new(5, 5, 5)
        lamp.Position = post.Position + Vector3.new(0, 10, 0)
        lamp.Anchored = true
        lamp.Material = Enum.Material.Neon
        lamp.Color = Color3.fromHex("#FFF9C4")
        lamp.Parent = walkwayModel
        
        local light = Instance.new("PointLight")
        light.Color = Color3.fromHex("#FFF9C4")
        light.Brightness = 1.5
        light.Range = 35
        light.Parent = lamp
    end
    
    walkwayModel.Parent = parent
    return walkwayModel
end

-- Generate beautiful landscape features with grand trees
local function generateLandscapeFeatures(districtName: string, config: any, center: Vector3, direction: Vector3)
    local width = Blueprint.Settings.DistrictSize
    local featureFolder = Instance.new("Folder")
    featureFolder.Name = districtName .. "_Landscape"
    featureFolder.Parent = Workspace
    
    local scale = config.Scale or 100
    local roughness = config.Roughness or 20
    
    -- District-specific tree types
    local treeTypes = {
        BrainyBorough = { "Oak", "Birch" },
        HeartwoodGrove = { "Willow", "Oak", "Autumn" },
        WhisperWinds = { "Birch", "Pine" },
        ActionAlley = { "Pine", "Oak" },
    }
    local districtTrees = treeTypes[districtName] or { "Oak", "Pine" }
    
    -- Generate GRAND TREES (fewer but much more impressive)
    local grandTreeCount = 12 + math.random(8) -- Fewer but bigger trees
    local treePositions = {}
    
    for i = 1, grandTreeCount do
        local x = (math.random() - 0.5) * width * 0.75
        local z = (math.random() - 0.5) * width * 0.75
        
        local worldX = center.X + x
        local worldZ = center.Z + z
        local height = fbm(worldX / scale, worldZ / scale, 4, 0.5, 2) * roughness
        
        if height > -5 and height < roughness * 0.7 then
            -- Check minimum distance from other trees
            local tooClose = false
            for _, pos in ipairs(treePositions) do
                local dist = math.sqrt((pos.X - x)^2 + (pos.Z - z)^2)
                if dist < 50 then -- Minimum 50 studs between grand trees
                    tooClose = true
                    break
                end
            end
            
            if not tooClose then
                table.insert(treePositions, {
                    X = x,
                    Z = z,
                    Height = height,
                    Size = 0.8 + math.random() * 0.5,
                    Type = districtTrees[math.random(1, #districtTrees)],
                })
            end
        end
    end
    
    -- Spawn grand trees
    for _, pos in ipairs(treePositions) do
        local treePos = center + Vector3.new(pos.X, pos.Height - 5, pos.Z)
        generateGrandTree(featureFolder, treePos, pos.Size, pos.Type)
    end
    
    -- Generate bush clusters (more varied)
    local bushCount = 40 + math.random(25)
    for i = 1, bushCount do
        local x = (math.random() - 0.5) * width * 0.85
        local z = (math.random() - 0.5) * width * 0.85
        local worldX = center.X + x
        local worldZ = center.Z + z
        local height = fbm(worldX / scale, worldZ / scale, 4, 0.5, 2) * roughness
        
        -- Bush cluster (multiple parts)
        local clusterSize = 1 + math.random(3)
        for j = 1, clusterSize do
            local bush = Instance.new("Part")
            bush.Name = "Bush"
            bush.Shape = Enum.PartType.Ball
            local size = 3 + math.random(5)
            bush.Size = Vector3.new(size, size * 0.7, size)
            bush.Position = center + Vector3.new(
                x + (math.random() - 0.5) * 4,
                height - 5 + size/2,
                z + (math.random() - 0.5) * 4
            )
            bush.Anchored = true
            bush.Material = Enum.Material.Grass
            bush.Color = Color3.fromHex("#388E3C"):Lerp(Color3.fromHex("#66BB6A"), math.random())
            bush.Parent = featureFolder
        end
    end
    
    -- Generate decorative rocks (more varied shapes)
    local rockCount = 15 + math.random(10)
    for i = 1, rockCount do
        local x = (math.random() - 0.5) * width * 0.85
        local z = (math.random() - 0.5) * width * 0.85
        local worldX = center.X + x
        local worldZ = center.Z + z
        local height = fbm(worldX / scale, worldZ / scale, 4, 0.5, 2) * roughness
        
        -- Rock cluster
        local clusterSize = 1 + math.random(2)
        for j = 1, clusterSize do
            local rock = Instance.new("Part")
            rock.Name = "Rock"
            rock.Size = Vector3.new(
                4 + math.random(8),
                3 + math.random(5),
                4 + math.random(8)
            )
            rock.Position = center + Vector3.new(
                x + (math.random() - 0.5) * 3,
                height - 5 + rock.Size.Y/2,
                z + (math.random() - 0.5) * 3
            )
            rock.Anchored = true
            rock.Material = Enum.Material.Rock
            rock.Color = Color3.fromRGB(
                80 + math.random(40),
                80 + math.random(30),
                70 + math.random(30)
            )
            rock.Orientation = Vector3.new(
                math.random(-20, 20),
                math.random(0, 360),
                math.random(-20, 20)
            )
            rock.Parent = featureFolder
        end
    end
    
    -- Generate flower beds (clustered, more natural)
    local flowerColors = {
        Color3.fromHex("#E91E63"),
        Color3.fromHex("#9C27B0"),
        Color3.fromHex("#FFEB3B"),
        Color3.fromHex("#FF5722"),
        Color3.fromHex("#03A9F4"),
        Color3.fromHex("#F44336"),
        Color3.fromHex("#E040FB"),
        Color3.fromHex("#00BCD4"),
    }
    
    local flowerBedCount = 8 + math.random(6)
    for i = 1, flowerBedCount do
        local bedX = (math.random() - 0.5) * width * 0.8
        local bedZ = (math.random() - 0.5) * width * 0.8
        local worldX = center.X + bedX
        local worldZ = center.Z + bedZ
        local height = fbm(worldX / scale, worldZ / scale, 4, 0.5, 2) * roughness
        
        -- Flower bed base
        local bed = Instance.new("Part")
        bed.Name = "FlowerBed"
        bed.Size = Vector3.new(8, 1, 8)
        bed.Position = center + Vector3.new(bedX, height - 4.5, bedZ)
        bed.Anchored = true
        bed.Material = Enum.Material.Sand
        bed.Color = Color3.fromHex("#5D4037")
        bed.Parent = featureFolder
        
        -- Flowers in bed
        local flowerCount = 5 + math.random(8)
        local bedColor = flowerColors[math.random(1, #flowerColors)]
        for j = 1, flowerCount do
            local flower = Instance.new("Part")
            flower.Name = "Flower"
            flower.Shape = Enum.PartType.Ball
            flower.Size = Vector3.new(1.5, 1.5, 1.5)
            flower.Position = center + Vector3.new(
                bedX + (math.random() - 0.5) * 6,
                height - 4,
                bedZ + (math.random() - 0.5) * 6
            )
            flower.Anchored = true
            flower.Material = Enum.Material.Neon
            flower.Color = bedColor
            flower.Transparency = 0.2
            flower.Parent = featureFolder
            
            -- Flower stem
            local stem = Instance.new("Part")
            stem.Name = "Stem"
            stem.Size = Vector3.new(0.3, 2, 0.3)
            stem.Position = flower.Position - Vector3.new(0, 1.5, 0)
            stem.Anchored = true
            stem.Material = Enum.Material.Grass
            stem.Color = Color3.fromHex("#2E7D32")
            stem.Parent = featureFolder
        end
    end
    
    -- Generate ponds/lakes with decorative features
    if config.HasWater then
        local pondCount = 2 + math.random(2)
        for i = 1, pondCount do
            local x = (math.random() - 0.5) * width * 0.5
            local z = (math.random() - 0.5) * width * 0.5
            local worldX = center.X + x
            local worldZ = center.Z + z
            local height = fbm(worldX / scale, worldZ / scale, 4, 0.5, 2) * roughness
            
            if height < -roughness * 0.15 then
                local pondSize = 25 + math.random(20)
                
                -- Pond water
                local pond = Instance.new("Part")
                pond.Name = "Pond"
                pond.Shape = Enum.PartType.Cylinder
                pond.Size = Vector3.new(2, pondSize, pondSize * 0.8)
                pond.Position = center + Vector3.new(x, -5, z)
                pond.Orientation = Vector3.new(0, 0, 90)
                pond.Anchored = true
                pond.Material = Enum.Material.Water
                pond.Color = Color3.fromHex("#0288D1")
                pond.Transparency = 0.3
                pond.Parent = featureFolder
                
                -- Pond edge stones
                for j = 1, 12 do
                    local angle = (j / 12) * math.pi * 2
                    local stone = Instance.new("Part")
                    stone.Name = "PondStone"
                    stone.Size = Vector3.new(3 + math.random(3), 2 + math.random(2), 3 + math.random(3))
                    stone.Position = center + Vector3.new(
                        x + math.cos(angle) * (pondSize/2 + 2),
                        -4,
                        z + math.sin(angle) * (pondSize * 0.4 + 2)
                    )
                    stone.Anchored = true
                    stone.Material = Enum.Material.Rock
                    stone.Color = Color3.fromRGB(100 + math.random(30), 100 + math.random(20), 90 + math.random(20))
                    stone.Orientation = Vector3.new(math.random(-15, 15), math.random(0, 360), math.random(-15, 15))
                    stone.Parent = featureFolder
                end
                
                -- Lily pads
                for j = 1, 4 do
                    local lily = Instance.new("Part")
                    lily.Name = "LilyPad"
                    lily.Shape = Enum.PartType.Cylinder
                    lily.Size = Vector3.new(0.5, 4, 4)
                    lily.Position = center + Vector3.new(
                        x + (math.random() - 0.5) * pondSize * 0.5,
                        -4,
                        z + (math.random() - 0.5) * pondSize * 0.3
                    )
                    lily.Orientation = Vector3.new(0, 0, 90)
                    lily.Anchored = true
                    lily.Material = Enum.Material.Grass
                    lily.Color = Color3.fromHex("#4CAF50")
                    lily.Parent = featureFolder
                end
            end
        end
    end
    
    -- Generate decorative walkways within the district
    local walkwayStyle = "Cobblestone"
    if districtName == "BrainyBorough" then walkwayStyle = "Marble"
    elseif districtName == "WhisperWinds" then walkwayStyle = "Sandstone"
    elseif districtName == "ActionAlley" then walkwayStyle = "Slate"
    elseif districtName == "HeartwoodGrove" then walkwayStyle = "Brick" end
    
    -- Main walkway from district entrance toward center
    local entrancePos = center - direction * (width * 0.25)
    local centerPos = center
    generateWalkway(featureFolder, entrancePos, centerPos, 12, walkwayStyle)
    
    print("[TerrainService] Generated enhanced landscape features for " .. districtName)
end

function TerrainService:KnitStart()
    -- Base layer is now called manually by TownGenerator to ensure it's not cleared
    print("[TerrainService] Service Started.")
end

-- [SAFETY] Fill any gaps in the city area to prevent falling through
function TerrainService:FillCityGaps()
    print("[TerrainService] Filling city gaps for safety...")
    
    local cityRadius = 1500 -- Covers the main expansive play area
    local resolution = 8
    
    for x = -cityRadius, cityRadius, resolution do
        for z = -cityRadius, cityRadius, resolution do
            local dist = math.sqrt(x^2 + z^2)
            
            if dist < cityRadius then
                -- Fill from the safety floor up to a solid base
                -- This ensures no gaps between terrain features
                Workspace.Terrain:FillBlock(
                    CFrame.new(x, -30, z),
                    Vector3.new(resolution, 60, resolution),
                    Enum.Material.Grass
                )
            end
        end
        if x % 160 == 0 then task.wait() end
    end
    
    print("[TerrainService] City gaps filled - play area is now fully solid.")
end

-- [SAFETY] Verify no gaps exist in the playable area
function TerrainService:VerifyTerrainIntegrity(): boolean
    print("[TerrainService] Verifying terrain integrity...")
    
    local testPoints = {
        Vector3.new(0, 0, 0),      -- Town center
        Vector3.new(200, 0, 0),     -- District edge
        Vector3.new(-200, 0, 0),    -- District edge
        Vector3.new(0, 0, 200),     -- District edge
        Vector3.new(0, 0, -200),    -- District edge
        Vector3.new(300, 0, 300),   -- Wilderness
        Vector3.new(-300, 0, -300), -- Wilderness
    }
    
    local ray = Ray.new(Vector3.new(0, 100, 0), Vector3.new(0, -1, 0))
    
    for _, point in ipairs(testPoints) do
        ray = Ray.new(point + Vector3.new(0, 50, 0), Vector3.new(0, -1, 0))
        local hit = Workspace:Raycast(ray.Origin, ray.Direction, RaycastParams.new())
        
        if not hit then
            warn("[TerrainService] WARNING: Gap detected at " .. tostring(point))
            return false
        end
    end
    
    print("[TerrainService] Terrain integrity verified - no gaps found!")
    return true
end

function TerrainService:GenerateBaseLayer()
    print("[TerrainService] Generating base grass layer...")
    -- Cover the entire expansive world with grass from -1500 to +1500
    local mapSize = 3000 
    local resolution = 8 -- Larger blocks for base layer
    local scale = 300
    local richness = 10
    
    for x = -mapSize/2, mapSize/2, resolution do
        for z = -mapSize/2, mapSize/2, resolution do
            -- Add subtle natural roll to the base terrain
            local noiseVal = fbm(x / scale, z / scale, 3, 0.5, 2)
            local height = noiseVal * richness
            
            Workspace.Terrain:FillBlock(
                CFrame.new(x, -15 + height / 2, z),
                Vector3.new(resolution, 20 + height, resolution),
                Enum.Material.Grass
            )
        end
        if x % 160 == 0 then task.wait() end
    end
    print("[TerrainService] Base grass layer complete.")
    print("[TerrainService] Storage Initialized. Waiting for Map Generation...")
end

function TerrainService:GenerateWilderness(districtName: string, config: any, center: Vector3, direction: Vector3)
    local width = Blueprint.Settings.DistrictSize
    local citySize = Blueprint.Settings.DistrictSize * Blueprint.Settings.CityPadRatio
    local wildernessStart = citySize / 2 + 20 -- Start wilderness 20 studs past city edge
    
    local material = config.Biome or Enum.Material.Grass
    local scale = config.Scale or 100
    local roughness = config.Roughness or 20
    
    print("[TerrainService] Generating wilderness for " .. districtName .. " starting at " .. wildernessStart .. " studs from center")
    
    -- Multi-pass terrain generation for more interesting features
    -- Pass 1: Base terrain with varied heights
    -- Generate in a box around the district center, extending outward
    local searchRadius = width / 2
    
    for x = -searchRadius, searchRadius, RESOLUTION do
        for z = -searchRadius, searchRadius, RESOLUTION do
            local wx = center.X + x
            local wz = center.Z + z
            
            -- Calculate distance from district center
            local distFromCenter = math.sqrt(x * x + z * z)
            
            -- Only generate terrain in the wilderness area (beyond city pad)
            if distFromCenter > wildernessStart then
                -- Use multi-octave noise for more natural terrain
                local noiseVal = fbm(wx / scale, wz / scale, 4, 0.5, 2)
                local height = noiseVal * roughness
                
                -- Add secondary noise for micro-variation
                local microNoise = math.noise(wx / 30, wz / 30, SEED + 500) * 5
                height = height + microNoise
                
                -- Fade in height as we get further into wilderness
                local distFactor = math.clamp((distFromCenter - wildernessStart) / 200, 0, 1)
                height = height * distFactor
                
                local baseY = -2
                local topY = baseY + math.max(0, height)

                -- CRITICAL: Always fill a solid base layer ALL THE WAY DOWN to -25
                -- This ensures no gaps between terrain and safety floor
                Workspace.Terrain:FillBlock(
                    CFrame.new(wx, -25, wz),
                    Vector3.new(RESOLUTION, 50, RESOLUTION),
                    material
                )
                
                -- Solid base fill
                Workspace.Terrain:FillBlock(
                    CFrame.new(wx, baseY - 4, wz),
                    Vector3.new(RESOLUTION, 8, RESOLUTION),
                    material
                )

                -- Height topper for organic bumps
                if height > 2 then
                    Workspace.Terrain:FillBlock(
                        CFrame.new(wx, baseY + height / 2, wz),
                        Vector3.new(RESOLUTION, height, RESOLUTION),
                        material
                    )
                end

                -- Accent features based on terrain height
                if noiseVal > 0.55 then
                    -- Rocky peaks
                    Workspace.Terrain:FillBlock(
                        CFrame.new(wx, topY, wz),
                        Vector3.new(RESOLUTION, 2, RESOLUTION),
                        Enum.Material.Rock
                    )
                elseif noiseVal < -0.4 then
                    -- Valley pools/water
                    Workspace.Terrain:FillBlock(
                        CFrame.new(wx, -5, wz),
                        Vector3.new(RESOLUTION, 1, RESOLUTION),
                        Enum.Material.Water
                    )
                end
            end
        end
        if x % 80 == 0 then task.wait() end
    end
    
    -- Pass 2: Add decorative surface detail (only in wilderness area)
    local detailRadius = width / 2
    for x = -detailRadius, detailRadius, RESOLUTION * 2 do
        for z = -detailRadius, detailRadius, RESOLUTION * 2 do
            local wx = center.X + x
            local wz = center.Z + z
            
            -- Calculate distance from district center
            local distFromCenter = math.sqrt(x * x + z * z)
            
            -- Only add details in wilderness area
            if distFromCenter > wildernessStart then
                local noiseVal = fbm(wx / scale, wz / scale, 4, 0.5, 2)
                
                -- Add grass tufts on good terrain
                if noiseVal > -0.2 and noiseVal < 0.4 then
                    if math.random() > 0.7 then
                        Workspace.Terrain:FillBlock(
                            CFrame.new(wx, 1, wz),
                            Vector3.new(1, 1, 1),
                            Enum.Material.Grass
                        )
                    end
                end
            end
        end
    end
    
    -- Generate landscape features (trees, bushes, flowers)
    task.spawn(function()
        generateLandscapeFeatures(districtName, config, center, direction)
    end)
    
    print("[TerrainService] Generated Wilderness for " .. districtName)
end

function TerrainService:GenerateDungeonWalls()
    local center = Vector3.new(0, 0, 0)
    local radius = 1600 -- Encase the new huge map
    local height = 150
    local thickness = 100
    
    print("[TerrainService] Generating Dungeon Walls...")
    
    -- Generate more interesting walls with variation
    for x = -radius - thickness, radius + thickness, 8 do
        for z = -radius - thickness, radius + thickness, 8 do
            local dist = math.sqrt(x^2 + z^2)
            
            if dist > radius then
                -- Use multi-octave noise for more natural rock formations
                local noise = fbm(x/80, z/80, 3, 0.6, 2) * 60
                local wallHeight = height + noise
                
                -- Add some variation with secondary noise
                local detailNoise = math.noise(x/30, z/30, SEED + 1000) * 20
                wallHeight = wallHeight + detailNoise
                
                -- Fade in wall from radius
                local alpha = math.clamp((dist - radius) / 50, 0, 1)
                local finalHeight = wallHeight * alpha
                
                if finalHeight > 5 then
                     Workspace.Terrain:FillBlock(
                        CFrame.new(x, finalHeight/2 - 20, z), 
                        Vector3.new(10, finalHeight + 40, 10), 
                        Enum.Material.Rock
                    )
                    
                    -- Add moss/grass on lower parts of walls
                    if finalHeight < 50 and math.random() > 0.85 then
                        Workspace.Terrain:FillBlock(
                            CFrame.new(x, 5, z),
                            Vector3.new(8, 3, 8),
                            Enum.Material.Grass
                        )
                    end
                end
            end
        end
        if x % 80 == 0 then task.wait() end
    end
    print("[TerrainService] Dungeon Walls Complete.")
end

function TerrainService:Clear()
    Workspace.Terrain:Clear()
end

return TerrainService
