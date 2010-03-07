require 'rack/lobster'
require File.join(File.dirname(__FILE__), "..", "lib", "doco")

# Rack config
use Rack::CommonLogger

use Rack::Static, :urls => ['/stylesheets', '/javascript', '/favicon.ico', '/404.html'], :root => "public"
use Rack::Doco, :url => '/docs/'

if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end
 
#
# Create and configure a hex instance
#

run Rack::Lobster.new