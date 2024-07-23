module Api
  class JsonWebToken
    BASE_ISSUER = ENV.fetch('ZEABUR_web_URL') { 'http://localhost:3000/' }
    GAAS_ISSUER = 'https://dev-1l0ixjw8yohsluoi.us.auth0.com/'.freeze
    GAAS_USERS_ME_API = 'https://api.gaas.waterballsa.tw/users/me'.freeze

    class << self
      def encode(payload, exp = 1.hours.from_now)
        payload[:exp] = exp.to_i
        payload[:iss] = BASE_ISSUER
        JWT.encode(payload, ENV.fetch('JWT_SECRET') { 'secret' })
      end

      def decode(token)
        # body = JWT.decode(token, ENV.fetch('JWT_SECRET') { 'secret' })[0]
        # HashWithIndifferentAccess.new body

        # 1. parse the token to get the header and the payload
        # 2. use different process to different Issuer

        # 1. parse the token to get the header and the payload
        payload, _header = JWT.decode(token, nil, false)

        # 2. use different process to different Issuer
        case payload['iss']
        when GAAS_ISSUER
          # try to get the decoded token from redis
          key = Digest::SHA256.hexdigest(token).prepend('gaas:auth0_token:')
          decoded = $redis.get(key)
          return JSON.parse(decoded) if decoded

          uri = URI(GAAS_USERS_ME_API)
          req = Net::HTTP::Get.new uri
          req['Authorization'] = "Bearer #{token}"
          res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
            http.request req
          end

          raise JWT::DecodeError.new(res.body) unless res.code.to_i.between?(200, 299)

          data = JSON.parse(res.body)
          name = data.fetch('id') # ensure the key exists
          _email = data['email']
          nickname = data['nickname'] || 'player from gaas'

          # TODO: take care of the id conflict
          user = Visitor.find_or_initialize_by(name:)
          if user.new_record?
            user.password = SecureRandom.alphanumeric(16)
            user.save!
            user.update!(preferences: { nickname: })
          end

          decoded = {
            'sub' => user.id,
            'gaas_auth0_token' => token
          }
          # use redis to cache the decoded token
          # key = Digest::SHA256.hexdigest(token).prepend('gaas:auth0_token:')
          $redis.set(key, decoded.to_json)
          $redis.expire(key, payload['exp'] - Time.now.to_i + 5) # 5 seconds earlier

          decoded
        when BASE_ISSUER
          body = JWT.decode(token, ENV.fetch('JWT_SECRET') { 'secret' })[0]
          HashWithIndifferentAccess.new body
        end
      end
    end
  end
end
