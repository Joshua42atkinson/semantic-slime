--!strict
--==============================================================
-- MMMM Context: Procedurally unifies districts. Ensures NPCs and gameplay spaces are distributed optimally to encourage exploration.
--==============================================================
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

local NPCDataList = require(ReplicatedStorage.Shared.NPCData)
local Blueprint = require(ReplicatedStorage.Shared.TownBlueprint)
local BuildingStyles = require(ReplicatedStorage.Shared.BuildingStyles)
local BuildingInterior = require(ReplicatedStorage.Shared.BuildingInterior)
local LearningStationData = require(ReplicatedStorage.Shared.LearningStationData)

local TownGenerator = Knit.CreateService {
	Name = "TownGenerator",
	Client = {},
}

-- Helpers

local function createDistrictTerrain(name: string, data: any)
	local center = data.Direction * Blueprint.Settings.OffsetFromCenter
	local citySize = Blueprint.Settings.DistrictSize * Blueprint.Settings.CityPadRatio
	local cframe = CFrame.new(center + Vector3.new(0, -2, 0))

	-- 1. City Pad — read material from blueprint, fall back to Grass
	local material = data.FloorMaterial or Enum.Material.Grass
	Workspace.Terrain:FillBlock(cframe, Vector3.new(citySize, 4, citySize), material)

	-- 2. Color the flat city pad with a thin cosmetic Part so district colors show
	if data.FloorColor then
		local floorDecal = Instance.new("Part")
		floorDecal.Name = name .. "_FloorDecal"
		floorDecal.Size = Vector3.new(citySize, 0.5, citySize)
		floorDecal.Position = center + Vector3.new(0, 0.5, 0)
		floorDecal.Anchored = true
		floorDecal.CanCollide = false
		floorDecal.Material = Enum.Material.SmoothPlastic
		floorDecal.Color = data.FloorColor
		floorDecal.Transparency = 0.8 -- tinted overlay, lets terrain show through
		floorDecal.CastShadow = false
		floorDecal.Parent = Workspace
	end

	-- 3. Road from hub to district (paved strip)
	local roadLength = Blueprint.Settings.OffsetFromCenter - Blueprint.Hub.Size.X / 2 - 10
	local roadCF = CFrame.new(center / 2 + Vector3.new(0, -2, 0)) -- midpoint between hub and district
	local roadDir = data.Direction
	local isNS = math.abs(roadDir.Z) > 0.5 -- north/south road is long on Z axis
	local roadSize = isNS
		and Vector3.new(Blueprint.Settings.RoadWidth, 4, roadLength)
		or  Vector3.new(roadLength, 4, Blueprint.Settings.RoadWidth)
	Workspace.Terrain:FillBlock(roadCF, roadSize, Enum.Material.Pavement)

	-- 4. Wilderness (Organic terrain past city pad)
	local TerrainService = Knit.GetService("TerrainService")
	if data.Wilderness then
		task.spawn(function()
			TerrainService:GenerateWilderness(name, data.Wilderness, center, data.Direction)
		end)
	end

	-- 5. ActionAlley water channel (lore: ActionAlley = body/flow)
	if name == "ActionAlley" then
		local waterSize = Vector3.new(80, 8, 120)
		local waterCF = cframe * CFrame.new(-citySize/2 - 30, 0, 0)
		Workspace.Terrain:FillBlock(waterCF, waterSize, Enum.Material.Water)
	end
end

