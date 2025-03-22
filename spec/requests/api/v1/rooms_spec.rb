# frozen_string_literal: true

require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Rooms", type: :request do
  let(:user) { Visitor.new_visitor }
  let(:room) { Room.create(name: 'room') }
  let(:bot) { Bot.create(owner: user, name: 'bot', webhook_url: 'https://localhost:3000/mybot/c8763') }
  let :Authorization do
    payload = { sub: user.id }
    token = Api::JsonWebToken.encode payload

    "Bearer #{token}"
  end

  path "/api/#{version}/rooms" do
    get '查詢房間列表' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      # consumes 'application/json'
      produces 'application/json'
      # parameter name: :user, in: :body, schema: {
      #   type: :object,
      #   properties: {
      #     id: { type: :string },
      #     password: { type: :string }
      #   }
      # }

      response 200, 'ok.' do
        xit
      end
    end

    post '開啟房間' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :room, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response 201, 'ok.' do
        xit
      end
    end
  end

  path "/api/#{version}/rooms/{id}" do
    get '查詢房間資料' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end

    patch '更新房間資料' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      let(:id) { room.id }
      let(:payload) { { name: 'new name' } }

      context 'when the user is the owner' do
        before { room.update(owner_id: user.id) }

        response 200, 'ok.' do
          run_test!
        end

        response 404, 'not found.' do
          let(:id) { 'invalid' }

          run_test!
        end
      end

      response 401, 'unauthorized.' do
        let(:Authorization) { nil }

        run_test!
      end

      response 403, 'forbidden.' do
        run_test!
      end
    end
  end

  path "/api/#{version}/rooms/{id}/close" do
    let(:id) { room.id }

    post '關閉房間' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        before { room.update(owner_id: user.id) }

        run_test!
      end

      response 404, 'not found.' do
        let(:id) { 'invalid' }

        run_test!
      end

      response 401, 'unauthorized.' do
        let(:Authorization) { nil }

        run_test!
      end

      response 403, 'forbidden.' do
        run_test!
      end

      context 'when the user is admin' do
        before { user.role_admin! }

        response 200, 'ok.' do
          run_test!
        end
      end
    end
  end

  path "/api/#{version}/rooms/{id}/knock-knock" do
    let(:id) { room.id }

    get '取得加入房間 token' do
      tags 'Rooms'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        run_test! do |response|
          expect(JSON.parse(response.body)).to have_key('token')
          expect(Api::JsonWebToken.decode(JSON.parse(response.body)['token'])['sub']).to eq(room.id)
        end
      end

      response 404, 'not found.' do
        let(:id) { 'invalid' }

        run_test!
      end

      response 401, 'unauthorized.' do
        let(:Authorization) { nil }

        run_test!
      end

      response 422, 'unprocessable entity. see response.error.' do
        before do
          players = 4.times.map { Visitor.new_visitor }
          players.each { |player| room.players << player }
        end

        run_test!
      end
    end
  end

  path "/api/#{version}/rooms/{id}/bots" do
    let(:id) { room.id }
    before { room.players << user }

    post '新增 AI 玩家' do
      tags 'Rooms'
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        before { bot.online! }

        run_test! do |response|
          expect(JSON.parse(response.body)).to have_key('ai_player_id')
        end
      end

      response 404, 'not found.' do
        let(:id) { 'invalid' }

        run_test!
      end

      response 401, 'unauthorized.' do
        let(:Authorization) { nil }

        run_test!
      end

      response 422, 'unprocessable entity. see response.error.' do
        before do
          players = 4.times.map { Visitor.new_visitor }
          players.each { |player| room.players << player }
        end

        run_test!
      end
    end
  end

  path "/api/#{version}/rooms/{id}/ai_players" do
    let(:id) { room.id }

    post '(即將棄用)新增 AI 玩家' do
      tags 'Deprecated'
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        before do
          room.players << user
          bot.online!
        end

        run_test! do |response|
          expect(JSON.parse(response.body)).to have_key('warning')
          expect(JSON.parse(response.body)).to have_key('ai_player_id')
        end
      end
    end
  end
end
