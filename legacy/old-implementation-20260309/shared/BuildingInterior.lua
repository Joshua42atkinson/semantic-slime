--!strict
-- BuildingInterior.lua
-- Generates explorable interiors for buildings in Syllable Springs
-- Each building type has unique educational room layouts

export type InteriorRoom = {
	Name: string,
	Type: "floor" | "wall" | "furniture" | "deco" | "light",
	Size: Vector3,
	CFrame: CFrame,
	Color: Color3,
	Material: Enum.Material,
}

export type InteriorLayout = {
	Rooms: { InteriorRoom },
	DoorPosition: Vector3,
	DoorCFrame: CFrame,
}

local BuildingInterior = {}

-- Color palettes for interiors (matching district themes)
local InteriorPalettes = {
	BrainyBorough = {
		Wall = Color3.fromHex("#E2E8F0"),
		Floor = Color3.fromHex("#CBD5E1"),
		Accent = Color3.fromHex("#1E3A8A"),
		Light = Color3.fromHex("#93C5FD"),
	},
	HeartwoodGrove = {
		Wall = Color3.fromHex("#78350F"),
		Floor = Color3.fromHex("#575329"),
		Accent = Color3.fromHex("#065F46"),
		Light = Color3.fromHex("#86EFAC"),
	},
	WhisperWinds = {
		Wall = Color3.fromHex("#E9D5FF"),
		Floor = Color3.fromHex("#C4B5FD"),
		Accent = Color3.fromHex("#5B21B6"),
		Light = Color3.fromHex("#FFFFFF"),
	},
	ActionAlley = {
		Wall = Color3.fromHex("#44403C"),
		Floor = Color3.fromHex("#292524"),
		Accent = Color3.fromHex("#991B1B"),
		Light = Color3.fromHex("#FB923C"),
	},
	Hub = {
		Wall = Color3.fromHex("#FEF3C7"),
		Floor = Color3.fromHex("#D97706"),
		Accent = Color3.fromHex("#FFD700"),
		Light = Color3.fromHex("#FEF08A"),
	},
}

-- Generate floor pieces for a building interior
local function generateFloors(buildingSize: Vector3, palette: any): { InteriorRoom }
	local floors = {}
	local floorHeight = buildingSize.Y
	local numFloors = math.floor(buildingSize.Y / 12) -- Each floor is ~12 studs tall
	numFloors = math.max(1, numFloors)
	
	local floorThickness = 1
	local roomHeight = floorHeight / numFloors
	
	for floor = 1, numFloors do
		local yPos = -buildingSize.Y/2 + (floor - 1) * roomHeight + roomHeight/2
		
		-- Main floor
		table.insert(floors, {
			Name = `Floor_{floor}`,
			Type = "floor",
			Size = Vector3.new(buildingSize.X - 4, floorThickness, buildingSize.Z - 4),
			CFrame = CFrame.new(0, yPos, 0),
			Color = palette.Floor,
			Material = Enum.Material.Wood,
		})
		
		-- Floor trim/border
		table.insert(floors, {
			Name = `FloorTrim_{floor}`,
			Type = "floor",
			Size = Vector3.new(buildingSize.X - 2, floorThickness * 0.5, buildingSize.Z - 2),
			CFrame = CFrame.new(0, yPos + floorThickness/2 + 0.25, 0),
			Color = palette.Accent,
			Material = Enum.Material.SmoothPlastic,
		})
	end
	
	return floors
end

