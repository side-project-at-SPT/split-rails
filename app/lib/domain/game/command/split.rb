class Domain::Game::Command::Split
  def initialize(game: nil, player: nil)
    raise 'game is required' if game.nil?
    raise 'player is required' if player.nil?

    @game = game
    @player = player
  end

  def call
    # if the game is ended, reject
    if @game.ended?
      Rails.logger.info { 'The game is ended' }
      return
    end

    # if the player is not the current player, reject
    unless @player == @game.current_player
      Rails.logger.info { 'The player is not the current player' }
      return
    end

    # if the player is not a ai player, reject
    unless @player.ai?
      Rails.logger.info { 'The player is not an AI player' }
      return
    end

    def bypass_is_blocked(*)
      true
    end

    # randomly choose a stack to split
    candidate_origin_positions = @game.pastures.select do |pasture|
      (pasture['stack']['color'] == @player.color) &&
        (pasture['stack']['amount'] >= 2) &&
        bypass_is_blocked(!pasture['is_blocked'])
    end
    raise 'No available position to split a stack' if candidate_origin_positions.empty?

    candidate_positions = @game.pastures.select { |pasture| pasture['stack']['amount'].zero? }
    raise 'No available position to place a stack' if candidate_positions.empty?

    original_grid = candidate_origin_positions.sample

    candidate_positions.sample.then do |grid|
      @game.split_stack(
        origin_x: original_grid['x'],
        origin_y: original_grid['y'],
        destination_x: grid['x'],
        destination_y: grid['y'],
        target_amount: original_grid['stack']['amount'] / 2
      )
    end
      .then { |res| handle_split_stack_result(res) }
  end

  private

  def handle_split_stack_result(res)
    if res.errors.any?
      Rails.logger.error { res.errors.full_messages }
      return
    end

    Domain::GameStackSplittedEvent.new(game_id: @game.id).dispatch

    if @game.reload.game_phase == 'game_over'
      @game.close
      Domain::GameEndEvent.new(game_id: @game.id).dispatch
    else
      Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

      # trigger the next player to play
      Domain::Game::Command::Move.new(game: @game, player: @game.current_player).call
    end
  end
end