-- Generate interior content (floors, walls, furniture) for a building
local function generateBuildingInterior(cframe: CFrame, size: Vector3, buildingName: string, districtName: string, model: Model)
	-- Generate the interior layout data
	local interiorLayout = BuildingInterior.GenerateLayout(buildingName, size, districtName)
	
	-- Create interior folder
	local interiorFolder = Instance.new("Folder")
	interiorFolder.Name = "Interior"
	interiorFolder.Parent = model
	
	local palette = BuildingInterior.GetPalette(districtName)
	
	-- Create each interior piece
	for _, room in ipairs(interiorLayout.Rooms) do
		local part = Instance.new("Part")
		part.Name = room.Name
		part.Size = room.Size
		part.CFrame = cframe * room.CFrame
		part.Anchored = true
		part.Material = room.Material
		part.Color = room.Color
		part.CastShadow = true
		
		-- Handle different room types
		if room.Type == "light" then
			part.Transparency = 0.2
			part.Shape = Enum.PartType.Ball
			-- Add point light for lights
			local light = Instance.new("PointLight")
			light.Color = room.Color
			light.Brightness = 2
			light.Range = 20
			light.Parent = part
		elseif room.Type == "wall" then
			-- Walls are collidable
			part.CanCollide = true
		elseif room.Type == "floor" then
			-- Floors are collidable
			part.CanCollide = true
		elseif room.Type == "furniture" then
			-- Furniture is collidable
			part.CanCollide = true
		elseif room.Type == "deco" then
			-- Decorations are not collidable
			part.CanCollide = false
		end
		
		part.Parent = interiorFolder
	end
	
	-- Create door frame and door at the front of the building
	local doorWidth = 8
	local doorHeight = 12
	local doorThickness = 1
	
	-- Door frame (non-collidable, decorative)
	local doorFrame = Instance.new("Part")
	doorFrame.Name = "DoorFrame"
	doorFrame.Size = Vector3.new(doorWidth + 2, doorHeight + 2, doorThickness)
	doorFrame.CFrame = cframe * CFrame.new(0, -size.Y/2 + doorHeight/2 + 1, size.Z/2 - 1)
	doorFrame.Anchored = true
	doorFrame.CanCollide = false
	doorFrame.Material = Enum.Material.SmoothPlastic
	doorFrame.Color = palette.Accent
	doorFrame.Parent = interiorFolder
	
	-- Door (collidable, opens on interaction)
	local door = Instance.new("Part")
	door.Name = "Door"
	door.Size = Vector3.new(doorWidth, doorHeight, doorThickness)
	door.CFrame = cframe * CFrame.new(-doorWidth/2, -size.Y/2 + doorHeight/2 + 1, size.Z/2 - 1)
	door.Anchored = true
	door.CanCollide = true
	door.Material = Enum.Material.Wood
	door.Color = palette.Floor
	door.Parent = interiorFolder
	
	-- Door hinge point (for rotation)
	door:SetAttribute("IsDoor", true)
	door:SetAttribute("DoorOpen", false)
	door:SetAttribute("OriginalCFrame", door.CFrame:ToEulerAnglesXYZ())
	
	-- Door knob
	local knob = Instance.new("Part")
	knob.Name = "DoorKnob"
	knob.Shape = Enum.PartType.Ball
	knob.Size = Vector3.new(1, 1, 1)
	knob.CFrame = door.CFrame * CFrame.new(doorWidth/2 - 1, 0, doorThickness/2 + 0.5)
	knob.Anchored = true
	knob.Material = Enum.Material.Metal
	knob.Color = Color3.fromHex("#FFD700")
	knob.Parent = interiorFolder
	
	-- Add proximity prompt for entering the building
	local enterPrompt = Instance.new("ProximityPrompt")
	enterPrompt.Name = "EnterBuilding"
	enterPrompt.ActionText = "Enter " .. buildingName
	enterPrompt.ObjectText = buildingName
	enterPrompt.KeyboardKeyCode = Enum.KeyCode.E
	enterPrompt.HoldDuration = 0
	enterPrompt.Triggered:Connect(function(player)
		-- Teleport player inside the building
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				-- Move player inside, centered in the building
				local interiorPos = cframe.Position + Vector3.new(0, -size.Y/2 + 6, 0)
				hrp.CFrame = CFrame.new(interiorPos)
			end
		end
	end)
	enterPrompt.Parent = doorFrame
	
	-- Add enter label
	local enterGui = Instance.new("BillboardGui")
	enterGui.Name = "EnterLabel"
	enterGui.Size = UDim2.new(0, 150, 0, 40)
	enterGui.StudsOffset = Vector3.new(0, doorHeight/2 + 3, 0)
	enterGui.Adornee = doorFrame
	enterGui.AlwaysOnTop = true
	enterGui.Parent = doorFrame
	
	local enterLabel = Instance.new("TextLabel")
	enterLabel.Size = UDim2.fromScale(1, 1)
	enterLabel.BackgroundTransparency = 1
	enterLabel.Text = "Press E to Enter"
	enterLabel.TextColor3 = Color3.new(1, 1, 1)
	enterLabel.TextStrokeTransparency = 0
	enterLabel.Font = Enum.Font.Gotham
	enterLabel.TextScaled = true
	enterLabel.Parent = enterGui
	
	enterGui.Enabled = false -- Hidden for UI Simplification
	
	-- Add exit proximity prompts inside the building
	local exitPrompt = Instance.new("ProximityPrompt")
	exitPrompt.Name = "ExitBuilding"
	exitPrompt.ActionText = "Exit Building"
	exitPrompt.ObjectText = "Exit"
	exitPrompt.KeyboardKeyCode = Enum.KeyCode.E
	exitPrompt.HoldDuration = 0
	exitPrompt.Triggered:Connect(function(player)
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				-- Move player outside, in front of the door
				local exitPos = cframe.Position + Vector3.new(0, -size.Y/2 + 4, size.Z/2 + 10)
				hrp.CFrame = CFrame.new(exitPos)
			end
		end
	end)
	exitPrompt.Parent = interiorFolder
	
	-- Create "You Are Here" label inside
	local insideLabel = Instance.new("BillboardGui")
	insideLabel.Name = "InsideLabel"
	insideLabel.Size = UDim2.new(0, 200, 0, 50)
	insideLabel.StudsOffset = Vector3.new(0, size.Y/2 - 5, 0)
	insideLabel.AlwaysOnTop = false
	insideLabel.Parent = model
	
	local labelText = Instance.new("TextLabel")
	labelText.Size = UDim2.fromScale(1, 1)
	labelText.BackgroundTransparency = 1
	labelText.Text = buildingName .. "\n(Inside)"
	labelText.TextColor3 = palette.Accent
	labelText.TextScaled = true
	labelText.Parent = insideLabel
	
	insideLabel.Enabled = false -- Hidden for UI Simplification
	
	return interiorFolder
end

