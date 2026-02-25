# 🖥️ Zed IDE + Cline Workflow Guide
## Maximizing Productivity for Roblox Development

---

## 🚀 Quick Start

### What is Cline?
Cline is an AI-powered coding assistant that works directly in your IDE. It can:
- Read and write files in your codebase
- Execute terminal commands
- Search and analyze code
- Create and modify entire features

### Starting a Session
1. Open Zed IDE in your project folder
2. Open the Cline panel (usually `Cmd+I` or `Ctrl+I`)
3. Describe what you want to accomplish

---

## 💡 Effective Prompting

### ❌ Bad Prompts
```
"Fix the code"
"Add a feature"
"Make it better"
```

### ✅ Good Prompts
```
"Read docs/session_turnover.md and implement Priority 2: Quest Tracker UI"
"The LureUI timer isn't working. Search for the timer logic and fix it"
"Create a new SynonymDatabase entry for 'benevolent' with synonyms, antonyms, and element mapping"
```

### 🎯 Best Prompts (Context-Rich)
```
"I'm building Semantic Slime, an educational Roblox game. 
Read docs/context.md for background.

Current task: Create QuestTrackerUI.lua in src/client/UI/
Requirements:
- Show active quest name and description
- Display step progress (e.g., '1/3 words captured')
- Use GameConfig.Colors for theming
- Animate when quest updates

Reference LureUI.lua for UI patterns we use."
```

---

## 🔄 Recommended Workflow

### Session Start (5 minutes)
```
1. "Read docs/session_turnover.md and summarize current state"
2. "What are the priorities for this session?"
3. "Read the files I'll need to work on [feature]"
```

### During Development
```
1. Start with Plan Mode - discuss approach
2. Switch to Act Mode - implement
3. Test in Roblox Studio
4. Return to fix issues
```

### Session End (5 minutes)
```
1. "Update docs/session_turnover.md with what we accomplished"
2. "Document any new bugs or issues found"
3. "List priorities for next session"
```

---

## 🛠️ MCP Tools & Integrations

### Available Tools in Cline

| Tool | Use Case | Example |
|------|----------|---------|
| `read_file` | Understand existing code | "Read the LogosService and explain how evolution works" |
| `write_to_file` | Create new files | "Create a new UI component for the shop" |
| `replace_in_file` | Edit existing files | "Add a new method to SpawnerService" |
| `search_files` | Find patterns | "Find all uses of 'Element' in the codebase" |
| `list_files` | Explore structure | "List all files in src/client/Controllers" |
| `execute_command` | Run terminal commands | "Run rojo build to test the game" |

### MCP Server Integrations

If you have MCP servers configured, you can:

```
# With a browser MCP
"Search the web for Roblox Luau best practices"

# With a database MCP
"Query the player data for testing"

# With a git MCP
"Show me the diff of my last commit"
```

---

## 📁 Project Structure Tips

### Keep Cline Oriented
When starting a session, establish context:

```
"Here's my project structure:
- src/server/Services - Backend logic (Knit services)
- src/client/Controllers - Frontend logic (Knit controllers)  
- src/client/UI - UI components
- src/shared - Shared data and config

Read docs/session_turnover.md for current state."
```

### Use Documentation Files
Cline reads documentation well. Maintain these:

```
docs/
├── session_turnover.md    # Current state, priorities
├── worldbuilding_workflow.md  # Content creation process
├── context.md             # Game design overview
├── game_mechanics.md      # Technical details
└── specs/                 # Feature specifications
```

---

## 🎮 Roblox + Rojo Workflow

### The Development Loop

```
┌─────────────────────────────────────────────────────────┐
│  1. CODE (Zed + Cline)                                  │
│     - Write/edit Luau files                             │
│     - Cline helps with implementation                   │
│     - Save files                                        │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  2. SYNC (Rojo)                                         │
│     - rojo serve (running in terminal)                  │
│     - Files auto-sync to Studio                         │
│     - Or: rojo build -o test.rbxl                       │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  3. TEST (Roblox Studio)                                │
│     - Play test the game                                │
│     - Check Output for errors                           │
│     - Test gameplay features                            │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│  4. FIX (Zed + Cline)                                   │
│     - Report errors to Cline                            │
│     - "Fix this error: [paste error message]"           │
│     - Iterate                                           │
└─────────────────────┬───────────────────────────────────┘
                      │
                      └──────────► Back to Step 1
```

