require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-twitter'

configure do
  enable :sessions
  use OmniAuth::Builder do
    #_ak_adem için keys
    provider :twitter, '1TEwFFzAyfDGoqKgs1kenF6Nh', 'IDUcFEFaN9J9eFgQBLCYfQ9R1bvfvgUyfROG4uMzI2MmoRNCtm', callback_url: "http://127.0.0.1:4567/auth/twitter/callback" # use ENV variables instead :)
  end
end

get '/' do
  @uname = session[:uname]
  erb :index
end

get '/auth/twitter/callback' do
  session[:uname] = env['omniauth.auth']['extra']['raw_info']['screen_name']
  redirect '/'
end

get '/auth/twitter/logout' do
  session.clear 
  redirect '/'
end