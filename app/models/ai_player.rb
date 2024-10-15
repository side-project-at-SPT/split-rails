class AiPlayer < ApplicationRecord
  belongs_to :bot
  belongs_to :player, class_name: 'Visitor', foreign_key: 'player_id'

  def nickname
    "#{bot.name} (#{bot.owner.nickname})"
  end
end
