# frozen_string_literal: true

require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Users", type: :request do

  # let :Authorization do
  #   payload = { sub: user.id }
  #   token = Api::JsonWebToken.encode payload

  #   "Bearer #{token}"
  # end

  path "/api/#{version}/users" do
    post '登入' do
      tags "Users"
      # description ""
      # security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          id: { type: :string },
          password: { type: :string }
        }
      }

      response 200, 'ok.' do
        xit
      end
    end
  end

  path "/api/#{version}/me" do
    post '查詢個人資料' do
      tags "Users"
      # description ""
      # security [bearerAuth: []]
      produces 'application/json'

      response 200, 'ok.' do
        xit
      end
    end
  end
end
