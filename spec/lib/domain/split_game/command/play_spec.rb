require 'rails_helper'

RSpec.describe Domain::SplitGame::Command::Play do
  let(:room) { Room.create(name: 'room') }
  let(:user) { Visitor.new_visitor }
  let(:bot) { Bot.create(owner: user, name: 'bot', webhook_url: 'https://localhost:3000/mybot/c8763') }
  let(:bot_player) { Visitor.find(bot.join_room(room)) }
  let(:another_player) { Visitor.new_visitor(role: :test_dummy) }
  let(:game) do
    bot_player.touch
    room.players << another_player
    room.save
    room.start_new_game(seed: 0)
  end

  before do
    mock_http = double('HTTPX')
    mock_response = double('Response')

    allow(HTTPX).to receive(:with).and_return(mock_http)
    allow(mock_http).to receive(:with).and_return(mock_http)
    allow(mock_http).to receive(:get).and_return(mock_response)
    allow(mock_response).to receive(:json).and_return({ 'ip' => '8.8.8.8', 'city' => 'Mountain View' })
  end

  it 'places a stack' do
    expect do
      described_class.new(game:, player: bot_player).call
    end.not_to raise_error

    expect(game.steps.last.step_type).to eq('place_stack')
  end
end
