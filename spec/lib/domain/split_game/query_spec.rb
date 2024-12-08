require 'rails_helper'

RSpec.describe Domain::SplitGame::Query do
  let(:room) { Room.create }
  let(:player1) { Visitor.create(name: 'player1', password: 'password') }
  let(:player2) { Visitor.create(name: 'player2', password: 'password') }
  let(:game) { room.start_new_game(seed: 1) }
  before do
    player1.update(preferences: { 'nickname' => 'player1' })
    player2.update(preferences: { 'nickname' => 'player2' })
    room.players << player1
    room.players << player2
  end

  describe '::ShowBoundary' do
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

  describe '::ShowAvailableSplitAction' do
    before do
      pastures = game.game_data['pastures']
      pastures.find { |pasture| pasture['x'] == 4 && pasture['y'] == 3 }['stack'] = {
        'color' => 'blue',
        'amount' => 8
      }
      pastures.find { |pasture| pasture['x'] == 3 && pasture['y'] == 4 }['stack'] = {
        'color' => 'blue',
        'amount' => 8
      }
      pastures.find { |pasture| pasture['x'] == 3 && pasture['y'] == 6 }['stack'] = {
        'color' => 'red',
        'amount' => 16
      }
      game.steps << GameStep.new(
        game:,
        step_number: 2,
        step_type: 'place_stack',
        current_player_index: 1,
        pastures:,
        game_phase: 'split_stack'
      )
      # game.update
    end

    xit 'shows the available split action' do
      # pp game.steps
      # pp game.reload.game_data['pastures']
      described_class::ShowAvailableSplitAction.new(game:).call.eql?(true)
    end
  end
end
