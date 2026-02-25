--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local NPCDataList = require(ReplicatedStorage.Shared.NPCData)
local Blueprint = require(ReplicatedStorage.Shared.TownBlueprint)
local BuildingStyles = require(ReplicatedStorage.Shared.BuildingStyles)

local TownGenerator = {}
TownGenerator.__index = TownGenerator

-- Helpers

local function createDistrictTerrain(name: string, data: any)
	local center = data.Direction * Blueprint.Settings.OffsetFromCenter
	local size = Vector3.new(Blueprint.Settings.DistrictSize, 4, Blueprint.Settings.DistrictSize)
	
	-- 1. City Base (Flat) - Smaller than full district, just for buildings
	local citySize = Blueprint.Settings.DistrictSize * 0.6
	local cframe = CFrame.new(center + Vector3.new(0, -2, 0)) 
	
	local material = Enum.Material.Grass
	if name == "Logos" then material = Enum.Material.Cobblestone end
	if name == "Soma" then material = Enum.Material.CrackedLava end
	if name == "Pneuma" then material = Enum.Material.Snow end
	if name == "Eros" then material = Enum.Material.Grass end

	Workspace.Terrain:FillBlock(cframe, Vector3.new(citySize, 4, citySize), material)
	
	-- 2. Wilderness (Organic)
	local TerrainService = Knit.GetService("TerrainService")
	if data.Wilderness then
		task.spawn(function()
			TerrainService:GenerateWilderness(name, data.Wilderness, center, data.Direction)
		end)
	end
	
	if name == "Soma" then
		local waterSize = Vector3.new(80, 8, 120)
		local waterCF = cframe * CFrame.new(-citySize/2 - 30, 0, 0)
		Workspace.Terrain:FillBlock(waterCF, waterSize, Enum.Material.Water)
	end
end

