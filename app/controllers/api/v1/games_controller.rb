module Api
  module V1
    class GamesController < BaseController
      before_action :find_game,
                    only: %i[show destroy play split init_map_automatically reset_game
                             place_stack random_place_stack
                             random_split_stack]
      # show create destroy play split

      # POST /api/v1/rooms/:id/game
      # 開始遊戲
      def create
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?

        user = Visitor.find(@jwt_request['sub'])
        unless room.players.include?(user)
          return render json: { error: 'You are not in this room' },
                        status: :unauthorized
        end

        if room.games.last&.on_going?
          return render json: { error: 'Game is already on going' }, status: :unprocessable_entity
        end

        return render json: { error: 'Not enough players' }, status: :unprocessable_entity if room.players.size < 2

        room.start_new_game

        render json: { game: room.games.last }, status: :created
      end

      # GET /api/v1/games/:id?step=0
      # 查詢目前遊戲狀態
      def show
        @step = params.key?(:step) ? params[:step].to_i : @game.steps.size

        render status: :ok
      end

      # DELETE /api/v1/rooms/:id/game
      # 結束遊戲
      def destroy
        return render json: { error: 'Game is already finished' }, status: :unprocessable_entity if @game.finished?

        @game.close
        render json: { game: @game }, status: :ok
      end

      # POST /api/v1/rooms/:id/game/play-unit
      # 放入棋子
      # params: { x: 0, y: 0 }
      def play
        return render json: { error: 'Game is already finished' }, status: :unprocessable_entity if @game.finished?

        unless @game.current_player['name'] == @user.name
          return render json: { error: 'Not your turn' },
                        status: :unprocessable_entity
        end
        if @game.steps.size >= @game.players.size
          # all players have played their pieces
          return render json: { error: 'All players have played their pieces' }, status: :unprocessable_entity
        end

        unless @game.valid_position?(params)
          return render json: { error: 'Invalid position' },
                        status: :unprocessable_entity
        end

        @game.steps << { x: params[:x], y: params[:y], color: @game.current_player['color'] }
        @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
        @game.save!

        render json: { game: @game }, status: :ok
      end

      # POST /api/v1/rooms/:id/game/split
      # 分配棋子
      # params: { origin_x: 1, origin_y: 1, target_x: 0, target_y: 0, amount: 1 }
      def split
        return render json: { error: 'Game is already finished' }, status: :unprocessable_entity if @game.finished?

        unless @game.current_player['name'] == @user.name
          return render json: { error: 'Not your turn' },
                        status: :unprocessable_entity
        end
        unless @game.valid_position?(params)
          return render json: { error: 'Invalid position' },
                        status: :unprocessable_entity
        end

        return render json: { error: 'Invalid amount' }, status: :unprocessable_entity if params[:amount].to_i < 1

        @game.steps << {
          origin_x: params[:origin_x],
          origin_y: params[:origin_y],
          target_x: params[:target_x],
          target_y: params[:target_y],
          amount: params[:amount],
          color: @game.current_player['color']
        }
        @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
        @game.save!

        render json: { game: @game }, status: :ok
      end

      # POST /api/v1/games/:id/place-stack
      def place_stack
        res = @game.place_stack(target_x: params[:target_x].to_i, target_y: params[:target_y].to_i)

        return render json: { error: res.errors.full_messages }, status: :unprocessable_entity if res.errors.any?

        Domain::GameStackPlacedEvent.new(game_id: @game.id).dispatch
        Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

        render json: { message: 'Stack placed' }, status: :ok
      end

      # POST /api/v1/games/:id/split-stack
      def split_stack
        res = @game.split_stack(
          origin_x: params[:origin_x].to_i,
          origin_y: params[:origin_y].to_i,
          target_x: params[:target_x].to_i,
          target_y: params[:target_y].to_i,
          target_amount: params[:target_amount].to_i
        )

        return render json: { error: res.errors.full_messages }, status: :unprocessable_entity if res.errors.any?

        Domain::GameStackSplittedEvent.new(game_id: @game.id).dispatch

        if @game.reload.game_phase == 'game_over'
          @game.close
          Domain::GameEndEvent.new(game_id: @game.id).dispatch
        else
          Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch
        end

        render json: { message: 'Stack splitted' }, status: :ok
      end

      # development usage
      def init_map_automatically
        res = @game.initialize_map_by_system

        return render json: { error: res.errors.full_messages }, status: :unprocessable_entity if res.errors.any?

        Domain::GameInitializedEvent.new(game_id: @game.id).dispatch
        Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

        render json: { message: 'Map initialized' }, status: :ok
      end

      def random_place_stack
        res = @game.random_place_stack

        return render json: { error: res.errors.full_messages }, status: :unprocessable_entity if res.errors.any?

        Domain::GameStackPlacedEvent.new(game_id: @game.id).dispatch
        Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

        render json: { message: 'Stack placed' }, status: :ok
      end

      def random_split_stack
        res = @game.random_split_stack

        return render json: { error: res.errors.full_messages }, status: :unprocessable_entity if res.errors.any?

        Domain::GameStackSplittedEvent.new(game_id: @game.id).dispatch
        Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

        render json: { message: 'Stack splitted' }, status: :ok
      end

      def reset_game
        @game.close
        Domain::GameEndEvent.new(game_id: @game.id).dispatch

        room = @game.room

        return render json: {
          error: 'Need at least 2 players to start a new game'
        }, status: :unprocessable_entity if room.players.size < 2

        new_game_id = room.start_new_game.id
        Domain::GameCreatedEvent.new(game_id: @game.id, new_game_id:).dispatch

        render json: { message: 'Game reset' }, status: :ok
      end

      private

      def find_game
        @game = Game.find_by(id: params[:id])
        return render json: { error: 'Game not found' }, status: :not_found unless @game

        @game
      end
    end
  end
end
