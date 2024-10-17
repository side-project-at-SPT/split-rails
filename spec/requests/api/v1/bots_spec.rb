require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Bots", type: :request do
  let(:user) { Visitor.new_visitor }
  let :Authorization do
    payload = { sub: user.id }
    token = Api::JsonWebToken.encode payload

    "Bearer #{token}"
  end

  path "/api/#{version}/bots" do
    get '查詢所有機器人' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'

      response 200, 'ok.' do
        before { Bot.create(name: 'bot1', owner: user, webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1) }
        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }

        run_test!
      end
    end

    post '註冊機器人' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'bot1' },
          webhook_url: { type: :string, example: 'https://localhost:3000/mybot/c8763' },
          concurrent_number: { type: :integer, example: 1 }
        }
      }

      response 201, 'created.' do
        let(:payload) { { name: 'bot1', webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1 } }

        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }
        let(:payload) {}

        run_test!
      end
    end
  end

  path "/api/#{version}/bots/{id}" do
    get '查詢機器人' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        before { Bot.create(name: 'bot1', owner: user, webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1) }
        let(:id) { Bot.first.id }

        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }
        let(:id) { '1' }

        run_test!
      end

      response 404, 'Not Found' do
        let(:id) { '1' }

        run_test!
      end
    end

    put '更新機器人(replace)' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'bot1' },
          webhook_url: { type: :string, example: 'https://localhost:3000/mybot/c8763' },
          concurrent_number: { type: :integer, example: 1 }
        }
      }

      response 200, 'ok.' do
        before { Bot.create(name: 'bot1', owner: user, webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1) }
        let(:id) { Bot.first.id }
        let(:payload) { { name: 'bot2', webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1 } }

        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }
        let(:id) { '1' }
        let(:payload) {}

        run_test!
      end

      response 403, 'Forbidden' do
        let(:id) { 999 }
        let(:payload) {}

        run_test!
      end
    end

    patch '更新機器人(partial)' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :string
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'bot1' },
          webhook_url: { type: :string, example: 'https://localhost:3000/mybot/c8763' },
          concurrent_number: { type: :integer, example: 1 }
        }
      }

      response 200, 'ok.' do
        before { Bot.create(name: 'bot1', owner: user, webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1) }
        let(:id) { Bot.first.id }
        let(:payload) { { name: 'bot2' } }

        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }
        let(:id) { '1' }
        let(:payload) {}

        run_test!
      end

      response 404, 'Not Found' do
        let(:id) { '1' }
        let(:payload) {}

        run_test!
      end
    end

    delete '刪除機器人' do
      tags 'Bots'
      # description ""
      security [bearerAuth: []]
      parameter name: :id, in: :path, type: :string

      response 204, 'ok.' do
        before { Bot.create(name: 'bot1', owner: user, webhook_url: 'https://localhost:3000/mybot/c8763', concurrent_number: 1) }
        let(:id) { Bot.first.id }

        run_test!
      end

      response 401, 'Unauthorized' do
        let(:Authorization) { nil }
        let(:id) { '1' }

        run_test!
      end

      response 403, 'Forbidden' do
        let(:id) { 999 }

        run_test!
      end
    end
  end
end
