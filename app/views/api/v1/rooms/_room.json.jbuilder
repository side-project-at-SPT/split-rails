json.id room.id
json.name room.name
json.players room.players do |player|
  json.id player.id
  json.nickname player.nickname
  json.character player.character
  json.is_ready player.ready?
end
json.status room.status
