class Domain::SplitGame::Command::Play
  def initialize(game: nil, player: nil)
    raise 'game is required' if game.nil?
    raise 'player is required' if player.nil?

    @game = game
    @player = player
  end

  def call
    # if the game is finished, reject
    if @game.finished?
      Rails.logger.info { 'The game is finished?' }
      return
    end

    # if the player is not the current player, reject
    unless @player == @game.current_player
      Rails.logger.info { 'The player is not the current player' }
      return
    end

    # if the player is not a ai player, reject
    unless @player['role'] == 'ai'
      Rails.logger.info { 'The player is not an AI player' }
      return
    end

    # randomly place a stack
    candidate_positions = @game.pastures.select { |pasture| pasture['stack']['amount'].zero? }
    raise 'No available position to place a stack' if candidate_positions.empty?

    candidate_positions
      .sample
      .then { |grid| @game.place_stack(target_x: grid['x'], target_y: grid['y']) }
      .then { |res| handle_place_stack_result(res) }
  end

  private

  def handle_place_stack_result(res)
    if res.errors.any?
      Rails.logger.error { res.errors.full_messages }
      return
    end

    Domain::GameStackPlacedEvent.new(game_id: @game.id).dispatch
    Domain::GameTurnStartedEvent.new(game_id: @game.id).dispatch

    # trigger the next player to play
    Domain::SplitGame::Command::Move.new(game: @game, player: @game.current_player).call
  end
end
