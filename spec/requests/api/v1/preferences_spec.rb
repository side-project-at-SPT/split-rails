# frozen_string_literal: true

require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Preferences", type: :request do
  # let :Authorization do
  #   payload = { sub: user.id }
  #   token = Api::JsonWebToken.encode payload

  #   "Bearer #{token}"
  # end

  path "/api/#{version}/preferences" do
    patch '更新偏好設定' do
      tags 'Users/Preferences'
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :preferences, in: :body, schema: {
        type: :object,
        properties: {
          nickname: { type: :string }
        }
      }

      response 200, 'ok.' do
        xit
      end

      response 304, 'not modified.' do
        xit
      end
    end

    get '查詢偏好設定' do
      tags 'Users/Preferences'
      # description ""
      security [bearerAuth: []]
      produces 'application/json'

      response 200, 'ok.' do
        xit
      end
    end
  end
end
