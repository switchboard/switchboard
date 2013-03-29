load 'deploy'
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }

load 'deploy/assets' # Asset pipeline compilation
load 'config/deploy' # remove this line to skip loading any of the default tasks