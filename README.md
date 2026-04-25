# Ripple Repair

A Godot 4 2D game for the jam theme **Unintended Consequences**.

You are a station tech trying to repair broken systems across three rooms. Every successful fix creates a new side effect: vents, shorts, collapsing tiles, confused maintenance drones, locked doors, and spreading coolant. The goal is to survive the ripple effects of your own solutions.

Each broken system tells you what kind of consequence it will create before you repair it. That preview is intentional: the game is about choosing the repair order that creates the least disastrous chain, not guessing hidden punishments.

The game is set in a damaged space-station control room with broken monitors, loose wires, floating trash bags, food packs, drifting space junk, small ship silhouettes, and a cracked observation window sealed by a flickering emergency field.

## Play

Open this folder in Godot 4 and run the project.

- The first screen has Play, Scoreboard, Instructions, and Achievements.
- Move with WASD or arrow keys.
- Stand on a glowing system to preview its side effect.
- Repair by pressing Space or Enter.
- Restart with R.

Goal: repair every glowing system in the room, then continue to the next room.

Watch the consequence chain at the bottom. Fallout is the station danger meter: repairs and hazards raise it. If Fallout reaches 100%, the room becomes impossible to stabilize.

The first room includes tutorial popups. Press Space or Enter to dismiss each hint.

The HUD includes Fallout/progress meters, a current objective, an arrow to the next repair target, a hazard legend, dynamic danger states, a repair card with consequence preview plus risk grade, and a red emergency alert banner when a repair backfires.

After clearing a room, the game shows a dedicated next-level screen. Use the button to continue to the next room instead of restarting.
