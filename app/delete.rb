require "rubygems"
require "twitter"
require "json"

# things you must configure
TWITTER_USER = ENV['TWITTER_USER']
MAX_AGE_IN_DAYS = ENV['MAX_AGE_IN_DAYS'].to_i || 1 # anything older than this is deleted

# get these from dev.twitter.com
CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET']
OAUTH_TOKEN = ENV['TWITTER_OAUTH_TOKEN']
OAUTH_TOKEN_SECRET = ENV['TWITTER_OAUTH_TOKEN_SECRET']
KEEP_TWEETS = ENV['KEEP_TWEETS'] || ""

### you shouldn't have to change anything below this line ###

MAX_AGE_IN_SECONDS = MAX_AGE_IN_DAYS*24*60*60
NOW_IN_SECONDS = Time.now

TWEETS_PER_REQUEST = 200

### A METHOD ###

def delete_from_twitter(tweet, client)
  begin
    client.destroy_status(tweet.id)
  rescue StandardError => e
    puts e.inspect
    puts "Error deleting #{tweet.id}; exiting"
    exit
  else
    puts "Deleted #{tweet.id}"
  end
end

### WE BEGIN ###

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = OAUTH_TOKEN
  config.access_token_secret = OAUTH_TOKEN_SECRET
end

puts "Starting tweet delete for user: #{TWITTER_USER}"
puts "Max age: #{MAX_AGE_IN_DAYS} days"

tweets = []
got_tweets = true
oldest_tweet_id = 9000000000000000000

while got_tweets do
  begin
    new_tweets = client.user_timeline(TWITTER_USER, {:count => TWEETS_PER_REQUEST,
                                                     :max_id => oldest_tweet_id,
                                                     :include_entities => false,
                                                     :include_rts => true})

    if (new_tweets.length > 0) then
      puts "Retrieving more tweets.."
      oldest_tweet_id = new_tweets.last.id - 1
      tweets += new_tweets
    else
      got_tweets = false
    end

  rescue Twitter::Error::TooManyRequests => e
    puts "Hit the rate limit; pausing for #{e.rate_limit.reset_in} seconds"
    sleep e.rate_limit.reset_in
    retry

  rescue StandardError => e
    puts e.inspect
    exit
  end
end

puts "#{tweets.length} tweets found"

total_tweets = tweets.length
tweets_to_keep = KEEP_TWEETS.gsub(/\s+/, "").split(',')
tweets.each_with_index do |tweet, idx|
  begin
    idx += 1
    tweet_age = NOW_IN_SECONDS - tweet.created_at
    tweet_age_in_days = (tweet_age/(24*60*60)).round
    if (tweet_age < MAX_AGE_IN_SECONDS) then
      puts "Ignored tweet #{tweet.id} (#{idx}/#{total_tweets})"
    elsif tweets_to_keep.include?(tweet.id) then
      puts "Excluded tweet #{tweet.id} (#{idx}/#{total_tweets})"
    else
      puts "Deleted tweet #{tweet.id} (#{idx}/#{total_tweets})"
      delete_from_twitter(tweet, client)
    end

  rescue Twitter::Error::TooManyRequests => e
    puts "Hit the rate limit; pausing for #{e.rate_limit.reset_in} seconds"
    sleep e.rate_limit.reset_in
    retry

  rescue StandardError => e
    puts e.inspect
    exit
  end
end