local function generateBuilding(cframe: CFrame, size: Vector3, styleName: string, name: string, districtName: string?): Model
	local style = BuildingStyles[styleName]
	if not style then
		style = BuildingStyles.Hub 
	end

	local model = Instance.new("Model")
	model.Name = name
	
	-- Store building data for interior generation
	model:SetAttribute("BuildingName", name)
	model:SetAttribute("DistrictName", districtName or "Hub")
	
	-- 1. Foundation / Base (slightly wider, darker)
	local baseSize = Vector3.new(size.X + 2, 4, size.Z + 2)
	local basePart = Instance.new("Part")
	basePart.Name = "Foundation"
	basePart.Size = baseSize
	basePart.CFrame = cframe * CFrame.new(0, -size.Y/2 + 2, 0)
	basePart.Anchored = true
	basePart.Material = Enum.Material.Concrete
	basePart.Color = style.PrimaryColor:Lerp(Color3.new(0,0,0), 0.3)
	basePart.Parent = model

	-- 2. Main Structure (HOLLOW - walls only, not solid)
	-- Create wall parts instead of solid block
	local wallThickness = 2
	
	-- Front wall (with door opening)
	local frontWall = Instance.new("Part")
	frontWall.Name = "Wall_Front"
	frontWall.Size = Vector3.new(size.X, size.Y, wallThickness)
	frontWall.CFrame = cframe * CFrame.new(0, 0, -size.Z/2 + wallThickness/2)
	frontWall.Anchored = true
	frontWall.Material = style.PrimaryMaterial
	frontWall.Color = style.PrimaryColor
	frontWall.CanCollide = true
	frontWall.Parent = model
	
	-- Back wall
	local backWall = Instance.new("Part")
	backWall.Name = "Wall_Back"
	backWall.Size = Vector3.new(size.X, size.Y, wallThickness)
	backWall.CFrame = cframe * CFrame.new(0, 0, size.Z/2 - wallThickness/2)
	backWall.Anchored = true
	backWall.Material = style.PrimaryMaterial
	backWall.Color = style.PrimaryColor
	backWall.CanCollide = true
	backWall.Parent = model
	
	-- Left wall
	local leftWall = Instance.new("Part")
	leftWall.Name = "Wall_Left"
	leftWall.Size = Vector3.new(wallThickness, size.Y, size.Z - wallThickness * 2)
	leftWall.CFrame = cframe * CFrame.new(-size.X/2 + wallThickness/2, 0, 0)
	leftWall.Anchored = true
	leftWall.Material = style.PrimaryMaterial
	leftWall.Color = style.PrimaryColor
	leftWall.CanCollide = true
	leftWall.Parent = model
	
	-- Right wall
	local rightWall = Instance.new("Part")
	rightWall.Name = "Wall_Right"
	rightWall.Size = Vector3.new(wallThickness, size.Y, size.Z - wallThickness * 2)
	rightWall.CFrame = cframe * CFrame.new(size.X/2 - wallThickness/2, 0, 0)
	rightWall.Anchored = true
	rightWall.Material = style.PrimaryMaterial
	rightWall.Color = style.PrimaryColor
	rightWall.CanCollide = true
	rightWall.Parent = model
	
	-- 3. Windows (add details to each face)
	local windowColor = style.SecondaryColor:Lerp(Color3.new(1,1,1), 0.5)
	local faces = {
		{ Orientation = CFrame.Angles(0, 0, 0), Offset = Vector3.new(0, 0, size.Z/2 + 0.1) },
		{ Orientation = CFrame.Angles(0, math.rad(90), 0), Offset = Vector3.new(size.X/2 + 0.1, 0, 0) },
		{ Orientation = CFrame.Angles(0, math.rad(180), 0), Offset = Vector3.new(0, 0, -size.Z/2 - 0.1) },
		{ Orientation = CFrame.Angles(0, math.rad(270), 0), Offset = Vector3.new(-size.X/2 - 0.1, 0, 0) },
	}

	for i, face in ipairs(faces) do
		-- Rows and columns of windows
		local rows = 2
		local cols = 3
		local wWidth = (size.X * 0.15)
		local wHeight = (size.Y * 0.2)
		
		for r = 1, rows do
			for c = -1, 1 do
				local window = Instance.new("Part")
				window.Name = "Window"
				window.Size = Vector3.new(i % 2 == 0 and 0.2 or wWidth, wHeight, i % 2 == 0 and wWidth or 0.2)
				
				local rowOffset = (r - 1.5) * (size.Y * 0.4)
				local colOffset = c * (size.X * 0.25)
				
				window.CFrame = cframe * face.Orientation * CFrame.new(c * (size.X * 0.25), rowOffset, size.Z/2 + 0.1)
				window.Anchored = true
				window.Material = Enum.Material.Neon
				window.Color = Color3.fromRGB(255, 255, 200) -- Warm window glow
				window.Transparency = 0.3
				window.CanCollide = false
				window.Parent = model

				local wLight = Instance.new("SurfaceLight")
				wLight.Face = Enum.NormalId.Front
				wLight.Color = window.Color
				wLight.Range = 15
				wLight.Brightness = 1
				wLight.Parent = window
			end
		end
	end

	-- 4. Roof Generation
	if style.RoofType == "Wedge" then
		local roof = Instance.new("WedgePart")
		roof.Name = "Roof"
		roof.Size = Vector3.new(size.X + 4, size.Y * 0.6, size.Z + 4)
		roof.CFrame = cframe * CFrame.new(0, size.Y/2 + size.Y*0.3, 0)
		roof.Anchored = true
		roof.Material = style.SecondaryMaterial
		roof.Color = style.SecondaryColor
		roof.Parent = model
	elseif style.RoofType == "Dome" then
		local roof = Instance.new("Part")
		roof.Name = "Dome"
		roof.Shape = Enum.PartType.Ball
		roof.Size = Vector3.new(size.X * 1.1, size.X * 1.1, size.X * 1.1)
		roof.CFrame = cframe * CFrame.new(0, size.Y/2, 0)
		roof.Anchored = true
		roof.Material = style.SecondaryMaterial
		roof.Color = style.SecondaryColor
		roof.Parent = model
	elseif style.RoofType == "Spire" then
		local spire = Instance.new("Part")
		spire.Name = "Spire"
		spire.Size = Vector3.new(size.X * 0.6, size.Y * 1.2, size.Z * 0.6)
		spire.CFrame = cframe * CFrame.new(0, size.Y, 0)
		spire.Anchored = true
		spire.Material = style.SecondaryMaterial
		spire.Color = style.SecondaryColor
		spire.Transparency = 0.3
		spire.Parent = model
		
		-- Tiny tip orb
		local tip = Instance.new("Part")
		tip.Shape = Enum.PartType.Ball
		tip.Size = Vector3.new(4, 4, 4)
		tip.CFrame = spire.CFrame * CFrame.new(0, spire.Size.Y/2, 0)
		tip.Material = Enum.Material.Neon
		tip.Color = Color3.fromRGB(255, 255, 255)
		tip.Anchored = true
		tip.Parent = model
	end
	
	-- 5. Decorations
	if style.Decorations then
		for _, decType in ipairs(style.Decorations) do
			if decType == "Pillars" then
				local offset = size / 2
				for x = -1, 1, 2 do
					for z = -1, 1, 2 do
						local pillar = Instance.new("Part")
						pillar.Name = "Pillar"
						pillar.Shape = Enum.PartType.Cylinder
						pillar.Size = Vector3.new(size.Y, 4, 4)
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
					pipe.Size = Vector3.new(size.X + 2, 1.5, 1.5)
					pipe.CFrame = cframe * CFrame.new(0, math.random(-size.Y/3, size.Y/2), size.Z/2 + 0.8)
					pipe.Anchored = true
					pipe.Color = Color3.fromHex("#1F2937")
					pipe.Material = Enum.Material.DiamondPlate
					pipe.Parent = model
				end
			elseif decType == "Floating_Crystal" or decType == "Floating_Orbs" then
				local crystal = Instance.new("Part")
				crystal.Name = "Crystal"
				crystal.Shape = Enum.PartType.Ball 
				crystal.Size = Vector3.new(8, 12, 8)
				crystal.CFrame = cframe * CFrame.new(0, size.Y + 25, 0)
				crystal.Anchored = true
				crystal.Material = Enum.Material.Neon
				crystal.Color = style.SecondaryColor
				crystal.Transparency = 0.2
				crystal.Parent = model
				local light = Instance.new("PointLight")
				light.Color = crystal.Color
				light.Range = 40
				light.Brightness = 3
				light.Parent = crystal
			elseif decType == "Steps" then
				local stepSize = Vector3.new(size.X * 0.4, 2, 8)
				for i = 1, 3 do
					local step = Instance.new("Part")
					step.Name = "Step"
					step.Size = stepSize
					step.CFrame = cframe * CFrame.new(0, -size.Y/2 + i, size.Z/2 + (i * 2))
					step.Anchored = true
					step.Material = Enum.Material.Marble
					step.Color = style.SecondaryColor
					step.Parent = model
				end
			elseif decType == "Vines" then
				-- Green drooping parts
				for i = 1, 6 do
					local vine = Instance.new("Part")
					vine.Size = Vector3.new(1, math.random(10, 25), 1)
					vine.CFrame = cframe * CFrame.new(math.random(-size.X/2, size.X/2), size.Y/2, size.Z/2 + 0.5)
					vine.Anchored = true
					vine.Color = Color3.fromRGB(34, 139, 34)
					vine.Material = Enum.Material.Grass
					vine.Transparency = 0.2
					vine.Parent = model
				end
			end
		end
	end

	-- 5.5 Mycelial Node — disabled (SemanticArchitectureService is archived)
	-- TODO: Re-enable when Semantic Architecture system is reintroduced

	-- 6. Generate Interior
	if districtName then
		generateBuildingInterior(cframe, size, name, districtName, model)
	end

	return model
