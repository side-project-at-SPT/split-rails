# Models and Relationships

This diagram illustrates the data models in the Split game application and their relationships. The application follows a standard Rails ActiveRecord pattern with models representing game entities.

```mermaid
classDiagram
    class Visitor {
        +name: string
        +password_digest: string
        +preferences: jsonb
        +role: enum [admin, user, guest, ai]
        +encode_jwt()
        +read_preferences()
        +nickname()
        +ready?()
        +ready!()
        +unready!()
        +character()
        +owner_of?(room)
        +knock_knock(room)
    }

    class Room {
        +name: string
        +owner_id: integer
        +closed_at: datetime
        +generate_players(seed)
        +start_new_game(seed)
        +closed?()
        +close()
        +ready_to_start?()
        +start_in_seconds()
        +countdown_game_start(seconds)
        +countdown()
        +status()
        +full?()
    }

    class VisitorsRoom {
        +ready: boolean
        +character: string
        +ready!()
        +unready!()
    }

    class Game {
        +room_id: integer
        +is_finished: boolean
        +players: jsonb
        +current_player_index: integer
        +current_player()
        +close()
        +on_going?()
        +finished?()
        +game_phase()
        +valid_position?(params)
        +pastures()
        +place_stack(target_x, target_y)
        +split_stack(origin_x, origin_y, target_x, target_y, target_amount)
        +game_config()
        +game_data(step)
    }

    class GameStep {
        +game_id: integer
        +step_number: integer
        +step_type: enum [initialize_map_by_system, place_pasture, place_stack, split_stack, game_over]
        +game_phase: enum [build_map, place_stack, split_stack, game_over, game_interrupted]
        +pastures: jsonb
        +action: jsonb
        +author()
        +action_name()
        +to_grid()
        +from_grid()
    }

    class Bot {
        +name: string
        +visitor_id: integer
        +generate_player()
        +join_room(room)
    }

    class AiPlayer {
        +bot_id: integer
        +player_id: integer
        +nickname()
    }

    Visitor "1" -- "1" VisitorsRoom : has_one
    Room "1" -- "*" VisitorsRoom : has_many
    VisitorsRoom "1" -- "1" Visitor : belongs_to
    VisitorsRoom "1" -- "1" Room : belongs_to
    Visitor "1" -- "1" Room : through VisitorsRoom
    Room "1" -- "*" Game : has_many
    Game "1" -- "*" GameStep : has_many
    Bot "1" -- "*" AiPlayer : has_many
    Visitor "1" -- "*" Bot : has_many as owner
    AiPlayer "1" -- "1" Visitor : belongs_to as player
    AiPlayer "1" -- "1" Bot : belongs_to
```

## Key Model Relationships

- **Visitor**: Represents users in the system with different roles (admin, user, guest, ai)
- **Room**: A virtual room where players gather to play games
- **VisitorsRoom**: Join table connecting visitors to rooms with additional attributes like ready status
- **Game**: Represents a game session with its state and players
- **GameStep**: Records each step/move in a game with detailed information
- **Bot**: Represents an AI bot that can play the game
- **AiPlayer**: Join table connecting bots to visitor records that represent AI players

The diagram shows how these models are interconnected, forming the foundation of the Split game application's data structure.
