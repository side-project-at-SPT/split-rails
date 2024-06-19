module Api
  module V1
    class UsersController < BaseController
      skip_before_action :load_jwt_request, only: :create

      # GET /api/v1/users
      def index
        online_users_count = $redis.hlen('lobby_channel_users')
        online_users = $redis.hgetall('lobby_channel_users').map { |id, name| { id:, name: } }

        render json: { online_users_count:, online_users: }, status: :ok
      end

      # POST /api/v1/users
      def create
        # user_params = params.require(:user).permit(:name, :password)
        # name = user_params.fetch(:name)
        # password = user_params.fetch(:password)
        name = params.fetch(:name)
        password = params.fetch(:password)

        return render json: { error: 'Password must be a string with at least 6 characters' }, status: :bad_request unless password.is_a?(String) && password.length >= 6

        user = Visitor.find_or_initialize_by(name: name)

        if user.new_record?
          user.password = password
          user.save!

          return render json: { token: user.encode_jwt }, status: :created
        end

        return render json: { token: user.encode_jwt }, status: :ok if user.authenticate(password)

        render json: { error: 'Invalid name or password' }, status: :unauthorized
      end

      # GET /api/v1/me
      def show
        user = Visitor.find(@jwt_request['sub'])

        render json: { name: user.name }, status: :ok
      end
    end
  end
end