end

local function spawnDistrictFoliage(districtName: string, districtCenter: Vector3, data: any)
	local citySize = Blueprint.Settings.DistrictSize * Blueprint.Settings.CityPadRatio
	local halfPad = citySize / 2
	local foliageFolder = Instance.new("Folder")
	foliageFolder.Name = districtName .. "_Foliage"
	foliageFolder.Parent = Workspace

	local count = 12
	local material = data.FloorMaterial or Enum.Material.Grass

	for i = 1, count do
		local rx = (math.random() - 0.5) * citySize
		local rz = (math.random() - 0.5) * citySize
		
		local foliage = Instance.new("Part")
		foliage.Anchored = true
		foliage.CanCollide = false
		foliage.CastShadow = false  -- save render budget for tiny scatter objects
		foliage.Position = districtCenter + Vector3.new(rx, 1, rz)
		
		if math.random() > 0.3 then
			-- Grass/Bush
			foliage.Name = "Bush"
			foliage.Size = Vector3.new(math.random(2, 5), math.random(1, 3), math.random(2, 5))
			foliage.Shape = Enum.PartType.Ball
			foliage.Material = Enum.Material.Grass
			foliage.Color = data.FloorColor:Lerp(Color3.fromRGB(20, 120, 20), math.random(30,60)/100)
		else
			-- Rock
			foliage.Name = "Rock"
			foliage.Size = Vector3.new(math.random(2, 6), math.random(1, 4), math.random(2, 6))
			foliage.Material = Enum.Material.Rock
			foliage.Color = Color3.fromRGB(
				math.random(80, 120),
				math.random(80, 110),
				math.random(80, 100)
			)
			foliage.CFrame = CFrame.new(districtCenter + Vector3.new(rx, 1, rz))
				* CFrame.Angles(math.rad(math.random(-20, 20)), math.rad(math.random(0,360)), math.rad(math.random(-10,10)))
		end
		foliage.Parent = foliageFolder
	end
end

-- Spawn environmental props for a district or the hub.
-- Respects: Type (Block/Cylinder/Ball), Neon flag (sets Material+PointLight), Color.
local function spawnPropsForDistrict(districtName: string, districtCenter: Vector3, propsData: any)
	if not propsData then return end

	local propsFolder = Workspace:FindFirstChild(districtName .. "_Props")
			or Instance.new("Folder")
	propsFolder.Name = districtName .. "_Props"
	propsFolder.Parent = Workspace

	for _, prop in ipairs(propsData) do
		local p = Instance.new("Part")
		p.Name = prop.Name
		p.Size = prop.Size
		p.Position = districtCenter + prop.Offset
		p.Color = prop.Color
		p.Anchored = true
		p.CastShadow = true
		p.Transparency = prop.Transparency or 0

		-- Shape
		if prop.Type == "Cylinder" then
			p.Shape = Enum.PartType.Cylinder
			p.Orientation = Vector3.new(0, 0, 90) -- upright
		elseif prop.Type == "Ball" then
			p.Shape = Enum.PartType.Ball
		end

		-- Neon / Glow support
		if prop.Neon then
			p.Material = Enum.Material.Neon
			p.CastShadow = false
			-- Point light so neon illuminates the world
			local light = Instance.new("PointLight")
			light.Color = prop.Color
			light.Brightness = 2
			light.Range = math.max(prop.Size.X, prop.Size.Y, prop.Size.Z) * 4
			light.Parent = p
		else
			-- Pick a sensible default material based on type
			p.Material = Enum.Material.SmoothPlastic
			if prop.Name:find("Tree") or prop.Name:find("Trunk") then
				p.Material = (prop.Type == "Ball") and Enum.Material.Grass or Enum.Material.Wood
			elseif prop.Name:find("Crate") then
				p.Material = Enum.Material.Wood
			end
		end

		p.Parent = propsFolder

		-- Add labels to Signs with distance culling
		if prop.Name:find("Sign_") then
			local districtName = prop.Name:gsub("Sign_", "")
			
			local bGui = Instance.new("BillboardGui")
			bGui.Size = UDim2.new(0, 180, 0, 60)
			bGui.StudsOffset = Vector3.new(0, prop.Size.Y / 2 + 2, 0)
			bGui.Adornee = p
			bGui.AlwaysOnTop = false  -- occluded by world, feels grounded
			bGui.MaxDistance = 120    -- only visible within Town Square, not from entire map
			bGui.Parent = p
			
			local bg = Instance.new("Frame")
			bg.Size = UDim2.fromScale(1, 1)
			bg.BackgroundColor3 = prop.Color:Lerp(Color3.new(0,0,0), 0.5)
			bg.BackgroundTransparency = 0.3
			bg.BorderSizePixel = 0
			bg.Parent = bGui
			local bgCorner = Instance.new("UICorner")
			bgCorner.CornerRadius = UDim.new(0, 8)
			bgCorner.Parent = bg

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 0.65)
			label.Position = UDim2.fromScale(0, 0.05)
			label.BackgroundTransparency = 1
			label.Text = districtName:upper()
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 0.3
			label.TextScaled = true
			label.Font = Enum.Font.GothamBold
			label.Parent = bGui

			local subLabel = Instance.new("TextLabel")
			subLabel.Size = UDim2.fromScale(1, 0.3)
			subLabel.Position = UDim2.fromScale(0, 0.7)
			subLabel.BackgroundTransparency = 1
			subLabel.Text = "▶  This Way"
			subLabel.TextColor3 = prop.Color:Lerp(Color3.new(1,1,1), 0.5)
			subLabel.TextScaled = true
			subLabel.Font = Enum.Font.Gotham
			subLabel.Parent = bGui
		end

		-- Add particles if it's a special prop
		if prop.Name:find("Tree") and math.random() > 0.5 then
			local particles = Instance.new("ParticleEmitter")
			particles.Texture = "rbxasset://textures/particles/leaf_main.dds"
			particles.Color = ColorSequence.new(prop.Color)
			particles.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
			particles.Acceleration = Vector3.new(0, -5, 0)
			particles.Lifetime = NumberRange.new(2, 5)
			particles.Rate = 2
			particles.Speed = NumberRange.new(2, 5)
			particles.Parent = p
		elseif prop.Name:find("Fire") or prop.Name:find("Torch") then
			local fire = Instance.new("Fire")
			fire.Color = prop.Color
			fire.SecondaryColor = Color3.fromRGB(255, 100, 0)
			fire.Heat = 5
			fire.Size = 5
			fire.Parent = p
		end
	end
