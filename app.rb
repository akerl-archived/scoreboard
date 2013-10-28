require 'sinatra'

get %r{/hello/([a-zA-Z-]+)?} do |name|
    "Hello #{params[:name]}!"
end

