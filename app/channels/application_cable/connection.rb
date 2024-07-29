module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      if (user_id = cookies.encrypted['_split_session']&.dig('user_id'))
        self.current_user = Visitor.find_by(id: user_id)
      else
        self.current_user = find_verified_user
        logger.add_tags "#{current_user.id}, #{current_user.nickname}"
      end
    end

    def disconnect
      # Any cleanup work needed when the cable connection is cut.
      $redis.del("used:#{current_user.id}:gaas_auth0_token")
    end

    private

    def find_verified_user
      Rails.logger.debug { 'Connection#find_verified_user' }
      Rails.logger.debug { 'try to decode the token' }
      auth_token = request.GET[:token]

      if auth_token.nil?
        Rails.logger.debug { 'No Authorization header' }
        return reject_unauthorized_connection
      else
        token = auth_token.gsub(/^Bearer /, '')
        decoded_token = Api::JsonWebToken.decode(token)
        Rails.logger.debug { "decoded_token: #{decoded_token}" }
        Rails.logger.debug { 'try to find the user' }

        if (current_user = Visitor.find_by(id: decoded_token[:sub]))
          $redis.set("used:#{current_user.id}:gaas_auth0_token", token) if decoded_token[:gaas_auth0_token]
          return current_user
        end
      end

      reject_unauthorized_connection
    rescue JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.error { "Error decoding the token: #{e.message}" }
      reject_unauthorized_connection
    end
  end
end
