module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info { 'Connection#connect' }
    end

    private

    def find_verified_user
      # return 'guest_' + SecureRandom.hex(1) + Time.now.to_i.to_s if Rails.env.development?
      # if current_user = User.find_by(id: cookies.signed[:user_id])
      #   current_user
      # else
      #   reject_unauthorized_connection
      # end

      Rails.logger.info { 'Connection#find_verified_user' }
      Rails.logger.info { 'try to decode the token' }
      auth_token = request.headers['Authorization']

      if auth_token.nil?
        Rails.logger.info { 'No Authorization header' }
        # return reject_unauthorized_connection
      else
        token = auth_token.gsub(/^Bearer /, '')
        decoded_token = Api::JsonWebToken.decode(token)
        Rails.logger.info { "decoded_token: #{decoded_token}" }
        Rails.logger.info { 'try to find the user' }

        if current_user = Visitor.find_by(id: decoded_token[:sub])
          return current_user
        end
      end

      # reject_unauthorized_connection
      'guest_' + SecureRandom.hex(10) + Time.now.to_i.to_s
    rescue JWT::VerificationError, JWT::DecodeError => e
      Rails.logger.error { "Error decoding the token: #{e.message}" }
      reject_unauthorized_connection
    end
  end
end
