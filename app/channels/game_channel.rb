# frozen_string_literal: true

class GameChannel < ApplicationCable::Channel
  def subscribed
    @game = Game.find(params[:game_id])
    stream_for(@game)

    player_joined_game @game.id, current_user.id
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed

    player_left_game @game.id, current_user.id
  end

  private

  # def current_game_state
  #   {
  #     id: @game.id,
  #     players: player_state,
  #     steps: @game.steps
  #   }
  # end

  def player_joined_game(game_id, player_id)
    key = "game_#{game_id}:#{player_id}:connected"
    $redis.set(key, true, ex: 1.hour.to_i)

    broadcast_to(@game, { event: 'player_joined_game', player_state: })
  end

  def player_left_game(game_id, player_id)
    key = "@game_#{game_id}:#{player_id}:connected"
    $redis.del(key)

    broadcast_to(@game, { event: 'player_left_game', player_state: })
  end

  def player_is_connected?(game_id, player_id)
    key = "game_#{game_id}:#{player_id}:connected"
    $redis.get(key).present?
  end

  def player_state
    @game.players.map do |player|
      {
        id: player['id'],
        nickname: player['nickname'],
        color: player['color'],
        character: player['character'],
        is_connected: player_is_connected?(@game.id, player['id'])
      }
    end
  end
end
