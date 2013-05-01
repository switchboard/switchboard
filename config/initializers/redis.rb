$redis_server = Redis.new(host: 'localhost', port: 6379)
$redis = Redis::Namespace.new("sb#{Rails.env[0..2]}", redis: $redis_server)