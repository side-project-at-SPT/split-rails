# Split Game Documentation

Welcome to the Split Game documentation. This directory contains comprehensive documentation about the architecture and design of the Split game application.

## Architecture Documentation

For a detailed overview of the system architecture with Mermaid diagrams, see the [Architecture Overview](architecture_overview.md).

The architecture documentation includes:

- [Models and Relationships](models.md)
- [System Architecture](system_architecture.md)
- [Game Flow](game_flow.md)
- [Game States](game_states.md)
- [API Endpoints](api_endpoints.md)
- [Real-time Communication Channels](realtime_channels.md)

## Game Rules

Split (also known as Battle Sheep) is a board game where players compete to control territory on a hexagonal grid.

### Preparation

- Each player starts with 16 sheep.
- Players take turns placing map tiles. (Not supported in Sprint 1)
- Players take turns placing their sheep on empty spaces at the edge of the map.

### How to Play

1. A player selects one of their stacks of sheep that isn't surrounded.
   - A stack must have at least two sheep.
   - A stack is surrounded if all adjacent spaces are occupied by other sheep or the edge of the map.
   - If all of a player's sheep are surrounded, their turn is skipped.
2. The player moves 1 to (N-1) sheep from the stack in any direction until they encounter another sheep or the edge of the map.
   - N is the number of sheep in the stack.
   - The sheep must move at least one space.
3. Play passes to the next player.

### How to Win

- The game ends when no player can move any sheep.
- The player who occupies the most spaces on the map wins.
- If multiple players occupy the same number of spaces, the player with the largest group of sheep wins.
- If the largest groups are also tied, the players share the victory.

## Project Links

- Frontend Repository: https://github.com/side-project-at-SPT/split-front
- API Documentation: https://side-project-at-spt.github.io/split-rails/
- Project Board: https://miro.com/app/board/uXjVK7A5iEI=
