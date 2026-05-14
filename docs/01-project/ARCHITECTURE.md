# Architecture Overview

## System Diagram

```mermaid
graph TD
    subgraph "Server (ServerScriptService)"
        Boot["Boot.server.luau"]
        Boot --> Remotes["Remotes.luau (creates RemoteEvents)"]
        Boot --> Services["47 Knit Services"]
        Boot --> Knit["Knit.Start()"]
        Knit --> TG["TownGenerator.SpawnWorld()"]
        
        Services --> GLS["GameLoopService"]
        Services --> CS["CrystalService"]
        Services --> SF["SlimeFactory"]
        Services --> BS["LetterNuisanceService"]
        Services --> DS["DataService"]
        Services --> MLS["MadLibService"]
        Services --> NS["NPCService"]
        Services --> TS["TerrainService"]
    end
    
    subgraph "Client (StarterPlayerScripts)"
        CBoot["Boot.client.luau"]
        CBoot --> Controllers["28 Knit Controllers"]
        
        Controllers --> HUD["HUDController"]
        Controllers --> WCC["WordConstructorController"]
        Controllers --> BUI["WordConstructorController"]
        Controllers --> SC["SlimeController"]
        Controllers --> QC["QuestUIController"]
    end
    
    subgraph "Shared (ReplicatedStorage)"
        GameConfig
        SynonymDB["SynonymDatabase (67K lines)"]
        WordDB["WordDatabase (956KB)"]
        EtyDB["EtymologyDB"]
        QuestData
        NPCData
        TownBlueprint
    end
    
    Services -.->|require| Shared
    Controllers -.->|require| Shared
    Services <-->|Knit Signals| Controllers
```

## Boot Sequence

```
1. Boot.server.luau runs
2. Creates emergency floor + trees
3. Waits for Packages/Knit (5s timeout)
4. ⚡ require(Remotes.luau) — creates all RemoteEvents
5. Loops through Services folder → require() each
6. Knit.Start()
7. After 3s delay → TownGenerator.SpawnWorld()
```

## Key Service Dependencies

| Service | Depends On (require) | Depends On (runtime) |
|---------|---------------------|---------------------|
| GameLoopService | Knit | CrystalService, SlimeFactory, MadLibService, LetterNuisanceService, DataService |
| CrystalService | Knit, Remotes | GameLoopService |
| LetterNuisanceService | Knit | CrystalService, GameLoopService |
| SlimeFactory | Knit, EtymologyDB, WordDatabase | DataService |
| TownGenerator | Knit, NPCData, TownBlueprint, BuildingStyles, BuildingInterior | NPCService, TerrainService |
| DataService | Knit | LogosService, SlimeFactory, CrystalService |

## File Counts

| Section | Files | Notes |
|---------|-------|-------|
| Server Services | 47 `.lua` | All use `Knit.CreateService` |
| Client Controllers | 28 `.lua` | All use `Knit.CreateController` |
| Client UI | 14 `.lua` | Plain modules, initialized by HUDController |
| Shared Modules | 22 `.lua` | Data, config, types, visual builders |
| Shared Data | 36 files | Lore, templates |
