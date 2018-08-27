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
    #_ak_adem için keys for heroku
    #provider :twitter, '1TEwFFzAyfDGoqKgs1kenF6Nh', 'IDUcFEFaN9J9eFgQBLCYfQ9R1bvfvgUyfROG4uMzI2MmoRNCtm', callback_url: "http://127.0.0.1:4567/auth/twitter/callback" # use ENV variables instead :)
    #_siyahgolge icin keys for local
    #provider :twitter, 'FMY49JTN57AiLxqtgbE4push7', 'MSv1ZdYRAJoq6RDcKGIEftqWtxrDoxntEQAj2l5dif7LVrrorp'
   
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



get '/kisifav' do
  erb :kisifav
end

post '/kisifav' do
  @kisi = params[:q]
  @no = params[:no]
    # burası kendi user_timeline'ı veriyor. aradığın kişinin değil.
    #twitter.user_timeline(params[:q].to_s, { count: params[:no].to_i }, exclude: "retweets").each do |tweet|
      twitter.search("from:#{@kisi .to_s}").take(params[:no].to_i).each do |tweet|  
        begin
         # logger.info "Kimden : #{tweet.user.screen_name}: ====>>> #{tweet.text}"
         # logger.info "URL : #{tweet.url}"
          twitter.favorite(tweet)
           rescue Twitter::Error::Forbidden
          begin
            next if twitter.favorite(tweet)
          rescue Twitter::Error::Forbidden
            # either retweet or unretweet failed and there's no way to proceed
          end
          rescue Twitter::Error::Unauthorized => e
           logger.info "Unauthorized access"
          rescue => e
        end
        #sleep 3
      end

  erb :kisifavsonuc
end

get '/tagdestek' do
  erb :tagdestek
end

post '/tagdestek' do
  @tag = params[:q]
  @no = params[:no]
  
    twitter.search(params[:q]).take(params[:no].to_i).each do |tweet|
        begin
          #logger.info "Kimden : #{tweet.user.screen_name}: ====>>> #{tweet.text}"
          #logger.info "URL : #{tweet.url}"
          twitter.favorite(tweet)
          twitter.retweet(tweet)
           rescue Twitter::Error::Forbidden
          begin
            next if twitter.favorite(tweet)
            next if twitter.retweet(tweet)
          rescue Twitter::Error::Forbidden
            # either retweet or unretweet failed and there's no way to proceed
          end
          rescue Twitter::Error::Unauthorized => e
           logger.info "Unauthorized access"
          rescue => e
        end
        #sleep 3
      end

  erb :tagdesteksonuc
end


