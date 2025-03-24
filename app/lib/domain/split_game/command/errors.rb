module Domain
  module SplitGame
    module Command
      module Errors
        class GameRequiredError < StandardError; end
        class PlayerRequiredError < StandardError; end
        class NotCurrentPlayerError < StandardError; end
        class NotAiPlayerError < StandardError; end
        class GamePhaseError < StandardError; end
      end
    end
  end
end
