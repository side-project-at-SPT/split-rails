# frozen_string_literal: true

require 'swagger_helper'
version = 'v1'

RSpec.describe "#{version}/Rooms", type: :request do

  # let :Authorization do
  #   payload = { sub: user.id }
  #   token = Api::JsonWebToken.encode payload

  #   "Bearer #{token}"
  # end

  path "/api/#{version}/rooms" do
    get '查詢房間列表' do
      tags "Rooms"
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
      tags "Rooms"
      # description ""
      security [bearerAuth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :room, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
        }
      }

      response 201, 'ok.' do
        xit
      end
    end
  end

  path "/api/#{version}/rooms/{id}" do
    get '查詢房間資料' do
      tags "Rooms"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end

    put '加入房間' do
      tags "Rooms"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end

    delete '離開房間' do
      tags "Rooms"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end
  end

  path "/api/#{version}/rooms/{id}/close" do
    post '關閉房間' do
      tags "Rooms"
      # description ""
      security [bearerAuth: []]
      produces 'application/json'
      parameter name: :id, in: :path, type: :string

      response 200, 'ok.' do
        xit
      end
    end
  end
end
