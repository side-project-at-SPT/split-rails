class RoomChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find_by(id: params[:room_id])

    if room.nil?
      reject
      return
    end

    stream_for(room)
    room_join_with(room, current_user)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    room = Room.find_by(id: params[:room_id])

    if room.nil?
      Rails.logger.debug('Room not found')
      return
    end

    room_leave_with(room, current_user)
    # stop_all_streams
  end

  def set_character(data)
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return if room.players.exclude?(current_user)

    character = data['character']

    Rails.logger.debug { "Character: #{character}" }

    current_user.character = character
    current_user.save

    players = room.players.map do |player|
      {
        player_id: player.id,
        nickname: player.nickname,
        character: player.character,
        is_ready: player.ready?
      }
    end

    broadcast_to(room, { event: 'set_character', players: })
  end

  def cancel_ready
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return if room.players.exclude?(current_user)

    current_user.unready!

    broadcast_to(
      room,
      {
        event: 'cancel_ready',
        player: {
          id: current_user.id,
          nickname: current_user.nickname,
          character: current_user.character,
          is_ready: current_user.ready?
        }
      }
    )

    # there is game starting
    return unless room.start_in_seconds.positive?

    # interrupt starting game
    key = "room_#{room.id}:start_game_interrupted"
    $redis.set(key, true)
  end

  def ready
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return if room.players.exclude?(current_user)

    current_user.reload.ready!
    # current_user.reload
    # room = current_user.room.reload
    broadcast_to(
      room,
      {
        event: 'ready',
        player: {
          id: current_user.id,
          nickname: current_user.nickname,
          character: current_user.character,
          is_ready: current_user.ready?
        }
      }
    )

    return unless room.ready_to_start?

    dispatch_to_lobby('game_is_starting', room)

    while room.status == 'starting'
      broadcast_to(room, { event: 'game_start_in_seconds', seconds: room.start_in_seconds })
      room.countdown

      return if interrupt_start_game
    end

    room.start_new_game

    broadcast_to(room, { event: 'game_started', game_id: room.games.last.id })
    dispatch_to_lobby('game_started', room)
  end

  def close_game
    room = current_user.room
    game = room.games.last
    return unless game&.on_going?

    game.close
    game.room.players.each { |player| player.reload.unready! }

    broadcast_to(room, { event: 'game_closed' })
    Rails.logger.debug("Game Status: #{room.status}")
    dispatch_to_lobby('game_closed', room)
  end

  private

  def room_join_with(room, player)
    reject and return if room.players.include?(player)

    room.players << player unless room.players.include?(player)

    broadcast_to(room, {
                   event: 'join_room',
                   player: {
                     id: player.id,
                     nickname: player.nickname,
                     character: player.character,
                     is_ready: player.ready?
                   }
                 })
    dispatch_to_lobby('join_room', room)
  end

  def room_leave_with(room, player)
    room.players.delete(player)
    broadcast_to(room, {
                   event: 'leave_room',
                   player: {
                     id: player.id,
                     nickname: player.nickname,
                     character: player.character,
                     is_ready: player.ready?
                   }
                 })
    dispatch_to_lobby('leave_room', room)
  end

  def interrupt_start_game
    room = current_user.room
    key = "room_#{room.id}:start_game_interrupted"
    return false unless $redis.get(key)

    $redis.del(key)
    $redis.del("room_#{room.id}:game_start_in_seconds")

    broadcast_to(room, { event: 'starting_game_is_cancelled' })
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
                         nickname: player.nickname,
                         character: player.character,
                         is_ready: player.ready?
                       }
                     end
          },
          status: room.status
        }
      )
  end
end
