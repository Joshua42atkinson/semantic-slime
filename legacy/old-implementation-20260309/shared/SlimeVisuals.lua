--!strict
-- SlimeVisuals.lua
-- Shared module for building slime 3D models.
-- Decorative parts are WELDED to the RootPart and Unanchored (Massless=true).
-- The caller only needs to CFrame the RootPart to move the whole model.

local SlimeVisuals = {}

SlimeVisuals.ELEMENT_COLORS = {
	Fire   = Color3.fromRGB(255, 90, 30),
	Water  = Color3.fromRGB(40, 140, 255),
	Earth  = Color3.fromRGB(80, 160, 80),
	Air    = Color3.fromRGB(190, 210, 255),
	Shadow = Color3.fromRGB(110, 40, 160),
	Light  = Color3.fromRGB(255, 230, 80),
	Normal = Color3.fromRGB(160, 200, 160),
}

local ELEMENT_SECONDARY = {
	Fire   = Color3.fromRGB(255, 40, 0),
	Water  = Color3.fromRGB(150, 220, 255),
	Earth  = Color3.fromRGB(50, 120, 50),
	Air    = Color3.fromRGB(255, 255, 255),
	Shadow = Color3.fromRGB(50, 0, 80),
	Light  = Color3.fromRGB(255, 255, 180),
	Normal = Color3.fromRGB(140, 180, 140),
}

