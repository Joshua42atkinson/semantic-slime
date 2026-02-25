--!strict
-- QuestData.lua
-- All level definitions, Pete's dialogue, and completion conditions
-- for "The Local AI Architect" — teaching the Antigravity + Rojo workflow

local QuestData = {}

QuestData.Levels = {

	-- ══════════════════════════════════════════════════════════════════
	-- LEVEL 1: The Connection Room
	-- Real-world skill: Install Rojo, connect Studio, start rojo serve
	-- ══════════════════════════════════════════════════════════════════
	[1] = {
		id        = 1,
		title     = "The Connection Room",
		badge     = "Rojo Conductor",
		objective = "Connect the three cables to link your editor to the game world.",

		npcDialogue = {
			"Hey, welcome! I'm Pete. I keep this whole network running. 🚂",
			"Right now, your code editor and your game world can't talk to each other.",
			"We need to connect them. Think of it like plugging in a cable.",
			"In the real world, you'd run one command: 'rojo serve'.",
			"Here, connect the three cables on the panel — and we'll be live.",
		},

		mechanic  = "wire",
		wireCount = 3,
		wireLabels = {
			"Install Rojo",
			"Run: rojo serve",
			"Connect Studio",
		},

		-- After wires: Teaching Toast (no lock UI)
		vaamSocket = {
			correctWord     = "Sync",
			correctFeedback = "✅ Connected! This is called 'Sync' — code and game are now linked.",
		},

		idleHint = "Connect the cables in order from top to bottom.",
	},

	-- ══════════════════════════════════════════════════════════════════
	-- LEVEL 2: The Forge Room
	-- Real-world skill: Lesson Plan → Full Game Generation
	-- ══════════════════════════════════════════════════════════════════
	[2] = {
		id        = 2,
		title     = "The Forge Room",
		badge     = "Agentic Builder",
		objective = "Input a Lesson Plan into the Forge Terminal. Watch Antigravity generate the entire game structure.",

		npcDialogue = {
			"Great — we're connected! Now let's see what this rig can do. 🔧",
			"See that massive Forge? That's Antigravity.",
			"You don't need to build piece by piece. You just feed it a Lesson Plan.",
			"'Teach the Water Cycle using a platformer mechanic.' That's all it needs.",
			"Input a plan into the terminal and watch it generate the entire game.",
		},

		mechanic   = "forge",
		
		-- Shown in the Forge Terminal
		promptPlaceholder = "e.g. Create a game about The Solar System where players must orbit planets to learn gravity...",
		promptHint        = "Describe the lesson you want to teach and the game mechanic to use.",
		minPromptLength   = 20,

		-- Simulated "Build Log" returned by the Forge
		forgeLog = {
			"1. Analyzing Lesson Plan... [OK]",
			"2. Generating Map Geometry... [OK]",
			"3. Scripting Mechanics... [OK]",
			"4. Placing NPCs... [OK]",
			"✅  GAME GENERATION COMPLETE. Ready for playtest.",
		},

		idleHint = "Click the Forge terminal and type a lesson plan. Watch the game build itself.",
	},

	-- ══════════════════════════════════════════════════════════════════
	-- LEVEL 3: The Playtest Chamber
	-- Real-world skill: Playtest, observe, describe improvements
	-- ══════════════════════════════════════════════════════════════════
	[3] = {
		id        = 3,
		title     = "The Playtest Chamber",
		badge     = "Experience Architect",
		objective = "Fix the glitches in the generated level, then write a feedback note to iterate.",

		npcDialogue = {
			"It's done. But AI isn't perfect. It makes mistakes — just like students do. 🎮",
			"You need to verify the build. Look for glitches (floating buildings, missing textures).",
			"Fix them with your Debug Tool (Press E).",
			"Then open your Architect's Log (Press G) and write one improvement note.",
			"That note goes back to the Forge, and the cycle continues.",
		},

		mechanic        = "playtest",
		minPromptLength = 20,

		-- Shown inside the Architect's Log (prompt box)
		promptPlaceholder = "e.g. The gravity is too strong — make the jump height higher...",
		promptHint        = "One clear observation. What would make this better for a student?",

		-- Shown after a valid note is submitted
		successFeedback = {
			"Your note is logged. 📋",
			"In the real workflow, you'd paste that into Antigravity and it would update the game instantly.",
			"That's the loop: Plan → Generate → Playtest → Iterate.",
			"You are now ready to build. 🏆",
		},

		idleHint = "Fix the glitches, then press [G] to open your Architect's Log.",
	},
}

-- Shown after all 3 levels complete
QuestData.CompletionMessage = {
	"🎉 You've completed The Local AI Architect! 🎉",
	"",
	"You now know the workflow:",
	"  ✅  Connect Rojo to sync code instantly",
	"  ✅  Generate entire games from a single Lesson Plan",
	"  ✅  Iterate based on playtesting feedback",
	"",
	"The tools are ready. Your students are waiting.",
	"Go build something great. 🚂",
}

return QuestData
