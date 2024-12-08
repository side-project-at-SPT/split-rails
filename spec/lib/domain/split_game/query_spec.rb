require 'rails_helper'

RSpec.describe Domain::SplitGame::Query do
  describe '::ShowBoundary' do
    let(:room) { Room.create }
    let(:player1) { Visitor.create }
    let(:player2) { Visitor.create }
    let(:game) { room.start_new_game(seed: 1) }
    before do
      room.players << player1
      room.players << player2
    end

    let(:result) do
      [[0, 4, 0], [1, 4, 0], [1, 5, 0], [2, 5, 0], [3, 5, 0], [3, 6, 0],
       [2, 7, 0], [3, 7, 0], [4, 6, 0], [5, 6, 0], [4, 5, 0], [5, 4, 0],
       [6, 3, 0], [7, 3, 0], [8, 2, 0], [7, 2, 0], [6, 2, 0], [6, 1, 0],
       [7, 0, 0], [6, 0, 0], [5, 0, 0], [5, 1, 0], [4, 2, 0], [3, 2, 0],
       [2, 3, 0]]
    end

    it 'shows the boundary' do
      described_class::ShowBoundary.new(game:).call.eql?(result)
    end
  end
end
