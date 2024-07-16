module Api
  module V1
    class UsersController < BaseController
      require 'net/http'

      skip_before_action :load_jwt_request, only: %i[create login_via_gaas_token]

      # GET /api/v1/users
      def index
        @users = Visitor.all

        render status: :ok
      end

      def login_via_gaas_token
        # auth0_token = params.fetch(:token)
        # via bearer token
        reg = /\ABearer .+\z/
        auth0_token = request.headers['Authorization'].match(reg).to_s.split(' ')[1]
        # TODO: parse auth0_token
        Rails.logger.warn { 'TODO: validate auth0_token' }

        # use auth0_token to get user info
        # api endpoint: https://api.gaas.waterballsa.tw/users/me
        # headers
        # Authorization
        # Bearer {auth0_token}

        uri = URI('https://api.gaas.waterballsa.tw/users/me')
        req = Net::HTTP::Get.new uri
        req['Authorization'] = "Bearer #{auth0_token}"
        res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
          http.request req
        end

        unless res.code.to_i.between?(200, 299)
          Rails.logger.warn { "Failed to get user info: #{res.code}" }
          begin
            message = JSON.parse(res.body)
            Rails.logger.debug { message }
          rescue StandardError => e
            Rails.logger.error { e }
          end
        end

        user = Visitor.find_or_initialize_by(name: res['id'])
        if user.new_record?
          user.password = SecureRandom.alphanumeric(16)
          user.save!
          user.update!(preferences: { nickname: res['nickname'] || 'player from gaas' })
        end

        Rails.logger.debug { user.inspect }

        render json: { token: user.encode_jwt }, status: :ok
      end

      # POST /api/v1/users
      def create
        # user_params = params.require(:user).permit(:name, :password)
        # name = user_params.fetch(:name)
        # password = user_params.fetch(:password)
        name = params.fetch(:name)
        password = params.fetch(:password)

        user = Visitor.find_or_initialize_by(name:)

        if user.new_record?
          unless password.is_a?(String) && password.length >= 6
            return render json: { error: 'Password must be a string with at least 6 characters' },
                          status: :bad_request
          end
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
