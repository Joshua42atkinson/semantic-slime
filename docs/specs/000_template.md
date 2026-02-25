# Spec Title

**Created:** YYYY-MM-DD
**Status:** DRAFT | APPROVED | IMPLEMENTED

## Goal
Brief content describing what this feature does.

## User Story
"As a [player/teacher], I want to [action] so that [benefit]."

## Technical Specification

### State
What data is stored?
- `Inventory: { [ItemId]: Count }`

### API (Services/Controllers)
What functions are exposed?
- `Service:AddItem(player, item)`

### Network (Remotes)
What data crosses the client/server boundary?
- `RemoteEvent: InventoryChanged(newItem)`

### Validation / Edges
- What happens if inventory is full?
- Security checks?
