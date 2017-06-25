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

# Model

class WebData
  include Mongoid::Document

  field :url, type: String
  field :html, type: String, default: "pending"
  validates :url, presence: true
end

# Routes (Apparently Sinatra doesn't do controllers)

namespace '/api' do
  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
  end

  get '/index' do # Index
    WebData.all.to_json
  end

  get '/:id' do |id| # Show
    data_object = WebData.where(id: id).first
    halt(404, { message:'Object Not Found'}.to_json) unless data_object
    data_object.to_json
  end

  post '/' do # Create
    data_object = WebData.new(JSON.parse(request.body.read))
    id = data_object._id.to_s

    if data_object.save
      response.headers['Location'] = "#{base_url}/api/#{id}"
      status 201
    else
      status 422
    end
  end
end

get '/' do
  val += 1
  QUEUE << val
  "Hello World! #{QUEUE}"
end
