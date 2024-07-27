module Domain
  class CloseRoomEvent < Event
    def initialize(room_id: nil)
      raise 'room_id is required' if room_id.nil?

      super(room_id:)
    end

    def identifier
      'lobby_channel'.freeze
    end

    def event_type
      'room_closed'.freeze
    end

    def dispatch
      # to room channel
      Room.find(params[:room_id])
          .then do |room|
        RoomChannel.broadcast_to(
          room, {
            event: event_type
          }
        )
      end

      # to lobby channel
      super
    end
  end
end
