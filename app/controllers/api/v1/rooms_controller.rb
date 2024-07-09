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
      def destroy
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?

        user = Visitor.find(@jwt_request['sub'])

        unless room.players.include?(user)
          return render json: { error: 'You are not in this room' },
                        status: :unauthorized
        end

        Room.find_by(id: params[:id]).close

        Domain::CloseRoomEvent.new(room_id: @room.id).dispatch

        head :ok
      end
    end
  end
end
