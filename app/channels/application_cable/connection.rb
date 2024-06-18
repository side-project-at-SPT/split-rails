module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info { 'Connection#connect' }
      # subscribe to the public channel
      # stream_from 'public'
    end

    private

    def find_verified_user
      # if current_user = User.find_by(id: cookies.signed[:user_id])
      #   current_user
      # else
      #   reject_unauthorized_connection
      # end

      Rails.logger.info { 'Connection#find_verified_user' }
      Rails.logger.info { 'try to decode the token' }
      token = request.headers['Authorization'].gsub(/^Bearer /, '')
      decoded_token = Api::JsonWebToken.decode(token)
      Rails.logger.info { "decoded_token: #{decoded_token}" }
      Rails.logger.info { 'try to find the user' }

      if current_user = Visitor.find_by(id: decoded_token[:visitor_id])
        current_user
      else
        # reject_unauthorized_connection
        'guest_' + SecureRandom.hex(10) + Time.now.to_i.to_s
      end
    end
  end
end
