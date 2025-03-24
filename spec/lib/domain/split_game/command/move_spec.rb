require 'rails_helper'

RSpec.describe Domain::SplitGame::Command::Move do
  let(:room) { Room.create }
  let(:player) { Visitor.new_visitor }
  let(:game) do
    room.players << player
    room.save
    room.start_new_game
  end

  context 'when the game is not given' do
    it 'raise an error' do
      expect do
        described_class.new.call
      end.to raise_error(Domain::SplitGame::Command::Errors::GameRequiredError)
    end
  end

  context 'when the player is not given' do
    it 'raise an error' do
      expect do
        described_class.new(game:).call
      end.to raise_error(Domain::SplitGame::Command::Errors::PlayerRequiredError)
    end
  end

  context 'when the player is not an AI player' do
    it 'does not play' do
      expect do
        described_class.new(game:, player:).call
      end.to raise_error(Domain::SplitGame::Command::Errors::NotAiPlayerError)
    end
  end

  context 'when the player is AI' do
    before do
      player.update(role: 'ai')
    end

    context 'when the game is finished' do
      before do
        game.close_by(user: 'test')
      end

      it 'raise an error' do
        expect do
          described_class.new(game:, player:).call
        end.to raise_error(Domain::SplitGame::Command::Errors::GamePhaseError)
      end
    end

    context 'when the player is not the current player' do
      let(:another_player) { Visitor.new_visitor(role: 'ai') }

      it 'does not play' do
        expect do
          described_class.new(game:, player: another_player).call
        end.to raise_error(Domain::SplitGame::Command::Errors::NotCurrentPlayerError)
      end
    end
  end
end
