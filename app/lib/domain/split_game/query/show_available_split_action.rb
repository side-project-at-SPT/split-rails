class Domain::SplitGame::Query::ShowAvailableSplitAction
  def initialize(game: nil)
    raise 'game is required' if game.nil?

    @game = game
  end

  def call(print_debug_info: false)
    directions = [[0, 1], [1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1]]
    available_split_actions = []
    candidates = Set.new(
      @game.game_data['pastures'].select do |g|
        g['stack']['amount'].zero?
      end.map { |g| [g['x'], g['y']] }
    )
    @game.game_data['pastures'].select { |g| g['stack']['color'] == @game.current_player['color'] }.each do |grid|
      # try six directions
      directions.each do |direction|
        x = grid['x']
        y = grid['y']
        temp_candidates = nil
        loop do
          x += direction[0]
          y += direction[1]
          break unless candidates.include?([x, y])

          temp_candidates = [x, y]
        end

        next unless temp_candidates

        available_split_actions << [grid, temp_candidates[0], temp_candidates[1]]
      end
    end

    pp available_split_actions if print_debug_info

    available_split_actions
  end
end