end

-- Scatter ambient glow crystals around a district for atmosphere.
-- Config: { Color, Count, Height } from Blueprint.Districts[X].AmbientCrystals
local function spawnAmbientCrystals(districtName: string, districtCenter: Vector3, config: any)
	if not config then return end

	local folder = Instance.new("Folder")
	folder.Name = districtName .. "_AmbientCrystals"
	folder.Parent = Workspace

	local citySize = Blueprint.Settings.DistrictSize * Blueprint.Settings.CityPadRatio
	local halfPad = citySize / 2

	for i = 1, config.Count do
		-- Random scatter inside city pad
		local rx = (math.random() - 0.5) * (halfPad * 1.4)
		local rz = (math.random() - 0.5) * (halfPad * 1.4)
		local height = config.Height * (0.5 + math.random() * 0.8)
		local width  = math.random(2, 5)

		-- Shard is a tall thin block, randomly rotated
		local shard = Instance.new("Part")
		shard.Name = "AmbientCrystal_" .. i
		shard.Size = Vector3.new(width, height, width)
		shard.CFrame = CFrame.new(
			districtCenter.X + rx,
			districtCenter.Y + height / 2,
			districtCenter.Z + rz
		) * CFrame.Angles(0, math.random() * math.pi * 2, math.rad(math.random(-15, 15)))
		shard.Anchored = true
		shard.CanCollide = false
		shard.Material = Enum.Material.Neon
		shard.Color = config.Color
		shard.Transparency = 0.35
		shard.CastShadow = false

		local light = Instance.new("PointLight")
		light.Color = config.Color
		light.Brightness = 0.8
		light.Range = height * 2.5
		light.Parent = shard

		shard.Parent = folder
	end

	print("[TownGenerator] Placed " .. config.Count .. " ambient crystals in " .. districtName)
end

