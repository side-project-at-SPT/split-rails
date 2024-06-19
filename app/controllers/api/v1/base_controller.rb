module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :load_jwt_request
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      def render_parameter_missing(exception)
        render json: { errors: exception.message }, status: :bad_request
      end

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
