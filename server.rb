require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'

Mongoid.load! 'mongoid.config'

# Routes (Apparently Sinatra doesn't do controllers)

get '/' do
  "Hello World!"
end
