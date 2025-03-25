require 'rails_helper'

RSpec.describe Domain::SplitGame::Command::Play do
  let(:room) { Room.create(name: 'room') }
  let(:user) { Visitor.new_visitor }
  let(:bot) { Bot.create(owner: user, name: 'bot', webhook_url: 'https://localhost:3000/mybot/c8763') }
  let(:player) { Visitor.find(bot.join_room(room)) }
  let(:another_player) { Visitor.new_visitor(role: :test_dummy) }
  let(:game) do
    player.touch
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
