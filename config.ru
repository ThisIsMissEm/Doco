require 'lib/doco'
 
# Rack config
use Rack::Static, :urls => ['/stylesheets', '/javascript', '/favicon.ico'], :root => "public"
use Rack::CommonLogger
 
if ENV['RACK_ENV'] == 'development'
  use Rack::ShowExceptions
end
 
#
# Create and configure a hex instance
#
run Doco::Server.new({
  :root => Dir.pwd
})