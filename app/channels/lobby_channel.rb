class LobbyChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'lobby_channel'

    if current_user.is_a?(Visitor)
      $redis.hset('lobby_channel_users', current_user.id, current_user.name)
    else
      $redis.hset('lobby_channel_users', current_user, current_user)
    end

    ActionCable.server.broadcast 'lobby_channel', "Hello, World! #{$redis.hlen('lobby_channel_users')}"
  end

  def receive(data)
  end

  def echo(data)
    message = {
      event: 'echo',
      user_id: current_user.id,
      message: data
    }
    ActionCable.server.broadcast 'lobby_channel', message
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    if current_user.is_a?(Visitor)
      $redis.hdel('lobby_channel_users', current_user.id)
    else
      $redis.hdel('lobby_channel_users', current_user)
    end
    stop_all_streams
  end
end
