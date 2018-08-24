# coding: utf-8

require 'sinatra'
require 'twitter'
require 'omniauth-twitter'
require 'json'
require 'dotenv'
require './src/twidiary'

Dotenv.load

set :server, :thin
set :session_secret, DateTime.now.to_s

twidiary = TwiDiary.new

configure do
  enable :sessions
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_CONSUMER_KEY'], ENV['TWITTER_CONSUMER_SECRET']
  end
end

helpers do
  def logged_in?
    session[:twitter_oauth]
  end

  def twitter
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token = session[:twitter_oauth][:token]
      config.access_token_secret = session[:twitter_oauth][:secret]
    end
  end
end

before do
  pass if request.path_info =~ /^\/auth\//
  redirect to('/auth/twitter') unless logged_in?
end

get '/auth/failure' do
end

get '/auth/twitter/callback' do
  session[:twitter_oauth] = env['omniauth.auth'][:credentials]
  redirect to('/')
end

get '/' do
  @oauth = session[:twitter_oauth]
  #@timeline = twitter.home_timeline
  @user = twitter.user
  @tweets = twitter.user_timeline(@user, { count: 300 })
  @groupedtweets = twidiary.group_by_month(@tweets)
  erb :index
end

get '/timeline' do
  @oauth = session[:twitter_oauth]
  @timeline = twitter.home_timeline
  @user = twitter.user
  erb :tline
end


get '/logout' do
  session.clear
  redirect to('/')
end
