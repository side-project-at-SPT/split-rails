class Rack::Attack

  # throttle request to 100 requests per 5 minutes
  throttle('req/ip', limit: 100, period: 5.minutes) do |req|
    if req.path.start_with?('/assets') # Ignore assets requests
      req.ip
    end
  end


  # Ban IPs that are making too many requests in a short period of time
  # Ban if user login 10 times in 1 minute, for 5 minutes
  Rack::Attack.blocklist('blocklist') do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 10, findtime: 1.minute, bantime: 5.minutes) do
      if req.path == '/api/v1/login' && req.post?
        req.ip
      end
    end
  end
end
