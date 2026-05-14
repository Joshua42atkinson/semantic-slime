--!strict
-- NPCVisualBuilders.lua
-- Per-NPC visual model builders. Each function creates a unique, lore-accurate 3D model.
-- Called by NPCService:SpawnNPC() to replace the old generic body builder.

local NPCVisualBuilders = {}

-- ═══════════════════════════════════════════════════════════════
-- SHARED HELPERS
-- ═══════════════════════════════════════════════════════════════

local function makePart(name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material, model: Model, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = mat
	p.Anchored = true
	p.CanCollide = false
	if shape then p.Shape = shape end
	p.Parent = model
	return p
end

local function makeHRP(cf: CFrame, size: Vector3, model: Model): Part
	local hrp = Instance.new("Part")
	hrp.Name = "HumanoidRootPart"
	hrp.Size = size
	hrp.Transparency = 1
	hrp.Anchored = true
	hrp.CFrame = cf
	hrp.Parent = model
	model.PrimaryPart = hrp
	return hrp
end

local function addGlow(part: Part, color: Color3, range: number?)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = 2
	light.Range = range or 12
	light.Parent = part
end

local function addBillboardName(hrp: Part, name: string, archetype: string, color: Color3)
	local bGui = Instance.new("BillboardGui")
	bGui.Size = UDim2.new(0, 200, 0, 50)
	bGui.StudsOffset = Vector3.new(0, 3, 0)
	bGui.Adornee = hrp
	bGui.AlwaysOnTop = false
	bGui.MaxDistance = 60
	bGui.Parent = hrp

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 0.6)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = bGui

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.fromScale(1, 0.4)
	sub.Position = UDim2.fromScale(0, 0.6)
	sub.BackgroundTransparency = 1
	sub.Text = "<" .. archetype .. ">"
	sub.TextColor3 = color:Lerp(Color3.new(1,1,1), 0.5)
	sub.TextStrokeTransparency = 0.3
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.Parent = bGui
end

-- Standard biped helper (used by humanoid NPCs with varying scale/colors)
local function makeBiped(loc: CFrame, model: Model, scale: number, bodyColor: Color3, headColor: Color3, legColor: Color3)
	local s = scale
	local torso = makePart("Torso", Vector3.new(2*s, 2*s, 1*s), loc * CFrame.new(0, 3*s, 0), bodyColor, Enum.Material.SmoothPlastic, model)
	local head = makePart("Head", Vector3.new(1.2*s, 1.2*s, 1.2*s), loc * CFrame.new(0, 4.6*s, 0), headColor, Enum.Material.SmoothPlastic, model)
	makePart("LeftArm", Vector3.new(1*s, 2*s, 1*s), loc * CFrame.new(-1.5*s, 3*s, 0), bodyColor, Enum.Material.SmoothPlastic, model)
	makePart("RightArm", Vector3.new(1*s, 2*s, 1*s), loc * CFrame.new(1.5*s, 3*s, 0), bodyColor, Enum.Material.SmoothPlastic, model)
	makePart("LeftLeg", Vector3.new(1*s, 2*s, 1*s), loc * CFrame.new(-0.5*s, 1*s, 0), legColor, Enum.Material.SmoothPlastic, model)
	makePart("RightLeg", Vector3.new(1*s, 2*s, 1*s), loc * CFrame.new(0.5*s, 1*s, 0), legColor, Enum.Material.SmoothPlastic, model)
	local hrp = makeHRP(loc * CFrame.new(0, 2.5*s, 0), Vector3.new(2*s, 5*s, 1*s), model)
	return hrp, head, torso
end

