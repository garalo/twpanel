require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-twitter'
require 'twitter'

set :session_secret, 'secret12344321secret'

configure do
  enable :sessions
  
  use OmniAuth::Builder do
    #_ak_adem için keys for heroku
    provider :twitter, '1TEwFFzAyfDGoqKgs1kenF6Nh', 'IDUcFEFaN9J9eFgQBLCYfQ9R1bvfvgUyfROG4uMzI2MmoRNCtm', callback_url: "http://127.0.0.1:4567/auth/twitter/callback" # use ENV variables instead :)
    #_siyahgolge icin keys for local
    #provider :twitter, 'FMY49JTN57AiLxqtgbE4push7', 'MSv1ZdYRAJoq6RDcKGIEftqWtxrDoxntEQAj2l5dif7LVrrorp'
 end
end


def twitter
    Twitter::REST::Client.new do |config|
      config.consumer_key        = session[:consumer_key]
      config.consumer_secret     = session[:consumer_secret]
      config.access_token        = session[:access_token] 
      config.access_token_secret = session[:access_token_secret]
    end
  end



get '/' do
  @uname = session[:uname]
 # @image = session[:image]
  @screen_name = session[:screen_name]
  @consumer_key = session[:consumer_key]
  @consumer_secret = session[:consumer_secret]
  @access_token = session[:access_token] 
  @access_token_secret = session[:access_token_secret]
  
  # @oauth = session[:twitter_oauth]
  @timeline = twitter.home_timeline
  
  
  #@timeline = twitter.user_timeline(@uname, { count: 10 })
  
  erb :index
end

get '/auth/twitter/callback' do
 # session[:twitter_oauth] = env['omniauth.auth'][:credentials]
  session[:uname] = env['omniauth.auth']['extra']['raw_info']['screen_name']
  #session[:image] = env['omniauth.auth']['info']['image']
  session[:screen_name] = env['omniauth.auth']['extra']['raw_info']['name']
  session[:consumer_key] = env['omniauth.auth']['extra']['access_token'].consumer.key
  session[:consumer_secret] = env['omniauth.auth']['extra']['access_token'].consumer.secret
  session[:access_token] = env['omniauth.auth']['extra']['access_token'].params[:oauth_token]
  session[:access_token_secret] = env['omniauth.auth']['extra']['access_token'].params[:oauth_token_secret]
  
  redirect '/'
end

get '/auth/twitter/logout' do
    #session.each_value do |value|
    #    value = nil
    # end
  session.clear 
  redirect '/'
end