class Visitor < ApplicationRecord
  has_secure_password

  has_many :visitors_rooms, dependent: :destroy
  has_many :rooms, through: :visitors_rooms

  validates :name, presence: true, uniqueness: true
  validate :allow_preferences_attributes?

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

  def ready?
    visitors_rooms.find_by(room_id:)&.ready
  end

  def ready!
    visitors_rooms.find_by(room_id:)&.ready!
  end

  def character
    visitors_rooms.find_by(room_id:)&.character
  end

  def room_id
    rooms.first&.id
  end
end
