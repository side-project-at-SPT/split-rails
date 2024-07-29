module Api
  module V1
    class RoomsController < BaseController
      # GET /api/v1/rooms
      def index
        @rooms = Room.where(closed_at: nil).left_outer_joins(:players, :games).distinct.includes(:players, :games)

        render status: :ok
      end

      # GET /api/v1/rooms/:id
      def show
        if (room = Room.find_by(id: params[:id]))
          return render json: { room: Room.find(params[:id]) }, status: :ok
        end

        render json: { error: 'Room not found' }, status: :not_found
      end

      # POST /api/v1/rooms
      def create
        @room = Room.create!(name: params.fetch(:name, 'New Room'))

        # Deprecated: User is automatically joined to the room
        # Reason: User should join the room explicitly by calling /api/v1/rooms/:id/join or with websocket call
        # user = Visitor.find(@jwt_request['sub'])
        # room.players << user

        Domain::CreateRoomEvent.new(room_id: @room.id).dispatch

        render status: :created
      end

      # DELETE /api/v1/rooms/:id/close
      # 關閉房間
      # issue #10: while closing room, call gaas end game if possible
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
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?

        user = Visitor.find(@jwt_request['sub'])

        unless room.players.include?(user)
          return render json: { error: 'You are not in this room' },
                        status: :unauthorized
        end

        room.call_gaas_end_game(@jwt_request[:gaas_auth0_token])
        room.close

        Domain::CloseRoomEvent.new(room_id: params[:id]).dispatch

        head :ok
      end
    end
  end
end
