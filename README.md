# Twitter Cleaner

This container is designed as a "run once at intervals" (ie. crontab) rather than a leave running kind of situation.

Depending on what you enable, it will delete and unfavourite/unlike tweets older than x days.

The delete and unfavourite scripts are modified versions of:
* Unfav Tweets: https://gist.github.com/robinsloan/3688616
* Delete Tweets https://gist.github.com/robinsloan/5cbb76d9f8ab7ec15b5c811dd671959a

## Getting started
To get started you will need to setup an app on https://apps.twitter.com

This will give you your `Consumer Key` and `Consumer Secret` (available on the "Keys and Access Tokens" page once you've created an app.

On the "Keys and Access Tokens" page, you will also need to create yourself an "Access Token" so that you have an `Access Token` and `Access Token Secret`.

## Environment variables
| Variable | Value | Description |
| --- | --- | --- |
| TWITTER_USER | your twitter username | Your twitter username |
| MAX_AGE_IN_DAYS | 7 | The number of days worth of tweets you'd like to keep (this is obviously dependent on how often you run this container too) |
| ENABLE_TWEET_DELETE | 0 or 1 | Enables deletion of tweets older than MAX_AGE_IN_DAYS |
| ENABLE_TWEET_UNFAV | 0 or 1 | Enables unfavouriting of tweets that are older than MAX_AGE_IN_DAYS (this is the age of the favourited tweet, rather than when you favourited it) |
| TWITTER_CONSUMER_KEY | | Your app consumer key (generated in Getting Started)|
| TWITTER_CONSUMER_SECRET | | Your app consumer key secret (generated in Getting Started) |
| TWITTER_OAUTH_TOKEN | | Your access token (generated in Getting Started) |
| TWITTER_OAUTH_TOKEN_SECRET | | Your access token secret (generated in Getting Started) |

## Building the image
```
git clone https://github.com/mdusher/twitter-cleaner.git
cd twitter-cleaner
docker build --tag "tweet-cleaner" --no-cache .
```
Ta da, you're done. You have a nice new docker image.

## Running the container
Once you've built the image just run:
```
docker run --rm --name twitter-cleaner \
           -e "ENABLE_TWEET_DELETE=1" \
           -e "ENABLE_TWEET_UNFAV=1" \
           -e "TWITTER_USER=mushyyyy" \
           -e "MAX_AGE_IN_DAYS=7" \
           -e "TWITTER_CONSUMER_KEY=xxxxxxxxxxxxxxxxxxxxxxxxx" \
           -e "TWITTER_CONSUMER_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
           -e "TWITTER_OAUTH_TOKEN=xxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
           -e "TWITTER_OAUTH_TOKEN_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" \
           twitter-cleaner
```

## Running with docker-compose
Let's be honest, this is way easier.
Setup your `.env` file with your environment variables (example is provided) and then just run `docker-compose up` and bam. It builds and runs it for you.
