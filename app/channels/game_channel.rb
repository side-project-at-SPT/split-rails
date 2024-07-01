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

  def echo(data)
    transmit({ echo: data['message'] })
  end

  def place_stack(data)
    # to ensure the game is up-to-date
    @game.reload

    # if is not the player's turn
    unless @game.current_player['id'] == current_user.id
      Rails.logger.warn { 'Not your turn' }
      Rails.logger.warn { "Current player: #{current_user.id}" }
      Rails.logger.warn { "Your id: #{current_user.id}" }
      return
    end

    required_params = %w[x y]
    lacking_params = required_params.reject { |param| data.key?(param) }
    if lacking_params.any?
      Rails.logger.warn { "Missing required params: #{lacking_params.join(', ')}" }
      return
    end

    res = @game.place_stack(target_x: data['x'].to_i, target_y: data['y'].to_i)

    if res.errors.any?
      Rails.logger.error { res.errors.full_messages }
      return
    end

    Domain::GameStackPlacedEvent.new(game_id: @game.id).dispatch
    Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch
  end

  def split_stack(data)
    # to ensure the game is up-to-date
    @game.reload

    # if is not the player's turn
    unless @game.current_player['id'] == current_user.id
      Rails.logger.warn { 'Not your turn' }
      Rails.logger.warn { "Current player: #{current_user.id}" }
      Rails.logger.warn { "Your id: #{current_user.id}" }
      return
    end

    required_params = %w[origin_x origin_y target_x target_y target_amount]
    lacking_params = required_params.reject { |param| data.key?(param) }
    if lacking_params.any?
      Rails.logger.warn { "Missing required params: #{lacking_params.join(', ')}" }
      return
    end

    params = {
      origin_x: data.fetch('origin_x').to_i,
      origin_y: data.fetch('origin_y').to_i,
      target_x: data.fetch('target_x').to_i,
      target_y: data.fetch('target_y').to_i,
      target_amount: data.fetch('target_amount').to_i
    }
    res = @game.split_stack(**params)

    if res.errors.any?
      Rails.logger.error { res.errors.full_messages }
      return
    end

    Domain::GameStackSplittedEvent.new(game_id: @game.id).dispatch
    Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch
  end

  private

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
