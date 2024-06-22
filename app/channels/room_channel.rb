class RoomChannel < ApplicationCable::Channel
  def subscribed
    @room = Room.find_by(id: params[:room_id])

    if @room.nil?
      reject
      return
    end

    room_join_with(current_user)

    stream_for(@room)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    room_leave_with(current_user)
    # stop_all_streams
  end

  private

  def room_join_with(player)
    reject and return if @room.players.include?(player)

    @room.players << player unless @room.players.include?(player)

    dispatch_to_room('join_room', player)
    dispatch_to_lobby('join_room', @room)
  end

  def room_leave_with(player)
    # TODO: Implement this
    Rails.logger.debug('Not Implemented')
  end

  def dispatch_to_room(event, player)
    broadcast_to(
      @room,
      {
        event:,
        player: {
          id: player.id,
          nickname: player.nickname
        }
      }
    )
  end

  def dispatch_to_lobby(event, room)
    ActionCable
      .server
      .broadcast(
        'lobby_channel',
        {
          event:,
          room:
          {
            id: room.id,
            name: room.name,
            players: room.players.map do |player|
                       {
                         id: player.id,
                         nickname: player.nickname
                       }
                     end
          }
        }
      )
  end
end
