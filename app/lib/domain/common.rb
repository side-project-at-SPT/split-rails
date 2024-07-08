module Domain
  class Common
    class << self
      def connect_grids(grid)
        # is connected means that the grid is connected to the grid that shares the same edge
        # the grid is Hexagon
        # the grid coordinate is (x, y)
        # the pseudo axis is a: "x = N", b: "y = N", c: "x + y = N"

        # given the grid coordinate (x, y)
        # output the connected grid coordinate

        grid = grid.with_indifferent_access

        [
          { x: grid[:x] + 1, y: grid[:y] },
          { x: grid[:x] - 1, y: grid[:y] },
          { x: grid[:x], y: grid[:y] + 1 },
          { x: grid[:x], y: grid[:y] - 1 },
          { x: grid[:x] + 1, y: grid[:y] - 1 },
          { x: grid[:x] - 1, y: grid[:y] + 1 }
        ].map { |g| { x: g[:x], y: g[:y], is_blocked: false, stack: { color: 'blank', amount: 0 } } }
          .map(&:with_indifferent_access)
      end

      def grid_and_its_neighbors_on_the_map(grid, pastures)
        grid = grid.with_indifferent_access
        (
          [grid] +
              [
                { x: grid[:x] + 1, y: grid[:y] },
                { x: grid[:x] - 1, y: grid[:y] },
                { x: grid[:x], y: grid[:y] + 1 },
                { x: grid[:x], y: grid[:y] - 1 },
                { x: grid[:x] + 1, y: grid[:y] - 1 },
                { x: grid[:x] - 1, y: grid[:y] + 1 }
              ]
            .map do |g|
              pastures.select do |pasture|
                pasture['x'] == g[:x] && pasture['y'] == g[:y]
              end.first
            end.compact
        ).map(&:with_indifferent_access)
      end

      def all_neighbors_capture?(grid, pastures)
        grid = grid.with_indifferent_access
        (
          [
            { x: grid[:x] + 1, y: grid[:y] },
            { x: grid[:x] - 1, y: grid[:y] },
            { x: grid[:x], y: grid[:y] + 1 },
            { x: grid[:x], y: grid[:y] - 1 },
            { x: grid[:x] + 1, y: grid[:y] - 1 },
            { x: grid[:x] - 1, y: grid[:y] + 1 }
          ].map { |g| (pastures.select { |pasture| pasture['x'] == g[:x] && pasture['y'] == g[:y] }).first }
        ).compact.map(&:with_indifferent_access).all? { |g| g['stack']['amount'].positive? }
      end

      def next_available_player_index(current_player_index:, colors:, pastures:)
        available_pastures = []

        counter = 0

        while available_pastures.empty? && counter < colors.size
          current_player_index = (current_player_index + 1) % colors.size
          captured_pastures = pastures.select do |pasture|
            pasture['stack']['color'] == colors[current_player_index]
          end
          available_pastures = captured_pastures.select do |pasture|
            !pasture['is_blocked']
          end
          counter += 1
        end

        if available_pastures.empty?
          -1
        else
          current_player_index
        end
      end
    end
  end
end
