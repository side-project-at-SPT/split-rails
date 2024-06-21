module Domain
  class CreateRoomEvent < Event
    def initialize(room_id: nil)
      raise 'room_id is required' if room_id.nil?

      super(room_id:)
    end

    def identifier
      'lobby_channel'.freeze
    end

    def event_type
      'create_room'.freeze
    end
  end
end
