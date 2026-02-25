---
description: Scaffold a new quest from template
---
// turbo
1. Add the new quest to QuestData.lua
```bash
echo "Quest scaffold: edit src/shared/QuestData.lua to add the new quest entry"
```

2. If the quest needs a new mechanic (not quiz/collect/prompt), create a handler in GameManager.server.luau

3. Rojo will sync automatically — no build step needed