-- Spawn floating magical elements (letters, spirits, fireflies, embers)
local function spawnFloatingElements(districtName: string, districtCenter: Vector3, elements: any)
	if not elements then return end

	local folder = Instance.new("Folder")
	folder.Name = districtName .. "_FloatingElements"
	folder.Parent = Workspace

	for i, elem in ipairs(elements) do
		local pos = districtCenter + elem.Offset
		
		-- Create floating orb
		local orb = Instance.new("Part")
		orb.Name = elem.Name
		orb.Size = Vector3.new(2, 2, 2)
		orb.CFrame = CFrame.new(pos)
		orb.Anchored = true
		orb.CanCollide = false
		orb.Material = Enum.Material.Neon
		orb.Color = elem.Color
		orb.Transparency = 0.3
		orb.CastShadow = false
		
		-- Add glow light
		local light = Instance.new("PointLight")
		light.Color = elem.Color
		light.Brightness = 1.5
		light.Range = 15
		light.Parent = orb
		
		-- Add sparkle particles
		local sparkle = Instance.new("ParticleEmitter")
		sparkle.Texture = "rbxasset://textures/particles/sparkle_main.dds"
		sparkle.Color = ColorSequence.new(elem.Color)
		sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
		sparkle.Lifetime = NumberRange.new(1, 3)
		sparkle.Rate = 8
		sparkle.Speed = NumberRange.new(0.5, 1.5)
		sparkle.VelocityInheritance = 0.5
		sparkle.Parent = orb
		
		-- Gentle floating animation via Tween
		local startY = pos.Y
		local tweenInfo = TweenInfo.new(2 + math.random(), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
		local tween = game:GetService("TweenService"):Create(orb, tweenInfo, {Position = Vector3.new(pos.X, startY + 3, pos.Z)})
		tween:Play()
		
		orb.Parent = folder
	end
	
	print("[TownGenerator] Placed " .. #elements .. " floating elements in " .. districtName)
end

local function spawnBuildingsAndNPCs(districtName: string, districtCenter: Vector3, layoutData: any, overrideStyle: string?)
	if not layoutData or not layoutData.Buildings then return end
	
	local districtFolder = Instance.new("Folder")
	districtFolder.Name = districtName .. "_Buildings"
	districtFolder.Parent = Workspace
	
	-- NPCs - use Knit.GetService to avoid circular dependency
	local NPCService = Knit.GetService("NPCService")
	
	for _, bData in ipairs(layoutData.Buildings) do
		local buildingPos
		local lookAtCenter
		if bData.RingIndex then
			local RING_RADIUS = Blueprint.Settings.OffsetFromCenter
			local angleRad = math.rad(bData.RingIndex * 30)
			local x = math.sin(angleRad) * RING_RADIUS
			local z = -math.cos(angleRad) * RING_RADIUS
			
			-- Terrain is at height 0, the building origin is its center
			-- We add 2 to base position so foundation isn't perfectly flush
			buildingPos = Vector3.new(x, bData.Size.Y / 2 + 2, z)
			lookAtCenter = Vector3.new(0, buildingPos.Y, 0)
		else
			buildingPos = districtCenter + (bData.Offset or Vector3.new()) + Vector3.new(0, bData.Size.Y / 2, 0)
			lookAtCenter = Vector3.new(districtCenter.X, buildingPos.Y, districtCenter.Z)
		end
		
		local buildingCFrame = CFrame.lookAt(buildingPos, lookAtCenter)
		
		-- Use override style if provided, otherwise default to district name
		local styleToUse = overrideStyle or districtName
		
		-- Pass districtName to generateBuilding for interior generation
		local buildingModel = generateBuilding(buildingCFrame, bData.Size, styleToUse, bData.Name, districtName)
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
		
		-- Check for NPCs in this building
		print("TownGenerator: Checking for NPCs in district '" .. districtName .. "' for building '" .. bData.Name .. "'")
		local npcFound = false
		for _, npc in pairs(NPCDataList) do
			if npc.District == districtName and npc.BuildingName == bData.Name then
				npcFound = true
				local dirToCenter = (lookAtCenter - buildingPos).Unit
				local spawnPos = buildingPos + (dirToCenter * (bData.Size.Z/2 + 5))
				
				-- Normal ground level is 0, so height 4 works for characters
				spawnPos = Vector3.new(spawnPos.X, 4, spawnPos.Z)
				
				local npcMsg = CFrame.new(spawnPos, Vector3.new(lookAtCenter.X, spawnPos.Y, lookAtCenter.Z))
				
				print("TownGenerator: Spawning NPC '" .. npc.Id .. "' at position:", spawnPos)
				NPCService:SpawnNPC(npc.Id, npcMsg, Workspace)
				print("TownGenerator: NPC '" .. npc.Id .. "' spawned!")
			end
		end
		if not npcFound then
			print("TownGenerator: No NPCs found for district '" .. districtName .. "' building '" .. bData.Name .. "'")
		end
	end
end


-- Public API

-- Public API

local function createHealthIndicator()
    -- Disabled: dev-only visual noise for players
    print("TownGenerator: Health indicator disabled (dev-only)")
end

function TownGenerator:KnitStart()
    -- World generation runs automatically when Knit starts
    print("[TownGenerator] KnitStart — beginning world generation...")
    print(string.format("[TownGenerator] Memory before world gen: %dKB", gcinfo()))
    self:SpawnWorld()
    print(string.format("[TownGenerator] Memory after world gen: %dKB", gcinfo()))
end

function TownGenerator:SpawnWorld()
    print("[TownGenerator] SpawnWorld() STARTED")
    
    -- ================================================================
    -- AGGRESSIVE CLEANUP - Remove EVERYTHING from previous runs
    -- ================================================================
    print("TownGenerator: AGGRESSIVE CLEANUP...")
    local cleanupCount = 0
    for _, child in ipairs(Workspace:GetChildren()) do
        -- Remove almost everything except player characters
        if not child:IsA("Model") or (child:IsA("Model") and not child:FindFirstChild("Humanoid")) then
            -- Also keep Terrain, Camera, etc
            if child.Name ~= "Terrain" and child.Name ~= "Camera" and child.Name ~= "LuaApp" then
                child:Destroy()
                cleanupCount = cleanupCount + 1
            end
        end
    end
    print("TownGenerator: Cleaned up " .. cleanupCount .. " objects")
    
    -- Also clear terrain
    Workspace.Terrain:Clear()
    task.wait(0.5)
    
    -- ================================================================
    -- ABSOLUTE GROUND - Created FIRST, lasts FOREVER
    -- This is a single massive floor that spans the entire playable area
    -- ================================================================
    print("TownGenerator: Creating absolute ground floor...")
    local absoluteGround = Instance.new("Part")
    absoluteGround.Name = "AbsoluteGround"
    absoluteGround.Size = Vector3.new(3000, 50, 3000) -- 3000x50x3000 - covers everything
    absoluteGround.Position = Vector3.new(0, -25, 0) -- Top surface at Y=0
    absoluteGround.Anchored = true
    absoluteGround.CanCollide = true
    absoluteGround.Transparency = 0.3 -- Visible green
    absoluteGround.Material = Enum.Material.Grass
    absoluteGround.Color = Color3.fromRGB(60, 160, 60) -- Green
    absoluteGround.Parent = Workspace
    print("TownGenerator: Absolute ground created at Y=0 (3000x50x3000)")
    
    -- ================================================================
    -- MAIN GROUND FLOOR - VISIBLE FALLBACK
    -- ================================================================
    print("TownGenerator: Creating MainGround...")
    local groundFloor = Instance.new("Part")
    groundFloor.Name = "MainGround"
    groundFloor.Size = Vector3.new(4000, 20, 4000)
    groundFloor.Position = Vector3.new(0, -14, 0)
    groundFloor.Anchored = true
    groundFloor.CanCollide = true
    groundFloor.Transparency = 0
    groundFloor.Material = Enum.Material.Grass
    groundFloor.Color = Color3.fromRGB(100, 200, 100)
    groundFloor.Parent = Workspace
    print("TownGenerator: MainGround created")

    -- ================================================================
    -- GLOSSARY GROTTO (LEXICAL UNDERWORLD)
    -- ================================================================
    print("TownGenerator: Spawning Glossary Grotto...")
    local grotto = Instance.new("Part")
    grotto.Name = "GlossaryGrotto"
    grotto.Size = Vector3.new(2000, 100, 2000) -- massive subterranean cave
    grotto.Position = Vector3.new(0, -90, 0)
    grotto.Anchored = true
    grotto.CanCollide = false
    grotto.Material = Enum.Material.Neon
    grotto.Transparency = 0.85
    grotto.Color = Color3.fromRGB(60, 0, 80) -- Dark purple/magenta glow
    grotto.Parent = Workspace
    
    local grottoFloor = Instance.new("Part")
    grottoFloor.Name = "GrottoFloor"
    grottoFloor.Size = Vector3.new(2000, 20, 2000)
    grottoFloor.Position = Vector3.new(0, -150, 0)
    grottoFloor.Anchored = true
    grottoFloor.CanCollide = true
    grottoFloor.Material = Enum.Material.Basalt
    grottoFloor.Color = Color3.fromRGB(20, 0, 30)
    grottoFloor.Parent = Workspace

    -- ================================================================
    -- SPAWN LOCATION: Players always start in the Town Square center.
    -- ================================================================
    local spawnLoc = Instance.new("SpawnLocation")
    spawnLoc.Name = "HubSpawn"
    spawnLoc.Size = Vector3.new(6, 1, 6)
    spawnLoc.Position = Vector3.new(0, 3, 0)
    spawnLoc.Anchored = true
    spawnLoc.Neutral = true
    spawnLoc.Duration = 0
    spawnLoc.Material = Enum.Material.Neon
    spawnLoc.Color = Color3.fromHex("#FFD700")
    spawnLoc.Transparency = 0.7
    spawnLoc.Parent = Workspace
    print("TownGenerator: SpawnLocation placed at Town Square.")

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
    
    print("TownGenerator: Hub created successfully!")
    
    -- Spawn any Hub NPCs (if any exist in data)
    local NPCService = Knit.GetService("NPCService")
    local NPCDataList = require(game:GetService("ReplicatedStorage").Shared.NPCData)
    local hubNPCCount = 0
    for _, npc in pairs(NPCDataList) do
        if npc.District == "Hub" then
            local spawnPos = Vector3.new(math.random(-30, 30), 4, math.random(-30, 30))
            local npcMsg = CFrame.new(spawnPos, Vector3.new(0, spawnPos.Y, 0))
            NPCService:SpawnNPC(npc.Id, npcMsg, Workspace)
            hubNPCCount = hubNPCCount + 1
        end
    end
    if hubNPCCount > 0 then
        print("TownGenerator: Spawned " .. hubNPCCount .. " Hub NPCs")
    else
        print("TownGenerator: No Hub NPCs to spawn")
    end
	
	-- Districts (staggered to prevent instance flood crashing Wine)
	print("TownGenerator: Starting district generation...")
	local districtIndex = 0
	local districtTotal = 0
	for _ in pairs(Blueprint.Districts) do districtTotal += 1 end

	for name, data in pairs(Blueprint.Districts) do
		districtIndex += 1
		print(string.format("TownGenerator: === District %d/%d -> %s === [%dKB]", districtIndex, districtTotal, name, gcinfo()))
		local center = data.Direction * Blueprint.Settings.OffsetFromCenter

		-- 1. Terrain (floor, color overlay, road, wilderness)
		createDistrictTerrain(name, data)
		task.wait() -- yield to prevent frame spike

		-- 2. Buildings + NPCs
		spawnBuildingsAndNPCs(name, center, data.Layout)
		task.wait() -- yield after heavy instance creation

		-- 3. District props (lamps, trees, crystals, banners etc.)
		if data.Layout then
			spawnPropsForDistrict(name, center, data.Layout.Props)
		end

		-- 4. Ambient atmosphere crystals (scattered glow shards)
		spawnAmbientCrystals(name, center, data.AmbientCrystals)

		-- 5. Floating magical elements (letters, spirits, fireflies, embers)
		spawnFloatingElements(name, center, data.FloatingElements)
		
		-- 6. District Foliage (Grass, rocks)
		spawnDistrictFoliage(name, center, data)
		
		print(string.format("TownGenerator: === Completed %s (%d/%d) === [%dKB]", name, districtIndex, districtTotal, gcinfo()))
		
		-- Stagger between districts — gives Wine/renderer time to breathe
		if districtIndex < districtTotal then
			task.wait(0.5)
		end

		-- 5. District Entrance Arch (two pillars + glowing name sign)
		local dir = data.Direction
		local archCenter = dir * (Blueprint.Settings.OffsetFromCenter - 155) -- between hub and district
		local isNS = math.abs(dir.Z) > 0.5
		local pillarOffsetX = isNS and 18 or 0
		local pillarOffsetZ = isNS and 0 or 18

		for _, side in ipairs({ -1, 1 }) do
			local pillar = Instance.new("Part")
			pillar.Name = name .. "_ArchPillar_" .. side
			pillar.Size = Vector3.new(4, 28, 4)
			pillar.Position = Vector3.new(
				archCenter.X + side * pillarOffsetX,
				12,
				archCenter.Z + side * pillarOffsetZ
			)
			pillar.Anchored = true
			pillar.Material = Enum.Material.Marble
			pillar.Color = data.FloorColor or Color3.fromHex("#E2E8F0")
			pillar.Parent = Workspace
		end

		-- Glowing district name sign spanning the arch
		local sign = Instance.new("Part")
		sign.Name = name .. "_ArchSign"
		sign.Size = Vector3.new(isNS and 32 or 4, 4, isNS and 4 or 32)
		sign.Position = Vector3.new(archCenter.X, 27, archCenter.Z)
		sign.Anchored = true
		sign.Material = Enum.Material.Neon
		sign.Color = data.FloorColor or Color3.fromHex("#60A5FA")
		sign.Transparency = 0.4
		sign.Parent = Workspace

		local billGui = Instance.new("BillboardGui")
		billGui.Size = UDim2.new(0, 300, 0, 60)
		billGui.AlwaysOnTop = false
		billGui.Adornee = sign
		billGui.Parent = sign

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.fromScale(1, 1)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = name:upper()
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextScaled = true
		nameLabel.Parent = billGui
		print("TownGenerator: === District Arch Built -> " .. name .. " ===")
	end
	
	print("TownGenerator: ALL DISTRICTS COMPLETE!")
	
	-- Central Word Orb on a pedestal (the hub's focal point)
	print("TownGenerator: Spawning Word Orb...")
	local orbPedestal = Instance.new("Part")
	orbPedestal.Name = "WordOrb_Stand"
	orbPedestal.Size = Vector3.new(8, 5, 8)
	orbPedestal.Position = Vector3.new(40, 2, -40)
	orbPedestal.Anchored = true
	orbPedestal.Material = Enum.Material.Marble
	orbPedestal.Color = Color3.fromHex("#E2E8F0")
	orbPedestal.Parent = Workspace

	local orb = Instance.new("Part")
	orb.Name = "Word_Orb"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(5, 5, 5)
	orb.Position = Vector3.new(40, 8, -40)
	orb.Color = Color3.fromHex("#7DD3FC") -- Sky blue glow
	orb.Anchored = true
	orb.Material = Enum.Material.Neon
	orb.Transparency = 0.15
	orb:SetAttribute("WordId", "orb")
	orb.Parent = Workspace

	local orbLight = Instance.new("PointLight")
	orbLight.Color = Color3.fromHex("#7DD3FC")
	orbLight.Brightness = 5
	orbLight.Range = 60
	orbLight.Parent = orb

	local orbBillboard = Instance.new("BillboardGui")
	orbBillboard.Size = UDim2.new(0, 200, 0, 40)
	orbBillboard.StudsOffset = Vector3.new(0, 5, 0)
	orbBillboard.Adornee = orb
	orbBillboard.AlwaysOnTop = false
	orbBillboard.Parent = orb

	local orbLabel = Instance.new("TextLabel")
	orbLabel.Size = UDim2.fromScale(1, 1)
	orbLabel.BackgroundTransparency = 1
	orbLabel.Text = "✨ Word of Power"
	orbLabel.TextColor3 = Color3.fromHex("#E0F2FE")
	orbLabel.TextStrokeTransparency = 0
	orbLabel.Font = Enum.Font.GothamBold
	orbLabel.TextScaled = true
	orbLabel.Parent = orbBillboard

	-- Support for Slime Synthesizer machine interaction
	task.delay(1, function()
		local console = Workspace:FindFirstChild("Hub_Props") and Workspace.Hub_Props:FindFirstChild("Synthesizer_Console")
		if console then
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Synthesize Slime"
			prompt.ObjectText = "Lore-Machine"
			prompt.KeyboardKeyCode = Enum.KeyCode.E
			prompt.HoldDuration = 0.5
			prompt.Parent = console

			local bill = Instance.new("BillboardGui")
			bill.Size = UDim2.new(0, 200, 0, 50)
			bill.Adornee = console
			bill.StudsOffset = Vector3.new(0, 4, 0)
			bill.AlwaysOnTop = true
			bill.Parent = console

			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Text = "🧬 SLIME FABRICATOR"
			label.TextColor3 = Color3.fromHex("#FBBF24")
			label.TextStrokeTransparency = 0
			label.Font = Enum.Font.GothamBold
			label.TextScaled = true
			label.Parent = bill
			
			prompt.Triggered:Connect(function(player)
				local remotesMod = ReplicatedStorage:WaitForChild("Shared"):FindFirstChild("Remotes")
				local remotes = (remotesMod and remotesMod:IsA("ModuleScript")) and require(remotesMod) or ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes", 10)
				local openEvent = remotes:FindFirstChild("OpenWordConstructor")
				if openEvent then
					openEvent:FireClient(player)
				end
			end)
		end
	end)

	-- Collect on touch
	orb.Touched:Connect(function(hit)
		local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
		if player then
			orb:Destroy()
		end
	end)

	-- Initialise world lighting (Dawn warmth at startup)
	task.delay(1, function()
		local ok, LightingService = pcall(function()
			return Knit.GetService("LightingService")
		end)
		if ok and LightingService then
			LightingService:SetPhase("Dawn")
		end
	end)

	-- Generate Dungeon Walls (border containment, async)
	print("TownGenerator: Spawning Dungeon Walls (Async)...")
	task.spawn(function()
		local TerrainService = Knit.GetService("TerrainService")
		TerrainService:GenerateDungeonWalls()
		
		-- Fill any remaining gaps in the city area for player safety
		task.wait(1)
		TerrainService:FillCityGaps()
		
		-- Verify terrain integrity
		TerrainService:VerifyTerrainIntegrity()
	end)

	-- Spawn Learning Stations (async, after buildings are ready)
	print("TownGenerator: Spawning Learning Stations (Async)...")
	task.spawn(function()
		task.wait(2) -- Wait for buildings to fully spawn
		local ok, LearningStationService = pcall(function()
			return Knit.GetService("LearningStationService")
		end)
		if ok and LearningStationService then
			-- Spawn learning stations for each district
			for name, data in pairs(Blueprint.Districts) do
				local center = data.Direction * Blueprint.Settings.OffsetFromCenter
				LearningStationService:SpawnDistrictStations(name, center)
			end
			print("[TownGenerator] Learning Stations spawned successfully")
		else
			warn("[TownGenerator] LearningStationService not available")
		end
	end)

	print("TownGenerator: World Generation Complete.")
end

function TownGenerator:RegenerateDistrict(districtName: string, styleName: string)
	-- 1. Clean existing
	local existingFolder = Workspace:FindFirstChild(districtName .. "_Buildings")
	if existingFolder then existingFolder:Destroy() end
	
	-- 2. Find Blueprint Data
	local data = Blueprint.Districts[districtName]
	if not data then warn("Invalid District") return end
	
	local center = data.Direction * Blueprint.Settings.OffsetFromCenter
	
	print("[TownGenerator] Regenerating " .. districtName .. " with style " .. styleName)
	spawnBuildingsAndNPCs(districtName, center, data.Layout, styleName)
end

return TownGenerator
