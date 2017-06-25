require 'sinatra'
require 'sinatra/namespace'
require 'open-uri'
require 'mongoid'

Mongoid.load! 'mongoid.config'

QUEUE = []

Thread.new do
  while true do
    sleep 1
    next if QUEUE.empty?
    scrape_html(QUEUE.shift)
  end
end

def scrape_html(id)
  web_data = WebData.where(id: id).first
  scraped_html = open(web_data.url).read.encode('UTF-8') # UTF-8 Keeps MongoDB happy

  web_data.update_attribute(:html, scraped_html)
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
    web_data = WebData.where(id: id).first
    halt(404, { message:'Object Not Found'}.to_json) unless web_data
    web_data.to_json
  end

  post '/' do # Create
    web_data = WebData.new(JSON.parse(request.body.read))
    id = web_data._id.to_s

    if web_data.save
      QUEUE << web_data.id

      response.headers['Location'] = "#{base_url}/api/#{id}"
      status 201
    else
      status 422
    end
  end
end

get '/' do
  "Hello World! #{QUEUE}"
end
