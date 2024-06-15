json.extract! visitor, :id, :name, :password_digest, :created_at, :updated_at
json.url visitor_url(visitor, format: :json)
