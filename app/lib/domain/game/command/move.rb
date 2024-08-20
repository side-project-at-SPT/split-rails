class Domain::Game::Command::Move
  def initialize(game: nil, player: nil)
    raise 'game is required' if game.nil?
    raise 'player is required' if player.nil?

    @game = game
    @player = player
  end

  def call
    # FIXME: Temporarily print the game data for debugging
    pp "game id: #{@game.id}"
    pp "game phase: #{@game.game_phase}"
    pp "current player: #{@player.current_player.nickname}"
    pp "incoming player: #{@player.nickname}"

    case @game.game_phase
    when 'place_stack'
      place_stack
    when 'split_stack'
      split_stack
    end
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
    Domain::Game::Command::Move.new(game: @game, player: @game.current_player).call
  end

  def place_stack
    Domain::Game::Command::Play.new(game: @game, player: @player).call
  end

  def split_stack
    Domain::Game::Command::Split.new(game: @game, player: @player).call
  end
end
