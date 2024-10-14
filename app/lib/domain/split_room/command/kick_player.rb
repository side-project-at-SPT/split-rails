# https://stackoverflow.com/questions/39815216/how-to-terminate-subscription-to-an-actioncable-channel-from-server

class Domain::SplitRoom::Command::KickPlayer
  # def initialize(room: nil, player: nil)
  #   raise 'room is required' if room.nil?
  #   raise 'player is required' if player.nil?

  #   @room = room
  #   @player = player
  # end

  # def call
  #   VisitorRoom.where(room: @room, visitor: @player).destroy_all

  #   @room.players << @ai_player

  #   # get ready
  #   @ai_player.ready!

  #   @ai_player.character = SAMPLE_CHARACTER.sample
  #   @ai_player.save

  #   @room.reload

  #   # notify lobby channel
  #   dispatch_to_lobby('join_room', @room)
  #   # notify room channel
  #   dispatch_to_room('room_updated', @room)
  # end

  # private

  # def dispatch_to_lobby(event, room)
  #   ActionCable
  #     .server
  #     .broadcast(
  #       'lobby_channel',
  #       {
  #         event:,
  #         room:
  #         {
  #           id: room.id,
  #           name: room.name,
  #           players: room.players.map do |player|
  #                      {
  #                        id: player.id,
  #                        nickname: player.nickname,
  #                        character: player.character,
  #                        is_ready: player.ready?,
  #                        role: player.role
  #                      }
  #                    end
  #         },
  #         status: room.status
  #       }
  #     )
  # end

  # def dispatch_to_room(event, room)
  #   players = room.players.map do |rp|
  #     {
  #       id: rp.id,
  #       nickname: rp.nickname,
  #       character: rp.character,
  #       is_ready: rp.ready?,
  #       role: rp.role
  #     }
  #   end

  #   RoomChannel.broadcast_to(room, { event:, players:, status: room.status })
  # end
end
