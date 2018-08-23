require 'sinatra'
require 'sinatra/reloader'
require 'omniauth-twitter'

configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, 'FMY49JTN57AiLxqtgbE4push7', 'MSv1ZdYRAJoq6RDcKGIEftqWtxrDoxntEQAj2l5dif7LVrrorp', callback_url: "http://127.0.0.1:4567/auth/twitter/callback" # use ENV variables instead :)
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