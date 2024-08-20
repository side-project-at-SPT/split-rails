class Domain::SplitGame::Command::Move
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
    pp "current player: #{@game.current_player['nickname']}"
    pp "incoming player: #{@player['nickname']}"

    case @game.game_phase
    when 'place_stack'
      place_stack
    when 'split_stack'
      split_stack
    end
  end

  private

  def place_stack
    Domain::SplitGame::Command::Play.new(game: @game, player: @player).call
  end

  def split_stack
    Domain::SplitGame::Command::Split.new(game: @game, player: @player).call
  end
end
