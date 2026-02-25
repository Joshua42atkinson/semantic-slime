# Spec-Driven Development (SDD)

**"Code is a liability. Specifications are an asset."**

SDD is the workflow of defining *behavior* before writing *implementation*. It allows the AI (Antigravity) to act as a **Code Generator** rather than a **Code Guesser**.

## The Workflow

1.  **Draft (User)**: Create a file in `specs/` (e.g., `002_combat_system.md`).
2.  **Define (User)**: Describe describing State, API, and Network interactions.
3.  **Generate (Agent)**: "Implement `specs/002_combat_system.md` in `src/server/Services/CombatService.luau`."
4.  **Verify**: Playtest against the spec's "Acceptance Criteria".

## Anatomy of a Perfect Spec

Copy this template for every new feature.

```markdown
# [Feature Name] Spec

## 1. Overview
**Goal:** [One sentence summary]
**User Story:** As a [Role], I want [Feature] so that [Benefit].

## 2. Architecture

### State (Server)
What data does this service own?
- `_activeBattles: { [Player]: BattleSession }`
- `_cooldowns: { [Player]: number }`

### Public API (Methods)
How do other scripts talk to this?
- `CombatService:InitiateBattle(player, target)`
- `CombatService:DealDamage(attacker, defender, amount)`
- `CombatService:IsInCombat(player) -> boolean`

### Network (Client <-> Server)
- **RemoteEvents**:
  - `CombatStarted(targetId)` (Server -> Client)
  - `DamageTaken(amount, source)` (Server -> Client)
- **RemoteFunctions**:
  - `RequestAttack(targetId)` (Client -> Server) -> bool

## 3. Implementation Details

### Validation Rules
- Player cannot attack if `IsDead`.
- Cooldown must be checked on Server (never trust client).
- Range check: Max 10 studs.

### Edge Cases
- What if target disconnects mid-battle? (Handle `PlayerRemoving`)
- What if damage is negative? (Clamp to 0)

## 4. Acceptance Criteria (Testing)
- [ ] Two players can damage each other.
- [ ] HP updates on both screens.
- [ ] Cannot attack during cooldown.
```

## Why This Works
- **Context**: The AI reads the spec and knows *exactly* what to write.
- **Documentation**: Your `specs/` folder becomes the manual for your game.
- **Scalability**: You can hand a spec to a human or an AI, and the result will be consistent.
