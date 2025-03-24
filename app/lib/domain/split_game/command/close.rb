module Domain
  module SplitGame
    module Command
      class Close
        include Errors

        def initialize(game: nil, invoker: nil)
          raise GameRequiredError if game.nil?

          @game = game
          @invoker = invoker || 'system'
        end

        def call
          case @game.game_phase
          when 'game_over'
            Rails.logger.warn { 'The game is already over' }
          when 'game_interrupted'
            Rails.logger.warn { 'The game is already over(Interrupted)' }
          else
            game_over_step = @game.steps.last.dup.then do |step|
              step.step_number += 1
              step.step_type = 'game_over'
              step.game_phase = 'game_over'
              step.action = { author: @invoker, action_name: 'game_over' }
              step
            end
            game_over_step.save!

            @game.steps << game_over_step
            @game.save!
          end

          @game
        end
      end
    end
  end
end
