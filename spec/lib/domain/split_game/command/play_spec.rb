require 'rails_helper'

RSpec.describe Domain::SplitGame::Command::Play do
  let(:room) { Room.create }
  let(:player) { Visitor.new_visitor(role: :ai) }
  let(:another_player) { Visitor.new_visitor(role: :test_dummy) }
  let(:game) do
    room.players << player
    room.players << another_player
    room.save
    room.start_new_game
  end

  it 'places a stack' do
    expect do
      described_class.new(game:, player:).call
    end.not_to raise_error

    expect(game.steps.last.step_type).to eq('place_stack')
  end
end
