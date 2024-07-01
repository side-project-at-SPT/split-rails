require 'rails_helper'

RSpec.describe Step, type: :model do
  let(:room) { Room.create!(name: SecureRandom.hex) }
  let(:player_a) { Visitor.create!(name: 'a', password: SecureRandom.alphanumeric) }
  let(:player_b) { Visitor.create!(name: 'b', password: SecureRandom.alphanumeric) }
  let(:game) do
    room.players << player_a << player_b
    room.start_new_game
    room.games.last
  end

  describe 'initialize_map_by_system' do
    it 'initializes the map' do
      # NOTE: Current version of the game will build the map automatically
      #
      # expect(Game.find(game.id).pastures.size).to eq(0)
      # expect(Game.find(game.id).game_phase).to eq('build map')
      # game.initialize_map_by_system

      expect(Game.find(game.id).pastures.size).to eq(16 * 2)
      expect(Game.find(game.id).game_phase).to eq('place_stack')
    end
  end

  describe 'play' do
    it 'places the stack' do
      # game.initialize_map_by_system

      # ignore fail and retry until the stack is placed
      loop do
        break if game.random_place_stack.errors.empty?
      end

      expect(
        Game.find(game.id).pastures.count { |pasture| pasture['stack']['amount'].positive? }
      ).to eq(1)
      expect(Game.find(game.id).game_phase).to eq('place_stack')

      # when second player places the stack

      loop do
        break if game.random_place_stack.errors.empty?
      end

      expect(
        Game.find(game.id).pastures.count { |pasture| pasture['stack']['amount'].positive? }
      ).to eq(2)
      expect(Game.find(game.id).game_phase).to eq('split_stack')
    end
  end

  describe 'split' do
    it 'splits the stack' do
      game.initialize_map_by_system

      # ignore fail and retry until the stack is placed
      loop do
        break if game.random_place_stack.errors.empty?
      end

      loop do
        break if game.random_place_stack.errors.empty?
      end

      expect(Game.find(game.id).game_phase).to eq('split_stack')

      # ignore fail and retry until the stack is splitted
      loop do
        break if game.random_split_stack.errors.empty?
      end

      expect(
        Game.find(game.id).pastures.count { |pasture| pasture['stack']['amount'].positive? }
      ).to eq(3)

      # After split, the sum of the stack amount should be the same
      expect(
        Game
          .find(game.id)
          .pastures
          .group_by { |pasture| pasture['stack']['color'] }
          .select { |k, v| v.size > 1 && k != 'blank' }
          .values[0]
          .sum(0) { |v| v['stack']['amount'].to_i }
      ).to eq(16)
      expect(Game.find(game.id).game_phase).to eq('split_stack')
    end
  end
end
