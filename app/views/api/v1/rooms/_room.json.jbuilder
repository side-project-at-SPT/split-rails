json.id room.id
json.name room.name
json.players room.players do |player|
  json.id player.id
  json.nickname player.preferences&.dig('nickname') || 'none'
end
json.status room.status