-- Generate walls for a building interior
local function generateWalls(buildingSize: Vector3, palette: any, numFloors: number): { InteriorRoom }
	local walls = {}
	local wallThickness = 1
	local roomHeight = buildingSize.Y / numFloors
	
	for floor = 1, numFloors do
		local floorBase = -buildingSize.Y/2 + (floor - 1) * roomHeight
		local yPos = floorBase + roomHeight/2
		
		-- Four walls per floor
		local wallConfigs = {
			{ size = Vector3.new(buildingSize.X - 4, roomHeight, wallThickness), offset = Vector3.new(0, yPos, -buildingSize.Z/2 + 4) },
			{ size = Vector3.new(buildingSize.X - 4, roomHeight, wallThickness), offset = Vector3.new(0, yPos, buildingSize.Z/2 - 4) },
			{ size = Vector3.new(wallThickness, roomHeight, buildingSize.Z - 4), offset = Vector3.new(-buildingSize.X/2 + 4, yPos, 0) },
			{ size = Vector3.new(wallThickness, roomHeight, buildingSize.Z - 4), offset = Vector3.new(buildingSize.X/2 - 4, yPos, 0) },
		}
		
		for i, config in ipairs(wallConfigs) do
			table.insert(walls, {
				Name = `Wall_{floor}_{i}`,
				Type = "wall",
				Size = config.size,
				CFrame = CFrame.new(config.offset),
				Color = palette.Wall,
				Material = Enum.Material.SmoothPlastic,
			})
		end
		
		-- Ceiling for each floor
		table.insert(walls, {
			Name = `Ceiling_{floor}`,
			Type = "wall",
			Size = Vector3.new(buildingSize.X - 4, wallThickness, buildingSize.Z - 4),
			CFrame = CFrame.new(0, yPos + roomHeight/2 - wallThickness/2, 0),
			Color = palette.Wall,
			Material = Enum.Material.SmoothPlastic,
		})
	end
	
	return walls
end

-- Generate stairs between floors
local function generateStairs(buildingSize: Vector3, palette: any): { InteriorRoom }
	local stairs = {}
	local numFloors = math.floor(buildingSize.Y / 12)
	
	if numFloors <= 1 then return stairs end
	
	local stairWidth = 6
	local stepHeight = 1.5
	local stepDepth = 2
	local totalHeight = buildingSize.Y - 4
	local numSteps = math.floor(totalHeight / stepHeight)
	
	for floor = 1, numFloors - 1 do
		local startY = -buildingSize.Y/2 + floor * 12
		
		-- Position stairs along one wall
		local stairX = buildingSize.X/2 - 8
		local stairZ = 0
		
		for step = 1, numSteps do
			table.insert(stairs, {
				Name = `Stair_{floor}_{step}`,
				Type = "furniture",
				Size = Vector3.new(stairWidth, stepHeight, stepDepth),
				CFrame = CFrame.new(
					stairX,
					startY + step * stepHeight - totalHeight/2 + stepHeight/2,
					stairZ + step * stepDepth/2
				),
				Color = palette.Floor,
				Material = Enum.Material.WoodPlanks,
			})
		end
		
		-- Stair rail
		table.insert(stairs, {
			Name = `StairRail_{floor}`,
			Type = "furniture",
			Size = Vector3.new(stairWidth + 2, 3, 1),
			CFrame = CFrame.new(stairX, startY + totalHeight + 1, stairZ),
			Color = palette.Accent,
			Material = Enum.Material.Metal,
		})
	end
	
	return stairs
end

