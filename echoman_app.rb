require 'json'


class EchomanApp < Sinatra::Base
  def self.get_or_post(path, opts={}, &block)
    get(path, opts, &block)
    post(path, opts, &block)
  end

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post]
    end
  end

  before do
    content_type :json
  end

  post '/echo' do
    if params[:json]
      params[:json]
    else
      status '400'
      {error: '"json" param not found'}.to_json
    end
  end

  get_or_post '/' do
    {greeting: "Hello #{request.ip}.  How are you? I am fine. What is your name? My name is Jerry.."}.to_json
  end

  get_or_post '/error/:code' do
    status params[:code]
    {message: 'Responded with requested status code'}.to_json
  end

  get_or_post '/object/*' do
    key_vals = params[:splat].first.split('/')
    key_vals << nil if (key_vals.size%2) != 0
    Hash[*key_vals.flatten].to_json
  end

  get_or_post '/array/*' do
    params[:splat].first.split('/').to_json
  end

  get_or_post '/gist/:gist_id' do
    begin
      gist = RestClient.get("https://raw.github.com/gist/#{params[:gist_id]}")
      gist
    rescue => e
      status '500'
      {error: "unable to retrieve gist #{params[:gist_id]}"}.to_json
    end
  end
end
