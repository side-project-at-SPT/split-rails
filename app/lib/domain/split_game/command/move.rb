module Domain
  module SplitGame
    module Command
      class Move
        include Errors

        def initialize(game: nil, player: nil)
          raise GameRequiredError if game.nil?
          raise PlayerRequiredError if player.nil?

          @game = game
          @player = player

          raise NotAiPlayerError, 'The player is not an AI player' unless @player['role'].in? %w[ai test_dummy]

          unless @player['id'] == @game.current_player['id']
            raise NotCurrentPlayerError,
                  "Current player: #{@game.current_player['id']}"
          end

          # FIXME: Temporarily print the game data for debugging
          pp "game id: #{@game.id}"
          pp "game phase: #{@game.game_phase}"
          pp "current player: #{@game.current_player['nickname']}"
          pp "incoming player: #{@player['nickname']}"
        end

        def call
          # HACK: Workaround for running test
          return if @player['role'] == 'test_dummy'

          case @game.game_phase
          when 'build_map'
            raise GamePhaseError, 'The game is in build_map phase, and currently not support'
          when 'game_over'
            raise GamePhaseError, 'The game is over'
          when 'game_interrupted'
            raise GamePhaseError, 'The game is over(Interrupted)'
          when 'place_stack'
            place_stack
          when 'split_stack'
            split_stack
          else
            raise GamePhaseError, 'Invalid game phase'
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
    end
  end
end
