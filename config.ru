$stdout.sync = true
require './app'

use Rack::Cache,
  :metastore   => 'file:tmp/cache/rack/meta',
  :entitystore => 'file:tmp/cache/rack/body'

run Sinatra::Application