local function generateBuilding(cframe: CFrame, size: Vector3, styleName: string, name: string): Model
	local style = BuildingStyles[styleName]
	if not style then
		-- Fallback to Hub only if strict match fails, but try to be flexible
		style = BuildingStyles.Hub 
	end

	local model = Instance.new("Model")
	model.Name = name
	
	-- 1. Main Structure
	local mainPart = Instance.new("Part")
	mainPart.Name = "MainStructure"
	mainPart.Size = size
	mainPart.CFrame = cframe
	mainPart.Anchored = true
	mainPart.Material = style.PrimaryMaterial
	mainPart.Color = style.PrimaryColor
	if style.Name == "Ethereal" then
		mainPart.Transparency = 0.5
	end
	mainPart.Parent = model
	
	-- 2. Roof Generation
	if style.RoofType == "Wedge" then
		local roof = Instance.new("WedgePart")
		roof.Name = "Roof"
		roof.Size = Vector3.new(size.X, size.Y * 0.5, size.Z)
		roof.CFrame = cframe * CFrame.new(0, size.Y/2 + size.Y*0.25, 0)
		roof.Anchored = true
		roof.Material = style.SecondaryMaterial
		roof.Color = style.SecondaryColor
		roof.Parent = model
	elseif style.RoofType == "Dome" then
		local roof = Instance.new("Part")
		roof.Name = "Dome"
		roof.Shape = Enum.PartType.Ball
		roof.Size = Vector3.new(size.X * 0.8, size.X * 0.8, size.X * 0.8)
		roof.CFrame = cframe * CFrame.new(0, size.Y/2, 0)
		roof.Anchored = true
		roof.Material = style.SecondaryMaterial
		roof.Color = style.SecondaryColor
		roof.Parent = model
	elseif style.RoofType == "Spire" then
		local spire = Instance.new("Part")
		spire.Name = "Spire"
		spire.Size = Vector3.new(size.X * 0.5, size.Y, size.Z * 0.5)
		spire.CFrame = cframe * CFrame.new(0, size.Y, 0)
		spire.Anchored = true
		spire.Material = style.SecondaryMaterial
		spire.Color = style.SecondaryColor
		spire.Transparency = 0.3
		spire.Parent = model
	elseif style.RoofType == "Flat" then
		-- Flat roof implies maybe a parapet? Simple flat for now
	end
	
	-- 3. Decorations
	if style.Decorations then
		for _, decType in ipairs(style.Decorations) do
			if decType == "Pillars" then
				local offset = size / 2
				for x = -1, 1, 2 do
					for z = -1, 1, 2 do
						local pillar = Instance.new("Part")
						pillar.Name = "Pillar"
						pillar.Shape = Enum.PartType.Cylinder
						pillar.Size = Vector3.new(size.Y, 2, 2)
						pillar.CFrame = cframe * CFrame.new(x * (offset.X + 2), 0, z * (offset.Z + 2)) * CFrame.Angles(0, 0, math.rad(90))
						pillar.Anchored = true
						pillar.Material = style.SecondaryMaterial
						pillar.Color = style.SecondaryColor
						pillar.Parent = model
					end
				end
			elseif decType == "Pipes" then
				for i = 1, 4 do
					local pipe = Instance.new("Part")
					pipe.Size = Vector3.new(size.X + 2, 1, 1)
					pipe.CFrame = cframe * CFrame.new(0, math.random(-size.Y/2, size.Y/2), size.Z/2 + 0.5)
					pipe.Anchored = true
					pipe.Color = Color3.fromHex("#1F2937")
					pipe.Material = Enum.Material.DiamondPlate
					pipe.Parent = model
				end
			elseif decType == "Floating_Crystal" then
				local crystal = Instance.new("Part")
				crystal.Name = "Crystal"
				crystal.Shape = Enum.PartType.Ball 
				crystal.Size = Vector3.new(8, 12, 8)
				crystal.CFrame = cframe * CFrame.new(0, size.Y + 15, 0) * CFrame.Angles(math.rad(45), math.rad(45), 0)
				crystal.Anchored = true
				crystal.Material = Enum.Material.Neon
				crystal.Color = Color3.fromHex("#60A5FA")
				crystal.Transparency = 0.2
				crystal.Parent = model
				local light = Instance.new("PointLight")
				light.Color = crystal.Color
				light.Range = 30
				light.Brightness = 2
				light.Parent = crystal
			elseif decType == "Glowing_Flowers" then
				for i = 1, 8 do
					local flower = Instance.new("Part")
					flower.Name = "Flower"
					flower.Size = Vector3.new(1.5, 1.5, 1.5)
					local angle = math.rad((i/8) * 360)
					local radius = (size.X + size.Z)/4 + 2
					flower.CFrame = cframe * CFrame.new(math.cos(angle)*radius, -size.Y/2 + 1, math.sin(angle)*radius)
					flower.Anchored = true
					flower.Material = Enum.Material.Neon
					flower.Color = Color3.fromHex("#F472B6")
					flower.Shape = Enum.PartType.Ball
					flower.Parent = model
				end
			elseif decType == "Star_Particles" then
				local emitterPart = Instance.new("Part")
				emitterPart.Transparency = 1
				emitterPart.Anchored = true
				emitterPart.CanCollide = false
				emitterPart.CFrame = cframe * CFrame.new(0, size.Y, 0)
				emitterPart.Parent = model
				local particles = Instance.new("ParticleEmitter")
				particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
				particles.Color = ColorSequence.new(Color3.fromHex("#E0E7FF"))
				particles.Size = NumberSequence.new(2)
				particles.Rate = 5
				particles.Parent = emitterPart
			elseif decType == "Chimney_Smoke" then
				local chimney = Instance.new("Part")
				chimney.Size = Vector3.new(2, 6, 2)
				chimney.CFrame = cframe * CFrame.new(size.X/3, size.Y/2 + 3, size.Z/3)
				chimney.Color = Color3.fromRGB(50,50,50)
				chimney.Anchored = true
				chimney.Parent = model
				local smoke = Instance.new("Smoke")
				smoke.Color = Color3.new(0.2, 0.2, 0.2)
				smoke.RiseVelocity = 10
				smoke.Opacity = 0.5
				smoke.Size = 5
				smoke.Parent = chimney
			end
		end
	end

	return model
