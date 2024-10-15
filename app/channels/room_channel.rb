class RoomChannel < ApplicationCable::Channel
  def subscribed
    begin
      _decoded_token = Api::JsonWebToken.decode(params[:token])
    rescue JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.error { "Error decoding the token: #{e.message}" }
      transmit({ error: 'Invalid token' })
      reject
      return
    end

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
    stop_all_streams
  end

  def receive(data)
    broadcast_to(Room.find_by(id: params[:room_id]), data)
  end

  def set_character(data)
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return if room.players.exclude?(current_user)

    character = data['character']

    Rails.logger.debug { "Character: #{character}" }

    current_user.character = character
    current_user.save

    dispatch_to_room('room_updated', room)
  end

  def cancel_ready
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return if room.players.exclude?(current_user)

    current_user.unready!

    dispatch_to_room('room_updated', room)

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

    dispatch_to_room('room_updated', room)

    return unless room.ready_to_start?

    dispatch_to_lobby('game_is_starting', room)

    while room.status == 'starting'
      broadcast_to(room, { event: 'game_start_in_seconds', seconds: room.start_in_seconds })
      room.countdown

      return if interrupt_start_game
    end

    room.start_new_game

    # let players in the room change their ready status to false
    room.players.reload.each(&:unready!)
    # check if all players are unready
    # TODO: remove this line after testing
    Rails.logger.info { "All players are unready? #{room.players.reload.none?(&:ready?)}" }

    broadcast_to(room, { event: 'game_started', game_id: room.games.last.id })
    dispatch_to_lobby('game_started', room)

    # trigger the first player to make a move
    current_player = room.games.last.current_player
    Domain::SplitGame::Command::Move.new(game: room.games.last, player: current_player).call
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

  # https://stackoverflow.com/questions/39815216/how-to-terminate-subscription-to-an-actioncable-channel-from-server
  def kick_player(data)
    room = Room.find_by(id: params[:room_id])

    reject and return if room.nil?
    reject and return unless current_user.owner_of?(room)

    kicked_player = Visitor.find_by(id: data['player_id'])
    reject and return if kicked_player.nil?

    VisitorsRoom.where(room:, visitor: kicked_player).destroy_all

    dispatch_to_room('room_updated', room)
    dispatch_to_lobby('leave_room', room)

    ActionCable.server.remote_connections.where(current_user: kicked_player).disconnect
  end

  private

  def room_join_with(room, player)
    reject and return if room.players.include?(player)

    room.players << player

    # if room is hosted via gaas and player is gaas player, save gaas_token in redis
    if $redis.get("gaas_room_id_of:#{room.id}") && (token_to_close_room = $redis.get("user:#{player.id}:gaas_auth0_token"))
      $redis.rpush("room:#{room.id}:gaas_tokens", token_to_close_room)
    end

    dispatch_to_room('room_updated', room)
    dispatch_to_lobby('join_room', room)
    interrupt_start_game
  end

  def room_leave_with(room, player)
    room.players.delete(player)

    dispatch_to_room('room_updated', room)
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
            owner_id: room.owner_id,
            players: room.players.map do |player|
                       {
                         id: player.id,
                         nickname: player.nickname,
                         character: player.character,
                         is_ready: player.ready?,
                         role: player.role,
                         is_owner: player.id == room.owner_id
                       }
                     end
          },
          status: room.status
        }
      )
  end

  def dispatch_to_room(event, room)
    players = room.players.map do |rp|
      {
        id: rp.id,
        nickname: rp.nickname,
        character: rp.character,
        is_ready: rp.ready?,
        role: rp.role,
        is_owner: rp.id == room.owner_id
      }
    end

    broadcast_to(room, { event:, owner_id: room.owner_id, players:, status: room.status })
  end
end
