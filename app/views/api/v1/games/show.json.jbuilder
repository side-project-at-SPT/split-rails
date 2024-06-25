# json.room @game, partial: 'game', game: @game, step: @step

json.game do
  json.partial! 'game', game: @game, step: @step
end