-- Generate educational furniture based on building type
local function generateFurniture(buildingName: string, buildingSize: Vector3, palette: any, floor: number): { InteriorRoom }
	local furniture = {}
	local roomHeight = buildingSize.Y / math.max(1, math.floor(buildingSize.Y / 12))
	local floorY = -buildingSize.Y/2 + (floor - 1) * roomHeight + roomHeight/2
	
	-- Default furniture based on building name keywords
	local function addShelf(x: number, z: number, width: number)
		table.insert(furniture, {
			Name = "Bookshelf",
			Type = "furniture",
			Size = Vector3.new(width, 12, 2),
			CFrame = CFrame.new(x, floorY - roomHeight/2 + 6, z),
			Color = palette.Accent,
			Material = Enum.Material.Wood,
		})
	end
	
	local function addTable(x: number, z: number, width: number, length: number)
		table.insert(furniture, {
			Name = "Table",
			Type = "furniture",
			Size = Vector3.new(width, 3, length),
			CFrame = CFrame.new(x, floorY - roomHeight/2 + 4, z),
			Color = palette.Floor,
			Material = Enum.Material.Wood,
		})
		-- Table legs
		for _, offset in ipairs({ Vector3.new(-width/3, -2, -length/3), Vector3.new(width/3, -2, -length/3), 
			Vector3.new(-width/3, -2, length/3), Vector3.new(width/3, -2, length/3) }) do
			table.insert(furniture, {
				Name = "TableLeg",
				Type = "furniture",
				Size = Vector3.new(1, 4, 1),
				CFrame = CFrame.new(x + offset.X, floorY - roomHeight/2 + 2, z + offset.Z),
				Color = palette.Floor,
				Material = Enum.Material.Wood,
			})
		end
	end
	
	local function addChair(x: number, z: number, rotation: number)
		table.insert(furniture, {
			Name = "Chair",
			Type = "furniture",
			Size = Vector3.new(4, 4, 4),
			CFrame = CFrame.new(x, floorY - roomHeight/2 + 2, z) * CFrame.Angles(0, math.rad(rotation), 0),
			Color = palette.Accent,
			Material = Enum.Material.SmoothPlastic,
		})
	end
	
	local function addTorch(x: number, y: number, z: number)
		table.insert(furniture, {
			Name = "Torch",
			Type = "light",
			Size = Vector3.new(1, 3, 1),
			CFrame = CFrame.new(x, y, z),
			Color = palette.Light,
			Material = Enum.Material.Neon,
		})
	end
	
	local function addPedestal(x: number, z: number, height: number)
		table.insert(furniture, {
			Name = "Pedestal",
			Type = "furniture",
			Size = Vector3.new(4, height, 4),
			CFrame = CFrame.new(x, floorY - roomHeight/2 + height/2, z),
			Color = palette.Accent,
			Material = Enum.Material.Marble,
		})
	end
	
	-- Building-specific furniture layouts
	local lowerName = string.lower(buildingName)
	
	if string.find(lowerName, "archive") or string.find(lowerName, "library") or string.find(lowerName, "city hall") then
		-- Library/Archive style - lots of bookshelves
		local shelfSpacing = 12
		for z = -buildingSize.Z/4, buildingSize.Z/4, shelfSpacing do
			addShelf(-buildingSize.X/4, z, 15)
			addShelf(buildingSize.X/4, z, 15)
		end
		addTable(0, 0, 20, 8)
		addChair(-5, -4, 90)
		addChair(5, -4, -90)
		addChair(-5, 4, 90)
		addChair(5, 4, -90)
		
	elseif string.find(lowerName, "forge") or string.find(lowerName, "arena") then
		-- Forge/Arena style - industrial, weapons, anvil
		addPedestal(-buildingSize.X/4, 0, 8)
		addTable(buildingSize.X/4, 0, 15, 10)
		-- Forge fire
		table.insert(furniture, {
			Name = "Forge",
			Type = "light",
			Size = Vector3.new(8, 6, 8),
			CFrame = CFrame.new(-buildingSize.X/4, floorY - roomHeight/2 + 5, buildingSize.Z/4),
			Color = Color3.fromRGB(255, 100, 0),
			Material = Enum.Material.Neon,
		})
		
	elseif string.find(lowerName, "garden") or string.find(lowerName, "sanctuary") then
		-- Garden/Sanctuary style - nature, plants
		for x = -buildingSize.X/4, buildingSize.X/4, 10 do
			for z = -buildingSize.Z/4, buildingSize.Z/4, 10 do
				if math.random() > 0.5 then
					table.insert(furniture, {
						Name = "Plant",
						Type = "deco",
						Size = Vector3.new(3, math.random(4, 8), 3),
						CFrame = CFrame.new(x, floorY - roomHeight/2 + 2, z),
						Color = Color3.fromRGB(34, 139, 34),
						Material = Enum.Material.Grass,
					})
				end
			end
		end
		addTable(0, 0, 12, 12)
		
	elseif string.find(lowerName, "market") or string.find(lowerName, "shop") then
		-- Market style - stalls
		local stallCount = 3
		for i = 1, stallCount do
			local x = (i - (stallCount + 1) / 2) * (buildingSize.X / (stallCount + 1))
			table.insert(furniture, {
				Name = "Stall",
				Type = "furniture",
				Size = Vector3.new(8, 6, 6),
				CFrame = CFrame.new(x, floorY - roomHeight/2 + 3, buildingSize.Z/4),
				Color = Color3.fromHex("#92400E"),
				Material = Enum.Material.Wood,
			})
		end
		
	elseif string.find(lowerName, "observatory") or string.find(lowerName, "spire") then
		-- Observatory style - telescope, star maps
		addPedestal(0, 0, 10)
		table.insert(furniture, {
			Name = "Telescope",
			Type = "furniture",
			Size = Vector3.new(3, 8, 3),
			CFrame = CFrame.new(0, floorY - roomHeight/2 + 14, 0),
			Color = palette.Accent,
			Material = Enum.Material.DiamondPlate,
		})
		addChair(0, -6, 0)
		
	elseif string.find(lowerName, "docks") or string.find(lowerName, "undercity") then
		-- Docks/Undercity style - crates, barrels
		for i = 1, 5 do
			table.insert(furniture, {
				Name = "Crate",
				Type = "furniture",
				Size = Vector3.new(5, 5, 5),
				CFrame = CFrame.new(
					-buildingSize.X/4 + (i % 3) * 6,
					floorY - roomHeight/2 + 2.5,
					-buildingSize.Z/4 + math.floor(i/3) * 6
				),
				Color = Color3.fromHex("#78350F"),
				Material = Enum.Material.Wood,
			})
		end
		
	elseif string.find(lowerName, "carnival") then
		-- Carnival style - games, prizes
		addTable(0, 0, 10, 10)
		table.insert(furniture, {
			Name = "PrizeCase",
			Type = "deco",
			Size = Vector3.new(6, 8, 2),
			CFrame = CFrame.new(-buildingSize.X/4, floorY - roomHeight/2 + 4, 0),
			Color = palette.Accent,
			Material = Enum.Material.Glass,
		})
		
	else
		-- Generic interior - basic furniture
		addTable(0, 0, 10, 6)
		addChair(-4, -3, 45)
		addChair(4, -3, -45)
		addChair(-4, 3, 135)
		addChair(4, 3, -135)
	end
	
	-- Add lights on walls
	local lightHeight = roomHeight - 2
	addTorch(-buildingSize.X/4 + 2, floorY - roomHeight/2 + lightHeight, -buildingSize.Z/4 + 2)
	addTorch(buildingSize.X/4 - 2, floorY - roomHeight/2 + lightHeight, -buildingSize.Z/4 + 2)
	
	return furniture
