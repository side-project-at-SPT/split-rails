class Domain::SplitGame::Query::ShowBoundary
  def initialize(game: nil)
    raise 'game is required' if game.nil?

    @game = game
  end

  def call(print_debug_info: false)
    puts 'ShowBoundary' if print_debug_info

    # determine the boundary of the game_map
    min_x = min_y = 100
    max_x = max_y = 0
    @game.game_data['pastures'].each do |pasture|
      min_x = pasture['x'] if pasture['x'] < min_x
      min_y = pasture['y'] if pasture['y'] < min_y
      max_x = pasture['x'] if pasture['x'] > max_x
      max_y = pasture['y'] if pasture['y'] > max_y
    end

    diff_x = max_x - min_x
    diff_y = max_y - min_y

    scale_factor = 1

    map = Array.new(scale_factor * diff_x + 1) { Array.new(scale_factor * diff_y + 1) { '(_,_)' } }

    # print the game_data["pastures"]
    # 3 axis: N = x, N = y, N = x + y

    @game.game_data['pastures'].each do |pasture|
      pp pasture if print_debug_info

      x = pasture['x'] - min_x
      y = pasture['y'] - min_y
      map[x][y] = "(#{x},#{y})"
    end

    # Detect the boundary
    # 1. select the start point which is the top left corner
    start_point = map.map do |row|
      row.map do |cell|
        x, y = cell.scan(/\d+/).map(&:to_i)
        next unless x && y

        [cell, x, y]
      end.compact
    end.then do |tmp|
      tmp.flatten(1).group_by { |_, x, y| x + y }.min_by { |x, _| x }.last.min_by { |_, x, _| x }
    end

    pp start_point if print_debug_info

    # 2. go through the map to find the boundary in dfs
    directions = [[0, 1], [1, 0], [1, -1], [0, -1], [-1, 0], [-1, 1]]
    visited = Set.new
    boundary = Set.new
    stacks = [[start_point[1], start_point[2], 0], nil]

    while stacks.any?
      # @counter ||= 0
      # @counter += 1
      # if @counter > 400
      #   # pp stacks
      #   break
      # end

      cell = stacks.shift

      if cell.nil?
        puts 'complete the loop' if print_debug_info
        break
      end

      if visited.include?(cell.join(','))
        puts 'complete the loop' if print_debug_info
        break
      end
      visited << cell.join(',')

      print "cell: #{cell} " if print_debug_info
      x, y, direction = cell

      if x.negative? || y.negative? || x >= map.size || y >= map[0].size
        puts "X\nout of the boundary" if print_debug_info
        next
      end

      if map[x][y] == '(_,_)'
        puts "X\nthe cell is not part of the pastures" if print_debug_info
        next
      end

      if boundary.include?([x, y, direction])
        puts "X\nthe cell is already visited" if print_debug_info
        next
      end

      boundary << [x, y, 0]
      puts "O\nadd the neighbors to the stack" if print_debug_info
      tmp_stacks = []
      6.times do |i|
        current_direction_index = (direction + i + 5) % 6
        diff_x, diff_y = directions[current_direction_index]
        tmp_stacks << [x + diff_x, y + diff_y, current_direction_index]
      end

      stacks.prepend(*tmp_stacks)
    end

    pp "@counter: #{@counter}" if print_debug_info

    boundary.each do |x, y|
      map[x][y] = "[#{x},#{y}]"
    end

    if print_debug_info
      map.each_with_index do |row, x|
        print ' ' * x * 3
        row.each_with_index do |cell, y|
          print "#{cell}"
        end

        print "\n"
      end
    end

    boundary
  end
end
