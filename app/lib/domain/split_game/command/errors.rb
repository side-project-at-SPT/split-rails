module Domain
  module SplitGame
    module Command
      module Errors
        class GameRequiredError < StandardError; end
        class PlayerRequiredError < StandardError; end
        class GameIsFinishedError < StandardError; end
        class NotCurrentPlayerError < StandardError; end
        class NotAiPlayerError < StandardError; end
      end
    end
  end
end
