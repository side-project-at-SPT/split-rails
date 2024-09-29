json.id room.id
json.name room.name
json.owner_id room.owner_id
json.players room.players do |player|
  json.id player.id
  json.nickname player.nickname
  json.character player.character
  json.is_ready player.ready?
  json.role player.role
  json.is_owner player.id == room.owner_id
end
json.status room.status
json.game_id room.games.last.id if room.status == 'playing'
