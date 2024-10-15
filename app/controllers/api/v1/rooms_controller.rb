module Api
  module V1
    class RoomsController < BaseController
      before_action :set_room, only: %i[show update destroy add_ai_players knock_knock]

      # GET /api/v1/rooms
      def index
        @rooms = Room.where(closed_at: nil).left_outer_joins(:players, :games).distinct.includes(:players, :games)

        render status: :ok
      end

      # GET /api/v1/rooms/:id
      def show
        if @room
          render json: { room: @room }, status: :ok
        else
          render json: { error: 'Room not found' }, status: :not_found
        end
      end

      # POST /api/v1/rooms
      def create
        current_user = Visitor.find(@jwt_request['sub'])
        @room = Room.create!(name: params.fetch(:name, 'New Room'), owner_id: current_user.id)

        Domain::CreateRoomEvent.new(room_id: @room.id).dispatch

        render status: :created
      end

      # DELETE /api/v1/rooms/:id/close
      # 關閉房間
      # https://github.com/side-project-at-SPT/split-rails/issues/10
      # While closing room, call gaas end game if possible
      # situation:
      #   1. room is not hosted by gaas player
      #     => won't call gaas end game
      #   2. room is hosted by gaas player
      #     => api called by gaas player
      #     => call gaas end game
      #   3. room is hosted by gaas player
      #     => api called by non-gaas player
      #     => use reserve gaas token to call gaas end game
      # changes:
      #   when room created, save open_by_gaas in redis if room is hosted via gaas
      #     => save open_by_gaas in redis: type: str, key 'room:#{room.id}:open_by_gaas', value: true/false
      #   when player join room, save gaas_token in redis if room is hosted by gaas player && player is gaas player
      #     => save gaas_token in redis: type: list, key 'room:#{room.id}:gaas_tokens', value: [gaas_token1, gaas_token2, ...]
      #   when close room, call gaas end game if possible
      def destroy
        return render json: { error: 'Room not found' }, status: :not_found unless @room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if @room.closed?

        user = Visitor.find(@jwt_request['sub'])

        unless user.owner_of?(@room)
          return render json: { error: 'You are not the owner of this room' },
                        status: :forbidden
        end

        @room.call_gaas_end_game(@jwt_request[:gaas_auth0_token])
        @room.close

        Domain::CloseRoomEvent.new(room_id: @room.id).dispatch

        head :ok
      end

      # POST /api/v1/rooms/:id/ai_players
      # Add a random AI player to the room
      # constraints:
      #  1. request user must be in the same room
      def add_ai_players
        return render json: { error: 'Room not found' }, status: :not_found unless @room

        user = Visitor.find(@jwt_request['sub'])
        unless @room.players.include?(user)
          return render json: { error: 'You are not in this room' },
                        status: :unauthorized
        end

        # if room is full, return error
        return render json: { error: 'Room is full' }, status: :unprocessable_entity if @room.full?

        ai_player = Visitor.where.not(id: @room.players.pluck(:id)).role_ai.sample
        return render json: { error: 'AI player not found' }, status: :not_found unless ai_player

        Domain::SplitRoom::Command::AddAi.new(room: @room, ai_player:).call

        render json: {
          message: 'AI player added to the room',
          room_id: @room.id,
          ai_player_id: ai_player.id
        }
      end

      def update
        return render json: { error: 'Room not found' }, status: :not_found unless @room

        user = Visitor.find_by(id: @jwt_request['sub'])
        return render json: { error: 'User not found' }, status: :unauthorized unless user

        unless @room.owner_id == user.id
          return render json: { error: 'You are not the owner of this room' },
                        status: :forbidden
        end

        if @room.update(params.require(:room).permit(:name))
          render json: { message: 'Room updated', room_id: @room.id }, status: :ok
        else
          render json: { error: 'Room not updated' }, status: :unprocessable_entity
        end
      end

      # Provide token to subscribe to the room channel
      def knock_knock
        return render json: { error: 'Room not found' }, status: :not_found unless @room

        user = Visitor.find_by(id: @jwt_request['sub'])
        return render json: { error: 'User not found' }, status: :unauthorized unless user

        return render json: { error: 'Room is full' }, status: :unprocessable_entity if @room.full?

        render json: { token: user.knock_knock(@room) }, status: :ok
      end

      private

      def set_room
        @room = Room.find_by(id: params[:id])
      end
    end
  end
end