end

local function spawnPropsForDistrict(districtName: string, districtCenter: Vector3, propsData: any)
	if not propsData then return end
	
	local propsFolder = Instance.new("Folder")
	propsFolder.Name = "Props"
	propsFolder.Parent = Workspace
	
	for _, prop in ipairs(propsData) do
		local p = Instance.new("Part")
		p.Name = prop.Name
		p.Size = prop.Size
		p.Position = districtCenter + prop.Offset
		p.Color = prop.Color
		p.Anchored = true
		p.Material = Enum.Material.Plastic
		if prop.Type == "Cylinder" then
			p.Shape = Enum.PartType.Cylinder
			p.Orientation = Vector3.new(0,0,90) -- Upright cylinder
		elseif prop.Type == "Ball" then
			p.Shape = Enum.PartType.Ball
		end
		p.Parent = propsFolder
	end
end

local function spawnBuildingsAndNPCs(districtName: string, districtCenter: Vector3, layoutData: any, overrideStyle: string?)
	if not layoutData or not layoutData.Buildings then return end
	
	local districtFolder = Instance.new("Folder")
	districtFolder.Name = districtName .. "_Buildings"
	districtFolder.Parent = Workspace
	
	for _, bData in ipairs(layoutData.Buildings) do
		local buildingPos = districtCenter + bData.Offset + Vector3.new(0, bData.Size.Y / 2, 0)
		local buildingCFrame = CFrame.new(buildingPos)
		local lookAt = Vector3.new(districtCenter.X, buildingPos.Y, districtCenter.Z)
		buildingCFrame = CFrame.lookAt(buildingPos, lookAt)
		
		-- Use override style if provided, otherwise default to district name
		local styleToUse = overrideStyle or districtName
		
		local buildingModel = generateBuilding(buildingCFrame, bData.Size, styleToUse, bData.Name)
		buildingModel.Parent = districtFolder
		
		-- Label
		local mainPart = buildingModel:FindFirstChild("MainStructure") :: Part
		if mainPart then
			local bgui = Instance.new("SurfaceGui")
			bgui.Face = Enum.NormalId.Front
			bgui.Parent = mainPart
			local btext = Instance.new("TextLabel")
			btext.Size = UDim2.fromScale(1, 1)
			btext.Text = bData.Name
			btext.TextScaled = true
			btext.BackgroundTransparency = 1
			btext.TextColor3 = Color3.new(1,1,1)
			btext.Parent = bgui
		end
		
		-- NPCs - use Knit.GetService to avoid circular dependency
		local NPCService = Knit.GetService("NPCService")
		for _, npc in pairs(NPCDataList) do
			if npc.District == districtName and npc.BuildingName == bData.Name then
				local dirToCenter = (districtCenter - buildingPos).Unit
				local spawnPos = buildingPos + (dirToCenter * (bData.Size.Z/2 + 5))
				spawnPos = Vector3.new(spawnPos.X, districtCenter.Y + 4, spawnPos.Z)
				
				local npcMsg = CFrame.new(spawnPos, Vector3.new(districtCenter.X, spawnPos.Y, districtCenter.Z))
				
				NPCService:SpawnNPC(npc.Id, npcMsg, Workspace)
			end
		end
	end
end


-- Public API

-- Public API

