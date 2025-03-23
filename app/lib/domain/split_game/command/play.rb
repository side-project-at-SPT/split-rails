module Domain
  module SplitGame
    module Command
      class Play
        include Errors

        def initialize(game: nil, player: nil)
          raise GameRequiredError if game.nil?
          raise PlayerRequiredError if player.nil?

          @game = game
          @player = player
        end

        def call
          # randomly place a stack in boundary
          boundary = Domain::SplitGame::Query::ShowBoundary.new(game: @game).call
          candidate_positions = @game.pastures.select { |pasture| pasture['stack']['amount'].zero? }.select do |pasture|
            boundary.any? { |grid| grid[0] == pasture['x'] && grid[1] == pasture['y'] }
          end
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
    end
  end
end
