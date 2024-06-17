# frozen_string_literal: true

require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Games", type: :request do

  # let :Authorization do
  #   payload = { sub: user.id }
  #   token = Api::JsonWebToken.encode payload

  #   "Bearer #{token}"
  # end

  path "/api/#{version}/rooms/{room_id}/game" do
    post '開始遊戲' do
      tags "Games"
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :room_id, in: :path, type: :string

      response 201, 'ok.' do
        xit
      end
    end

    get '查詢目前遊戲狀態' do
      tags "Games"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :room_id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end

    delete '結束遊戲' do
      tags "Games"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :room_id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end
  end

  path "/api/#{version}/rooms/{room_id}/game/play-unit" do
    post '放入棋子' do
      tags "Games"
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :room_id, in: :path, type: :string
      parameter name: :play, in: :body, schema: {
        type: :object,
        properties: {
          x: { type: :integer },
          y: { type: :integer }
        }
      }

      response 200, 'ok.' do
        xit
      end
    end

  end

  path "/api/#{version}/rooms/{room_id}/game/split" do
    post '分配棋子' do
      tags "Games"
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :room_id, in: :path, type: :string
      parameter name: :split, in: :body, schema: {
        type: :object,
        properties: {
          origin_x: { type: :integer },
          origin_y: { type: :integer },
          target_x: { type: :integer },
          target_y: { type: :integer },
          amount: { type: :integer }
        }
      }

      response 200, 'ok.' do
        xit
      end
    end
  end
end
