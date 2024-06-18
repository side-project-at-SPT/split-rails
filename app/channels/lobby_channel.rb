class LobbyChannel < ApplicationCable::Channel
  def subscribed
    puts "current_user: #{current_user}"

    stream_from 'lobby_channel'

    # $redis.incr('lobby_channel_count')
    if current_user.is_a?(Visitor)
      $redis.hset('lobby_channel_users', current_user.id, current_user.name)
    else
      $redis.hset('lobby_channel_users', current_user, current_user)
    end

    ActionCable.server.broadcast 'lobby_channel', "Hello, World! #{$redis.hlen('lobby_channel_users')}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    # $redis.decr('lobby_channel_count')
    if current_user.is_a?(Visitor)
      $redis.hdel('lobby_channel_users', current_user.id)
    else
      $redis.hdel('lobby_channel_users', current_user)
    end
    ActionCable.server.broadcast 'lobby_channel', 'Goodbye, World!'
    stop_all_streams
  end
end
