module Api
  module V1
    class RoomsController < BaseController
      # GET /api/v1/rooms
      def index
        render json: { rooms: Room.where(closed_at: nil) }, status: :ok
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
        room = Room.create!(name: params[:name])
        user = Visitor.find(@jwt_request['sub'])
        room.players << user

        render json: { room: room }, status: :created
      end

      # DELETE /api/v1/rooms/:id/close
      # 關閉房間
      def destroy
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        return render json: { error: 'Room is already closed' }, status: :unprocessable_entity if room.closed?

        user = Visitor.find(@jwt_request['sub'])

        return render json: { error: 'You are not in this room' }, status: :unauthorized unless room.players.include?(user)

        Room.find_by(id: params[:id]).close

        head :ok
      end


      # POST /api/v1/rooms/:id/join
      # 加入房間
      def join
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room
        # return render json: { error: 'You are already in this room' }, status: :unprocessable_entity if room.players.include?(@jwt_request['sub'])

        user = Visitor.find(@jwt_request['sub'])

        return render json: { room: room }, status: :ok if room.players.include?(user)

        room.players << user

        render json: { room: room }, status: :ok
      end

      # POST /api/v1/rooms/:id/leave
      # 離開房間
      def leave
        room = Room.find_by(id: params[:id])
        return render json: { error: 'Room not found' }, status: :not_found unless room

        user = Visitor.find(@jwt_request['sub'])

        return render json: { error: 'You are not in this room' }, status: :unprocessable_entity unless room.players.include?(user)

        room.players.delete(user)
        room.save!

        render json: { room: room }, status: :ok
      end
    end
  end
end