### Terminal Commands to Keep Running

```bash
# Terminal 1: Rojo sync (keep running)
rojo serve

# Terminal 2: Build for testing
rojo build -o test.rbxl

# Terminal 3: Git operations
git status
git add .
git commit -m "feat: add quest tracker UI"
```

### Testing Commands for Cline

Ask Cline to run these:
```
"Run rojo build and tell me if there are any errors"
"Check if all services are properly required in Boot.server.luau"
"Search for any TODO comments in the codebase"
```

---

## 🐛 Debugging with Cline

### When You Find a Bug

```
"I found a bug. When I click a slime, the LureUI doesn't open.

Error message: [paste from Studio Output]

Relevant files:
- src/client/Controllers/SlimeController.lua
- src/client/UI/LureUI.lua

Please investigate and fix."
```

### Proactive Debugging

```
"Search the codebase for potential issues:
1. Undefined variables
2. Missing requires
3. Incorrect service references
4. Type mismatches"
```

---

## 📊 Code Review with Cline

### Pre-Commit Review
```
"Review the changes I've made this session:
1. Check for code quality issues
2. Verify error handling
3. Ensure consistency with existing patterns
4. Suggest improvements"
```

### Architecture Review
```
"Analyze the architecture of my Knit services:
1. Are there circular dependencies?
2. Is error handling consistent?
3. Are client-server boundaries correct?
4. What would you improve?"
```

---

## 🎯 Session Templates

### Feature Implementation
```
SESSION GOAL: Implement [FEATURE NAME]

1. Read docs/session_turnover.md for context
2. Read [relevant existing files]
3. Plan the implementation approach
4. Create/modify necessary files
5. Test in Studio
6. Update documentation
```

### Bug Fix Session
```
SESSION GOAL: Fix [BUG DESCRIPTION]

1. Reproduce the bug in Studio
2. Identify the problematic code
3. Implement fix
4. Test thoroughly
5. Document the fix
```

### Content Creation Session
```
SESSION GOAL: Add [NUMBER] new words

1. Read docs/worldbuilding_workflow.md
2. Use the Word Entry Template
3. Add entries to SynonymDatabase.lua
4. Create associated quests
5. Test captures in Studio
```

---

## ⚡ Pro Tips

### 1. Use Plan Mode for Complex Features
Before implementing, discuss the approach:
```
"I want to add a Synthesis System where players combine 
Root + Suffix to create new words. Let's plan this out."
```

### 2. Provide Error Messages
Always paste Studio output errors:
```
"Error: ServerScriptService.Server.Services.QuestService:45: 
attempt to index nil with 'QuestDefinitions'

Fix this error."
```

### 3. Reference Existing Patterns
```
"Create a new service called AchievementService
following the same pattern as QuestService"
```

### 4. Batch Related Changes
```
"Update all UI files to use GameConfig.Colors
instead of hardcoded colors"
```

### 5. Keep Documentation Updated
```
"We just finished the QuestTrackerUI.
Update session_turnover.md with this accomplishment."
```

---

## 🔧 Troubleshooting

### Cline Seems Lost
```
"Let me reorient you. Read these files:
1. docs/session_turnover.md
2. docs/context.md
3. src/shared/GameConfig.lua

Then summarize what you understand about the project."
```

### Code Doesn't Match Studio
```
"The code in Zed doesn't match what I see in Studio.
Help me verify rojo serve is working correctly."
```

### Can't Find a File
```
"Search for files containing [keyword]
and list their paths"
```

---

*This workflow maximizes the synergy between Zed IDE, Cline AI, and Roblox Studio.*