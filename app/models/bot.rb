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

  # Generate a grid to place a stack
  def generate_grid_to_place_stack(info)
    http = HTTPX.with(headers: { "accept": 'application/json' }).with(timeout: { request_timeout: 5 })
    url = 'https://ipinfo.io'
    url = webhook_url if webhook_url.present?
    response = http.get url
    case response
    in {error: error}
      puts error
    in {status: 400.., body: body}
      puts body
    else
      response.json
    end
  end
end
