require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'

Mongoid.load! 'mongoid.config'

QUEUE = []
val = 0

Thread.new do
  while true do
    sleep 1
    next if QUEUE.empty?
    QUEUE.shift
  end
end

# Routes (Apparently Sinatra doesn't do controllers)

get '/' do
  val += 1
  QUEUE << val
  "Hello World! #{QUEUE}"
end
