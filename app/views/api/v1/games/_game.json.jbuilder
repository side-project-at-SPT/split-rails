# frozen_string_literal: true

json.id game.id
json.game_config do
  json.players_number game.players.size
  json.players game.players do |player|
    json.id player['id']
    json.nickname player['nickname']
    json.color player['color']
    json.character player['character']
  end
end
json.game_data do
  json.step step
  json.current_player_index game.current_player_index
  json.pastures game.pastures do |pasture|
    json.x pasture['x']
    json.y pasture['y']
    json.is_blocked pasture['is_blocked']
    json.stack do
      json.color pasture['stack']['color']
      json.amount pasture['stack']['amount']
    end
  end
  # json.colors game.colors
end
