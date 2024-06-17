module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :load_jwt_request

      private

      def load_jwt_request
        header = request.headers['Authorization']
        return render json: { errors: 'Failed to authenticate' }, status: :unauthorized unless header

        decoded = header.gsub(/^Bearer /, '')

        begin
          @jwt_request = Api::JsonWebToken.decode(decoded)
        rescue JWT::DecodeError
          return render json: { errors: 'Failed to authenticate' }, status: :unauthorized
        end
      end
    end
  end
end
