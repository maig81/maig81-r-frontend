# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Issue Tracking

TODOs live as **GitHub Issues** in `maig81/fortification-project` (see the root `../CLAUDE.md` for full details). Current focus is the **v0.1** milestone; roadmap: [`../docs/MVP_v0.1.md`](../docs/MVP_v0.1.md).

- Frontend tasks: `gh issue list -R maig81/fortification-project --label frontend`
- All v0.1 issues: `gh issue list -R maig81/fortification-project --milestone v0.1`
- Frontend-heavy work starts at parent **#14** (score HUD, result screen, return-to-lobby) and **#24** (Game feel/control: camera-follow, placement feedback, phase timer).
- Check the relevant issue before starting; update/close it when done (confirm with the user before closing).

## Project

**Godot 4.6** / **GDScript** frontend for an online multiplayer remake of Rampart. No traditional build system — the Godot Editor manages compilation, asset importing, and exports. Backend runs at `localhost:8080`.

## Running the Project

Open in Godot 4.6 Editor and press F5, or from the command line:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/markomarjanovic/r/r_frontend
```

Main scene on launch: `login/login.tscn`.

## Architecture

### Autoload Singleton

**`network.gd`** (registered as `Network`) — owns all networking state and persists across scene changes.

- `Network.login(email, password)` — `POST /api/v1/login`, stores token, then opens WebSocket
- `Network.send_message(type, payload)` — sends `{ "type": "...", "payload": ... }` over WebSocket
- `Network.token` — session token after login
- WebSocket is polled every frame in `_process()`; state transitions emit signals

Signals: `login_success`, `login_failed(error)`, `ws_connected`, `ws_disconnected`, `message_received(type, payload)`

### Scenes

| Scene | Script | Purpose |
|---|---|---|
| `login/login.tscn` | `login/login.gd` | Entry point: username/password form → calls `Network.login()`, transitions to hub on WS connect |
| `hub/hub.tscn` | `hub/hub.gd` | Lobby: `ItemList` showing available rooms; sends `list_rooms` to backend on ready |
| `game/game.tscn` | `game/game.gd` | Main gameplay scene: fetches terrain, handles all in-game WS messages, emits signals to sub-nodes |

### Backend Protocol

- HTTP: `POST http://localhost:8080/api/v1/login` → `{ "token": "..." }`
- WebSocket: `ws://localhost:8080/api/v1/ws?token=<token>`
- All WS messages: `{ "type": "...", "payload": {...} }`

### Engine Configuration (`project.godot`)

- Rendering: Forward Plus, Direct3D 12 (Windows)
- Physics: Jolt 3D
- Autoload: `Network = *res://network.gd`

## Lifecycle rules

- Every scene that connects to `Network` signals in `_ready()` **must** disconnect them in `_exit_tree()` — e.g. `Network.message_received.disconnect(_on_message_received)`. Failing to do so leaves stale connections on the `Network` autoload, causing duplicate message handling in subsequent scenes.
- Call `GameSession.reset()` when returning to the login scene so stale room/player state doesn't bleed into the next session.

## File Conventions

- All text files use **LF line endings** (enforced via `.gitattributes`)
- Charset: **UTF-8** (`.editorconfig`)
- Scenes and their scripts live in a shared subdirectory (e.g. `login/login.tscn` + `login/login.gd`)
- The `.godot/` directory is editor cache — do not commit it
