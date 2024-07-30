module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :load_jwt_request
      rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

      # force response to be JSON
      before_action do
        request.format = :json
      end

      def render_parameter_missing(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      private

      def load_jwt_request
        if (user_id = cookies.encrypted['_split_session']&.dig('user_id'))
          @user = Visitor.find_by(id: user_id)
          if @user
            @jwt_request = { 'sub' => @user.id }
          else
            render json: { error: 'Failed to authenticate' }, status: :unauthorized
          end
        else
          header = request.headers['Authorization']
          return render json: { error: 'Failed to authenticate' }, status: :unauthorized unless header

          decoded = header.gsub(/^Bearer /, '')

          begin
            @jwt_request = Api::JsonWebToken.decode(decoded)
          rescue JWT::DecodeError
            render json: { error: 'Failed to authenticate' }, status: :unauthorized
          end
        end
      end
    end
  end
end
