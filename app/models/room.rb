class Room < ApplicationRecord
  has_many :visitors_rooms, dependent: :destroy
  has_many :players, through: :visitors_rooms, source: :visitor
  has_many :games

  validates :name, presence: true

  COLOR = %w[red blue green yellow].freeze

  # TODO: move to Game model
  def generate_players(seed: 13)
    ret = []
    colors = COLOR.shuffle
    players.rotate(seed).each_with_index do |player, i|
      ret << {
        id: player.id,
        nickname: player.nickname,
        color: colors[i],
        character: player.character,
        role: player.role
      }
    end

    ret
  end

  # TODO: move to Game model
  def start_new_game(seed: nil)
    game = Game.create do |g|
      seed ||= created_at.to_i
      g.room = self
      g.players = generate_players(seed:)
      g.current_player_index = (seed * 13 + 17) % g.players.size
    end

    game.initialize_map_by_system(seed:) if game.should_initialize_map_by_system?
    game
  end

  def closed?
    closed_at.present?
  end

  def call_gaas_end_game(auth0_token)
    room_id = $redis.get("gaas_room_id_of:#{id}")
    return unless room_id

    token_to_close_room = if auth0_token.nil?
                            # use reserve gaas token to call gaas end game
                            $redis.lrange("room:#{id}:gaas_tokens", 0, -1)
                          else
                            [auth0_token]
                          end

    token_to_close_room.each do |token|
      uri = URI("https://api.gaas.waterballsa.tw/rooms/#{room_id}:endGame")
      req = Net::HTTP::Post.new uri
      req['Authorization'] = "Bearer #{token}"
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.request req
      end
      if res.code.to_i.between?(200, 299)
        $redis.del("gaas_room_id_of:#{id}")
        $redis.del("room:#{id}:gaas_tokens")
        Rails.logger.warn { "Successfully end game #{res.body}" }
        return 0
      else
        # do not raise error, just log it
        Rails.logger.warn { "Failed to end game #{res.body}" }
      end
    end

    Rails.logger.warn { 'Failed to end game' }
  end

  def close
    return nil if closed?

    self.closed_at = Time.current
    self.players = []
    save!
  end

  def ready_to_start?
    players = self.players.reload
    Rails.logger.info { "status: #{status}, players: #{players.size}, all ready: #{players.all?(&:ready?)}" }
    if status == 'waiting' && players.size >= 2 && players.all?(&:ready?)
      Rails.logger.info { 'countdown game start' }
      countdown_game_start
      true
    else
      false
    end
  end

  def start_in_seconds
    $redis.get("room_#{id}:game_start_in_seconds").to_i
  end

  def countdown_game_start(seconds: 5)
    $redis.set("room_#{id}:game_start_in_seconds", seconds)
  end

  def countdown
    Rails.logger.debug("countdown: #{start_in_seconds}")

    return unless start_in_seconds.positive?

    sleep 1

    $redis.decr("room_#{id}:game_start_in_seconds")
  end

  def status
    if games.last&.on_going?
      'playing'
    elsif start_in_seconds.positive?
      'starting'
    else
      'waiting'
    end
  end

  def full?
    players.size >= 4
  end
end