-- ═══════════════════════════════════════════════════════════════
-- 01 BARNABY — Giant Cyclops (The Innocent)
-- ═══════════════════════════════════════════════════════════════
local function buildBarnaby(loc: CFrame, model: Model, data: any): Part
	local s = 2.5
	local blue = Color3.fromRGB(60, 130, 220)
	local skin = Color3.fromRGB(255, 210, 170)
	local hrp, head, torso = makeBiped(loc, model, s, blue, skin, blue)

	-- Remove default face — single giant eye
	local eye = makePart("CyclopsEye", Vector3.new(2, 2, 1.5), head.CFrame * CFrame.new(0, 0, -0.8*s), Color3.new(1,1,1), Enum.Material.Neon, model, Enum.PartType.Ball)
	addGlow(eye, Color3.fromRGB(255, 250, 200), 15)
	-- Pupil
	makePart("Pupil", Vector3.new(0.8, 0.8, 0.3), eye.CFrame * CFrame.new(0, 0, -0.6), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	-- Golden iris flecks
	makePart("Iris", Vector3.new(1.3, 1.3, 0.2), eye.CFrame * CFrame.new(0, 0, -0.3), Color3.fromRGB(218, 165, 32), Enum.Material.Neon, model, Enum.PartType.Ball)

	-- Propeller beanie
	local beanie = makePart("Beanie", Vector3.new(1.8*s, 0.6*s, 1.8*s), head.CFrame * CFrame.new(0, 0.9*s, 0), Color3.fromRGB(255, 50, 50), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	makePart("Propeller", Vector3.new(3*s, 0.15, 0.2), beanie.CFrame * CFrame.new(0, 0.3*s, 0), Color3.fromRGB(255, 220, 50), Enum.Material.Metal, model)

	-- Flower crown (torus approximated with small spheres)
	for i = 1, 8 do
		local angle = math.rad((i / 8) * 360)
		local r = 1.0 * s
		local flowerColor = (i % 2 == 0) and Color3.fromRGB(255, 130, 180) or Color3.fromRGB(255, 220, 80)
		makePart("Flower" .. i, Vector3.new(0.5*s, 0.5*s, 0.5*s),
			head.CFrame * CFrame.new(math.cos(angle)*r, 0.4*s, math.sin(angle)*r),
			flowerColor, Enum.Material.Neon, model, Enum.PartType.Ball)
	end

	addBillboardName(hrp, "Barnaby", "The Innocent", blue)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 02 YORICK — Skeleton (The Everyman)
-- ═══════════════════════════════════════════════════════════════
local function buildYorick(loc: CFrame, model: Model, data: any): Part
	local bone = Color3.fromRGB(255, 245, 220)
	local vestOrange = Color3.fromRGB(255, 140, 0)
	local hrp, head, torso = makeBiped(loc, model, 1, bone, bone, Color3.fromRGB(80, 80, 80))

	-- Safety vest over torso
	makePart("SafetyVest", Vector3.new(2.2, 2.2, 0.3), torso.CFrame * CFrame.new(0, 0, -0.5), vestOrange, Enum.Material.Neon, model)
	-- Hard hat
	makePart("HardHat", Vector3.new(1.6, 0.5, 1.6), head.CFrame * CFrame.new(0, 0.7, 0), Color3.fromRGB(255, 200, 0), Enum.Material.SmoothPlastic, model, Enum.PartType.Cylinder)
	-- Push broom
	makePart("BroomHandle", Vector3.new(0.2, 5, 0.2), loc * CFrame.new(2, 3, 0), Color3.fromRGB(160, 120, 60), Enum.Material.Wood, model)
	makePart("BroomHead", Vector3.new(1.5, 0.4, 0.6), loc * CFrame.new(2, 0.5, 0), Color3.fromRGB(120, 90, 40), Enum.Material.Wood, model)

	-- Skull face — hollow eye sockets
	makePart("EyeSocketL", Vector3.new(0.3, 0.3, 0.2), head.CFrame * CFrame.new(-0.25, 0.1, -0.6), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	makePart("EyeSocketR", Vector3.new(0.3, 0.3, 0.2), head.CFrame * CFrame.new(0.25, 0.1, -0.6), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)

	addBillboardName(hrp, "Yorick", "The Everyman", vestOrange)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 03 KAEL — Minotaur (The Hero)
-- ═══════════════════════════════════════════════════════════════
local function buildKael(loc: CFrame, model: Model, data: any): Part
	local s = 1.7
	local silver = Color3.fromRGB(180, 195, 210)
	local brown = Color3.fromRGB(140, 100, 60)
	local hrp, head, torso = makeBiped(loc, model, s, silver, brown, Color3.fromRGB(60, 60, 70))

	-- Horns
	makePart("HornL", Vector3.new(0.4*s, 1.5*s, 0.4*s), head.CFrame * CFrame.new(-0.5*s, 0.8*s, 0) * CFrame.Angles(0, 0, math.rad(-20)), Color3.fromRGB(200, 180, 140), Enum.Material.SmoothPlastic, model, Enum.PartType.Cylinder)
	makePart("HornR", Vector3.new(0.4*s, 1.5*s, 0.4*s), head.CFrame * CFrame.new(0.5*s, 0.8*s, 0) * CFrame.Angles(0, 0, math.rad(20)), Color3.fromRGB(200, 180, 140), Enum.Material.SmoothPlastic, model, Enum.PartType.Cylinder)

	-- Snout
	makePart("Snout", Vector3.new(0.8*s, 0.5*s, 0.6*s), head.CFrame * CFrame.new(0, -0.3*s, -0.7*s), brown, Enum.Material.SmoothPlastic, model)

	-- Cape
	makePart("Cape", Vector3.new(1.8*s, 2.5*s, 0.15), torso.CFrame * CFrame.new(0, -0.3*s, 0.6*s), Color3.fromRGB(180, 30, 30), Enum.Material.Fabric, model)

	-- Sword on back
	makePart("SwordBlade", Vector3.new(0.4, 4*s, 0.15), torso.CFrame * CFrame.new(0.8*s, 0.5*s, 0.7*s) * CFrame.Angles(0, 0, math.rad(30)), Color3.fromRGB(200, 210, 220), Enum.Material.Metal, model)
	makePart("SwordHilt", Vector3.new(1.2, 0.3, 0.3), torso.CFrame * CFrame.new(0.5*s, 2.2*s, 0.7*s), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, model)

	-- Gold chest plate accent
	makePart("ChestPlate", Vector3.new(1.6*s, 1.2*s, 0.2), torso.CFrame * CFrame.new(0, 0.2*s, -0.55*s), Color3.fromRGB(255, 215, 0), Enum.Material.Metal, model)

	addBillboardName(hrp, "Kael", "The Hero", Color3.fromRGB(255, 215, 0))
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 04 MARTHA — Gargoyle (The Caregiver)
-- ═══════════════════════════════════════════════════════════════
local function buildMartha(loc: CFrame, model: Model, data: any): Part
	local stone = Color3.fromRGB(140, 140, 145)
	local pink = Color3.fromRGB(255, 180, 200)
	-- Hover: raise position by 2 studs
	local hoverLoc = loc * CFrame.new(0, 2, 0)
	local hrp, head, torso = makeBiped(hoverLoc, model, 1.1, stone, stone, stone)
	torso.Material = Enum.Material.Slate
	head.Material = Enum.Material.Slate

	-- Reading glasses
	makePart("GlassL", Vector3.new(0.4, 0.35, 0.05), head.CFrame * CFrame.new(-0.25, 0, -0.65), Color3.fromRGB(180, 160, 120), Enum.Material.Glass, model, Enum.PartType.Cylinder)
	makePart("GlassR", Vector3.new(0.4, 0.35, 0.05), head.CFrame * CFrame.new(0.25, 0, -0.65), Color3.fromRGB(180, 160, 120), Enum.Material.Glass, model, Enum.PartType.Cylinder)
	makePart("GlassBridge", Vector3.new(0.15, 0.05, 0.05), head.CFrame * CFrame.new(0, 0, -0.65), Color3.fromRGB(180, 160, 120), Enum.Material.Metal, model)

	-- Bat wings
	makePart("WingL", Vector3.new(0.15, 2.5, 3), torso.CFrame * CFrame.new(-1.5, 0.5, 0.6) * CFrame.Angles(0, math.rad(-20), math.rad(-15)), stone, Enum.Material.Slate, model)
	makePart("WingR", Vector3.new(0.15, 2.5, 3), torso.CFrame * CFrame.new(1.5, 0.5, 0.6) * CFrame.Angles(0, math.rad(20), math.rad(15)), stone, Enum.Material.Slate, model)

	-- Floral apron
	makePart("Apron", Vector3.new(1.8, 2.2, 0.15), torso.CFrame * CFrame.new(0, -0.5, -0.55), pink, Enum.Material.Fabric, model)

	-- Soup bowl
	makePart("SoupBowl", Vector3.new(0.8, 0.4, 0.8), hoverLoc * CFrame.new(-1.8, 3, -0.5), Color3.fromRGB(200, 180, 150), Enum.Material.SmoothPlastic, model, Enum.PartType.Cylinder)

	addBillboardName(hrp, "Martha", "The Caregiver", pink)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 05 GRIBBLE — Goblin (The Explorer)
-- ═══════════════════════════════════════════════════════════════
local function buildGribble(loc: CFrame, model: Model, data: any): Part
	local s = 0.6
	local green = Color3.fromRGB(80, 180, 60)
	local brown = Color3.fromRGB(140, 100, 50)
	local hrp, head, torso = makeBiped(loc, model, s, brown, green, brown)

	-- Pointy ears
	makePart("EarL", Vector3.new(0.15*s, 0.6*s, 0.3*s), head.CFrame * CFrame.new(-0.7*s, 0.2*s, 0) * CFrame.Angles(0, 0, math.rad(-30)), green, Enum.Material.SmoothPlastic, model)
	makePart("EarR", Vector3.new(0.15*s, 0.6*s, 0.3*s), head.CFrame * CFrame.new(0.7*s, 0.2*s, 0) * CFrame.Angles(0, 0, math.rad(30)), green, Enum.Material.SmoothPlastic, model)

	-- Oversized aviator goggles
	makePart("GogglesL", Vector3.new(0.5, 0.45, 0.2), head.CFrame * CFrame.new(-0.25, 0.3*s, -0.5*s), Color3.fromRGB(180, 140, 60), Enum.Material.Glass, model, Enum.PartType.Cylinder)
	makePart("GogglesR", Vector3.new(0.5, 0.45, 0.2), head.CFrame * CFrame.new(0.25, 0.3*s, -0.5*s), Color3.fromRGB(180, 140, 60), Enum.Material.Glass, model, Enum.PartType.Cylinder)
	makePart("GoggleStrap", Vector3.new(1.3, 0.12, 0.1), head.CFrame * CFrame.new(0, 0.3*s, 0), Color3.fromRGB(80, 60, 30), Enum.Material.Fabric, model)

	-- Giant backpack
	makePart("Backpack", Vector3.new(1.5*s, 2*s, 1.2*s), torso.CFrame * CFrame.new(0, 0, 0.8*s), brown, Enum.Material.Fabric, model)
	-- Stuff sticking out
	makePart("MapRoll", Vector3.new(0.15, 1.2*s, 0.15), torso.CFrame * CFrame.new(0.4*s, 1.2*s, 1*s) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(240, 230, 200), Enum.Material.SmoothPlastic, model)

	-- Magnifying glass
	makePart("MagHandle", Vector3.new(0.12, 0.8, 0.12), loc * CFrame.new(0.8, 1.2*s, -0.5), Color3.fromRGB(160, 120, 60), Enum.Material.Wood, model)
	makePart("MagLens", Vector3.new(0.5, 0.5, 0.08), loc * CFrame.new(0.8, 1.8*s, -0.5), Color3.fromRGB(200, 230, 255), Enum.Material.Glass, model, Enum.PartType.Cylinder)

	addBillboardName(hrp, "Gribble", "The Explorer", green)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 06 NYX — Banshee (The Rebel)
-- ═══════════════════════════════════════════════════════════════
local function buildNyx(loc: CFrame, model: Model, data: any): Part
	local black = Color3.fromRGB(30, 30, 35)
	local neonPink = Color3.fromRGB(255, 50, 180)
	local pale = Color3.fromRGB(220, 210, 225)
	local hrp, head, torso = makeBiped(loc, model, 1, black, pale, Color3.fromRGB(25, 25, 25))

	-- Make body translucent (ghostly)
	for _, p in model:GetChildren() do
		if p:IsA("Part") and p.Name ~= "HumanoidRootPart" then
			p.Transparency = 0.3
		end
	end

	-- Wild neon hair
	makePart("Hair", Vector3.new(1.6, 1.2, 1.4), head.CFrame * CFrame.new(0, 0.6, 0.1) * CFrame.Angles(math.rad(-10), 0, 0), neonPink, Enum.Material.Neon, model)
	makePart("HairSpike1", Vector3.new(0.3, 1, 0.3), head.CFrame * CFrame.new(-0.4, 1.1, 0) * CFrame.Angles(0, 0, math.rad(-25)), neonPink, Enum.Material.Neon, model)
	makePart("HairSpike2", Vector3.new(0.3, 0.9, 0.3), head.CFrame * CFrame.new(0.5, 1, -0.2) * CFrame.Angles(0, 0, math.rad(20)), neonPink, Enum.Material.Neon, model)

	-- Eyeliner / dark eye markings
	makePart("EyelinerL", Vector3.new(0.35, 0.15, 0.1), head.CFrame * CFrame.new(-0.22, 0.05, -0.6), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model)
	makePart("EyelinerR", Vector3.new(0.35, 0.15, 0.1), head.CFrame * CFrame.new(0.22, 0.05, -0.6), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model)

	-- Guitar on back
	makePart("GuitarBody", Vector3.new(1, 1.4, 0.3), torso.CFrame * CFrame.new(0.3, -0.5, 0.7) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(60, 0, 0), Enum.Material.Wood, model)
	makePart("GuitarNeck", Vector3.new(0.25, 2.5, 0.15), torso.CFrame * CFrame.new(0.1, 1.5, 0.7) * CFrame.Angles(0, 0, math.rad(15)), Color3.fromRGB(80, 50, 20), Enum.Material.Wood, model)

	-- Ghostly glow
	local aura = makePart("GhostAura", Vector3.new(3, 5, 3), hrp.CFrame, neonPink, Enum.Material.ForceField, model, Enum.PartType.Ball)
	aura.Transparency = 0.85
	addGlow(aura, neonPink, 18)

	addBillboardName(hrp, "Nyx", "The Rebel", neonPink)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 07 VLAD — Vampire (The Lover)
-- ═══════════════════════════════════════════════════════════════
local function buildVlad(loc: CFrame, model: Model, data: any): Part
	local pale = Color3.fromRGB(250, 240, 245)
	local darkRed = Color3.fromRGB(120, 15, 25)
	local hrp, head, torso = makeBiped(loc, model, 1, Color3.fromRGB(30, 25, 40), pale, Color3.fromRGB(20, 20, 30))

	-- Cape with red collar
	makePart("Cape", Vector3.new(2.2, 3, 0.15), torso.CFrame * CFrame.new(0, -0.3, 0.55), Color3.fromRGB(15, 15, 20), Enum.Material.Fabric, model)
	makePart("CapeCollar", Vector3.new(2.4, 0.8, 0.3), torso.CFrame * CFrame.new(0, 1.2, 0.4), darkRed, Enum.Material.Fabric, model)

	-- Heart-shaped sunglasses (two angled circles)
	makePart("HeartGlassL", Vector3.new(0.4, 0.35, 0.08), head.CFrame * CFrame.new(-0.22, 0.05, -0.62), Color3.fromRGB(255, 50, 80), Enum.Material.Neon, model, Enum.PartType.Ball)
	makePart("HeartGlassR", Vector3.new(0.4, 0.35, 0.08), head.CFrame * CFrame.new(0.22, 0.05, -0.62), Color3.fromRGB(255, 50, 80), Enum.Material.Neon, model, Enum.PartType.Ball)

	-- Fangs
	makePart("FangL", Vector3.new(0.08, 0.2, 0.08), head.CFrame * CFrame.new(-0.15, -0.5, -0.5), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model)
	makePart("FangR", Vector3.new(0.08, 0.2, 0.08), head.CFrame * CFrame.new(0.15, -0.5, -0.5), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model)

	-- Rose in hand
	makePart("RoseStem", Vector3.new(0.08, 1.2, 0.08), loc * CFrame.new(-1.6, 2.5, -0.5), Color3.fromRGB(30, 100, 30), Enum.Material.Grass, model)
	local rose = makePart("RoseBud", Vector3.new(0.4, 0.3, 0.4), loc * CFrame.new(-1.6, 3.2, -0.5), Color3.fromRGB(220, 20, 40), Enum.Material.Neon, model, Enum.PartType.Ball)
	addGlow(rose, Color3.fromRGB(220, 20, 40), 6)

	-- Puffy shirt accent
	makePart("Shirt", Vector3.new(1.6, 0.6, 0.3), torso.CFrame * CFrame.new(0, 0.5, -0.55), Color3.new(1,1,1), Enum.Material.Fabric, model)

	addBillboardName(hrp, "Vlad", "The Lover", darkRed)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 08 PYGMALION — Frost-Clay Golem (The Creator)
-- ═══════════════════════════════════════════════════════════════
local function buildPygmalion(loc: CFrame, model: Model, data: any): Part
	local s = 1.5
	local clay = Color3.fromRGB(160, 160, 170)
	local ice = Color3.fromRGB(180, 220, 255)
	local hrp, head, torso = makeBiped(loc, model, s, clay, clay, clay)
	torso.Material = Enum.Material.Slate
	head.Material = Enum.Material.Slate

	-- Glowing blue crystal eyes
	makePart("EyeL", Vector3.new(0.3*s, 0.3*s, 0.15), head.CFrame * CFrame.new(-0.25*s, 0.1*s, -0.65*s), ice, Enum.Material.Neon, model, Enum.PartType.Ball)
	makePart("EyeR", Vector3.new(0.3*s, 0.3*s, 0.15), head.CFrame * CFrame.new(0.25*s, 0.1*s, -0.65*s), ice, Enum.Material.Neon, model, Enum.PartType.Ball)

	-- Paint-splattered apron
	local apron = makePart("Apron", Vector3.new(1.8*s, 2.5*s, 0.15), torso.CFrame * CFrame.new(0, -0.3*s, -0.55*s), Color3.fromRGB(50, 45, 40), Enum.Material.Fabric, model)
	-- Paint splatters on apron
	for i = 1, 4 do
		local colors = {Color3.fromRGB(255, 80, 50), Color3.fromRGB(50, 130, 255), Color3.fromRGB(255, 220, 30), Color3.fromRGB(100, 220, 80)}
		makePart("Splat" .. i, Vector3.new(0.4*s, 0.4*s, 0.05),
			apron.CFrame * CFrame.new((math.random()-0.5)*1.2*s, (math.random()-0.5)*1.8*s, -0.1),
			colors[i], Enum.Material.Neon, model, Enum.PartType.Ball)
	end

	-- Chisel and mallet on back
	makePart("Chisel", Vector3.new(0.2*s, 2.5*s, 0.2*s), torso.CFrame * CFrame.new(-0.6*s, 0.5*s, 0.7*s) * CFrame.Angles(0, 0, math.rad(10)), Color3.fromRGB(180, 180, 190), Enum.Material.Metal, model)
	makePart("Mallet", Vector3.new(0.8*s, 0.6*s, 0.6*s), torso.CFrame * CFrame.new(0.6*s, 1.5*s, 0.7*s), Color3.fromRGB(140, 100, 50), Enum.Material.Wood, model)

	-- Floating snowflake above head
	local snowflake = makePart("Snowflake", Vector3.new(1.2, 1.2, 0.2), head.CFrame * CFrame.new(0, 2*s, 0) * CFrame.Angles(0, math.rad(45), 0), ice, Enum.Material.Neon, model)
	addGlow(snowflake, ice, 20)

	addBillboardName(hrp, "Pygmalion", "The Creator", ice)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 09 CHESTY — Mimic Treasure Chest (The Jester)
-- NOT a humanoid — custom box build
-- ═══════════════════════════════════════════════════════════════
local function buildChesty(loc: CFrame, model: Model, data: any): Part
	local wood = Color3.fromRGB(140, 90, 40)
	local iron = Color3.fromRGB(80, 80, 90)

	-- Main chest body
	local body = makePart("ChestBody", Vector3.new(3, 2, 2.5), loc * CFrame.new(0, 1.5, 0), wood, Enum.Material.Wood, model)
	-- Iron bands
	makePart("Band1", Vector3.new(3.1, 0.2, 2.6), loc * CFrame.new(0, 1, 0), iron, Enum.Material.Metal, model)
	makePart("Band2", Vector3.new(3.1, 0.2, 2.6), loc * CFrame.new(0, 2, 0), iron, Enum.Material.Metal, model)
	-- Lock
	makePart("Lock", Vector3.new(0.5, 0.5, 0.15), loc * CFrame.new(0, 1.5, -1.3), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, model, Enum.PartType.Cylinder)

	-- Open lid (tilted back)
	makePart("Lid", Vector3.new(3, 0.4, 2.5), loc * CFrame.new(0, 2.8, 0.3) * CFrame.Angles(math.rad(-30), 0, 0), wood, Enum.Material.Wood, model)
	makePart("LidBand", Vector3.new(3.1, 0.15, 2.6), loc * CFrame.new(0, 2.9, 0.25) * CFrame.Angles(math.rad(-30), 0, 0), iron, Enum.Material.Metal, model)

	-- Googly eyes
	local eyeY = 2.8
	local eyeL = makePart("EyeL", Vector3.new(0.7, 0.7, 0.5), loc * CFrame.new(-0.6, eyeY, -1), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	makePart("PupilL", Vector3.new(0.3, 0.3, 0.2), eyeL.CFrame * CFrame.new(0.1, -0.1, -0.2), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	local eyeR = makePart("EyeR", Vector3.new(0.7, 0.7, 0.5), loc * CFrame.new(0.6, eyeY, -1), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)
	makePart("PupilR", Vector3.new(0.3, 0.3, 0.2), eyeR.CFrame * CFrame.new(-0.1, -0.1, -0.2), Color3.new(0,0,0), Enum.Material.SmoothPlastic, model, Enum.PartType.Ball)

	-- Blunt teeth
	for i = -3, 3 do
		makePart("Tooth" .. i, Vector3.new(0.3, 0.35, 0.2), loc * CFrame.new(i * 0.35, 2.3, -1.15), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model)
	end

	-- Big purple tongue
	makePart("Tongue", Vector3.new(1, 0.2, 1.5), loc * CFrame.new(0, 2.1, -1.8) * CFrame.Angles(math.rad(15), 0, 0), Color3.fromRGB(180, 50, 200), Enum.Material.SmoothPlastic, model)

	local hrp = makeHRP(loc * CFrame.new(0, 1.5, 0), Vector3.new(3, 3, 2.5), model)
	addBillboardName(hrp, "Chesty", "The Jester", Color3.fromRGB(255, 215, 0))
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 10 OZYMANDIAS — Blind Cat (The Sage)
-- Quadruped build, no biped.
-- ═══════════════════════════════════════════════════════════════
local function buildOzymandias(loc: CFrame, model: Model, data: any): Part
	local fur = Color3.fromRGB(120, 110, 95)
	local gold = Color3.fromRGB(255, 220, 100)

	-- Body (horizontal = cat torso)
	local body = makePart("Body", Vector3.new(1.2, 1, 2.2), loc * CFrame.new(0, 1.5, 0), fur, Enum.Material.Fabric, model)
	-- Head
	local head = makePart("Head", Vector3.new(1, 0.9, 0.9), loc * CFrame.new(0, 1.9, -1.3), fur, Enum.Material.Fabric, model)
	-- Ears
	makePart("EarL", Vector3.new(0.2, 0.4, 0.15), head.CFrame * CFrame.new(-0.3, 0.5, 0), fur, Enum.Material.Fabric, model)
	makePart("EarR", Vector3.new(0.2, 0.4, 0.15), head.CFrame * CFrame.new(0.3, 0.5, 0), fur, Enum.Material.Fabric, model)
	-- Blindfold
	makePart("Blindfold", Vector3.new(1.05, 0.25, 0.95), head.CFrame * CFrame.new(0, 0.1, 0), Color3.fromRGB(230, 220, 180), Enum.Material.Fabric, model)

	-- Legs (4 short pillars)
	makePart("LegFL", Vector3.new(0.3, 1, 0.3), loc * CFrame.new(-0.4, 0.5, -0.7), fur, Enum.Material.Fabric, model)
	makePart("LegFR", Vector3.new(0.3, 1, 0.3), loc * CFrame.new(0.4, 0.5, -0.7), fur, Enum.Material.Fabric, model)
	makePart("LegBL", Vector3.new(0.3, 1, 0.3), loc * CFrame.new(-0.4, 0.5, 0.7), fur, Enum.Material.Fabric, model)
	makePart("LegBR", Vector3.new(0.3, 1, 0.3), loc * CFrame.new(0.4, 0.5, 0.7), fur, Enum.Material.Fabric, model)

	-- Tail
	makePart("Tail", Vector3.new(0.2, 0.2, 1.5), loc * CFrame.new(0, 1.8, 1.5) * CFrame.Angles(math.rad(-30), 0, 0), fur, Enum.Material.Fabric, model)

	-- Floating book
	local book = makePart("FloatingBook", Vector3.new(1.5, 0.2, 1), loc * CFrame.new(0, 3.2, -1) * CFrame.Angles(math.rad(-15), math.rad(10), 0), Color3.fromRGB(80, 50, 30), Enum.Material.Wood, model)
	-- Book pages
	makePart("Pages", Vector3.new(1.3, 0.15, 0.9), book.CFrame * CFrame.new(0, 0.1, 0), Color3.fromRGB(245, 240, 220), Enum.Material.SmoothPlastic, model)

	-- Wisdom aura glow
	local aura = makePart("WisdomAura", Vector3.new(3, 3, 3), body.CFrame, gold, Enum.Material.ForceField, model, Enum.PartType.Ball)
	aura.Transparency = 0.9
	addGlow(body, gold, 12)

	-- Runic text glow on body
	local runeGlow = makePart("RuneGlow", Vector3.new(1.3, 1.1, 2.3), body.CFrame, gold, Enum.Material.Neon, model)
	runeGlow.Transparency = 0.85

	local hrp = makeHRP(loc * CFrame.new(0, 1.5, 0), Vector3.new(1.5, 2, 2.5), model)
	addBillboardName(hrp, "Ozymandias", "The Sage", gold)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 11 ZAFIR — Djinn (The Magician)
-- Floating, tornado lower body, no legs.
-- ═══════════════════════════════════════════════════════════════
local function buildZafir(loc: CFrame, model: Model, data: any): Part
	local purple = Color3.fromRGB(100, 40, 180)
	local gold = Color3.fromRGB(255, 200, 50)
	local emerald = Color3.fromRGB(0, 180, 80)

	-- Upper body (humanoid torso + arms)
	local torso = makePart("Torso", Vector3.new(2.2, 2.2, 1.2), loc * CFrame.new(0, 4, 0), purple, Enum.Material.Fabric, model)
	local head = makePart("Head", Vector3.new(1.3, 1.3, 1.3), loc * CFrame.new(0, 5.8, 0), Color3.fromRGB(160, 120, 80), Enum.Material.SmoothPlastic, model)
	makePart("LeftArm", Vector3.new(1, 2, 1), loc * CFrame.new(-1.6, 4, 0), purple, Enum.Material.Fabric, model)
	makePart("RightArm", Vector3.new(1, 2, 1), loc * CFrame.new(1.6, 4, 0), purple, Enum.Material.Fabric, model)

	-- Tornado / smoke cone lower body (tapers down)
	local tornadoColor = Color3.fromRGB(140, 80, 220)
	makePart("Tornado1", Vector3.new(2, 1, 2), loc * CFrame.new(0, 2.8, 0), tornadoColor, Enum.Material.Neon, model, Enum.PartType.Cylinder)
	makePart("Tornado2", Vector3.new(1.5, 1, 1.5), loc * CFrame.new(0, 1.8, 0), tornadoColor:Lerp(Color3.new(1,1,1), 0.2), Enum.Material.Neon, model, Enum.PartType.Cylinder)
	makePart("Tornado3", Vector3.new(1, 1, 1), loc * CFrame.new(0, 0.8, 0), tornadoColor:Lerp(Color3.new(1,1,1), 0.4), Enum.Material.Neon, model, Enum.PartType.Cylinder)
	local tip = makePart("TornadoTip", Vector3.new(0.5, 0.8, 0.5), loc * CFrame.new(0, 0.2, 0), tornadoColor:Lerp(Color3.new(1,1,1), 0.6), Enum.Material.Neon, model, Enum.PartType.Cylinder)
	tip.Transparency = 0.3

	-- Turban / headpiece
	makePart("Turban", Vector3.new(1.5, 0.8, 1.5), head.CFrame * CFrame.new(0, 0.7, 0), gold, Enum.Material.Fabric, model, Enum.PartType.Ball)
	-- Jewel on turban
	local jewel = makePart("TurbanJewel", Vector3.new(0.3, 0.3, 0.3), head.CFrame * CFrame.new(0, 1.1, -0.4), emerald, Enum.Material.Neon, model, Enum.PartType.Ball)
	addGlow(jewel, emerald, 8)

	-- Mischievous grin
	makePart("Grin", Vector3.new(0.6, 0.1, 0.1), head.CFrame * CFrame.new(0, -0.3, -0.65), Color3.new(1,1,1), Enum.Material.Neon, model)

	-- Juggling elemental orbs
	local orbColors = {Color3.fromRGB(255, 90, 30), Color3.fromRGB(40, 140, 255), Color3.fromRGB(80, 200, 80)}
	for i, c in ipairs(orbColors) do
		local angle = math.rad((i / 3) * 360)
		local orb = makePart("Orb" .. i, Vector3.new(0.6, 0.6, 0.6),
			loc * CFrame.new(math.cos(angle) * 1.8, 5.5 + math.sin(angle * 2) * 0.5, math.sin(angle) * 1.8),
			c, Enum.Material.Neon, model, Enum.PartType.Ball)
		addGlow(orb, c, 8)
	end

	-- Sparkle trail particle
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Color = ColorSequence.new(purple, gold)
	sparkle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0)})
	sparkle.Lifetime = NumberRange.new(0.5, 1.5)
	sparkle.Rate = 15
	sparkle.Speed = NumberRange.new(1, 3)
	sparkle.Parent = torso

	local hrp = makeHRP(loc * CFrame.new(0, 3, 0), Vector3.new(2.5, 6, 1.5), model)
	addBillboardName(hrp, "Zafir", "The Magician", purple)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- 12 IGNIS — Red Dragon (The Ruler)
-- ═══════════════════════════════════════════════════════════════
local function buildIgnis(loc: CFrame, model: Model, data: any): Part
	local s = 1.4
	local red = Color3.fromRGB(180, 30, 20)
	local gold = Color3.fromRGB(255, 200, 50)
	local hrp, head, torso = makeBiped(loc, model, s, red, red, Color3.fromRGB(140, 25, 15))
	torso.Material = Enum.Material.SmoothPlastic

	-- Dragon snout (wedge)
	local snout = Instance.new("WedgePart")
	snout.Name = "Snout"
	snout.Size = Vector3.new(0.8*s, 0.5*s, 0.8*s)
	snout.CFrame = head.CFrame * CFrame.new(0, -0.2*s, -0.8*s) * CFrame.Angles(math.rad(180), 0, 0)
	snout.Color = red
	snout.Material = Enum.Material.SmoothPlastic
	snout.Anchored = true
	snout.CanCollide = false
	snout.Parent = model

	-- Small horns
	makePart("HornL", Vector3.new(0.2*s, 0.6*s, 0.2*s), head.CFrame * CFrame.new(-0.35*s, 0.6*s, 0.1*s) * CFrame.Angles(math.rad(-20), 0, math.rad(-15)), Color3.fromRGB(200, 180, 100), Enum.Material.SmoothPlastic, model)
	makePart("HornR", Vector3.new(0.2*s, 0.6*s, 0.2*s), head.CFrame * CFrame.new(0.35*s, 0.6*s, 0.1*s) * CFrame.Angles(math.rad(-20), 0, math.rad(15)), Color3.fromRGB(200, 180, 100), Enum.Material.SmoothPlastic, model)

	-- Tiny reading glasses
	makePart("GlassL", Vector3.new(0.3, 0.25, 0.04), head.CFrame * CFrame.new(-0.2*s, 0, -0.65*s), Color3.fromRGB(200, 200, 210), Enum.Material.Glass, model, Enum.PartType.Cylinder)
	makePart("GlassR", Vector3.new(0.3, 0.25, 0.04), head.CFrame * CFrame.new(0.2*s, 0, -0.65*s), Color3.fromRGB(200, 200, 210), Enum.Material.Glass, model, Enum.PartType.Cylinder)

	-- MAYOR sash
	makePart("Sash", Vector3.new(0.4, 2.5*s, 0.15), torso.CFrame * CFrame.new(0, 0, -0.55*s) * CFrame.Angles(0, 0, math.rad(25)), gold, Enum.Material.Fabric, model)
	-- Sash text billboard
	local sashPart = makePart("SashLabel", Vector3.new(1, 0.5, 0.01), torso.CFrame * CFrame.new(0, 0.3*s, -0.6*s), gold, Enum.Material.Neon, model)
	sashPart.Transparency = 1
	local sGui = Instance.new("SurfaceGui")
	sGui.Face = Enum.NormalId.Front
	sGui.Parent = sashPart
	local sLabel = Instance.new("TextLabel")
	sLabel.Size = UDim2.fromScale(1, 1)
	sLabel.BackgroundTransparency = 1
	sLabel.Text = "MAYOR"
	sLabel.TextColor3 = gold
	sLabel.TextStrokeTransparency = 0
	sLabel.Font = Enum.Font.GothamBold
	sLabel.TextScaled = true
	sLabel.Parent = sGui

	-- Tiny necktie
	makePart("Tie", Vector3.new(0.25, 0.8*s, 0.1), torso.CFrame * CFrame.new(0, 0.6*s, -0.55*s), Color3.fromRGB(30, 30, 80), Enum.Material.Fabric, model)

	-- Clipboard in claw
	makePart("Clipboard", Vector3.new(0.8, 1.2, 0.1), loc * CFrame.new(-1.8*s, 3*s, -0.5), Color3.fromRGB(180, 150, 80), Enum.Material.Wood, model)
	makePart("ClipboardPaper", Vector3.new(0.7, 1, 0.05), loc * CFrame.new(-1.8*s, 3*s, -0.55), Color3.new(1,1,1), Enum.Material.SmoothPlastic, model)

	-- Small smoke puff from nostrils (particle)
	local smoke = Instance.new("ParticleEmitter")
	smoke.Color = ColorSequence.new(Color3.fromRGB(100, 100, 100))
	smoke.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1)})
	smoke.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 1)})
	smoke.Lifetime = NumberRange.new(0.5, 1)
	smoke.Rate = 3
	smoke.Speed = NumberRange.new(1, 2)
	smoke.Parent = snout

	addBillboardName(hrp, "Ignis", "The Ruler", gold)
	return hrp
