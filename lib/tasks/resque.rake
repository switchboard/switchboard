require 'resque/tasks'
require 'resque/failure/multiple'
require 'resque/failure/redis'

# Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
# Resque::Failure.backend = Resque::Failure::Multiple

# Resque tasks need entire Rails environment
task "resque:setup" => :environment