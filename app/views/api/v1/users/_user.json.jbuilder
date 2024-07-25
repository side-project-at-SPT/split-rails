json.id user.id
json.nickname user.preferences&.dig('nickname') || 'none'
json.is_online $redis.hexists('lobby_channel_users', user.id)
json.room_id user.room_id
json.role user.role
