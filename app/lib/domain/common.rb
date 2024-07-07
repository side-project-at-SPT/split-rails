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
        connect_grids(grid).select { |g| pastures.include?(g) } + [grid]
      end
    end
  end
end
