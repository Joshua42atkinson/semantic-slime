# Game Manager Service Spec

**Created:** 2026-02-18
**Status:** DRAFT

## 1. Overview
**Goal:** Manage the central game loop (Lobby -> Round -> Rewards -> Lobby).
**User Story:** As a player, I want the game to cycle through rounds automatically so I can play continuously.

## 2. Architecture

### State (Server)
- `_state: "Lobby" | "Round" | "Intermission"`
- `_timer: number` (Time remaining in current state)
- `_playersInRound: { Player }`

### Public API
- `GameManager:SetState(newState)`
- `GameManager:GetState() -> string`
- `GameManager:GetTimeRemaining() -> number`
- `GameManager:ForceStartRound()` (Admin only)

### Network
- **RemoteEvents**:
  - `GameStateChanged(newState, duration)` (Broadcase to all clients)
  - `TimerTick(timeLeft)` (Optional: sync every 5s instead of every tick)

## 3. Implementation Details

### State Transitions
1.  **Lobby**: Wait for min players (2). Timer = Infinity.
2.  **Intermission**: Countdown (10s) before start.
3.  **Round**: The game. Timer = 300s. Ends if timer -> 0 OR only 1 survivor.
4.  **Rewards**: Show winners. Timer = 10s. -> Go to Lobby.

### Validation
- Only Server can change state.
- `ForceStart` requires `player.UserId` to be in Admin list.

## 4. Acceptance Criteria
- [ ] Game waits in Lobby until 2 players join.
- [ ] Intermission counts down correctly.
- [ ] Round starts and teleports players to map.
- [ ] UI shows correct State and Timer on Client.
