$LOAD_PATH.unshift '.'
require 'lib/router'
use Rack::ShowExceptions
run App.new
