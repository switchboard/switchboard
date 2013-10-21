require 'resque/tasks'

# Resque tasks need entire Rails environment
task "resque:setup" => :environment