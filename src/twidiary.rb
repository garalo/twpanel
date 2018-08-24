# coding: utf-8

require 'twitter'

class TwiDiary
  def group_by_month(tweets)
    result = Hash.new{|hash, key| hash[key] = []}
    tweets.each do |tweet|
      date = tweet.created_at.getlocal.strftime("%Y-%m")
      result[date] << tweet
    end
    result
  end
end