-- Helper: weld a part to root so it moves with the model
local function weld(root: Part, child: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = child
	w.Parent = root
	child.Anchored = false
	child.Massless = true
end

-- Helper: create a basic decorative part already welded to root
local function addPart(root: Part, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat
	p.CastShadow = false
	p.CanCollide = false
	if shape then p.Shape = shape end
	p.Parent = root.Parent
	weld(root, p)
	return p
end

function SlimeVisuals.GetElement(term: string): string
	local lower = term:lower()
	if lower:find("burn") or lower:find("fire") or lower:find("ignit") or lower:find("hot") or lower:find("heat") or lower:find("blaz") or lower:find("ember") then
		return "Fire"
	elseif lower:find("flow") or lower:find("water") or lower:find("aqua") or lower:find("wet") or lower:find("rain") or lower:find("tide") or lower:find("moist") then
		return "Water"
	elseif lower:find("rock") or lower:find("stone") or lower:find("earth") or lower:find("ground") or lower:find("soil") or lower:find("natur") or lower:find("blossom") then
		return "Earth"
	elseif lower:find("wind") or lower:find("air") or lower:find("sky") or lower:find("breath") or lower:find("gust") or lower:find("cloud") or lower:find("aero") then
		return "Air"
	elseif lower:find("dark") or lower:find("shadow") or lower:find("gloom") or lower:find("night") or lower:find("umbra") or lower:find("void") then
		return "Shadow"
	elseif lower:find("radiant") or lower:find("light") or lower:find("sun") or lower:find("bright") or lower:find("luminous") or lower:find("lux") or lower:find("beam") then
		return "Light"
	end
	return "Normal"
end

function SlimeVisuals.BuildStructure(model: Model, term: string, element: string): Part
	local color = SlimeVisuals.ELEMENT_COLORS[element] or SlimeVisuals.ELEMENT_COLORS.Normal
	local secondary = ELEMENT_SECONDARY[element] or ELEMENT_SECONDARY.Normal

	-- ── PRIMARY BODY ──────────────────────────────────────────────
	local root = Instance.new("Part")
	root.Name = "RootPart"
	root.Size = Vector3.new(2.8, 2.8, 2.8)
	root.Shape = Enum.PartType.Ball
	root.Material = Enum.Material.Neon
	root.Anchored = true
	root.CanCollide = false
	root.CastShadow = false
	root.Color = color
	root.Parent = model

	-- ── ELEMENT-SPECIFIC DECORATIONS ──────────────────────────────
	if element == "Fire" then
		-- A ring of 6 spiky wedge "flames" sprouting from the top
		for i = 1, 6 do
			local angle = math.rad((i / 6) * 360)
			local offset = CFrame.new(math.cos(angle) * 1.1, 1.0, math.sin(angle) * 1.1)
				* CFrame.Angles(math.rad(-50 + math.random(-15, 15)), angle, 0)
			local spike = addPart(root,
				Vector3.new(0.5, 1.8, 0.4),
				root.CFrame * offset,
				(i % 2 == 0) and color or secondary,
				Enum.Material.Neon)
		end
		-- Small inner glow core
		addPart(root, Vector3.new(1.2, 1.2, 1.2), root.CFrame, secondary, Enum.Material.Neon, Enum.PartType.Ball)

	elseif element == "Water" then
		-- Raised droplet cap
		addPart(root, Vector3.new(2.0, 2.2, 2.0), root.CFrame * CFrame.new(0, 1.5, 0), color, Enum.Material.Neon, Enum.PartType.Ball)
		-- Thin base ripple ring
		addPart(root, Vector3.new(4.5, 0.3, 4.5), root.CFrame * CFrame.new(0, -1.3, 0), secondary, Enum.Material.Neon, Enum.PartType.Cylinder)

	elseif element == "Air" then
		root.Transparency = 0.35
		-- 3 orbiting cloud puffs at different heights
		for i = 1, 3 do
			local angle = math.rad((i / 3) * 360)
			local puff = addPart(root,
				Vector3.new(1.8, 1.4, 1.8),
				root.CFrame * CFrame.new(math.cos(angle) * 1.6, (i - 2) * 0.6, math.sin(angle) * 1.6),
				Color3.new(1, 1, 1),
				Enum.Material.Neon,
				Enum.PartType.Ball)
			puff.Transparency = 0.5
		end

	elseif element == "Earth" then
		root.Shape = Enum.PartType.Block
		root.Material = Enum.Material.SmoothPlastic
		-- 5 crystal shards erupting from top and sides
		for i = 1, 5 do
			local angle = math.rad((i / 5) * 360)
			local lean = math.rad(math.random(15, 50))
			addPart(root,
				Vector3.new(0.7, 2.5 - i * 0.3, 0.7),
				root.CFrame * CFrame.Angles(lean, angle, 0) * CFrame.new(0, 1.2, 0),
				(i <= 2) and Color3.fromRGB(80, 200, 100) or Color3.fromRGB(60, 160, 80),
				Enum.Material.Glass)
		end

	elseif element == "Shadow" then
		root.Transparency = 0.15
		-- ForceField aura shell
		local aura = addPart(root, Vector3.new(3.8, 3.8, 3.8), root.CFrame, Color3.fromRGB(60, 0, 120), Enum.Material.ForceField, Enum.PartType.Ball)
		aura.Transparency = 0.4
		-- Dark orbiting tendrils
		for i = 1, 4 do
			local angle = math.rad((i / 4) * 360)
			addPart(root,
				Vector3.new(0.4, 2.2, 0.4),
				root.CFrame * CFrame.new(math.cos(angle) * 1.5, 0, math.sin(angle) * 1.5) * CFrame.Angles(0, 0, math.rad(20)),
				secondary,
				Enum.Material.Neon)
		end

	elseif element == "Light" then
		-- 3 crossing star-bars (X, Y, Z axes)
		for _, rot in ipairs({CFrame.Angles(0,0,0), CFrame.Angles(math.rad(90),0,0), CFrame.Angles(0,0,math.rad(90))}) do
			addPart(root, Vector3.new(0.35, 4.5, 0.35), root.CFrame * rot, Color3.new(1,1,0.9), Enum.Material.Neon)
		end
		-- Bright inner sphere
		addPart(root, Vector3.new(1.5, 1.5, 1.5), root.CFrame, Color3.new(1,1,1), Enum.Material.Neon, Enum.PartType.Ball)

	else -- Normal / fallback
		-- Subtle highlight stripe
		addPart(root, Vector3.new(2.9, 0.6, 2.9), root.CFrame * CFrame.new(0, 0.5, 0), color:Lerp(Color3.new(1,1,1), 0.4), Enum.Material.Neon, Enum.PartType.Cylinder)
	end

	-- ── INNER SOUL CORE ───────────────────────────────────────────
	local core = addPart(root, Vector3.new(1.1, 1.1, 1.1), root.CFrame, color:Lerp(Color3.new(0,0,0), 0.5), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	core.Transparency = 0.25

	-- ── EYES ──────────────────────────────────────────────────────
	local eyeOffsets = { Vector3.new(-0.42, 0.28, 1.0), Vector3.new(0.42, 0.28, 1.0) }
	for i, offset in ipairs(eyeOffsets) do
		-- White sclera
		local eye = addPart(root, Vector3.new(0.45, 0.45, 0.22), root.CFrame * CFrame.new(offset), Color3.new(1,1,1), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		-- Dark pupil
		addPart(root, Vector3.new(0.22, 0.22, 0.12), eye.CFrame * CFrame.new(0, 0, 0.12), Color3.new(0,0,0), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		-- Sparkle
		addPart(root, Vector3.new(0.08, 0.08, 0.05), eye.CFrame * CFrame.new(0.07, 0.08, 0.14), Color3.new(1,1,1), Enum.Material.Neon, Enum.PartType.Ball)
	end

	model.PrimaryPart = root
	return root
end

return SlimeVisuals
