require 'rails_helper'

RSpec.describe Domain::Common do
  let(:pastures_1x5) do
    5.times.map do |i|
      HashWithIndifferentAccess.new(
        { x: 1, y: i, is_blocked: false, stack: { color: 'blank', amount: 0 } }
      )
    end
  end
  let(:colors) { %w[red blue] }
  let(:current_player_index) { 0 }

  describe '.next_available_player_index' do
    context 'when both players can play' do
      let(:pastures) do
        pastures_1x5.find { |pasture| pasture[:y] == 0 }.then do |pasture|
          pasture[:stack][:color] = 'red'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5.find { |pasture| pasture[:y] == 4 }.then do |pasture|
          pasture[:stack][:color] = 'blue'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5
      end

      it 'returns blue index(1)' do
        next_available_player_index = described_class.next_available_player_index(
          current_player_index:, colors:, pastures:
        )
        expect(next_available_player_index).to eq(1)
      end
    end

    context 'when red player can play' do
      let(:pastures) do
        pastures_1x5.find { |pasture| pasture[:y] == 3 }.then do |pasture|
          pasture[:stack][:color] = 'red'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5.find { |pasture| pasture[:y] == 4 }.then do |pasture|
          pasture[:stack][:color] = 'blue'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5
      end

      it 'returns red index(0)' do
        next_available_player_index = described_class.next_available_player_index(
          current_player_index: 1, colors:, pastures:
        )
        expect(next_available_player_index).to eq(0)
      end
    end

    context 'when blue player can play' do
      let(:pastures) do
        pastures_1x5.find { |pasture| pasture[:y] == 0 }.then do |pasture|
          pasture[:stack][:color] = 'red'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5.find { |pasture| pasture[:y] == 1 }.then do |pasture|
          pasture[:stack][:color] = 'blue'
          pasture[:stack][:amount] = 16
        end
        pastures_1x5
      end

      it 'returns blue index(1)' do
        next_available_player_index = described_class.next_available_player_index(
          current_player_index: 0, colors:, pastures:
        )
        expect(next_available_player_index).to eq(1)
      end
    end
  end
end