end

-- ═══════════════════════════════════════════════════════════════
-- DISPATCH
-- ═══════════════════════════════════════════════════════════════
local Builders = {
	Barnaby    = buildBarnaby,
	Yorick     = buildYorick,
	Kael       = buildKael,
	Martha     = buildMartha,
	Gribble    = buildGribble,
	Nyx        = buildNyx,
	Vlad       = buildVlad,
	Pygmalion  = buildPygmalion,
	Chesty     = buildChesty,
	Ozymandias = buildOzymandias,
	Zafir      = buildZafir,
	Ignis      = buildIgnis,
}

function NPCVisualBuilders.Build(npcId: string, location: CFrame, model: Model, data: any): Part
	print("[NPCVisualBuilders] Building NPC: " .. npcId)
	local builder = Builders[npcId]
	if builder then
		return builder(location, model, data)
	end
	-- Fallback: generic colored biped
	print("[NPCVisualBuilders] Using fallback for: " .. npcId)
	local hrp, _, _ = makeBiped(location, model, 1, data.Color or Color3.new(0.5,0.5,0.5), Color3.new(1, 0.8, 0.6), Color3.new(0.2, 0.2, 0.2))
	addBillboardName(hrp, data.Name or npcId, data.Archetype or "Unknown", data.Color or Color3.new(1,1,1))
	return hrp
end

return NPCVisualBuilders
