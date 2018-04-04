require "rubygems"
require "twitter"
require "json"
require "faraday"

# things you must configure
TWITTER_USER = ENV['TWITTER_USER']
MAX_AGE_IN_DAYS = ENV['MAX_AGE_IN_DAYS'].to_i || 7

# get these from dev.twitter.com
CONSUMER_KEY = ENV['TWITTER_CONSUMER_KEY']
CONSUMER_SECRET = ENV['TWITTER_CONSUMER_SECRET']
OAUTH_TOKEN = ENV['TWITTER_OAUTH_TOKEN']
OAUTH_TOKEN_SECRET = ENV['TWITTER_OAUTH_TOKEN_SECRET']

### you shouldn't have to change anything below this line ###

MAX_AGE_IN_SECONDS = MAX_AGE_IN_DAYS*24*60*60
NOW_IN_SECONDS = Time.now

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = OAUTH_TOKEN
  config.access_token_secret = OAUTH_TOKEN_SECRET
end

faves = []
oldest_fave_id = 9000000000000000000
got_faves = true

puts "Starting tweet unfavouriting for user: #{TWITTER_USER}"

while got_faves do
  begin
    new_faves = client.favorites(TWITTER_USER,{:count => 200, :max_id => oldest_fave_id})

    if (new_faves.length > 0) then
      oldest_fave_id = new_faves.last.id - 1 # the - 1 is important, because of course it is
      faves += new_faves
      puts "Retrieving more favourited tweets..."
    else
      puts "All favourites retrieved. Found #{faves.length}."
      got_faves = false
    end

  rescue Twitter::Error::TooManyRequests => e
    puts "Hit the rate limit. Pausing for #{e.rate_limit.reset_in} seconds..."
    sleep e.rate_limit.reset_in
    retry

  rescue StandardError => e
    puts e.inspect
    exit
  end
end

total_fave = faves.length
faves.each_with_index do |fave, idx|
  idx += 1
  begin
    faved_tweet_age = NOW_IN_SECONDS - fave.created_at
    if faved_tweet_age > MAX_AGE_IN_SECONDS
      puts "Unfavoriting tweet #{fave.id} (#{idx}/#{total_fave})"
      client.unfavorite(fave.id)
    else
      puts "Skipping favourited tweet #{fave.id} (#{idx}/#{total_fave})"
    end

  rescue Twitter::Error::TooManyRequests => e
    puts "Hit the rate limit. Pausing for #{e.rate_limit.reset_in} seconds..."
    sleep e.rate_limit.reset_in
    retry

  rescue StandardError => e
    puts e.inspect
    exit
  end
end
