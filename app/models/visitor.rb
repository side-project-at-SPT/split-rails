class Visitor < ApplicationRecord
  has_secure_password

  has_one :visitors_room, dependent: :destroy
  has_one :room, through: :visitors_room

  validates :name, presence: true, uniqueness: true
  validate :allow_preferences_attributes?

  enum role: { admin: 0, user: 1, guest: 2, ai: 3 }, _prefix: true

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

  delegate :id, :name, to: :room, prefix: true, allow_nil: true
end
