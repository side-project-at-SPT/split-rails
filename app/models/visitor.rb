class Visitor < ApplicationRecord
  has_secure_password

  has_many :visitors_rooms, dependent: :destroy
  has_many :rooms, through: :visitors_rooms

  validates :name, presence: true, uniqueness: true

  def encode_jwt
    payload = { sub: id }
    Api::JsonWebToken.encode payload
  end
end
