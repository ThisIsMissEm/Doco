require 'rack/lobster'
require 'lib/doco'

# Rack config
use Rack::CommonLogger

use Doco::App
use Rack::Static, :urls => ['/stylesheets', '/javascript', '/favicon.ico'], :root => "public"

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end
 
#
# Create and configure a hex instance
#

run Rack::Lobster.new