local function createHealthIndicator()
    print("TownGenerator: Creating Server Health Indicator...")
    local part = Instance.new("Part")
    part.Name = "SERVER_HEALTH_INDICATOR"
    part.Size = Vector3.new(4, 4, 4)
    part.Position = Vector3.new(0, 50, 0) -- High up in the air
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.new(0, 1, 0) -- Green for OK
    part.Parent = Workspace

    local bGui = Instance.new("BillboardGui")
    bGui.Size = UDim2.new(0, 200, 0, 50)
    bGui.Adornee = part
    bGui.AlwaysOnTop = true
    bGui.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "SERVER ACTIVE"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Parent = bGui
    
    print("TownGenerator: Health Indicator Created.")
end

function TownGenerator.SpawnWorld()
    print("TownGenerator: SpawnWorld Started.")
	if Workspace:FindFirstChild("TownSquare") then
		warn("TownGenerator: World already spawned. Skipping generation.")
		return
	end
	
    createHealthIndicator()

    print("TownGenerator: Clearing Terrain...")
	Workspace.Terrain:Clear()
	
	-- Hub
    print("TownGenerator: Generating Hub...")
	local hubSize = Vector3.new(Blueprint.Hub.Size.X, 4, Blueprint.Hub.Size.Z)
	local hubCF = CFrame.new(0, -2, 0)
	Workspace.Terrain:FillBlock(hubCF, hubSize, Enum.Material.Pavement)
	
	local hubLabelPart = Instance.new("Part")
	hubLabelPart.Name = "TownSquare"
	hubLabelPart.Size = Blueprint.Hub.Size
	hubLabelPart.Transparency = 1
	hubLabelPart.CanCollide = false
	hubLabelPart.Anchored = true
	hubLabelPart.Position = Vector3.new(0, 0, 0)
	hubLabelPart.Parent = Workspace
	
	spawnPropsForDistrict("Hub", Vector3.new(0,0,0), Blueprint.Hub.Props)
	
	-- Districts
	for name, data in pairs(Blueprint.Districts) do
        print("TownGenerator: Generating District -> " .. name)
		local center = data.Direction * Blueprint.Settings.OffsetFromCenter
		createDistrictTerrain(name, data)
		spawnBuildingsAndNPCs(name, center, data.Layout)
		if data.Layout then
			spawnPropsForDistrict(name, center, data.Layout.Props)
		end
	end
	
	-- Word Orb
    print("TownGenerator: Spawning Word Orb...")
	local orb = Instance.new("Part")
	orb.Name = "Word_Orb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(2, 2, 2)
	orb.Position = Vector3.new(15, 5, 15)
	orb.Color = Color3.new(0, 1, 1)
	orb.Anchored = true
	orb.Material = Enum.Material.Neon
	orb:SetAttribute("WordId", "orb")
	orb.Parent = Workspace
	local s = Instance.new("Script")
	s.Name = "CollectScript"
	s.Source = [[
		script.Parent.Touched:Connect(function(h) 
			local p=game.Players:GetPlayerFromCharacter(h.Parent)
			if p then script.Parent:Destroy() end 
		end)
	]]
	s.Parent = orb

	-- Generate Dungeon Walls
    print("TownGenerator: Spawning Dungeon Walls (Async)...")
    task.spawn(function()
        local TerrainService = Knit.GetService("TerrainService")
        TerrainService:GenerateDungeonWalls()
    end)
    
	print("TownGenerator: World Generation Complete.")
end

function TownGenerator.RegenerateDistrict(districtName: string, styleName: string)
	-- 1. Clean existing
	local existingFolder = Workspace:FindFirstChild(districtName .. "_Buildings")
	if existingFolder then existingFolder:Destroy() end
	
	-- 2. Find Blueprint Data
	local data = Blueprint.Districts[districtName]
	if not data then warn("Invalid District") return end
	
	local center = data.Direction * Blueprint.Settings.OffsetFromCenter
	
	print("TownGenerator: Regenerating " .. districtName .. " with style " .. styleName)
	spawnBuildingsAndNPCs(districtName, center, data.Layout, styleName)
end

return TownGenerator
