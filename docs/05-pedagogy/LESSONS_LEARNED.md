# Lessons Learned - Semantic Slime

This document captures high-level technical and architectural lessons learned during the development of Semantic Slime, providing guidance for future expansions.

## 1. Knit Framework Communication Nuances

**The Issue**: Throughout the client controllers, signals were being incorrectly bound using the server-side syntax: `Service.Client.SignalName:Connect()`. This led to over 12 broken controllers and a complete failure of the client-side game loop. Similarly, the server tried to use `self.Client.Signal:Fire()` inside local functions where `self` wasn't defined.

**The Lesson**: 
- **Client Side**: When calling `Knit.GetService("MyService")` on the client, Knit automatically unwraps the `.Client` table and gives you direct access to methods/signals. **Never use `.Client` on the client.** Always write `MyService.SignalName:Connect()`.
- **Server Side**: Inside a Knit Service, `self.Client` is only accessible inside member methods (e.g., `function MyService:Method()`). If you are inside a `task.spawn` or `local function`, you must use the explicit service table reference `MyService.Client.SignalName:FireAll()`.

## 2. Lua Scoping & Parse Errors

**The Issue**: The `NPCService` crashed because `startWandering` was defined *below* the function that called it. Since it was declared `local function startWandering`, it was `nil` at the moment it was referenced. The `TownGenerator` also had a severe block-nesting error where a premature `end` left half the script outside the loop scope.

**The Lesson**:
- Lua is strictly single-pass for local variables. Helper functions *must* be defined before they are used, or forward-declared (e.g., `local startWandering; function startWandering() ... end`).
- Large monolithic generator scripts (like TownGenerator) are highly susceptible to "extra end" bugs. Refactoring these tightly-coupled 500+ line blocks into standalone helper modules makes scope tracking significantly easier.

## 3. API Accuracy vs Copilot Assumptions

**The Issue**: `TerrainService` attempted to use `Workspace.Terrain:Raycast()`, and `SoundController` attempted `SoundService:CreateSound()`. Both APIs don't exist.

**The Lesson**:
- AI coding assistants often "hallucinate" plausible-sounding APIs that Roblox doesn't actually support. Always verify core engine interactions against official documentation. (`Workspace:Raycast` exists; `Instance.new("Sound")` is the correct pattern).

## 4. Avoiding Capability Errors

**The Issue**: Earlier in development, scripts attempted to write directly to `Script.Source` at runtime to inject dynamically generated modules. This triggers a `PluginOrOpenCloud` security warning and crashes the thread.

**The Lesson**:
- In Roblox, running games cannot directly edit script source code. All dynamic behavior must be handled via data-driven design (ModuleScripts returning tables, remote events passing JSON, string.format, or loadstring if explicitly enabled on the server, though loadstring is discouraged).
