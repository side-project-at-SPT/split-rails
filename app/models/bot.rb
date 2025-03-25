class Bot < ApplicationRecord
  belongs_to :owner, class_name: 'Visitor', foreign_key: 'visitor_id'
  has_many :players, class_name: 'Visitor'

  enum status: { offline: 'offline', online: 'online' }

  def generate_player
    bot = Visitor.new_visitor(name: "#{name} #{SecureRandom.base36(4)}", role: :ai)
    bot.update!(bot: self)
    players << bot
    bot
  end

  def join_room(room)
    ai_player = generate_player
    Domain::SplitRoom::Command::AddAi.new(room:, ai_player:).call
    ai_player.id
  end
end