end

-- Main function to generate complete interior layout
function BuildingInterior.GenerateLayout(buildingName: string, buildingSize: Vector3, districtName: string): InteriorLayout
	local palette = InteriorPalettes[districtName] or InteriorPalettes.Hub
	local rooms: { InteriorRoom } = {}
	
	local numFloors = math.max(1, math.floor(buildingSize.Y / 12))
	
	-- Generate structure (floors, walls, ceilings)
	local floors = generateFloors(buildingSize, palette)
	for _, floor in ipairs(floors) do
		table.insert(rooms, floor)
	end
	
	local walls = generateWalls(buildingSize, palette, numFloors)
	for _, wall in ipairs(walls) do
		table.insert(rooms, wall)
	end
	
	-- Generate stairs
	local stairs = generateStairs(buildingSize, palette)
	for _, stair in ipairs(stairs) do
		table.insert(rooms, stair)
	end
	
	-- Generate furniture for each floor
	for floor = 1, numFloors do
		local furniture = generateFurniture(buildingName, buildingSize, palette, floor)
		for _, item in ipairs(furniture) do
			table.insert(rooms, item)
		end
	end
	
	-- Determine door position (front of building facing district center)
	local doorCF = CFrame.new(0, -buildingSize.Y/2 + 4, buildingSize.Z/2 + 1)
	local doorPos = Vector3.new(0, -buildingSize.Y/2 + 4, buildingSize.Z/2 + 1)
	
	return {
		Rooms = rooms,
		DoorPosition = doorPos,
		DoorCFrame = doorCF,
	}
end

-- Get palette for a district
function BuildingInterior.GetPalette(districtName: string)
	return InteriorPalettes[districtName] or InteriorPalettes.Hub
end

return BuildingInterior
