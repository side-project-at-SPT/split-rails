module Api
  module V1
    class GamesController < BaseController
      before_action :find_game, only: %i[show destroy play split]
      # show create destroy play split


      # POST /api/v1/rooms/:id/game
      # 開始遊戲
      def create
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?

        user = Visitor.find(@jwt_request['sub'])
        return render json: { error: 'You are not in this room' }, status: :unauthorized unless room.players.include?(user)

        if room.games.last&.on_going?
          return render json: { error: 'Game is already on going' }, status: :unprocessable_entity
        end

        return render json: { error: 'Not enough players' }, status: :unprocessable_entity if room.players.size < 2

        room.start_new_game

        render json: { game: room.games.last }, status: :created
      end

      # GET /api/v1/rooms/:id/game
      # 查詢目前遊戲狀態
      def show
        render json: { game: @game }, status: :ok
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
        return render json: { error: 'Not your turn' }, status: :unprocessable_entity unless @game.current_player["name"] == @user.name
        if @game.steps.size >= @game.players.size
          # all players have played their pieces
          return render json: { error: 'All players have played their pieces' }, status: :unprocessable_entity
        end

        return render json: { error: 'Invalid position' }, status: :unprocessable_entity unless @game.valid_position?(params)

        @game.steps << { x: params[:x], y: params[:y], color: @game.current_player["color"] }
        @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
        @game.save!

        render json: { game: @game }, status: :ok
      end

      # POST /api/v1/rooms/:id/game/split
      # 分配棋子
      # params: { origin_x: 1, origin_y: 1, target_x: 0, target_y: 0, amount: 1 }
      def split
        return render json: { error: 'Game is already finished' }, status: :unprocessable_entity if @game.finished?
        return render json: { error: 'Not your turn' }, status: :unprocessable_entity unless @game.current_player["name"] == @user.name
        return render json: { error: 'Invalid position' }, status: :unprocessable_entity unless @game.valid_position?(params)

        if params[:amount].to_i < 1
          return render json: { error: 'Invalid amount' }, status: :unprocessable_entity
        end

        @game.steps << {
          origin_x: params[:origin_x],
          origin_y: params[:origin_y],
          target_x: params[:target_x],
          target_y: params[:target_y],
          amount: params[:amount],
          color: @game.current_player["color"]
        }
        @game.current_player_index = (@game.current_player_index + 1) % @game.players.size
        @game.save!

        render json: { game: @game }, status: :ok
      end

      private

      def find_game
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?
        @user = Visitor.find(@jwt_request['sub'])
        return render json: { error: 'You are not in this room' }, status: :unauthorized unless room.players.include?(@user)

        @game = room.games.last
        return render json: { error: 'Game is finished' }, status: :unprocessable_entity if @game&.finished?
        return render json: { error: 'Game not found' }, status: :not_found unless @game

        @game
      end
    end
  end
end
