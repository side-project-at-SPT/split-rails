class Room < ApplicationRecord
  has_many :visitors_rooms, dependent: :destroy
  has_many :players, through: :visitors_rooms, source: :visitor
  has_many :games

  validates :name, presence: true

  COLOR = %w[red blue green yellow orange].freeze

  def generate_players(seed: 13)
    ret = []
    colors = COLOR.shuffle
    players.rotate(seed).each_with_index do |player, i|
      ret << { name: player.name, color: colors[i] }
    end

    ret
  end

  def start_new_game
    Game.create do |g|
      seed = created_at.to_i
      g.room = self
      g.players = generate_players(seed:)
      g.current_player_index = (seed * 13 + 17) % g.players.size
    end
  end

  def closed?
    closed_at.present?
  end

  def close
    return nil if closed?

    self.closed_at = Time.current
    self.players = []
    save!
  end

  def status
    if games.last&.on_going?
      'playing'
    else
      'waiting'
    end
  end
end
