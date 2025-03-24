class Visitor < ApplicationRecord
  has_secure_password

  has_one :visitors_room, dependent: :destroy
  has_one :room, through: :visitors_room

  validates :name, presence: true, uniqueness: true
  validate :allow_preferences_attributes?

  enum :role, {
    admin: 0,
    user: 1,
    guest: 2,
    ai: 3,
    test_dummy: 4
  }, prefix: true

  def encode_jwt
    payload = { sub: id }
    Api::JsonWebToken.encode payload
  end

  ALLOW_PREFERENCES = %w[nickname].freeze

  def allow_preferences_attributes?
    return true if preferences.blank?

    preferences.keys.all? { |key| ALLOW_PREFERENCES.include?(key) }
  end

  def read_preferences
    self.preferences ||= {}
    ALLOW_PREFERENCES.each_with_object({}) do |key, hash|
      hash[key] = preferences[key] || 'none'
    end
  end

  def nickname
    return AiPlayer.find_by(player_id: id)&.nickname || 'none' if role_ai?

    self.preferences&.dig('nickname') || 'none'
  end

  # delegate 'ready?', to: :visitors_room,  allow_nil: true

  def ready?
    visitors_room&.ready? || false
  end

  def ready!
    visitors_room&.ready!
  end

  def unready!
    visitors_room&.unready!
  end

  def character
    visitors_room&.character
  end

  def character=(value)
    visitors_room&.update(character: value)
  end

  def owner_of?(room)
    room.owner_id == id
  end

  def knock_knock(room)
    payload = { sub: room.id }
    Api::JsonWebToken.encode payload, 10.seconds.from_now
  end

  class << self
    def new_visitor(name: nil, password: nil, role: nil)
      create!(
        name: name || "guest_#{Time.now.strftime('%Y%m%d')}_#{SecureRandom.alphanumeric(10)}",
        password: password || SecureRandom.alphanumeric(16),
        role: role || :guest
      )
    end
  end

  delegate :id, :name, to: :room, prefix: true, allow_nil: true
end
